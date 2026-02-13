{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        settings.indent.enable = true;
        nixvimInjections = false;

        folding = {
          enable = false;
        };

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          # Languages you use (from core.nix)
          go
          gomod
          gosum
          javascript
          typescript
          tsx
          ruby
          python
          ocaml # for opam
          proto # protobuf
          sql # pgcli, supabase

          # DevOps / Config (from your setup)
          nix
          dockerfile
          yaml # kubernetes, docker-compose
          toml
          json
          hcl # terraform/opentofu
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
          lua # neovim config
          vim
          vimdoc
          markdown
          markdown_inline
          regex
          query # treesitter queries

          # Misc useful
          c # often needed as dependency
          cpp
          comment
        ];
      };
    };
  };
}
