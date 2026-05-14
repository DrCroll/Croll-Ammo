## Croll-Ammo 

Open-source, server-authoritative ammo box unpacking for FiveM (Qbox, QB-Core, ESX, and custom adapters).

## Features

- Server-side reward catalog with validation at load time.
- Fixed or random reward amounts per ammo type (`30` or `{20, 40}` for a random range).
- Optional per-box job restriction (single job or multiple).
- Per-box progress bar duration with client animation for non-ox flows.
- Supports `ox_inventory` server export and framework usable-item flow.
- Atomic unpack mode with full rollback protection.
- Multi-language locale system.
- Configurable framework, inventory adapter, and notification provider.

## Requirements

- FiveM server with OneSync.
- One of:
  - Qbox (`qbx_core`)
  - QB-Core (`qb-core`)
  - ESX (`es_extended`)
  - Custom framework (edit `opensource/server/opensource.lua`)

Optional:

- `ox_inventory` (recommended)
- `ox_lib` (when `Config.Notification = 'ox'`)

## Installation

1. Place the resource folder in your server resources.
2. Ensure this resource **after** your framework and inventory resources in `server.cfg`.
3. Open `config.lua` and set `Config.Framework`, `Config.Inventory`, and `Config.Notification`.
4. Configure your ammo boxes in `Config.AmmoBoxes` (see below).
5. Restart the resource.

## ox_inventory Setup

Each ammo box item in `ox_inventory` must call the server export:

```
server.export = 'Croll-Ammo.openBox'
```

Use `install/ox_inventory_ammo_boxes.lua` as a template. Set each item's `client.usetime` to match the `usetime` you defined for that box in `Config.AmmoBoxes`.

## Non-ox Setup (QB / Qbox / ESX / Custom)

If `ox_inventory` is not running, the resource auto-registers usable items through your framework adapter. A client-side animation plays for the configured `usetime` duration.

For custom frameworks, implement `AddItem`, `RemoveItem`, `CanCarryItem`, `GetPlayerJob`, and `RegisterAmmoUseableItem` in `opensource/server/opensource.lua`.

## Configuration

### Box Catalog (`Config.AmmoBoxes`)

Each entry supports:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `rewards` | `table<string, number\|{min,max}>` | Yes | Ammo items and amounts. Use a number for fixed or `{min, max}` for server-generated random. |
| `notifyPhrase` | `string` | No | Shown on success: "You unpacked %s." |
| `job` | `string \| string[]` | No | Restrict to job(s). `nil` = anyone. |
| `usetime` | `number` | No | Progress duration in ms. Falls back to `Config.DefaultUsetime`. |

Example:

```lua
Config.AmmoBoxes = {
    ['ammo_pistol'] = {
        rewards = { ['ammo-9'] = {40, 60} },
        notifyPhrase = 'your 9mm box',
        usetime = 2000,
    },
    ['ammo_pistol_pd'] = {
        rewards = { ['ammo-justicep'] = 50 },
        notifyPhrase = 'your 9mm Justice box',
        job = 'police',
        usetime = 3000,
    },
}
```

### Other Config Options

| Option | Default | Description |
|--------|---------|-------------|
| `Config.Framework` | `'qbox'` | `qbox \| qb-core \| esx \| custom` |
| `Config.Inventory` | `'ox'` | `ox \| qb \| ps \| codem \| origen \| tgiann \| custom` |
| `Config.Notification` | `'ox'` | `ox \| qb \| esx \| chat` |
| `Config.AtomicUnpack` | `true` | Rollback all rewards on partial failure. |
| `Config.Language` | `'en'` | Locale file to load from `locale/`. |
| `Config.DefaultUsetime` | `2500` | Default progress duration (ms). |

## Locale System

Strings live in `locale/en.lua`. To add a language, create `locale/xx.lua` following the same format and set `Config.Language = 'xx'`. The `L()` function falls back to English for missing keys.

## Security Model

- Client usage does not decide rewards, amounts, or success/failure.
- Box definitions, reward amounts, and random rolls are server-only.
- Job restrictions are validated server-side via `GetPlayerJob`.
- Inventory operations are guarded with rollback on failure.
- Unpack flow checks: player source, box existence, job access, carry capacity, item removal.
- Atomic mode prevents partial exploit outcomes.
- Active unpack tracking prevents concurrent use abuse.
- Random reward amounts are cached between ox_inventory `usingItem`/`usedItem` events to prevent carry-check bypass.

## Troubleshooting

- **Missing item warnings** -- add those item names to your `ox_inventory` items data.
- **Box does nothing on use** -- verify `Config.Framework`, `Config.Inventory`, and that dependencies start before this resource.
- **Job restriction not working** -- confirm the job name string matches your framework's job name exactly.
- **No progress bar (non-ox)** -- the client animation fires automatically; ensure `Config.DefaultUsetime` or per-box `usetime` is above 0.
- **No notifications** -- switch `Config.Notification` to a provider your server runs.
