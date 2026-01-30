{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-marketplace; [
      alexkrechik.cucumberautocomplete
      bierner.markdown-preview-github-styles
      biomejs.biome
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      esbenp.prettier-vscode
      golang.go
      jnoortheen.nix-ide
      mkhl.direnv
      vscodevim.vim
    ];

    userSettings = {
      # Window
      "window.commandCenter" = true;

      # Editor
      "editor.fontFamily" = "FiraCode Nerd Font Mono, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;

      # Terminal
      "terminal.integrated.scrollback" = 100000;
      "terminal.integrated.defaultProfile.osx" = "zsh";
      "terminal.integrated.enableMultiLinePasteWarning" = "never";

      # Workbench
      "workbench.sideBar.location" = "right";
      "workbench.editor.showTabs" = "single";
      "workbench.editor.enablePreview" = false;
      "workbench.colorTheme" = "Catppuccin Frappé";
      "workbench.iconTheme" = "catppuccin-frappe";

      # Git
      "git.blame.editorDecoration.enabled" = true;
      "git.blame.statusBarItem.enabled" = false;

      # Biome
      "biome.requireConfiguration" = true;
      "biome.lsp.trace.server" = "verbose";
      "biome.suggestInstallingGlobally" = false;

      # Language-specific formatters
      "[jsonc]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[css]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[javascriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
      };
      "[go]" = {
        "editor.defaultFormatter" = "golang.go";
        "editor.formatOnSave" = true;
      };
      "[feature]" = {
        "editor.defaultFormatter" = "alexkrechik.cucumberautocomplete";
        "editor.formatOnSave" = true;
      };

      # Vim extension settings
      "vim.leader" = " ";
      "vim.useSystemClipboard" = true;
      "vim.hlsearch" = true;
      "vim.handleKeys" = {
        "<C-v>" = false;
        "<C-x>" = false;
      };

      "vim.normalModeKeyBindingsNonRecursive" = [
        {
          before = [ "<Esc>" ];
          commands = [ ":noh" ];
        }
        {
          before = [ "<M-k>" ];
          commands = [ ":move-2" ];
        }
        {
          before = [ "<M-j>" ];
          commands = [ ":move+" ];
        }
        {
          before = [ "<leader>" "p" "v" ];
          commands = [ "workbench.action.toggleSidebarVisibility" ];
        }
        {
          before = [ "J" ];
          after = [ "m" "z" "J" "\`" "z" ];
        }
        {
          before = [ "<C-d>" ];
          after = [ "<C-d>" "z" "z" ];
        }
        {
          before = [ "<C-u>" ];
          after = [ "<C-u>" "z" "z" ];
        }
        {
          before = [ "n" ];
          after = [ "n" "z" "z" "z" "v" ];
        }
        {
          before = [ "N" ];
          after = [ "N" "z" "z" "z" "v" ];
        }
        {
          before = [ "<leader>" "y" ];
          after = [ "\"" "+" "y" ];
        }
        {
          before = [ "<leader>" "Y" ];
          after = [ "\"" "+" "Y" ];
        }
        {
          before = [ "<leader>" "d" ];
          after = [ "\"" "d" ];
        }
        {
          before = [ "<C-c>" ];
          after = [ "<Esc>" ];
        }
        {
          before = [ "<leader>" "f" ];
          commands = [ "editor.action.formatDocument" ];
        }
        {
          before = [ "<C-k>" ];
          commands = [ "editor.action.marker.next" ];
          after = [ "z" "z" ];
        }
        {
          before = [ "<C-j>" ];
          commands = [ "editor.action.marker.prev" ];
          after = [ "z" "z" ];
        }
        {
          before = [ "<leader>" "k" ];
          commands = [ "editor.action.diagnosticPrevious" ];
          after = [ "z" "z" ];
        }
        {
          before = [ "<leader>" "j" ];
          commands = [ "editor.action.diagnosticNext" ];
          after = [ "z" "z" ];
        }
        {
          before = [ "<leader>" "v" "d" ];
          commands = [ "editor.action.showHover" ];
        }
        {
          before = [ "g" "d" ];
          commands = [ "editor.action.revealDefinition" ];
        }
        {
          before = [ "g" "D" ];
          commands = [ "editor.action.goToReferences" ];
        }
        {
          before = [ "g" "t" ];
          commands = [ "editor.action.goToTypeDefinition" ];
        }
        {
          before = [ "g" "i" ];
          commands = [ "editor.action.goToImplementation" ];
        }
        {
          before = [ "K" ];
          commands = [ "editor.action.showHover" ];
        }
        {
          before = [ "<leader>" "v" "c" "a" ];
          commands = [ "editor.action.quickFix" ];
        }
        {
          before = [ "<leader>" "v" "w" "s" ];
          commands = [ "workbench.action.showAllSymbols" ];
        }
        {
          before = [ "<leader>" "v" "r" "n" ];
          commands = [ "editor.action.rename" ];
        }
        {
          before = [ "<leader>" "s" ];
          commands = [ "actions.find" ];
        }
        {
          before = [ "<leader>" "a" ];
          commands = [ "vscode-harpoon.addEditor" ];
        }
        {
          before = [ "<leader>" "e" ];
          commands = [ "vscode-harpoon.editEditors" ];
        }
        {
          before = [ "<leader>" "p" "e" ];
          commands = [ "vscode-harpoon.editorQuickPick" ];
        }
        {
          before = [ "<leader>" "h" ];
          commands = [ "vscode-harpoon.gotoEditor1" ];
        }
        {
          before = [ "<leader>" "t" ];
          commands = [ "vscode-harpoon.gotoEditor2" ];
        }
        {
          before = [ "<leader>" "n" ];
          commands = [ "vscode-harpoon.gotoEditor3" ];
        }
        # Note: This binding conflicts with "<leader>s" -> "actions.find" above
        # Keeping it as-is from the original config
        {
          before = [ "<leader>" "s" ];
          commands = [ "vscode-harpoon.gotoEditor4" ];
        }
      ];

      "vim.visualModeKeyBindingsNonRecursive" = [
        {
          before = [ ">" ];
          after = [ ">" "g" "v" ];
        }
        {
          before = [ "<" ];
          after = [ "<" "g" "v" ];
        }
        {
          before = [ "<Tab>" ];
          after = [ ">" "g" "v" ];
        }
        {
          before = [ "<S-Tab>" ];
          after = [ "<" "g" "v" ];
        }
        {
          before = [ "K" ];
          commands = [ ":m '<-2<CR>gv=gv" ];
        }
        {
          before = [ "J" ];
          commands = [ ":m '>+1<CR>gv=gv" ];
        }
        {
          before = [ "<leader>" "y" ];
          after = [ "\"" "+" "y" ];
        }
        {
          before = [ "<leader>" "d" ];
          after = [ "\"" "d" ];
        }
        {
          before = [ "<leader>" "p" ];
          after = [ "\"" "_" "d" "P" ];
        }
        {
          before = [ "Q" ];
          commands = [ ];
        }
        {
          before = [ "<C-c>" ];
          after = [ "<Esc>" ];
        }
      ];

      "vim.insertModeKeyBindingsNonRecursive" = [
        {
          before = [ "<C-c>" ];
          after = [ "<Esc>" ];
        }
      ];
    };

    keybindings = [
      # Note: cmd+i -> composerMode.agent is Cursor-specific and won't work in VS Code
      {
        key = "ctrl+t";
        command = "workbench.action.terminal.toggleTerminal";
      }
      {
        key = "ctrl+m";
        command = "workbench.action.toggleMaximizedPanel";
        when = "terminalFocus";
      }
      {
        key = "ctrl+p";
        command = "workbench.action.quickOpen";
      }
    ];
  };
}
