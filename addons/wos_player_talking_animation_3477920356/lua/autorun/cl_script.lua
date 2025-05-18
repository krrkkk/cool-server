AddCSLuaFile()
local animCooldown = CreateConVar("talking_animation_cooldown", "2.5", FCVAR_ARCHIVE, "Change cooldown of animation(starts with the animation)")
local animChance = CreateClientConVar("talking_animation_chance", "1",true,true, "Change the chance of talking animation happening", 0, 1)
local enableAnimsClient = CreateClientConVar("enable_player_talking_animation", "1",true,true, "Enable or disable your talking animation.", 0, 1)
local enableVoiceText = CreateClientConVar("talking_chatvoice_animations", "0", true, true, "Enable talking animation only for voice/text chat or both")
local enableWeaponAnims = CreateClientConVar("enable_player_weapon_anims","1",true,true,"Enable talking animations with weapons")

if SERVER then
    util.AddNetworkString( "TalkingStart" )
end
if CLIENT then
    local doingAnim = false
    timer.Create("toggleAnim", 5, 0, function()
        if doingAnim then
           doingAnim = false
        end
   end )


    hook.Add("PopulateToolMenu", "TalkingAnimationMenu", function()
        spawnmenu.AddToolMenuOption("Options", "Player Talking Animation", "TalkingAnimationMenu", "Settings", "", "", function(panel)
            local isAdmin = LocalPlayer():IsAdmin()
            panel:NumSlider("Talking animation chance", "talking_animation_chance", 0, 1, 2)

            panel:NumSlider("Talking animation cooldown", "talking_animation_cooldown", 0,60,1)
            panel:Help("(Cooldown starts with the animation)")
            panel:NumSlider("Talking animation only for voice/text chat or both", "talking_chatvoice_animations", 0,2,0)
            panel:Help("0 - Animations for both text and voice chat")
            panel:Help("1 - Animations only for voice chat")
            panel:Help("2 - Animations only for text chat")
            panel:CheckBox("Enable talking animation with weapons", "enable_player_weapon_anims")
            panel:CheckBox("Enable talking animation", "enable_player_talking_animation")
            if isAdmin then
                panel:Help("------------------------------------")
                panel:CheckBox("Enable talking animation (Server)", "enable_talking_animation")
                panel:Help("Enable or disable talking animation for everyone")
            end 
        end)  
    end)
    hook.Add("PlayerStartVoice", "AnimationStart", function(player)
    if ( player != LocalPlayer() ) then return end
            if enableAnimsClient:GetBool() and (!bDead) and enableVoiceText:GetInt() == 0 or enableVoiceText:GetInt() == 1 then
                local chance = math.Rand(0,1)
                if chance <= animChance:GetFloat() and doingAnim == false then
                    doingAnim = true
                    lookup = player:LookupSequence("M_g_sweepout")
                    if lookup == -1 then
                        net.Start( "TalkingStart" )
                            net.WriteBool(true)
                            net.WriteString("M")
                            net.WriteBool(enableWeaponAnims:GetBool())
                        net.SendToServer()
                    else
                        net.Start( "TalkingStart" )
                            net.WriteBool(true)
                            net.WriteString("W")
                            net.WriteBool(enableWeaponAnims:GetBool())
                        net.SendToServer()
                    end
                end
            end
    end)
    hook.Add( "OnPlayerChat", "SendChatTalkingAnimation", function( ply, strText, bTeam, bDead ) 
    if ( ply != LocalPlayer() ) then return end
        if enableAnimsClient:GetBool() and (!bDead) and enableVoiceText:GetInt() == 0 or enableVoiceText:GetInt() == 2 then
            local chance = math.Rand(0,1)
                if chance <= animChance:GetFloat() and doingAnim == false then
                    doingAnim = true
                    lookup = ply:LookupSequence("M_g_sweepout")
                    if lookup == -1 then
                        net.Start( "TalkingStart" )
                            net.WriteBool(true)
                            net.WriteString("M")
                            net.WriteBool(enableWeaponAnims:GetBool())
                        net.SendToServer()
                    else
                        net.Start( "TalkingStart" )
                            net.WriteBool(true)
                            net.WriteString("W")
                            net.WriteBool(enableWeaponAnims:GetBool())
                        net.SendToServer()
                    end
                end
        end
    end)

    net.Receive("TalkingAnimNet",function(Len)
        local ply = net.ReadPlayer()
        local lookup = net.ReadUInt(16)
        ply:SetLayerBlendIn(lookup, 1)
        ply:AddVCDSequenceToGestureSlot(6, lookup, 0,true)
        timer.Adjust("toggleAnim", animCooldown:GetFloat())
        timer.Start("toggleAnim")
    end )
end
