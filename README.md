# terminai
Local LLM chat interface for Linux.

Usage: Set a keyboard shortcut to launch the script. This opens a prompt dialog, then a terminal for output and further chat (with formatting for markdown and thinking tags, and chat history).

## Features

Portable and customizable.
Uses a dialog like wofi or kdialog for the prompt, and a terminal (e.g. ptyxis or whatever you like) for streaming output and allowing subsequent prompts with memory. Markdown formatting (and formatting of thinking tags) with deno + glow.

## Dependencies

* Ollama (with any model installed, e.g. gpt-oss or gemma3, etc.)
* Deno (for running glow with streaming)
* glow (for markdown formatting output)
* gum (allowing multi-line input in the prompt, or using your favorite text editor to prompt)
* wofi, or kdialog or rofi (for the dialog prompt. wofi is default, you can modify a single line (PROMPT variable) in `ask_llm.sh` with your dialog tool of choice)
* a terminal of your choice (for the output. `foot` is default, but you can modify a single line (the last one) in `ask_llm.sh` with your terminal of choice)
* stdbuf (for streaming)
* tee

## Installation

Move `render_stream.ts` and `ask_llm.sh` to `/usr/local/bin` and make them executable with `chmod +x`.

Then add a keyboard shortcut to launch `ask_llm.sh`, for example SUPER+Backspace, in your DE of choice (e.g. KDE).

You can change the model name in `ask_llm.sh` (default is gpt-oss:20b) to whatever you want to use through ollama.

You can change the dialog used for the prompt, for example `rofi` or `kdialog` (`wofi` is default). Just change the PROMPT variable in `ask_llm.sh` to whatever. Same for the terminal (last line of `ask_llm.sh`).

## Wofi customization

If you use wofi, you can copy-paste the contents of .config/wofi to your home folder to make it look like the wofi screenshot below. In style.css, change <ABSOLUTE_PATH_TO_YOUR_HOME_DIR> to your home dir, e.g. /home/myuser.

## Screenshots

wofi version of prompt dialog:
<img width="853" height="118" alt="image" src="https://github.com/user-attachments/assets/b599f766-d5b4-4b52-9f71-68049a2690d1" />

Terminal output (showing multi-line input in the prompt, support for Magistral thinking tags). Foot is default terminal but can of course be modified to your favorite terminal of use in the `ask_llm.sh` script:
<img width="2275" height="1111" alt="image" src="https://github.com/user-attachments/assets/8500c7b5-8c87-4980-828c-19e755852f38" />

Updated version with now showing the user's prompt in the output:
<img width="2279" height="1499" alt="image" src="https://github.com/user-attachments/assets/7be355df-c105-4037-93ba-0c576509c06b" />
