return {
	"neovim/nvim-lspconfig",
	opts = {
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
