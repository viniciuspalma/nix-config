{
  programs.nixvim.plugins = {
    lsp-format.enable = true;

    none-ls = {
      enable = true;

      sources = {
        formatting = {
          prettierd.enable = true;
        };
      };
    };
  };
}



  #   lsp.servers.efm = {
  #     enable = true;
  #
  #     extraOptions.init_options = {
  #       documentFormatting = true;
  #       documentRangeFormatting = true;
  #       hover = true;
  #       documentSymbol = true;
  #       codeAction = true;
  #       completion = true;
  #     };
  #   };
  #
  #   # lsp-format = {
  #   #   enable = true;
  #   #   lspServersToEnable = ["efm"];
  #   # };
  #
  #   efmls-configs = {
  #     enable = true;
  #
  #     setup = {
  #       javascript = {
  #         formatter = "prettier";
  #         linter = "eslint";
  #       };
  #
  #       typescript = {
  #         formatter = "prettier";
  #         linter = "eslint";
  #       };
  #     };
  #   };
  # };

