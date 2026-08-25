/** @jsxImportSource @opentui/solid */

import { RGBA } from "@opentui/core";
import type { JSX } from "@opentui/solid";
import {
  For,
  Show,
  createEffect,
  createMemo,
  createSignal,
  onCleanup,
} from "solid-js";
import { spawn } from "node:child_process";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

const REFRESH_MS = 5 * 60 * 1000;
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

type UsageWindow = {
  usedPercent: number;
  resetsAt?: number;
  windowMinutes?: number;
  startsAt?: number;
};

type UsageSnapshot = {
  provider: "codex" | "xai";
  plan?: string;
  windows: UsageWindow[];
  credits?: number;
};

type ProviderState =
  | { status: "loading" }
  | { status: "ready"; snapshot: UsageSnapshot }
  | { status: "error"; message: string };

type UsageState = {
  codex: ProviderState;
  xai: ProviderState;
  refreshing: boolean;
  updatedAt: number;
  open: boolean;
};

type Context = {
  theme: {
    text: {
      default: RGBA;
      subdued: RGBA;
      feedback: {
        error: { default: RGBA };
        success: { default: RGBA };
        warning: { default: RGBA };
      };
    };
    markdown: { link: RGBA };
    background: { default: RGBA };
  };
  ui: {
    slot(input: {
      append: "sidebar.content";
      render(props: { sessionID: string }): JSX.Element;
    }): () => void;
  };
  storage: {
    memory<T>(
      key: string,
      options: { initial: T },
    ): [T, (update: (draft: T) => void) => void];
  };
};

type CodexRateWindow = {
  usedPercent?: number;
  resetsAt?: number | null;
  windowDurationMins?: number | null;
};

type CodexRateLimits = {
  primary?: CodexRateWindow | null;
  secondary?: CodexRateWindow | null;
  planType?: string | null;
};

type CodexRateLimitsResponse = {
  rateLimits?: CodexRateLimits;
};

type XaiCredential = {
  token: string;
  userID?: string;
  expiresAt?: number;
};

type XaiBillingConfig = {
  creditUsagePercent?: number;
  currentPeriod?: { start?: string; end?: string };
  monthlyLimit?: { val?: number };
  used?: { val?: number };
  onDemandCap?: { val?: number };
  onDemandUsed?: { val?: number };
  prepaidBalance?: { val?: number };
  billingPeriodStart?: string;
  billingPeriodEnd?: string;
};

function errorMessage(error: unknown) {
  if (error instanceof Error && error.message) return error.message;
  if (
    typeof error === "object" &&
    error !== null &&
    "message" in error &&
    typeof error.message === "string"
  )
    return error.message;
  if (typeof error === "string" && error) return error;
  return "Usage unavailable";
}

function clampPercent(value: number) {
  return Math.max(0, Math.min(100, value));
}

function mutedBarColor(theme: Context["theme"]) {
  const foreground = theme.text.subdued.toInts();
  const background = theme.background.default.toInts();
  return RGBA.fromInts(
    Math.round(background[0] + (foreground[0] - background[0]) * 0.25),
    Math.round(background[1] + (foreground[1] - background[1]) * 0.25),
    Math.round(background[2] + (foreground[2] - background[2]) * 0.25),
  );
}

