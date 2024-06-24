{pkgs, ...}: {

  programs.tmux = {
    enable = true;

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

    extraConfig = ''
      # Enable mouse
      set -g mouse on

      # For neovim
      set -g focus-events on

      # Update the status line every seconds
      set -g status-interval 1

      # auto window rename
      set -g automatic-rename
      set -g automatic-rename-format '#{pane_current_command}'

      set -g default-terminal "xterm-256color"

      set -g prefix C-space
      unbind-key C-b
      bind-key C-space send-prefix

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Set vi-mode
      # bind-key -T copy-mode-vi v send-keys -X begin-selection
      # bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -r f run-shell "tmux neww ~/.config/nix-darwin/scripts/tmux-sessionizer"

      # set -g @plugin 'tmux-plugins/tpm'
      # set -g @plugin 'tmux-plugins/tmux-sensible'
      # set -g @plugin 'christoomey/vim-tmux-navigator'
      # set -g @plugin 'dreamsofcode-io/catppuccin-tmux'
      # set -g @plugin 'tmux-plugins/tmux-yank'

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
