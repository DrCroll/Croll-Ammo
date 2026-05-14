--[[
    Croll-Ammo -- catalog validation (server-side only).
    Validates Config.AmmoBoxes entries defined in config.lua.
]]

function LoadServerAmmoCatalog()
    Config.BoxLabels = {}

    if type(Config.AmmoBoxes) ~= 'table' then
        error('[Croll-Ammo] Config.AmmoBoxes must be a table.')
    end

    for boxName, def in pairs(Config.AmmoBoxes) do
        if type(boxName) ~= 'string' or boxName == '' then
            error('[Croll-Ammo] Invalid box key in Config.AmmoBoxes.')
        end
        if type(def) ~= 'table' or type(def.rewards) ~= 'table' or not next(def.rewards) then
            error(('[Croll-Ammo] Box "%s" must define a non-empty rewards table.'):format(boxName))
        end

        for ammoName, amount in pairs(def.rewards) do
            if type(ammoName) ~= 'string' or ammoName == '' then
                error(('[Croll-Ammo] Invalid ammo name in box "%s".'):format(boxName))
            end
            if type(amount) == 'number' then
                local n = math.floor(amount)
                if n < 1 or n > 10000 then
                    error(('[Croll-Ammo] Invalid amount in box "%s": ammo=%s amount=%s'):format(boxName, ammoName, tostring(amount)))
                end
            elseif type(amount) == 'table' and #amount == 2 then
                local min = math.floor(tonumber(amount[1]) or -1)
                local max = math.floor(tonumber(amount[2]) or -1)
                if min < 1 or max < min or max > 10000 then
                    error(('[Croll-Ammo] Invalid range in box "%s": ammo=%s range={%s, %s}'):format(
                        boxName, ammoName, tostring(amount[1]), tostring(amount[2])
                    ))
                end
            else
                error(('[Croll-Ammo] Invalid reward format in box "%s": ammo=%s (use number or {min, max})'):format(boxName, ammoName))
            end
        end

        if def.notifyPhrase ~= nil and type(def.notifyPhrase) ~= 'string' then
            error(('[Croll-Ammo] notifyPhrase for box "%s" must be a string.'):format(boxName))
        end

        if def.job ~= nil then
            if type(def.job) ~= 'string' and type(def.job) ~= 'table' then
                error(('[Croll-Ammo] job for box "%s" must be a string or table of strings.'):format(boxName))
            end
            if type(def.job) == 'table' then
                for i = 1, #def.job do
                    if type(def.job[i]) ~= 'string' then
                        error(('[Croll-Ammo] job[%d] for box "%s" must be a string.'):format(i, boxName))
                    end
                end
            end
        end

        if def.usetime ~= nil then
            local ut = tonumber(def.usetime)
            if not ut or ut < 0 then
                error(('[Croll-Ammo] usetime for box "%s" must be a positive number.'):format(boxName))
            end
        end

        if type(def.notifyPhrase) == 'string' and def.notifyPhrase ~= '' then
            Config.BoxLabels[boxName] = def.notifyPhrase
        end
    end
end
