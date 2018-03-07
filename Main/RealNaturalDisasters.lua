print("Loading RealNaturalDisasters.lua from Real Natural Disasters");
-- ===========================================================================
-- Real Natural Disasters
-- Author: Infixo
-- Created: March 25th - April 1st, 2017
-- ===========================================================================

local RND = ExposedMembers.RND;


-- ===========================================================================
-- DEBUG ROUTINES
-- ===========================================================================

-- debug output routine
function dprint(sStr,p1,p2,p3,p4,p5,p6)
	local sOutStr = sStr;
	if p1 ~= nil then sOutStr = sOutStr.." [1] "..tostring(p1); end
	if p2 ~= nil then sOutStr = sOutStr.." [2] "..tostring(p2); end
	if p3 ~= nil then sOutStr = sOutStr.." [3] "..tostring(p3); end
	if p4 ~= nil then sOutStr = sOutStr.." [4] "..tostring(p4); end
	if p5 ~= nil then sOutStr = sOutStr.." [5] "..tostring(p5); end
	if p6 ~= nil then sOutStr = sOutStr.." [6] "..tostring(p6); end
	print(sOutStr);
end

-- debug routine - print contents of a table of plot indices
function dshowtable(pTable:table)  -- For debugging purposes. LOT of table data being handled here.
	-- for ease of reading they will be printed in rows by 10
	dprint("Showing table (t,count)", pTable, table.count(pTable));
	local iSize = table.count(pTable);
	if iSize == 0 then dprint("...nothing to show"); return; end
	for y = 0, math.floor((iSize-1)/10), 1 do
		local sOutStr = "";
		for x = 0,9,1 do
			local idx = 10*y+x;
			if idx < iSize then sOutStr = sOutStr..string.format("%5d", pTable[idx+1]); end
		end
		dprint("  row", y, sOutStr);
	end
end

-- debug routine - will display ASCII map
-- pPlots is a table of IDs, sCode is 2-chars string to represent the feature
function ddisplaymap(pPlots:table, sCode:string)
	dprint("FUNSTA ddisplaymap(plots,code)", table.count(pPlots), sCode);
	
	local iW, iH = Map.GetGridSize();
	-- helper to check if ID exists in a given table
	local function plotIDExists(pPlots:table, iID:number)
		for _, val in pairs(pPlots) do
			if val == iID then return true; end
		end
		return false;
	end
	-- helper function - generate single row of Width codes
	local function getRowAsString( iy:number )
		local sRow:string = "";
		for ix = 0, iW-1, 1 do
			if plotIDExists(pPlots, iy * iW + ix) then
				sRow = sRow..sCode;
			else
				sRow = sRow.."_ ";
			end
			--dprint("@(y,x) ", iy, ix, sRow);
		end
		--dprint("@(y,x) ", iy, ix, sXRow);
		return sRow;
	end
	-- show the map - we must generate [height] strings for each x-row
	for iy = iH-1, 0, -1 do
		--dprint("map", iy, getRowAsString(iy));
		print(string.format("%2d ",iy), string.rep(" ", iy%2)..getRowAsString(iy));
	end
	
	dprint("FUNEND ddisplaymap(code)", sCode);
end

-- ===========================================================================
-- HELPFUL ENUMS
-- ===========================================================================

-- from MapEnums.lua
DirectionTypes = {
	DIRECTION_NORTHEAST = 0,
	DIRECTION_EAST 		= 1,
	DIRECTION_SOUTHEAST = 2,
	DIRECTION_SOUTHWEST = 3,
	DIRECTION_WEST		= 4,
	DIRECTION_NORTHWEST = 5,
	NUM_DIRECTION_TYPES = 6,
};

-- from MapEnums.lua
function GetGameInfoIndex(table_name, type_name) 
	local index = -1;
	local table = GameInfo[table_name];
	if(table) then
		local t = table[type_name];
		if(t) then
			index = t.Index;
		end
	end
	return index;
end

-- from MapEnums.lua, These come from the database.  Get the runtime index values.
g_TERRAIN_NONE				= -1;
g_TERRAIN_GRASS				= GetGameInfoIndex("Terrains", "TERRAIN_GRASS");
g_TERRAIN_GRASS_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_GRASS_HILLS");
g_TERRAIN_GRASS_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_GRASS_MOUNTAIN");
g_TERRAIN_PLAINS			= GetGameInfoIndex("Terrains", "TERRAIN_PLAINS");
g_TERRAIN_PLAINS_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_PLAINS_HILLS");
g_TERRAIN_PLAINS_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_PLAINS_MOUNTAIN");
g_TERRAIN_DESERT			= GetGameInfoIndex("Terrains", "TERRAIN_DESERT");
g_TERRAIN_DESERT_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_DESERT_HILLS");
g_TERRAIN_DESERT_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_DESERT_MOUNTAIN");
g_TERRAIN_TUNDRA			= GetGameInfoIndex("Terrains", "TERRAIN_TUNDRA");
g_TERRAIN_TUNDRA_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_TUNDRA_HILLS");
g_TERRAIN_TUNDRA_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_TUNDRA_MOUNTAIN");
g_TERRAIN_SNOW				= GetGameInfoIndex("Terrains", "TERRAIN_SNOW");
g_TERRAIN_SNOW_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_SNOW_HILLS");
g_TERRAIN_SNOW_MOUNTAIN		= GetGameInfoIndex("Terrains", "TERRAIN_SNOW_MOUNTAIN");
g_TERRAIN_COAST				= GetGameInfoIndex("Terrains", "TERRAIN_COAST");
g_TERRAIN_OCEAN				= GetGameInfoIndex("Terrains", "TERRAIN_OCEAN");
g_FEATURE_NONE				= -1;
g_FEATURE_FLOODPLAINS		= GetGameInfoIndex("Features", "FEATURE_FLOODPLAINS");
g_FEATURE_ICE				= GetGameInfoIndex("Features", "FEATURE_ICE");
g_FEATURE_JUNGLE			= GetGameInfoIndex("Features", "FEATURE_JUNGLE");
g_FEATURE_FOREST			= GetGameInfoIndex("Features", "FEATURE_FOREST");
g_FEATURE_OASIS				= GetGameInfoIndex("Features", "FEATURE_OASIS");
g_FEATURE_MARSH				= GetGameInfoIndex("Features", "FEATURE_MARSH");

-- mountain like natural wonders
g_FEATURE_EVEREST			= GetGameInfoIndex("Features", "FEATURE_EVEREST");
g_FEATURE_KILIMANJARO		= GetGameInfoIndex("Features", "FEATURE_KILIMANJARO");
g_FEATURE_PIOPIOTAHI		= GetGameInfoIndex("Features", "FEATURE_PIOPIOTAHI");
g_FEATURE_TORRES_DEL_PAINE	= GetGameInfoIndex("Features", "FEATURE_TORRES_DEL_PAINE");
g_FEATURE_TSINGY			= GetGameInfoIndex("Features", "FEATURE_TSINGY");
g_FEATURE_YOSEMITE			= GetGameInfoIndex("Features", "FEATURE_YOSEMITE");
g_FEATURE_PANTANAL			= GetGameInfoIndex("Features", "FEATURE_PANTANAL");  -- not flammable


-- flammable resources
g_RESOURCE_NONE				= -1;
g_RESOURCE_WHEAT			= GetGameInfoIndex("Resources", "RESOURCE_WHEAT");
g_RESOURCE_TOBACCO			= GetGameInfoIndex("Resources", "RESOURCE_TOBACCO");
g_RESOURCE_TEA				= GetGameInfoIndex("Resources", "RESOURCE_TEA");
g_RESOURCE_SILK				= GetGameInfoIndex("Resources", "RESOURCE_SILK");
g_RESOURCE_COTTON			= GetGameInfoIndex("Resources", "RESOURCE_COTTON");
g_RESOURCE_COCOA			= GetGameInfoIndex("Resources", "RESOURCE_COCOA");

-- ===========================================================================
-- KEY VARIABLES AND CONSTANTS
-- ===========================================================================

-- map and game parameters
local iMapWidth, iMapHeight, iMapSize = 0, 0, 0;
local iGameSpeedMultiplier = 100;
local iRNDConfigNumDis, iRNDConfigMagnitude, iRNDConfigRange = 100, 0, 0;

-- adjustment factor due to map size
-- empiric formula referencing STANDARD map size, as of now: =1.0*map_ratio^(-0.55)
local fMapProbAdj = 0.0; 


-- ===========================================================================
-- TABLE FUNCTIONS AND HELPERS (INC. TABLE OF PLOT INDICES)
-- ===========================================================================

-- check if 'value' exists in table 'pTable'; should work for any type of 'value' and table indices
function IsInTable(pTable:table, value)
	for _, data in pairs(pTable) do
		if data == value then return true; end
	end
	return false;
end


-- ===========================================================================
-- PLOT FUNCTIONS AND HELPERS
-- ===========================================================================

--[[
From MapUtilities:
- IsAdjacentToLand => plotTypes[i] ~= g_PLOT_TYPE_OCEAN  -- is Coast Water considered a land? => BEFORE MAP
- IsAdjacentToLandPlot => all sorrounding have testPlot:IsWater() ~= false
- IsAdjacentToRiver => at least one adjacentPlot:IsRiver()
- IsAdjacentToIce => featureType ~= nil and featureType == g_FEATURE_ICE
- AdjacentToSaltWater => testPlot:IsWater() and testPlot:IsLake() == false
- IsAdjacentToShallowWater => at least one terrainTypes[i] == g_TERRAIN_TYPE_COAST
- GenerateCoastalLandDataTable => all AdjacentToSaltWater are Coastal
--]]

-- table with new coors corresponding to given Direction
local tAdjCoors:table = {
	[DirectionTypes.DIRECTION_NORTHEAST] = { dx= 1, dy= 1 },  -- shifting +X, in some conditons dx=0 (rows with even Y-coor)
	[DirectionTypes.DIRECTION_EAST] 	 = { dx= 1, dy= 0 },
	[DirectionTypes.DIRECTION_SOUTHEAST] = { dx= 1, dy=-1 },  -- shifting +X, in some conditons dx=0
	[DirectionTypes.DIRECTION_SOUTHWEST] = { dx=-1, dy=-1 },  -- shifting -X, in some conditons dx=0 (rows with odd Y-coor)
	[DirectionTypes.DIRECTION_WEST]      = { dx=-1, dy= 0 },
	[DirectionTypes.DIRECTION_NORTHWEST] = { dx=-1, dy= 1 },  -- shifting -X, in some conditons dx=0
};

-- Returns coordinates (x,y) of a plot adjacent to the one tested in a specific direction
function GetAdjacentPlotXY(iX:number, iY:number, eDir:number)
	-- double-checking
	if tAdjCoors[eDir] == nil then
		print("ERROR: GetAdjacentXY() invalid direction - ", tostring(eDir));
		return iX, iY;
	end
	-- shifting X, in some conditons dx=-1 or dx=+1
	local idx = tAdjCoors[eDir].dx;
	if (eDir == DirectionTypes.DIRECTION_NORTHEAST or eDir ==  DirectionTypes.DIRECTION_SOUTHEAST) and (iY % 2 == 0) then idx = 0; end
	if (eDir == DirectionTypes.DIRECTION_NORTHWEST or eDir ==  DirectionTypes.DIRECTION_SOUTHWEST) and (iY % 2 == 1) then idx = 0; end
	-- get new coors
	local iAdjX = iX + idx;
	local iAdjY = iY + tAdjCoors[eDir].dy;
	-- wrap coordinates
	if iAdjX >= iMapWidth 	then iAdjX = 0; end
	if iAdjX < 0 			then iAdjX = iMapWidth-1; end
	if iAdjY >= iMapHeight 	then iAdjY = 0; end
	if iAdjY < 0 			then iAdjY = iMapHeight-1; end
	return iAdjX, iAdjY;
end

-- Returns Index of a plot adjacent to the one tested in a specific direction
function GetAdjacentPlotIndex(iIndex:number, eDir:number)
	local iAdjX, iAdjY = GetAdjacentPlotXY(iIndex % iMapWidth, math.floor(iIndex/iMapWidth), eDir);
	return iMapWidth * iAdjY + iAdjX;
end

-- Returns 2 Indices of plots adjacent to the one tested in a specific direction and direction clockwise
function GetAdjacentPlotTwoIndices(iIndex:number, eDir:number)
	-- first plot is easy
	local iFirstIndex = GetAdjacentPlotIndex(iIndex, eDir);
	-- second plot is little tricky
	local eClockDir = eDir + 1;
	if eClockDir == DirectionTypes.NUM_DIRECTION_TYPES then eClockDir = DirectionTypes.DIRECTION_NORTHEAST; end
	local iSecondIndex = GetAdjacentPlotIndex(iIndex, eClockDir)
	return iFirstIndex, iSecondIndex;
end

-- Returns 3 Indices of plots adjacent to the one tested in a specific direction and direction clockwise and anticlockwise
function GetAdjacentPlotThreeIndices(iIndex:number, eDir:number)
	-- first plot is easy
	local iFirstIndex = GetAdjacentPlotIndex(iIndex, eDir);
	-- second plot is little tricky
	local eClockDir = eDir + 1;
	if eClockDir == DirectionTypes.NUM_DIRECTION_TYPES then eClockDir = DirectionTypes.DIRECTION_NORTHEAST; end  -- 0
	local iSecondIndex = GetAdjacentPlotIndex(iIndex, eClockDir)
	-- third plot is little tricky
	local eAntiClockDir = eDir - 1;
	if eAntiClockDir == -1 then eAntiClockDir = DirectionTypes.DIRECTION_NORTHWEST; end  -- 5
	local iThirdIndex = GetAdjacentPlotIndex(iIndex, eAntiClockDir)
	return iFirstIndex, iSecondIndex, iThirdIndex;
end


-- Checks if plot is a Mountain including also Mountain-like natural wonders (EVEREST, KILIMANJARO, etc.)
function IsPlotMountain(plot:table)
	local eFeature = plot:GetFeatureType();
	if plot:IsMountain() or
		eFeature == g_FEATURE_EVEREST or eFeature == g_FEATURE_KILIMANJARO or
		eFeature == g_FEATURE_PIOPIOTAHI or eFeature == g_FEATURE_TORRES_DEL_PAINE or
		eFeature == g_FEATURE_TSINGY or eFeature == g_FEATURE_YOSEMITE then
		return true;
	end;
	return false;
end

-- Checks if plot is Flammable: forest, grass, Not flammable: jungle, tundra, ice, lake 
function IsPlotFlammable(plot:table)
	--dprint("FUNCAL IsPlotFlammable() (idx) (wat,mnt,ter,ft,res)", plot:GetIndex(), plot:IsWater(), plot:IsMountain(), plot:GetTerrainType(), plot:GetFeatureType(), plot:GetResourceType());
	-- first let's get rid of things surely not flammable
	if plot:IsWater() or IsPlotMountain(plot) or plot:GetFeatureType() == g_FEATURE_MARSH or plot:GetFeatureType() == g_FEATURE_PANTANAL or 
		plot:GetTerrainType() == g_TERRAIN_SNOW   or plot:GetTerrainType() == g_TERRAIN_SNOW_HILLS or
		plot:GetTerrainType() == g_TERRAIN_DESERT or plot:GetTerrainType() == g_TERRAIN_DESERT_HILLS or
		plot:GetTerrainType() == g_TERRAIN_TUNDRA or plot:GetTerrainType() == g_TERRAIN_TUNDRA_HILLS then return false; end
	-- now, what is flammable
	if plot:GetFeatureType() == g_FEATURE_FOREST or 
		plot:GetTerrainType() == g_TERRAIN_GRASS or plot:GetTerrainType() == g_TERRAIN_GRASS_HILLS or plot:GetTerrainType() == g_TERRAIN_GRASS_MOUNTAIN or
		-- some resource are flammable
		plot:GetResourceType() == g_RESOURCE_COCOA or plot:GetResourceType() == g_RESOURCE_COTTON or plot:GetResourceType() == g_RESOURCE_SILK or 
		plot:GetResourceType() == g_RESOURCE_TEA or plot:GetResourceType() == g_RESOURCE_TOBACCO or plot:GetResourceType() == g_RESOURCE_WHEAT then
		--dprint("  ...YES");
		return true;
	end
	return false;
