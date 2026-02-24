{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      rose-pine
      dracula-nvim
    ];

    extraConfigLua = ''
      local current_theme = nil

      local function detect_system_background()
        if vim.fn.has("mac") == 0 and vim.fn.has("macunix") == 0 then
          return nil
        end

        local style = vim.fn.system("/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null")
        if style:match("Dark") then
          return "dark"
        end

        return "light"
      end

      local function apply_system_theme()
        vim.o.termguicolors = true

        local background = detect_system_background() or "dark"

        vim.o.background = background

        if background == "dark" then
          if current_theme == "dracula" then
            return true
          end

          local ok = pcall(vim.cmd.colorscheme, "dracula")
          if ok then
            current_theme = "dracula"
            return true
          end

          return false
        end

        if current_theme == "rose-pine-dawn" then
          return true
        end

        local ok_rose_pine, rose_pine = pcall(require, "rose-pine")
        if ok_rose_pine then
          rose_pine.setup({
            variant = "dawn",
            dark_variant = "main",
          })
        end

        local ok = pcall(vim.cmd.colorscheme, "rose-pine")
        if ok then
          current_theme = "rose-pine-dawn"
          return true
        end

        return false
      end

      local function apply_system_theme_with_retry()
        if apply_system_theme() then
          return
        end

        vim.defer_fn(function()
          apply_system_theme()
        end, 80)
      end

      local group = vim.api.nvim_create_augroup("SystemThemeSync", { clear = true })
      vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "FocusGained" }, {
        group = group,
        callback = apply_system_theme_with_retry,
      })

      vim.schedule(apply_system_theme_with_retry)
    '';
  };
}