function formatPlan(plan?: string) {
  if (!plan) return "";
  return plan
    .replace(/^prolite$/i, "Pro")
    .split(/[_-]/)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function formatDuration(milliseconds: number) {
  if (!Number.isFinite(milliseconds) || milliseconds <= 0) return "now";
  const minutes = Math.max(1, Math.round(milliseconds / 60_000));
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  if (hours < 24)
    return `${hours}h${remainingMinutes ? ` ${remainingMinutes}m` : ""}`;
  const days = Math.floor(hours / 24);
  const remainingHours = hours % 24;
  return `${days}d${remainingHours ? ` ${remainingHours}h` : ""}`;
}

function resetText(window: UsageWindow, now: number) {
  if (!window.resetsAt) return "Reset unknown";
  const remaining = window.resetsAt - now;
  if (remaining <= 0) return "Resetting";
  return `Resets in ${formatDuration(remaining)}`;
}

function pace(window: UsageWindow, now: number) {
  if (!window.resetsAt || !window.windowMinutes) return undefined;
  const duration = window.windowMinutes * 60_000;
  const start = window.startsAt ?? window.resetsAt - duration;
  const elapsed = Math.max(0, Math.min(duration, now - start));
  if (elapsed <= 0) return undefined;

  const expected = (elapsed / duration) * 100;
  const delta = window.usedPercent - expected;
  const remaining = Math.max(0, window.resetsAt - now);
  const eta =
    window.usedPercent > 0
      ? ((100 - window.usedPercent) * elapsed) / window.usedPercent
      : Infinity;
  const willLast = eta >= remaining;
  const position =
    !willLast || delta >= 5
      ? `${Math.max(1, Math.round(delta))}% over pace`
      : delta <= -5
        ? `${Math.round(-delta)}% under pace`
        : "On pace";
  return {
    text: `${position} · ${willLast ? "lasts to reset" : `empty in ${formatDuration(eta)}`}`,
    warning: !willLast || delta >= 5,
  };
}

function requestCodexUsage(signal: AbortSignal) {
  return new Promise<CodexRateLimitsResponse>((resolve, reject) => {
    const child = spawn(
      "codex",
      ["-s", "read-only", "-a", "never", "app-server"],
      {
        stdio: ["pipe", "pipe", "pipe"],
      },
    );
    let stdout = "";
    let settled = false;

    const finish = (result: CodexRateLimitsResponse | Error) => {
      if (settled) return;
      settled = true;
      clearTimeout(timeout);
      signal.removeEventListener("abort", abort);
      child.stdin.end();
      child.kill("SIGTERM");
      if (result instanceof Error) reject(result);
      else resolve(result);
    };
    const abort = () => finish(new Error("Refresh cancelled"));
    const timeout = setTimeout(
      () => finish(new Error("Codex usage timed out")),
      15_000,
    );
    timeout.unref?.();
    signal.addEventListener("abort", abort, { once: true });

    child.once("error", (error) =>
      finish(
        new Error(
          error.message.includes("ENOENT")
            ? "Codex CLI not found"
            : error.message,
        ),
      ),
    );
    child.once("close", (code) => {
      if (!settled)
        finish(new Error(`Codex app-server exited with code ${code ?? 1}`));
    });
    child.stdout.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
      let newline = stdout.indexOf("\n");
      while (newline !== -1) {
        const line = stdout.slice(0, newline);
        stdout = stdout.slice(newline + 1);
        newline = stdout.indexOf("\n");
        if (!line.trim()) continue;

        let message: {
          id?: number;
          result?: CodexRateLimitsResponse;
          error?: { message?: string };
        };
        try {
          message = JSON.parse(line);
        } catch {
          continue;
        }
        if (message.id === 1) {
          child.stdin.write(
            `${JSON.stringify({ id: 2, method: "account/rateLimits/read" })}\n`,
          );
        }
        if (message.id === 2) {
          if (message.error)
            finish(
              new Error(message.error.message || "Codex usage unavailable"),
            );
          else finish(message.result ?? {});
        }
      }
    });

    child.stdin.write(
      `${JSON.stringify({
        id: 1,
        method: "initialize",
        params: {
          clientInfo: {
            name: "opencode-usage-sidebar",
            title: "OpenCode Usage Sidebar",
            version: "0.1.0",
          },
          capabilities: { experimentalApi: true },
        },
      })}\n`,
    );
  });
}

async function fetchCodexUsage(signal: AbortSignal): Promise<UsageSnapshot> {
  const response = await requestCodexUsage(signal);
  const limits = response.rateLimits;
  if (!limits) throw new Error("Connect a Codex subscription");

  const windows = [limits.primary, limits.secondary]
    .filter((window): window is CodexRateWindow =>
      Boolean(window && Number.isFinite(window.usedPercent)),
    )
    .map((window) => ({
      usedPercent: clampPercent(window.usedPercent ?? 0),
      resetsAt: window.resetsAt ? window.resetsAt * 1_000 : undefined,
      windowMinutes: window.windowDurationMins ?? undefined,
    }));
  if (!windows.length) throw new Error("Codex did not return a usage window");

  return {
    provider: "codex",
    plan: limits.planType ?? undefined,
    windows,
  };
}