end
function IsPlotIndexFlammable(iPlot:number)
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then return false; end
	return IsPlotFlammable(pPlot);
end

-- This can be used for Tsunami?
function ShiftPlotTypesBy(plotTypes, xshift, yshift)

	local g_iW, g_iH = Map.GetGridSize();

	if(xshift > 0 or yshift > 0) then
		local iWH = g_iW * g_iH;
		local buf = {};
		for i = 0, iWH do
			buf[i] = plotTypes[i];
		end
		
		for iDestY = 0, g_iH do
			for iDestX = 0, g_iW do
				local iDestI = g_iW * iDestY + iDestX;
				local iSourceX = (iDestX + xshift) % g_iW;
				local iSourceY = (iDestY + yshift) % g_iH;
				
				local iSourceI = g_iW * iSourceY + iSourceX

				plotTypes[iDestI] = buf[iSourceI]
			end
		end
	end
end

-- this can be use for starting plots that might depend on latitude (e.g. Tornado, Hurricane, Drougth)
function GetLatitudeAtPlot(variationFrac, iX, iY)

	local g_iW, g_iH = Map.GetGridSize();

	-- Terrain bands are governed by latitude.
	-- Returns a latitude value between 0.0 (tropical) and 1.0 (polar).
	local lat = math.abs((g_iH / 2) - iY) / (g_iH / 2);
	
	-- Adjust latitude using variation fractal, to roughen the border between bands:
	lat = lat + (128 - variationFrac:GetHeight(iX, iY))/(255.0 * 5.0);
	-- Limit to the range [0, 1]:
	lat = math.clamp(lat, 0, 1);
	
	return lat;
end


-- ===========================================================================
-- DEVASTATE AND REPORT FUNCTIONS
-- ===========================================================================

local bRealEffects = true;  -- set to FALSE to only simulate effects (no real damage will be applied)

EffectClasses = {
	EFFECT_NONE		   = 0,
	EFFECT_UNIT 	   = 1,
	EFFECT_IMPROVEMENT = 2,
	EFFECT_CITY 	   = 3,
	EFFECT_DISTRICT    = 4,
	EFFECT_BUILDING    = 5,
};

-- All data regarding effects of devastations will be kept in effect records:
local Effect_Record = {
	-- plot info
	Plot = 0,			-- what plot index
	Magnitude = 0,		-- what magnitude was applied
	OwnerID = 0,		-- who owns it (civ), it will be -1 if nobody
	OwnerCiv = "",		-- who owns it (civ) and takes effect, it will be "" if nobody
	OwnerCity = "",		-- who owns it (city), "" if nobody
	-- object info
	Class = 0,			-- see EffectClasses
	Object = nil,		-- object to apply effect
	ID = 0,				-- unique - could help destroy things, after that might become unusable
	Type = "",			-- e.g. BuildingType, UnitType, etc. must reference sth in DB since GameInfo will be used here
	Name = "",			-- name of the object
	OurOwn = false,		-- if plot or unit belongs to local player
	-- damage info
	IsDestroyed = false,-- if completely destroyed
	IsDamaged = true,	-- if not destroyed but damaged
	Damage = 0,			-- damage value (applicabe only to Units as of now)
	Desc = "",			-- effect short description
	DescLong = "",		-- effect long description (for debug?)
	-- specific class data
	UnitOwnerID = 0,	-- ID of player that owns the unit - need to destroy it
	UnitOwner = "",		-- if unit is on tile, it can be owned by somebody else
	--Population = 0,		-- city's population
};

-- constructor (1) empty record
-- constructor (2) we have plot and magnitude
-- constructor (3) we have an owner
function Effect_Record:new(iPlot:number, iMagnitude:number, eOwnerID:number, sOwnerCiv:string, sOwnerCity:string, sLocalOwner:string)
	dprint("FUNCAL Effect_Record:new() (plot,magn,pid,civ,cit,own)",iPlot,iMagnitude,eOwnerID,sOwnerCiv,sOwnerCity,sLocalOwner);
	local tObject = {};
	setmetatable(tObject, {__index = Effect_Record}); -- this should link a newly created object to table that acts as object class
	-- plot info
	tObject.Plot = 0;				-- what plot index
	tObject.Magnitude = 0;			-- what magnitude was applied
	tObject.OwnerID = -1;			-- who owns it (civ), it will be -1 if nobody
	tObject.OwnerCiv = "";			-- who owns it (civ) and takes affect, it will be "" if nobody
	tObject.OwnerCity = "";			-- who owns it (city), "" if nobody
	-- object info
	tObject.Class = EffectClasses.EFFECT_NONE;
	tObject.Object = nil;			-- object to apply effect
	tObject.ID = 0;					-- unique - could help destroy things, after that might become unusable
	tObject.Type = "";				-- e.g. BuildingType, UnitType, etc. must reference sth in DB since GameInfo will be used here
	tObject.Name = "";				-- name of the object
	tObject.OurOwn = false;			-- if plot/unit belongs to local player
	-- damage info
	tObject.IsDestroyed = false;	-- if completely destroyed
	tObject.IsDamaged = false;		-- if not destroyed but damaged
	tObject.Damage = 0;				-- damage value (applicabe only to Units as of now)
	tObject.Desc = "";				-- effect shor description
	tObject.DescLong = "";			-- effect long description (for debug?)
	-- specific class data
	tObject.UnitOwnerID = -1;		-- ID of player that owns the unit - need to destroy it
	tObject.UnitOwner = "";			-- if unit is on tile, it can be owned by somebody else
	--tObject.Population = 0;			-- city's population
	-- version (2) for plot initiation
	if iPlot ~= nil and iMagnitude ~= nil then
		tObject.Plot = iPlot;
		tObject.Magnitude = iMagnitude;
		-- version (3) for owned plot
		if eOwnerID ~= nil and sOwnerCiv ~= nil and sOwnerCity ~= nil then
			tObject.OwnerID = eOwnerID;
			tObject.OwnerCiv = sOwnerCiv;
			tObject.OwnerCity = sOwnerCity;
			tObject.OurOwn = (sOwnerCiv == sLocalOwner);
		end
	end
	return tObject;
end

-- debug
function Effect_Record:dshoweffect()
	dprint("FUNCAL Effect_Record:dshoweffect()");
	for k,v in pairs(self) do dprint("  (k,v)", k, v); end
end

-- function to generate desc on-the-fly; needed to properly handle 'unmet player' condition, also should be easier to apply changes if needed
function Effect_Record:GetDescription(eLocalPlayer:number, sLocalCiv:string)
end

-- this function will assign an object that later will be used in ApplyEffect()
function Effect_Record:AssignObject(eClass:number, pObject:table, sLocalOwner:string, eBuildingIndex:number)
	dprint("FUNCAL Effect_Record:AssignObject() (class,object,locciv,bidx)", eClass, pObject, sLocalOwner, eBuildingIndex);
	
	self.Class = eClass;
	self.Object = pObject;
	-- process basic object info based on its type
	if     eClass == EffectClasses.EFFECT_UNIT then
		-- pObject must be a Unit
		if pObject.TypeName ~= "Unit" then dprint("ERROR Effect_Record:AssignObject() object is not Unit"); return; end
		self.ID = pObject:GetID();
		self.UnitOwnerID = pObject:GetOwner();
		self.UnitOwner = PlayerConfigurations[self.UnitOwnerID]:GetCivilizationShortDescription();
		self.UnitOwner = Locale.Lookup(self.UnitOwner);
		self.OurOwn = (self.UnitOwner == sLocalOwner);
		self.Type = GameInfo.Units[pObject:GetType()].UnitType;
		self.Name = Locale.Lookup(pObject:GetName());
	elseif eClass == EffectClasses.EFFECT_IMPROVEMENT then
		-- pObject must be a Plot
		if pObject.TypeName ~= "Plot" then dprint("ERROR Effect_Record:AssignObject() object is not Plot"); return; end
		self.ID = self.Plot;  -- improvements don't have unique IDs - they belong to tiles
		local pImp = GameInfo.Improvements[pObject:GetImprovementType()];
		self.Type = pImp.ImprovementType;
		self.Name = Locale.Lookup(pImp.Name);
	elseif eClass == EffectClasses.EFFECT_CITY then
		-- pObject must be a City
		if pObject.TypeName ~= "City" then dprint("ERROR Effect_Record:AssignObject() object is not City"); return; end
		self.ID = pObject:GetID();
		self.Type = "(not used)";  -- to catch errors
		self.Name = Locale.Lookup(pObject:GetName());
		--self.Population = pObject:GetPopulation();
	elseif eClass == EffectClasses.EFFECT_DISTRICT then
		-- pObject must be a District
		if pObject.TypeName ~= "District" then dprint("ERROR Effect_Record:AssignObject() object is not District"); return; end
		self.ID = pObject:GetID();
		local pDis = GameInfo.Districts[pObject:GetType()];
		self.Type = pDis.DistrictType;
		self.Name = Locale.Lookup(pDis.Name);
	elseif eClass == EffectClasses.EFFECT_BUILDING then
		-- pObject must be a City, we also need building Index since buildings don't have unique IDs across the game
		if pObject.TypeName ~= "City" then dprint("ERROR Effect_Record:AssignObject() object is not City"); return; end
		self.ID = eBuildingIndex;
		self.Type = GameInfo.Buildings[eBuildingIndex].BuildingType;
		self.Name = Locale.Lookup(GameInfo.Buildings[eBuildingIndex].Name);
	else
		print("ERROR: Effect_Record:AssignObject() unknown object class", eClass);
		self.Class = EffectClasses.EFFECT_NONE;
		self.Object = nil;
	end
	dprint("  ...assigned (id,type,name)", self.ID, self.Type, self.Name);
	self:dshoweffect();
end


-- real devastation happens here
function Effect_Record:DamageObject()
	dprint("FUNCAL Effect_Record:DamageObject() id", self.ID);
	if bRealEffects then dprint("  -- REAL EFFECTS --"); else dprint("  -- SIMULATION --"); end
	-- process object based on its type
	if     self.Class == EffectClasses.EFFECT_UNIT then
	
		-- DAMAGE UNIT
		-- unit description is little different than others - it contains unit's owner
		-- must add check if it's us or if we met the civ
		local bHasMet = Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(self.UnitOwnerID);
		local sUnitOwner = Locale.Lookup("LOC_RNDINFO_UNKNOWN_CIV");
		if self.OurOwn then sUnitOwner = "[COLOR_Green]"..self.UnitOwner.."[ENDCOLOR]";  -- make it green
		elseif bHasMet then sUnitOwner = self.UnitOwner; end  -- we can show the name
		--local iDamage:number, iMaxDamage:number = self.Object:GetDamage(), self.Object:GetMaxDamage();  -- don't need iMaxDamage?
		local iNewDamage:number = self.Object:GetDamage() + self.Magnitude;
		if iNewDamage < self.Object:GetMaxDamage() then  -- wounded only
			dprint("  ...damaging unit (player,civ,id) (from,to)", self.UnitOwnerID, self.UnitOwner, self.ID, self.Object:GetDamage(), iNewDamage);
			if bRealEffects then self.Object:SetDamage(iNewDamage); end
			dprint("    ...checking result (id) (new)", self.Object:GetID(), self.Object:GetDamage());
			self.IsDamaged = true;
			--local unitOwner:string = self.UnitOwner;
			--if self.OurOwn then unitOwner = "[COLOR_Green]"..unitOwner.."[ENDCOLOR]"; end
			--self.Desc = self.Name.." ("..sUnitOwner..") [ICON_Pillaged] wounded for "..self.Magnitude.." HP";
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_WOUNDED", self.Name, sUnitOwner, self.Magnitude);
		else  -- it seems that the unit didn't survived the wounds
		
			-- KILL UNIT
			dprint("  ...destroying unit due to wounds (player,civ,unitid) (from,to)", self.UnitOwnerID, self.UnitOwner, self.ID, self.Object:GetMaxDamage(), iNewDamage);
			--if bRealEffects then UnitManager.Kill(self.UnitOwnerID, self.ID); end
			--if bRealEffects then UnitManager.Kill(self.Object); end
			Players[self.UnitOwnerID]:GetUnits():Destroy(self.Object);
			self.IsDestroyed = true;
			--self.Desc = self.Name.." ("..sUnitOwner..") [ICON_CheckFail] died because of the wounds";
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DIED_WOUNDS", self.Name, sUnitOwner);
						
		end
		
	elseif self.Class == EffectClasses.EFFECT_IMPROVEMENT then
	
		if (math.random(0,99) < self.Magnitude) then 
			-- check for Goody Huts - cannot be pillaged (nobody to repair them)
			if GameInfo.Improvements[self.Type].RemoveOnEntry == true then 
				dprint("  ...cannot pillage Entry-type improvements - call destroy instead");
				self:DestroyObject();
			else
				-- DAMAGE IMPROVEMENT
				dprint("  ...pillaging improvement at plot (idx,state)", self.Plot, self.Object:GetImprovementType());
				if bRealEffects then ImprovementBuilder.SetImprovementPillaged(self.Object, true); end
				dprint("    ...verify result manually at plot (idx,state)", self.Plot, self.Object:GetImprovementType());
				self.IsDamaged = true;
				self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_PILLAGED", self.Name);
			end
		else
			dprint("  ...the improvement survived!");
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_SURVIVED", self.Name);
		end
	
	elseif self.Class == EffectClasses.EFFECT_CITY then
	
		-- DAMAGE City
		-- cannot show sity's name if the owner has not been met
		local bHasMet = Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(self.OwnerID);
		local sName = Locale.Lookup("LOC_RNDINFO_UNKNOWN_CITY");
		if self.OurOwn then sName = "[COLOR_Green]"..self.Name.."[ENDCOLOR]";  -- make it green
		elseif bHasMet then sName = self.Name; end  -- we can show the name
		-- % function will not really work for small cites; Magnitude always shows the power - small cities gets should be wiped out [TODO]
		-- as for now population loss will be proortional to Magnitude i.e. 1 pop for 10 points - easy
		-- even the worst catastrophies will never kill entire city if it's big
		local iCurPop = self.Object:GetPopulation(); --, math.floor(self.Magnitude/10);
		local iPopLost = math.floor(iCurPop*self.Magnitude/(100+self.Magnitude));
		dprint("  ...damaging city - loss of population (name,pop,lost)", self.Name, iCurPop, iPopLost);
		if iPopLost >= iCurPop then iPopLost = iCurPop - 1; end  -- leave at least 1 pop
		if bRealEffects then self.Object:ChangePopulation((-1)*iPopLost); end
		dprint("    ...checking result (name,pop)", self.Object:GetName(), self.Object:GetPopulation());
		if iPopLost > 0 then
			self.IsDamaged = true;
			--self.Desc = sName.." [ICON_Pillaged] lost [COLOR_Red]"..iPopLost.."[ENDCOLOR] of its population";
			self.Desc = Locale.Lookup("LOC_RNDINFO_CITY_LOST_POP", sName, iPopLost);
		else
			--self.Desc = sName.." [ICON_CheckSuccess] survived with no population lost";
			self.Desc = Locale.Lookup("LOC_RNDINFO_CITY_SURVIVED", sName);
		end
		
	elseif self.Class == EffectClasses.EFFECT_DISTRICT then
	
		-- DAMAGE DISTRICT
		--dprint("  ...damaging district (destroyed if no buildings left and healh < 0)");
		local iTotDmg:number = 0;
		dprint("  ...damaging district (type,id) (in,out) (maxin,maxout)",
							self.Object:GetType(), self.Object:GetID(),
							self.Object:GetDamage(DefenseTypes.DISTRICT_GARRISON), self.Object:GetDamage(DefenseTypes.DISTRICT_OUTER),
							self.Object:GetMaxDamage(DefenseTypes.DISTRICT_GARRISON), self.Object:GetMaxDamage(DefenseTypes.DISTRICT_OUTER));
		-- we're not going to destroy a district (YET), so there's no need to check if damage will exceed max damage
		-- check if there's inside protection
		if self.Object:GetMaxDamage(DefenseTypes.DISTRICT_GARRISON) > 0 then 
			if bRealEffects then self.Object:ChangeDamage(DefenseTypes.DISTRICT_GARRISON, 2*self.Magnitude); end-- inside def starts with 200, need DefType parameter FIRST
			iTotDmg = iTotDmg + 2*self.Magnitude;
		end
		-- check if there's outside protection
		if self.Object:GetMaxDamage(DefenseTypes.DISTRICT_OUTER) > 0 then  
			if bRealEffects then self.Object:ChangeDamage(DefenseTypes.DISTRICT_OUTER, 1*self.Magnitude); end  -- out def are Walls actually (+150) [TODO - might analyze Walls at start to see how Magnitude relates]
			iTotDmg = iTotDmg + 1*self.Magnitude;
		end
		dprint("    ...checking result (type,id,tot) (in,out)",
							self.Object:GetType(), self.Object:GetID(), iTotDmg,
							self.Object:GetDamage(DefenseTypes.DISTRICT_GARRISON), self.Object:GetDamage(DefenseTypes.DISTRICT_OUTER));
		if iTotDmg > 0 then
			self.IsDamaged = true;
			--self.Desc = self.Name.." [ICON_Pillaged] damaged for "..iTotDmg.." HP";
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DAMAGED_HP", self.Name, iTotDmg);
		else
			dprint("  ...the district survived!");
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_SURVIVED", self.Name);
		end
		
	elseif self.Class == EffectClasses.EFFECT_BUILDING then
		-- cannot pillage ALL non-destroyed buildings, must use randomization
		-- they will be pillaged with Magnitude probabbility
		--if (math.random(0,99) < self.Magnitude) and GameInfo.Buildings[self.Type].IsWonder == false then  -- cannot pillage Wonders
		if (math.random(0,99) < self.Magnitude) then  -- actually, Wonders CAN be pillaged

			-- DAMAGE BUILDING
			dprint("  ...pillaging building (city,name,state)", self.Object:GetName(), self.Name, self.Object:GetBuildings():IsPillaged(self.ID));
			if bRealEffects then self.Object:GetBuildings():SetPillaged(self.ID, true); end
			dprint("    ...checking result (city,name,state)", self.Object:GetName(), self.Name, self.Object:GetBuildings():IsPillaged(self.ID));
			self.IsDamaged = true;
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_PILLAGED", self.Name); --.." [ICON_Pillaged] pillaged";			
			
		else
			dprint("  ...the building survived!");
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_SURVIVED", self.Name); --.." [ICON_CheckSuccess] survived";
		end
	else
		print("ERROR: Effect_Record:DamageObject() unknown object class", self.Class);
	end
	-- generate info
	--self.DescLong = self.Desc.." (id="..self.ID..",type="..self.Type..")";
	dprint("  ...effect info (bool,desc,long)", self.IsDamaged, self.Desc, self.DescLong);
