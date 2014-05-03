
if SERVER then

	AddCSLuaFile();

	util.AddNetworkString( "acf_vehicle_update" );

	hook.Add( "PlayerEnteredVehicle", "ACFPlayerEnteredVehicle", function( pl, veh, role ) 

		if( IsValid( veh ) and IsValid( pl ) and veh.ACFTable ) then

			net.Start( "acf_vehicle_update" );
				net.WriteTable( veh.ACFTable );
			net.Send( pl );

		end

	end );

end

if CLIENT then

	net.Receive( "acf_vehicle_update", function( len )

		local new = net.ReadTable();

		ACFVehicleTable = new or {};

	end );

	hook.Add( "InitPostEntity", "ACFGMCalcOverride", function()

		function GAMEMODE:CalcVehicleView( veh, pl, view )

			return hook.Run( "CalcVehicleView", veh, pl, view );

		end

	end );

	hook.Add( "CalcVehicleView", "ACFCalcVehicleView", function( veh, pl, view )

		if( IsValid( veh ) and IsValid( pl ) and ACFVehicleTable ) then

			-- fetch acf_vehicle_controller values from the vehicle
			local acf = ACFVehicleTable;

			-- setup our new view table
			local new = {};

			if( acf.origin ) then

				new.origin = Vector( ( acf.origin.x or 0 ), ( acf.origin.y or 0 ), ( acf.origin.z or 0 ) );

			end

			if( acf.angles ) then

				new.angles = Angle( ( acf.angles.pitch or 0 ), ( acf.angles.yaw or 0 ), ( acf.angles.roll or 0 ) );

			end

			if( acf.fov ) then

				new.fov = acf.fov or 0;

			end

			if( acf.znear ) then

				new.znear = acf.znear or 0;

			end

			if( acf.zfar ) then

				new.zfar = acf.zfar or 0;

			end

			-- add the new values to the old values
			local override = table.Copy( view );

			if( new.origin ) then

				override.origin = override.origin + new.origin;

			end

			if( new.angles ) then

				override.angles = override.angles + new.angles;

			end

			if( new.fov ) then

				override.fov = override.fov + new.fov;

			end

			if( new.znear ) then

				override.znear = override.znear + new.znear;

			end

			if( new.zfar ) then

				override.zfar = override.zfar + new.zfar;

			end

			-- return overridden view table
			return override;

		end

		return view;

	end );

end