function jwtSubject(token: string) {
  try {
    const payload = JSON.parse(
      Buffer.from(token.split(".")[1] ?? "", "base64url").toString("utf8"),
    ) as {
      sub?: string;
      exp?: number;
    };
    return {
      userID: payload.sub,
      expiresAt: payload.exp ? payload.exp * 1_000 : undefined,
    };
  } catch {
    return {};
  }
}

async function xaiCredentials() {
  const result: XaiCredential[] = [];
  const dataHome =
    process.env.XDG_DATA_HOME || join(homedir(), ".local", "share");

  try {
    const auth = JSON.parse(
      await readFile(join(dataHome, "opencode", "auth.json"), "utf8"),
    ) as {
      xai?: { access?: string; expires?: number };
    };
    if (auth.xai?.access) {
      const claims = jwtSubject(auth.xai.access);
      result.push({
        token: auth.xai.access,
        userID: claims.userID,
        expiresAt: auth.xai.expires ?? claims.expiresAt,
      });
    }
  } catch {}

  try {
    const grokHome = process.env.GROK_HOME || join(homedir(), ".grok");
    const auth = JSON.parse(
      await readFile(join(grokHome, "auth.json"), "utf8"),
    ) as Record<
      string,
      { key?: string; user_id?: string; expires_at?: string }
    >;
    for (const entry of Object.values(auth)) {
      if (!entry?.key) continue;
      const claims = jwtSubject(entry.key);
      result.push({
        token: entry.key,
        userID: entry.user_id ?? claims.userID,
        expiresAt: entry.expires_at
          ? Date.parse(entry.expires_at)
          : claims.expiresAt,
      });
    }
  } catch {}

  const now = Date.now() + 60_000;
  return result.filter(
    (credential, index) =>
      (!credential.expiresAt || credential.expiresAt > now) &&
      result.findIndex((candidate) => candidate.token === credential.token) ===
        index,
  );
}

async function xaiRequest(
  path: string,
  credential: XaiCredential,
  signal: AbortSignal,
) {
  const response = await fetch(`https://cli-chat-proxy.grok.com/v1/${path}`, {
    headers: {
      Authorization: `Bearer ${credential.token}`,
      "X-XAI-Token-Auth": "xai-grok-cli",
      ...(credential.userID ? { "x-userid": credential.userID } : {}),
      Accept: "application/json",
    },
    signal,
  });
  if (!response.ok)
    throw new Error(
      response.status === 401 || response.status === 403
        ? "xAI login expired"
        : `xAI usage failed (${response.status})`,
    );
  return response.json() as Promise<Record<string, unknown>>;
}