end


-- real devastation happens here
function Effect_Record:DestroyObject()
	dprint("FUNCAL Effect_Record:DestroyObject() id", self.ID);
	if bRealEffects then dprint("  -- REAL EFFECTS --"); else dprint("  -- SIMULATION --"); end
	-- process object based on its type
	if     self.Class == EffectClasses.EFFECT_UNIT then
	
		-- KILL UNIT
		local bHasMet = Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(self.UnitOwnerID);
		local sUnitOwner = Locale.Lookup("LOC_RNDINFO_UNKNOWN_CIV");
		if self.OurOwn then sUnitOwner = "[COLOR_Green]"..self.UnitOwner.."[ENDCOLOR]";  -- make it green
		elseif bHasMet then sUnitOwner = self.UnitOwner; end  -- we can show the name
		dprint("  ...destroying unit (player,civ,unitid,plot,state)", self.UnitOwnerID, self.UnitOwner, self.ID, self.Plot, Units.GetUnitByIndexInPlot(self.ID, self.Plot));
		--if bRealEffects then UnitManager.Kill(self.UnitOwnerID, self.ID); end
		--if bRealEffects then UnitManager.Kill(self.Object); end
		Players[self.UnitOwnerID]:GetUnits():Destroy(self.Object);
		dprint("    ...checking result (unitid,plot,state)", self.ID, self.Plot, Units.GetUnitByIndexInPlot(self.ID, self.Plot));
		self.IsDestroyed = true;
		--local unitOwner:string = self.UnitOwner;
		--if self.OurOwn then unitOwner = "[COLOR_Green]"..unitOwner.."[ENDCOLOR]"; end
		self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_KILLED", self.Name, sUnitOwner); --..") [ICON_CheckFail] killed";
		
	elseif self.Class == EffectClasses.EFFECT_IMPROVEMENT then
	
		-- DESTROY IMPROVEMENT
		dprint("  ...destroying improvement at plot (idx,state)", self.Plot, self.Object:GetImprovementType());
		if bRealEffects then ImprovementBuilder.SetImprovementType(self.Object, -1); end
		dprint("    ...checking result at plot (idx,state)", self.Plot, self.Object:GetImprovementType());
		self.IsDestroyed = true;
		self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DESTROYED", self.Name); --.." [ICON_CheckFail] destroyed";
		
	elseif self.Class == EffectClasses.EFFECT_CITY then
		dprint("  ...cannot destroy city - calling damage instead");
		self:DamageObject();		
	elseif self.Class == EffectClasses.EFFECT_DISTRICT then
		dprint("  ...cannot destroy district - call damage instead");
		self:DamageObject();
	elseif self.Class == EffectClasses.EFFECT_BUILDING then
		-- check for Capital buildings - cannot be destroyed only damaged
		-- also Wonders cannot be destroyed - only damaged
		if GameInfo.Buildings[self.Type].Capital == true or GameInfo.Buildings[self.Type].IsWonder == true then 
			dprint("  ...cannot destroy Wonders and Capital-only buildings - call damage instead");
			self:DamageObject();
		else
		
			-- DESTROY BUILDING
			dprint("  ...destroying building (city,name,state)", self.Object:GetName(), self.Name, self.Object:GetBuildings():HasBuilding(self.ID));
			if bRealEffects then self.Object:GetBuildings():RemoveBuilding(self.ID); end  -- this function has a DELAY - don't know why - but it's removing
			dprint("    ...checking result (city,name,state)", self.Object:GetName(), self.Name, self.Object:GetBuildings():HasBuilding(self.ID));
			self.IsDestroyed = true;			
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DESTROYED", self.Name); --.." [ICON_CheckFail] destroyed";
			
		end
	else
		print("ERROR: Effect_Record:DestroyObject() unknown object class", self.Class);
	end
	-- generate info
	--self.DescLong = self.Desc.." (id="..self.ID..",type="..self.Type..")";
	dprint("  ...effect info (bool,desc,long)", self.IsDestroyed, self.Desc, self.DescLong);
end


-- this function will apply either DamageObject() or DestroyObject() depending on Magnitude and randomization
function Effect_Record:ApplyEffect()
	dprint("FUNCAL Effect_Record:ApplyEffect() id", self.ID);
	self:dshoweffect();
	-- first we check for Destroy - it happens in Magnitude/2 percent cases
	if math.random(0,99) < math.floor(self.Magnitude/2) then
		self:DestroyObject();
	else
		self:DamageObject();
	end
end


-- ===========================================================================
-- DISASTER FUNCTIONS AND DEFINITIONS
-- ===========================================================================

--[[
GenerateEvent - returns starting plots, magnitude, etc. or nils , type etc.
ExecuteEvent - will use devastate plot
ContinueEvent - will use devastate plot with different data
FinishEvent - this could create another one
--]]

-- will be exposed
local tDisasterTypes:table = {};

-- ===========================================================================
-- Helper functions

--[[----------------------------------------------------------------------------
-- Gutenberg-Richter relation
-- This function returns a random number from the set of {0,10,20,...,90,100}
-- The probabbility of a number is such that it simulates Gutenberg-Richter relation
-- i.e. lower numbers are more common, higher are rare and the relation is logarithmic
-- The numbers are calculated in Excel and can be changed easily. Here we use a parametric
-- table to speed up the process. The below table will produce results so the probability
-- will be as follow:
--    0-10 45%
--   20-30 25%
--   40-50 15%
--   60-70  8%
--   80-90  5%
--     100  1,5%
-- Each disaster will have then 2 parameters: BaseMagnitude and MagnitudeMax
-- that will be used to scale the magnitude, so it will fall into desired range
--                            0,  10,  20,  30,  40,  50,  60,  70,  80,  90,  100
--]]
local tParamsForGutRich = {2579,4523,5987,7091,7923,8550,9022,9378,9646,9848,10000};
-- formula for table: sum(exp(-0,02829*magnitude+7,86))
function GetRandomMagnitudeWithGutenbergRichter()
	local iR = math.random(0,9999);
	local iM = 0;
	for _,par in pairs(tParamsForGutRich) do
		if iR < par then return iM; end
		iM = iM + 10;
	end
	print("ERROR: GetRandomMagnitudeWithGutenbergRichter() could not find magnitude");
	return 0;
end

--[[
In Lua, it is trivial to implement prototypes, using the idea of inheritance. More specifically,
if we have two objects a and b, all we have to do to make b a prototype for a is
   setmetatable(a, {__index = b})
After that, a looks up in b for any operation that it does not have. To see b as the class of object a is not much more than a change in terminology.
--]]

-- ===========================================================================
-- DISASTER OBJECT
-- ===========================================================================
local Disaster_Object = { Type = "DISASTER_TYPE" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
	--[[
	-- properties
	Disaster_Object.Type = "DISASTER_TYPE";					-- identifies DB record with parameters - MUST be defined in the code for each Disaster
	Disaster_Object.Name = "Disaster";						-- later change to LOC_ or load from Database?
	Disaster_Object.Description = "Disaster Description";	-- later change to LOC_ or load from Database?
	Disaster_Object.Icon = "ICON_CIVILIZATION_UNKNOWN";		-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Object.BaseProbability = 0;					-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Object.DeltaProbability = 0;					-- range min/max
	Disaster_Object.BaseMagnitude = 50;						-- magnitude of a devastation applied for a tile that started the event
	Disaster_Object.MagnitudeMax = 100;						-- max magnitude; final Magnitude should be rounded up to 5 to look nicely
	Disaster_Object.MagnitudeMin = 20;						-- if gets less than that it's either bumped or stopped; even the slightest event should cause at least some damage, so default is to bump
	Disaster_Object.MaxTurns = 1;							-- how many turns lasts
	Disaster_Object.ColorNow = "COLOR_RED";					-- color for the current event
	Disaster_Object.ColorRisk = "COLOR_RED";				-- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Object.ColorHistoric = "COLOR_RED";			-- color for a historic event
	Disaster_Object.Sound = "Disaster_Event_Siren";			-- sound for the event
	-- specific params - meaning may differ for each disaster
	Disaster_Object.Range = 0;
	Disaster_Object.MagnitudeChange = 0;
	-- operational data - must be initialized when game starts
	Disaster_Object.StartPlots = {};						-- Indices of possible starting plots
	Disaster_Object.NumStartPlots = 0;						-- Num of possible starting plots
	Disaster_Object.StartingPlot = -1;						-- Index of the starting plot for a new event
	Disaster_Object.StartingMagnitude = -1;					-- Event's power
	Disaster_Object.HistoricEvents = {};					-- FOR FUTURE - list of old events
	Disaster_Object.HistoricStartingPlots = {};				-- a list of indices of starting plots from old events
	--]]
	
-- loads parameters from database
-- this function assumes that .Type is properly set for a disaster bo be initialized
function Disaster_Object:InitializeDisaster()
	dprint("FUNCAL Disaster_Object:InitializeDisaster() (type)", self.Type);
	local tDisaster = GameInfo.RNDDisasters[self.Type];
	if tDisaster == nil then
		print("ERROR: Disaster_Object:InitializeDisaster() cannot load parameters for", self.Type);
		return;
	end
	-- loaded from DB
	self.Type = tDisaster.DisasterType;
	self.Name = tDisaster.Name;								-- later change to LOC_
	self.Description = tDisaster.Description;				-- later change to LOC_
	self.Icon = tDisaster.Icon;								-- graphical sign of the disaster; [TODO - ICON_ATLAS_CIVILIZATIONS]
	self.Range = math.max(tDisaster.Range+iRNDConfigRange, 1);  -- determines the area of the disaster - meaning varies for each type; should be at least 1
	self.BaseProbability  = tDisaster.BaseProbability;		-- probability of an event for a tile that can spawn it per one turn * 1000000
	self.DeltaProbability = tDisaster.DeltaProbability;		-- range min/max
	self.BaseMagnitude = math.max(tDisaster.BaseMagnitude+iRNDConfigMagnitude, 20); -- magnitude of a devastation applied for a tile that started the event; should be at least 20
	self.MagnitudeMax  = math.max(tDisaster.MagnitudeMax +iRNDConfigMagnitude, 20);	-- max magnitude; final Magnitude should be rounded up to 5 to look nicely
	self.MagnitudeMin  = tDisaster.MagnitudeMin;			-- if gets less than that it's either bumped or stopped; even the slightest event should cause at least some damage, so default is to bump
	self.MagnitudeChange = tDisaster.MagnitudeChange;		-- magnitude change for each tile far away from starting tile
	self.MaxTurns = tDisaster.MaxTurns;						-- how many turns lasts (NOT USED)
	self.ColorNow = tDisaster.ColorNow;						-- color for the current event
	self.ColorRisk = tDisaster.ColorRisk;					-- color for a risk area; will get them later using UI.GetColorValue()
	self.ColorHistoric = tDisaster.ColorHistoric;			-- color for a historic event (NOT USED)
	self.Sound = tDisaster.Sound;							-- sound for the event
	-- operational data - SOME WILL BE LOADED IF SAVE FILES WILL BE IMPLEMENTED
	self.StartPlots = {};									-- Indices of possible starting plots
	self.NumStartPlots = 0;									-- Num of possible starting plots
	self.StartingPlot = -1;									-- Index of the starting plot for a new event
	self.StartingMagnitude = -1;							-- Event's power
	self.HistoricEvents = {};								-- FOR FUTURE - list of old events
	self.HistoricStartingPlots = {};						-- a list of indices of starting plots from old events
end

-- changes parameters according to the map size of num of disasters
function Disaster_Object:AdjustProbability(fAdjustment:number)
	--self.BaseProbability = math.max(math.floor(self.BaseProbability * fAdjustment), 1);  -- we need at least 1/1000000 chance
	self.BaseProbability = math.floor(self.BaseProbability * fAdjustment);  -- we allow for 0 probabbility if someone will want to play a modpack that includes RND but doesn't want RND itself (Ananse's request)
	self.DeltaProbability = math.floor(self.DeltaProbability * fAdjustment);
end

function Disaster_Object:CheckIfHappened(bReallyCheck:boolean)
	-- generic as of now, later some specific events might require specific function at Disater level
	--dprint("FUNCAL Disaster_Object:CheckIfHappened() (type,base,delta,plots,real)", self.Name, self.BaseProbability, self.DeltaProbability, self.NumStartPlots, bReallyCheck);
	local iRealBase = self.BaseProbability + math.random(-self.DeltaProbability, self.DeltaProbability);  -- base is little randomized each turn different
	local iRealProb = iRealBase * self.NumStartPlots;  -- its *1000000
	local iRand = math.random(1000000);
	--dprint("  ...checking (realbase,realprob,rand,out)", iRealBase, iRealProb, iRand, (iRealProb>iRand));
	if (bReallyCheck == false) or (iRealProb > iRand) then
		-- generate a starting plot and magnitude
		self.StartingPlot = self.StartPlots[math.random(self.NumStartPlots)];  -- indices are numbered from 1..n and random returns 1..n
		--self.StartingMagnitude = self.BaseMagnitude + math.random( -self.MagnitudeMax, self.MagnitudeMax );  -- Base +/- random Range
		-- here the use of new algorithm based on Gutenberg-Richter relation
		local iRandMagn = GetRandomMagnitudeWithGutenbergRichter();
		local iMagnitude = iRandMagn * (self.MagnitudeMax - self.BaseMagnitude)/100;  -- scale to desired range
		iMagnitude = math.floor((iMagnitude*2)/10)*5;  -- round down to multiple of 5
		self.StartingMagnitude = self.BaseMagnitude + iMagnitude;
		--dprint("  ...HAPPENED @(idx,x,y)", self.StartingPlot, Map.GetPlotByIndex(self.StartingPlot):GetX(), Map.GetPlotByIndex(self.StartingPlot):GetY());
		dprint("  ...HAPPENED @(idx,x,y) with magn(base,rand,start)",
			self.StartingPlot, self.StartingPlot%iMapWidth, math.floor(self.StartingPlot/iMapWidth),
			self.BaseMagnitude, iRandMagn, self.StartingMagnitude);
		return true;  -- TRUE if not-really-checking or really happened
	else
		--dprint("  ...NO EVENT");
		return false;
	end
