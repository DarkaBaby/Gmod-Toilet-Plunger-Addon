if CLIENT then return end

util.AddNetworkString("ToiletPlunger_SpotCleared")

ToiletPlunger = ToiletPlunger or {}
ToiletPlunger.Config = ToiletPlunger.Config or {}
ToiletPlunger.Markers = ToiletPlunger.Markers or {}
ToiletPlunger.ActiveSpots = ToiletPlunger.ActiveSpots or {}
ToiletPlunger.TimerName = "ToiletPlunger_AutoSpawner"

function ToiletPlunger.GetMapFileName()
    return ToiletPlunger.Config.DataDir .. "/" .. game.GetMap() .. ".json"
end

function ToiletPlunger.EnsureDataDir()
    if not file.Exists(ToiletPlunger.Config.DataDir, "DATA") then
        file.CreateDir(ToiletPlunger.Config.DataDir)
    end
end

function ToiletPlunger.SaveMarkers()
    ToiletPlunger.EnsureDataDir()

    local data = {}
    for _, marker in ipairs(ToiletPlunger.Markers) do
        data[#data + 1] = {
            class = marker.class,
            pos = {x = marker.pos.x, y = marker.pos.y, z = marker.pos.z},
            offset = {x = marker.offset.x, y = marker.offset.y, z = marker.offset.z}
        }
    end

    file.Write(ToiletPlunger.GetMapFileName(), util.TableToJSON(data, true))
    hook.Run("ToiletPlungerMarkersSaved", data)
end

function ToiletPlunger.LoadMarkers()
    ToiletPlunger.Markers = {}

    if not file.Exists(ToiletPlunger.GetMapFileName(), "DATA") then return end

    local raw = file.Read(ToiletPlunger.GetMapFileName(), "DATA")
    if not raw or raw == "" then return end

    local data = util.JSONToTable(raw)
    if not istable(data) then return end

    for _, marker in ipairs(data) do
        if marker.class and marker.pos and marker.offset then
            ToiletPlunger.Markers[#ToiletPlunger.Markers + 1] = {
                class = marker.class,
                pos = Vector(marker.pos.x, marker.pos.y, marker.pos.z),
                offset = Vector(marker.offset.x, marker.offset.y, marker.offset.z)
            }
        end
    end

    hook.Run("ToiletPlungerMarkersLoaded", table.Copy(ToiletPlunger.Markers))
end

function ToiletPlunger.CleanupActiveSpots()
    for i = #ToiletPlunger.ActiveSpots, 1, -1 do
        if not IsValid(ToiletPlunger.ActiveSpots[i]) then
            table.remove(ToiletPlunger.ActiveSpots, i)
        end
    end
end

function ToiletPlunger.GetActiveSpots()
    ToiletPlunger.CleanupActiveSpots()
    return table.Copy(ToiletPlunger.ActiveSpots)
end

function ToiletPlunger.FindNearestEntityByClass(className, pos, maxDist)
    local bestEnt
    local bestDistSqr = maxDist * maxDist

    for _, ent in ipairs(ents.FindByClass(className)) do
        if not IsValid(ent) then continue end

        local dist = ent:GetPos():DistToSqr(pos)
        if dist <= bestDistSqr then
            bestEnt = ent
            bestDistSqr = dist
        end
    end

    return bestEnt
end

function ToiletPlunger.HasSpotOnToilet(ent)
    for _, spot in ipairs(ToiletPlunger.ActiveSpots) do
        if IsValid(spot) and spot:GetToiletEnt() == ent then
            return true
        end
    end

    return false
end

