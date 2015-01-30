# dmc-events-mixin

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-events-mixin"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-events-mixin",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_events_mix.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-events-mixin", module_config )