end

-- this function is used in "directional" Disasters i.e. ones that can act in 6 diffrent directions
-- the direction with highest impact should be chosen for an event
function Disaster_Object:CountAffectedTilesInDirection(iSeedPlot:number, eDirection:number)
	-- generic functions that should be replaced by specific Disasters - for reference only
	return 0;
end

-- this function will output data to tTheDisaster
-- it assumes that StartingPlot and StartingMagnitude has been set and tTheDisaster initialized
-- DEFAULT BEHAVIOR: generate tiles around StartingPlot in Range and assign lowering Magnitude
function Disaster_Object:EventGenerate(pDisaster:table)  -- need a poiner because it is defined later, also might be for multiple-event generation later
	dprint("FUNCAL Disaster_Object:EventGenerate() (plot,range,magn,change)", self.StartingPlot, self.Range, self.StartingMagnitude, self.MagnitudeChange)
	-- obligatory - register type and add Starting Plot
	pDisaster.DisasterType = self;
	pDisaster.StartingPlot = self.StartingPlot;
	pDisaster.StartingMagnitude = self.StartingMagnitude;
	table.insert(pDisaster.Plots, self.StartingPlot);
	table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
	-- then Range rings with lowering Magnitude (but not less than MagnitudeMin)
	local pStartingPlot = Map.GetPlotByIndex(self.StartingPlot);
	for distance = 1, self.Range, 1 do  -- go through all rings
		local iMagnitude = math.max(self.StartingMagnitude + self.MagnitudeChange * distance, self.MagnitudeMin);  -- we assume that MagnitudeChange is negative
		for plot in RND.PlotRingIterator(pStartingPlot, distance) do  -- we don't need starting sector nor anticlockwise - just the ring
			--dprint("  ...(ring): adding plot (idx,x,y,magn)", distance, plot:GetIndex(), plot:GetX(), plot:GetY(), iMagnitude);
			table.insert(pDisaster.Plots, plot:GetIndex());
			table.insert(pDisaster.Magnitudes, iMagnitude);
		end
	end
end	

--[[	-- this function will output data to tTheDisaster
		-- it assumes that StartingPlot has been set and tTheDisaster initialized
		-- generate 6 tiles and assign event's magnitude
		--local iMagnitude = self.BaseMagnitude + math.random( -self.MagnitudeMax, self.MagnitudeMax );  -- Base +/- random Range
		--dprint("  ...name of magnitude", self.Name, iMagnitude);
		pDisaster.DisasterType = self;
		-- first - register and add Starting Plot
		--for k,v in pairs(pDisaster) do dprint(" pDisaster", k, v); end
		--table.insert(pDisaster.StartingPlots, self.StartingPlot);
		pDisaster.StartingPlot = self.StartingPlot;
		pDisaster.StartingMagnitude = self.StartingMagnitude;
		table.insert(pDisaster.Plots, self.StartingPlot);
		table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
		-- then adjacent ones
		local pStartPlot = Map.GetPlotByIndex(self.StartingPlot);
		local iX, iY = pStartPlot:GetX(), pStartPlot:GetY();
		for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
			local newPlot = Map.GetAdjacentPlot(iX, iY, direction);
			--dprint("  ...adding plot (idx,x,y,magn)", newPlot:GetIndex(), newPlot:GetX(), newPlot:GetY(), self.StartingMagnitude);
			table.insert(pDisaster.Plots, newPlot:GetIndex());
			table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
		end
--]]

-- main function to apply effects
-- will go through all plots
function Disaster_Object:EventExecute(tTheDisaster:table) -- so it can be called from tTheDisaster as well
end

-- ===========================================================================
-- EARTHQUAKE
-- ===========================================================================
local Disaster_Earthquake = { Type = "DISASTER_EARTHQUAKE" };		-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Earthquake, {__index = Disaster_Object});
tDisasterTypes.Disaster_Earthquake = Disaster_Earthquake;	
--[[
	-- properties
	Disaster_Earthquake.Name = "Earthquake";						-- later change to LOC_ or load from Database?
	Disaster_Earthquake.Description = "Earthquake Description";		-- later change to LOC_ or load from Database?
	Disaster_Earthquake.Icon = "ICON_CIVILIZATION_PRESLAV";			-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Earthquake.BaseProbability = 250;						-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Earthquake.DeltaProbability = 50;						-- range min/max
	Disaster_Earthquake.BaseMagnitude = 50;							-- magnitude of a devastation applied for a tile that started the event
	Disaster_Earthquake.MagnitudeMax = 100;
	Disaster_Earthquake.MagnitudeMin = 20;							-- if gets less than that it's either bumped or stopped
	Disaster_Earthquake.MaxTurns = 1;								-- how many turns lasts
	Disaster_Earthquake.ColorNow = "COLOR_DISASTER_EARTHQUAKE";		-- color for the current event
	Disaster_Earthquake.ColorRisk = "COLOR_DISASTER_EARTHQUAKE_RISK"; 	-- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Earthquake.ColorHistoric = "COLOR_PLAYER_RED";			-- color for a historic event
	-- specific params
	Disaster_Earthquake.Range = 3;								-- 0 means - number of rings depends on magnitude
	Disaster_Earthquake.MagnitudeChange = -10;					-- the further from epicenter, the lower magnitude
	-- operational data - must be initialized when game starts
	Disaster_Earthquake.StartPlots = {};
	Disaster_Earthquake.NumStartPlots = 0;
	Disaster_Earthquake.StartingPlot = -1;						-- Index of the starting plot for a new event
	Disaster_Earthquake.StartingMagnitude = -1;					-- Event's power
	Disaster_Earthquake.HistoricEvents = {};					-- FOR FUTURE - list of old events
	Disaster_Earthquake.HistoricStartingPlots = {};				-- a list of indices of starting plots from old events
--]]
-- methods
function Disaster_Earthquake:CheckPlotForPossibleStart(pCheckPlot:table)
	-- hills and mountains are possible starts
	if not (pCheckPlot:IsHills() or IsPlotMountain(pCheckPlot)) then return; end
	-- ...but should eliminate lonely mountains or hills for sure
	local iAdjacentMountain = 0;
	local iX, iY = pCheckPlot:GetX(), pCheckPlot:GetY();
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if testPlot ~= nil and (testPlot:IsHills() or IsPlotMountain(testPlot)) then
			iAdjacentMountain = iAdjacentMountain + 1;
		end
	end
	-- mountains must be close to each other, at least adjacent to 2 other; this will eliminate lonely ones and very short mountain ranges
	if iAdjacentMountain < 2 then return; end
	-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
	--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Earthquake");
	table.insert(self.StartPlots, pCheckPlot:GetIndex());
	self.NumStartPlots = self.NumStartPlots+1;
end
	

-- ===========================================================================
-- FLOOD
-- ===========================================================================
local Disaster_Flood = { Type = "DISASTER_FLOOD" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Flood, {__index = Disaster_Object});
tDisasterTypes.Disaster_Flood = Disaster_Flood;	
--[[
	-- properties
	Disaster_Flood.Name = "Flood";							-- later change to LOC_ or load from Database?
	Disaster_Flood.Description = "Flood Description";		-- later change to LOC_ or load from Database?
	Disaster_Flood.Icon = "ICON_CIVILIZATION_LISBON";		-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Flood.BaseProbability = 70;					-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Flood.DeltaProbability = 20;					-- range min/max
	Disaster_Flood.BaseMagnitude = 30;						-- magnitude of a devastation applied for a tile that started the event
	Disaster_Flood.MagnitudeMax = 70;	
	Disaster_Flood.MagnitudeMin = 20;						-- if gets less than that it's either bumped or stopped
	Disaster_Flood.MaxTurns = 1;							-- how many turns lasts
	Disaster_Flood.ColorNow = "COLOR_DISASTER_FLOOD";		-- color for the current event
	Disaster_Flood.ColorRisk = "COLOR_DISASTER_FLOOD_RISK"; -- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Flood.ColorHistoric = "COLOR_PLAYER_RED";		-- color for a historic event
	-- specific params
	Disaster_Flood.Range = 2;								-- starting plot + adjacent river + 2 rings of flow around it
	Disaster_Flood.MagnitudeChange = -5;					-- the further from epicenter, the lower magnitude
	-- operational data - must be initialized when game starts
	Disaster_Flood.StartPlots = {};
	Disaster_Flood.NumStartPlots = 0;
	Disaster_Flood.StartingPlot = -1;						-- Index of the starting plot for a new event
	Disaster_Flood.StartingMagnitude = -1;					-- Event's power
	Disaster_Flood.HistoricEvents = {};						-- FOR FUTURE - list of old events
	Disaster_Flood.HistoricStartingPlots = {};				-- a list of indices of starting plots from old events
--]]
-- methods
function Disaster_Flood:CheckPlotForPossibleStart(pCheckPlot:table)
	-- Rivers - but only if another river is adjacent, and Lakes [Lakes are very rare anyway]
	-- Seems that Rivers always come in pairs or even threes due to the fact that they flow between tiles actually
	if pCheckPlot:IsRiver() or pCheckPlot:IsLake() then
		-- also, must remove plots with Mountain
		if not IsPlotMountain(pCheckPlot) then 
			-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
			--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Flood");
			table.insert(self.StartPlots, pCheckPlot:GetIndex());
			self.NumStartPlots = self.NumStartPlots+1;
		end
	end
end
-- this function will output data to tTheDisaster
-- it assumes that StartingPlot and StartingMagnitude has been set and tTheDisaster initialized
-- starting plot + adjacent river + Range rings of flow around it
function Disaster_Flood:EventGenerate(pDisaster:table)
	dprint("FUNCAL Disaster_Flood:EventGenerate() (plot,range,magn,change)", self.StartingPlot, self.Range, self.StartingMagnitude, self.MagnitudeChange)
	-- obligatory - register type and add Starting Plot
	pDisaster.DisasterType = self;
	pDisaster.StartingPlot = self.StartingPlot;
	pDisaster.StartingMagnitude = self.StartingMagnitude;
	table.insert(pDisaster.Plots, self.StartingPlot);
	table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
	-- special case for Flood - second starting plot [LAKE - SOME EXTRA TREATMENT]
	-- this can be any (random) adjacent River or Lake tile
	local iSecondStartingPlot = -1;  -- 1-tile lakes case!
	-- we'll start from random direction and find first River or Lake plot
	local iRandDir = math.random(0,DirectionTypes.NUM_DIRECTION_TYPES-1); 
	dprint("  ...looking for 2nd starting plot near (x,y)", self.StartingPlot%iMapWidth, math.floor(self.StartingPlot/iMapWidth));
	for direction = iRandDir, iRandDir + DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do  
		--local testPlot = Map.GetAdjacentPlot(
		--						self.StartingPlot%iMapWidth,
		--						math.floor(self.StartingPlot/iMapWidth),
		--						direction % DirectionTypes.NUM_DIRECTION_TYPES);
		local iAdjPlot = GetAdjacentPlotIndex(self.StartingPlot, direction % DirectionTypes.NUM_DIRECTION_TYPES);
		local testPlot = Map.GetPlotByIndex(iAdjPlot);
		dprint("    ...at (dir) there is (river,lake) ", direction % DirectionTypes.NUM_DIRECTION_TYPES, testPlot:IsRiver(), testPlot:IsLake());
		if testPlot ~= nil and (testPlot:IsRiver() or testPlot:IsLake()) then
			iSecondStartingPlot = testPlot:GetIndex();
			break;
		end
	end
	-- check if 2nd plot exists (1-tile lake case)
	if iSecondStartingPlot ~= -1 then
		dprint("  ...found 2nd starting plot (idx,x,y)", iSecondStartingPlot, iSecondStartingPlot%iMapWidth, math.floor(iSecondStartingPlot/iMapWidth));
		table.insert(pDisaster.Plots, iSecondStartingPlot);
		table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
	end
	-- now flooding begins
	local tFloodedPlots = {};  -- temp table - will hold plots that are flooded already (current ring)
	table.insert(tFloodedPlots, self.StartingPlot);
	if iSecondStartingPlot ~= -1 then table.insert(tFloodedPlots, iSecondStartingPlot); end
	local tTestPlots = {};  -- temp table - will hold plots that have potential (next ring)
	local iDistance = 0;
	-- for each ring we must go through flooded tiles and check if any adjacent tile can be also flooded
	while iDistance < self.Range do  -- will not go here if Range = 0
		local iMagnitude = math.max(self.StartingMagnitude + (iDistance+1) * self.MagnitudeChange, self.MagnitudeMin);  -- anticipated next ring magnitute
		for _, index in pairs(tFloodedPlots) do
			-- try to flood all adjacent tiles
			for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
				local iAdjPlot = GetAdjacentPlotIndex(index, direction);
				-- need to add check if not HILLS, etc. - testing ALL terrain
				local pAdjPlot = Map.GetPlotByIndex(iAdjPlot);
				if not IsInTable(tTestPlots, iAdjPlot) and  -- not flooded in new ring
					not IsInTable(pDisaster.Plots, iAdjPlot) and  -- not flooded in previous rings
					pAdjPlot ~= nil and pAdjPlot:IsFlatlands() then  -- cannot flood hills and mountains
					--not pAdjPlot:IsMountain() and
					--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot, iAdjPlot%iMapWidth, math.floor(iAdjPlot/iMapWidth), iMagnitude);
					table.insert(tTestPlots, iAdjPlot);
					table.insert(pDisaster.Plots, iAdjPlot);
					table.insert(pDisaster.Magnitudes, iMagnitude);
				end
			end
		end
		-- now the flood goes to the next Ring
		iDistance = iDistance + 1;
		tFloodedPlots = tTestPlots;
		tTestPlots = {};
	end
end
	

-- ===========================================================================
-- METEOR
-- ===========================================================================
local Disaster_Meteor = { Type = "DISASTER_METEOR" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Meteor, {__index = Disaster_Object});
tDisasterTypes.Disaster_Meteor = Disaster_Meteor;
--[[
	-- properties
	Disaster_Meteor.
	Disaster_Meteor.Name = "Meteor";							-- later change to LOC_ or load from Database?
	Disaster_Meteor.Description = "Meteor Description";			-- later change to LOC_ or load from Database?
	Disaster_Meteor.Icon = "ICON_CIVILIZATION_BUENOS_AIRES";	-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Meteor.BaseProbability = 7;						-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Meteor.DeltaProbability = 1;						-- range min/max
	Disaster_Meteor.BaseMagnitude = 70;							-- magnitude of a devastation applied for a tile that started the event
	Disaster_Meteor.MagnitudeMax = 100;	
	Disaster_Meteor.MaxTurns = 1;								-- how many turns lasts
	Disaster_Meteor.ColorNow = "COLOR_DISASTER_METEOR";			-- color for the current event
	Disaster_Meteor.ColorRisk = "COLOR_DISASTER_METEOR_RISK"; 	-- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Meteor.ColorHistoric = "COLOR_PLAYER_RED";			-- color for a historic event
	-- specific params
	Disaster_Meteor.Range = 2;									-- 2 rings around starting plot
	Disaster_Meteor.MagnitudeChange = -10;
	-- operational data - must be initialized when game starts
	Disaster_Meteor.StartPlots = {};
	Disaster_Meteor.NumStartPlots = 0;
	Disaster_Meteor.StartingPlot = -1;							-- Index of the starting plot for a new event
	Disaster_Meteor.StartingMagnitude = -1;						-- Event's power
	Disaster_Meteor.HistoricEvents = {};						-- FOR FUTURE - list of old events
	Disaster_Meteor.HistoricStartingPlots = {};					-- a list of indices of starting plots from old events
--]]
-- methods
function Disaster_Meteor:CheckPlotForPossibleStart(pCheckPlot:table)
	-- basically Everywhere but we don't want to have empty hits in the game
	-- the condition will be: land (inc. lakes) or coastal water
	if pCheckPlot:GetTerrainType() == g_TERRAIN_COAST or
		pCheckPlot:IsLake() or (not pCheckPlot:IsWater()) then 
		--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Meteor");
		table.insert(self.StartPlots, pCheckPlot:GetIndex());
		self.NumStartPlots = self.NumStartPlots+1;
	end
