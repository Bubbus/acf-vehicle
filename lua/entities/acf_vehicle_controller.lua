
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
	
	self.Inputs = Wire_CreateInputs( self, { 
		"X", 
		"Y", 
		"Z", 
		-- Angle modifications cause bugs atm
		--"Pitch", 
		--"Yaw", 
		--"Roll", 
		"Fov", 
		"ZNear", 
		"ZFar" 
	} );

	self.Vehicle = NULL;

	self.VehicleACFTable = {
		origin = Vector( 0, 0, 0 ),
		angles = Angle( 0, 0, 0 ),
		fov = 0,
		znear = 0,
		zfar = 0
	};

end

function ENT:Setup()

	self:SetOwner( self:GetPlayer() );

end

function ENT:LinkEnt( pod )

	if( !IsValid( pod ) or !pod:IsVehicle() ) then 

		return false, "Must link to a vehicle";

	end

	self.Vehicle = pod;
	self.VehicleID = pod:EntIndex();

	if( !self.Vehicle.ACFTable ) then

		self:UpdateVehicle();

	end

	WireLib.SendMarks(self, {pod});

	return true;

end

function ENT:UnlinkEnt()

	self.Vehicle = NULL;

	WireLib.SendMarks(self, {});

	return true;

end

function ENT:TriggerInput( k, v )

	if( k == "X" ) then

		self.VehicleACFTable.origin.x = tonumber( v );

	elseif( k == "Y" ) then

		self.VehicleACFTable.origin.y = tonumber( v );	

	elseif( k == "Z" ) then

		self.VehicleACFTable.origin.z = tonumber( v );	

	elseif( k == "Pitch" ) then

		self.VehicleACFTable.angles.pitch = tonumber( v );	

	elseif( k == "Yaw" ) then

		self.VehicleACFTable.angles.yaw = tonumber( v );	

	elseif( k == "Roll" ) then

		self.VehicleACFTable.angles.roll = tonumber( v );	

	elseif( k == "Fov" ) then

		self.VehicleACFTable.fov = tonumber( v );	

	elseif( k == "ZNear" ) then

		self.VehicleACFTable.znear = tonumber( v );	

	elseif( k == "ZFar" ) then

		self.VehicleACFTable.zfar = tonumber( v );

	end

	self:UpdateVehicle();

end

function ENT:UpdateVehicle()

	if( !IsValid( self.Vehicle ) ) then return end

	self.Vehicle.ACFTable = self.VehicleACFTable;

	local pl = self:GetOwner();

	if( IsValid( pl ) and IsValid( pl:GetVehicle() ) ) then
		
		net.Start( "acf_vehicle_update" );
			net.WriteTable( veh.ACFTable );
		net.Send( pl );

	end

end

function MakeACF_VehicleController( pl, Pos, Angle, Model, VehicleID, VehicleACFTable )

	local controller = ents.Create( "acf_vehicle_controller" );

	if( !IsValid( controller ) ) then return end

	controller:SetModel( Model );
	controller:SetPos( Pos );
	controller:SetAngles( Angle );
	controller:Spawn();

	controller.VehicleACFTable = VehicleACFTable;

	local veh = Entity( VehicleID );

	if( IsValid( veh ) ) then

		controller:LinkEnt( veh );

	end

	return controller;

end

duplicator.RegisterEntityClass( "acf_vehicle_controller", MakeACF_VehicleController, "Pos", "Angle", "Model", "VehicleID", "VehicleACFTable" );
