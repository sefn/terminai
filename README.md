# simple-kde-ai-chat
AI chat client for Linux. Can be modified, but currently uses kdialog for the prompt, and a terminal (e.g. kde-ptyxis) for streaming output and allowing subsequent prompts with memory. Markdown formatting with deno + glow

## Dependencies

* Ollama with any model
* Deno (with glow for markdown formatting)
* stdbuf (for streaming)
* tee

## Installation

Move render_stream.ts and ask_llm.sh to /ust/local/bin and make them executable with chmod +x.

Then add a keyboard shortcut to launch ask_llm.sh, for example SUPER+Backspace, in your DE of choice (like KDE).

That's it.

<img width="448" height="384" alt="image" src="https://github.com/user-attachments/assets/a221f25b-b3d9-428c-bdef-c3cbc16175cf" />

<img width="1033" height="578" alt="image" src="https://github.com/user-attachments/assets/3e47571a-83f2-48f9-bff2-aa0e9bf9cc99" />

