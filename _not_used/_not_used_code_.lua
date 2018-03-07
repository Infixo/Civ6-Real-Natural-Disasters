--------------------------------------------------------------
-- _not_used_code_
-- Author: Infixo
-- DateCreated: 4/26/2017 5:12:47 PM
--------------------------------------------------------------

-- NOT USED - another method, online checking, no need to store in-memory buildings and keep track of them

-- ===========================================================================
-- PREVENTION CLASSES
-- Class_DisasterPrevention
--   A table of Class_DisasterBuilding and functions to manipulate
-- Class_PreventionDamage | Class_PreventionPopulation | Class_PreventionRemoval | Class_PreventionInsurance
--   Various functions to manipulate
-- Class_DisasterBuilding
--   Many instances, one for each building on the map
--   Keeps track of the status (pillaged), owner, CityID, etc.
-- ===========================================================================

BuildingClasses = {
	DAMAGE = 1, 		-- Reduce Magnitude (damage)
	POPULATION = 2,  	-- Reduce Magnitude (pop loss)
	REMOVAL = 3,  		-- Prevent Disaster (remove start plots)
	INSURANCE = 4,
};

local Class_DisasterBuilding:table = { _ClassName = "Class_DisasterBuilding" };
RegisterClass(Class_DisasterBuilding, Class_Object);

function Class_DisasterBuilding:new(eOwnerID:number, iCityID:number, iBuilding:number, iPlot:number, iRange:number)
	--dprint("FUNCAL Class_DisasterBuilding:new() (buld,own,cit,plot,rang)",iBuilding, eOwnerID, iCityID, iPlot, iRange);
	local tObject:table = self:newObject();
	-- fill in oprational data
	tObject.OwnerID = eOwnerID;			-- number, player index who owns the building
	tObject.CityID = iCityID;			-- number, city id in which the building is located
	tObject.Building = iBuilding; 		-- number, building index
	tObject.Plot = iPlot;				-- number, plot index
	--tObject.IsPillaged = bIsPillaged; 	-- boolean, flag  -- there's no event for pillaging, so this flag must be retrieved online each time a check is performed
	-- some config data
	tObject.Range = iRange;				-- number, effect range, -1 for City limits, 0 is the plot itself only
	--tObject.Value = iValue;				-- prevention value
	return tObject;
end

-- helper
function Class_DisasterBuilding:GetCityBuildings()
	local pPlayer = Players[self.OwnerID];
	if (not pPlayer) or (not pPlayer:WasEverAlive()) or (not pPlayer:IsAlive()) or pPlayer:IsBarbarian() then return nil; end
	local pCity = pPlayer:GetCities():FindID(self.CityID);
	if pCity == nil then return nil; end
	return pCity:GetBuildings();
end

-- check if the building still exists
function Class_DisasterBuilding:IsExists()
	local cityBuildings = self:GetCityBuildings();
	if cityBuildings then return cityBuildings:HasBuilding( self.Building ); end
	return false
end

-- check if the building is pillaged
function Class_DisasterBuilding:IsPillaged()
	local cityBuildings = self:GetCityBuildings();
	if cityBuildings then return cityBuildings:IsPillaged( self.Building ); end
	return false
end

-- simple check for range
function Class_DisasterBuilding:IsPlotIndexInPreventionRange(iPlot:number)
	--dprint("FUNCAL Class_DisasterBuilding:IsPlotIndexInPreventionRange (center,range,plot)", self.Plot, self.Range, iPlot);
	if self:IsPillaged() then return false; end  -- pillaged building is not working, same as being out of range
	if self.Range == 0 then return self.Plot == iPlot; end  -- plot itself, no need to call distance calculations
	if self.Range > 0 then return Map.GetPlotDistance(self.Plot, iPlot) <= self.Range; end
	-- for Range < 0 check if iPlot is within City limits
	local pPlot = Map.GetPlotByIndex(iPlot);
	if not (pPlot and pPlot:IsOwned()) then return false; end
	return pPlot:GetOwner() == self.OwnerID and Cities.GetPlotPurchaseCity(pPlot):GetID() == self.CityID;
end

-- DISASTER PREVENTIONS

local Class_DisasterPrevention:table = { _ClassName = "Class_DisasterPrevention", BuildingClass = 0 };
RegisterClass(Class_DisasterPrevention, Class_Object);

local Class_PreventionDamage:table = { _ClassName = "Class_PreventionDamage", BuildingClass = BuildingClasses.DAMAGE };
RegisterClass(Class_PreventionDamage, Class_DisasterPrevention);

local Class_PreventionPopulation:table = { _ClassName = "Class_PreventionPopulation", BuildingClass = BuildingClasses.POPULATION };
RegisterClass(Class_PreventionPopulation, Class_DisasterPrevention);

local Class_PreventionRemoval:table = { _ClassName = "Class_PreventionRemoval", BuildingClass = BuildingClasses.REMOVAL };
RegisterClass(Class_PreventionRemoval, Class_DisasterPrevention);

