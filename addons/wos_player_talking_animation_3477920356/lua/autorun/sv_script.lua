AddCSLuaFile()


local enableAnims = CreateConVar("enable_talking_animation", "1", FCVAR_ARCHIVE, "Enable or disable talking animation.")
local animCooldown = CreateConVar("talking_animation_cooldown", "2.5", FCVAR_ARCHIVE, "Change cooldown of animation(starts with the animation)")

local gender = "M"
local lastAnim = ""

-- убрать анимацию при стрельбе

local talkingAnimationM = {
    "Gesture01",
    "Gesture05",
    "Gesture05NP",
    "Gesture06",
    "Gesture06NP",
    "Gesture07",
    "Gesture13",
    "E_g_shrug",
    "G_medurgent_mid",
    "G_righthandroll",
    "G_righthandheavy",
    "g_palm_out_l",
    "g_palm_out_high_l"
}

local talkingAnimationWeaponsM = {
    "g_Rifle_Lhand",
    "g_Rifle_Lhand_low",
    "bg_accentUp",
    "bg_up_l",
    "bg_up_r",
    "g_palm_out_high_l",
    "g_palm_up_high_l"
}

local talkingAnimationW = {
    "A_gesture16",
    "M_g_sweepout",
    "A_g_midhigh_arcout",
    "A_g_midhigh_arcout_left",
    "A_g_midhigh_arcout_right",
    "A_g_rtl_dwnshp",
    "A_g_low2side_palmsout",
    "A_g_hflipout",
    "A_g_armscrossed",
    "A_g_rthdflipout",
    "A_g_mid_rtfingflareout",
    "A_g_mid_2hdcutdwn",
    "A_g_mid_2hdcutdwn_rt",
    "A_g_midrtarcdwnout",
    "A_g_rtsweepoutbig",
    "A_g_leftsweepoutbig",
    "A_g_mid_rtcutdwn"
}

local talkingAnimationWeaponsW = {
    "A_g_midhigh_arcout_left",
    "g_Rifle_Lhand",
    "g_Rifle_Lhand_low",
    "bg_accentUp",
    "bg_up_l",
    "bg_up_r"
}


local nonweapon = {
    "camera",
    "duel",
    "knife",
    "melee",
    "melee2",
    "physgun",
    "slam",
    "normal",
    "grenade",
    "fist"
}

local doingAnim = false
local lastAnim = ""

function fixtables()
    print("Fixed tables!")
    talkingAnimationWeaponsM = {
    "g_Rifle_Lhand",
    "g_Rifle_Lhand_low",
    "bg_accentUp",
    "bg_up_l",
    "bg_up_r",
    "g_palm_out_high_l",
    "g_palm_up_high_l"
    }

    talkingAnimationM = {
    "Gesture01",
    "Gesture05",
    "Gesture05NP",
    "Gesture06",
    "Gesture06NP",
    "Gesture07",
    "Gesture13",
    "E_g_shrug",
    "G_medurgent_mid",
    "G_righthandroll",
    "G_righthandheavy",
    "g_palm_out_l",
    "g_palm_out_high_l"
    }
    
    talkingAnimationW = {
        "A_gesture16",
        "M_g_sweepout",
        "A_g_midhigh_arcout",
        "A_g_midhigh_arcout_left",
        "A_g_midhigh_arcout_right",
        "A_g_rtl_dwnshp",
        "A_g_low2side_palmsout",
        "A_g_hflipout",
        "A_g_armscrossed",
        "A_g_rthdflipout",
        "A_g_mid_rtfingflareout",
        "A_g_mid_2hdcutdwn",
        "A_g_mid_2hdcutdwn_rt",
        "A_g_midrtarcdwnout",
        "A_g_rtsweepoutbig",
        "A_g_leftsweepoutbig",
        "A_g_mid_rtcutdwn"
    }

    talkingAnimationWeaponsW = {
        "A_g_midhigh_arcout_left",
        "g_Rifle_Lhand",
        "g_Rifle_Lhand_low",
        "bg_accentUp",
        "bg_up_l",
        "bg_up_r"
    }
end

if SERVER then
    

    util.AddNetworkString("TalkingAnimNet")

    function GetWeaponHoldAnim( ent)

        if( !IsValid( ent ) ) then return nil end

        local wephold = ent:GetActiveWeapon():GetHoldType()

        for i=0,#nonweapon do
            if wephold == nonweapon[i] then
                return true
            end
        end
    end

    net.Receive("TalkingStart", function(len,ply)
        local IsDeveloper = GetConVar("developer"):GetInt()
        local isTalking = net.ReadBool()
        local gender = net.ReadString()
        local enableWeaponAnims = net.ReadBool()
        local isDealingWithTables = false
        if(!IsValid(ply)) then return nil 
        elseif(!isTalking) then return nil end
            if isTalking and isDealingWithTables == false and enableAnims:GetBool() then
                local wephold = GetWeaponHoldAnim(ply)
                local animationToLookup = ""
                isDealingWithTables = true
                if wephold and gender == "M" then
                    animationToLookup = talkingAnimationM[math.random(#talkingAnimationM)]
                    if lastAnim == animationToLookup then
                        table.RemoveByValue(talkingAnimationM, lastAnim)
                        animationToLookup = talkingAnimationM[math.random(#talkingAnimationM)]
                        table.insert(talkingAnimationM, lastAnim)
                    end
                elseif wephold and gender == "W" then
                    animationToLookup = talkingAnimationW[math.random(#talkingAnimationW)]
                    if lastAnim == animationToLookup then
                        table.RemoveByValue(talkingAnimationW, lastAnim)
                        animationToLookup = talkingAnimationW[math.random(#talkingAnimationW)]
                        table.insert(talkingAnimationW, lastAnim)
                    end
                elseif gender == "M" and enableWeaponAnims then
                    animationToLookup = talkingAnimationWeaponsM[math.random(#talkingAnimationWeaponsM)]
                    if lastAnim == animationToLookup then
                        table.RemoveByValue(talkingAnimationWeaponsM, lastAnim)
                        animationToLookup = talkingAnimationWeaponsM[math.random(#talkingAnimationWeaponsM)]
                        table.insert(talkingAnimationWeaponsM, lastAnim)
                    end    
                elseif gender == "W" and enableWeaponAnims then
                    animationToLookup = talkingAnimationWeaponsW[math.random(#talkingAnimationWeaponsW)]
                    if lastAnim == animationToLookup then
                        table.RemoveByValue(talkingAnimationWeaponsW, lastAnim)
                        animationToLookup = talkingAnimationWeaponsW[math.random(#talkingAnimationWeaponsW)]
                        table.insert(talkingAnimationWeaponsW, lastAnim)
                    end
                end

                if animationToLookup == nil then
                    fixtables()
                    return
                end
                lookup = ply:LookupSequence(animationToLookup)
                isDealingWithTables = false
                if lookup == -1 then
                    if IsDeveloper > 0 then
                        print("Sequence not found!")
                        ply:ChatPrint(animationToLookup)
                        print(lookup)
                    end
                else
                    if IsDeveloper > 0 then
                        ply:ChatPrint(animationToLookup)
                        print(lookup)
                    end
                    net.Start("TalkingAnimNet")
                        net.WritePlayer(ply)
                        net.WriteUInt(lookup, 16)
                    net.Broadcast()
                    lastAnim = animationToLookup
                end
            end
    end)
end