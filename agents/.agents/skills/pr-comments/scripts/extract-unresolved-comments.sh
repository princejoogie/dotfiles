#!/usr/bin/env bash
set -e

# Default to current PR if no argument provided
PR_NUMBER=${1:-$(gh pr view --json number -q .number)}
OUTPUT_FILE=${2:-.tmp/pr-${PR_NUMBER}-comments.md}

if [ -z "$PR_NUMBER" ]; then
  echo "Error: Could not determine PR number. Please specify it as an argument or run this from a branch with an active PR."
  exit 1
fi

echo "Fetching info for PR #$PR_NUMBER..."
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Create a temporary file for the GraphQL query
QUERY_FILE=$(mktemp)
DATA_FILE=$(mktemp)

cat << 'EOF' > "$QUERY_FILE"
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      title
      state
      author { login }
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 100) {
            nodes {
              author { login }
              body
              path
              line
              diffHunk
            }
          }
        }
      }
    }
  }
}
EOF

echo "Querying GitHub GraphQL API..."
gh api graphql -F owner="$OWNER" -F repo="$REPO" -F pr=$PR_NUMBER -F query=@"$QUERY_FILE" > "$DATA_FILE"

echo "Formatting comments..."
node -e "
const fs = require('fs');
const path = require('path');

const data = JSON.parse(fs.readFileSync('$DATA_FILE', 'utf8'));
const pr = data.data.repository.pullRequest;
const threads = pr.reviewThreads.nodes;
const prAuthor = pr.author ? pr.author.login : 'Unknown';

let md = \`# PR Comments for ${PR_NUMBER}\\n\`;
md += \`## \${pr.title}\\n\\n\`;
md += \`- Status: \${pr.state}\\n\`;
md += \`- Author: \${prAuthor}\\n\\n\`;
md += \`## Comments\\n\\n\`;

let unresolvedCount = 0;

for (const thread of threads) {
  if (thread.isResolved) continue;
  
  unresolvedCount++;
  
  const firstComment = thread.comments.nodes[0];
  const file = firstComment.path;
  const line = firstComment.line;
  const hunk = firstComment.diffHunk;
  const ext = path.extname(file).replace('.', '') || 'diff';
  
  md += \`File: \\\`\${file}\${line ? \`:\${line}\` : ''}\\\`\\n\\n\`;
  
  if (hunk) {
    const hunkLines = hunk.split('\\n');
    const displayHunk = hunkLines.length > 15 
      ? hunkLines.slice(0, 15).join('\\n') + '\\n... (hunk truncated)'
      : hunk;
    md += \`\\\`\\\`\\\`\${ext}\\n\${displayHunk}\\n\\\`\\\`\\\`\\n\\n\`;
  }
  
  for (const comment of thread.comments.nodes) {
    const author = comment.author ? comment.author.login : 'Unknown';
    const body = comment.body;
    
    const lines = body.split('\\n');
    md += \`> \\\`@\${author}\\\`: \${lines[0]}\\n\`;
    for (let i = 1; i < lines.length; i++) {
      md += \`> \${lines[i]}\\n\`;
    }
    md += \`\\n\`;
  }
  md += \`---\\n\\n\`;
}

if (unresolvedCount === 0) {
  md += 'No unresolved comments found!\\n';
}

fs.writeFileSync('$OUTPUT_FILE', md);
console.log(\`Done. Formatted \${unresolvedCount} unresolved threads to $OUTPUT_FILE.\`);
"

# Clean up
rm "$QUERY_FILE" "$DATA_FILE"
