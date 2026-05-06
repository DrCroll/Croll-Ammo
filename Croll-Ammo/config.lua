--[[
	Edit `server/opensource.lua` for your framework + inventory adapters.

	Ammo box catalog is server-side in `server/main.lua`.

	ox_inventory: set `server.export = 'Croll-Ammo.openBox'` on each box item.
	qb / ESX stacks without ox item exports: tune adapters in opensource.lua.

	`rewards` / notify phrases are unpacked in `server/main.lua` only.
	For client progress + animation with ox_inventory, merge `Config.BoxUnpackClient` into each box item's `client` in items data.
]]

Config = {}

-- qbox | qb-core | esx | custom (edit opensource.lua for custom)
Config.Framework = 'qbox'

-- ox | qb | codem | origen | tgiann | custom
Config.Inventory = 'ox'

-- ox | qb | esx | chat
Config.Notification = 'ox'

Config.NotificationDuration = 5000

Config.AtomicUnpack = true

---@type table<string, table<string, number|number[]>>
Config.AmmoBoxes = {}

---@type table<string, string>
Config.BoxLabels = {}

Config.Locale = {
	no_space = 'You cannot carry that much ammunition.',
	could_not_remove_box = 'You cannot use that right now.',
	unknown_box = 'This box is not configured.',
	unpacked = 'You unpacked the ammunition.',
	unpacked_named = 'You unpacked %s.',
	give_failed_returned = 'Could not add all ammunition. Your ammo box was returned.',
	give_failed_partial = 'Some ammunition could not be added. Check the server console.',
	give_failed_critical = 'Unpacking failed and inventory could not be restored. Contact staff.',
}

--- Copy into ox_inventory each box `client = { ... }` plus a per-item `label` (progress text).
Config.BoxUnpackClient = {
	usetime = 2500,
	cancel = true,
	anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', flag = 49 },
	disable = { move = true, car = true, combat = true },
}
