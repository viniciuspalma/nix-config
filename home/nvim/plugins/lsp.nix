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
            "<F2>" = "rename";
          };
        };

        servers = {
          clangd.enable   = true;
          lua-ls.enable   = true;
          texlab.enable   = true;
	  hls.enable      = true;
          marksman.enable = true;
          nil_ls.enable   = true;
	  gopls.enable    = true;
	  tsserver.enable = true;

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
