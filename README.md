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

# Table of contents

- [Installing](#installing)
- [Setup](#setup)
- [Example keymaps](#example-keymaps)
- [Supported Codecs](#supported-codecs)
    - [base32](#base32)
    - [z-base32](#z-base32)
    - [crockford](#crockford)
    - [base64](#base64)
    - [base64-url](#base64-url)
    - [base64-url-safe](#base64)
    - [base64-url-encoded](#base64-url-encoded)
    - [url](#url)

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
    float = { -- Floating window options
        padding = 0, -- Zero padding (does not apply to title if any)
        border = { -- Floating window border
            { "â•­", "FloatBorder" },
            { "â”€", "FloatBorder" },
            { "â•®", "FloatBorder" },
            { "â”‚", "FloatBorder" },
            { "â•¯", "FloatBorder" },
            { "â”€", "FloatBorder" },
            { "â•°", "FloatBorder" },
            { "â”‚", "FloatBorder" },
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

#### Base32

Example: `"this is encoded" => "ORUGS4ZANFZSAZLOMNXWIZLE"`

#### Z-base32

A more human-readable version of base32.

Example: `"this is encoded" => "qtwg1h3ypf31y3mqcpzse3mr"`

#### Crockford

Variant of base32 which excludes 'I', 'L', 'O', and 'U' to avoid confusion with digits.

Example: `"this is encoded" => "EHM6JWS0D5SJ0SBECDQP8SB4"`

#### Base64

Example `"light work." => "bGlnaHQgd29yay4="`

#### Base64-url

Url-safe version of base64 with optional padding used in [json web tokens](https://www.jwt.io/).

Example `"light work." => "bGlnaHQgd29yay4"` (base64 would have added a single `'='` at the end)

#### Base64-url-safe

Url-safe version of base64 that uses a different encoding table to avoid use of
url-unsafe characters. This is basically base64url with mandatory padding.

Example `"Å³«ÍE#ÿ•3" => "xQSzq81FI_-VMw=="`

#### Base64-url-encoded

Url-safe version of base64 with url percent-encoding.

Example `"Å³«ÍE#ÿ•3" =>  "xQSzq81FI%2f%2bVMw%3d%3d"`

#### Url

Also known as percent-encoding.

Example `th<is is encod!ed> => th%3cis+is+encod%21ed%3e`
