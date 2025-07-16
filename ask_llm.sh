#!/bin/bash
# Get the model name from the first argument, or use a default
MODEL=${1:-"gemma3:27b"}

# Get the prompt from the user using an input box
PROMPT=$(kdialog --title "Ask LLM" --inputbox "Enter your prompt for $MODEL:")
# Alternatively, comment above and uncomment or add your own tool for the interface:
#PROMPT=$(wofi --dmenu --prompt "$PROMPT_TEXT" --lines 1 --hide-scroll --no-actions)
#PROMPT=$(rofi --dmenu --prompt "$PROMPT_TEXT" --lines 1 --hide-scroll --no-actions)

if [ $? -ne 0 ] || [ -z "$PROMPT" ]; then
    exit 0
fi

SCRIPTLET='
  RENDERER_SCRIPT="/usr/local/bin/render_stream.ts"

  # -- MEMORY: Initialize an empty conversation history --
  CONVERSATION_HISTORY=""

  run_chat() {
    local current_prompt="$2"
    local model="$1"

    # -- MEMORY: Use a temporary file to capture the response --
    local temp_response_file
    temp_response_file=$(mktemp)

    # -- MEMORY: Prepend the history to the new prompt --
    /usr/bin/stdbuf -oL /usr/local/bin/ollama run "$model" "$CONVERSATION_HISTORY $current_prompt" | \
    /usr/bin/tee "$temp_response_file" | \
    /home/linuxbrew/.linuxbrew/bin/deno run --allow-run "$RENDERER_SCRIPT"

    # -- MEMORY: Update the history with the new exchange --
    local assistant_response
    assistant_response=$(<"$temp_response_file")
    CONVERSATION_HISTORY+="User: $current_prompt\nAssistant: $assistant_response\n\n"

    # Clean up the temporary file
    rm "$temp_response_file"
  }

  echo "Chatting with $1. Type '\''exit'\'' or '\''quit'\'' to close."
  echo "---"

  # Run the initial prompt
  run_chat "$1" "$2"
  echo "---"

  while true; do
    read -p ">> " follow_up_prompt
    if [[ "$follow_up_prompt" == "exit" || "$follow_up_prompt" == "quit" ]]; then
      break
    fi
    # Run follow-up prompt
    run_chat "$1" "$follow_up_prompt"
    echo "---"
  done
'

# Output in terminal - modify for your terminal of choice.
kde-ptyxis --title "LLM Chat: $MODEL" -x "sh -c '$SCRIPTLET' _ \"$MODEL\" \"$PROMPT\""
