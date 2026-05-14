Config = {}

-- qbox | qb-core | esx | custom (edit opensource/server/opensource.lua for custom)
Config.Framework = 'qbox'

-- ox | qb | ps | codem | origen | tgiann | custom
Config.Inventory = 'ox'

-- ox | qb | esx 
Config.Notification = 'ox'

Config.NotificationDuration = 5000

Config.AtomicUnpack = true

-- Set to false to ignore all per-box job restrictions
Config.EnableJobRestrictions = false

-- Must match a file in locale/ (e.g. 'en' loads locale/en.lua)
Config.Language = 'en'

-- Default progress bar duration (ms) when a box has no usetime override
Config.DefaultUsetime = 4000

-- Default client-side unpack animation
-- For ox_inventory: copy these into each box item's `client` data in your items file.
Config.BoxUnpackClient = {
    cancel = true,
    anim = { dict = 'mini@repair', clip = 'fixing_a_ped', flag = 49 },
    disable = { move = true, car = true, combat = true },
}

--[[
    Ammo Box Catalog

    Each key is the item name of the box.

    Fields:
        rewards      (required)  table<string, number|number[]>
                     number = fixed amount, {min, max} = server-generated random range
        notifyPhrase (optional)  string shown on success ("You unpacked %s.")
        job          (optional)  string or string[] of allowed job names (nil = no restriction)
        usetime      (optional)  number in ms, overrides Config.DefaultUsetime for this box

    Examples:

    -- Fixed amount, no restrictions, default usetime
    ['ammo_basic'] = {
        rewards = { ['ammo-9'] = 50 },
        notifyPhrase = 'your 9mm box',
    },

    -- Random amount between 20-40, police only, custom usetime
    ['ammo_crate_pd'] = {
        rewards = {
            ['ammo-rifle'] = {20, 40},
        },
        notifyPhrase = 'your police supply crate',
        job = {'police', 'sheriff'},
        usetime = 5000,
    },
]]

Config.AmmoBoxes = {
    ['ammo_rifle'] = {
        rewards = { ['ammo-rifle'] = 30 },
        notifyPhrase = 'your 5.56x45 box',
    },
    ['ammo-22box'] = {
        rewards = { ['ammo-22'] = 50 },
        notifyPhrase = 'your .22 LR box',
    },
    ['ammo-38box'] = {
        rewards = { ['ammo-38'] = 50 },
        notifyPhrase = 'your .38 LC box',
    },
    ['ammo-44box'] = {
        rewards = { ['ammo-44'] = 50 },
        notifyPhrase = 'your .44 Magnum box',
    },
    ['ammo-45box'] = {
        rewards = { ['ammo-45'] = 50 },
        notifyPhrase = 'your .45 ACP box',
    },
    ['ammo-50box'] = {
        rewards = { ['ammo-50'] = 20 },
        notifyPhrase = 'your .50 AE box',
    },
    ['ammo_pistol'] = {
        rewards = { ['ammo-9'] = 50 },
        notifyPhrase = 'your 9mm box',
    },
    ['ammo_rifle2'] = {
        rewards = { ['ammo-rifle2'] = 30 },
        notifyPhrase = 'your 7.62x39 box',
    },
    ['ammo_shotgun'] = {
        rewards = { ['ammo-shotgun'] = 25 },
        notifyPhrase = 'your 12 gauge box',
    },
    ['ammo_shotgun_pd'] = {
        rewards = { ['ammo-justices'] = 25 },
        notifyPhrase = 'your 12 gauge Justice box',
        job = 'police',
    },
    ['ammo_rifle_pd'] = {
        rewards = { ['ammo-justicea'] = 30 },
        notifyPhrase = 'your 5.56x45 Justice box',
        job = 'police',
    },
    ['ammo_pistol_pd'] = {
        rewards = { ['ammo-justicep'] = 50 },
        notifyPhrase = 'your 9mm Justice box',
        job = 'police',
    },
}

function L(key, ...)
    if not Locales then return key end
    local lang = Config and Config.Language or 'en'
    local str = Locales[lang] and Locales[lang][key]
    if not str then
        str = Locales['en'] and Locales['en'][key]
    end
    if not str then return key end
    local n = select('#', ...)
    if n > 0 then
        local ok, result = pcall(string.format, str, ...)
        return ok and result or str
    end
    return str
end
