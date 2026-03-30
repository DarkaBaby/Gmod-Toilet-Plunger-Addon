if CLIENT then return end

local function Notify(ply, msg)
    if IsValid(ply) then
        ply:ChatPrint("[Toilet Plunger] " .. msg)
    else
        print("[Toilet Plunger] " .. msg)
    end
end

concommand.Add("toilet_plunger_add_toilet", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        Notify(ply, "Admin only.")
        return
    end

    local tr = IsValid(ply) and ply:GetEyeTrace() or nil
    if not tr or not IsValid(tr.Entity) then
        Notify(ply, "Look at a toilet prop/entity first.")
        return
    end

    local marker, index = ToiletPlunger.AddMarker(tr.Entity, tr.HitPos, true)
    if marker then
        Notify(ply, "Added toilet marker #" .. index .. " for class " .. tr.Entity:GetClass())
    end
end)

concommand.Add("toilet_plunger_remove_nearest_toilet", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        Notify(ply, "Admin only.")
        return
    end

    if #ToiletPlunger.Markers <= 0 then
        Notify(ply, "No saved toilet markers.")
        return
    end

    local pos = IsValid(ply) and ply:GetPos() or vector_origin
    local removed = ToiletPlunger.RemoveNearestMarker(pos, true)

    if removed then
        Notify(ply, "Removed nearest saved toilet marker.")
    end
end)

concommand.Add("toilet_plunger_clear_toilets", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        Notify(ply, "Super admin only.")
        return
    end

    ToiletPlunger.ClearMarkers(true)
    Notify(ply, "Cleared all saved toilet markers for this map.")
end)

concommand.Add("toilet_plunger_spawn_spot", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        Notify(ply, "Admin only.")
        return
    end

    local spot = ToiletPlunger.SpawnRandomSpot()
    if IsValid(spot) then
        Notify(ply, "Spawned a blocked toilet.")
    else
        Notify(ply, "Could not spawn a blocked toilet.")
    end
end)

concommand.Add("toilet_plunger_start_spawner", function(ply, _, args)
    if IsValid(ply) and not ply:IsAdmin() then
        Notify(ply, "Admin only.")
        return
    end

    local interval = tonumber(args[1]) or ToiletPlunger.Config.Spawning.SpawnInterval
    ToiletPlunger.Config.Spawning.SpawnInterval = interval
    ToiletPlunger.Config.Spawning.AutoSpawnEnabled = true
    ToiletPlunger.StartAutoSpawner(interval)
    Notify(ply, "Started auto spawner with interval " .. interval .. "s.")
end)

concommand.Add("toilet_plunger_stop_spawner", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then
        Notify(ply, "Admin only.")
        return
    end

    ToiletPlunger.Config.Spawning.AutoSpawnEnabled = false
    ToiletPlunger.StopAutoSpawner()
    Notify(ply, "Stopped auto spawner.")
end)

hook.Add("InitPostEntity", "ToiletPlunger_LoadAndStart", function()
    ToiletPlunger.LoadMarkers()
    ToiletPlunger.CleanupActiveSpots()

    if ToiletPlunger.Config.Spawning.AutoSpawnEnabled then
        ToiletPlunger.StartAutoSpawner(ToiletPlunger.Config.Spawning.SpawnInterval)
    end

    timer.Simple(ToiletPlunger.Config.Spawning.InitialSpawnDelay, function()
        ToiletPlunger.SpawnInitialSpots()
    end)
end)

hook.Add("PostCleanupMap", "ToiletPlunger_ReloadAfterCleanup", function()
    timer.Simple(1, function()
        ToiletPlunger.CleanupActiveSpots()
        ToiletPlunger.SpawnInitialSpots()
    end)
end)
