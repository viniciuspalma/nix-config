{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code";
      size = 16;
    };

    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
    };

    theme = "Dracula";
  };
}