local Class_PreventionInsurance:table = { _ClassName = "Class_PreventionInsurance", BuildingClass = BuildingClasses.INSURANCE };
RegisterClass(Class_PreventionInsurance, Class_DisasterPrevention);

function Class_DisasterPrevention:AddBuilding(eOwnerID:number, iCityID:number, iBuilding:number, iPlot:number) --, bIsPillaged:boolean)
	dprint("FUNCAL Class_DisasterPrevention:AddBuilding() (buld,own,cit,plot)",iBuilding, eOwnerID, iCityID, iPlot); --, bIsPillaged);
	if not IsInTable(self.TrackedBuildings, iBuilding) then print("WARNING Class_DisasterPrevention:AddBuilding(): building is not tracked (class,idx)", self.BuildingClass, iBuilding); end
	-- we must insert one instance for each disaster type it is registered with
	for distype,disbuld in pairs(self.DisasterBuildings) do -- disbuld is a simple table
		for ibuld,buld in pairs(disbuld) do  -- buld is a record with 5 fields
			if ibuld == iBuilding then 
				-- ok, we found a place to add it
				dprint("   ...adding to queue (dis,ibuld,type,range,value)", distype, ibuld, buld.BuildingType, buld.Range, buld.Value);
				local tBuilding:table = Class_DisasterBuilding:new(eOwnerID, iCityID, iBuilding, iPlot, buld.Range); --bIsPillaged, 
				table.insert(buld.Buildings, tBuilding);
			end
		end
	end
end

-- initialize prevention class - get data from DB and check for already existing buildings on the map
-- this will actually be called for each sub-class separately, not for parent object
function Class_DisasterPrevention:Initialize()
	dprint("FUNCAL Class_DisasterPrevention:Initialize() (class,buldcl)", self._ClassName, self.BuildingClass);
	-- get data for a specific class
	-- it will be stored in a table indexed by DisasterType
	-- each entry will be a table of: BuildingType, Index, Value, Range, and table of actual buildings
	self.DisasterBuildings = {};
	self.TrackedBuildings = {};  -- table of building indexes
	for buld in GameInfo.RNDDisasterBuildings() do
		if buld.BuildingClass == self.BuildingClass then
			dprint("   ...registering disaster building (class,dis,buld)", buld.BuildingClass, buld.DisasterType, buld.BuildingType);
			if self.DisasterBuildings[buld.DisasterType] == nil then self.DisasterBuildings[buld.DisasterType] = {}; end
			-- the record below will often be references as 'disbuld'
			local tBuilding:table = {
				BuildingType = buld.BuildingType,
				BuildingIndex = GameInfo.Buildings[buld.BuildingType].Index, 
				Value = buld.Value,
				Range = buld.Range,
				Buildings = {},  -- table of Class_DisasterBuilding objects
			};
			self.DisasterBuildings[buld.DisasterType][ tBuilding.BuildingIndex ] = tBuilding;  -- ["DISASTER_TYPE"][iBuildingIndex]
			if not IsInTable(self.TrackedBuildings, tBuilding.BuildingIndex) then
				table.insert(self.TrackedBuildings, tBuilding.BuildingIndex);
			end
		end
	end
	-- check for buildings
	dprint("  Checking for existing disaster buildings");
	local ePlayer:number = 0;
	local pPlayer = Players[ePlayer];
	while pPlayer do
		if pPlayer:WasEverAlive() and pPlayer:IsAlive() and not pPlayer:IsBarbarian() then
			--dprint("   ...found player (idx,name)", ePlayer, Locale.Lookup( PlayerConfigurations[ePlayer]:GetCivilizationShortDescription() ));
			for _,city in pPlayer:GetCities():Members() do
				dprint("      ...found city (idx,name)", city:GetID(), city:GetName());
				for _,buld in pairs(self.TrackedBuildings) do
					if city:GetBuildings():HasBuilding(buld) then
						dprint("         ...found building (idx,loc,name)", buld, city:GetBuildings():GetBuildingLocation(buld), GameInfo.Buildings[buld].BuildingType);
						self:AddBuilding(ePlayer, city:GetID(), buld, city:GetBuildings():GetBuildingLocation(buld)); --, city:GetBuildings():IsPillaged(buld));
					end
				end -- tracked buildings
			end -- cities
		end -- checking player
		ePlayer = ePlayer + 1;
		pPlayer = Players[ePlayer];
	end -- while
	
	-- debug
	--dprint("--- CLASS INITIALIZED ---", self._ClassName);
	--dshowrectable(self);
end

-- simple check if anything is registered for a given Disaster, can save some processing time later
function Class_DisasterPrevention:HasDisasterPrevention(sDisasterType:string)
	return self.DisasterBuildings[sDisasterType] ~= nil;
end

