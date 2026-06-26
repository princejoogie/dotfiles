#!/usr/bin/env bash
# Deploy agent-agnostic skills + MCP to opencode, Codex, and Claude Code.
# Idempotent — safe to re-run. See PLAN.md for design.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PKG="agents"
AGENTS_SKILLS="$HOME/.agents/skills"

# Agents that do NOT read ~/.agents/skills get a per-skill symlink farm here.
BRIDGE_DIRS=( "$HOME/.claude/skills" )

hdr() { printf '\n== %s ==\n' "$*"; }
log() { printf '   %s\n' "$*"; }

# 1. prereqs ------------------------------------------------------------------
# ~/.claude/skills as a REAL dir keeps the Case-2 child-symlink bridge layout
# (sidesteps the historical ~/.claude/skills-as-symlink discovery bug).
hdr "prereqs"
mkdir -p "$HOME/.claude/skills" "$HOME/.config/opencode" "$HOME/.codex"
log "ensured ~/.claude/skills, ~/.config/opencode, ~/.codex"

# 2. stow ---------------------------------------------------------------------
hdr "stow $PKG"
stow -d "$DOTFILES" -t "$HOME" -R "$PKG"
log "~/.agents -> $(readlink "$HOME/.agents")"
log "~/.agents/skills: $(find "$AGENTS_SKILLS" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ') skills"

# 3. Claude (and other non-.agents agents) skills bridge ----------------------
hdr "skills bridge"
for dst in "${BRIDGE_DIRS[@]}"; do
  mkdir -p "$dst"
  # drop our previously-created links (so removed skills don't linger)
  find "$dst" -maxdepth 1 -type l | while read -r link; do
    case "$(readlink "$link")" in
      *"/.agents/skills/"*) rm -f "$link" ;;
    esac
  done
  n=0
  for s in "$AGENTS_SKILLS"/*/; do
    [ -d "$s" ] || continue
    ln -sfn "${s%/}" "$dst/$(basename "$s")"
    n=$((n + 1))
  done
  log "$dst: $n skills linked"
done

# 4. Codex: enable skills feature --------------------------------------------
hdr "codex skills flag"
CODEX_CFG="$HOME/.codex/config.toml"
[ -f "$CODEX_CFG" ] || : >"$CODEX_CFG"
if grep -qE '^[[:space:]]*skills[[:space:]]*=[[:space:]]*true' "$CODEX_CFG"; then
  log "already enabled"
elif grep -qE '^[[:space:]]*skills[[:space:]]*=' "$CODEX_CFG"; then
  log "WARNING: a 'skills =' key exists but is not 'true' — leaving as-is"
else
  cp "$CODEX_CFG" "$CODEX_CFG.agents-bak.$$"
  if grep -qE '^\[features\]' "$CODEX_CFG"; then
    awk '1; /^\[features\]/ && !ins {print "skills = true"; ins=1}' \
      "$CODEX_CFG" >"$CODEX_CFG.tmp" && mv "$CODEX_CFG.tmp" "$CODEX_CFG"
    log "added 'skills = true' under existing [features]"
  else
    printf '\n[features]\nskills = true\n' >>"$CODEX_CFG"
    log "appended [features] skills = true"
  fi
fi

# 5. MCP fan-out -------------------------------------------------------------
# Render mcp/servers.json (neutral mcpServers shape) into each tool's own config.
hdr "mcp fan-out"
SRC="$DOTFILES/$PKG/mcp/servers.json"
if [ ! -f "$SRC" ]; then
  log "no mcp/servers.json — skipping"
else
  # 5a. opencode -> .mcp in the repo opencode.json (live via stow symlink)
  OC="$DOTFILES/$PKG/.config/opencode/opencode.json"
  jq --slurpfile src "$SRC" '
    def fixenv: gsub("\\$\\{(?<v>[A-Za-z_][A-Za-z0-9_]*)\\}"; "{env:\(.v)}");
    def fixval: if type=="string" then fixenv else . end;
    .mcp = ($src[0].mcpServers | with_entries(.value |= (
      if (.type=="http" or .type=="sse" or has("url"))
      then {type:"remote", url:(.url|fixenv)}
           + (if .headers then {headers:(.headers|map_values(fixval))} else {} end)
      else {type:"local", command:([.command]+(.args//[])), enabled:true}
           + (if ((.env//{})|length)>0 then {environment:(.env|map_values(fixval))} else {} end)
      end)))
  ' "$OC" >"$OC.tmp" && mv "$OC.tmp" "$OC"
  log "opencode: $(jq '.mcp|length' "$OC") servers -> opencode.json"

  # 5b. claude -> surgical .mcpServers merge into ~/.claude.json (stateful file!)
  CJ="$HOME/.claude.json"
  if [ -f "$CJ" ]; then
    cp "$CJ" "$CJ.agents-bak"
    jq --slurpfile src "$SRC" '.mcpServers = $src[0].mcpServers' "$CJ" >"$CJ.tmp" && mv "$CJ.tmp" "$CJ"
  else
    jq -n --slurpfile src "$SRC" '{mcpServers: $src[0].mcpServers}' >"$CJ"
  fi
  log "claude: $(jq '.mcpServers|length' "$CJ") servers -> ~/.claude.json"

  # 5c. codex -> managed [mcp_servers.*] block in ~/.codex/config.toml (stateful!)
  # NOTE: additive — pre-existing [mcp_servers.*] outside the markers are kept.
  # A server here whose name also exists outside the block = duplicate TOML table.
  CC="$HOME/.codex/config.toml"
  BEGIN="# >>> agents-mcp (generated) >>>"
  END="# <<< agents-mcp <<<"
  block=$(jq -r '
    def esc: gsub("\\\\";"\\\\") | gsub("\"";"\\\"");
    .mcpServers | to_entries[] |
    "[mcp_servers.\(.key)]",
    ( .value as $v |
      if ($v.type=="http" or $v.type=="sse" or ($v|has("url")))
      then "url = \"\($v.url|esc)\""
      else "command = \"\($v.command|esc)\"",
           (if (($v.args//[])|length)>0 then "args = [" + ([$v.args[]|"\"\(.|esc)\""]|join(", ")) + "]" else empty end),
           (if (($v.env//{})|length)>0 then "env = { " + ([$v.env|to_entries[]|"\(.key) = \"\(.value|esc)\""]|join(", ")) + " }" else empty end)
      end ),
    ""
  ' "$SRC")
  [ -f "$CC" ] || : >"$CC"
  cp "$CC" "$CC.agents-bak"
  awk -v b="$BEGIN" -v e="$END" '$0==b{s=1} s&&$0==e{s=0;next} !s{print}' "$CC" >"$CC.tmp"
  { cat "$CC.tmp"; printf '\n%s\n%s\n%s\n' "$BEGIN" "$block" "$END"; } >"$CC"
  rm -f "$CC.tmp"
  log "codex: $(jq '.mcpServers|length' "$SRC") servers -> ~/.codex/config.toml block"
fi

hdr "done"
