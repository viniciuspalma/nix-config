_: {
  programs.nixvim = {
    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      

      settings = {
	snippet = {
	  expand = "function(args) require('luasnip').lsp_expand(args.body) end";
	};
	mapping = {
	  "<C-Space>" = "cmp.mapping.complete()";
	  "<C-d>" = "cmp.mapping.scroll_docs(-4)";
	  "<C-e>" = "cmp.mapping.close()";
	  "<C-y>" = "cmp.mapping.confirm({ select = true })";
	  "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
	  "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
	}; 

	sources =
	  [ { name = "nvim_lsp"; }
	    { name = "treesitter"; }
	    { name = "path"; }
	    { name = "buffer"; }
	  ];
      };
    };
  };
}
