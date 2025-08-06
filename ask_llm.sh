#!/bin/bash

# Lock file
LOCK_DIR="/tmp/ask_llm.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Another instance is already running."
    exit 1
fi
trap 'rm -rf "$LOCK_DIR"' EXIT

# Get the model name from the first argument, or use a default
#MODEL=${1:-"gemma3:27b"}
MODEL=${1:-"gpt-oss:20b"}

# Get the prompt from the user using an input box
#PROMPT=$(kdialog --title "Ask LLM" --inputbox "Enter your prompt for $MODEL:")
# Alternatively, comment above and uncomment or add your own tool for the interface:
PROMPT=$(wofi --dmenu --prompt "$PROMPT_TEXT" --lines 1 --hide-scroll --no-actions)
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

    # -- MEMORY: Use a temporary file for the CLEANED response --
    local clean_response_file
    clean_response_file=$(mktemp)

    # Pipe the raw output to the Deno script and pass the temporary filename
    # as an argument for the script to write the clean response to.
    /usr/bin/stdbuf -oL /usr/local/bin/ollama run "$model" "$CONVERSATION_HISTORY $current_prompt" | \
    /home/linuxbrew/.linuxbrew/bin/deno run --allow-read --allow-write --allow-run "$RENDERER_SCRIPT" "$clean_response_file"

    # -- MEMORY: Update the history with the CLEAN exchange --
    # The response is read from the file prepared by our Deno script.
    local assistant_response
    assistant_response=$(<"$clean_response_file")
    
    if [ -n "$assistant_response" ]; then
        CONVERSATION_HISTORY+="User: $current_prompt\nAssistant: $assistant_response\n\n"
    fi

    # Clean up the temporary file
    rm "$clean_response_file"
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
