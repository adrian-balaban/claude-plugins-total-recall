#!/usr/bin/env bash
set -euo pipefail

CACHE="$HOME/.total-recall/.index-cache.txt"

if [ ! -f "$CACHE" ]; then
  echo '{"continue":true}'
  exit 0
fi

INDEX_CONTENT=$(cat "$CACHE")

INSTRUCTIONS="## Total Recall — Active Memory Index

The following memories are already in context. Use keys with get_memories_by_keys before searching.

### Retrieval Decision Tree
1. Scan this injected index first (free — already in context)
2. If key found → get_memories_by_keys(summary=true) for overview
3. If full depth needed → get_memories_by_keys(summary=false)
4. Only use search_index / recall_memory when key NOT in this index

### Capture Rules
- Call store_memory DIRECTLY from main agent (never delegate to subagent)
- Check for duplicates before storing
- Always include executive summary with WHY, not just WHAT
- Preferred categories: architecture, decisions, troubleshooting, meetings, knowledge, journal

### Memory Index
$INDEX_CONTENT"

# hookSpecificOutput REQUIRES hookEventName:"SessionStart" or additionalContext is
# silently dropped (verified against the Claude Code hooks reference). Without it,
# the injected memory index — the plugin's core feature — never reached Claude.
# JSON-encode via node (node is this plugin's hard dependency; python3 is not).
ADDCONTEXT=$(printf '%s' "$INSTRUCTIONS" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>process.stdout.write(JSON.stringify(s)))')
echo "{\"continue\":true,\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":$ADDCONTEXT}}"
