return {
	"neovim/nvim-lspconfig",
	opts = {
		diagnostics = {
			virtual_text = false,
			virtual_lines = true,
		},
		servers = {
			volar = {
				init_options = {
					vue = {
						-- disable hybrid mode
						hybridMode = false,
					},
				},
				filetypes = {
					"javascript",
					"typescript",
					"vue",
				},
			},
		},
	},
}
