return {
	"yetone/avante.nvim",
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	-- ⚠️ must add this setting! ! !
	build = "make",
	lazy = false,
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	---@module 'avante'
	---@type avante.Config
	opts = {
		provider = "ollama",
		providers = {
			ollama = {
				model = "deepseek-coder-v2:16b",
			},
		},
		vendors = {
			["deepseek-coder-v2:16b"] = {
				__inherited_from = "ollama",
				model = "deepseek-coder-v2:16b",
			},
			-- Add here other models you want to be available in `AvanteModels`.
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