-- simple check if a building is tracked
function Class_DisasterPrevention:IsTrackingBuilding(eBuilding:number)
	return IsInTable(self.TrackedBuildings, eBuilding);
end

-- main function - iterate through all active buildings assigned to a given Disaster and sum all of their prevention values
-- returns (boolean) - prevention active, (number) - sum of prevention values
function Class_DisasterPrevention:GetDisasterPrevention(sDisasterType:string, iPlot:number)
	local tDisasterBuildings:table = self.DisasterBuildings[sDisasterType];
	if tDisasterBuildings == nil then return false, 0; end  -- no building registered for this Disaster Type
	local bActive:boolean = false;
	local iValue:number = 0;
	for _,disbuld in pairs(tDisasterBuildings) do
		for _,buld in pairs(disbuld.Buildings) do
			if buld:IsPlotIndexInPreventionRange(iPlot) then
				bActive = true;
				iValue = iValue + disbuld.Value;
				break;  -- DO NOT COUNT TWICE SAME BUILDINGS
			end
		end
	end
	return bActive, iValue;
end

function Class_DisasterPrevention:ddisplayprevmap(sDisasterType:string)
	dprint("--- DISPLAY PREVENTION ---", self._ClassName, sDisasterType);
	if not self:HasDisasterPrevention(sDisasterType) then dprint("  No registered prevention buildings for (disaster)", sDisasterType); return; end
	local tPlots:table = {};
	for i=0,iMapSize-1 do
		if self:GetDisasterPrevention(sDisasterType,i) then table.insert(tPlots,i); end
	end
	ddisplaymap(tPlots,"XX");
end

function Class_DisasterPrevention:CheckAndRemoveFromPrevention(iPlot:number)
	dprint("FUNCAL Class_DisasterPrevention:CheckAndRemoveFromPrevention() (class,plot)", self._ClassName, iPlot);
	local bRemoved:boolean = false;
	for sDisasterType, tDisasterBuildings in pairs(self.DisasterBuildings) do
		dprint("   ...checking (dis)", sDisasterType);
		for _,disbuld in pairs(tDisasterBuildings) do
			dprint("      ...checking (type)", disbuld.BuildingType);
			for i, buld in pairs(disbuld.Buildings) do
				-- buld is Class_DisasterBuilding object
				if buld.Plot == iPlot and not buld:IsExists() then
					dprint("   ...removing building (plot,owner,city,type)", buld.Plot, buld.OwnerID, buld.CityID, disbuld.BuildingType);
					table.remove(disbuld.Buildings, i);
					bRemoved = true; -- no need go check more plots
					break;
				end
			end
			if bRemoved then
				dprint("   ...not checking other types");
				bRemoved = false;
				break;
			end
		end
	end
	--if not bRemoved then print("WARNING Class_DisasterPrevention:CheckAndRemoveFromPrevention(): (class) couldn't remove a building at (plot)", self._ClassName, iPlot); end
end


-- we're only interested in buildings as for now
function OnCityProductionCompleted(ePlayer:number, iCity:number, eOrderType:number, eObjectType:number, bCanceled, typeModifier)
	if eOrderType ~= 1 then return; end  -- OrderTypes.ORDER_CONSTRUCT
	dprint("FUNCAL OnCityProductionCompleted [CONSTRUCT](ePlayer,iCity,eObjectType)",ePlayer,iCity,GameInfo.Buildings[eObjectType].BuildingType);
	-- check if any prevention is assigned to it
	local cityBuildings = Players[ePlayer]:GetCities():FindID(iCity):GetBuildings();  -- we've just completed a building, so player and city SHOULD exist
	local function CheckAndRegisterForPrevention(tClass:table)
		if tClass:IsTrackingBuilding(eObjectType) then --dprint("  ...no tracking in", tClass._ClassName); return; end
			dprint("  ...building is tracked by", tClass._ClassName);
			tClass:AddBuilding(ePlayer, iCity, eObjectType, cityBuildings:GetBuildingLocation(eObjectType), cityBuildings:IsPillaged(eObjectType));
		end
	end
	CheckAndRegisterForPrevention(Prevention_Damage);
	CheckAndRegisterForPrevention(Prevention_Population);
	CheckAndRegisterForPrevention(Prevention_Removal);
	CheckAndRegisterForPrevention(Prevention_Insurance);
end

-- notice that we don't know which building was removed exactly - we need to check them all
function OnBuildingRemovedFromMap(iX:number, iY:number)
	dprint("FUNCAL OnBuildingRemovedFromMap() (x,y)", iX, iY);
	local iPlot:number = iMapWidth * iY + iX;
	Prevention_Damage:CheckAndRemoveFromPrevention(iPlot);
	Prevention_Population:CheckAndRemoveFromPrevention(iPlot);
	Prevention_Removal:CheckAndRemoveFromPrevention(iPlot);
	Prevention_Insurance:CheckAndRemoveFromPrevention(iPlot);
end
