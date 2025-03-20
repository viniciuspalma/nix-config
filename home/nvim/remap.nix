{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = 
      [ #{ mode = "n"; key = "<Space>"; action = "<NOP>"; }
        { mode = "n"; key = "<Esc>";   action = ":noh<CR>"; }

        { mode = "v"; key = ">";       action = ">gv"; }
        { mode = "v"; key = "<";       action = "<gv"; }
        { mode = "v"; key = "<TAB>";   action = ">gv"; } 
        { mode = "v"; key = "<S-TAB>"; action = "<gv"; }
        { mode = "v"; key = "K";       action = ":m '<-2<CR>gv=gv"; }
        { mode = "v"; key = "J";       action = ":m '>+1<CR>gv=gv"; }

        { mode = "n"; key = "<M-k>"; action = ":move-2<CR>"; }
        { mode = "n"; key = "<M-j>"; action = ":move+<CR>"; }

        { mode = "n"; key = "<leader>pv"; action = { __raw = "vim.cmd.Ex"; }; }

        { mode = "n"; key = "J"; action = "mzJ`z"; }

        { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; }
        { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; }
        { mode = "n"; key = "n"; action = "nzzzv"; }
        { mode = "n"; key = "N"; action = "Nzzzv"; }

        { mode = "x"; key = "<leader>p"; action = "\"_dP"; }
        { mode = "n"; key = "<leader>y"; action = "\"+y"; }
        { mode = "v"; key = "<leader>y"; action = "\"+y"; }
        { mode = "n"; key = "<leader>Y"; action = "\"+Y"; }

        { mode = "n"; key = "<leader>d"; action = "\"d"; }
        { mode = "v"; key = "<leader>d"; action = "\"d"; }

        { mode = "n"; key = "<C-c>";     action = "<Esc>"; }
        { mode = "v"; key = "Q";         action = "<NOP>"; }
        { mode = "n"; key = "<leader>f"; action = "vim.lsp.buf.format"; }

        { mode = "n"; key = "<C-k>"; action = "<cmd>cnext<CR>zz"; }
        { mode = "n"; key = "<C-j>"; action = "<cmd>cprev<CR>zz"; }
        { mode = "n"; key = "<leader>k"; action = "<cmd>lnexc<CR>zz"; }
        { mode = "n"; key = "<leader>j"; action = "<cmd>lprev<CR>zz"; }

        { mode = "n"; key = "<leader>s"; action = "[[:%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>]]"; }
        { mode = "n"; key = "<leader>x"; action = "<cmd>!chmod +x %<CR>"; options.silent = true; }
      ];
  };
}