end


-- ===========================================================================
-- TORNADO
-- ===========================================================================
local Disaster_Tornado = { Type = "DISASTER_TORNADO" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Tornado, {__index = Disaster_Object});
tDisasterTypes.Disaster_Tornado = Disaster_Tornado;
--[[
	-- properties
	Disaster_Tornado.
	Disaster_Tornado.Name = "Tornado";							-- later change to LOC_ or load from Database?
	Disaster_Tornado.Description = "Tornado Description";		-- later change to LOC_ or load from Database?
	Disaster_Tornado.Icon = "ICON_CIVILIZATION_YEREVAN";		-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Tornado.BaseProbability = 50;						-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Tornado.DeltaProbability = 20;						-- range min/max
	Disaster_Tornado.BaseMagnitude = 40;						-- magnitude of a devastation applied for a tile that started the event
	Disaster_Tornado.MagnitudeMax = 70;		
	Disaster_Tornado.MaxTurns = 1;								-- how many turns lasts
	Disaster_Tornado.ColorNow = "COLOR_DISASTER_TORNADO";		-- color for the current event
	Disaster_Tornado.ColorRisk = "COLOR_DISASTER_TORNADO_RISK"; -- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Tornado.ColorHistoric = "COLOR_PLAYER_RED";		-- color for a historic event
	-- specific params
	Disaster_Tornado.Range = 5;									-- a straight line of Range tiles
	Disaster_Tornado.MagnitudeChange = -5;						-- each next turn is weaker
	-- operational data - must be initialized when game starts
	Disaster_Tornado.StartPlots = {};
	Disaster_Tornado.NumStartPlots = 0;
	Disaster_Tornado.StartingPlot = -1;							-- Index of the starting plot for a new event
	Disaster_Tornado.StartingMagnitude = -1;					-- Event's power
	Disaster_Tornado.HistoricEvents = {};						-- FOR FUTURE - list of old events
	Disaster_Tornado.HistoricStartingPlots = {};				-- a list of indices of starting plots from old events
--]]
-- methods
function Disaster_Tornado:CheckPlotForPossibleStart(pCheckPlot:table)
	-- Flat Land only... [DONE] must check for Natural Wonders Mountain-like as well
	--if not pCheckPlot:IsFlatlands() then return false; end
	if pCheckPlot:IsWater() or pCheckPlot:IsHills() or IsPlotMountain(pCheckPlot) then return false; end
	-- ...but it has to have at least 2-3 other flat tiles adjacent - so it can move!
	local iAdjacentFlatlands = 0;
	local iX, iY = pCheckPlot:GetX(), pCheckPlot:GetY();
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if not( testPlot == nil or testPlot:IsWater() or testPlot:IsHills() or IsPlotMountain(testPlot)) then
			iAdjacentFlatlands = iAdjacentFlatlands + 1;
		end
	end
	-- register plot if conditions check
	if iAdjacentFlatlands > 2 then
		-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
		--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Tornado");
		table.insert(self.StartPlots, pCheckPlot:GetIndex());
		self.NumStartPlots = self.NumStartPlots+1;
	end
end
-- helper function to check which direction might be the most destructive
function Disaster_Tornado:CountAffectedTilesInDirection(iSeedPlot:number, eDirection:number)
	--dprint("FUNCAL Disaster_Tornado:CountAffectedTilesInDirection() (idx,x,y,dir)", iSeedPlot, iSeedPlot%iMapWidth, math.floor(iSeedPlot/iMapWidth), eDirection)
	local iNumAffectedTiles = 0;
	local pPlot = Map.GetPlotByIndex(iSeedPlot);
	if not pPlot:IsFlatlands() then
		print("ERROR: Disaster_Tornado:CountAffectedTilesInDirection() called with not flat seed tile");
	end
	local iDistance = 0;
	local iAffectedPlot = iSeedPlot;
	-- let's simulate a straight line
	while iDistance < self.Range do  -- will not go here if Range = 0
		local iAdjPlot = GetAdjacentPlotIndex(iAffectedPlot, eDirection);
		pPlot = Map.GetPlotByIndex(iAdjPlot);
		-- first check if we need to turn
		if pPlot ~= nil and (pPlot:IsHills() or IsPlotMountain(pPlot)) then
			-- select which direction?
			local eClockDir = eDirection + 1;
			if eClockDir == DirectionTypes.NUM_DIRECTION_TYPES then eClockDir = DirectionTypes.DIRECTION_NORTHEAST; end  -- 0
			local iAdjPlot1 = GetAdjacentPlotIndex(iAffectedPlot, eClockDir)
			local pAdjPlot1 = Map.GetPlotByIndex(iAdjPlot1);
			local eAntiClockDir = eDirection - 1;
			if eAntiClockDir == -1 then eAntiClockDir = DirectionTypes.DIRECTION_NORTHWEST; end  -- 5
			local iAdjPlot2 = GetAdjacentPlotIndex(iAffectedPlot, eAntiClockDir)
			local pAdjPlot2 = Map.GetPlotByIndex(iAdjPlot2);
			if pAdjPlot1 ~= nil and pAdjPlot1:IsFlatlands() then
				iAdjPlot = iAdjPlot1; eDirection = eClockDir;
			elseif pAdjPlot2 ~= nil and pAdjPlot2:IsFlatlands() then
				iAdjPlot = iAdjPlot2; eDirection = eAntiClockDir;
			end
		end
		-- if we can move that's easy
		pPlot = Map.GetPlotByIndex(iAdjPlot);
		if pPlot == nil or not pPlot:IsFlatlands() then break; end  -- cannot move any further
		--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot, iAdjPlot%iMapWidth, math.floor(iAdjPlot/iMapWidth));
		iAffectedPlot = iAdjPlot;
		iNumAffectedTiles = iNumAffectedTiles + 1;
		iDistance = iDistance + 1;
	end
	return iNumAffectedTiles;
end
-- this function will output data to tTheDisaster
-- it assumes that StartingPlot and StartingMagnitude has been set and tTheDisaster initialized
-- a straight line of Range tiles
function Disaster_Tornado:EventGenerate(pDisaster:table)
	dprint("FUNCAL Disaster_Tornado:EventGenerate() (plot,range,magn,change)", self.StartingPlot, self.Range, self.StartingMagnitude, self.MagnitudeChange)
	-- obligatory - register type and add Starting Plot
	pDisaster.DisasterType = self;
	pDisaster.StartingPlot = self.StartingPlot;
	pDisaster.StartingMagnitude = self.StartingMagnitude;
	table.insert(pDisaster.Plots, self.StartingPlot);
	table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
	-- chech in which direction to go
	dprint("  ...looking for the best direction");
	local iMaxAffectedTiles = 0;
	local eDirection = DirectionTypes.NUM_DIRECTION_TYPES;
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local iAffectedTiles = self:CountAffectedTilesInDirection(self.StartingPlot, direction);
		dprint("  ...in (dir) there are (n) affected tiles", direction, iAffectedTiles);
		if  iAffectedTiles > iMaxAffectedTiles then
			iMaxAffectedTiles = iAffectedTiles;
			eDirection = direction;
		end
	end
	if eDirection == DirectionTypes.NUM_DIRECTION_TYPES then
		print("ERROR: Disaster_Tornado:EventGenerate() could not find a direction for tornado - no flat land around?");
		return;
	end
	-- go towards the chosen direction (straight line)
	local iAffectedPlot = self.StartingPlot;
	local pPlot:table = {};
	local iDistance = 0;
	while iDistance < self.Range do  -- will not go here if Range = 0
		local iAdjPlot = GetAdjacentPlotIndex(iAffectedPlot, eDirection);
		pPlot = Map.GetPlotByIndex(iAdjPlot);
		local iMagnitude = math.max(self.StartingMagnitude + iDistance * self.MagnitudeChange, self.MagnitudeMin);
		-- first check if we need to turn
		if pPlot ~= nil and (pPlot:IsHills() or IsPlotMountain(pPlot)) then
			-- select which direction?
			local eClockDir = eDirection + 1;
			if eClockDir == DirectionTypes.NUM_DIRECTION_TYPES then eClockDir = DirectionTypes.DIRECTION_NORTHEAST; end  -- 0
			local iAdjPlot1 = GetAdjacentPlotIndex(iAffectedPlot, eClockDir)
			local pAdjPlot1 = Map.GetPlotByIndex(iAdjPlot1);
			local eAntiClockDir = eDirection - 1;
			if eAntiClockDir == -1 then eAntiClockDir = DirectionTypes.DIRECTION_NORTHWEST; end  -- 5
			local iAdjPlot2 = GetAdjacentPlotIndex(iAffectedPlot, eAntiClockDir)
			local pAdjPlot2 = Map.GetPlotByIndex(iAdjPlot2);
			if pAdjPlot1 ~= nil and pAdjPlot1:IsFlatlands() then
				iAdjPlot = iAdjPlot1; eDirection = eClockDir;  -- go clockwise
			elseif pAdjPlot2 ~= nil and pAdjPlot2:IsFlatlands() then
				iAdjPlot = iAdjPlot2; eDirection = eAntiClockDir;  -- go anticlockwise
			end
		end
		-- if we can move that's easy
		pPlot = Map.GetPlotByIndex(iAdjPlot);
		if pPlot == nil or not pPlot:IsFlatlands() then break; end  -- cannot move any further
		--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot, iAdjPlot%iMapWidth, math.floor(iAdjPlot/iMapWidth), iMagnitude);
		table.insert(pDisaster.Plots, iAdjPlot);
		table.insert(pDisaster.Magnitudes, iMagnitude);
		iAffectedPlot = iAdjPlot;
		iDistance = iDistance + 1;
	end
end


-- ===========================================================================
-- TSUNAMI
-- ===========================================================================
local Disaster_Tsunami = { Type = "DISASTER_TSUNAMI" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Tsunami, {__index = Disaster_Object});
tDisasterTypes.Disaster_Tsunami = Disaster_Tsunami;
--[[
	-- properties
	Disaster_Tsunami.
	Disaster_Tsunami.Name = "Tsunami";							-- later change to LOC_ or load from Database?
	Disaster_Tsunami.Description = "Tsunami Description";		-- later change to LOC_ or load from Database?
	Disaster_Tsunami.Icon = "ICON_CIVILIZATION_EGYPT";			-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Tsunami.BaseProbability = 80;						-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Tsunami.DeltaProbability = 20;						-- range min/max
	Disaster_Tsunami.BaseMagnitude = 60;						-- magnitude of a devastation applied for a tile that started the event
	Disaster_Tsunami.MagnitudeMax = 100;						-- it has to travel 2 tiles to get to land, so it will be much weaker
	Disaster_Tsunami.MaxTurns = 1;								-- how many turns lasts
	Disaster_Tsunami.ColorNow = "COLOR_DISASTER_TSUNAMI";		-- color for the current event
	Disaster_Tsunami.ColorRisk = "COLOR_DISASTER_TSUNAMI_RISK"; -- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Tsunami.ColorHistoric = "COLOR_PLAYER_RED";		-- color for a historic event
	-- specific params
	Disaster_Tsunami.Range = 5;									-- it moves in the direction of a nearest land up to x tiles
	Disaster_Tsunami.MagnitudeChange = -10;						-- the further, the weaker
	-- operational data - must be initialized when game starts
	Disaster_Tsunami.StartPlots = {};
	Disaster_Tsunami.NumStartPlots = 0;
	Disaster_Tsunami.StartingPlot = -1;							-- Index of the starting plot for a new event
	Disaster_Tsunami.StartingMagnitude = -1;					-- Event's power
	Disaster_Tsunami.HistoricEvents = {};						-- FOR FUTURE - list of old events
	Disaster_Tsunami.HistoricStartingPlots = {};				-- a list of indices of starting plots from old events
--]]
-- methods
--[[ Version 1 - coastal water tiles 1-tile from the land
function Disaster_Tsunami:CheckPlotForPossibleStart(pCheckPlot:table)
	-- will be more difficult, let's start with an easy version - Sea plots but not directly close to Coast
	if not pCheckPlot:IsWater() then return; end  -- land cannot generate tsunami
	--if pCheckPlot:GetFeatureType() == g_FEATURE_ICE then return; end  -- we can also rule out ice caps
	if pCheckPlot:GetFeatureType() ~= g_FEATURE_NONE then return; end  -- actually ALL Features on water must be taken out (e.g. Ice, Barrier Reef, Galapagos Islands)
	if pCheckPlot:GetTerrainType() ~= g_TERRAIN_COAST then return; end  -- for simplicity - nor can Ocean (too far from land)
	-- ...but it also cannot be directly adjacent to Coast or Ice
	local iX, iY = pCheckPlot:GetX(), pCheckPlot:GetY();
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if testPlot ~= nil and (testPlot:IsCoastalLand() or testPlot:GetFeatureType() == g_FEATURE_ICE) then return; end  -- no need to process any further
	end
	-- all conditions met
	-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
	--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Tsunami");
	table.insert(self.StartPlots, pCheckPlot:GetIndex());
	self.NumStartPlots = self.NumStartPlots+1;
end
--]]
-- Version 2 - deep ocean tiles with 2 tiles of water to the nearest land - MIGHT ADJUST TO MAP SIZE IF NECESSARY
-- TODO - eliminate 1-tile Islands from NearestLand
function Disaster_Tsunami:CheckPlotForPossibleStart(pCheckPlot:table)
	if not pCheckPlot:IsWater() then return; end  -- land cannot generate tsunami
	if pCheckPlot:GetFeatureType() ~= g_FEATURE_NONE then return; end  -- ALL Features on water must be taken out (e.g. Ice, Barrier Reef, Galapagos Islands)
	if pCheckPlot:GetTerrainType() ~= g_TERRAIN_OCEAN then return; end  -- only deep ocean can generate tsunami
	-- ...but it needs to be 2 or 3 tiles from the land
	local iX, iY = pCheckPlot:GetX(), pCheckPlot:GetY();
	local pLand = pCheckPlot:GetNearestLandPlot();
	if pLand == nil then print("ERROR Disaster_Tsunami:CheckPlotForPossibleStart() cannot find Land"); return; end
	local iDist = Map.GetPlotDistance(iX, iY, pLand:GetX(), pLand:GetY());
	if iDist ~= 3 then return; end
	-- also, exclude tiles close to ICE (never heard of sub-polar tsunami)
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if testPlot ~= nil and testPlot:GetFeatureType() == g_FEATURE_ICE then return; end
	end
	-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
	--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Tsunami");
	table.insert(self.StartPlots, pCheckPlot:GetIndex());
	self.NumStartPlots = self.NumStartPlots+1;
