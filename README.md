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
* a terminal of your choice (for the output. kde-ptyxis is default, but you can modify a single line (the last one) in `ask_llm.sh` with your terminal of choice)
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

Terminal output:
<img width="1274" height="2097" alt="image" src="https://github.com/user-attachments/assets/22597d5a-8995-4155-8455-4a8026619004" />
(Notice the continuous chat, formatting (of markdown and thinking tags (gpt-oss in this example)) and history/memory of the previous prompt)

You can also customize the width of glow's output in `render_stream.ts`, e.g. to 200:
<img width="2281" height="1420" alt="image" src="https://github.com/user-attachments/assets/9dcab3ff-f9dc-493d-b36d-1622f174c094" />

Updated version with multi-line input in the prompt, and support for Magistral thinking tags:
<img width="2275" height="1111" alt="image" src="https://github.com/user-attachments/assets/8500c7b5-8c87-4980-828c-19e755852f38" />
