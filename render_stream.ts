#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run

// --- Get the output filename from command-line arguments ---
const cleanOutputFile = Deno.args[0];
if (!cleanOutputFile) {
  console.error("Error: Output file path argument is missing.");
  Deno.exit(1);
}

const decoder = new TextDecoder();
const encoder = new TextEncoder();

// ANSI escape codes for the Alternate Screen Buffer
const enterAlternateScreen = "\x1b[?1049h";
const exitAlternateScreen = "\x1b[?1049l";

// ANSI escape codes for colors
const gray = "\x1b[90m";
const reset = "\x1b[0m";

// The NEW, more robust regex to format the thinking block
const thinkingRegex = /^(Thinking\.*.*?\.*done thinking\.?)\s*/s;

let inputBuffer = ""; // This will hold the RAW, un-rendered output
let finalRenderedOutput = ""; // This will hold the GLOW-RENDERED output for display

// --- Main Execution ---

// 1. Enter the Alternate Screen Buffer immediately.
await Deno.stdout.write(encoder.encode(enterAlternateScreen));

try {
  // The `for await` loop handles the streaming input.
  for await (const chunk of Deno.stdin.readable) {
    inputBuffer += decoder.decode(chunk, { stream: true });

    let processedBuffer = inputBuffer;
    const match = inputBuffer.match(thinkingRegex);

    if (match) {
      const thinkingBlock = match[1];
      const restOfBuffer = inputBuffer.substring(match[0].length);
      processedBuffer = `${gray}${thinkingBlock}${reset}\n\n${restOfBuffer}`;
    }

    // Render the current buffer with glow
    const cmd = new Deno.Command("glow", {
      args: ["--style", "dark", "--width", "100"],
      stdin: "piped",
      stdout: "piped",
    });
    const child = cmd.spawn();
    const writer = child.stdin.getWriter();
    await writer.write(encoder.encode(processedBuffer));
    writer.close();
    const { stdout } = await child.output();

    // Do all rendering inside the alternate screen.
    console.clear();
    await Deno.stdout.write(stdout);

    // Keep a copy of the latest rendered output for the final display.
    finalRenderedOutput = decoder.decode(stdout);
  }
} finally {
  // ALWAYS exit the Alternate Screen, even if there's an error.
  await Deno.stdout.write(encoder.encode(exitAlternateScreen));
}

// After exiting the alternate screen, print the single, final, RENDERED output
// to the NORMAL terminal for the user to see.
if (finalRenderedOutput) {
  Deno.stdout.write(encoder.encode(finalRenderedOutput));
}

// --- FINALIZATION STEP ---
// Now, clean the RAW buffer and write it to the file for the bash script.
let finalCleanResponse = inputBuffer;
const finalMatch = inputBuffer.match(thinkingRegex);
if (finalMatch) {
  // If a thinking block exists, the clean response is everything AFTER it.
  finalCleanResponse = inputBuffer.substring(finalMatch[0].length);
}

// Write the clean, trimmed response to the file the bash script is waiting for.
await Deno.writeTextFile(cleanOutputFile, finalCleanResponse.trim());
