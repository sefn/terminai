#!/bin/bash

# ---- CONFIGURATION ----
# Model to use for the chat
MODEL=${1:-"magistral-small-2509-codiac:latest"}

# Terminal to use
launch_terminal() {
    local script_to_run="$1"
    foot -W 200x40 --title "LLM Chat: $MODEL" "$script_to_run"
}
# ---- END CONFIGURATION ----

# ---- SCRIPT LOGIC ----
LOCK_DIR="/tmp/ask_llm.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Another instance is already running."
    exit 1
fi
trap 'rm -rf "$LOCK_DIR"' EXIT

# Create the helper script file
HELPER_SCRIPT=$(mktemp)

# Get the initial prompt from the user
PROMPT=$(wofi --dmenu --prompt "$PROMPT_TEXT" --lines 1 --hide-scroll --no-actions)
if [ $? -ne 0 ] || [ -z "$PROMPT" ]; then
    rm -f "$HELPER_SCRIPT"
    exit 0
fi

# --- Dynamically generate the helper script content ---
# Note: Expects render_stream to have this path: /usr/local/bin/render_stream.ts
# Adjust absolute paths to dependency runtimes like stdbuf, ollama and deno if applicable
cat > "$HELPER_SCRIPT" << EOF
#!/bin/bash

trap 'rm -f "\$0"' EXIT

MODEL_NAME="$MODEL"
INITIAL_PROMPT="$PROMPT"

RENDERER_SCRIPT="/usr/local/bin/render_stream.ts"
CONVERSATION_HISTORY=""

run_chat() {
    local current_prompt="\$2"
    local model="\$1"
    local clean_response_file
    clean_response_file=\$(mktemp)

    stdbuf -oL ollama run "\$model" "\$CONVERSATION_HISTORY \$current_prompt" | \\
    /home/linuxbrew/.linuxbrew/bin/deno run --allow-read --allow-write --allow-run "\$RENDERER_SCRIPT" "\$clean_response_file" "\$current_prompt"

    local assistant_response
    assistant_response=\$(<"\$clean_response_file")

    if [ -n "\$assistant_response" ]; then
        CONVERSATION_HISTORY+="User: \$current_prompt\nAssistant: \$assistant_response\n\n"
    fi

    rm "\$clean_response_file"
}

echo "Chatting with \$MODEL_NAME. Type 'exit' or 'quit' to close."
echo
echo "---"
echo

run_chat "\$MODEL_NAME" "\$INITIAL_PROMPT"
echo "---"
echo

while true; do
    follow_up_prompt=\$(gum write --placeholder "")

    if [ -z "\$follow_up_prompt" ]; then
      continue
    fi

    if [[ "\$follow_up_prompt" == "exit" || "\$follow_up_prompt" == "quit" ]]; then
      break
    fi

    run_chat "\$MODEL_NAME" "\$follow_up_prompt"
    echo "---"
    echo
done
EOF

# Make the helper script executable
chmod +x "$HELPER_SCRIPT"

# Launch terminal
launch_terminal "$HELPER_SCRIPT"
