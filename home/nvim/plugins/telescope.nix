{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;

      keymaps = {
        # Find files using Telescope command-line sugar.
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>b" = "buffers";
        "<leader>fh" = "help_tags";
        "<leader>fd" = "diagnostics";

        # FZF like bindings
        # Note: <C-p> is configured below in extraConfigLua for scoped git search
        "<leader>p" = "oldfiles";
        "<C-f>" = "live_grep";
      };

      settings.defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^.mypy_cache/"
          "^__pycache__/"
          "^output/"
          "^data/"
          "%.ipynb"
        ];
        set_env.COLORTERM = "truecolor";
      };
    };

    # Custom keybindings for scoped git search
    extraConfigLua = ''
      -- Scoped git files search (cwd-based) - for monorepo workflows
      vim.keymap.set('n', '<C-p>', function()
        require('telescope.builtin').git_files({
          cwd = vim.fn.getcwd(),
          use_git_root = false,
          show_untracked = true,
        })
      end, { desc = 'Git files (scoped to cwd)' })

      -- Full repo git files search (git root-based)
      vim.keymap.set('n', '<leader>gF', function()
        require('telescope.builtin').git_files({
          use_git_root = true,
          show_untracked = true,
        })
      end, { desc = 'Git files (full repo)' })
    '';
  };
}
