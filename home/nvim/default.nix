{
  nixpkgs,
  ...
}: {
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
    version.enableNixpkgsReleaseCheck = false;

    nixpkgs = {
      source = nixpkgs;
      config = {
        allowUnfree = true;
      };
    };

    opts = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width should be 2
      swapfile = false;
      undofile = true;
      updatetime = 50;
      colorcolumn = "100";
      hlsearch = false;
      incsearch = true;
      backup = false;
      wrap = false;
      termguicolors = true;
    };
  };

  home = {
    shellAliases.v = "nvim";

    sessionVariables.EDITOR = "nvim";
  };
}
