{
  programs.nixvim = {

    plugins = {
      typescript-tools.enable = true;

      lsp = {
        enable = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate in diagnostics
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };


          lspBuf = {
            gd = "definition";
            gD = "references";
            gt = "type_definition";
            gi = "implementation";
            K = "hover";
	    "<leader>vca" = "code_action";
	    "<leader>vd" = "diagnostic.open_float";
	    "<leader>vws" = "workspace_symbol";
	    "<leader>vrn" = "rename";
          };
        };

        servers = {
          clangd.enable   = true;
          lua-ls.enable   = true;
          texlab.enable   = true;
          marksman.enable = true;
	  gopls.enable    = true;
	  volar.enable      = true;

          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
    };
  };
}
