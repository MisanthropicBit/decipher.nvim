rockspec_format = "3.0"
package = "decipher.nvim"
version = "scm-1"

description = {
  summary = "A plugin that provides ways to encode and decode text using various codecs like base64",
  detailed = [[Important: A bit library is needed which requires that either neovim has been compiled with luajit or you are using v0.9.0+ which provides a bit library.]],
  labels = {
    "neovim",
    "plugin",
    "decipher",
    "codec",
    "encode",
    "decode",
    "base64",
  },
  homepage = "https://github.com/MisanthropicBit/decipher.nvim",
  issues_url = "https://github.com/MisanthropicBit/decipher.nvim/issues",
  license = "BSD 3-Clause",
}

dependencies = {
  "lua == 5.1",
}

source = {
   url = "git+https://github.com/MisanthropicBit/decipher.nvim",
}

build = {
   type = "builtin",
   copy_directories = {
     "doc",
     "plugin",
   },
}

test = {
    type = "command",
    command = "./tests/run_tests.sh",
}
