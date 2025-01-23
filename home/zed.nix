{pkgs, lib, ... }:

{
    programs.zed-editor = {
        enable = true;
        extensions = ["nix" "toml" "elixir" "make"];

        ## everything inside of these brackets are Zed options.
        userSettings = {

            assistant = {
                enabled = false;
                version = "2";
                default_open_ai_model = null;
                ### PROVIDER OPTIONS
                ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
                ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
                ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
                default_model = { 
                    provider = "zed.dev";
                    model = "claude-3-5-sonnet-latest";
                };

                #                inline_alternatives = [
                #                    {
                #                        provider = "copilot_chat";
                #                        model = "gpt-3.5-turbo";
                #                    }
                #                ];
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
        };
    };
}
