# simple-kde-ai-chat
AI chat client for Linux. Can be modified, but currently uses kdialog for the prompt, and a terminal (e.g. kde-ptyxis) for streaming output and allowing subsequent prompts with memory. Markdown formatting with deno + glow

## Dependencies

* Ollama (with any model installed)
* Deno (for running glow with streaming)
* glow (for markdown formatting output)
* stdbuf (for streaming)
* kdialog, or rofi or wofi (for the dialog prompt. kdialog is default, you can modify a single line in `ask_llm.sh` with your dialog tool of choice)
* tee

## Installation

Move `render_stream.ts` and `ask_llm.sh` to `/usr/local/bin` and make them executable with `chmod +x`.

Then add a keyboard shortcut to launch `ask_llm.sh`, for example SUPER+Backspace, in your DE of choice (like KDE).

You can change the model name in `ask_llm.sh` (default is gemma3:27b) to what you want to use through ollama, and change paths to the commands if needed (currently assumes absolute paths).

If you want to use another dialog for the prompt, for example `rofi` or `wofi`, change the PROMPT line in `ask_llm.sh` from kdialog to whatever. Examples:
* `wofi`: PROMPT=$(wofi --dmenu --prompt "$PROMPT_TEXT" --lines 1 --hide-scroll --no-actions)

That's it.

<img width="448" height="384" alt="image" src="https://github.com/user-attachments/assets/a221f25b-b3d9-428c-bdef-c3cbc16175cf" />

<img width="1033" height="578" alt="image" src="https://github.com/user-attachments/assets/3e47571a-83f2-48f9-bff2-aa0e9bf9cc99" />

