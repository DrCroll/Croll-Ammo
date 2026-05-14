--[[
    Croll-Ammo -- core logic (keep portable).
    Inventory / framework hooks live in `opensource/server/opensource.lua`.
]]

local activeUnpacks = {}
local pendingRewards = {}

local function invAddItem(src, name, count, meta)
    return AddItem(src, name, count, meta) == true
end

local function invRemoveItem(src, name, count)
    return RemoveItem(src, name, count) == true
end

local function invCanCarryItem(src, name, count)
    return CanCarryItem(src, name, count) == true
end

---@param itemName string
---@return string|nil
local function invItemLabel(itemName)
    local label = GetItemLabel(itemName)
    if type(label) == 'string' and label ~= '' then
        return label
    end
    return nil
end

---@param item any
---@return table|nil
local function metaFromUsableItem(item)
    if type(item) ~= 'table' then
        return nil
    end
    local m = item.metadata or item.info or item.MetaData
    if type(m) == 'table' and next(m) then
        return m
    end
    return nil
end

if type(LoadServerAmmoCatalog) ~= 'function' then
    error('[Croll-Ammo] LoadServerAmmoCatalog missing. Ensure `server/amounts.lua` is loaded before server/main.lua.')
end
LoadServerAmmoCatalog()

CreateThread(function()
    Wait(1000)
    if Config.Inventory ~= 'ox' or GetResourceState('ox_inventory') ~= 'started' then
        return
    end
    for boxName in pairs(Config.AmmoBoxes) do
        local ok, def = pcall(function()
            return exports.ox_inventory:Items(boxName)
        end)
        if ok and not def then
            print(('[Croll-Ammo] Item "%s" missing from ox_inventory — add it to data/items.lua (see install/ folder).'):format(boxName))
        end
    end
end)

---@param v number|number[]|nil
---@return number?
local function resolveAmount(v)
    if type(v) == 'number' then
        return math.floor(v)
    end
    if type(v) == 'table' and type(v[1]) == 'number' and type(v[2]) == 'number' then
        local min = math.floor(v[1])
        local max = math.floor(v[2])
        if min >= 1 and max >= min then
            return math.random(min, max)
        end
    end
    return nil
end

---@param rewardsDef table<string, number|number[]>
---@return table<string, number>|nil, string|nil
local function resolvedRewards(rewardsDef)
    local out = {}
    for ammoName, raw in pairs(rewardsDef) do
        local n = resolveAmount(raw)
        if not n or n < 1 then
            return nil, ('invalid amount for %s'):format(ammoName)
        end
        out[ammoName] = n
    end
    if not next(out) then
        return nil, 'empty box definition'
    end
    return out
end

---@param meta table|nil
---@return table|nil
local function shallowCopyMeta(meta)
    if not meta or not next(meta) then
        return nil
    end
    local out = {}
    for k, v in pairs(meta) do
        out[k] = v
    end
    return out
end

