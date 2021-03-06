
if SERVER then

	AddCSLuaFile();

	util.AddNetworkString( "acf_vehicle_update" );

	hook.Add( "PlayerEnteredVehicle", "ACFPlayerEnteredVehicle", function( pl, veh, role ) 

		if( IsValid( veh ) and IsValid( pl ) and veh.ACFTable ) then

			local tbl = veh.ACFTable or {};

			net.Start( "acf_vehicle_update" );
				net.WriteEntity( veh );
				net.WriteTable( tbl );
			net.Send( pl );

		end

	end );

end

if CLIENT then

	ACFVehicleTable = {};

	net.Receive( "acf_vehicle_update", function( len )

		local ent = net.ReadEntity();
		local tbl = net.ReadTable();

		if( IsValid( ent ) ) then

			ACFVehicleTable[ ent ] = tbl;

		end

	end );

	hook.Add( "InitPostEntity", "ACFGMCalcOverride", function()

		function GAMEMODE:CalcVehicleView( veh, pl, view )

			if( IsValid( veh ) and !veh:GetThirdPersonMode() ) then

				return hook.Run( "CalcVehicleView", veh, pl, view );

			else

				return hook.Run( "CalcVehicleThirdPersonView", veh, pl, view );

			end

		end

	end );

	hook.Add( "CalcVehicleView", "ACFCalcVehicleView", function( veh, pl, view )

		if( IsValid( veh ) and IsValid( pl ) and ACFVehicleTable[ veh ] ) then

			-- fetch acf_vehicle_controller values from the vehicle
			local acf = ACFVehicleTable[ veh ];

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

				local ent = IsValid(acf.ent) and acf.ent or veh
				local viewbasis = ent:GetPos();
				local viewoffset = acf.poslocal and WorldToLocal(new.origin, Angle(), Vector(0,0,0), -acf.ent:GetAngles()) or new.origin;

				override.origin = viewbasis + viewoffset;

			end

			if( new.angles ) then

				override.angles = override.angles + new.angles;

			end

			if( new.fov and new.fov > 0 and new.fov < 180 ) then

				override.fov = new.fov;

			end

			if( new.znear and new.znear ~= 0 ) then

				override.znear = new.znear;

			end

			if( new.zfar and new.zfar ~= 0 ) then

				override.zfar = new.zfar;

			end

			-- return overridden view table
			return override;

		end

		return view;

	end );

	hook.Add( "CalcVehicleThirdPersonView", "ACFCalcVehicleThirdPersonView", function( veh, pl, view )

		if ( veh.GetThirdPersonMode == nil || pl:GetViewEntity() != pl ) then return end

		-- If we're not in third person mode - then get outa here stalker
		if ( !veh:GetThirdPersonMode() ) then return view end

		-- Don't roll the camera 
		-- view.angles.roll = 0

		local mn, mx = veh:GetRenderBounds();
		local radius = (mn - mx):Length();
		local radius = radius + radius * veh:GetCameraDistance();

		-- Trace back from the original eye position, so we don't clip through walls/objects
		local TargetOrigin = view.origin + ( view.angles:Forward() * -radius );
		local WallOffset = 4;
			  
		local tr = util.TraceHull( {
			start	= view.origin,
			endpos	= TargetOrigin,
			filter	= function()
				return false
			end,
			mins	= Vector( -WallOffset, -WallOffset, -WallOffset ),
			maxs	= Vector( WallOffset, WallOffset, WallOffset ),
		} );
		
		view.origin			= tr.HitPos;
		view.drawviewer		= true;

		-- If the trace hit something, put the camera there.
		if ( tr.Hit && !tr.StartSolid) then
			view.origin = view.origin + tr.HitNormal * WallOffset
		end

		return view;

	end );

end
