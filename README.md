<div align="center">
  <br />
  <h1>decipher.nvim</h1>
  <p><i>Encode and decode text</i></p>
  <p>
    <img src="https://img.shields.io/badge/version-1.0.0-blue?style=flat-square" />
    <a href="https://img.shields.io/github/actions/workflow/status/MisanthropicBit/decipher.nvim/ci.yml?branch=master&style=flat-square">
        <img src="https://img.shields.io/github/actions/workflow/status/MisanthropicBit/decipher.nvim/ci.yml?branch=master&style=flat-square" />
    </a>
    <a href="/LICENSE">
        <img src="https://img.shields.io/github/license/MisanthropicBit/decipher.nvim?style=flat-square" />
    </a>
  </p>
  <br />
</div>

A small plugin that provides ways to encode and decode text using various codecs
like base64.

## Installing

Use whatever package manager you use to install.

* **vim-plug**

    ```vim
    Plug 'MisanthropicBit/decipher.nvim'
    ```

## Setup

Setup decipher using `decipher.setup`. The options below are the default values.
Refer to the [docs](docs//decipher.txt) for more help.

```lua
require('decipher').setup({
    active_codecs = "all", -- Set all codecs as active and useable
    float = { -- Floating window options
        max_width = "auto", -- Auto-adjust width
        max_height = "auto", -- Auto-adjust height
        padding = 0, -- Zero padding (does not apply to title if any)
        border = { -- Floating window border
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
        },
        mappings = {
            close = "q", -- Key to press to close the floating window
            apply = "a", -- Key to press to apply the encoding/decoding
            help = "?", -- Toggle help
        },
        title = true, -- Display a title with the codec name
        title_pos = "left" -- Position of the title
        autoclose = true, -- Autoclose floating window if insert
                          -- mode is activated or the cursor is moved
        enter = false, -- Automatically enter the floating window if
                       -- opened
        options = { -- Options to apply to the floating window contents
            wrap = false,
        },
    },
})
```

## Supported Codecs

<details>
<summary>Legend</summary>

* ✔ = supported
* 🗓️ = planned
</details>

| Codec            | Encoding  | Decoding  |
| :--------------- | :-------: | :-------: |
| base32           | ✔         | ✔         |
| zbase32          | ✔         | ✔         |
| crockford        | ✔         | ✔         |
| base64           | ✔         | ✔         |
| base64-url¹      | ✗         | ✔         |
| base64-url-safe² | ✔         | ✔         |
| url              | ✗         | ✔         |

¹ Combination of base64 and url codecs.

² Base64-variant that is safe to include in urls.
