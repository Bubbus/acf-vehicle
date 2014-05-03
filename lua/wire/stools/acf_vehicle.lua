
WireToolSetup.setCategory( "I/O" )
WireToolSetup.open( "acf_vehicle", "ACF Vehicle Controller", "acf_vehicle_controller", nil, "ACF Vehicle Controllers" )

if CLIENT then
	language.Add("Tool.wire_acf_vehicle.name", "ACF Vehicle Controller Tool")
	language.Add("Tool.wire_acf_vehicle.desc", "Spawn/link a controller.")
	language.Add("Tool.wire_acf_vehicle.0", "Primary: Create controller. Secondary: Link controller.")
	language.Add("Tool.wire_acf_vehicle.1", "Now select the ACF Pod to link to.")
end

WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 5 )

TOOL.ClientConVar[ "model" ] = "models/jaanus/wiretool/wiretool_siren.mdl"

WireToolSetup.SetupLinking( true )

function TOOL.BuildCPanel(panel)
	WireDermaExts.ModelSelect(panel, "wire_vehicle_model", list.Get( "Wire_Misc_Tools_Models" ), 1)
end

