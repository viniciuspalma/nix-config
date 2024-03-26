{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      nixvimInjections = false;

      folding = false;
      indent = true;
    };

    treesitter-refactor = {
      enable = true;
      highlightDefinitions = {
        enable = true;
        # Set to false if you have an `updatetime` of ~100.
        clearOnCursorMove = false;
      };
    };

    hmts.enable = true;
  };
}
