{ pkgs, ... }:

let
  webFormatters = {
    __raw = ''
      function(bufnr)
        local has_biome = vim.fs.find({ "biome.json", "biome.jsonc" }, {
          upward = true,
          path = vim.api.nvim_buf_get_name(bufnr),
          stop = vim.uv.os_homedir(),
        })
        if #has_biome > 0 then
          return { "biome-check" }
        end
        return { "prettierd" }
      end
    '';
  };
in
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      biome
      prettierd
    ];

    plugins.conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          timeout_ms = 2000;
          lsp_format = "fallback";
        };
        formatters_by_ft = {
          javascript = webFormatters;
          typescript = webFormatters;
          javascriptreact = webFormatters;
          typescriptreact = webFormatters;
          vue = webFormatters;
          json = webFormatters;
          jsonc = webFormatters;
          css = webFormatters;
          html = [ "prettierd" ];
          yaml = [ "prettierd" ];
          markdown = [ "prettierd" ];
	  nix = [ "alejandra" ];
        };
      };
    };
  };
}
