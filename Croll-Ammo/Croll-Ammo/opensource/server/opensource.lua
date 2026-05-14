
Webhook = ''

local ESX

local function notifyDuration(d)
	return math.floor(tonumber(d) or Config.NotificationDuration or 5000)
end

local function qbCore()
	local res = Config.Framework == 'qbox' and 'qbx_core' or 'qb-core'
	return exports[res]:GetCoreObject()
end

if Config.Framework == 'esx' then
	CreateThread(function()
		local res = 'es_extended'
		while not ESX do
			TriggerEvent('esx:getSharedObject', function(obj)
				ESX = obj
			end)
			if not ESX then
				pcall(function()
					ESX = exports[res]:getSharedObject()
				end)
			end
			Wait(200)
		end
	end)
end

function NotificationServer(source, notification, notificationType, duration)
	local src = tonumber(source)
	if not src then
		return
	end
	notification = tostring(notification or '')
	notificationType = notificationType or 'inform'
	local d = notifyDuration(duration)
	local style = Config.Notification or 'ox'

	if style == 'ox' then
		TriggerClientEvent('ox_lib:notify', src, {
			description = notification,
			type = notificationType,
			duration = d,
			position = 'top-right',
		})
		return
	end
	if style == 'qb' and (Config.Framework == 'qb-core' or Config.Framework == 'qbox') then
		TriggerClientEvent('QBCore:Notify', src, notification, notificationType, d)
		return
	end
	if style == 'esx' or (Config.Framework == 'esx' and style ~= 'chat') then
		TriggerClientEvent('esx:showNotification', src, notification)
		return
	end
	TriggerClientEvent('chat:addMessage', src, {
		color = notificationType == 'error' and { 255, 80, 80 } or { 80, 255, 120 },
		multiline = false,
		args = { 'Ammo', notification },
	})
end

function ItemBox(source, item, addRemove, amount)
	if Config.Framework ~= 'qb-core' and Config.Framework ~= 'qbox' then
		return
	end
	if Config.Inventory == 'ox' then
		return
	end
	local QBCore = qbCore()
	if not QBCore or not QBCore.Shared or not QBCore.Shared.Items then
		return
	end
	local def = QBCore.Shared.Items[item]
	if type(def) == 'table' then
		TriggerClientEvent('inventory:client:ItemBox', source, def, addRemove, amount)
	end
end

function GetItemLabel(itemName)
	itemName = tostring(itemName or ''):match('^%s*(.-)%s*$')
	if itemName == '' then
		return nil
	end
	if Config.Inventory == 'ox' and GetResourceState('ox_inventory') == 'started' then
		local ok, def = pcall(function()
			return exports.ox_inventory:Items(itemName)
		end)
		if ok and type(def) == 'table' and type(def.label) == 'string' and def.label ~= '' then
			return def.label
		end
	end
	if Config.Framework == 'qb-core' or Config.Framework == 'qbox' then
		local ok, QBCore = pcall(qbCore)
		if ok and QBCore and QBCore.Shared and QBCore.Shared.Items then
			local it = QBCore.Shared.Items[itemName]
			if type(it) == 'table' and type(it.label) == 'string' and it.label ~= '' then
				return it.label
			end
		end
	end
	return nil
end

function GetFirstItemSlotMetadata(source, itemName)
	local src = tonumber(source)
	itemName = tostring(itemName or ''):match('^%s*(.-)%s*$')
	if not src or itemName == '' then
		return nil
	end
	if Config.Inventory == 'ox' and GetResourceState('ox_inventory') == 'started' then
		local ok, slots = pcall(function()
			return exports.ox_inventory:Search(src, 'slots', itemName)
		end)
		if ok and type(slots) == 'table' then
			for _, slot in pairs(slots) do
				if slot and type(slot.metadata) == 'table' then
					return slot.metadata
				end
			end
		end
	end
	return nil
end

local function qbWeightCheck(src, itemName, amt)
	local ok, QBCore = pcall(qbCore)
	if not ok or not QBCore or not QBCore.Shared or not QBCore.Shared.Items then return nil end
	local ok2, Player = pcall(function()
		return QBCore.Functions.GetPlayer(src)
	end)
	if not ok2 or not Player or not Player.PlayerData then return nil end
	local itemInfo = QBCore.Shared.Items[itemName]
	if not itemInfo then return false end
	local addWeight = (itemInfo.weight or 0) * amt
	local currentWeight = 0
	if Player.PlayerData.items then
		for _, slot in pairs(Player.PlayerData.items) do
			if slot then
				local info = QBCore.Shared.Items[slot.name]
				currentWeight = currentWeight + ((info and info.weight or 0) * (slot.amount or 1))
			end
		end
	end
	local maxWeight = QBCore.Config and QBCore.Config.MaxInventoryWeight or 120000
	return (currentWeight + addWeight) <= maxWeight
