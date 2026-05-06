--[[
	Croll-Ammo server catalog (server-side only).
	Define and validate ammo box reward amounts here.
]]

---@return table<string, { rewards: table<string, number>, notifyPhrase?: string }>
local function buildAmmoBoxCatalog()
	local raw = {
		['ammo_rifle'] = { rewards = { ['ammo-rifle'] = 30 }, notifyPhrase = 'your 5.56x45 box' },
		['ammo-22box'] = { rewards = { ['ammo-22'] = 50 }, notifyPhrase = 'your .22 LR box' },
		['ammo-38box'] = { rewards = { ['ammo-38'] = 50 }, notifyPhrase = 'your .38 LC box' },
		['ammo-44box'] = { rewards = { ['ammo-44'] = 50 }, notifyPhrase = 'your .44 Magnum box' },
		['ammo-45box'] = { rewards = { ['ammo-45'] = 50 }, notifyPhrase = 'your .45 ACP box' },
		['ammo-50box'] = { rewards = { ['ammo-50'] = 20 }, notifyPhrase = 'your .50 AE box' },
		['ammo_pistol'] = { rewards = { ['ammo-9'] = 50 }, notifyPhrase = 'your 9mm box' },
		['ammo_rifle2'] = { rewards = { ['ammo-rifle2'] = 30 }, notifyPhrase = 'your 7.62x39 box' },
		['ammo_shotgun'] = { rewards = { ['ammo-shotgun'] = 25 }, notifyPhrase = 'your 12 gauge box' },
		['ammo_shotgun_pd'] = { rewards = { ['ammo-justices'] = 25 }, notifyPhrase = 'your 12 gauge Justice box' },
		['ammo_rifle_pd'] = { rewards = { ['ammo-justicea'] = 30 }, notifyPhrase = 'your 5.56x45 Justice box' },
		['ammo_pistol_pd'] = { rewards = { ['ammo-justicep'] = 50 }, notifyPhrase = 'your 9mm Justice box' },
	}

	local out = {}
	for boxName, def in pairs(raw) do
		if type(boxName) ~= 'string' or boxName == '' then
			error('[Croll-Ammo] Invalid box key in server catalog.')
		end
		if type(def) ~= 'table' or type(def.rewards) ~= 'table' or not next(def.rewards) then
			error(('[Croll-Ammo] Box "%s" must define a non-empty rewards table.'):format(boxName))
		end

		local rewards = {}
		for ammoName, amount in pairs(def.rewards) do
			local n = math.floor(tonumber(amount) or -1)
			if type(ammoName) ~= 'string' or ammoName == '' or n < 1 or n > 10000 then
				error(('[Croll-Ammo] Invalid reward in box "%s": ammo=%s amount=%s'):format(
					boxName,
					tostring(ammoName),
					tostring(amount)
				))
			end
			rewards[ammoName] = n
		end

		local phrase = def.notifyPhrase
		if phrase ~= nil and type(phrase) ~= 'string' then
			error(('[Croll-Ammo] notifyPhrase for box "%s" must be a string.'):format(boxName))
		end

		out[boxName] = {
			rewards = rewards,
			notifyPhrase = phrase,
		}
	end

	return out
end

function LoadServerAmmoCatalog()
	Config.AmmoBoxes = {}
	Config.BoxLabels = {}

	local catalog = buildAmmoBoxCatalog()
	for itemName, def in pairs(catalog) do
		Config.AmmoBoxes[itemName] = def.rewards
		if def.notifyPhrase and def.notifyPhrase ~= '' then
			Config.BoxLabels[itemName] = def.notifyPhrase
		end
	end
end
