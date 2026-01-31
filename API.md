# API

Below is the specification for the public types and api functions.

## Types

## `decipher.Codecs`

Type: ```lua
enum
```

Values:

* `base32`
* `base64`
* `base64_url`
* `base64_url_encoded`
* `base64_url_safe`
* `crockford`
* `c_escape`
* `url`
* `url_plus`
* `xml`
* `zbase32`

## `decipher.CodecArg`

Type: ```lua
string | decipher.Codecs
```

General type for functions that accept codecs as arguments. Either a string
(e.g. "base64") or or a an enum (e.g. decipher.codec.base64).

## API functions

Any functions not listed here that may be accessed via the decipher module are
not considered public and are subject to change.

### `decipher.setup({config})`

Setup global configuration for decipher. See [`decipher.setup`](#decipher-setup)

Parameters:  
    • {config} (`decipher.Config`) Setup configuration table

### `decipher.version()`

Returns the current version string.

### `decipher.supported_codecs()`

Returns a list of currently supported codecs.

Return:
    (type) ...

### `decipher.encode({codec_name}, {value})`

Encode a value using a codec.

Parameters:  
    • {codec_name} (`decipher.CodecArg`) Setup configuration table
    • {value}      (`string`) Value to encode

### `decipher.decode({codec_name}, {value})`

Decode a value using a codec.

### `decipher.encode_selection({codec_name}, {options})`

Encode a visual selection using a codec.

Parameters:  
    • {codec_name} (`decipher.CodecArg`) Codec to use for encoding
    • {options}    (`decipher.Options`) Options to use

### `decipher.decode_selection({codec_name}, {options})`

Decode a visual selection using a codec.

Parameters:  
    • {codec_name} (`decipher.CodecArg`) Codec to use for decoding
    • {options}    (`decipher.Options`) Options to use

### `decipher.encode_motion({codec_name}, {options})`

Encode using a motion and a codec.

Parameters:  
    • {codec_name} (`decipher.CodecArg`) Codec to use for encoding
    • {options}    (`decipher.Options`) Options to use

### `decipher.decode_motion({codec_name}, {options})`

Decode using a motion and a codec.

Parameters:  
    • {codec_name} (`decipher.CodecArg`) Codec to use for decoding
    • {options}    (`decipher.Options`) Options to use

### `decipher.encode_selection_prompt({options})`

Encode a visual selection using a codec. Prompts with a list of the active
codecs via `vim.ui.select`.

Parameters:  
    • {options} (`decipher.Options`) Options to use

### `decipher.decode_selection_prompt({options})`

Decode a visual selection using a codec. Prompts with a list of the active
codecs via `vim.ui.select`.

Parameters:  
    • {options} (`decipher.Options`) Options to use

### `decipher.encode_motion_prompt({options})`

Encode using a motion. Prompts with a list of the active codecs via
`vim.ui.select`.

Parameters:  
    • {options}    (`decipher.Options`) Options to use

### `decipher.decode_motion_prompt({options})`

Decode using a motion. Prompts with a list of the active codecs via
vim.ui.select.

Parameters:  
    • {options}    (`decipher.Options`) Options to use
