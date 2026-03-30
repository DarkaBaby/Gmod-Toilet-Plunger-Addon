if SERVER then
    AddCSLuaFile()
end

ToiletPlunger = ToiletPlunger or {}
ToiletPlunger.Config = ToiletPlunger.Config or {}

ToiletPlunger.Config.DataDir = ToiletPlunger.Config.DataDir or "toilet_plunger"

ToiletPlunger.Config.Spawning = ToiletPlunger.Config.Spawning or {}
ToiletPlunger.Config.Spawning.SpawnInterval = ToiletPlunger.Config.Spawning.SpawnInterval or 45
ToiletPlunger.Config.Spawning.MaxActiveSpots = ToiletPlunger.Config.Spawning.MaxActiveSpots or 4
ToiletPlunger.Config.Spawning.InitialSpawnCount = ToiletPlunger.Config.Spawning.InitialSpawnCount or 2
ToiletPlunger.Config.Spawning.InitialSpawnDelay = ToiletPlunger.Config.Spawning.InitialSpawnDelay or 10
ToiletPlunger.Config.Spawning.AutoSpawnEnabled = ToiletPlunger.Config.Spawning.AutoSpawnEnabled ~= false

ToiletPlunger.Config.Spot = ToiletPlunger.Config.Spot or {}
ToiletPlunger.Config.Spot.DefaultOffset = ToiletPlunger.Config.Spot.DefaultOffset or Vector(0, 0, 18)
ToiletPlunger.Config.Spot.TraceRange = ToiletPlunger.Config.Spot.TraceRange or 90
ToiletPlunger.Config.Spot.TraceRadius = ToiletPlunger.Config.Spot.TraceRadius or 24

ToiletPlunger.Config.BlockedProp = ToiletPlunger.Config.BlockedProp or {}
ToiletPlunger.Config.BlockedProp.Enabled = ToiletPlunger.Config.BlockedProp.Enabled ~= false
ToiletPlunger.Config.BlockedProp.Model = ToiletPlunger.Config.BlockedProp.Model or "models/props_junk/Shoe001a.mdl"
ToiletPlunger.Config.BlockedProp.LocalPos = ToiletPlunger.Config.BlockedProp.LocalPos or Vector(0, 0, 0)
ToiletPlunger.Config.BlockedProp.LocalAng = ToiletPlunger.Config.BlockedProp.LocalAng or Angle(0, 0, 0)
ToiletPlunger.Config.BlockedProp.ModelScale = ToiletPlunger.Config.BlockedProp.ModelScale or 1
ToiletPlunger.Config.BlockedProp.Solid = ToiletPlunger.Config.BlockedProp.Solid or SOLID_NONE

ToiletPlunger.Config.Marker = ToiletPlunger.Config.Marker or {}
ToiletPlunger.Config.Marker.MaxDrawDistance = ToiletPlunger.Config.Marker.MaxDrawDistance or 3000
ToiletPlunger.Config.Marker.WorldOffset = ToiletPlunger.Config.Marker.WorldOffset or Vector(0, 0, 24)
ToiletPlunger.Config.Marker.MinSize = ToiletPlunger.Config.Marker.MinSize or 10
ToiletPlunger.Config.Marker.MaxSize = ToiletPlunger.Config.Marker.MaxSize or 20
ToiletPlunger.Config.Marker.SizeDivisor = ToiletPlunger.Config.Marker.SizeDivisor or 9000
ToiletPlunger.Config.Marker.Alpha = ToiletPlunger.Config.Marker.Alpha or 150

ToiletPlunger.Config.Weapon = ToiletPlunger.Config.Weapon or {}
ToiletPlunger.Config.Weapon.HoldType = ToiletPlunger.Config.Weapon.HoldType or "normal"
ToiletPlunger.Config.Weapon.ViewModelFOV = ToiletPlunger.Config.Weapon.ViewModelFOV or 70
ToiletPlunger.Config.Weapon.ViewModelFlip = ToiletPlunger.Config.Weapon.ViewModelFlip or false
ToiletPlunger.Config.Weapon.UseHands = ToiletPlunger.Config.Weapon.UseHands or false
ToiletPlunger.Config.Weapon.ViewModel = ToiletPlunger.Config.Weapon.ViewModel or "models/weapons/c_toilet_plunger.mdl"
ToiletPlunger.Config.Weapon.WorldModel = ToiletPlunger.Config.Weapon.WorldModel or "models/weapons/w_toilet_plunger.mdl"
ToiletPlunger.Config.Weapon.PlungeCycleTime = ToiletPlunger.Config.Weapon.PlungeCycleTime or 0.78
ToiletPlunger.Config.Weapon.PlungeDepth = ToiletPlunger.Config.Weapon.PlungeDepth or 7
ToiletPlunger.Config.Weapon.PlungeDrop = ToiletPlunger.Config.Weapon.PlungeDrop or 4
ToiletPlunger.Config.Weapon.PlungePitch = ToiletPlunger.Config.Weapon.PlungePitch or 6
ToiletPlunger.Config.Weapon.SoundInterval = ToiletPlunger.Config.Weapon.SoundInterval or 0.72
ToiletPlunger.Config.Weapon.HitCheckPoint = ToiletPlunger.Config.Weapon.HitCheckPoint or 0.62
ToiletPlunger.Config.Weapon.PlungeHoldDelay = ToiletPlunger.Config.Weapon.PlungeHoldDelay or 0.14
ToiletPlunger.Config.Weapon.ViewModelBoneMods = ToiletPlunger.Config.Weapon.ViewModelBoneMods or {
    ["ValveBiped.Bip01_R_Hand"] = {scale = Vector(1, 1, 1), pos = Vector(5.369, 0, 0), angle = Angle(-92.223, -18.889, 5.556)},
    ["ValveBiped.Bip01_R_Clavicle"] = {scale = Vector(1, 1, 1), pos = Vector(-0.186, 0, 0), angle = Angle(0, 0, 0)},
    ["ValveBiped.Bip01_R_Forearm"] = {scale = Vector(1, 1, 1), pos = Vector(-5.37, -0.186, -0.926), angle = Angle(0, -3.333, 0)},
    ["ValveBiped.Bip01"] = {scale = Vector(1, 1, 1), pos = Vector(5, 0, 0), angle = Angle(0, 0, 0)}
}
