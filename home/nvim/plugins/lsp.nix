{
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
          "<leader>f" = "format";
          "<leader>vca" = "code_action";
          "<leader>vws" = "workspace_symbol";
          "<leader>vrn" = "rename";
        };
      };

      servers = {
        clangd.enable   = true;
        lua_ls.enable   = true;
        texlab.enable   = true;
        gopls.enable    = true;
        volar.enable    = true;
        ts_ls.enable    = true;
        eslint.enable   = true;
        jdtls.enable    = true;
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
