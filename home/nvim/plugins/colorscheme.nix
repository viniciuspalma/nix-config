{
  programs.nixvim = {
    # colorschemes.gruvbox.enable = true;
    # colorschemes.dracula-nvim.enable = true;
    
    options = {
      background = "dark";
  
    };

    config = {
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
            functionStyle = { };
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
    };
  };
}
