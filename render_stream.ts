#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run

/**
 * This script processes a stream from stdin (e.g., from ollama).
 *
 * It performs two main tasks:
 * 1. Streams the output directly to stdout for the user to see in real-time.
 * 2. Filters out "thinking" blocks/tags from the stream.
 * 3. Writes the final, "clean" response (without thinking blocks) to a specified file.
 *
 * It now supports two types of thinking tags:
 * - "Thinking.... " and ".... done thinking" (e.g. gpt-oss:20b)
 * - "[THINK]" and "[/THINK]" (e.g. Magistral)
 * To add more thinking tags, adjust the thinkingRegex.
 */

// --- Get the output filename from command-line arguments ---
const cleanOutputFile = Deno.args[0];
const userPrompt = Deno.args[1];
if (!cleanOutputFile) {
  console.error("Error: Output file path argument is missing.");
  Deno.exit(1);
}

const decoder = new TextDecoder();
const encoder = new TextEncoder();

// ANSI escape codes
const enterAlternateScreen = "\x1b[?1049h";
const exitAlternateScreen = "\x1b[?1049l";
const gray = "\x1b[90m";
const cyan = "\x1b[36m";
const reset = "\x1b[0m";

// Regexes
const thinkingRegex = /((?:Thinking\.*.*?\.{4} done thinking)|(?:\[THINK\][\s\S]*?\[\/THINK\]))/s;
const headingFixRegex = /^\s+(#+)/gm; // Fix for indented headings

let rawInputBuffer = ""; // Holds the pure, raw text from ollama
let finalDisplayOutput = ""; // Holds the final, combined text for display

// --- Main Execution ---

await Deno.stdout.write(encoder.encode(enterAlternateScreen));

// Display the user's prompt immediately before waiting for the AI
const formattedPrompt = `${cyan}> You: ${userPrompt}${reset}\n`;
await Deno.stdout.write(encoder.encode(formattedPrompt));

try {
  for await (const chunk of Deno.stdin.readable) {
    rawInputBuffer += decoder.decode(chunk, { stream: true });

    // --- 1. Separate Content ---
    let thinkingBlock = "";
    let mainContent = rawInputBuffer; // Assume no thinking block initially

    const match = rawInputBuffer.match(thinkingRegex);
    if (match) {
      // If found, separate the thinking block from the main content
      thinkingBlock = match[1];
      mainContent = rawInputBuffer.substring(match[0].length);
    }

    // --- 2. Fix and Render ONLY the Main Content ---
    // First, fix any indented headings in the pure markdown content
    const cleanMainContent = mainContent.replace(headingFixRegex, "$1");

    // Now, pipe ONLY the clean markdown to glow
    // Note: adjust the width (of content) or text style to your preference
    const cmd = new Deno.Command("glow", {
      args: ["--style", "dark", "--width", "200"],
      stdin: "piped",
      stdout: "piped",
      stderr: "piped",
    });
    const child = cmd.spawn();
    const writer = child.stdin.getWriter();
    await writer.write(encoder.encode(cleanMainContent));
    writer.close();
    const { stdout } = await child.output();
    const renderedMainContent = decoder.decode(stdout);

    // --- 3. Assemble the Final View ---
    let displayOutput = "";
    if (thinkingBlock) {
      // With thinking models, color the separated thinking block and combine it
      const formattedThinkingBlock = `${gray}${thinkingBlock}${reset}`;
      displayOutput = `${formattedPrompt}\n${formattedThinkingBlock}\n\n${renderedMainContent}`;
    } else {
      // If no thinking block, the display is just the user prompt and rendered content
      displayOutput = `${formattedPrompt}\n${renderedMainContent}`;
    }

    // --- 4. Render to Alternate Screen ---
    console.clear();
    await Deno.stdout.write(encoder.encode(displayOutput));

    // Keep a copy for the final print after exiting the alternate screen
    finalDisplayOutput = displayOutput;
  }
} finally {
  await Deno.stdout.write(encoder.encode(exitAlternateScreen));
}

// After exiting, print the single, final display output to the NORMAL terminal
if (finalDisplayOutput) {
  Deno.stdout.write(encoder.encode(finalDisplayOutput));
}

// --- FINALIZATION STEP for History ---
// We use the final raw buffer to extract the clean response for the shell script
let finalCleanResponse = rawInputBuffer;
const finalMatch = rawInputBuffer.match(thinkingRegex);
if (finalMatch) {
  finalCleanResponse = rawInputBuffer.substring(finalMatch[0].length);
}

await Deno.writeTextFile(cleanOutputFile, finalCleanResponse.trim());