end

function CanCarryItem(source, itemName, amount)
	local src = tonumber(source)
	local amt = math.floor(tonumber(amount) or 0)
	itemName = tostring(itemName or ''):match('^%s*(.-)%s*$')
	if not src or itemName == '' or amt < 1 then
		return false
	end

	if Config.Inventory == 'ox' and GetResourceState('ox_inventory') == 'started' then
		local ok, r = pcall(function()
			return exports.ox_inventory:CanCarryItem(src, itemName, amt)
		end)
		return ok and r == true
	end

	if Config.Inventory == 'qb' and (Config.Framework == 'qb-core' or Config.Framework == 'qbox') then
		local result = qbWeightCheck(src, itemName, amt)
		if result ~= nil then return result end
		return false
	end

	if Config.Inventory == 'ps' then
		local ok, r = pcall(function()
			return exports['ps-inventory']:CanAddItem(src, itemName, amt)
		end)
		if ok and r ~= nil then return r == true end
		if Config.Framework == 'qb-core' or Config.Framework == 'qbox' then
			local result = qbWeightCheck(src, itemName, amt)
			if result ~= nil then return result end
		end
		return true
	end

	if Config.Inventory == 'codem' then
		local ok, r = pcall(function()
			return exports['codem-inventory']:CanCarryItem(src, itemName, amt)
		end)
		if ok and r ~= nil then return r == true end
		return true
	end

	if Config.Inventory == 'origen' then
		local ok, r = pcall(function()
			return exports.origen_inventory:CanCarryItem(src, itemName, amt)
		end)
		if ok and r ~= nil then return r == true end
		return true
	end

	if Config.Inventory == 'tgiann' then
		local ok, r = pcall(function()
			return exports['tgiann-inventory']:CanCarryItem(src, itemName, amt)
		end)
		if ok and r ~= nil then return r == true end
		return true
	end

	return true
end

