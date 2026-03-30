AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Toilet Plunge Spot"
ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "ToiletEnt")
    self:NetworkVar("Vector", 0, "LocalOffset")
    self:NetworkVar("Entity", 1, "BlockedProp")
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/plates/plate025x025.mdl")
        self:SetNoDraw(true)
        self:SetSolid(SOLID_NONE)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    end

    function ENT:SetSpotParent(ent, localOffset)
        if not IsValid(ent) then return end

        localOffset = localOffset or ToiletPlunger.Config.Spot.DefaultOffset

        self:SetParent(ent)
        self:SetPos(ent:LocalToWorld(localOffset))
        self:SetAngles(ent:GetAngles())
        self:SetToiletEnt(ent)
        self:SetLocalOffset(localOffset)
    end

    function ENT:AttachBlockedProp()
        local cfg = ToiletPlunger.Config.BlockedProp
        if not cfg or not cfg.Enabled then return end
        if not util.IsValidModel(cfg.Model) then return end

        local prop = ents.Create("prop_dynamic")
        if not IsValid(prop) then return end

        prop:SetModel(cfg.Model)
        prop:SetPos(self:GetWorldSpotPos())
        prop:SetAngles(self:GetAngles())
        prop:SetParent(self)
        prop:SetLocalPos(cfg.LocalPos)
        prop:SetLocalAngles(cfg.LocalAng)
        prop:SetModelScale(cfg.ModelScale, 0)
        prop:SetSolid(cfg.Solid)
        prop:SetMoveType(MOVETYPE_NONE)
        prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        prop:Spawn()
        prop:Activate()

        self:SetBlockedProp(prop)
    end

    function ENT:OnRemove()
        local prop = self:GetBlockedProp()
        if IsValid(prop) then
            prop:Remove()
        end
    end
end

function ENT:GetWorldSpotPos()
    local toilet = self:GetToiletEnt()
    if IsValid(toilet) then
        return toilet:LocalToWorld(self:GetLocalOffset())
    end

    return self:GetPos()
end
