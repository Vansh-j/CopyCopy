
# CopyCopy (`cpcp` for short, hehe) 📋

[![macOS](https://img.shields.io/badge/macOS-10.15+-000000.svg?logo=apple&logoColor=white)](#)
[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343.svg?logo=swift&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](#)

A smarter macOS clipboard copy utility. `cpcp` is a drop in replacement for `pbcopy` that understands what you're trying to do.


> **⭐ Help get `cpcp` into Homebrew Core!**
> If you find this tool useful, please leave a star ⭐. We need **75 stars** to submit this utility to the official Homebrew repository so everyone can install it without tapping.


## The Problem with `pbcopy`
Native macOS `pbcopy` is good for basic scripting, but it has terrible developer UX:
- It copies trailing newlines from pipes (`echo "password" | pbcopy`).
- It copies invisible ANSI color codes from terminal logs, pasting gibberish into your editor.
- It doesn't understand non text files (like images, PDFs, etc).
- It offers zero feedback to tell you if the copy was successful (kinda not imp, but still).

**`cpcp` fixes all of this.**


## Features

✨ **Clean Pastes by Default:** Automatically strips trailing whitespaces and newlines from pipes. No more accidental form submissions when pasting tokens or passwords.  
🎨 **ANSI Stripping:** Pipes from `grep --color=always` or logs are stripped of invisible color codes so they paste perfectly.  
🧠 **Smart File Detection:** `cpcp image.png` copies the actual **image** to your clipboard so you can paste it directly into Slack, Figma, or Chrome.  
👁️ **Human Feedback:** Prints a subtle success message (`✔ Copied 42 characters`) to the terminal (but stays silent inside bash scripts).

## Installation

Currently available via a custom Homebrew tap. *(Note: Homebrew requires you to temporarily trust third-party taps, Give a ⭐ to submit this utility to the official Homebrew repository).*

```bash
brew tap vansh-j/cpcp
brew trust vansh-j/cpcp
brew install cpcp

```

## Usage

**Copy text directly:**

```bash
cpcp "Hello world"
# ✔ Copied 11 characters

```

**Pipe output (strips newlines & ANSI by default):**

```bash
echo "password123" | cpcp
# ✔ Copied 11 characters from pipe (Trailing newline removed!)

```

**Copy file contents (Text):**

```bash
cpcp notes.txt
# ✔ Copied text contents of notes.txt

```

**Copy file assets (Images, PDFs, etc.):**

```bash
cpcp screenshot.png 
# ✔ Copied file asset: screenshot.png
# Now hit Cmd+V in Slack, Figma, Browser, or Finder!

```

### Options / Flags

* **`-r`, `--raw**`: Keep raw formatting. Bypasses the auto-cleaner to keep trailing newlines and ANSI color codes intact.
* **`-t`, `--text-only**`: Force input to be treated as literal text. Useful if you want to copy a string that happens to match a local file name (e.g., `cpcp -t "image.png"` copies the word, not the file).

## Contributing

Pull requests are welcome!

1. Fork it
2. Create your feature branch (`git checkout -b feature/MyFeature`)
3. Commit your changes (`git commit -m 'Add some MyFeature'`)
4. Push to the branch (`git push origin feature/MyFeature`)
5. Open a Pull Request

## License

MIT License.