end
-- helper function to check which direction might be the most destructive
function Disaster_Tsunami:CountAffectedTilesInDirection(iSeedPlot:number, eDirection:number)
	--dprint("FUNCAL Disaster_Tsunami:CountAffectedTilesInDirection() (idx,x,y,dir)", iSeedPlot, iSeedPlot%iMapWidth, math.floor(iSeedPlot/iMapWidth), eDirection)
	local iNumLandTiles = 0;
	local tWavedPlots = {};  -- temp table - will hold plots that already have been affected by the wave (current ring)
	local tTestPlots = {};  -- temp table - will hold plots that have potential (next ring)
	table.insert(tWavedPlots, iSeedPlot);  -- we'll start with initial one, as Ring 0
	local pPlot = Map.GetPlotByIndex(iSeedPlot);
	if not pPlot:IsWater() then
		print("ERROR: Disaster_Tsunami:CountAffectedTilesInDirection() called with Land seed tile");
	end
	local iDistance = 0;
	-- let's simulate a wave
	while iDistance < self.Range do  -- will not go here if Range = 0
		-- now we go for each plot to check and generate new waves from it
		for _, index in pairs(tWavedPlots) do
			-- try to go with wave to adjacent tiles
			local iAdjPlot1, iAdjPlot2, iAdjPlot3 = GetAdjacentPlotThreeIndices(index, eDirection);
			-- helper - checks the next plot and counts it if not already counted nor counted in previous rings
			local function ProcessAdjacentPlot(iAdjPlot:number)
				if IsInTable(tTestPlots, iAdjPlot) or IsInTable(tWavedPlots, iAdjPlot) then return; end
				table.insert(tTestPlots, iAdjPlot);
				pPlot = Map.GetPlotByIndex(iAdjPlot);
				-- modified function - counts also water resources!
				if pPlot == nil or (pPlot:IsWater() and pPlot:GetResourceCount()==0) then return; end
				--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot, iAdjPlot%iMapWidth, math.floor(iAdjPlot/iMapWidth));
				iNumLandTiles = iNumLandTiles + 1;
			end
			ProcessAdjacentPlot(iAdjPlot1);
			ProcessAdjacentPlot(iAdjPlot2);
			ProcessAdjacentPlot(iAdjPlot3);			
			--[[
			-- process 1st plot
			if not( IsInTable(tTestPlots, iAdjPlot1) or IsInTable(tWavedPlots, iAdjPlot1) ) then 
				table.insert(tTestPlots, iAdjPlot1);
				pPlot = Map.GetPlotByIndex(iAdjPlot1);
				--if not (pPlot == nil or pPlot:IsWater()) then
				-- modified function - count also water resources!
				if pPlot ~= nil and ( (not pPlot:IsWater()) or (pPlot:GetResourceCount()>0) ) then
					--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot1, iAdjPlot1%iMapWidth, math.floor(iAdjPlot1/iMapWidth));
					iNumLandTiles = iNumLandTiles + 1;
				end
			end
			-- process 2nd plot
			if not( IsInTable(tTestPlots, iAdjPlot2) or IsInTable(tWavedPlots, iAdjPlot2) ) then
				table.insert(tTestPlots, iAdjPlot2);
				pPlot = Map.GetPlotByIndex(iAdjPlot2);
				--if not (pPlot == nil or pPlot:IsWater()) then
				-- modified function - count also water resources!
				if pPlot ~= nil and ( (not pPlot:IsWater()) or (pPlot:GetResourceCount()>0) ) then
					--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot2, iAdjPlot2%iMapWidth, math.floor(iAdjPlot2/iMapWidth));
					iNumLandTiles = iNumLandTiles + 1;
				end
			end
			-- process 3rd plot
			if not( IsInTable(tTestPlots, iAdjPlot3) or IsInTable(tWavedPlots, iAdjPlot3) ) then
				table.insert(tTestPlots, iAdjPlot3);
				pPlot = Map.GetPlotByIndex(iAdjPlot3);
				--if not (pPlot == nil or pPlot:IsWater()) then
				-- modified function - count also water resources!
				if pPlot ~= nil and ( (not pPlot:IsWater()) or (pPlot:GetResourceCount()>0) ) then
					--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot3, iAdjPlot3%iMapWidth, math.floor(iAdjPlot3/iMapWidth));
					iNumLandTiles = iNumLandTiles + 1;
				end
			end
			--]]
		end
		-- now the fire goes to the next Ring
		iDistance = iDistance + 1;
		tWavedPlots = tTestPlots;
		tTestPlots = {};
	end
	return iNumLandTiles;
end
-- this function will output data to tTheDisaster
-- it assumes that StartingPlot and StartingMagnitude has been set and tTheDisaster initialized
-- it moves in the direction of a nearest land up to x tiles
function Disaster_Tsunami:EventGenerate(pDisaster:table)
	dprint("FUNCAL Disaster_Tsunami:EventGenerate() (plot,range,magn,change)", self.StartingPlot, self.Range, self.StartingMagnitude, self.MagnitudeChange)
	-- obligatory - register type and add Starting Plot
	pDisaster.DisasterType = self;
	pDisaster.StartingPlot = self.StartingPlot;
	pDisaster.StartingMagnitude = self.StartingMagnitude;
	table.insert(pDisaster.Plots, self.StartingPlot);
	table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
	-- now find out to which direction the wave should go
	dprint("  ...looking for the best direction");
	local iMaxLandTiles = 0;
	local eDirection = DirectionTypes.NUM_DIRECTION_TYPES;
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local iLandTiles = self:CountAffectedTilesInDirection(self.StartingPlot, direction);
		dprint("  ...in (dir) there are (n) land tiles", direction, iLandTiles);
		if  iLandTiles > iMaxLandTiles then
			iMaxLandTiles = iLandTiles;
			eDirection = direction;
		end
	end
	if eDirection == DirectionTypes.NUM_DIRECTION_TYPES then
		print("ERROR: Disaster_Tsunami:EventGenerate() could not find a wave direction - no land around?");
		return;
	end
	-- now process the selected wave going into eDirection
	local tWavedPlots = {};  -- temp table - will hold plots that already have been affected by the wave (current ring)
	local tTestPlots = {};  -- temp table - will hold plots that have potential (next ring)
	table.insert(tWavedPlots, self.StartingPlot);  -- we'll start with initial one, as Ring 0
	local iDistance = 0;
	while iDistance < self.Range do  -- will not go here if Range = 0
		local iMagnitude = math.max(self.StartingMagnitude + (iDistance+1) * self.MagnitudeChange, self.MagnitudeMin);  -- anticipated usage
		-- not we go for each plot to check and generate new waves from it
		for _, index in pairs(tWavedPlots) do
			-- try to go with wave to adjacent tiles
			local iAdjPlot1, iAdjPlot2, iAdjPlot3 = GetAdjacentPlotThreeIndices(index, eDirection);
			-- helper - checks the next plot and registers it if not already reagistered nor affected in previous rings
			local function ProcessAdjacentPlot(iAdjPlot)
				local pPlot = Map.GetPlotByIndex(iAdjPlot);
				if IsInTable(tTestPlots, iAdjPlot) or IsInTable(tWavedPlots, iAdjPlot) or pPlot == nil or IsPlotMountain(pPlot) or pPlot:GetFeatureType() == g_FEATURE_ICE then return ; end
				--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot, iAdjPlot%iMapWidth, math.floor(iAdjPlot/iMapWidth), iMagnitude);
				table.insert(tTestPlots, iAdjPlot);
				table.insert(pDisaster.Plots, iAdjPlot);
				table.insert(pDisaster.Magnitudes, iMagnitude);
			end
			ProcessAdjacentPlot(iAdjPlot1);
			ProcessAdjacentPlot(iAdjPlot2);
			ProcessAdjacentPlot(iAdjPlot3);
			--[[
			-- process 1st plot [ADD ADDITIONAL VALIDATIONS LATER]
			local pPlot = Map.GetPlotByIndex(iAdjPlot1);
			if not (IsInTable(tTestPlots, iAdjPlot1) or IsInTable(tWavedPlots, iAdjPlot1) or pPlot == nil or IsPlotMountain(pPlot) or pPlot:GetFeatureType() == g_FEATURE_ICE) then
				--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot1, iAdjPlot1%iMapWidth, math.floor(iAdjPlot1/iMapWidth), iMagnitude);
				table.insert(tTestPlots, iAdjPlot1);
				table.insert(pDisaster.Plots, iAdjPlot1);
				table.insert(pDisaster.Magnitudes, iMagnitude);
			end
			-- process 2nd plot [ADD ADDITIONAL VALIDATIONS LATER]
			pPlot = Map.GetPlotByIndex(iAdjPlot2);
			if not (IsInTable(tTestPlots, iAdjPlot2) or IsInTable(tWavedPlots, iAdjPlot2) or pPlot == nil or IsPlotMountain(pPlot) or pPlot:GetFeatureType() == g_FEATURE_ICE) then
				--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot2, iAdjPlot2%iMapWidth, math.floor(iAdjPlot2/iMapWidth), iMagnitude);
				table.insert(tTestPlots, iAdjPlot2);
				table.insert(pDisaster.Plots, iAdjPlot2);
				table.insert(pDisaster.Magnitudes, iMagnitude);
			end
			-- process 3rd plot [ADD ADDITIONAL VALIDATIONS LATER]
			pPlot = Map.GetPlotByIndex(iAdjPlot3);
			if not (IsInTable(tTestPlots, iAdjPlot3) or IsInTable(tWavedPlots, iAdjPlot3) or pPlot == nil or IsPlotMountain(pPlot) or pPlot:GetFeatureType() == g_FEATURE_ICE) then
				--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot3, iAdjPlot3%iMapWidth, math.floor(iAdjPlot3/iMapWidth), iMagnitude);
				table.insert(tTestPlots, iAdjPlot3);
				table.insert(pDisaster.Plots, iAdjPlot3);
				table.insert(pDisaster.Magnitudes, iMagnitude);
			end
			--]]
		end
		-- now the fire goes to the next Ring
		iDistance = iDistance + 1;
		tWavedPlots = tTestPlots;
		tTestPlots = {};
	end
end

	
-- ===========================================================================
-- VOLCANO
-- ===========================================================================
local Disaster_Volcano = { Type = "DISASTER_VOLCANO" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Volcano, {__index = Disaster_Object});
tDisasterTypes.Disaster_Volcano = Disaster_Volcano;
--[[
	-- properties
	Disaster_Volcano.
	Disaster_Volcano.Name = "Volcano";							-- later change to LOC_ or load from Database?
	Disaster_Volcano.Description = "Volcano Description";		-- later change to LOC_ or load from Database?
	Disaster_Volcano.Icon = "ICON_CIVILIZATION_NORWAY";			-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Volcano.BaseProbability = 380;						-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Volcano.DeltaProbability = 100;					-- range min/max
	Disaster_Volcano.BaseMagnitude = 60;						-- magnitude of a devastation applied for a tile that started the event
	Disaster_Volcano.MagnitudeMax = 90;	
	Disaster_Volcano.MaxTurns = 1;								-- how many turns lasts
	Disaster_Volcano.ColorNow = "COLOR_DISASTER_VOLCANO";		-- color for the current event
	Disaster_Volcano.ColorRisk = "COLOR_DISASTER_VOLCANO_RISK"; -- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Volcano.ColorHistoric = "COLOR_PLAYER_RED";		-- color for a historic event
	-- specific params
	Disaster_Volcano.Range = 1;									-- starting plot + 2 rings around are affected
	Disaster_Volcano.MagnitudeChange = -10;						-- all tiles affected the same
	-- operational data - must be initialized when game starts
	Disaster_Volcano.StartPlots = {};
	Disaster_Volcano.NumStartPlots = 0;
	Disaster_Volcano.StartingPlot = -1;							-- Index of the starting plot for a new event
	Disaster_Volcano.StartingMagnitude = -1;					-- Event's power
	Disaster_Volcano.HistoricEvents = {};						-- FOR FUTURE - list of old events
	Disaster_Volcano.HistoricStartingPlots = {};				-- a list of indices of starting plots from old events
--]]
-- methods
function Disaster_Volcano:CheckPlotForPossibleStart(pCheckPlot:table)
	-- only mountains are possible starts -- we EXCLUDE NATURAL WONDER type mountains
	if pCheckPlot:IsMountain() then
		-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
		--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Volcano");
		table.insert(self.StartPlots, pCheckPlot:GetIndex());
		self.NumStartPlots = self.NumStartPlots+1;
	end
end


-- ===========================================================================
-- WILDFIRE
-- ===========================================================================
local Disaster_Wildfire = { Type = "DISASTER_WILDFIRE" };					-- identifies DB record with parameters - MUST be defined in the code for each Disaster
setmetatable(Disaster_Wildfire, {__index = Disaster_Object});
tDisasterTypes.Disaster_Wildfire = Disaster_Wildfire;
--[[
	-- properties
	Disaster_Wildfire.
	Disaster_Wildfire.Name = "Wildfire";							-- later change to LOC_ or load from Database?
	Disaster_Wildfire.Description = "Wildfire Description";			-- later change to LOC_ or load from Database?
	Disaster_Wildfire.Icon = "ICON_CIVILIZATION_HONG_KONG";			-- later load from Database, test: will use ICON_ATLAS_CIVILIZATIONS
	Disaster_Wildfire.BaseProbability = 140;						-- probability of an event for a tile that can spawn it per one turn * 1000000
	Disaster_Wildfire.DeltaProbability = 40;						-- range min/max
	Disaster_Wildfire.BaseMagnitude = 40;							-- magnitude of a devastation applied for a tile that started the event
	Disaster_Wildfire.MagnitudeMax = 80;
	Disaster_Wildfire.MaxTurns = 5;									-- how many turns lasts
	Disaster_Wildfire.ColorNow = "COLOR_DISASTER_WILDFIRE";			-- color for the current event
	Disaster_Wildfire.ColorRisk = "COLOR_DISASTER_WILDFIRE_RISK";	-- color for a risk area; will get them later using UI.GetColorValue()
	Disaster_Wildfire.ColorHistoric = "COLOR_PLAYER_RED";			-- color for a historic event
	-- specific params
	Disaster_Wildfire.Range = 4;									-- a triangle sector of 4 tile range
	Disaster_Wildfire.MagnitudeChange = -5;							-- must fire out by itself, each tile is affected the same
	-- operational data - must be initialized when game starts
	Disaster_Wildfire.StartPlots = {};
	Disaster_Wildfire.NumStartPlots = 0;
	Disaster_Wildfire.StartingPlot = -1;							-- Index of the starting plot for a new event
	Disaster_Wildfire.StartingMagnitude = -1;						-- Event's power
	Disaster_Wildfire.HistoricEvents = {};							-- FOR FUTURE - list of old events
	Disaster_Wildfire.HistoricStartingPlots = {};					-- a list of indices of starting plots from old events
--]]
function Disaster_Wildfire:CheckPlotForPossibleStart(pCheckPlot:table)
	if not IsPlotFlammable(pCheckPlot) then return; end
	-- ...but it has to have at least 3 other flammable adjacent so it can move
	local iAdjacentFlammable = 0;
	local iX, iY = pCheckPlot:GetX(), pCheckPlot:GetY();
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot = Map.GetAdjacentPlot(iX, iY, direction);
		if testPlot ~= nil and IsPlotFlammable(testPlot) then
			iAdjacentFlammable = iAdjacentFlammable + 1;
		end
	end
	if iAdjacentFlammable > 2 then
		-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
		--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Wildfire");
		table.insert(self.StartPlots, pCheckPlot:GetIndex());
		self.NumStartPlots = self.NumStartPlots+1;
	end
