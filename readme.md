<p align="center">
  <img src="logo.webp" height="150" />
</p>

# humanscript

> A truly natural scripting language

humanscript is an inferpreter. A script interpreter that infers the meaning behind commands written in natural language using large language models. Human writeable commands are translated into code that is then executed on the fly. There is no predefined syntax, humanscripts just say what they want to happen, and when you execute them, it happens.

## Example

This is a humanscript called `todo`.

```shell
#!/usr/bin/env humanscript

get the first command-line argument as the action

get everything after the first command-line argument as the task

ensure the todo file exists at $HOME/.todo.txt

if action is "add"
  append the task to the todo file
  show a success message

if action is "complete"
  mark the task as complete
  show a success message

if action is "list"
  print each task
    prepend completed tasks with an ascii tick
    prepend uncompleted tasks with an ascii bullet point

if no action was set
  print "Invalid action. Usage: ./todo [add|complete|list] [task]"
```

It can be executed like any other script.

```shell
$ ./todo add buy milk
Task added successfully.

$ ./todo add buy eggs
Task added successfully.

$ ./todo list
• buy milk
• buy eggs

$ ./todo complete buy eggs
Task marked as complete.

$ ./todo list
• buy milk
✓ buy eggs
```

The LLM inferpreted the humanscript into the following bash script at runtime.

```shell
#!/usr/bin/env bash

action=$1
shift
task="$@"

todo_file="$HOME/.todo.txt"
touch "$todo_file"

if [ "$action" == "add" ]; then
  echo "$task" >> "$todo_file"
  echo "Task added successfully."
elif [ "$action" == "complete" ]; then
  sed -i "s/^$task$/✓ $task/" "$todo_file"
  echo "Task marked as complete."
elif [ "$action" == "list" ]; then
  while IFS= read -r line; do
    if [[ $line == ✓* ]]; then
      echo "$line"
    else
      echo "• $line"
    fi
  done < "$todo_file"
else
  echo "Invalid action. Usage: ./todo [add|complete|list] [task]"
fi
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

> Be careful if you're running humanscript unsandboxed. It can sometimes do weird and dangerous things. If you're brave enough to run unsandboxed it's a good idea to run humanscripts initially with `HUMANSCRIPT_EXECUTE="false"` to eyeball the resulting code.

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

Default: `https://api.openai.com`

A server following OpenAI's Chat Completion API.

Many local proxies exist that implement this API in front of locally running LLMs like Llama 2. [LM Studio](https://lmstudio.ai/) is a good option.

```shell
HUMANSCRIPT_API="http://localhost:1234"
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
