return {
	"nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	opts = {
		override_by_filename = {
			["dune"] = {
				icon = "🐫",
				name = "Dune",
			},
			["dune-workspace"] = {
				icon = "🐫",
				name = "DuneWorkspace",
			},
			["dune-project"] = {
				icon = "🐫",
				name = "DuneProject",
			},
			[".ocamlformat"] = {
				icon = "🐫",
				name = "OCamlFormat",
			},
		},
		override_by_extension = {
			opam = {
				icon = "🐫",
				name = "Opam",
			},
		},
		strict = true,
	},
	config = function(_, opts)
		require("nvim-web-devicons").setup(opts)
	end,
}
