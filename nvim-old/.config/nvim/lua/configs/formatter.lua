local prettier = {
  function()
    return {
      exe = "./node_modules/.bin/prettier",
      args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
      stdin = true
    }
  end
}

local prismafmt = {
  function()
    return {
      exe = "prisma-fmt",
      args = {"format", "-i", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
      stdin = true
    }
  end
}

local rustfmt = {
  function()
    return {
      exe = "rustfmt",
      args = {"--emit=stdout", "--edition=2021"},
      stdin = true
    }
  end
}

local luafmt = {
  function()
    return {
      exe = "luafmt",
      args = {"--indent-count", 2, "--stdin"},
      stdin = true
    }
  end
}

local clang_format = {
  function()
    return {
      exe = "clang-format",
      args = {"--assume-filename", vim.api.nvim_buf_get_name(0)},
      stdin = true,
      cwd = vim.fn.expand("%:p:h")
    }
  end
}

local autopep8 = {
  function()
    return {
      exe = "python3 -m autopep8",
      args = {
        "--in-place --aggressive --aggressive",
        vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
      },
      stdin = false
    }
  end
}

require("formatter").setup(
  {
    filetype = {
      javascript = prettier,
      javascriptreact = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      markdown = prettier,
      css = prettier,
      json = prettier,
      cpp = clang_format,
      lua = luafmt,
      python = autopep8,
      prisma = prismafmt,
      rust = rustfmt
    }
  }
)
