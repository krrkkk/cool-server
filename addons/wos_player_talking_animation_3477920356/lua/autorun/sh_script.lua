hook.Add( "InitLoadAnimations", "wOS.DynaBase.CustomMount", function()
    wOS.DynaBase:RegisterSource({
        Name = "Player Talking Animation",
        Type = WOS_DYNABASE.EXTENSION,
        Male = "models/humans/male_gestures.mdl",
        Female = "models/humans/female_gestures.mdl",
    })

    hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountPTA", function( gender )
        if gender == WOS_DYNABASE.SHARED then return end

        if gender == WOS_DYNABASE.FEMALE then
            IncludeModel( "models/mossman_gestures.mdl" )
            IncludeModel( "models/alyx_gest_ep1.mdl")
            IncludeModel( "models/alyx_gest_ep2.mdl")
            IncludeModel( "models/Eli_gestures.mdl" )
            IncludeModel( "models/humans/male_gestures.mdl")
        elseif gender == WOS_DYNABASE.MALE then
            IncludeModel( "models/Eli_gestures.mdl" )
            IncludeModel( "models/humans/male_gestures.mdl")
        end
    end )
end )