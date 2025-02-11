{pkgs, lib, ... }:

{
    programs.zed-editor = {
        enable = true;
        extensions = ["nix" "toml" "elixir" "make"];
        extraPackages = [ pkgs.nixd ];

        ## everything inside of these brackets are Zed options.
        userSettings = {

            assistant = {
                enabled = false;
                version = "2";
                # default_open_ai_model = null;
                ### PROVIDER OPTIONS
                ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
                ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
                copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview }
            };

            node = {
                path = lib.getExe pkgs.nodejs;
                npm_path = lib.getExe' pkgs.nodejs "npm";
            };

            hour_format = "hour24";
            auto_update = false;
            terminal = {
                alternate_scroll = "off";
                blinking = "off";
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
                font_family = "FiraCode Nerd Font";
                font_features = null;
                font_size = null;
                line_height = "comfortable";
                option_as_meta = false;
                button = false;
                shell = {
                    program = "zsh";
                };
                toolbar = {
                    title = true;
                };
                working_directory = "current_project_directory";
            };



            lsp = {
                rust-analyzer = {

                    binary = {
                        #                        path = lib.getExe pkgs.rust-analyzer;
                        path_lookup = true;
                    };
                };
                nix = { 
                    binary = { 
                        path_lookup = true; 
                    }; 
                };

                elixir-ls = {
                    binary = {
                        path_lookup = true; 
                    };
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

            vim_mode = true;
            ## tell zed to use direnv and direnv can use a flake.nix enviroment.
            load_direnv = "shell_hook";
            base_keymap = "VSCode";
            theme = {
                mode = "system";
                light = "One Light";
                dark = "One Dark";
            };
            show_whitespaces = "all" ;
            ui_font_size = 16;
            buffer_font_size = 16;

            bindings = {
                "ctrl+shift+o" = "open_file";
                "ctrl+shift+n" = "new_file";
                "ctrl+shift+s" = "save_file";
                "ctrl+shift+w" = "close_file";
                "ctrl+shift+q" = "quit";
                "ctrl+shift+p" = "command_palette";
                "ctrl+shift+f" = "find_in_files";
                "ctrl+shift+r" = "replace_in_files";
                "ctrl+shift+g" = "git";
                "ctrl+shift+h" = "show_history";
                "ctrl+shift+e" = "show_explorer";
                "ctrl+shift+t" = "show_terminal";
                "ctrl+shift+d" = "show_debugger";
                "ctrl+shift+l" = "show_lsp";
                "ctrl+shift+m" = "show_markdown";
                "ctrl+shift+c" = "show_copilot";
                "ctrl+shift+a" = "show_assistant";
                "ctrl+shift+v" = "show_vcs";
                "ctrl+shift+u" = "show_user_settings";
                "ctrl+shift+i" = "show_install_extensions";
                "ctrl+shift+1" = "layout_1";
                "ctrl+shift+2" = "layout_2";
                "ctrl+shift+3" = "layout_3";
                "ctrl+shift+4" = "layout_4";
                "ctrl+shift+5" = "layout_5";
                "ctrl+shift+6" = "layout_6";
                "ctrl+shift+7" = "layout_7";
                "ctrl+shift+8" = "layout_8";
                "ctrl+shift+9" = "layout_9";
                "ctrl+shift+0" = "layout_0";
                "ctrl+shift+tab" = "previous_tab";
                "ctrl+tab" = "next_tab";
                "ctrl+shift+[" = "previous_tab";
                "ctrl+shift+]" = "next_tab";
                "ctrl+shift+left" = "previous_tab";
                "ctrl+shift+right" = "next_tab";
                "ctrl+shift+up" = "move_tab_up";
                "ctrl+shift+down" = "move_tab_down";
        ];
      

        };
    };
}