async function fetchXaiUsage(signal: AbortSignal): Promise<UsageSnapshot> {
  const credentials = await xaiCredentials();
  if (!credentials.length) throw new Error("Connect xAI or run grok login");

  let lastError: unknown;
  for (const credential of credentials) {
    try {
      const billing = await xaiRequest(
        "billing?format=credits",
        credential,
        signal,
      );
      const config = (billing.config ?? billing) as XaiBillingConfig;
      const period = config.currentPeriod;
      const startsAt = period?.start
        ? Date.parse(period.start)
        : config.billingPeriodStart
          ? Date.parse(config.billingPeriodStart)
          : undefined;
      const resetsAt = period?.end
        ? Date.parse(period.end)
        : config.billingPeriodEnd
          ? Date.parse(config.billingPeriodEnd)
          : undefined;
      const windowMinutes =
        startsAt && resetsAt
          ? Math.round((resetsAt - startsAt) / 60_000)
          : undefined;
      const legacyLimit = config.monthlyLimit?.val;
      const usedPercent = Number.isFinite(config.creditUsagePercent)
        ? config.creditUsagePercent!
        : legacyLimit && Number.isFinite(config.used?.val)
          ? (config.used!.val! / legacyLimit) * 100
          : undefined;
      if (!Number.isFinite(usedPercent))
        throw new Error("xAI did not return a usage percentage");

      const settings: Record<string, unknown> = await xaiRequest(
        "settings",
        credential,
        signal,
      ).catch(() => ({}));
      const plan =
        typeof settings.subscription_tier_display === "string"
          ? settings.subscription_tier_display
          : typeof settings.subscriptionTierDisplay === "string"
            ? settings.subscriptionTierDisplay
            : "SuperGrok";
      return {
        provider: "xai",
        plan,
        windows: [
          {
            usedPercent: clampPercent(usedPercent!),
            startsAt,
            resetsAt,
            windowMinutes,
          },
        ],
        credits: config.prepaidBalance?.val,
      };
    } catch (error) {
      if (signal.aborted) throw error;
      lastError = error;
    }
  }
  throw lastError ?? new Error("xAI usage unavailable");
}

function ProviderCard(props: {
  context: Context;
  name: string;
  state: ProviderState;
  now: number;
}) {
  const theme = props.context.theme;
  const fallback = () =>
    props.state.status === "error"
      ? ` · ${props.state.message}`
      : " · Checking...";
  return (
    <box>
      <Show
        when={props.state.status === "ready" ? props.state.snapshot : undefined}
        fallback={
          <text
            fg={
              props.state.status === "error"
                ? theme.text.feedback.error.default
                : theme.text.subdued
            }
            wrapMode="word"
          >
            <b>{props.name}</b>
            {fallback()}
          </text>
        }
      >
        {(snapshot) => (
          <>
            <box flexDirection="row" justifyContent="space-between">
              <text fg={theme.text.default}>
                <b>{props.name}</b>
              </text>
              <Show when={snapshot().plan}>
                {(plan) => (
                  <text fg={theme.text.subdued}>{formatPlan(plan())}</text>
                )}
              </Show>
            </box>
            <For each={snapshot().windows}>
              {(window) => {
                const used = () => Math.round(window.usedPercent);
                const pacing = () => pace(window, props.now);
                return (
                  <box>
                    <box width="100%" height={1} flexDirection="row">
                      <box
                        height={1}
                        flexBasis={0}
                        flexGrow={used()}
                        overflow="hidden"
                      >
                        <text
                          fg={
                            used() >= 85
                              ? theme.text.feedback.warning.default
                              : theme.markdown.link
                          }
                          wrapMode="none"
                        >
                          {"▄".repeat(100)}
                        </text>
                      </box>
                      <box
                        height={1}
                        flexBasis={0}
                        flexGrow={100 - used()}
                        overflow="hidden"
                      >
                        <text fg={mutedBarColor(theme)} wrapMode="none">
                          {"▄".repeat(100)}
                        </text>
                      </box>
                    </box>
                    <box flexDirection="row" justifyContent="space-between">
                      <text fg={theme.text.subdued}>
                        {resetText(window, props.now)}
                      </text>
                      <text fg={theme.text.subdued}>{used()}% used</text>
                    </box>
                    <Show when={pacing()}>
                      {(item) => (
                        <text
                          fg={
                            item().warning
                              ? theme.text.feedback.warning.default
                              : theme.text.feedback.success.default
                          }
                        >
                          {item().text}
                        </text>
                      )}
                    </Show>
                  </box>
                );
              }}
            </For>
            <Show when={(snapshot().credits ?? 0) > 0}>
              <text fg={theme.text.subdued}>
                Extra credits ${((snapshot().credits ?? 0) / 100).toFixed(2)}
              </text>
            </Show>
          </>
        )}
      </Show>
    </box>
  );
}

