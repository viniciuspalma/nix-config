{
  programs.nixvim = {
    # colorschemes.gruvbox.enable = true;
    # colorschemes.dracula-nvim.enable = true;

    colorschemes = {
      kanagawa = {
        enable = true;
        settings = {
          background = {
            light = "lotus";
            dark = "wave";
          };

          compile = false;
          undercurl = true;
          commentStyle.italic = true;
          functionStyle = {};
          transparent = false;
          dimInactive = false;
          terminalColors = true;
          colors = {
            theme = {
              wave.ui.float.bg = "none";
              dragon.syn.parameter = "yellow";
              all.ui.bg_gutter = "none";
            };
          };
          theme = "wave";
        };
      };
    };

    extraConfigLua = ''
      local current_background = nil

      local function detect_system_background()
        if vim.fn.has("mac") == 0 and vim.fn.has("macunix") == 0 then
          return nil
        end

        local style = vim.fn.system("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if style:match("Dark") then
          return "dark"
        end

        return "light"
      end

      local function sync_background_with_system()
        local background = detect_system_background()
        if not background or background == current_background then
          return
        end

        current_background = background
        vim.o.background = background
        local ok, kanagawa = pcall(require, "kanagawa")
        if ok then
          kanagawa.load()
        end
      end

      local group = vim.api.nvim_create_augroup("SystemThemeSync", { clear = true })
      vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
        group = group,
        callback = sync_background_with_system,
      })
    '';
  };
}
