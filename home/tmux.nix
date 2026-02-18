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
    # Dvorak pane navigation and resizing is configured manually in extraConfig
    customPaneNavigationAndResize = false;

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
      set -g automatic-rename-format '#{?#{==:#{pane_current_command},zsh},#{b:pane_current_path},#{pane_current_command}}'

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

      # Use window name (#W) instead of pane title (#T) for shorter labels
      set -g @catppuccin_window_text " #W"
      set -g @catppuccin_window_current_text " #W"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Dvorak pane navigation (htnl instead of hjkl)
      bind h select-pane -L
      bind t select-pane -D
      bind n select-pane -U
      bind l select-pane -R

      # Dvorak pane resizing (HTNL instead of HJKL)
      bind -r H resize-pane -L 5
      bind -r T resize-pane -D 5
      bind -r N resize-pane -U 5
      bind -r L resize-pane -R 5

      bind-key -r f run-shell "tmux neww ~/.config/nix-config/scripts/tmux-sessionizer"
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