function ToiletPlunger.AddMarker(ent, worldPos, shouldSave)
    if not IsValid(ent) or not worldPos then return nil end

    local marker = {
        class = ent:GetClass(),
        pos = ent:GetPos(),
        offset = ent:WorldToLocal(worldPos)
    }

    ToiletPlunger.Markers[#ToiletPlunger.Markers + 1] = marker

    if shouldSave ~= false then
        ToiletPlunger.SaveMarkers()
    end

    hook.Run("ToiletPlungerMarkerAdded", marker, ent)
    return marker, #ToiletPlunger.Markers
end

function ToiletPlunger.RemoveMarker(index, shouldSave)
    local marker = ToiletPlunger.Markers[index]
    if not marker then return false end

    table.remove(ToiletPlunger.Markers, index)

    if shouldSave ~= false then
        ToiletPlunger.SaveMarkers()
    end

    hook.Run("ToiletPlungerMarkerRemoved", marker, index)
    return true
end

function ToiletPlunger.RemoveNearestMarker(pos, shouldSave)
    if #ToiletPlunger.Markers <= 0 then return false end

    local bestIndex
    local bestDist = math.huge

    for i, marker in ipairs(ToiletPlunger.Markers) do
        local dist = pos:DistToSqr(marker.pos)
        if dist < bestDist then
            bestDist = dist
            bestIndex = i
        end
    end

    if not bestIndex then return false end
    return ToiletPlunger.RemoveMarker(bestIndex, shouldSave), bestIndex
end

function ToiletPlunger.ClearMarkers(shouldSave)
    ToiletPlunger.Markers = {}

    if shouldSave ~= false then
        ToiletPlunger.SaveMarkers()
    end

    hook.Run("ToiletPlungerMarkersCleared")
end

function ToiletPlunger.SpawnSpotOnMarker(marker)
    if not marker then return nil end

    local toilet = ToiletPlunger.FindNearestEntityByClass(marker.class, marker.pos, 160)
    if not IsValid(toilet) or ToiletPlunger.HasSpotOnToilet(toilet) then return nil end

    local spot = ents.Create("sent_toilet_plunge_spot")
    if not IsValid(spot) then return nil end

    spot:Spawn()
    spot:SetSpotParent(toilet, marker.offset or ToiletPlunger.Config.Spot.DefaultOffset)
    spot:AttachBlockedProp()

    ToiletPlunger.ActiveSpots[#ToiletPlunger.ActiveSpots + 1] = spot
    hook.Run("ToiletPlungerSpotSpawned", spot, toilet, marker)

    return spot
end

function ToiletPlunger.SpawnRandomSpot()
    ToiletPlunger.CleanupActiveSpots()

    if #ToiletPlunger.Markers <= 0 then return nil end
    if #ToiletPlunger.ActiveSpots >= ToiletPlunger.Config.Spawning.MaxActiveSpots then return nil end

    local shuffled = table.Copy(ToiletPlunger.Markers)
    table.Shuffle(shuffled)

    for _, marker in ipairs(shuffled) do
        local spot = ToiletPlunger.SpawnSpotOnMarker(marker)
        if IsValid(spot) then
            return spot
        end
    end

    return nil
end

function ToiletPlunger.SpawnInitialSpots(count)
    local spawned = {}
    local wanted = math.min(count or ToiletPlunger.Config.Spawning.InitialSpawnCount, ToiletPlunger.Config.Spawning.MaxActiveSpots)

    for _ = 1, wanted do
        local spot = ToiletPlunger.SpawnRandomSpot()
        if not IsValid(spot) then break end
        spawned[#spawned + 1] = spot
    end

    return spawned
end

function ToiletPlunger.StartAutoSpawner(interval)
    local delay = interval or ToiletPlunger.Config.Spawning.SpawnInterval
    if delay <= 0 then return end

    timer.Remove(ToiletPlunger.TimerName)
    timer.Create(ToiletPlunger.TimerName, delay, 0, function()
        local spot = ToiletPlunger.SpawnRandomSpot()
        hook.Run("ToiletPlungerAutoSpawnTick", spot)
    end)

    hook.Run("ToiletPlungerAutoSpawnerStarted", delay)
end

function ToiletPlunger.StopAutoSpawner()
    if timer.Exists(ToiletPlunger.TimerName) then
        timer.Remove(ToiletPlunger.TimerName)
        hook.Run("ToiletPlungerAutoSpawnerStopped")
    end
end

function ToiletPlunger.RestartAutoSpawner(interval)
    ToiletPlunger.StopAutoSpawner()
    ToiletPlunger.StartAutoSpawner(interval)
end

function ToiletPlunger.CompletePlunge(ply, spot)
    if not IsValid(ply) or not IsValid(spot) then return false end

    local toilet = spot:GetToiletEnt()
    local pos = spot:GetWorldSpotPos()

    net.Start("ToiletPlunger_SpotCleared")
        net.WriteVector(pos)
    net.Broadcast()

    hook.Run("ToiletPlungerPlungeSuccess", ply, toilet, pos, spot)
    hook.Run("ToiletPlungerSpotCleared", ply, toilet, pos)

    spot:Remove()
    ToiletPlunger.CleanupActiveSpots()
    return true
end

function ToiletPlunger.TryPlunge(ply)
    if not IsValid(ply) then return false end

    local shootPos = ply:GetShootPos()
    local tr = ply:GetEyeTrace()
    local bestSpot
    local bestDist = math.huge

    for _, spot in ipairs(ents.FindByClass("sent_toilet_plunge_spot")) do
        if not IsValid(spot) then continue end

        local toilet = spot:GetToiletEnt()
        if not IsValid(toilet) then continue end

        local spotPos = spot:GetWorldSpotPos()
        local dist = shootPos:Distance(spotPos)
        if dist > ToiletPlunger.Config.Spot.TraceRange then continue end

        local lookingAtToilet = tr.Entity == toilet
        local nearSpot = tr.HitPos:Distance(spotPos) <= ToiletPlunger.Config.Spot.TraceRadius

        if (lookingAtToilet or nearSpot) and dist < bestDist then
            bestSpot = spot
            bestDist = dist
        end
    end

    if not IsValid(bestSpot) then
        hook.Run("ToiletPlungerPlungeFailed", ply, tr)
        return false
    end

    return ToiletPlunger.CompletePlunge(ply, bestSpot)
end
