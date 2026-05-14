local version = '1.1.1'
local versionUrl = 'https://raw.githubusercontent.com/DrCroll/Croll-Ammo/main/Croll-Ammo/version'

CreateThread(function()
    PerformHttpRequest(versionUrl, function(code, body)
        if code ~= 200 or not body then
            return
        end

        local latest = body:gsub('%s+', '')
        if latest == '' then
            return
        end

        if version ~= latest then
            print('^1----------------------| Croll-Ammo |---------------------')
            print('            ^0New version available [^1' .. latest .. '^0]')
            print('     ^5https://github.com/DrCroll/Croll-Ammo')
            print('^1----------------------| Croll-Ammo |---------------------^0')
        else
            print('^2Croll-Ammo is up to date! (^0' .. version .. '^2)^0')
        end
    end)
end)
