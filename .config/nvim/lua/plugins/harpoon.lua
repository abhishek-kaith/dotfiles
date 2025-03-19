return {
	"ThePrimeagen/harpoon",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		vim.keymap.set("n", "<leader>a", function()
			require("harpoon.mark").add_file()
		end)
		vim.keymap.set("n", "<C-e>", function()
			require("harpoon.ui").toggle_quick_menu()
		end)
	end,
}
