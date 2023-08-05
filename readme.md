<p align="center">
  <img src="logo.webp" height="150" />
</p>

# humanscript

> A truly natural scripting language

humanscript is an inferpreter. A script interpreter that infers the meaning behind commands written in natural language using large language models. Human writeable commands are translated into code that is then executed on the fly. There is no predefined syntax, humanscripts just say what they want to happen, and when you execute them, it happens.

## Example

This is a humanscript called `tidy-screenshots`.

```shell
#!/usr/bin/env humanscript

loop over all files (ignoring directories) in $HOME/Screenshots

move each file into a subdirectory in the format year-month

while the task is running show an ascii loading spinner

show how many files where moved

show the size of each subdirectory ordered smallest first
```

It can be executed like any other script.

```shell
$ ./tidy-screenshots
593 files were moved.
364K    2023-08
2.3M    2023-02
5.4M    2022-09
5.9M    2023-03
6.9M    2022-07
7.4M    2023-04
11M     2023-01
13M     2022-01
13M     2022-10
14M     2022-03
16M     2022-11
16M     2022-12
18M     2022-02
20M     2021-11
20M     2021-12
23M     2022-05
24M     2021-09
29M     2023-07
30M     2023-06
31M     2022-04
31M     2023-05
36M     2022-06
38M     2021-10
67M     2022-08
```

The LLM inferpreted the humanscript into the following bash script at runtime.

```shell
#!/usr/bin/env bash

# Variables
DIR="$HOME/Screenshots"
COUNTER=0

# Spinner setup
spinner=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
spin() {
  # Hide cursor
  echo -ne "\e[?25l"
  while :; do
    for i in "${spinner[@]}"; do
      echo -ne "\r$i"
      sleep 0.1
    done
  done
}

# Start the spinner in the background
spin &
SPIN_PID=$!

# Loop over files
for FILE in "$DIR"/*; do
  if [[ -f "$FILE" ]]; then
    YEAR_MONTH=$(date -r "$FILE" "+%Y-%m")
    mkdir -p "$DIR/$YEAR_MONTH"
    mv "$FILE" "$DIR/$YEAR_MONTH/"
    ((COUNTER++))
  fi
done

# Stop the spinner
kill $SPIN_PID
echo -ne "\e[?25h"
echo -ne "\r"

# Output the number of moved files
echo "$COUNTER files were moved."

# Show the size of each subdirectory
du -sh "$DIR"/* | sort -h | sed "s|$DIR/||"
```

The code is streamed out of the LLM during inferpretation and executed line by line so execution is not blocked waiting for inference to finish. The generated code is cached on first run and will be executed instantly on subsequent runs, bypassing the need for reinferpretation.

The humanscript inferpreter supports a wide range of LLM backends. It can be used with cloud hosted LLMs like OpenAI's GTP-3.5 and GPT-4 or locally running open source LLMs like Llama 2.

## Usage

### Install humanscript

You can run humanscript in a sandboxed environment via Docker:

```shell
docker run -it ghcr.io/lukechilds/humanscript
```

Alternatively you can install it natively on your system with Homebrew:

```shell
brew install lukechilds/tap/humanscript
```

Or manually install by downloading this repository and copy/symlink `humanscript` into your PATH.

> Be careful if you're running humanscript unsandboxed. It can sometimes do weird and dangerous things. If you're brave enough to run unsandboxed it's a good idea to run humanscripts initially with `HUMANSCRIPT_EXECUTE="false"` so you can check the resulting code before executing.

### Write and execute a humanscript

humanscript is configured out of the box to use OpenAI's GPT-4, you just need to add your API key.

We need to add it to `~/.humanscript/config`

```shell
mkdir -p ~/.humanscript/
echo 'HUMANSCRIPT_API_KEY="<your-openai-api-key>"' >> ~/.humanscript/config
```

Now you can create a humanscript and make it executable.

```shell
echo '#!/usr/bin/env humanscript
print an ascii art human' > asciiman
chmod +x asciiman
```

And then execute it.

```shell
./asciiman
  O
 /|\
 / \
```

## Configuration

The following environment variables can be added to `~/.humanscript/config` to be applied globally to all humanscripts like:

```shell
$ cat ~/.humanscript/config
HUMANSCRIPT_API_KEY="sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
HUMANSCRIPT_MODEL="gpt-4"
```

or on a per script basis like:

```shell
$ HUMANSCRIPT_REGENERATE="true" ./asciiman
```

### `HUMANSCRIPT_API`

Default: `https://api.openai.com/v1`

A server following OpenAI's Chat Completion API.

Many local proxies exist that implement this API in front of locally running LLMs like Llama 2. [LM Studio](https://lmstudio.ai/) is a good option.

```shell
HUMANSCRIPT_API="http://localhost:1234/v1"
```

### `HUMANSCRIPT_API_KEY`

Default: `unset`

The API key to be sent to the LLM backend. Only needed when using OpenAI.

```shell
HUMANSCRIPT_API_KEY="sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

### `HUMANSCRIPT_MODEL`

Default: `gpt-4`

The model to use for inference.

```shell
HUMANSCRIPT_MODEL="gpt-3.5"
```

### `HUMANSCRIPT_EXECUTE`

Default: `true`

Whether or not the humanscript inferpreter should automatically execute the generated code on the fly.

If false the generated code will not be executed and instead be streamed to stdout.

```shell
HUMANSCRIPT_EXECUTE="false"
```

### `HUMANSCRIPT_REGENERATE`

Default: `false`

Whether or not the humanscript inferpreter should regenerate a cached humanscript.

If true the humanscript will be reinferpreted and the cache entry will be replaced with the newly generated code.

```shell
HUMANSCRIPT_REGENERATE="true"
```

## License

MIT © Luke Childs
