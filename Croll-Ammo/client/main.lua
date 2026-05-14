local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local attempts = 0
    while not HasAnimDictLoaded(dict) and attempts < 500 do
        Wait(10)
        attempts = attempts + 1
    end
    return HasAnimDictLoaded(dict)
end

RegisterNetEvent('Croll-Ammo:playUnpackAnim', function(usetime)
    if type(usetime) ~= 'number' or usetime <= 0 then return end

    local ped = PlayerPedId()
    local cfg = Config.BoxUnpackClient
    local anim = cfg and cfg.anim
    local disable = cfg and cfg.disable

    if anim and anim.dict and anim.clip then
        if loadAnimDict(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, usetime, anim.flag or 49, 0, false, false, false)
        end
    end

    local endTime = GetGameTimer() + usetime
    CreateThread(function()
        while GetGameTimer() < endTime do
            if disable then
                if disable.move then
                    DisableControlAction(0, 30, true)
                    DisableControlAction(0, 31, true)
                    DisableControlAction(0, 21, true)
                    DisableControlAction(0, 36, true)
                end
                if disable.car then
                    DisableControlAction(0, 75, true)
                end
                if disable.combat then
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 25, true)
                    DisableControlAction(0, 47, true)
                    DisableControlAction(0, 58, true)
                end
            end
            Wait(0)
        end
        ClearPedTasks(ped)
        if anim and anim.dict then
            RemoveAnimDict(anim.dict)
        end
    end)
end)
