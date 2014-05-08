
if SERVER then

	AddCSLuaFile();

end

DEFINE_BASECLASS( "base_wire_entity" );

ENT.PrintName = "ACF Vehicle Controller";
ENT.WireDebugName = "ACF Vehicle Controller";

if CLIENT then return end


local function getDefaultVehicleTable()
	return {
			origin = Vector( 0, 0, 0 ),
			angles = Angle( 0, 0, 0 ),
			fov = 0,
			znear = 0,
			zfar = 0,
			ent = NULL,
			poslocal = false
		};
end


function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );
	
	self.Inputs = Wire_CreateInputs( self, { 
		"X", 
		"Y", 
		"Z", 
		"Local Pos",
		-- Angle modifications cause bugs atm
		--"Pitch", 
		--"Yaw", 
		--"Roll", 
		"Fov", 
		"ZNear", 
		"ZFar",
		"Entity [ENTITY]"
	} );

	self.Vehicle = NULL;
	
	self.VehicleACFTable = getDefaultVehicleTable()
	
end

function ENT:Setup()

end

function ENT:LinkEnt( pod )

	if( !IsValid( pod ) or !pod:IsVehicle() ) then 

		return false, "Must link to a vehicle";

	end

	self.Vehicle = pod;

	if( !self.Vehicle.ACFTable ) then

		self:UpdateVehicle();

	end

	WireLib.SendMarks(self, {pod});

	return true;

end

function ENT:UnlinkEnt()

	if( IsValid( self.Vehicle ) ) then

		self.Vehicle.ACFTable = nil;

	end

	self.Vehicle = NULL;

	WireLib.SendMarks(self, {});

	return true;

end

function ENT:OnRemove()

	if( IsValid( self.Vehicle ) ) then

		self.Vehicle.ACFTable = nil;

	end

end

function ENT:TriggerInput( k, v )

	k = tostring( k );
	--v = tonumber( v );

	if not self.VehicleACFTable then
		self.VehicleACFTable = getDefaultVehicleTable()
	end
	
	
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
		
	elseif( k == "Local Pos" ) then

		self.VehicleACFTable.poslocal = tobool( v );
		
	elseif( k == "Entity" ) then
	
		if IsValid(v) and v:GetOwner() == self:GetOwner() then
			self.VehicleACFTable.ent = v;
		else
			self.VehicleACFTable.ent = NULL;
		end

	end

	self:UpdateVehicle();

end



function ENT:UpdateVehicle()

	if( !IsValid( self.Vehicle ) ) then return end

	self.Vehicle.ACFTable = self.VehicleACFTable;

	local pl = self.Vehicle:GetDriver()

	if( IsValid( pl ) ) then
		
		local veh = self.Vehicle;
		local tbl = veh.ACFTable or {};

		net.Start( "acf_vehicle_update" );
			net.WriteEntity( veh );
			net.WriteTable( tbl );
		net.Send( pl );

	end

end

function MakeACF_VehicleController( pl, Pos, Angle, Model, VehicleACFTable )

	local controller = ents.Create( "acf_vehicle_controller" );

	if( !IsValid( controller ) ) then return end

	controller:SetModel( Model );
	controller:SetPos( Pos );
	controller:SetAngles( Angle );
	controller:Spawn();

	controller.VehicleACFTable = VehicleACFTable or getDefaultVehicleTable();
	
	return controller;

end

duplicator.RegisterEntityClass( "acf_vehicle_controller", MakeACF_VehicleController, "Pos", "Angle", "Model", "VehicleACFTable" );

function ENT:BuildDupeInfo()

	local info = self.BaseClass.BuildDupeInfo( self ) or {};

	if( IsValid( self.Vehicle ) ) then

		info.VehicleID = self.Vehicle:EntIndex();

	end

	return info;

end

function ENT:ApplyDupeInfo( pl, ent, info, GetEntByID )

	self.BaseClass.ApplyDupeInfo( self, pl, ent, info, GetEntByID );

	if( !IsValid( self:GetPlayer() ) ) then

		self:SetPlayer( pl );

	end

	veh = GetEntByID( info.VehicleID );

	if( IsValid( veh ) ) then

		self:LinkEnt( veh );

	end

end