end
-- helper function to check which direction might be the most destructive
function Disaster_Wildfire:CountAffectedTilesInDirection(iSeedPlot:number, eDirection:number)
	--dprint("FUNCAL Disaster_Wildfire:CountAffectedTilesInDirection() (idx,x,y,dir)", iSeedPlot, iSeedPlot%iMapWidth, math.floor(iSeedPlot/iMapWidth), eDirection)
	local iNumAffectedTiles = 0;
	local tAffectedPlots = {};  -- temp table - will hold plots that already have been affected (current ring)
	local tTestPlots = {};  -- temp table - will hold plots that have potential (next ring)
	table.insert(tAffectedPlots, iSeedPlot);  -- we'll start with initial one, as Ring 0
	
	local iDistance = 0;
	-- let's simulate a wave
	while iDistance < self.Range do  -- will not go here if Range = 0
		-- now we go for each plot to check and generate new waves from it
		for _, index in pairs(tAffectedPlots) do
			-- try to go with wave to adjacent tiles
			local iAdjPlot1, iAdjPlot2 = GetAdjacentPlotTwoIndices(index, eDirection);
			-- process 1st plot
			if not IsInTable(tTestPlots, iAdjPlot1) and IsPlotIndexFlammable(iAdjPlot1) then
				table.insert(tTestPlots, iAdjPlot1);
				--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot1, iAdjPlot1%iMapWidth, math.floor(iAdjPlot1/iMapWidth));
				iNumAffectedTiles = iNumAffectedTiles + 1;
				
			end
			-- process 2nd plot
			if not IsInTable(tTestPlots, iAdjPlot2) and IsPlotIndexFlammable(iAdjPlot2) then
				table.insert(tTestPlots, iAdjPlot2);
				--dprint("  ...(ring): counting plot (idx,x,y)", iDistance, iAdjPlot2, iAdjPlot2%iMapWidth, math.floor(iAdjPlot2/iMapWidth));
				iNumAffectedTiles = iNumAffectedTiles + 1;
			end
		end
		-- now the fire goes to the next Ring
		iDistance = iDistance + 1;
		tAffectedPlots = tTestPlots;
		tTestPlots = {};
	end
	return iNumAffectedTiles;
end
-- this function will output data to tTheDisaster
-- it assumes that StartingPlot and StartingMagnitude has been set and tTheDisaster initialized
-- a triangle sector of Range tiles
function Disaster_Wildfire:EventGenerate(pDisaster:table)
	dprint("FUNCAL Disaster_Wildfire:EventGenerate() (plot,range,magn,change)", self.StartingPlot, self.Range, self.StartingMagnitude, self.MagnitudeChange)
	-- obligatory - register type and add Starting Plot
	pDisaster.DisasterType = self;
	pDisaster.StartingPlot = self.StartingPlot;
	pDisaster.StartingMagnitude = self.StartingMagnitude;
	table.insert(pDisaster.Plots, self.StartingPlot);
	table.insert(pDisaster.Magnitudes, self.StartingMagnitude);
	-- now find out to which direction the fire should go
	dprint("  ...looking for the best direction");
	local iMaxAffectedTiles = 0;
	local eDirection = DirectionTypes.NUM_DIRECTION_TYPES;
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local iAffectedTiles = self:CountAffectedTilesInDirection(self.StartingPlot, direction);
		dprint("  ...in (dir) there are (n) affected tiles", direction, iAffectedTiles);
		if  iAffectedTiles > iMaxAffectedTiles then
			iMaxAffectedTiles = iAffectedTiles;
			eDirection = direction;
		end
	end
	if eDirection == DirectionTypes.NUM_DIRECTION_TYPES then
		print("ERROR: Disaster_Wildfire:EventGenerate() could not find direction for fire - no trees around?");
		return;
	end
	-- now run the real fire
	local tFlamingPlots = {};  -- temp table - will hold plots that are flaming already (current ring)
	local tTestPlots = {};  -- temp table - will hold plots that have potential (next ring)
	table.insert(tFlamingPlots, self.StartingPlot);  -- we'll start with initial one, as Ring 0
	local iDistance = 0;
	while iDistance < self.Range do  -- will not go here if Range = 0
		local iMagnitude = math.max(self.StartingMagnitude + (iDistance+1) * self.MagnitudeChange, self.MagnitudeMin);  -- anticipated
		-- not we go for each plot to check and set it aflame if possible
		for _, index in pairs(tFlamingPlots) do
			-- try to set aflame adjacent tiles
			local iAdjPlot1, iAdjPlot2 = GetAdjacentPlotTwoIndices(index, eDirection);
			-- process 1st plot, need to add check if FLAMMABLE
			if not IsInTable(tTestPlots, iAdjPlot1) and IsPlotIndexFlammable(iAdjPlot1) then
				--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot1, iAdjPlot1%iMapWidth, math.floor(iAdjPlot1/iMapWidth), iMagnitude);
				table.insert(tTestPlots, iAdjPlot1);
				table.insert(pDisaster.Plots, iAdjPlot1);
				table.insert(pDisaster.Magnitudes, iMagnitude);
			end
			-- process 2nd plot, need to add check if FLAMMABLE
			if not IsInTable(tTestPlots, iAdjPlot2) and IsPlotIndexFlammable(iAdjPlot2) then
				--dprint("  ...(ring): adding plot (idx,x,y,magn)", iDistance, iAdjPlot2, iAdjPlot2%iMapWidth, math.floor(iAdjPlot2/iMapWidth), iMagnitude);
				table.insert(tTestPlots, iAdjPlot2);
				table.insert(pDisaster.Plots, iAdjPlot2);
				table.insert(pDisaster.Magnitudes, iMagnitude);
			end
		end
		-- now the fire goes to the next Ring
		iDistance = iDistance + 1;
		tFlamingPlots = tTestPlots;
		tTestPlots = {};
	end
end


-- ===========================================================================
-- DISASTER EVENT OBJECT
-- As for now only 1 event per turn is supported
-- But having such event object, later I could add some queue and handle more than 1
-- ===========================================================================

local tHistoricDisasters = {};		-- FOR FUTURE - a table with all tTheDisaster objects (events)

local tTheDisaster = {
	-- properties & operational data
	IsActive = false,			-- flag saying if there's an event at all
	Turn = 0,					-- turn in which it happened
	Year = 0,					-- year in which it happened
	DisasterType = {},			-- disaster type
	StartingPlot = 0,			-- always 1 tile!
	StartingMagnitude = 0,		-- Event's power
	Plots = {},					-- list of plot indices that are in range of the disaster
	Magnitudes = {},			-- corresponding list of devastation levels to apply
	Effects = {}, 				-- effects that will be/has been applied
};
	
-- debug functions
function tTheDisaster:dshowevent()	-- debug function for showing event details
	dprint("Disaster Event details (turn,year,active):", self.Turn, self.Year, self.IsActive);
	dprint(" ...of type and magn on plot", self.DisasterType.Name, self.StartingMagnitude, self.StartingPlot);
	dprint(" ...affecting plots/magns", table.count(self.Plots), table.count(self.Magnitudes));
	--[[
	for i, index in ipairs (self.Plots) do
		local pPlot = Map.GetPlotByIndex(index);
		dprint("Plot (index,x,y,magn) (water,terrain)", index,
			pPlot:GetX(), pPlot:GetY(), 
			tTheDisaster.Magnitudes[i],
			pPlot:IsWater(),
			GameInfo.Terrains[pPlot:GetTerrainType()].TerrainType);
	end
	--]]
end
	
-- init new event data and clear data that will be filled by EventGenerate in a moment
function tTheDisaster:InitTheDisaster()
	dprint("FUNCAL tTheDisaster:InitTheDisaster()");
	self.IsActive = true;		-- catastrophy happened
	self.Turn = Game.GetCurrentGameTurn();
	self.Year = RND.Calendar.MakeYearStr(self.Turn);  -- Calendar only available in UI context
	self.DisasterType = {};
	self.StartingPlot = 0;
	self.StartingMagnitude = 0;
	self.Plots = {};
	self.Magnitudes = {};
	self.Effects = {};
end
	
-- main function to apply effects
-- 1. will go through all plots and analyze them for possible effects
-- 2. will apply specific effects

function tTheDisaster:AnalyzePlotForEffects(iPlot:number, iMagnitude:number)
	--dprint("FUNSTA tTheDisaster:AnalyzePlotForEffects() (idx,magn)", iPlot, iMagnitude);
	
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then print("ERROR tTheDisaster:AnalyzePlotForEffects() no plot with id", iPlot); return; end
	local tEffect:table = {};  -- will store new effects
	local iEffCnt = table.count(self.Effects);
	
	-- check for our own units and plots
	local sLocalOwner:string;
	local eLocalPlayer = Game.GetLocalPlayer();
	if eLocalPlayer ~= -1 then sLocalOwner = Locale.Lookup(PlayerConfigurations[eLocalPlayer]:GetCivilizationShortDescription());
	else sLocalOwner = nil; end
	
	-- 0 - check if there's an owner
	local eOwnerID, sOwnerCiv:string, sOwnerCity:string = -1, "", "";  -- will be passed to new effects
	if pPlot:IsOwned() then
		eOwnerID = pPlot:GetOwner();
		local pCity = Cities.GetPlotPurchaseCity(pPlot);
		dprint("  plot owned by (civ,city)", eOwnerID, pCity:GetID());
		sOwnerCiv = PlayerConfigurations[eOwnerID]:GetCivilizationShortDescription();  -- LOC_CIVILIZATION_AMERICA_NAME
		sOwnerCiv = Locale.Lookup(sOwnerCiv);
		sOwnerCity = Locale.Lookup(pCity:GetName());
		dprint("  plot owned by (civ,city)", sOwnerCiv, sOwnerCity);
	end
	
	-- 1 - check for units
	if Units.AreUnitsInPlot(iPlot) then
		for _,unit in pairs(Units.GetUnitsInPlot(iPlot)) do
			dprint("  ...found a unit", unit:GetName());
			tEffect = Effect_Record:new(iPlot, iMagnitude, eOwnerID, sOwnerCiv, sOwnerCity, sLocalOwner);
			tEffect:AssignObject(EffectClasses.EFFECT_UNIT, unit, sLocalOwner, -1);
			table.insert(self.Effects, tEffect);
		end
	end
	
	-- 2 - check for improvements
	if pPlot:GetImprovementType() ~= -1 then
		dprint("  ...found an improvement", pPlot:GetImprovementType());
		tEffect = Effect_Record:new(iPlot, iMagnitude, eOwnerID, sOwnerCiv, sOwnerCity, sLocalOwner);
		tEffect:AssignObject(EffectClasses.EFFECT_IMPROVEMENT, pPlot, sLocalOwner, -1);
		table.insert(self.Effects, tEffect);
	end
	
	-- 3 - check for city
	--if pPlot():IsCity() then
	if Cities.IsCityInPlot(iPlot) then
		dprint("  ...found a city");
		tEffect = Effect_Record:new(iPlot, iMagnitude, eOwnerID, sOwnerCiv, sOwnerCity, sLocalOwner);
		tEffect:AssignObject(EffectClasses.EFFECT_CITY, Cities.GetCityInPlot(iPlot), sLocalOwner, -1);
		table.insert(self.Effects, tEffect);
	end
	
	-- 4 - check for district
	if pPlot:GetDistrictType() ~= -1 then
		dprint("  ...found a district", pPlot:GetDistrictType());
		local pCity = Cities.GetPlotPurchaseCity(pPlot);
		-- must find which district it is
		for i=0, pCity:GetDistricts():GetNumDistricts()-1, 1 do
			dprint("  ...checking district at index", i);
			local pDistrict = pCity:GetDistricts():GetDistrictByIndex(i);
			local iX, iY = pDistrict:GetLocation();
			local iDistrictPlot = iY * iMapWidth + iX;
			dprint("  ...its location is (plot,x,y)", iDistrictPlot, iX, iY);
			if iDistrictPlot == iPlot then
				-- the district has been located - process it and then its buildings!
				-- must be careful with WONDERS - don't know if they can be Pillaged - must CHECK LATER
				-- anyway, district will be registered only if NOT internal
				if GameInfo.Districts[pDistrict:GetType()].InternalOnly == false then
					tEffect = Effect_Record:new(iPlot, iMagnitude, eOwnerID, sOwnerCiv, sOwnerCity, sLocalOwner);
					tEffect:AssignObject(EffectClasses.EFFECT_DISTRICT, pDistrict, sLocalOwner, -1);
					table.insert(self.Effects, tEffect);
				end
				-- 5 - check for buildings
				local pCityBuildings = pCity:GetBuildings();
				for building in GameInfo.Buildings() do
					if pCityBuildings:HasBuilding(building.Index) and
						pCityBuildings:GetBuildingLocation(building.Index) == iPlot then
						-- found building, register it
						dprint("  ...found a building (id,name)", building.Index, GameInfo.Buildings[building.Index]);
						tEffect = Effect_Record:new(iPlot, iMagnitude, eOwnerID, sOwnerCiv, sOwnerCity, sLocalOwner);
						tEffect:AssignObject(EffectClasses.EFFECT_BUILDING, pCity, sLocalOwner, building.Index);
						table.insert(self.Effects, tEffect);
					end -- found building
				end -- buildings loop
			end -- found district
		end -- district loop
	end -- check for district
	
	--dprint("FUNEND tTheDisaster:AnalyzePlotForEffects() found (num) effects for (plot)", table.count(self.Effects)-iEffCnt, iPlot);
end


function tTheDisaster:ExecuteTheDisaster()
	dprint("FUNCAL tTheDisaster:ExecuteTheDisaster()");
	self:dshowevent();
	for i, iPlot in ipairs(self.Plots) do
		self:AnalyzePlotForEffects(iPlot, self.Magnitudes[i]);
	end
	dprint("Found (n) effects to apply", table.count(self.Effects));
	for _, effect in pairs(self.Effects) do
		effect:ApplyEffect();
	end
end

	
-- ===========================================================================
-- MAIN FUNCTIONS
-- ===========================================================================


-- ===========================================================================
--[[
Need a routine to ‘devastate’ with level of devastation X%
Units
Destroyed with X/2 prob
Damaged for X hp
Cities / Districts
Loose 1/2X population
Buildings destroyed with 1/2X probability
Buildings pillaged with X probability
Amenities could go down
No function, modifiers again
Attached to the City should be easy
Land tiles (improvements)
Pillaged with X prob
Destroyed with 1/2X prob
Land Appeal should be down for some time
Ofc no function for, so need to use Modifiers?
Sea tiles
Improvements pillaged with 1,5X prob
Improvements destroyed with 1/2X prob
After devastation a report should be shown with effects
--]]


-- ===========================================================================
-- GAME EVENTS
-- ===========================================================================

function OnPreTurnBegin()
	dprint("FUNCAL OnPreTurnBegin");
end

-- ===========================================================================
-- Main function that handles disaster events
-- A. Process existing events [NEXT PHASE]
--   e.g. move tornadoes, extend flood (next phase), spread wildfire, keep drought
--   See if events are in progress, if so call ContinueEvent from them
-- B. Generate new events
--   1. Loop through Distaster types and check if new event happened (randomize and see if we have any events)
--   2. If so, create a new event, 
--     2a: In general, they vary in Magnitude: little, small, medium, large, huge
--         Can affect devastation: -20, -10, normal, +10, +20 with probabilities: 40% / 30% / 20% / 5% / 5%
--     2b. add it to the queue/historical data [NEXT PHASE]
--   3. ExecuteEvent (call devastate functions) and gather data

local tOrderOfDisasters = {
	-- put the ones to test at the begining or even duplicate
	Disaster_Earthquake,
	Disaster_Flood,
	Disaster_Meteor,
	Disaster_Tornado,
	Disaster_Tsunami,
	Disaster_Volcano,
	Disaster_Wildfire,
};
local iOrderCounter = 1;  							-- we'll start from the first, but during "empty" turns should be 8
local iOrderMax = table.count(tOrderOfDisasters);	-- should be 7

