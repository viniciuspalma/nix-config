{
  programs.nixvim.diagnostic.settings = {
    underline = {
      severity = {
        min.__raw = "vim.diagnostic.severity.ERROR";
      };
    };
  };

  programs.nixvim.plugins = {
    lsp = {
      enable = true;

      keymaps = {
        silent = true;
        diagnostic = {
          # Navigate in diagnostics
          "<leader>k" = "goto_prev";
          "<leader>j" = "goto_next";
          "<leader>vd" = "open_float";
        };

        lspBuf = {
          gd = "definition";
          gD = "references";
          gt = "type_definition";
          gi = "implementation";
          K = "hover";
          "<leader>vca" = "code_action";
          "<leader>vws" = "workspace_symbol";
          "<leader>vrn" = "rename";
        };
      };

      servers = {
        clangd.enable = true;
        lua_ls.enable = true;
        texlab.enable = true;
        gopls.enable = true;
        vue_ls.enable = true;
        ts_ls.enable = true;
        biome.enable = true;
        eslint.enable = true;
        jdtls.enable = true;
        terraformls.enable = true;

        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
          installRustfmt = false;
        };
      };
    };
  };
}
