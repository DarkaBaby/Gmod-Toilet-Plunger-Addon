if SERVER then
    AddCSLuaFile()
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "Plunger"
SWEP.Author = "bruhlord"
SWEP.Instructions = "Hold primary fire to plunge blocked toilets."
SWEP.Category = "Fun"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.HoldType = ToiletPlunger.Config.Weapon.HoldType
SWEP.ViewModelFOV = ToiletPlunger.Config.Weapon.ViewModelFOV
SWEP.ViewModelFlip = ToiletPlunger.Config.Weapon.ViewModelFlip
SWEP.UseHands = ToiletPlunger.Config.Weapon.UseHands
SWEP.ViewModel = ToiletPlunger.Config.Weapon.ViewModel
SWEP.WorldModel = ToiletPlunger.Config.Weapon.WorldModel
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Slot = 1
SWEP.SlotPos = 5

SWEP.ViewModelBoneMods = ToiletPlunger.Config.Weapon.ViewModelBoneMods

SWEP.PlungeCycleTime = ToiletPlunger.Config.Weapon.PlungeCycleTime
SWEP.PlungeDepth = ToiletPlunger.Config.Weapon.PlungeDepth
SWEP.PlungeDrop = ToiletPlunger.Config.Weapon.PlungeDrop
SWEP.PlungePitch = ToiletPlunger.Config.Weapon.PlungePitch
SWEP.SoundInterval = ToiletPlunger.Config.Weapon.SoundInterval
SWEP.HitCheckPoint = ToiletPlunger.Config.Weapon.HitCheckPoint
SWEP.PlungeHoldDelay = ToiletPlunger.Config.Weapon.PlungeHoldDelay

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Plunging")
    self:NetworkVar("Float", 0, "PlungeStartTime")
    self:NetworkVar("Float", 1, "NextPlungeSound")
    self:NetworkVar("Int", 0, "LastHitCycle")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.PendingPlungeStart = 0

    if CLIENT then
        self:ResetBonePositions()
    else
        self:SetPlunging(false)
        self:SetPlungeStartTime(0)
        self:SetNextPlungeSound(0)
        self:SetLastHitCycle(-1)
    end
end

function SWEP:Deploy()
    self:SetHoldType(self.HoldType)
    self:SendWeaponAnim(ACT_VM_DRAW)
    self.PendingPlungeStart = 0

    if SERVER then
        self:SetPlunging(false)
        self:SetLastHitCycle(-1)
    end

    if CLIENT then
        self:ApplyViewModelBoneMods()
    end

    return true
end

function SWEP:Holster()
    if SERVER then
        self:StopPlunging()
    end

    if CLIENT then
        self:ResetBonePositions()
    end

    return true
end

function SWEP:OnRemove()
    if SERVER then
        self:SetPlunging(false)
    end

    if CLIENT then
        self:ResetBonePositions()
    end
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER and not self:GetPlunging() and self.PendingPlungeStart == 0 then
        self.PendingPlungeStart = CurTime() + self.PlungeHoldDelay
    end

    self:SetNextPrimaryFire(CurTime() + 0.02)
end

function SWEP:SecondaryAttack()
end

function SWEP:StopPlunging()
    self.PendingPlungeStart = 0
    if not self:GetPlunging() then return end

    self:SetPlunging(false)
    self:SetLastHitCycle(-1)

    local owner = self:GetOwner()
    if IsValid(owner) and owner:GetActiveWeapon() == self then
        self:SendWeaponAnim(ACT_VM_IDLE)
    end
end

function SWEP:StartPlunging()
    local owner = self:GetOwner()
    if not IsValid(owner) or self:GetPlunging() then return end

    self:SetPlunging(true)
    self:SetPlungeStartTime(CurTime())
    self:SetNextPlungeSound(0)
    self:SetLastHitCycle(-1)
    self.PendingPlungeStart = 0
    self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:DoPlungeHit()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER and ToiletPlunger and ToiletPlunger.TryPlunge then
        local success = ToiletPlunger.TryPlunge(owner)
        if success then
            self:EmitSound("ambient/water/water_splash1.wav", 70, 100, 0.75, CHAN_WEAPON)
        end
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if CLIENT then
        self:ApplyViewModelBoneMods()
        return
    end

    if owner:GetActiveWeapon() ~= self or not owner:KeyDown(IN_ATTACK) then
        self:StopPlunging()
        return
    end

    if not self:GetPlunging() and self.PendingPlungeStart > 0 and CurTime() >= self.PendingPlungeStart then
        self:StartPlunging()
    end

    if not self:GetPlunging() then return end

    local elapsed = CurTime() - self:GetPlungeStartTime()
    local cycle = math.floor(elapsed / self.PlungeCycleTime)
    local frac = (elapsed % self.PlungeCycleTime) / self.PlungeCycleTime

    if CurTime() >= self:GetNextPlungeSound() then
        local snd = table.Random({
            "ambient/water/water_splash1.wav",
            "ambient/water/water_splash2.wav",
            "ambient/water/water_splash3.wav"
        })

        self:EmitSound(snd, 68, math.random(92, 104), 0.55, CHAN_WEAPON)
        self:SetNextPlungeSound(CurTime() + self.SoundInterval)
    end

    if frac >= self.HitCheckPoint and self:GetLastHitCycle() ~= cycle then
        self:SetLastHitCycle(cycle)
        owner:SetAnimation(PLAYER_ATTACK1)
        self:DoPlungeHit()
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    if not self:GetPlunging() then
        return pos, ang
    end

    local elapsed = CurTime() - self:GetPlungeStartTime()
    local frac = (elapsed % self.PlungeCycleTime) / self.PlungeCycleTime
    local wave = math.sin(frac * math.pi)

    local forward = ang:Forward()
    local right = ang:Right()
    local up = ang:Up()

    pos = pos - up * (wave * self.PlungeDrop)
    pos = pos + forward * (wave * self.PlungeDepth)
    pos = pos - right * (wave * 0.8)

    ang:RotateAroundAxis(right, wave * self.PlungePitch)
    ang:RotateAroundAxis(up, wave * 1.5)

    return pos, ang
end

if CLIENT then
    function SWEP:ViewModelDrawn()
        self:ApplyViewModelBoneMods()
    end

    function SWEP:ApplyViewModelBoneMods()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local vm = owner:GetViewModel()
        if not IsValid(vm) then return end

        for boneName, mod in pairs(self.ViewModelBoneMods or {}) do
            local bone = vm:LookupBone(boneName)
            if not bone then continue end

            vm:ManipulateBoneScale(bone, mod.scale)
            vm:ManipulateBoneAngles(bone, mod.angle)
            vm:ManipulateBonePosition(bone, mod.pos)
        end
    end

    function SWEP:ResetBonePositions()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local vm = owner:GetViewModel()
        if not IsValid(vm) then return end

        for i = 0, vm:GetBoneCount() - 1 do
            vm:ManipulateBoneScale(i, Vector(1, 1, 1))
            vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
            vm:ManipulateBonePosition(i, Vector(0, 0, 0))
        end
    end
end
