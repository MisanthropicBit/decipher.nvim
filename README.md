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
| base64-url¹      | ✔         | ✔         |
| base64-url-safe² | ✔         | ✔         |
| url              | 🗓️        | ✔         |
| html             | 🗓️        | 🗓️        |

¹ Combination of base64 and url codecs.

² Base64-variant that is safe to include in urls.
