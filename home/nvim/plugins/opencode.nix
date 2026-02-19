{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      pkgs.vimPlugins.opencode-nvim
      pkgs.vimPlugins.snacks-nvim
    ];

    opts.autoread = true;

    extraConfigLua = ''
      require("snacks").setup({ input = {}, picker = {}, terminal = {} })

      vim.g.opencode_opts = {
        provider = {
          enabled = "terminal",
        },
      }

      -- Auto-enter terminal mode when focusing the opencode terminal buffer
      -- so mouse and keyboard input pass through to the TUI
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "term://*opencode*",
        callback = function()
          vim.cmd("startinsert")
        end,
      })

      -- OpenCode helpers
      local function focus_opencode()
        vim.schedule(function()
          local provider = require("opencode.config").provider
          if provider and provider.winid and vim.api.nvim_win_is_valid(provider.winid) then
            vim.api.nvim_set_current_win(provider.winid)
            vim.cmd("startinsert")
          end
        end)
      end

      local function operator_with_focus(prompt)
        local result = require("opencode").operator(prompt)
        local original = _G.opencode_prompt_operator
        _G.opencode_prompt_operator = function(kind)
          original(kind)
          focus_opencode()
        end
        return result
      end

      -- OpenCode keymaps
      vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<leader>.", function()
        require("opencode").toggle()
        focus_opencode()
      end, { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go",  function() return operator_with_focus("@this ") end, { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n",          "goo", function() return operator_with_focus("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

      -- Recover increment/decrement on +/-
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    '';
  };
}
