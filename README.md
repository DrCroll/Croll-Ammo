## Croll-Ammo - discord.gg/DBqCZjZ8VN

Server-authoritative ammo box unpacking for FiveM (Qbox, QB-Core, ESX, and custom adapters).

## Features

- Server-side reward catalog and validation.
- Supports `ox_inventory` export flow and framework usable-item flow.
- Atomic unpack mode with rollback protection.
- Configurable framework, inventory adapter, and notify provider.
- Input sanitization and defensive checks around item use.

## Resource Structure

- `fxmanifest.lua` resource manifest.
- `config.lua` framework/inventory/notify options and locale text.
- `server/amounts.lua` server-only ammo box catalog.
- `server/opensource.lua` framework + inventory adapter layer.
- `server/main.lua` secure unpack flow and rollback logic.
- `install/ox_inventory_ammo_boxes.lua` example item definitions for `ox_inventory`.

## Requirements

- FiveM server 
- One of:
  - Qbox (`qbx_core`)
  - QB-Core (`qb-core`)
  - ESX (`es_extended`)
  - Custom framework/inventory implementation (edit `server/opensource.lua`)

Optional:

- `ox_inventory` (recommended)
- `ox_lib` (when `Config.Notification = 'ox'`)

## Installation

1. Place the resource folder in your server resources.
2. Ensure this resource after your framework and inventory resources in `server.cfg`.
3. Open `config.lua` and set:
   - `Config.Framework`
   - `Config.Inventory`
   - `Config.Notification`
4. Configure your ammo box catalog in `server/amounts.lua`.
5. Restart the resource.

## ox_inventory Setup

When using `ox_inventory`, each ammo box item must call this server export:

- `server.export = 'Croll-Ammo.openBox'`

Use `install/ox_inventory_ammo_boxes.lua` as a template and merge `Config.BoxUnpackClient` into each item's `client` data if you want progress/animation UX.

## Non-ox Setup (QB/Qbox/ESX/Custom)

If `ox_inventory` is not running, the resource auto-registers usable items through your selected framework in `server/opensource.lua`.

For custom frameworks/inventories:

- Implement `AddItem`, `RemoveItem`, `CanCarryItem`, and `RegisterAmmoUseableItem`.
- Keep all reward logic in `server/amounts.lua` and `server/main.lua` 

## Configuration Notes

`config.lua`:

- `Config.Framework`: `qbox | qb-core | esx | custom`
- `Config.Inventory`: `ox | qb | codem | origen | tgiann | custom`
- `Config.Notification`: `ox | qb | esx | chat`

`server/amounts.lua`:

- Defines every ammo box and reward amount server-side.
- Rejects invalid entries at load time (empty names, bad amounts, malformed tables).

## Troubleshooting

- If you see missing item warnings for `ox_inventory`, add those item names to your `ox_inventory` items data.
- If boxes do nothing on use:
  - verify `Config.Framework` and `Config.Inventory`
  - verify dependencies are started before this resource
  - verify the item export/usable registration path matches your inventory mode
- If notifications do not appear, switch `Config.Notification` to a provider your server runs.

## Extending

- Add/remove boxes in `server/amounts.lua`.
- Update labels/phrases by setting `notifyPhrase` per box in the catalog.
- For advanced custom behavior, edit only adapter functions in `server/opensource.lua` and keep core unpack logic untouched.
