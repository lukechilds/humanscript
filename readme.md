<p align="center">
  <img src="logo.webp" height="150" />
</p>

# humanscript

> A truly natural scripting language

humanscript is an inferpreter. A script interpreter that infers the meaning behind commands written in natural language using large language models. Human writeable commands are translated into code that is then executed on the fly. There is no predefined syntax, humanscripts just say what they want to happen, and when you execute them, it happens.

The humanscript inferpreter supports a wide range of LLM backends. It can be used with cloud hosted LLMs like OpenAI's GTP-3.5 and GPT-4 or locally running open source LLMs like Llama 2.

## Example

This is a humanscript called `tidy-screenshots`. It takes an unorganised directory of screenshots and organises them into directories based on the month the screenshot was taken.

```shell
#!/usr/bin/env humanscript

loop over all files (ignoring directories) in $HOME/Screenshots

move each file into a subdirectory in the format year-month

while the task is running show an ascii loading spinner

show how many files where moved

show the size of each subdirectory
```

It can be executed like any other script.

```shell
$ ./tidy-screenshots
Moved 593 files.
364K    2023-08
2.3M    2023-02
5.4M    2022-09
5.8M    2023-03
6.9M    2022-07
7.4M    2023-04
 10M    2023-01
 12M    2022-01
 13M    2022-10
 14M    2022-03
 16M    2022-11
 16M    2022-12
 18M    2022-02
 19M    2021-11
 20M    2021-12
 23M    2021-09
 23M    2022-05
 28M    2023-07
 30M    2022-04
 30M    2023-05
 30M    2023-06
 35M    2022-06
 38M    2021-10
 66M    2022-08
```

The LLM inferpreted the humanscript into the following bash script at runtime.

```shell
#!/usr/bin/env bash

spinner() {
    local i sp n
    sp='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    n=${#sp}
    while sleep 0.1; do
        printf "%s\r" "${sp:i++%n:1}"
    done
}

spinner &

spinner_pid=$!

moved_count=0

for file in "$HOME/Screenshots"/*; do
    if [ -f "$file" ]; then
        dir="$HOME/Screenshots/$(date -r "$file" "+%Y-%m")"
        mkdir -p "$dir"
        mv "$file" "$dir"
        ((moved_count++))
    fi
done

kill "$spinner_pid"

echo "Moved $moved_count files."

du -sh "$HOME/Screenshots"/* | sed "s|$HOME/Screenshots/||"
```

The code is streamed out of the LLM during inferpretation and executed line by line so execution is not blocked waiting for inference to finish. The generated code is cached on first run and will be executed instantly on subsequent runs, bypassing the need for reinferpretation.

You can see it in action here:

![](demo.svg)

## Usage

### Install humanscript

You can run humanscript in a sandboxed environment via Docker:

```shell
docker run -it lukechilds/humanscript
```

Alternatively you can install it natively on your system with Homebrew:

```shell
brew install lukechilds/tap/humanscript
```

Or manually install by downloading this repository and copy/symlink `humanscript` into your PATH.

> Be careful if you're running humanscript unsandboxed. The inferpreter can sometimes do weird and dangerous things. Speaking from experience, unless you want to be doing a system restore at 2am on a saturday evening, you should atleast run humanscripts initially with `HUMANSCRIPT_EXECUTE="false"` so you can check the resulting code before executing.

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

All environment variables can be added to `~/.humanscript/config` to be applied globally to all humanscripts:

```shell
$ cat ~/.humanscript/config
HUMANSCRIPT_API_KEY="sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
HUMANSCRIPT_MODEL="gpt-4"
```

or on a per script basis:

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

If true the humanscript will be reinferpreted and the cache entry will be replaced with the newly generated code. Due to the nondeterministic nature of LLMs each time you reinferpret a humanscript you will get a similar but slightly different output.

```shell
HUMANSCRIPT_REGENERATE="true"
```

## License

MIT © Luke Childs
