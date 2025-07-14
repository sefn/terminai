#!/usr/bin/env -S deno run --allow-run

let inputBuffer = "";
const decoder = new TextDecoder();

for await (const chunk of Deno.stdin.readable) {
  inputBuffer += decoder.decode(chunk, { stream: true });

  const cmd = new Deno.Command("glow", {
    args: [
      "--style", "dark",
      "--width", "100"
    ],
    stdin: "piped",
    stdout: "piped",
  });

  const child = cmd.spawn();

  const writer = child.stdin.getWriter();
  await writer.write(new TextEncoder().encode(inputBuffer));
  writer.close();

  const { stdout } = await child.output();

  console.clear();
  Deno.stdout.write(stdout);
}
