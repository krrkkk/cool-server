if CLIENT then

local BARDOOR_IMG = "materials/doorbar/util.png"
hook.Add("AddToolMenuCategories", "BaricadingDoorCategory", function()
    spawnmenu.AddToolCategory("Utilities", "Baricading Door", "Baricading Door")
end)

hook.Add("PopulateToolMenu", "BaricadingDoorSettings", function()
    spawnmenu.AddToolMenuOption("Utilities", "Baricading Door", "bardoorserver", "Barricading Door", "", "", function(panel)
        panel:ClearControls()

        local image = vgui.Create("DImage")
        image:SetSize(128, 128)
        image:SetImage(BARDOOR_IMG)
        panel:AddItem(image)

        panel:Help( "Baricading doors addon" )
        panel:CheckBox( "Players Support", "door_barricading_enable" )
        panel:ControlHelp( "On - Players will not be able to open barricaded doors" )
        panel:CheckBox( "NPCs Support", "door_barricading_npc" )
        panel:ControlHelp( "On - NPCs will not be able to open barricaded doors" )
        panel:CheckBox( "No Animation", "door_barricading_lockdoor" )
        panel:ControlHelp( "If everything is so bad for you, you can make sure that the doors do not open at all when they are barricaded" )

        panel:Help( "Values:" )
		panel:NumSlider( "Baricade Force Power", "door_barricading_forcepower", 0, 100000, 0 )
        panel:ControlHelp( "The force of throwing barricades away from the door" )
        panel:NumSlider( "Baricade Distance", "door_barricading_distance", 30, 70, 0 )
        panel:ControlHelp( "The distance at which the barricades will be located" )
        panel:NumSlider( "Kick Door Chance", "door_barricading_kickchance", 0, 100, 0 )
        panel:ControlHelp( "Door kick chance from NPCs" )

        local urlButton = vgui.Create("DButton", panel)
        urlButton:SetText("Workshop")
        urlButton:SizeToContents()
        urlButton:SetTall(30)
        urlButton:SetWide(200)
        urlButton.DoClick = function()
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3351927911")
        end

        panel:AddItem(urlButton)

        local urlButton = vgui.Create("DButton", panel)
        urlButton:SetText("Bug Report")
        urlButton:SizeToContents()
        urlButton:SetTall(30)
        urlButton:SetWide(200)
        urlButton.DoClick = function()
            gui.OpenURL("https://steamcommunity.com/workshop/filedetails/discussion/3351927911/4699035627968084515/")
        end

        panel:AddItem(urlButton)

        local sndButton = vgui.Create("DButton", panel)
        sndButton:SetText("Cheese")
        sndButton:SizeToContents()
        sndButton:SetTall(20)
        sndButton:SetWide(200)
        sndButton.DoClick = function()
            local snd = Sound( "vo/npc/male01/question06.wav")
			surface.PlaySound( snd )
        end

        panel:AddItem(sndButton)
    end)
end)

end