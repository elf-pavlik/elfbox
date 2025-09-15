return {
	{ "nvim-neotest/neotest-vitest" },
	{ "nvim-neotest/neotest-jest" },
	{
		"nvim-neotest/neotest",
		opts = { adapters = { "neotest-vitest", "neotest-jest" } },
	},
}
