# Plunger Addon

A Garry's Mod SWEP addon for blocked-toilet objectives with configurable spawn logic, marker rendering, and blocked props.

## Features

- Hold `Mouse1` to plunge instead of using a tap-to-swing melee attack.
- Random blocked-toilet spots can spawn on saved map markers.
- Each active spot can display a stuck prop that disappears when the toilet is cleared.
- Clients see a plunger icon marker for the nearest active plunge target, including through walls.
- Server-side API and hooks make it easier to integrate into gamemodes and job systems.

## Addon Layout

This addon should be packed with these top-level folders:

```text
plunger-addon/
  lua/
  models/
  materials/
  README.md
```

Relevant files:

- `lua/autorun/toilet_plunger_config.lua`
- `lua/autorun/server/sv_toilet_plunger.lua`
- `lua/autorun/server/toilet_plunger/sv_toilet_plunger_core.lua`
- `lua/autorun/server/toilet_plunger/sv_toilet_plunger_commands.lua`
- `lua/entities/sent_toilet_plunge_spot/shared.lua`
- `lua/weapons/weapon_toilet_plunger/shared.lua`
- `lua/weapons/weapon_toilet_plunger/init.lua`
- `lua/weapons/weapon_toilet_plunger/cl_init.lua`

The SWEP uses these renamed model files:

- `models/weapons/c_toilet_plunger.mdl`
- `models/weapons/w_toilet_plunger.mdl`

## Installation

1. Put the addon folder in `garrysmod/addons/`.
2. Make sure the addon root contains `lua/`, `models/`, and `materials/`.
3. Start or restart Garry's Mod.

## Basic Usage

Give yourself the weapon:

```text
give weapon_toilet_plunger
```

Mark a toilet while looking at it as admin:

```text
toilet_plunger_add_toilet
```

Force a blocked-toilet objective to spawn:

```text
toilet_plunger_spawn_spot
```

Remove the nearest saved marker:

```text
toilet_plunger_remove_nearest_toilet
```

Clear all saved markers for the current map:

```text
toilet_plunger_clear_toilets
```

Start the automatic spawner with an optional interval in seconds:

```text
toilet_plunger_start_spawner
toilet_plunger_start_spawner 120
```

Stop the automatic spawner:

```text
toilet_plunger_stop_spawner
```

## Config

Main config values live in:

- `lua/autorun/toilet_plunger_config.lua`

Main config sections:

- `ToiletPlunger.Config.Spawning`
- `ToiletPlunger.Config.Spot`
- `ToiletPlunger.Config.BlockedProp`
- `ToiletPlunger.Config.Marker`
- `ToiletPlunger.Config.Weapon`

Important values:

- `ToiletPlunger.Config.Spawning.SpawnInterval`
- `ToiletPlunger.Config.Spawning.MaxActiveSpots`
- `ToiletPlunger.Config.Spawning.InitialSpawnCount`
- `ToiletPlunger.Config.Spawning.InitialSpawnDelay`
- `ToiletPlunger.Config.Spawning.AutoSpawnEnabled`
- `ToiletPlunger.Config.Spot.DefaultOffset`
- `ToiletPlunger.Config.Spot.TraceRange`
- `ToiletPlunger.Config.Spot.TraceRadius`
- `ToiletPlunger.Config.BlockedProp.Enabled`
- `ToiletPlunger.Config.BlockedProp.Model`
- `ToiletPlunger.Config.BlockedProp.LocalPos`
- `ToiletPlunger.Config.BlockedProp.LocalAng`
- `ToiletPlunger.Config.BlockedProp.ModelScale`
- `ToiletPlunger.Config.Marker.MaxDrawDistance`
- `ToiletPlunger.Config.Marker.WorldOffset`
- `ToiletPlunger.Config.Marker.MinSize`
- `ToiletPlunger.Config.Marker.MaxSize`
- `ToiletPlunger.Config.Marker.SizeDivisor`
- `ToiletPlunger.Config.Marker.Alpha`
- `ToiletPlunger.Config.Weapon.HoldType`
- `ToiletPlunger.Config.Weapon.ViewModel`
- `ToiletPlunger.Config.Weapon.WorldModel`
- `ToiletPlunger.Config.Weapon.ViewModelBoneMods`

Default blocked prop:

```lua
ToiletPlunger.Config.BlockedProp.Model = "models/props_junk/Shoe001a.mdl"
```

## Server API

The addon exposes a global `ToiletPlunger` table on the server.

Useful functions:

- `ToiletPlunger.AddMarker(ent, worldPos, shouldSave)`
- `ToiletPlunger.RemoveMarker(index, shouldSave)`
- `ToiletPlunger.RemoveNearestMarker(pos, shouldSave)`
- `ToiletPlunger.ClearMarkers(shouldSave)`
- `ToiletPlunger.SaveMarkers()`
- `ToiletPlunger.LoadMarkers()`
- `ToiletPlunger.SpawnSpotOnMarker(marker)`
- `ToiletPlunger.SpawnRandomSpot()`
- `ToiletPlunger.SpawnInitialSpots(count)`
- `ToiletPlunger.StartAutoSpawner(interval)`
- `ToiletPlunger.StopAutoSpawner()`
- `ToiletPlunger.RestartAutoSpawner(interval)`
- `ToiletPlunger.TryPlunge(ply)`
- `ToiletPlunger.CompletePlunge(ply, spot)`
- `ToiletPlunger.GetActiveSpots()`

Example:

```lua
hook.Add("InitPostEntity", "MyCustomPlungerSetup", function()
    ToiletPlunger.Config.Spawning.SpawnInterval = 120
    ToiletPlunger.RestartAutoSpawner(120)
end)
```

## Hooks

Available server hooks:

- `ToiletPlungerPlungeSuccess`
- `ToiletPlungerPlungeFailed`
- `ToiletPlungerSpotCleared`
- `ToiletPlungerSpotSpawned`
- `ToiletPlungerMarkerAdded`
- `ToiletPlungerMarkerRemoved`
- `ToiletPlungerMarkersLoaded`
- `ToiletPlungerMarkersSaved`
- `ToiletPlungerMarkersCleared`
- `ToiletPlungerAutoSpawnTick`
- `ToiletPlungerAutoSpawnerStarted`
- `ToiletPlungerAutoSpawnerStopped`

Example:

```lua
hook.Add("ToiletPlungerPlungeSuccess", "MyServerReward", function(ply, toilet, pos, spot)
    if not IsValid(ply) then return end

    print(ply:Nick() .. " cleared a blocked toilet")
end)
```

## Blocked Prop Behavior

Each active spot can spawn a visual prop that appears stuck in the toilet.

Current default:

- `models/props_junk/Shoe001a.mdl`

This is attached by the spot entity and removed automatically when the plunge spot is cleared.

Tuning values:

- `ToiletPlunger.Config.BlockedProp.Enabled`
- `ToiletPlunger.Config.BlockedProp.Model`
- `ToiletPlunger.Config.BlockedProp.LocalPos`
- `ToiletPlunger.Config.BlockedProp.LocalAng`
- `ToiletPlunger.Config.BlockedProp.ModelScale`

## Marker Icon

The world marker uses:

- `materials/toilet_plunger/plunger_icon.png`

Marker size, offset, alpha, and draw distance are configurable in `ToiletPlunger.Config.Marker`.

## Notes

- The current first-person setup is a bone-modified custom pose on the viewmodel.
- A true two-hand custom animation would likely require a proper custom viewmodel and recompiled assets rather than more bone tweaking.