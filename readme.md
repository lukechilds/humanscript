<p align="center">
  <img src="logo.webp" height="150" />
</p>

# humanscript

> A truly natural scripting language

humanscript is an inferpreter. A script interpreter that uses a large language model to infer the meaning behind commands written in natural language. Human writeable commands are translated into code that is then executed on the fly. There is no predefined syntax, humanscripts just say what they want to happen, and when you execute them, it happens.

The humanscript inferpreter supports a wide range of LLM backends. It can be used with cloud hosted LLMs like OpenAI's GTP-3.5 and GPT-4 or locally running open source LLMs like Llama 2.

## Example

This is a humanscript called `bitcoin-poem`.

```shell
#!/usr/bin/env humanscript

write a poem

print the poem

get the latest bitcoin blockhash from the mempool api

hash the poem and the blockhash together

print the blockhash, and the combined hash
```

It can be executed like any other script.

```shell
$ ./bitcoin-poem
Poem: Roses are red, violets are blue. Bitcoin is volatile, and that is true
Bitcoin Blockhash: 0000000000000000000413b966555eee6794dac502ac66ec88d7e752ffec8a4b
Combined hash: ad69015c2f43d86b2d3247b78c81d9bb8f38e453a05d6fd264f42c44d74390e4
```

The LLM inferpreted the humanscript into the following bash script at runtime.

```shell
#!/usr/bin/env bash

poem="Roses are red, violets are blue. Bitcoin is volatile, and that is true"

echo "Poem: $poem"

blockhash=$(curl -s https://mempool.space/api/blocks/tip/hash)

combined_hash=$(echo -n "$poem$blockhash" | sha256sum | cut -d ' ' -f1)

echo "Bitcoin Blockhash: $blockhash"
echo "Combined hash: $combined_hash"
```

The code is streamed out of the LLM during inferpretation and executed line by line so execution is not blocked waiting for inference to finish. The resulting code is cached and will be executed immediately next time the humanscript is executed, bypassing the need for reinferpretation.

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

The following environment variables can be added to `~/.humanscript/config` to be globally applied to all humanscripts.

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

If the humanscript inferpreter should automatically execute the generated code on the fly.

If false the generated code will not be executed and instead be streamed to stdout.

```shell
HUMANSCRIPT_EXECUTE="false"
```

### `HUMANSCRIPT_REGENERATE`

Default: `false`

If the humanscript inferpreter should regenerate a cached humanscript.

If true the humanscript will be reinferpreted and the cache entry will be replaced with the newly generated code.

```shell
HUMANSCRIPT_REGENERATE="true"
```

## License

MIT © Luke Childs
