# terminai
Local LLM chat interface for Linux.

Keyboard shortcut to open a prompt dialog, then terminal for output and further chat (with formatting for markdown and thinking tags, chat history).

## Features

Portable and modifiable.
Use a dialog like wofi or kdialog for the prompt, and a terminal (e.g. ptyxis or whatever you like) for streaming output and allowing subsequent prompts with memory. Markdown formatting (and formatting of thinking tags) with deno + glow.

## Dependencies

* Ollama (with any model installed, e.g. gpt-oss or gemma3 etc)
* Deno (for running glow with streaming)
* glow (for markdown formatting output)
* stdbuf (for streaming)
* wofi, or kdialog or rofi (for the dialog prompt. wofi is default, you can modify a single line (PROMPT variable) in `ask_llm.sh` with your dialog tool of choice)
* a terminal of your choice (for the output. kde-ptyxis is default, but you can modify a single line (the last one) in `ask_llm.sh` with your terminal of choice)
* tee

## Installation

Move `render_stream.ts` and `ask_llm.sh` to `/usr/local/bin` and make them executable with `chmod +x`.

Then add a keyboard shortcut to launch `ask_llm.sh`, for example SUPER+Backspace, in your DE of choice (e.g. KDE).

You can change the model name in `ask_llm.sh` (default is gpt-oss:20b) to whatever you want to use through ollama.

You can change the dialog used for the prompt, for example `rofi` or `kdialog` (`wofi` is default). Just change the PROMPT variable in `ask_llm.sh` to whatever. Same for the terminal (last line of `ask_llm.sh`).

## Wofi customization

If you use wofi, you can copy-paste the contents of .config/wofi to your home folder to make it look like the wofi screenshot below.


That's it.

<img width="448" height="384" alt="image" src="https://github.com/user-attachments/assets/a221f25b-b3d9-428c-bdef-c3cbc16175cf" />

<img width="1033" height="578" alt="image" src="https://github.com/user-attachments/assets/3e47571a-83f2-48f9-bff2-aa0e9bf9cc99" />