function View(props: {
  context: Context;
  state: UsageState;
  refresh: () => Promise<void>;
  setOpen: (open: boolean) => void;
}) {
  const theme = props.context.theme;
  const [spinnerFrame, setSpinnerFrame] = createSignal(0);
  const [now, setNow] = createSignal(Date.now());

  const connected = createMemo(
    () =>
      [props.state.codex, props.state.xai].filter(
        (state) => state.status === "ready",
      ).length,
  );

  createEffect(() => {
    if (!props.state.refreshing) {
      setSpinnerFrame(0);
      return;
    }
    const timer = setInterval(
      () => setSpinnerFrame((frame) => (frame + 1) % SPINNER_FRAMES.length),
      80,
    );
    timer.unref?.();
    onCleanup(() => clearInterval(timer));
  });

  const clock = setInterval(() => setNow(Date.now()), 60_000);
  clock.unref?.();
  onCleanup(() => clearInterval(clock));

  return (
    <box>
      <box flexDirection="row" justifyContent="space-between">
        <box
          flexDirection="row"
          gap={1}
          onMouseDown={() => props.setOpen(!props.state.open)}
        >
          <text fg={theme.text.default}>{props.state.open ? "▼" : "▶"}</text>
          <text fg={theme.text.default}>
            <b>Usage</b>
            <span style={{ fg: theme.text.subdued }}> ({connected()}/2)</span>
          </text>
        </box>
        <text
          fg={
            props.state.refreshing
              ? theme.text.feedback.warning.default
              : theme.text.subdued
          }
          onMouseUp={() => void props.refresh()}
        >
          {props.state.refreshing ? SPINNER_FRAMES[spinnerFrame()] : "󰑐"}
        </text>
      </box>
      <Show when={props.state.open}>
        <ProviderCard
          context={props.context}
          name="OpenAI Codex"
          state={props.state.codex}
          now={now()}
        />
        <ProviderCard
          context={props.context}
          name="xAI Grok"
          state={props.state.xai}
          now={now()}
        />
      </Show>
    </box>
  );
}

const plugin = {
  id: "dotfiles.ai-usage-sidebar",
  setup(context: Context) {
    const [state, updateState] = context.storage.memory<UsageState>("usage", {
      initial: {
        codex: { status: "loading" },
        xai: { status: "loading" },
        refreshing: false,
        updatedAt: 0,
        open: true,
      },
    });
    updateState((draft) => {
      draft.refreshing = false;
    });
    let controller: AbortController | undefined;
    let refreshTimer: ReturnType<typeof setTimeout> | undefined;

    const schedule = (delay = REFRESH_MS) => {
      clearTimeout(refreshTimer);
      refreshTimer = setTimeout(() => void refresh(), delay);
      refreshTimer.unref?.();
    };
    const refresh = async () => {
      controller?.abort();
      controller = new AbortController();
      const signal = controller.signal;
      updateState((draft) => {
        draft.refreshing = true;
      });
      const [codexResult, xaiResult] = await Promise.allSettled([
        fetchCodexUsage(signal),
        fetchXaiUsage(signal),
      ]);
      if (signal.aborted) return;
      updateState((draft) => {
        draft.codex =
          codexResult.status === "fulfilled"
            ? { status: "ready", snapshot: codexResult.value }
            : { status: "error", message: errorMessage(codexResult.reason) };
        draft.xai =
          xaiResult.status === "fulfilled"
            ? { status: "ready", snapshot: xaiResult.value }
            : { status: "error", message: errorMessage(xaiResult.reason) };
        draft.refreshing = false;
        draft.updatedAt = Date.now();
      });
      schedule();
    };

    const unregister = context.ui.slot({
      append: "sidebar.content",
      render: () => (
        <View
          context={context}
          state={state}
          refresh={refresh}
          setOpen={(open) =>
            updateState((draft) => {
              draft.open = open;
            })
          }
        />
      ),
    });

    const age = Date.now() - state.updatedAt;
    if (state.updatedAt && age < REFRESH_MS) schedule(REFRESH_MS - age);
    else void refresh();

    return () => {
      controller?.abort();
      clearTimeout(refreshTimer);
      unregister();
    };
  },
};

export default plugin;
