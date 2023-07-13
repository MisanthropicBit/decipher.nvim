<div align="center">
  <br />
  <h1>decipher.nvim</h1>
  <p><i>Encode and decode text</i></p>
  <p>
    <img src="https://img.shields.io/badge/version-0.1.1-blue?style=flat-square" />
    <a href="https://img.shields.io/github/actions/workflow/status/MisanthropicBit/decipher.nvim/ci.yml?branch=master&style=flat-square">
        <img src="https://img.shields.io/github/actions/workflow/status/MisanthropicBit/decipher.nvim/ci.yml?branch=master&style=flat-square" />
    </a>
    <a href="/LICENSE">
        <img src="https://img.shields.io/github/license/MisanthropicBit/decipher.nvim?style=flat-square" />
    </a>
  </p>
  <br />
</div>

A plugin that provides ways to encode and decode text using various codecs like
base64.

![demo](https://github.com/MisanthropicBit/decipher.nvim/assets/1846147/6bc4db76-9a3b-428b-99b4-98e56d06901e)

## Installing

* **[vim-plug](https://github.com/junegunn/vim-plug)**

```vim
Plug 'MisanthropicBit/decipher.nvim'
```

* **[packer.nvim](https://github.com/wbthomason/packer.nvim)**

```lua
use 'MisanthropicBit/decipher.nvim'
```

## Setup

Setup decipher using `decipher.setup` unless you are content with the defaults.
The options below are the default values. Refer to the
[docs](doc/decipher.txt) for more help.

```lua
require('decipher').setup({
    active_codecs = "all", -- Set all codecs as active and useable
    float = { -- Floating window options
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
            jsonpp = "J", -- Key to prettily format contents as json if possbile
            help = "?", -- Toggle help
        },
        title = true, -- Display a title with the codec name
        title_pos = "left" -- Position of the title
        autoclose = true, -- Autoclose floating window if insert
                          -- mode is activated or the cursor is moved
        enter = false, -- Automatically enter the floating window if
                       -- opened
        options = {}, -- Options to apply to the floating window contents
    },
})
```

## Supported Codecs

<details>
<summary>Legend</summary>

* ✅ = supported
* ❌ = not supported
* 🗓️ = planned
</details>

| Codec            | Encoding  | Decoding  |
| :--------------- | :-------: | :-------: |
| base32           | ✅        | ✅         |
| zbase32          | ✅        | ✅         |
| crockford        | ✅        | ✅         |
| base64           | ✅        | ✅         |
| base64-url¹      | ❌        | ✅         |
| base64-url-safe² | ✅        | ✅         |
| url              | ❌        | ✅         |

¹ Combination of base64 and url codecs.

² Base64-variant that is safe to include in urls.
