
if SERVER then

	AddCSLuaFile();

end

DEFINE_BASECLASS( "base_wire_entity" );

ENT.PrintName = "ACF Vehicle Controller";
ENT.WireDebugName = "ACF Vehicle Controller";

if CLIENT then return end

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );
	
	self.Inputs = Wire_CreateInputs( self, { "X", "Y", "Z", "Pitch", "Yaw", "Roll", "Fov", "ZNear", "ZFar" } );

end

function ENT:LinkEnt( pod )

	if( !IsValid( pod ) or !pod:IsVehicle() ) then 

		return false, "Must link to a vehicle";

	end

	self.Vehicle = pod;

	if( !self.Vehicle.ACFTable ) then

		self.Vehicle.ACFTable = {
			origin = Vector( 0, 0, 0 ),
			angles = Angle( 0, 0, 0 ),
			fov = 0,
			znear = 0,
			zfar = 0
		};

	end

	WireLib.SendMarks(self, {pod});

	return true;

end

function ENT:UnlinkEnt()

	self.Vehicle = nil;

	WireLib.SendMarks(self, {});

	return true;

end

function ENT:TriggerInput( k, v )

	if( !IsValid( self.Vehicle ) ) then return end
	if( !self.Vehicle.ACFTable ) then return end

	if( k == "X" ) then

		self.Vehicle.ACFTable.origin.x = tonumber( v );

	elseif( k == "Y" ) then

		self.Vehicle.ACFTable.origin.y = tonumber( v );	

	elseif( k == "Z" ) then

		self.Vehicle.ACFTable.origin.z = tonumber( v );	

	elseif( k == "Pitch" ) then

		self.Vehicle.ACFTable.angles.pitch = tonumber( v );	

	elseif( k == "Yaw" ) then

		self.Vehicle.ACFTable.angles.yaw = tonumber( v );	

	elseif( k == "Roll" ) then

		self.Vehicle.ACFTable.angles.roll = tonumber( v );	

	elseif( k == "Fov" ) then

		self.Vehicle.ACFTable.fov = tonumber( v );	

	elseif( k == "ZNear" ) then

		self.Vehicle.ACFTable.znear = tonumber( v );	

	elseif( k == "ZFar" ) then

		self.Vehicle.ACFTable.zfar = tonumber( v );

	end

end

function ENT:BuildDupeInfo()

	local info = self.BaseClass.BuildDupeInfo( self ) or {};

	if( IsValid( self.Vehicle ) ) then

	    info.Vehicle = self.Vehicle:EntIndex();
	    info.VehicleACFTable = self.Vehicle.ACFTable;

	end

	return info;

end

function ENT:ApplyDupeInfo( ply, ent, info, GetEntByID )

	self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID );

	self.Vehicle = GetEntByID( info.Vehicle );

	if( IsValid( self.Vehicle ) ) then

		self.Vehicle.ACFTable = info.VehicleACFTable;

	end

end

duplicator.RegisterEntityClass( "acf_vehicle_controller", WireLib.MakeWireEnt, "Data", "Vehicle", "VehicleACFTable" );
