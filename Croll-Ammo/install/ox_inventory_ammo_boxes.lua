--[[
	Croll-Ammo — ox_inventory ammo box items (install snippet)

	This file is NOT loaded by FiveM (do not add it to fxmanifest).
	Adapt `server/opensource.lua` + `config.lua` for stacks other than ox_inventory.

	Option A — paste into `ox_inventory/data/items.lua` inside `Items = { ... }`:
		Copy the table entries only (the lines between `return {` and the final `}`),
		including the surrounding braces if you prefer to merge as a subtable.

	Option B — merge in Lua: load this file with `dofile` / your merge script and
		`for k,v in pairs(result) do Items[k] = v end` (adapt to your items loader).

	Export uses `Croll-Ammo.openBox` (resource folder name). Rename in every
	`server.export` if your folder is not `Croll-Ammo`.
]]

return {
	['ammo_rifle'] = {
		label = '5.56x45 Ammo Box',
		rarity = 'rare',
		weight = 500,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of rifle ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 5.56x45 box...',
			anim = { dict = 'mini@repair', clip = 'fixing_a_ped', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo-22box'] = {
		label = '.22 LR Ammo Box',
		weight = 400,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of .22 Long Rifle ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening .22 LR box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo-38box'] = {
		label = '.38 LC Ammo Box',
		weight = 1200,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of .38 LC ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening .38 LC box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo-44box'] = {
		label = '.44 Magnum Ammo Box',
		weight = 1200,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of .44 Magnum ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening .44 Magnum box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo-45box'] = {
		label = '.45 ACP Ammo Box',
		weight = 1200,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of .45 ACP ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening .45 ACP box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo-50box'] = {
		label = '.50 AE Ammo Box',
		weight = 1200,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of .50 AE ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening .50 AE box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo_pistol'] = {
		label = '9mm Ammo Box',
		weight = 800,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of 9mm ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 9mm box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo_rifle2'] = {
		label = '7.62x39 Ammo Box',
		weight = 600,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of rifle ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 7.62x39 box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo_shotgun'] = {
		label = '12 Gauge Ammo Box',
		weight = 2000,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of 12 gauge shells.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 12 gauge box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo_shotgun_pd'] = {
		label = '12 Gauge Ammo Box',
		weight = 2000,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of 12 Gauge Justice shells.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 12 gauge Justice box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo_rifle_pd'] = {
		label = '5.56x45 Justice Ammo Box',
		weight = 500,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of 5.56x45 Justice ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 5.56x45 Justice box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
	['ammo_pistol_pd'] = {
		label = '9mm Justice Ammo Box',
		weight = 800,
		stack = true,
		close = true,
		consume = 1,
		description = 'A box of 9mm Justice ammunition.',
		client = {
			usetime = 2500,
			cancel = true,
			label = 'Opening 9mm Justice box...',
			anim = { dict = 'pickup_object', clip = 'pickup_low', flag = 49 },
			disable = { move = true, car = true, combat = true },
		},
		server = { export = 'Croll-Ammo.openBox' },
	},
}
