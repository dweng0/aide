#!/bin/bash
set -e

REPO="${AIDE_REPO:-$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd)}"
NOTES_DIR="${NOTES_DIR:-$HOME/notes}"
CONTEXT_DIR="${CONTEXT_DIR:-$HOME/.notes-context}"
FISH_CONF_DIR="${FISH_CONF_DIR:-$HOME/.config/fish/conf.d}"

mkdir -p "$NOTES_DIR"
mkdir -p "$CONTEXT_DIR"
mkdir -p "$CONTEXT_DIR/projects"
mkdir -p "$FISH_CONF_DIR"

for f in manifest.md history_index.md user-planner.md daily-goals.md goals-archive.md; do
  target="$CONTEXT_DIR/$f"
  if [ ! -f "$target" ]; then
    case "$f" in
      manifest.md)
        printf "# aide manifest\n" > "$target"
        printf "cleanup_planner: %s/scripts/cleanup_planner.py\n" "$REPO" >> "$target"
        ;;
      history_index.md) printf "## Recent Files\n" > "$target" ;;
      *)                touch "$target" ;;
    esac
  fi
done

fish_file="$FISH_CONF_DIR/aide.fish"
path_line="fish_add_path $REPO/scripts"
if [ ! -f "$fish_file" ] || ! grep -qF "$path_line" "$fish_file"; then
  printf "%s\n" "$path_line" >> "$fish_file"
fi

mkdir -p "$CONTEXT_DIR/daily-briefing"

env_file="$CONTEXT_DIR/.env"
if [ ! -f "$env_file" ]; then
  printf "\n--- Gmail credentials ---\n"
  printf "GMAIL_APP_PASSWORD: Google Account → Security → App Passwords (requires 2-Step Verification)\n\n"
  printf "GMAIL_ADDRESS: "
  read -r gmail_address || true
  printf "GMAIL_APP_PASSWORD: "
  read -r gmail_pw || true
  printf "GMAIL_ADDRESS=%s\nGMAIL_APP_PASSWORD=%s\n" "$gmail_address" "$gmail_pw" > "$env_file"
fi

filter_file="$CONTEXT_DIR/email-filter.md"
if [ ! -f "$filter_file" ]; then
  cat > "$filter_file" <<'EOF'
# Email noise blocklist

Senders matching any pattern below are excluded before the LLM sees your emails.
Add one pattern per line — plain text substring match against the sender address.

- noreply@
- no-reply@
- notifications@
- discord.com
- github.com
- linkedin.com
- marketing@
- newsletter@
EOF
fi

printf "aide installed.\n"
printf "  notes dir:    %s\n" "$NOTES_DIR"
printf "  context dir:  %s\n" "$CONTEXT_DIR"
printf "  fish config:  %s\n" "$fish_file"
