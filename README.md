<div align="center">
  <br />
  <h1>decipher.nvim</h1>
  <p><i>A plugin that provides ways to encode and decode text using various codecs like base64.</i></p>
  <p>
    <img src="https://img.shields.io/badge/version-1.0.3-blue?style=flat-square" />
    <a href="https://luarocks.org/modules/misanthropicbit/decipher.nvim">
        <img src="https://img.shields.io/luarocks/v/misanthropicbit/decipher.nvim?logo=lua&color=purple" />
    </a>
    <a href="https://img.shields.io/github/actions/workflow/status/MisanthropicBit/decipher.nvim/tests.yml?branch=master&style=flat-square">
        <img src="https://img.shields.io/github/actions/workflow/status/MisanthropicBit/decipher.nvim/tests.yml?branch=master&style=flat-square" />
    </a>
    <a href="/LICENSE">
        <img src="https://img.shields.io/github/license/MisanthropicBit/decipher.nvim?style=flat-square" />
    </a>
  </p>
  <br />
</div>

> [!IMPORTANT]  
> A bit library is needed which requires that either neovim has been compiled with luajit or you are using v0.9.0+ which provides a bit library.

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
require("decipher").setup({
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
        title_pos = "left", -- Position of the title
        autoclose = true, -- Autoclose floating window if insert
                          -- mode is activated or the cursor is moved
        enter = false, -- Automatically enter the floating window if
                       -- opened
        options = {}, -- Options to apply to the floating window contents
    },
})
```

## Example keymaps

There are several ways in which you can invoke `decipher`. Check out the
[docs](doc/decipher.txt) for more info. Below are some examples:

```lua
-- Encode visually selected text as base64. If invoked from normal mode it will
-- try to use the last visual selection
vim.keymap.set({ "n", "v" }, "<mykeymap>", function()
    require("decipher").encode_selection("base64")
end)

-- Decode encoded text using a motion, selecting a codec and previewing the result
vim.keymap.set("n", "<mykeymap>", function()
    require("decipher").decode_motion_prompt({ preview = true })
end)
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
| base64-url¹      | ✅        | ✅         |
| base64-url-safe² | ✅        | ✅         |
| url              | ✅        | ✅         |

¹ Combination of base64 and url codecs.

² Base64-variant that is safe to include in urls.
