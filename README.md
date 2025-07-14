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