---@param rewards table<string, number>
---@return { name: string, count: integer }[]
local function rewardsToSortedList(rewards)
    local keys = {}
    for k in pairs(rewards) do
        keys[#keys + 1] = k
    end
    table.sort(keys)
    local list = {}
    for i = 1, #keys do
        local name = keys[i]
        list[#list + 1] = { name = name, count = rewards[name] }
    end
    return list
end

---@param boxName string
---@return string
local function unpackSuccessDescription(boxName)
    local phrase = Config.BoxLabels and Config.BoxLabels[boxName]
    if type(phrase) == 'string' and phrase ~= '' then
        return L('unpacked_named', phrase)
    end
    local label = invItemLabel(boxName)
    if label then
        return L('unpacked_named', label)
    end
    return L('unpacked')
end

local function notify(src, payload)
    NotificationServer(src, payload.description or '', payload.type or 'inform', Config.NotificationDuration)
end

---@param src number
---@param boxDef table
---@return boolean
local function isJobAllowed(src, boxDef)
    if not Config.EnableJobRestrictions then
        return true
    end
    local jobReq = boxDef.job
    if not jobReq then
        return true
    end
    local playerJob = GetPlayerJob(src)
    if not playerJob then
        print(('[Croll-Ammo] Job check failed for src=%s — GetPlayerJob returned nil'):format(tostring(src)))
        return false
    end
    if type(jobReq) == 'string' then
        if playerJob ~= jobReq then
            print(('[Croll-Ammo] Job mismatch src=%s playerJob="%s" required="%s"'):format(tostring(src), playerJob, jobReq))
            return false
        end
        return true
    end
    if type(jobReq) == 'table' then
        for i = 1, #jobReq do
            if jobReq[i] == playerJob then
                return true
            end
        end
        print(('[Croll-Ammo] Job mismatch src=%s playerJob="%s" required={%s}'):format(
            tostring(src), playerJob, table.concat(jobReq, ', ')
        ))
    end
    return false
end

---@param boxDef table
---@return number
local function getUsetime(boxDef)
    if boxDef.usetime then
        return math.floor(tonumber(boxDef.usetime) or 0)
    end
    return math.floor(tonumber(Config.DefaultUsetime) or 0)
end

---@param src number
---@param given { name: string, count: integer }[]
local function rollbackGivenAmmo(src, given)
    for i = #given, 1, -1 do
        local entry = given[i]
        local ok = invRemoveItem(src, entry.name, entry.count)
        if not ok then
            print(('[Croll-Ammo] CRITICAL rollback RemoveItem failed src=%s item=%s count=%s'):format(
                tostring(src),
                tostring(entry.name),
                tostring(entry.count)
            ))
            return false
        end
    end
    return true
end

---@param src number
---@param boxName string
---@param meta table|nil
---@return boolean
local function restoreBox(src, boxName, meta)
    local ok = invAddItem(src, boxName, 1, meta)
    if not ok then
        print(('[Croll-Ammo] CRITICAL could not restore box src=%s box=%s'):format(tostring(src), tostring(boxName)))
        return false
    end
    return true
end

---@param src number
---@param boxName string
---@param rewards table<string, number>
---@param restoreMeta table|nil
local function grantAmmoRewardsOrRollback(src, boxName, rewards, restoreMeta)
    local list = rewardsToSortedList(rewards)
    local given = {}

    if Config.AtomicUnpack then
        for i = 1, #list do
            local entry = list[i]
            local ok = invAddItem(src, entry.name, entry.count)
            if not ok then
                print(('[Croll-Ammo] AddItem failed (atomic) src=%s ammo=%s count=%s'):format(
                    tostring(src),
                    tostring(entry.name),
                    tostring(entry.count)
                ))
                if not rollbackGivenAmmo(src, given) then
                    restoreBox(src, boxName, restoreMeta)
                    notify(src, { type = 'error', description = L('give_failed_critical') })
                    return
                end
                if not restoreBox(src, boxName, restoreMeta) then
                    notify(src, { type = 'error', description = L('give_failed_critical') })
                    return
                end
                notify(src, { type = 'error', description = L('give_failed_returned') })
                return
            end
            given[#given + 1] = { name = entry.name, count = entry.count }
        end
        notify(src, { type = 'success', description = unpackSuccessDescription(boxName) })
        return
    end

    local anyFail = false
    for i = 1, #list do
        local entry = list[i]
        local ok = invAddItem(src, entry.name, entry.count)
        if not ok then
            anyFail = true
            print(('[Croll-Ammo] AddItem failed (non-atomic) src=%s ammo=%s count=%s'):format(
                tostring(src),
                tostring(entry.name),
                tostring(entry.count)
            ))
        end
    end
    if anyFail then
        notify(src, { type = 'error', description = L('give_failed_partial') })
    else
        notify(src, { type = 'success', description = unpackSuccessDescription(boxName) })
    end
end

local function parseOpenBoxArgs(a, b, c, d, e)
    if a == nil then
        return b, c, d, e
    end
    if type(a) == 'string' and (a == 'usingItem' or a == 'usedItem' or a == 'buyItem') then
        return a, b, c, d
    end
    return nil
end

-- ox_inventory: `server.export = '<resource-folder>.openBox'`
exports('openBox', function(a, b, c, d, e)
    local event, item, inventory, slot = parseOpenBoxArgs(a, b, c, d, e)
    if type(event) ~= 'string' or type(item) ~= 'table' or type(inventory) ~= 'table' then
        return false
    end

    if event == 'buyItem' then
        return
    end

    local src = inventory.id
    if type(src) ~= 'number' then
        return false
    end

    local boxName = item and item.name
    if type(boxName) ~= 'string' then
        return false
    end

    local boxDef = Config.AmmoBoxes[boxName]
    if not boxDef then
        if event == 'usingItem' then
            notify(src, { type = 'error', description = L('unknown_box') })
        end
        return false
    end

    if not isJobAllowed(src, boxDef) then
        if event == 'usingItem' then
            notify(src, { type = 'error', description = L('job_restricted') })
        end
        return false
    end

    if event == 'usingItem' then
        local rewards, err = resolvedRewards(boxDef.rewards)
        if not rewards then
            notify(src, { type = 'error', description = err or L('unknown_box') })
            return false
        end

        for ammoName, count in pairs(rewards) do
            if not invCanCarryItem(src, ammoName, count) then
                notify(src, { type = 'error', description = L('no_space') })
                return false
            end
        end

        pendingRewards[src] = { boxName = boxName, rewards = rewards, time = os.time() }
        return
    end

    if event == 'usedItem' then
        local rewards
        local pending = pendingRewards[src]
        if pending and pending.boxName == boxName and (os.time() - pending.time) < 60 then
            rewards = pending.rewards
        else
            local err
            rewards, err = resolvedRewards(boxDef.rewards)
            if not rewards then
                pendingRewards[src] = nil
                return false
            end
        end
        pendingRewards[src] = nil

        local restoreMeta = shallowCopyMeta(inventory.usingItem and inventory.usingItem.metadata)
        grantAmmoRewardsOrRollback(src, boxName, rewards, restoreMeta)
    end
end)

local function handleCoreUsableItem(src, boxName, item)
    if activeUnpacks[src] then
        notify(src, { type = 'error', description = L('already_unpacking') })
        return
    end

    local boxDef = Config.AmmoBoxes[boxName]
    if not boxDef then
        notify(src, { type = 'error', description = L('unknown_box') })
        return
    end

    if not isJobAllowed(src, boxDef) then
        notify(src, { type = 'error', description = L('job_restricted') })
        return
    end

    local rewards, err = resolvedRewards(boxDef.rewards)
    if not rewards then
        notify(src, { type = 'error', description = err or L('unknown_box') })
        return
    end

    for ammoName, count in pairs(rewards) do
        if not invCanCarryItem(src, ammoName, count) then
            notify(src, { type = 'error', description = L('no_space') })
            return
        end
    end

    local usetime = getUsetime(boxDef)

    if usetime > 0 then
        activeUnpacks[src] = true
        TriggerClientEvent('Croll-Ammo:playUnpackAnim', src, usetime)
        Wait(usetime)
        activeUnpacks[src] = nil

        if not GetPlayerName(src) then return end

        for ammoName, count in pairs(rewards) do
            if not invCanCarryItem(src, ammoName, count) then
                notify(src, { type = 'error', description = L('no_space') })
                return
            end
        end
    end

    local restoreMeta = shallowCopyMeta(metaFromUsableItem(item))
    if not restoreMeta then
        restoreMeta = shallowCopyMeta(GetFirstItemSlotMetadata(src, boxName))
    end

    if not invRemoveItem(src, boxName, 1) then
        notify(src, { type = 'error', description = L('could_not_remove_box') })
        return
    end

    grantAmmoRewardsOrRollback(src, boxName, rewards, restoreMeta)
end

CreateThread(function()
    Wait(2500)
    if GetResourceState('ox_inventory') == 'started' then
        return
    end
    for boxName in pairs(Config.AmmoBoxes) do
        RegisterAmmoUseableItem(boxName, function(source, item)
            handleCoreUsableItem(source, boxName, item)
        end)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeUnpacks[src] = nil
    pendingRewards[src] = nil
end)
