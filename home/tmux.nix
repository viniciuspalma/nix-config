{pkgs, ...}: {

  programs.tmux = {
    enable = true;

    prefix = "C-space";

    # Rather than constraining window size to the maximum size of any client
    # connected to the *session*, constrain window size to the maximum size of any
    # client connected to *that window*. Much more reasonable.
    aggressiveResize = true;

    clock24 = true;

    # Allows for faster key repetition
    escapeTime = 50;

    keyMode = "vi";
    # Overrides the hjkl and HJKL bindings for pane navigation and resizing in VI mode
    customPaneNavigationAndResize = true;

    plugins = with pkgs.tmuxPlugins; [
      gruvbox
      sensible
      catppuccin
      yank 
    ];

    terminal = "screen-256color";

    extraConfig = ''
      # Enable mouse
      set -g mouse on

      # For neovim
      set -g focus-events on

      # Update the status line every seconds
      set -g status-interval 1

      set -g default-command ${pkgs.zsh}/bin/zsh

      # auto window rename
      set -g automatic-rename
      set -g automatic-rename-format '#{pane_current_command}'

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1

      # catppuccin
      set -g @catppuccin_l_left_separator ""
      set -g @catppuccin_l_right_separator ""
      set -g @catppuccin_r_left_separator ""
      set -g @catppuccin_r_right_separator ""
      set -g @catppuccin_window_separator_left ""
      set -g @catppuccin_window_separator_right ""
      set -g @catppuccin_status_separator_left ""
      set -g @catppuccin_status_separator_right ""
      set -g @catppuccin_window_middle_separator "█"
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
      set -g @catppuccin_user "on"
      set -g @catppuccin_host "on"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      bind-key -r f run-shell "tmux neww ~/.config/nix-darwin/scripts/tmux-sessionizer"

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };

  home.shellAliases = {
    tm = "tmux";
    tms = "tmux new -s";
    tml = "tmux list-sessions";
    tma = "tmux attach -t";
    tmk = "tmux kill-session -t";
  };
}
