CreateConVar("doorbreach_enabled", 1, FCVAR_ARCHIVE, "Включает или выключает механику взлома дверей")
CreateConVar("doorbreach_health", 250, FCVAR_ARCHIVE, "Начальное здоровье двери")
CreateConVar("doorbreach_handlemultiplier", 1.5, FCVAR_ARCHIVE, "Множитель урона при попадании по ручке двери")
CreateConVar("doorbreach_respawntime", 0.5, FCVAR_ARCHIVE, "Время восстановления двери после взлома")
CreateConVar("doorbreach_speed", 350, FCVAR_ARCHIVE, "Скорость открытия двери")

local doorBreachEnabled = GetConVar("doorbreach_enabled")
local doorBreachHealth = GetConVar("doorbreach_health")
local doorBreachHandleMultiplier = GetConVar("doorbreach_handlemultiplier")
local doorBreachRespawnTime = GetConVar("doorbreach_respawntime")
local doorBreachSpeed = GetConVar("doorbreach_speed")

local maxHandleDistance = 5
local entityType = "prop_door_rotating"

hook.Add("EntityTakeDamage", "DoorBreachDamageDetection", function(ent, dmg)
    if not IsValid(ent) or not doorBreachEnabled:GetBool() then
        return
    end
    if ent:GetClass() ~= entityType then
        return
    end

    if not ent.DoorBreachHealth then
        ent.DoorBreachHealth = doorBreachHealth:GetFloat()
    end

    if ent.DoorBreachExploded then
        return
    end

    local attacker = dmg:GetAttacker()
    if attacker:IsPlayer() and attacker:GetActiveWeapon():GetClass() == "weapon_fists" then
        return
    end

    local dam = dmg:GetDamage()
    local damPos = dmg:GetDamagePosition()

    local bone = ent:LookupBone("handle")
    if bone then
        local handlePos = ent:GetBonePosition(bone)
        if handlePos:Distance(damPos) <= maxHandleDistance then
            dam = dam * doorBreachHandleMultiplier:GetFloat()
        end
    end

    ent.DoorBreachHealth = ent.DoorBreachHealth - dam

    if ent.DoorBreachHealth <= 0 then
        ent.DoorBreachExploded = true
        local defaultDoorSpeed = ent:GetInternalVariable("speed")
        ent:Fire("SetSpeed", doorBreachSpeed:GetString())
        ent:Fire("unlock", "", 0)
        ent:Fire("open", "", 0)
        timer.Simple(doorBreachRespawnTime:GetFloat(), function()
            if IsValid(ent) then
                ent.DoorBreachExploded = nil
                ent.DoorBreachHealth = doorBreachHealth:GetFloat()
                ent:Fire("SetSpeed", defaultDoorSpeed)
            end
        end)
    end
end)

hook.Add("PlayerUse", "DoorBreachSuppressUse", function(ply, ent)
    if IsValid(ent) and ent.DoorBreachExploded and ent:GetClass() == entityType then
        return false
    end
end)
