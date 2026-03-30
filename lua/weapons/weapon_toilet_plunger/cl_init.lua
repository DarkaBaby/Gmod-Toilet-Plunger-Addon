include("shared.lua")

local iconMat = Material("toilet_plunger/plunger_icon.png", "smooth mips")

local function GetNearestActiveSpot()
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end

    local bestSpot
    local bestDist = math.huge

    for _, spot in ipairs(ents.FindByClass("sent_toilet_plunge_spot")) do
        if not IsValid(spot) then continue end

        local dist = ply:GetPos():DistToSqr(spot:GetWorldSpotPos())
        if dist < bestDist then
            bestDist = dist
            bestSpot = spot
        end
    end

    return bestSpot
end

hook.Add("PostDrawTranslucentRenderables", "ToiletPlunger_DrawTargetMarker", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "weapon_toilet_plunger" then return end

    local spot = GetNearestActiveSpot()
    if not IsValid(spot) then return end

    local pos = spot:GetWorldSpotPos() + ToiletPlunger.Config.Marker.WorldOffset
    local dist = ply:GetPos():Distance(pos)
    if dist > ToiletPlunger.Config.Marker.MaxDrawDistance then return end

    local size = math.Clamp(ToiletPlunger.Config.Marker.SizeDivisor / math.max(dist, 1), ToiletPlunger.Config.Marker.MinSize, ToiletPlunger.Config.Marker.MaxSize)
    render.OverrideDepthEnable(true, false)
    render.SetMaterial(iconMat)
    render.DrawSprite(pos + Vector(0, 0, 6), size, size, Color(255, 255, 255, ToiletPlunger.Config.Marker.Alpha))
    render.OverrideDepthEnable(false, false)
end)

net.Receive("ToiletPlunger_SpotCleared", function()
    local pos = net.ReadVector()
    local emitter = ParticleEmitter(pos)

    if emitter then
        for _ = 1, 10 do
            local p = emitter:Add("particle/particle_smokegrenade", pos)
            if p then
                p:SetVelocity(VectorRand() * 18 + Vector(0, 0, 25))
                p:SetDieTime(math.Rand(0.4, 0.9))
                p:SetStartAlpha(120)
                p:SetEndAlpha(0)
                p:SetStartSize(4)
                p:SetEndSize(14)
                p:SetRoll(math.Rand(0, 360))
            end
        end

        emitter:Finish()
    end

    surface.PlaySound("ambient/water/drip2.wav")
end)
