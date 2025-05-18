if CLIENT then return end

local DoorBar_Enable = CreateConVar("door_barricading_enable", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable/disable barricading of doors with objects")
local DoorBar_PushForce = CreateConVar("door_barricading_forcepower", "5", FCVAR_ARCHIVE, "The force of pushing objects away from a door")
local DoorBar_Distance = CreateConVar("door_barricading_distance", "30", FCVAR_ARCHIVE, "The distance at which the barricades will be located")
local DoorBar_LockDoor = CreateConVar("door_barricading_lockdoor", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Turns off animation (Works better on double doors)")

local IsValid = IsValid
local util_TraceLine = util.TraceLine
local IN_USE = IN_USE
local timer_Simple = timer.Simple

hook.Add( "PlayerUse", "DoorBar_PlayerOpenDoor", function( ply, ent )
	if ( !IsValid( ent ) ) then return end
    if DoorBar_Enable:GetBool() then
	
        local eyetrace = ply:GetEyeTrace()

        local trent = eyetrace.Entity

        local doorclass = "prop_door_rotating"
        local getclass = ent:GetClass()
        if getclass == doorclass and trent != ent then return false end --Когда игрок смотрит в сторону двери то дверь открывается без проверки, фиксим быстра

        if (IsValid(trent) and trent:GetClass() == doorclass) then
            local door_state = trent:GetInternalVariable( "m_eDoorState" ) ~= 0
            local door_locked = trent:GetInternalVariable( "m_bLocked" ) ~= 0
            if !door_locked then return end
            if door_state then return true end

            local HitPos = eyetrace.HitPos
            local HitNormal = eyetrace.HitNormal
            local convardist = DoorBar_Distance:GetInt()
            
            local trentpos = trent:GetPos()

            local obb_maxs = trent:OBBMaxs()

            local doorpos = trentpos-trent:GetRight()*(obb_maxs.x * 7)-trent:GetUp()*(obb_maxs.z*0.5)
            local idealpos = doorpos + HitNormal * -0.1
            local idealpos2 = doorpos + HitNormal * -convardist

            local doortr = util_TraceLine({
                start = idealpos,
                endpos = idealpos2,
                filter = trent
            })

            local doortrhit = doortr.HitPos

            local idealX = idealpos.x
            local idealY = idealpos.y
            local idealZ = idealpos.z

            local ideal2X = doortrhit.x
            local ideal2Y = doortrhit.y
            local ideal2Z = doortrhit.z

            local min = Vector(math.min(idealX, ideal2X), math.min(idealX, ideal2Y), math.min(idealX, ideal2Z))
            local max = Vector(math.max(idealX, ideal2X), math.max(idealX, ideal2Y), math.max(idealX, ideal2Z))

            if trent.DoorBlocked then return false end

            local barricade_ent
            local findedents = ents.FindInBox(min,max)
            for i, ent in ipairs(findedents) do
                if ent == ply then return end
                if ent:GetClass() == trent:GetClass() then return end
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) and phys:GetMass() > 1 then
                    local model = ent:GetModel()
                    if util.IsValidModel(model) and trentpos:Distance(ent:GetPos()) < convardist*2 then
                        barricade_ent = ent
                        break
                    end
                end
            end

            if IsValid(barricade_ent) and !trent.DoorBlocked and barricade_ent:GetClass() != getclass then

                local pushpower = DoorBar_PushForce:GetInt()
                if pushpower > 0 then
                    local physbarricade = barricade_ent:GetPhysicsObject()
                    physbarricade:SetVelocity(- ( trentpos - barricade_ent:GetPos() ) * pushpower * 10 / physbarricade:GetMass())
                end

                if DoorBar_LockDoor:GetBool() then
                    trent.DoorBlocked = true
                    trent:EmitSound("doors/default_locked.wav")
                    trent:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
                    timer_Simple(0.5, function() if IsValid(trent) then trent.DoorBlocked = false end end)
                    return false
                else
                    trent.DoorBlocked = true
                    trent.LastDoorSpeed = trent:GetKeyValues()["speed"]
                    trent:SetKeyValue("speed",25)

                    trent:Fire("Open",1,0,ply)
                    --как оказалось, замена таймерам
                    trent:Fire("Close",1,0.3,ply)
                    timer_Simple(1, function() if IsValid(trent) then trent.DoorBlocked = false trent:SetKeyValue("speed",trent.LastDoorSpeed) end end)
                    timer_Simple(0.2, function() if IsValid(trent) then trent:EmitSound("physics/wood/wood_crate_impact_hard2.wav") end end)
                end
            end
        end
    end
end )