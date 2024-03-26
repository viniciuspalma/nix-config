{pkgs, ...}: {
  imports = [
    # ./autocommands.nix
    # ./completion.nix
    # ./highlights.nix
    ./remap.nix
    # ./options.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    options = {
      number = true;         # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2;        # Tab width should be 2
      swapfile = false;
      undofile = true;
      updatetime = 50;
      colorcolumn = "100";
      termguicolors = true;
      hlsearch = false;
      incsearch = true;
      backup = false;
      wrap = false;
    };
  };

  home = {
    shellAliases.v = "nvim";

    sessionVariables.EDITOR = "nvim";
  };
}