function AddItem(source, item, amount, info)
	local src = tonumber(source)
	amount = math.floor(tonumber(amount) or 0)
	item = tostring(item or ''):match('^%s*(.-)%s*$')
	if not src or item == '' or amount < 1 then
		return false
	end

	if Config.Inventory == 'ox' and GetResourceState('ox_inventory') == 'started' then
		local ok, a, b = pcall(function()
			return exports.ox_inventory:AddItem(src, item, amount, info)
		end)
		if not ok then
			return false
		end
		if a == true or a == 1 then
			return true
		end
		return a ~= false and a ~= nil
	end

	if Config.Inventory == 'origen' then
		local ok, r = pcall(function()
			return exports.origen_inventory:AddItem(src, item, amount, nil, nil, info)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'add', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'codem' then
		local ok, r = pcall(function()
			return exports['codem-inventory']:AddItem(src, item, amount, nil, info)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'add', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'tgiann' then
		local ok, r = pcall(function()
			return exports['tgiann-inventory']:AddItem(src, item, amount, nil, info, false)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'add', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'ps' then
		local ok, r = pcall(function()
			return exports['ps-inventory']:AddItem(src, item, amount, nil, info)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'add', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'qb' and (Config.Framework == 'qb-core' or Config.Framework == 'qbox') then
		local ok, Player = pcall(function()
			return qbCore().Functions.GetPlayer(src)
		end)
		if ok and Player and Player.Functions and Player.Functions.AddItem then
			local ok2, r = pcall(function()
				return Player.Functions.AddItem(item, amount, false, info)
			end)
			if ok2 and r ~= false and r ~= nil then
				ItemBox(src, item, 'add', amount)
				return true
			end
		end
		return false
	end

	if Config.Framework == 'esx' then
		while not ESX do
			Wait(100)
		end
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer and xPlayer.addInventoryItem then
			xPlayer.addInventoryItem(item, amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'custom' or Config.Framework == 'custom' then
		-- Implement your AddItem here.
	end

	return false
end

function RemoveItem(source, item, amount)
	local src = tonumber(source)
	amount = math.floor(tonumber(amount) or 0)
	item = tostring(item or ''):match('^%s*(.-)%s*$')
	if not src or item == '' or amount < 1 then
		return false
	end

	if Config.Inventory == 'ox' and GetResourceState('ox_inventory') == 'started' then
		local ok, r = pcall(function()
			return exports.ox_inventory:RemoveItem(src, item, amount)
		end)
		return ok and r ~= false and r ~= nil
	end

	if Config.Inventory == 'origen' then
		local ok, r = pcall(function()
			return exports.origen_inventory:RemoveItem(src, item, amount)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'remove', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'codem' then
		local ok, r = pcall(function()
			return exports['codem-inventory']:RemoveItem(src, item, amount)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'remove', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'tgiann' then
		local ok, r = pcall(function()
			return exports['tgiann-inventory']:RemoveItem(src, item, amount)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'remove', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'ps' then
		local ok, r = pcall(function()
			return exports['ps-inventory']:RemoveItem(src, item, amount, nil)
		end)
		if ok and r ~= false and r ~= nil then
			ItemBox(src, item, 'remove', amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'qb' and (Config.Framework == 'qb-core' or Config.Framework == 'qbox') then
		local ok, Player = pcall(function()
			return qbCore().Functions.GetPlayer(src)
		end)
		if ok and Player and Player.Functions and Player.Functions.RemoveItem then
			local ok2, r = pcall(function()
				return Player.Functions.RemoveItem(item, amount)
			end)
			if ok2 and r ~= false and r ~= nil then
				ItemBox(src, item, 'remove', amount)
				return true
			end
		end
		return false
	end

	if Config.Framework == 'esx' then
		while not ESX do
			Wait(100)
		end
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer and xPlayer.removeInventoryItem then
			xPlayer.removeInventoryItem(item, amount)
			return true
		end
		return false
	end

	if Config.Inventory == 'custom' or Config.Framework == 'custom' then
		-- Implement your RemoveItem here.
	end

	return false
end

function RegisterAmmoUseableItem(itemName, handler)
	if type(itemName) ~= 'string' or itemName == '' or type(handler) ~= 'function' then
		return
	end

	if Config.Framework == 'qbox' then
		CreateThread(function()
			local res = 'qbx_core'
			local n, lastErr = 0, nil
			while n < 100 do
				if GetResourceState(res) == 'started' then
					local ok, err = pcall(function()
						exports[res]:CreateUseableItem(itemName, function(source, item)
							handler(source, item)
						end)
					end)
					if ok then
						return
					end
					lastErr = err
				end
				n = n + 1
				Wait(100)
			end
			print(('[Croll-Ammo] CreateUseableItem(%s) failed: %s'):format(itemName, tostring(lastErr)))
		end)
		return
	end

	if Config.Framework == 'qb-core' then
		CreateThread(function()
			local res = 'qb-core'
			local n = 0
			while n < 100 do
				if GetResourceState(res) == 'started' then
					local ok, QBCore = pcall(function()
						return exports[res]:GetCoreObject()
					end)
					if ok and QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
						QBCore.Functions.CreateUseableItem(itemName, function(source, item)
							handler(source, item)
						end)
						return
					end
				end
				n = n + 1
				Wait(100)
			end
			print(('[Croll-Ammo] CreateUseableItem(%s) failed — is %s started?'):format(itemName, res))
		end)
		return
	end

	if Config.Framework == 'esx' then
		CreateThread(function()
			while not ESX do
				Wait(100)
			end
			ESX.RegisterUsableItem(itemName, function(source)
				handler(source, nil)
			end)
		end)
		return
	end

	-- Config.Framework == 'custom': register your own usable / item use handler here.
end

function GetPlayerJob(source)
	local src = tonumber(source)
	if not src then return nil end

	if Config.Framework == 'qbox' then
		local ok, player = pcall(function()
			return exports.qbx_core:GetPlayer(src)
		end)
		if ok and player then
			local job = player.PlayerData and player.PlayerData.job
			if job and job.name then
				return job.name
			end
		end
		local ok2, QBCore = pcall(function()
			return exports.qbx_core:GetCoreObject()
		end)
		if ok2 and QBCore and QBCore.Functions then
			local ok3, Player = pcall(function()
				return QBCore.Functions.GetPlayer(src)
			end)
			if ok3 and Player and Player.PlayerData and Player.PlayerData.job then
				return Player.PlayerData.job.name
			end
		end
		return nil
	end

	if Config.Framework == 'qb-core' then
		local ok, Player = pcall(function()
			return qbCore().Functions.GetPlayer(src)
		end)
		if ok and Player and Player.PlayerData and Player.PlayerData.job then
			return Player.PlayerData.job.name
		end
		return nil
	end

	if Config.Framework == 'esx' then
		if not ESX then return nil end
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer and xPlayer.job then
			return xPlayer.job.name
		end
		return nil
	end

	-- Config.Framework == 'custom': return the player's job name here.
	return nil
end
