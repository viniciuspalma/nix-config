{
  pkgs,
  lib,
  ...
}: {
  programs.zed-editor = {
    enable = true;
    extensions = ["nix" "toml" "elixir" "make"];
    extraPackages = [pkgs.nixd];

    userSettings = {
      assistant = {
        enabled = false;
        version = "2";
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      auto_update = false;
      hour_format = "hour24";

      base_keymap = "VSCode";
      vim_mode = true;
      vim = {
        use_system_clipboard = "always";
        toggle_relative_line_numbers = true;
        use_smartcase_find = true;
      };

      load_direnv = "shell_hook";

      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };

      buffer_font_family = "FiraCode Nerd Font Mono";
      buffer_font_features = {
        calt = true;
      };
      buffer_font_size = 14;
      ui_font_size = 16;

      tab_size = 2;
      hard_tabs = false;
      soft_wrap = "none";
      show_whitespaces = "all";
      wrap_guides = [100];
      preferred_line_length = 100;
      relative_line_numbers = "enabled";

      project_panel = {
        dock = "right";
      };

      tab_bar = {
        show = true;
        max_tabs = 1;
        show_nav_history_buttons = false;
      };

      preview_tabs = {
        enabled = false;
        enable_preview_from_project_panel = false;
        enable_preview_from_file_finder = false;
        enable_preview_from_multibuffer = false;
        enable_preview_multibuffer_from_code_navigation = false;
        enable_preview_file_from_code_navigation = false;
        enable_keep_preview_on_code_navigation = false;
      };

      bottom_dock_layout = "full";

      terminal = {
        alternate_scroll = "off";
        blinking = "off";
        button = false;
        copy_on_select = false;
        dock = "bottom";
        detect_venv = {
          on = {
            directories = [".env" "env" ".venv" "venv"];
            activate_script = "default";
          };
        };
        env = {
          TERM = "alacritty";
        };
        font_family = "FiraCode Nerd Font Mono";
        font_size = 16;
        line_height = "standard";
        option_as_meta = false;
        shell = {
          program = lib.getExe pkgs.zsh;
        };
        toolbar = {
          breadcrumbs = false;
        };
        working_directory = "current_project_directory";
      };

      lsp = {
        rust-analyzer = {
          binary.path_lookup = true;
        };
        nix = {
          binary.path_lookup = true;
        };
        elixir-ls = {
          binary.path_lookup = true;
          settings = {
            dialyzerEnabled = true;
          };
        };
      };

      languages = {
        "Elixir" = {
          language_servers = ["!lexical" "elixir-ls" "!next-ls"];
          format_on_save = {
            external = {
              command = "mix";
              arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
            };
          };
        };
        "HEEX" = {
          language_servers = ["!lexical" "elixir-ls" "!next-ls"];
          format_on_save = {
            external = {
              command = "mix";
              arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
            };
          };
        };
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-p" = "file_finder::Toggle";
          "ctrl-t" = "terminal_panel::ToggleFocus";
        };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-m" = "workspace::ToggleZoom";
          "ctrl-w h" = "workspace::ActivatePaneLeft";
          "ctrl-w t" = "workspace::ActivatePaneDown";
          "ctrl-w n" = "workspace::ActivatePaneUp";
          "ctrl-w l" = "workspace::ActivatePaneRight";
        };
      }
      {
        context = "Dock";
        bindings = {
          "ctrl-w h" = "workspace::ActivatePaneLeft";
          "ctrl-w t" = "workspace::ActivatePaneDown";
          "ctrl-w n" = "workspace::ActivatePaneUp";
          "ctrl-w l" = "workspace::ActivatePaneRight";
        };
      }
      {
        context = "Editor && !menu";
        bindings = {
          "alt-j" = "editor::MoveLineDown";
          "alt-k" = "editor::MoveLineUp";
        };
      }
      {
        context = "Editor && vim_mode == insert && !menu";
        bindings = {
          "ctrl-c" = "vim::NormalBefore";
        };
      }
      {
        context = "Editor && vim_mode == visual && !menu";
        bindings = {
          "ctrl-c" = ["workspace::SendKeystrokes" "escape"];
          ">" = ["workspace::SendKeystrokes" "> g v"];
          "<" = ["workspace::SendKeystrokes" "< g v"];
          "tab" = ["workspace::SendKeystrokes" "> g v"];
          "shift-tab" = ["workspace::SendKeystrokes" "< g v"];
          "J" = "editor::MoveLineDown";
          "K" = "editor::MoveLineUp";
          "space y" = "vim::VisualYank";
          "space d" = "vim::VisualDelete";
          "space p" = ["workspace::SendKeystrokes" "\" _ d P"];
          "Q" = null;
        };
      }
      {
        context = "Editor && vim_mode == normal && !menu";
        bindings = {
          "escape" = ["workspace::SendKeystrokes" ": n o h l s e a r c h enter"];
          "ctrl-c" = ["workspace::SendKeystrokes" "escape"];
          "ctrl-d" = ["workspace::SendKeystrokes" "ctrl-d z z"];
          "ctrl-u" = ["workspace::SendKeystrokes" "ctrl-u z z"];
          "ctrl-f" = "workspace::NewSearch";
          "ctrl-j" = "editor::GoToPreviousDiagnostic";
          "ctrl-k" = "editor::GoToDiagnostic";
          "n" = ["workspace::SendKeystrokes" "n z z z v"];
          "N" = ["workspace::SendKeystrokes" "shift-n z z z v"];
          "K" = "editor::Hover";
          "g d" = "editor::GoToDefinition";
          "g D" = "editor::FindAllReferences";
          "g i" = "editor::GoToImplementation";
          "g t" = "editor::GoToTypeDefinition";
          "space a" = "pane::TogglePinTab";
          "space b" = "tab_switcher::Toggle";
          "space e" = "tab_switcher::ToggleAll";
          "space f" = "editor::Format";
          "space f d" = "diagnostics::DeployCurrentFile";
          "space f f" = "file_finder::Toggle";
          "space f g" = "workspace::NewSearch";
          "space f h" = "zed::OpenDocs";
          "space g F" = "file_finder::Toggle";
          "space j" = "editor::GoToDiagnostic";
          "space k" = "editor::GoToPreviousDiagnostic";
          "space p" = "projects::OpenRecent";
          "space p e" = "tab_switcher::ToggleAll";
          "space p v" = "workspace::ToggleRightDock";
          "space s" = "buffer_search::DeployReplace";
          "space v c a" = "editor::ToggleCodeActions";
          "space v d" = "editor::Hover";
          "space v r n" = "editor::Rename";
          "space v w s" = "project_symbols::Toggle";
          "space y" = "vim::PushYank";
          "space Y" = "vim::YankLine";
          "space d" = "vim::PushDelete";
          "ctrl-w h" = "workspace::ActivatePaneLeft";
          "ctrl-w t" = "workspace::ActivatePaneDown";
          "ctrl-w n" = "workspace::ActivatePaneUp";
          "ctrl-w l" = "workspace::ActivatePaneRight";
          "ctrl-w H" = "vim::ResizePaneLeft";
          "ctrl-w T" = "vim::ResizePaneDown";
          "ctrl-w N" = "vim::ResizePaneUp";
          "ctrl-w L" = "vim::ResizePaneRight";
        };
      }
    ];
  };
}