function OnTurnBegin()
	--dprint("FUNCAL OnTurnBegin()");
	
	if Game.GetCurrentGameTurn() == GameConfiguration.GetStartTurn() then  -- always 1st turn is 'free', even when we start in later Eras
		LuaEvents.RNDInfoPopup_OpenWindow();  -- show parameters
		return;  -- so Civs won't be killed on 1st turn :)
	end
	
	-- first let's go through all of them and check if any triggers
	local iCheck = 0;  -- will be later used to update iOrderCounter
	for iCounter = iOrderCounter, iOrderCounter + iOrderMax - 1, 1 do
		iCheck = ((iCounter-1) % iOrderMax) + 1;  -- wrap index, complex because Lua tables start with index 1
		--dprint("Checking (i,pos,type)", iCounter, iCheck, tOrderOfDisasters[iCheck].Name);
		local disaster = tOrderOfDisasters[iCheck];
		if disaster:CheckIfHappened(true) then  -- well, the worse has happened [from Object] 'false' - not-real checking (debug), should be 'true' at the end MAIN SWICH HERE
			tTheDisaster:InitTheDisaster();  -- from tTheDisaster (it will initialize itself)
			--dprint("The Disaster has been initialized");
			--tTheDisaster:dshowevent()
			disaster:EventGenerate(tTheDisaster);  -- from specific disaster type
			dprint("DISASTER GENERATED");
			tTheDisaster:dshowevent();
			break;
		end
	end
	iOrderCounter = iCheck + 1;  -- next to check
	
	-- now let's see if there's an active disaster 
	-- if so - do some visualization (floating text via AddWorldViewText)
	-- [DONE] add checking for visibility
	if tTheDisaster.IsActive then
		local pPlayerVisibility = PlayersVisibility[Game.GetLocalPlayer()];
		for i, iPlot in pairs(tTheDisaster.Plots) do
			if pPlayerVisibility:IsRevealed(iPlot) then
				local sInfo = tTheDisaster.DisasterType.Name.." "..tostring(tTheDisaster.Magnitudes[i]);
				RND.UI.AddWorldViewText(0, sInfo, iPlot%iMapWidth, math.floor(iPlot/iMapWidth), 0);
			end
		end
		------------- CATASTROPHY -------------
		tTheDisaster:ExecuteTheDisaster();
		---------------------------------------
		for _, effect in pairs(tTheDisaster.Effects) do
			if effect.IsDestroyed and pPlayerVisibility:IsRevealed(effect.Plot) then
				RND.UI.AddWorldViewText(0, effect.Desc, effect.Plot%iMapWidth, math.floor(effect.Plot/iMapWidth), 0);
			end
		end
	end
end

-- ===========================================================================
function OnTurnEnd()
	dprint("FUNCAL OnTurnEnd()");
end


-- ===========================================================================
-- Main function to handle ongoing disasters
-- A. levels of information:
--   1. Display InfoPopup with details - for events that devastate OUR territory [FUNCTION]
--   2. Log notification for events outside of our territory [FUNCTION]
-- B. If event is within visible range - show it on the map [FUNCTION]

-- helper table and counter so we go through all disaster types equal number of times
-- if an event is generated, the next turn will start from the next disaster type


-- ===========================================================================
-- debug routine - to check statistics
function dgenerate1000events()
	dprint("FUNCAL dgenerate1000events()");
	
	-- first, test Gutenberg-Richter function - 10000 randoms
	dprint("Gutenberg-Richter routine test");
	local tGRTest = {};
	for i=0,100,10 do tGRTest[i] = 0; end
	for i=1,10000,1 do
		local iM = GetRandomMagnitudeWithGutenbergRichter();
		tGRTest[iM] = tGRTest[iM] + 1;
	end
	for i=0,100,10 do dprint("  (magn,count)", i,tGRTest[i]); end
	dprint("  Category 1 (%)", string.format("%5.1f", (tGRTest[ 0]+tGRTest[10])/100.0));
	dprint("  Category 2 (%)", string.format("%5.1f", (tGRTest[20]+tGRTest[30])/100.0));
	dprint("  Category 3 (%)", string.format("%5.1f", (tGRTest[40]+tGRTest[50])/100.0));
	dprint("  Category 4 (%)", string.format("%5.1f", (tGRTest[60]+tGRTest[70])/100.0));
	dprint("  Category 5 (%)", string.format("%5.1f", (tGRTest[80]+tGRTest[90])/100.0));
	dprint("  Category X (%)", string.format("%5.1f", (           tGRTest[100])/100.0));
	
	dprint("1000 turns event generation test");
	local tCounters = {};
	for _, disaster in pairs(tOrderOfDisasters) do tCounters[disaster] = 0; end
	-- simulate 1000 turns, for simplicity we allow multiple events per turn (no counter)
	for turn = 1, 1000, 1 do
		for _, disaster in pairs(tOrderOfDisasters) do
			if disaster:CheckIfHappened(true) then
				tCounters[disaster] = tCounters[disaster] + 1;
			end
		end
	end
	-- print final counters
	local iTotal = 0;
	for _, disaster in pairs(tOrderOfDisasters) do
		dprint("  ...(dis) happened (n) times", disaster.Name, tCounters[disaster]);
		iTotal = iTotal + tCounters[disaster];
	end
	dprint("  ...all disasters total", iTotal);
	dprint("Reference stats for Continents.lua @ 1000 turns");
	dprint("     Disaster      STD  TINY  DUEL");
	dprint("  ...Earthquake -   45    35    25");
	dprint("  ...Flood      -   30    20    15");
	dprint("  ...Meteor     -   10     5     5");
	dprint("  ...Tornado    -   35    25    20");
	dprint("  ...Tsunami    -   20    15    10");
	dprint("  ...Volcano    -   15    10    10");
	dprint("  ...Wildfire   -   50    35    25");
	dprint("  ...TOTAL      -  205   145   110");
end


-- ===========================================================================
function OnLocalPlayerTurnBegin()
	--dprint("FUNCAL OnLocalPlayerTurnBegin()");
	-- if there's an active disaster - show pop-up window with information
	if tTheDisaster.IsActive then
		LuaEvents.RNDInfoPopup_OpenWindow();
	end
end


-- ===========================================================================
-- If event has ended - remove it from the map [FUNCTION]
-- 
-- [NEXT PHASE] Continue showing (some effects?)
function OnLocalPlayerTurnEnd()
	--dprint("FUNCAL OnLocalPlayerTurnEnd()");
	
	-- if there was an event - store it into historic data
	if tTheDisaster.IsActive then
		local disaster = tTheDisaster.DisasterType;  -- we know where to store historic data
		-- create a copy to be stored
		local tCopyDisaster:table = {
				-- data
				IsActive = tTheDisaster.IsActive,
				Turn = tTheDisaster.Turn,
				Year = tTheDisaster.Year,
				DisasterType = tTheDisaster.DisasterType,
				StartingPlot = tTheDisaster.StartingPlot,
				StartingMagnitude = tTheDisaster.StartingMagnitude,
				Plots = tTheDisaster.Plots,
				Magnitudes = tTheDisaster.Magnitudes,
				-- functions
				dshowevent = tTheDisaster.dshowevent,
				-- don't copy InitTheDisaster - historic ones will never be initialized
		};
		-- debug check
		--dprint("Created a copy of the event to be stored; the details follow");
		--tCopyDisaster:dshowevent();
		-- store it in 2 queues (general and disaster's type)
		table.insert(tHistoricDisasters, tCopyDisaster);
		table.insert(disaster.HistoricEvents, tCopyDisaster);
		-- also store starting points for history
		--for _, index in pairs(tTheDisaster.StartingPlots) do
		table.insert(disaster.HistoricStartingPlots, tTheDisaster.StartingPlot);
		--end
		-- deactivate event
		tTheDisaster.IsActive = false;
	end
	
end

-- ===========================================================================
-- A player's turn has started
-- For AI player [NEXT PHASE]
-- Check if event was on our territory
-- Check if some action is to be taken
function OnPlayerTurnActivated( ePlayer, bFirstTime )
	dprint("FUNCAL OnPlayerTurnActivated(ePlayer,bFirstTime)", ePlayer, bFirstTime);
end


-- ===========================================================================
function OnPlayerTurnDeactivated(ePlayer:number)
	dprint("FUNCAL OnPlayerTurnDeactivated(ePlayer)", ePlayer);
end


-- ===========================================================================
-- Load data into distasters (careful - it is BEFORE OnLoadScreenClose)
-- 1. Deserialize values
-- [NEXT PHASE]
function OnLoadComplete()
	dprint("FUNCAL OnLoadComplete");
end


-- ===========================================================================
-- Initialize data for this game that can be recreated
-- 1. Retrieve map size and adjust distaster parameters to fit the map [AdjustForMapSize]
-- 2. Analyze current Map [CheckPlotForPossibleStart]

function OnLoadScreenClose()
	dprint("FUNSTA OnLoadScreenClose");
	
	-- retrieve map and game speed parameters (constant during the game)
	iMapWidth, iMapHeight = Map.GetGridSize();
	iMapSize = iMapWidth * iMapHeight;
	fMapProbAdj = 1.0 * math.pow(iMapSize/4536, -0.55);  -- empiric formula referencing STANDARD map size, as of now: =1.0*map_ratio^(-0.55)
	iGameSpeedMultiplier = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier;
	dprint("Map parameters (w,h,size,adj,speed) are", iMapWidth, iMapHeight, iMapSize, fMapProbAdj, iGameSpeedMultiplier);
	
	-- retrieve custom parameters
	local function RetrieveParameter(sParName:string, iDefault:number)
		local par = GameConfiguration.GetValue(sParName);
		if par == nil then par = iDefault; else par = tonumber(par); end
		dprint("Retrieving (par,def,out)", sParName, iDefault, par);
		return par;
	end
	iRNDConfigNumDis    = RetrieveParameter("RNDConfigNumDis", 100);
	iRNDConfigMagnitude = RetrieveParameter("RNDConfigMagnitude", 0);
	iRNDConfigRange     = RetrieveParameter("RNDConfigRange", 0);

	-- check if we should adjust parameters for map size
	if RetrieveParameter("RNDConfigAdjMapSize", 1) == 1 then --fMapProbAdj = 1.0; end  -- no, we can simply set it to 1.0
		iRNDConfigNumDis = math.floor(fMapProbAdj * iRNDConfigNumDis * iMapSize/4536);
	end

	-- load Disaster parameters from Database and adjust parameters for Range and Magnitude
	for _, disaster in pairs(tDisasterTypes) do
		dprint("Loading parameters for", disaster.Type);
		disaster:InitializeDisaster();
		-- debug: check if definitions are ok
		for k,v in pairs(disaster) do dprint("  (k,v)", k, v); end
	end

	-- iterate through all plots and understand what's on them
	for ix = 0, iMapWidth-1, 1 do
		for iy = 0, iMapHeight-1, 1 do
			local pPlot:table = Map.GetPlot(ix, iy);
			if pPlot == nil then print("ERROR: Plot (x,y) is nil", ix, iy); return; end
			--dprint("@(x,y) is plot idx", ix, iy, pPlot:GetIndex());
			-- iterate through all possible disaster types and check if it is a start
			for _, disaster in pairs(tDisasterTypes) do
				disaster:CheckPlotForPossibleStart(pPlot);
			end
		end
	end

	-- debug: probability calculations data
	--dprint("Number of starting plots for each disaster type");
	--for _,dis in pairs(tDisasterTypes) do dprint("  (dis,num)", dis.Name, dis.NumStartPlots); end

	-- now let's check the total number of events and adjust probability accordingly
	local iTotEvents = 0;  -- x1000 to avoid rounding errors
	for _, disaster in pairs(tDisasterTypes) do
		local numEvents = math.floor(disaster.BaseProbability * disaster.NumStartPlots * 500 / 1000);
		dprint("Estimated number of events for (dis,num,plots,prob,adj)", disaster.Type, numEvents/1000, disaster.NumStartPlots, disaster.BaseProbability, fMapProbAdj);
		iTotEvents = iTotEvents + numEvents;
	end
	local fNumDisAdj:number = 1.0 * iRNDConfigNumDis * 1000 / iTotEvents;
	dprint("Total number of events (par,num,adj)", iRNDConfigNumDis, iTotEvents, fNumDisAdj);
	
	-- adjust parameters for game speed, calculate final adjustment and adjust disasters probabilities
	local fProbAdj:number = fNumDisAdj * (100.0/iGameSpeedMultiplier);
	for _, disaster in pairs(tDisasterTypes) do
		dprint("Adjusting original parameters for (dis,base,delta,adj)", disaster.Type, disaster.BaseProbability, disaster.DeltaProbability, fProbAdj);
		disaster:AdjustProbability(fProbAdj);
		dprint("  ...adjusted params are (base,delta)", disaster.BaseProbability, disaster.DeltaProbability);
	end

	-- final check
	iTotEvents = 0; -- x1000
	for _, disaster in pairs(tDisasterTypes) do
		local numEvents = math.floor(disaster.BaseProbability * disaster.NumStartPlots * 500 * (iGameSpeedMultiplier/100) / 1000);
		dprint("Adjusted estimated number of events for (dis,num)", disaster.Type, numEvents/1000);
		iTotEvents = iTotEvents + numEvents;
	end
	dprint("Total adjusted number of events (par,num)", iRNDConfigNumDis, math.floor(iTotEvents/1000));
	
	-- debug - display all maps
	--ddisplaymap(Disaster_Earthquake.StartPlots, "EE");
	--ddisplaymap(Disaster_Flood.StartPlots, "FF");
	--ddisplaymap(Disaster_Meteor.StartPlots, "MM");
	--ddisplaymap(Disaster_Tornado.StartPlots, "OO");
	--ddisplaymap(Disaster_Tsunami.StartPlots, "TT");
	--ddisplaymap(Disaster_Volcano.StartPlots, "VV");
	--ddisplaymap(Disaster_Wildfire.StartPlots, "WW");
	--dgenerate1000events();
	
	dprint("FUNEND OnLoadScreenClose");	
end


-- ===========================================================================
function Initialize()
	dprint("FUNSTA Initialize()");
	if not ExposedMembers.RND then ExposedMembers.RND = {} end;
	if not ExposedMembers.RNDInit then ExposedMembers.RNDInit = {} end;
	RND = ExposedMembers.RND;

	--dprint("Calendar.MakeYearStr()="..tostring(Calendar.MakeYearStr(Game.GetCurrentGameTurn())));
	

	-- more pre-events to check
	Events.LoadComplete.Add( OnLoadComplete );  -- fires after loading a game, when it's ready to start (i.e. circle button)
	Events.LoadScreenClose.Add ( OnLoadScreenClose );   -- fires then Game is ready to begin i.e. big circle buttons appears; if loaded - fires AFTER LoadComplete
	--Events.RequestSave.Add( OnRequestSave );  -- didn't fire
	--Events.RequestLoad.Add( OnRequestLoad );  -- didn't fire
	
	-- initialize events - starting events
	--Events.LocalPlayerChanged.Add( OnLocalPlayerChanged );  -- fires in-between TurnEnd and TurnBegin
	--Events.PreTurnBegin.Add( OnPreTurnBegin );  -- fires ONCE at start of turn, before actual Turn start
	Events.TurnBegin.Add( OnTurnBegin );  -- fires ONCE at the start of Turn
	Events.LocalPlayerTurnBegin.Add( OnLocalPlayerTurnBegin );  -- event for LOCAL player only (i.e. HUMANS), fires BEFORE PlayerTurnActivated
	--Events.PlayerTurnActivated.Add( OnPlayerTurnActivated );  -- main event for any player start (AIs, including minors), goes for playerID = 0,1,2,...
	-- initialize events - that fire AFTER custom PlayerTurnActivated()
	-- HERE YOU PLAY GAME AS HUMAN
	-- initialize events - finishing events
	Events.LocalPlayerTurnEnd.Add( OnLocalPlayerTurnEnd );  -- fires only for HUMANS
	--Events.PlayerTurnDeactivated.Add( OnPlayerTurnDeactivated );  -- main event for any player end (including minors)
	--Events.TurnEnd.Add( OnTurnEnd );  -- fires ONCE at end of turn

	-- exposing functions and variables
	ExposedMembers.RND.tDisasterTypes = tDisasterTypes;
	ExposedMembers.RND.tTheDisaster = tTheDisaster;
	ExposedMembers.RND.Disaster_Earthquake 	= Disaster_Earthquake;
	ExposedMembers.RND.Disaster_Flood 		= Disaster_Flood;
	ExposedMembers.RND.Disaster_Meteor 		= Disaster_Meteor;
	ExposedMembers.RND.Disaster_Tornado 	= Disaster_Tornado;
	ExposedMembers.RND.Disaster_Tsunami 	= Disaster_Tsunami;
	ExposedMembers.RND.Disaster_Volcano 	= Disaster_Volcano;
	ExposedMembers.RND.Disaster_Wildfire 	= Disaster_Wildfire;
	ExposedMembers.RNDInit["RealNaturalDisasters"] = true;
	dprint("FUNEND Initialize()");
end
Initialize();

print("Finished loading RealNaturalDisasters.lua from Real Natural Disasters");