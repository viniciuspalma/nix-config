{ pkgs, ... }:
let
  # Example of building your own grammar
  treesitter-move-grammar = pkgs.tree-sitter.buildGrammar {
    language = "move";
    version = "0.0.0+rev=f5b37f6";
    src = pkgs.fetchFromGitHub {
      owner = "tzakian";
      repo = "tree-sitter-move";
      rev = "f5b37f63569f69dfbe7a9950527786d2f6b1d35c";
      hash = "sha256-rylKiJVkT48IJzYVRUW6L3fZsvFVXLUTq/Q7eI4qGnk=";
    };
    meta.homepage = "https://github.com/tzakian/tree-sitter-move";
  };

  treesitter-prisma = pkgs.tree-sitter.buildGrammar {
    language = "prisma";
    version = "v1.5.1";
    src = pkgs.fetchFromGitHub {
      owner = "victorhqc";
      repo = "tree-sitter-prisma";
      tag = "v1.5.1";
      hash = "sha256-WxR3URFjljD9IEoKRvo0eBbv16PGhrv9aTUWPw8XlJA=";
    };
    meta.homepage = "https://github.com/victorhqc/tree-sitter-prisma";
  };
in
{
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        settings.indent.enable = true;
        nixvimInjections = false;

        folding = {
          enable = true;
        };

        grammarPackages =  with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        # Languages you use (from core.nix)
          go
          gomod
          gosum
          javascript
          typescript
          tsx
          ruby
          python
          ocaml         # for opam
          proto         # protobuf
          sql           # pgcli, supabase
          
          # DevOps / Config (from your setup)
          nix
          dockerfile
          yaml          # kubernetes, docker-compose
          toml
          json
          hcl           # terraform/opentofu
          terraform
          
          # Shell & scripting
          bash
          make
          
          # Git
          gitcommit
          gitignore
          git_rebase
          diff
          
          # Web (for frontend if you do any)
          html
          css
          
          # Editor / Docs
          lua           # neovim config
          vim
          vimdoc
          markdown
          markdown_inline
          regex
          query         # treesitter queries
          
          # Misc useful
          c             # often needed as dependency
          cpp
          comment
        ] ++ [
          treesitter-move-grammar
          treesitter-prisma
        ];
        luaConfig.post=
        ''
          do
            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            -- change the following as needed
            parser_config.move = {
              install_info = {
                url = "${treesitter-move-grammar}", -- local path or git repo
                files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
                -- optional entries:
                --  branch = "main", -- default branch in case of git repo if different from master
                -- generate_requires_npm = false, -- if stand-alone parser without npm dependencies
                -- requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
              },
              filetype = "move", -- if filetype does not match the parser name
            }

            parser_config.prisma = {
              install_info = {
                url = "${treesitter-prisma}", -- local path or git repo
                files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
                -- optional entries:
                --  branch = "main", -- default branch in case of git repo if different from master
                -- generate_requires_npm = false, -- if stand-alone parser without npm dependencies
                -- requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
              },
              filetype = "prisma", -- if filetype does not match the parser name
            }
          end
        '';
      };
    };

    # Add as extra plugins so that their `queries/{language}/*.scm` get
    # installed and can be picked up by `tree-sitter`
    extraPlugins = [
      treesitter-move-grammar
      treesitter-prisma
    ];
  };
}
