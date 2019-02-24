print("Loading RealNaturalDisasters.lua from Real Natural Disasters version "..GlobalParameters.RND_VERSION_MAJOR.."."..GlobalParameters.RND_VERSION_MINOR.."."..GlobalParameters.RND_VERSION_PATCH);
-- ===========================================================================
-- Real Natural Disasters
-- Author: Infixo
-- Created: March 25th - April 1st, 2017
-- Version 2: April 21st - April 28th, 207
-- ===========================================================================

include("PlotIterators");
include("Serialize");

if ExposedMembers.RND == nil then ExposedMembers.RND = {} end;
local RND = ExposedMembers.RND;


-- ===========================================================================
-- DEBUG ROUTINES
-- ===========================================================================

local bRealEffects = true;  -- set to FALSE to only simulate effects (no real damage will be applied)
local bRealDisasters = true;  -- set to TRUE for final version

-- debug output routine
function dprint(sStr,p1,p2,p3,p4,p5,p6)
	if true then return; end
	local sOutStr = sStr;
	if p1 ~= nil then sOutStr = sOutStr.." [1] "..tostring(p1); end
	if p2 ~= nil then sOutStr = sOutStr.." [2] "..tostring(p2); end
	if p3 ~= nil then sOutStr = sOutStr.." [3] "..tostring(p3); end
	if p4 ~= nil then sOutStr = sOutStr.." [4] "..tostring(p4); end
	if p5 ~= nil then sOutStr = sOutStr.." [5] "..tostring(p5); end
	if p6 ~= nil then sOutStr = sOutStr.." [6] "..tostring(p6); end
	print(Game.GetCurrentGameTurn(), sOutStr);
end

-- debug routine - print contents of a table of plot indices
function dshowinttable(pTable:table)  -- For debugging purposes. LOT of table data being handled here.
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

-- debug routine - prints a table (no recursion)
function dshowtable(tTable:table)
	for k,v in pairs(tTable) do
		print(k, type(v), tostring(v));
	end
end

-- debug routine - prints a table, and tables inside recursively (up to 5 levels)
function dshowrectable(tTable:table, iLevel:number)
	local level:number = 0;
	if iLevel ~= nil then level = iLevel; end
	for k,v in pairs(tTable) do
		print(string.rep("---:",level), k, type(v), tostring(v));
		if type(v) == "table" and level < 5 then dshowrectable(v, level+1); end
	end
end

-- debug routine - will display ASCII map
-- pPlots is a table of IDs, sCode is 2-chars string to represent the feature
function ddisplaymap(pPlots:table, sCode:string)
	dprint("FUNCAL ddisplaymap(plots,code)", table.count(pPlots), sCode);
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

function GetGameInfoIndex(sTableName:string, sTypeName:string) 
	local tTable = GameInfo[sTableName];
	if tTable then
		local row = tTable[sTypeName];
		if row then return row.Index
		else        return -1;        end
	end
	return -1;
end

-- from MapEnums.lua, These come from the database.  Get the runtime index values.
-- CAREFUL! in MapEnums they are called g_TERRAIN_TYPE_xxx
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

-- features
g_FEATURE_NONE				= -1;
g_FEATURE_FLOODPLAINS		= GetGameInfoIndex("Features", "FEATURE_FLOODPLAINS");
g_FEATURE_ICE				= GetGameInfoIndex("Features", "FEATURE_ICE");
g_FEATURE_JUNGLE			= GetGameInfoIndex("Features", "FEATURE_JUNGLE");
g_FEATURE_FOREST			= GetGameInfoIndex("Features", "FEATURE_FOREST");
g_FEATURE_OASIS				= GetGameInfoIndex("Features", "FEATURE_OASIS");
g_FEATURE_MARSH				= GetGameInfoIndex("Features", "FEATURE_MARSH");

-- mountain-like natural wonders
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
local iTurnsForMagnitudeIncrease:number = 25;  -- how many turns for a magnitude to increase by 1, game speed adjusted
local iPreventionResistantDefaultValue:number = -15;

-- adjustment factor due to map size
-- empiric formula referencing STANDARD map size, as of now: =1.0*map_ratio^(-0.55)
local fMapProbAdj = 0.0; 

-- resources
local iTilesPerStandardResource:number = 20;
local fResourceProbabilityAdj:number = 0.7;  -- standard resources will be spawned with probabbility = Magnitude * fResourceProbabilityAdj
local fResourcePermanentAdj:number = 0.5;  -- specific resources will be spawned as permanent with probability = Magnitude * fResourcePermanentAdj (Version 2.3.0 adjusted down a bit)
local fResourceTemporaryAdj:number = 1.2;  -- specific resources will be spawned as temporary with probability = Magnitude * fResourceTemporaryAdj
local iTemporaryResourceTurns:number = 6;
local iTemporaryResourceTurnsLong:number = 10;
local iTemporaryResourceTurnsDelta:number = 2;

-- disaster types (table of objects)
local tDisasterTypes:table = {};
--local tHistoricDisasters = {};		-- FOR FUTURE - a table with all tTheDisaster objects (events)
local tHistoricStartingPlots:table = {};	-- for save/load purposes
local iOrderCounter = 1;  				-- used to cycle through all disasters; we'll start from the first, but during "empty" turns should be 8

-- resources
local tDisasterResources:table = {};  -- will hold possible resources for each Disaster type, loaded from DB
local tTemporaryResources:table = {};  -- will hold all temp Resource Effects
local bMapCleared = false;	-- will be set to true if game is loaded from a save file


-- ===========================================================================
-- GENERIC FUNCTIONS AND HELPERS
-- ===========================================================================

-- check if 'value' exists in table 'pTable'; should work for any type of 'value' and table indices
function IsInTable(pTable:table, value)
	for _,data in pairs(pTable) do
		if data == value then return true; end
	end
	return false;
end

-- returns 'key' at which a given 'value' is stored in table 'pTable'; nil if not found; should work for any type of 'value' and table indices
function GetTableKey(pTable:table, value)
	for key,data in pairs(pTable) do
		if data == value then return key; end
	end
	return nil;
end

-- returns random coordinates within a circle
function GetRandomCoorsInCircle(fRadius:number)
	local fDeg:number = 360.0*math.random();
	local fRad:number = math.random(0,fRadius);
	return fRad*math.sin(math.rad(fDeg)), fRad*math.cos(math.rad(fDeg));
end

-- ===========================================================================
-- PLOT FUNCTIONS AND HELPERS
-- ===========================================================================

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
function IsPlotMountain(pPlot:table)
	local eFeature = pPlot:GetFeatureType();
	if pPlot:IsMountain() or
		eFeature == g_FEATURE_EVEREST or eFeature == g_FEATURE_KILIMANJARO or
		eFeature == g_FEATURE_PIOPIOTAHI or eFeature == g_FEATURE_TORRES_DEL_PAINE or eFeature == g_FEATURE_YOSEMITE then
		return true;
	end;
	return false;
end
function IsPlotIndexMountain(iPlot:number)
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then return false; end
	return IsPlotMountain(pPlot);
end

function IsPlotMountainOrHills(pPlot:table)
	return pPlot:IsHills() or IsPlotMountain(pPlot)
end
function IsPlotIndexMountainOrHills(iPlot:number)
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then return false; end
	return IsPlotMountainOrHills(pPlot);
end

-- Checks if plot is Flatlands, Water is NOT flatlands
function IsPlotFlatlands(pPlot:table)
	return not( pPlot:IsWater() or pPlot:IsHills() or IsPlotMountain(pPlot));
end
function IsPlotIndexFlatlands(iPlot:number)
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then return false; end
	return IsPlotFlatlands(pPlot);
end

-- Checks if plot is Flammable: forest, grass, Not flammable: jungle, tundra, ice, lake 
function IsPlotFlammable(plot:table)
	--dprint("FUNCAL IsPlotFlammable() (idx) (wat,mnt,ter,ft,res)", plot:GetIndex(), plot:IsWater(), plot:IsMountain(), plot:GetTerrainType(), plot:GetFeatureType(), plot:GetResourceType());
	-- first let's get rid of things surely not flammable
	if plot:IsWater() or IsPlotMountain(plot) or
		plot:GetFeatureType() == g_FEATURE_JUNGLE or plot:GetFeatureType() == g_FEATURE_PANTANAL or 
		plot:GetFeatureType() == g_FEATURE_MARSH  or plot:GetFeatureType() == g_FEATURE_FLOODPLAINS or 
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

-- Check if there's fresh water close-by; must be River or adjacent to Lake
function IsPlotCloseToFreshWater(pPlot:table)
	if pPlot:IsRiver() then return true; end
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot = Map.GetPlotByIndex(GetAdjacentPlotIndex(pPlot:GetIndex(), direction));
		if testPlot and testPlot:IsLake() then return true; end
	end
	return false;
end
function IsPlotIndexCloseToFreshWater(iPlot:number)
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then return false; end
	return IsPlotCloseToFreshWater(pPlot);
end


-- Counts plots adjacent to given that CheckAdjacentFunction returns true/false
function CountAdjacentToPlotIndex(iPlot:number, functionCheckAdjacent)
	local iAdjacentCount:number = 0;
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local iTestPlot:number = GetAdjacentPlotIndex(iPlot, direction);
		if functionCheckAdjacent(iTestPlot) then iAdjacentCount = iAdjacentCount + 1; end
	end
	return iAdjacentCount;
end
function CountAdjacentToPlot(pPlot:table, functionCheckAdjacent)
	return CountAdjacentToPlotIndex(pPlot:GetIndex(), functionCheckAdjacent);
end

-- this can be use for starting plots that might depend on latitude (e.g. Tornado, Hurricane, Drougth)
-- returns an integer representing a latitude -90..90
-- row 0 is always South Pole (lat = -90), row (iMapHeight-1) is always North Pole (lat = 90)
-- if the number of rows is odd then the Equator exists (lat = 0)
function GetLatitudeForY(iY:number)
	return math.floor( 90.0 * (iY-(iMapHeight-1)/2) / ((iMapHeight-1)/2) );
end


-- Mixing plots and buildings
-- Plot: Plot:IsOwned(), Plot:GetOwner(), Plot:GetDistrictType()
-- Cities.GetPlotPurchaseCity() - takes all 3 types of plot designations
-- City: City:GetBuildings():HasBuilding(), City:GetBuildings():GetBuildingLocation(), City:GetBuildings():IsPillaged()

-- BASIC function - check if eBuilding is in plot (no matter the owner)
-- if last parameter is TRUE that the building needs to be active (=NOT pillaged)
function IsPlotIndexHasBuilding(iPlot:number, eBuilding:number, bCheckActive:boolean)
	local pCity:table = Cities.GetPlotPurchaseCity(iPlot);
	if pCity == nil then return false; end
	local pCityBuildings:table = pCity:GetBuildings();
	if pCityBuildings == nil then return false; end
	-- IMPORTANT! GetBuildingLocation returns -1 if city doesn't have that building
	if bCheckActive then return (pCityBuildings:GetBuildingLocation(eBuilding) == iPlot) and not pCityBuildings:IsPillaged(eBuilding); 
	else 				 return  pCityBuildings:GetBuildingLocation(eBuilding) == iPlot; end
end

-- VARIATION - checks if City that owns the plot (if there is any) has a specific building, no matter where building is located
function IsPlotIndexCityHasBuilding(iPlot:number, eBuilding:number, bCheckActive:boolean)
	local pCity:table = Cities.GetPlotPurchaseCity(iPlot);
	if pCity == nil then return false; end
	local pCityBuildings:table = pCity:GetBuildings();
	if pCityBuildings == nil then return false; end
	if bCheckActive then return pCityBuildings:HasBuilding(eBuilding) and not pCityBuildings:IsPillaged(eBuilding); 
	else 				 return pCityBuildings:HasBuilding(eBuilding); end
end



-- ===========================================================================
-- CLASS OBJECT
-- Some residual functionality, will grow in time
-- In Lua, it is trivial to implement prototypes, using the idea of inheritance. More specifically,
-- if we have two objects a and b, all we have to do to make b a prototype for a is
--    setmetatable(a, {__index = b})
-- After that, a looks up in b for any operation that it does not have. To see b as the class of object a is not much more than a change in terminology.
-- ===========================================================================

local tObjectClasses:table = {};  -- will keep all tables that function as object classes, indexed by their _ClassName

-- class can be registered only if it has its _ClassName already defined
function RegisterClass(tClass:table, tParent:table)
	dprint("FUNCAL RegisterClass() (class)", tClass._ClassName);
	if tClass._ClassName == nil then print("ERROR RegisterClass(): _ClassName not defined"); return; end
	tObjectClasses[tClass._ClassName] = tClass;
	if tParent then	setmetatable(tClass, { __index = tParent }); end
end

-- debug routine
function dshowclass(tClass:table)
	local sParent:string = "(root)"
	if getmetatable(tClass) then sParent = getmetatable(tClass).__index._ClassName; end
	dprint("CLASS (name,parent)", tClass._ClassName, sParent);
	local iFields:number, iTables:number = 0,0;
	local sFields:string, sTables:string = "","";
	for k,v in pairs(tClass) do
		if type(v) == "function" then dprint("  function", k);
		elseif type(v) == "table" then iTables = iTables + 1; sTables = sTables..k.." ";
		else 					       iFields = iFields + 1; sFields = sFields..k.." "; end
	end
	dprint("  fields", iFields, sFields);
	dprint("  tables", iTables, sTables);
end
function dshowallclasses()
	dprint("--- DISPLAY ALL CLASSES ---");
	for _,class in pairs(tObjectClasses) do dshowclass(class); end
end

local Class_Object = {
	_ClassName = "Class_Object",  -- all objects will have this field indicating to which class they belong, the field will be initialized by the function
	--ObjectType = "CLASS_OBJECT",  -- all objects will have this field; if possible, should correspond to DB object accessible via GameInfo
};
RegisterClass(Class_Object);

-- returns an EMPTY object (only its _ClassName is set)
-- cannot use 'new' since it will be defned in each class separately
function Class_Object:newObject()
	--dprint("FUNCAL Class_Object:newObject() (self)", self._ClassName);
	local tObject:table = { _ClassName = self._ClassName };
	setmetatable(tObject, {__index = self});
	return tObject;
end

-- makes a table into an object of a class calling the function
function Class_Object:attachObject(tObject:table)
	dprint("FUNCAL Class_Object:AttachObject() (self)", self._ClassName);
	tObject._ClassName = self._ClassName;
	setmetatable(tObject, {__index = self});
end

-- it will connect an object of a known class to the table that defines that class
function AttachClassToObject(tObject:table)
	dprint("FUNCAL AttachClassToObject() (class)", tObject._ClassName);
	if tObjectClasses[tObject._ClassName] == nil then print("ERROR AttachClassToObject(): class not registered", tObject._ClassName); return; end
	setmetatable(tObject, { __index = tObjectClasses[tObject._ClassName] });
end
-- it will connect objects of known classes to the tables that define those classes
function AttachClassToObjectsInTable(tTable:table)
	dprint("FUNCAL AttachClassToObjectsInTable() (num)", table.count(tTable));
	for _,object in pairs(tTable) do AttachClassToObject(object); end
end
-- it will connect an object to the class; it will set the object's _ClassName to the class'es
function AttachObjectToClass(tClass:table, tObject:table)
	dprint("FUNCAL AttachObjectToClass() (class)", tClass._ClassName);
	tObject._ClassName = tClass._ClassName;
	setmetatable(tObject, { __index = tClass });
end
function AttachObjectsInTableToClass(tClass:table, tTable:table)
	dprint("FUNCAL AttachObjectsInTableToClass() (cl,num)", tClass._ClassName, table.count(tTable));
	for _,object in pairs(tTable) do AttachObjectToClass(tClass, object); end	
end



-- ===========================================================================
-- PREVENTION CLASSES
-- Disaster_Prevention
--   A table of Class_DisasterBuilding and functions to manipulate
-- Prevention_Damage | Prevention_Population | Prevention_Removal | Prevention_Insurance
--   Various functions to manipulate
-- Class_DisasterBuilding
--   Many instances, one for each building on the map
--   Keeps track of the status (pillaged), owner, CityID, etc.
-- ===========================================================================

PreventionClasses = {
	DAMAGE = 1, 		-- Reduce Magnitude (damage)
	POPULATION = 2,  	-- Reduce Magnitude (pop loss)
	REMOVAL = 3,  		-- Prevent Disaster (remove start plots)
	INSURANCE = 4,
	RESISTANT = 5,
};

-- DISASTER PREVENTIONS

local Disaster_Prevention:table = { _ClassName = "Disaster_Prevention", PreventionClass = 0 };
RegisterClass(Disaster_Prevention, Class_Object);

local Prevention_Damage:table = { _ClassName = "Prevention_Damage", PreventionClass = PreventionClasses.DAMAGE };
RegisterClass(Prevention_Damage, Disaster_Prevention);

local Prevention_Population:table = { _ClassName = "Prevention_Population", PreventionClass = PreventionClasses.POPULATION };
RegisterClass(Prevention_Population, Disaster_Prevention);

local Prevention_Removal:table = { _ClassName = "Prevention_Removal", PreventionClass = PreventionClasses.REMOVAL };
RegisterClass(Prevention_Removal, Disaster_Prevention);

local Prevention_Insurance:table = { _ClassName = "Prevention_Insurance", PreventionClass = PreventionClasses.INSURANCE };
RegisterClass(Prevention_Insurance, Disaster_Prevention);

local Prevention_Resistant:table = { _ClassName = "Prevention_Resistant", PreventionClass = PreventionClasses.RESISTANT };
RegisterClass(Prevention_Resistant, Disaster_Prevention);

-- initialize prevention class - get data from DB and check for already existing buildings on the map
-- this will actually be called for each sub-class separately, not for parent object
function Disaster_Prevention:Initialize()
	dprint("FUNCAL Disaster_Prevention:Initialize() (class,buldcl)", self._ClassName, self.PreventionClass);
	-- get data for a specific class
	-- it will be stored in a table indexed by DisasterType
	-- each entry will be a table of: BuildingType, Index, Value, Range
	self.DisasterBuildings = {};
	for buld in GameInfo.RNDDisasterBuildings() do
		if buld.PreventionClass == self.PreventionClass then
			dprint("   ...registering disaster building (class,dis,buld,range,value)", buld.PreventionClass, buld.DisasterType, buld.BuildingType, buld.Range, buld.Value);
			if self.DisasterBuildings[buld.DisasterType] == nil then self.DisasterBuildings[buld.DisasterType] = {}; end
			-- the record below will often be references as 'disbuld'
			local tPreventionBuilding:table = {
				BuildingType = buld.BuildingType,
				BuildingIndex = GameInfo.Buildings[buld.BuildingType].Index, 
				Range = buld.Range,  
				Value = buld.Value,
			};
			-- Range parameter from Advanced Options
			if iRNDConfigRange ~= 0 and buld.Range > 0 then  -- do not adjust -1 (city) and 0 (plot)
				tPreventionBuilding.Range = math.max(0, buld.Range + iRNDConfigRange);
				dprint("      ...adjusted Range is (par,range)", iRNDConfigRange, tPreventionBuilding.Range);
			end
			table.insert(self.DisasterBuildings[buld.DisasterType], tPreventionBuilding);
		end
	end
	--dprint("--- CLASS INITIALIZED ---", self._ClassName);
	--dshowrectable(self);
end

-- simple check if anything is registered for a given Disaster, can save some processing time later
function Disaster_Prevention:HasDisasterPrevention(sDisasterType:string)
	return self.DisasterBuildings[sDisasterType] ~= nil;
end

-- helper - checks if a building is in one of the plots within Range
function Disaster_Prevention:IsBuildingWithinRange(iPlot:number, iRange:number, eBuilding:number, bCheckActive:boolean)
	--dprint("FUNCAL Disaster_Prevention:IsBuildingWithinRange() (class,plot,range,buld,active)", self._ClassName, iPlot, iRange, eBuilding, bCheckActive);
	-- check separately for the plot itself
	if IsPlotIndexHasBuilding(iPlot, eBuilding, bCheckActive) then return true; end
	for plot in PlotAreaSweepIterator(Map.GetPlotByIndex(iPlot), iRange) do -- RND.
		if IsPlotIndexHasBuilding(plot:GetIndex(), eBuilding, bCheckActive) then
			--dprint("   ...found at (x,y)", plot:GetX(), plot:GetY());
			return true;
		end
	end
	--dprint("   ...NOT found in the area");
	return false;
end

-- main function - iterate through all active buildings assigned to a given Disaster and sum all of their prevention values
-- returns (boolean) - prevention active, (number) - sum of prevention values
-- scenarios:
--   plot is not owned - only Range type are valid where Range > 0 (no city, and cannot be 0 because that would mean an actual tile with a building which is always owned)
--   plot is owned - check City (must be the same), check for Range=0 and check for Range>0 same as "plot not owned scenario"
function Disaster_Prevention:GetDisasterPrevention(sDisasterType:string, iPlot:number)
	--dprint("FUNCAL Disaster_Prevention:GetDisasterPrevention() (class,dis,plot)", self._ClassName, sDisasterType, iPlot);
	local tPreventionBuildings:table = self.DisasterBuildings[sDisasterType];
	if tPreventionBuildings == nil then return false, 0; end  -- no building registered for this Disaster Type
	local bPlotOwned:boolean = Map.GetPlotByIndex(iPlot):IsOwned();
	local bActive:boolean = false;
	local iValue:number = 0;
	for _,disbuld in pairs(tPreventionBuildings) do
		--dprint("   ...checking prevention (buld,range,value)", disbuld.BuildingType, disbuld.Range, disbuld.Value);
		-- scenario: check city
		if disbuld.Range < 0 then 
			if bPlotOwned and IsPlotIndexCityHasBuilding(iPlot, disbuld.BuildingIndex, true) then
				--dprint("      ...prevention active - CITY");
				bActive = true; iValue = iValue + disbuld.Value;
			end
		-- scenario: check plot
		elseif disbuld.Range == 0 then 
			if bPlotOwned and IsPlotIndexHasBuilding(iPlot, disbuld.BuildingIndex, true) then
				--dprint("      ...prevention active - PLOT");
				bActive = true; iValue = iValue + disbuld.Value;
			end
		-- scenario: check area in range
		else
			if self:IsBuildingWithinRange(iPlot, disbuld.Range, disbuld.BuildingIndex, true) then
				--dprint("      ...prevention active - RANGE");
				bActive = true; iValue = iValue + disbuld.Value;
			end
		end
	end
	return bActive, iValue;
end

function Disaster_Prevention:ddisplayprevmap(sDisasterType:string)
	dprint("--- DISPLAY PREVENTION ---", self._ClassName, sDisasterType);
	if not self:HasDisasterPrevention(sDisasterType) then dprint("  No registered prevention buildings for (disaster)", sDisasterType); return; end
	local tPlots:table = {};
	for i=0,iMapSize-1 do
		if self:GetDisasterPrevention(sDisasterType,i) then table.insert(tPlots,i); end
	end
	ddisplaymap(tPlots,"XX");
end


-- special case - resistant buildings
function Prevention_Resistant:HasDisasterPrevention(sDisasterType)
	return true;  -- always existing for all disaster types
end

-- must check if modifier PROJECT_DISASTER_RESISTANCE_COMPLETED_MODIFIER is attached to a city
-- there's no building for it, value of prevention is in the code
-- unfortunately we must iterate through all modifiers to find the right one
function Prevention_Resistant:GetDisasterPrevention(sDisasterType:string, iPlot:number)
	--dprint("FUNCAL Prevention_Resistant:GetDisasterPrevention() (class,dis,plot)", self._ClassName, sDisasterType, iPlot);
	if not Map.GetPlotByIndex(iPlot):IsOwned() then return false, 0; end
	local pCity:table = Cities.GetPlotPurchaseCity(iPlot);
	if pCity == nil then return false, 0; end
	local sCityName:string = pCity:GetName();  -- must be equal to modifier's owner name
	dprint("   ...looking for modifiers in city (name)", sCityName);
	-- iterate through all modifiers and check owners
	for _, instanceID in pairs(GameEffects.GetModifiers()) do
		local tInstance:table = GameEffects.GetModifierDefinition(instanceID);
		--if GameEffects.GetObjectType(GameEffects.GetModifierOwner(instanceID)) == "LOC_MODIFIER_OBJECT_CITY" then dprint("   ...found city (name)", GameEffects.GetObjectName(GameEffects.GetModifierOwner(instanceID))); end
		if tInstance.Id == "PROJECT_DISASTER_RESISTANCE_COMPLETED_MODIFIER" then
			local iOwnerID:number = GameEffects.GetModifierOwner(instanceID);
			dprint("   ...found proper modifier (id,type,owner,type,name)", instanceID, tInstance.Id, iOwnerID, GameEffects.GetObjectType(iOwnerID), GameEffects.GetObjectName(iOwnerID));
			if GameEffects.GetObjectType(iOwnerID) == "LOC_MODIFIER_OBJECT_CITY" and GameEffects.GetObjectName(iOwnerID) == sCityName then return true, iPreventionResistantDefaultValue; end
		end
	end
	return false, 0; -- not found = no protection
end


-- ===========================================================================
-- DEVASTATE AND REPORT FUNCTIONS
-- ===========================================================================

EffectClasses = {
	EFFECT_NONE		   = 0,
	EFFECT_UNIT 	   = 1,
	EFFECT_IMPROVEMENT = 2,
	EFFECT_CITY 	   = 3,
	EFFECT_DISTRICT    = 4,
	EFFECT_BUILDING    = 5,
};

-- All data regarding effects of devastations will be kept in effect records:
local Effect_Record:table = { _ClassName = "Effect_Record" };
RegisterClass(Effect_Record, Class_Object);

-- constructor (1) empty record
-- constructor (2) we have plot and magnitude w. prevention
-- constructor (3) we have an owner
function Effect_Record:new(iPlot:number, iMagnitude:number, iPrevention:number, eOwnerID:number, sOwnerCiv:string, sOwnerCity:string, sLocalOwner:string)
	dprint("FUNCAL Effect_Record:new() (plot,magn,pid,civ,cit,own)",iPlot,iMagnitude,eOwnerID,sOwnerCiv,sOwnerCity,sLocalOwner);
	local tObject:table = self:newObject();
	--tObject._ClassName = self._ClassName;
	--setmetatable(tObject, {__index = Effect_Record}); -- this should link a newly created object to table that acts as object class
	-- plot info
	tObject.Plot = 0;				-- what plot index
	tObject.Magnitude = 0;			-- what magnitude was applied
	tObject.Prevention = 0;			-- value of prevention (~=0 if exists)
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
	if iPlot ~= nil and iMagnitude ~= nil and iPrevention ~= nil then
		tObject.Plot = iPlot;
		tObject.Magnitude = iMagnitude;
		tObject.Prevention = iPrevention;
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

-- function to generate desc on-the-fly; needed to properly handle 'unmet player' condition, also should be easier to apply changes if needed
-- [LATER]
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
	--dshowtable(self);
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
		if self.OurOwn then sUnitOwner = "[COLOR_Blue]"..self.UnitOwner.."[ENDCOLOR]";  -- make it green
		elseif bHasMet then sUnitOwner = self.UnitOwner; end  -- we can show the name
		--local iDamage:number, iMaxDamage:number = self.Object:GetDamage(), self.Object:GetMaxDamage();  -- don't need iMaxDamage?
		local iNewDamage:number = self.Object:GetDamage() + (self.Magnitude+self.Prevention);
		if iNewDamage < self.Object:GetMaxDamage() then  -- wounded only
			dprint("  ...damaging unit (player,civ,id) (from,to)", self.UnitOwnerID, self.UnitOwner, self.ID, self.Object:GetDamage(), iNewDamage);
			if bRealEffects then self.Object:SetDamage(iNewDamage); end
			dprint("    ...checking result (id) (new)", self.Object:GetID(), self.Object:GetDamage());
			self.IsDamaged = true;
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_WOUNDED", self.Name, sUnitOwner, self.Magnitude+self.Prevention, self.Prevention);
		else  -- it seems that the unit didn't survived the wounds
		
			-- KILL UNIT
			dprint("  ...destroying unit due to wounds (player,civ,unitid) (from,to)", self.UnitOwnerID, self.UnitOwner, self.ID, self.Object:GetMaxDamage(), iNewDamage);
			--if bRealEffects then UnitManager.Kill(self.UnitOwnerID, self.ID); end
			--if bRealEffects then UnitManager.Kill(self.Object); end
			if bRealEffects then Players[self.UnitOwnerID]:GetUnits():Destroy(self.Object); end
			self.IsDestroyed = true;
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DIED_WOUNDS", self.Name, sUnitOwner, self.Prevention);
		
		end
		
	elseif self.Class == EffectClasses.EFFECT_IMPROVEMENT then
	
		if math.random(0,99) < (self.Magnitude+self.Prevention) then 
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
				self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_PILLAGED", self.Name, self.Prevention);
			end
		else
			dprint("  ...the improvement survived!");
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_SURVIVED", self.Name, self.Prevention);
		end
	
	elseif self.Class == EffectClasses.EFFECT_CITY then
	
		-- DAMAGE City
		-- cannot show sity's name if the owner has not been met
		local bHasMet = Players[Game.GetLocalPlayer()]:GetDiplomacy():HasMet(self.OwnerID);
		local sName = Locale.Lookup("LOC_RNDINFO_UNKNOWN_CITY");
		if self.OurOwn then sName = "[COLOR_Blue]"..self.Name.."[ENDCOLOR]";  -- make it green
		elseif bHasMet then sName = self.Name; end  -- we can show the name
		-- % function will not really work for small cites; Magnitude always shows the power - small cities gets should be wiped out [TODO]
		-- as for now population loss will be proortional to Magnitude i.e. 1 pop for 10 points - easy
		-- even the worst catastrophies will never kill entire city if it's big
		local iCurPop = self.Object:GetPopulation(); 
		local iPopLost = math.floor( iCurPop * (self.Magnitude+self.Prevention)/(100+self.Magnitude+self.Prevention) );
		dprint("  ...damaging city - loss of population (name,pop,lost)", self.Name, iCurPop, iPopLost);
		if iPopLost >= iCurPop then iPopLost = iCurPop - 1; end  -- leave at least 1 pop
		if bRealEffects then self.Object:ChangePopulation((-1)*iPopLost); end
		dprint("    ...checking result (name,pop)", self.Object:GetName(), self.Object:GetPopulation());
		if iPopLost > 0 then
			self.IsDamaged = true;
			self.Desc = Locale.Lookup("LOC_RNDINFO_CITY_LOST_POP", sName, iPopLost, self.Prevention);
		else
			self.Desc = Locale.Lookup("LOC_RNDINFO_CITY_SURVIVED", sName, self.Prevention);
		end
		
	elseif self.Class == EffectClasses.EFFECT_DISTRICT then
	
		-- DAMAGE DISTRICT
		--dprint("  ...damaging district (destroyed if no buildings left and healh < 0)");
		local iTotDmg:number = 0;
		local iMagnPrev:number = self.Magnitude + self.Prevention;
		dprint("  ...damaging district (type,id) (in,out) (maxin,maxout)",
							self.Object:GetType(), self.Object:GetID(),
							self.Object:GetDamage(DefenseTypes.DISTRICT_GARRISON), self.Object:GetDamage(DefenseTypes.DISTRICT_OUTER),
							self.Object:GetMaxDamage(DefenseTypes.DISTRICT_GARRISON), self.Object:GetMaxDamage(DefenseTypes.DISTRICT_OUTER));
		-- we're not going to destroy a district (YET), so there's no need to check if damage will exceed max damage
		-- check if there's inside protection
		if self.Object:GetMaxDamage(DefenseTypes.DISTRICT_GARRISON) > 0 then 
			if bRealEffects then self.Object:ChangeDamage(DefenseTypes.DISTRICT_GARRISON, 2*iMagnPrev); end-- inside def starts with 200, need DefType parameter FIRST
			iTotDmg = iTotDmg + 2*iMagnPrev;
		end
		-- check if there's outside protection
		if self.Object:GetMaxDamage(DefenseTypes.DISTRICT_OUTER) > 0 then  
			if bRealEffects then self.Object:ChangeDamage(DefenseTypes.DISTRICT_OUTER, 1*iMagnPrev); end  -- out def are Walls actually (+150) [TODO - might analyze Walls at start to see how Magnitude relates]
			iTotDmg = iTotDmg + 1*iMagnPrev;
		end
		dprint("    ...checking result (type,id,tot) (in,out)",
							self.Object:GetType(), self.Object:GetID(), iTotDmg,
							self.Object:GetDamage(DefenseTypes.DISTRICT_GARRISON), self.Object:GetDamage(DefenseTypes.DISTRICT_OUTER));
		if iTotDmg > 0 then
			self.IsDamaged = true;
			--self.Desc = self.Name.." [ICON_Pillaged] damaged for "..iTotDmg.." HP";
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DAMAGED_HP", self.Name, iTotDmg, self.Prevention);
		else
			dprint("  ...the district survived!");
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_SURVIVED", self.Name, self.Prevention);
		end
		
	elseif self.Class == EffectClasses.EFFECT_BUILDING then
		-- cannot pillage ALL non-destroyed buildings, must use randomization
		-- they will be pillaged with Magnitude probabbility
		if (math.random(0,99) < (self.Magnitude+self.Prevention)) and GameInfo.Buildings[self.Type].IsWonder == false and self.Type ~= "BUILDING_PALACE" then  -- cannot pillage Wonders and Palace in Version 2.3.0
		--if math.random(0,99) < (self.Magnitude+self.Prevention) then  -- actually, Wonders CAN be pillaged

			-- DAMAGE BUILDING
			dprint("  ...pillaging building (city,name,state)", self.Object:GetName(), self.Name, self.Object:GetBuildings():IsPillaged(self.ID));
			if bRealEffects then self.Object:GetBuildings():SetPillaged(self.ID, true); end
			dprint("    ...checking result (city,name,state)", self.Object:GetName(), self.Name, self.Object:GetBuildings():IsPillaged(self.ID));
			self.IsDamaged = true;
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_PILLAGED", self.Name, self.Prevention);
			
		else
			dprint("  ...the building survived!");
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_SURVIVED", self.Name, self.Prevention);
		end
	else
		print("ERROR: Effect_Record:DamageObject() unknown object class", self.Class);
	end
	-- generate info
	--self.DescLong = self.Desc.." (id="..self.ID..",type="..self.Type..")";
	dprint("  ...effect info after damage (isdmg,desc,long)", self.IsDamaged, self.Desc, self.DescLong);
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
		if self.OurOwn then sUnitOwner = "[COLOR_Blue]"..self.UnitOwner.."[ENDCOLOR]";  -- make it green
		elseif bHasMet then sUnitOwner = self.UnitOwner; end  -- we can show the name
		dprint("  ...destroying unit (player,civ,unitid,plot,state)", self.UnitOwnerID, self.UnitOwner, self.ID, self.Plot, Units.GetUnitByIndexInPlot(self.ID, self.Plot));
		--if bRealEffects then UnitManager.Kill(self.UnitOwnerID, self.ID); end
		--if bRealEffects then UnitManager.Kill(self.Object); end
		Players[self.UnitOwnerID]:GetUnits():Destroy(self.Object);
		dprint("    ...checking result (unitid,plot,state)", self.ID, self.Plot, Units.GetUnitByIndexInPlot(self.ID, self.Plot));
		self.IsDestroyed = true;
		self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_KILLED", self.Name, sUnitOwner, self.Prevention);
		
	elseif self.Class == EffectClasses.EFFECT_IMPROVEMENT then
	
		-- DESTROY IMPROVEMENT
		dprint("  ...destroying improvement at plot (idx,state)", self.Plot, self.Object:GetImprovementType());
		if bRealEffects then ImprovementBuilder.SetImprovementType(self.Object, -1); end
		dprint("    ...checking result at plot (idx,state)", self.Plot, self.Object:GetImprovementType());
		self.IsDestroyed = true;
		self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DESTROYED", self.Name, self.Prevention);
		
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
			self.Desc = Locale.Lookup("LOC_RNDINFO_NAME_DESTROYED", self.Name, self.Prevention);
			
		end
	else
		print("ERROR: Effect_Record:DestroyObject() unknown object class", self.Class);
	end
	-- generate info
	--self.DescLong = self.Desc.." (id="..self.ID..",type="..self.Type..")";
	dprint("  ...effect info after destroy (isdstr,desc,long)", self.IsDestroyed, self.Desc, self.DescLong);
end

-- this function will apply either DamageObject() or DestroyObject() depending on Magnitude and randomization
function Effect_Record:ApplyEffect()
	dprint("FUNCAL Effect_Record:ApplyEffect() (id,magn,prev)", self.ID, self.Magnitude, self.Prevention);
	--dshowtable(self);
	-- first we check for Destroy - it happens in Magnitude/2 percent cases
	if math.random(0,99) < math.floor((self.Magnitude+self.Prevention)/2) then
		self:DestroyObject();
	else
		self:DamageObject();
	end
	-- this line added for save/load - we don't want to store internal game objects (like City, Unit, etc.)
	-- since effect has been applied - we can set it to nil
	-- WARNING! must redesign this if damage will also be possible on TurnEnd? maybe not - could simply create new Effects, like with resources
	self.Object = nil;
end


-- ===========================================================================
-- RESOURCES
-- ===========================================================================

ResourceClasses = {
	STANDARD = 0,		-- always permanent
	TEMPORARY = 1,		-- always temporary
	PERMANENT = 2,		-- perma IF rolled
	SITE_SMALL = 3,		-- always temporary
	SITE_LARGE = 4,		-- always temporary
	SITE_PERMA = 5,		-- perma IF rolled
};

local Effect_Resource:table = { _ClassName = "Effect_Resource" };
RegisterClass(Effect_Resource, Class_Object);

-- init function for a class - must prepare internal data for work
-- loads data from DB mainly
function Effect_Resource:Initialize()
	dprint("FUNCAL Effect_Resource:Initialize()");
	-- first, let's get all Disaster types
	for disaster in GameInfo.RNDDisasters() do
		local tEmptyResources:table = {
			[ResourceClasses.STANDARD] = {},     -- a table of more than 1
			[ResourceClasses.TEMPORARY] = {},    -- a table of more than 1
			[ResourceClasses.PERMANENT] = {},    -- a table of more than 1
			[ResourceClasses.SITE_SMALL] = nil,  -- one only
			[ResourceClasses.SITE_LARGE] = nil,  -- one only
			[ResourceClasses.SITE_PERMA] = nil,  -- one only
		};
		tDisasterResources[disaster.DisasterType] = tEmptyResources;
	end
	-- now, let's iterate through all registered resources
	for res in GameInfo.RNDDisasterResources() do
		if res.ResourceClass == ResourceClasses.STANDARD or res.ResourceClass == ResourceClasses.TEMPORARY or res.ResourceClass == ResourceClasses.PERMANENT then
			table.insert(tDisasterResources[res.DisasterType][res.ResourceClass], res);
		elseif res.ResourceClass == ResourceClasses.SITE_SMALL or res.ResourceClass == ResourceClasses.SITE_LARGE or res.ResourceClass == ResourceClasses.SITE_PERMA then
			tDisasterResources[res.DisasterType][res.ResourceClass] = res;
		else
			print("WARNING Effect_Resource:Initialize(): unknown resource class", res.ResourceClass);
		end
	end	
	-- debug check
	--[[
	for dt,dis in pairs(tDisasterResources) do
		for class,res in pairs(dis) do
			if class > 2 then
				dprint("registered (d,c,r)",dt,class,res.ResourceType);
			else
				for _,r in pairs(res) do dprint("registered (d,c,r)",dt,class,r.ResourceType); end
			end
		end
	end
	--]]
end

-- constructor (0 arg) empty record
-- constructor (1 arg) we have plot
-- constructor (2 arg) for permanent resources - we have plot and a resource
-- constructor (4 arg) for temporary resources - we have plot, resource, flag=true and number of turns>0
function Effect_Resource:new(iPlot:number, sResourceType:string, bTemporary:boolean, iNumTurns:number)
	dprint("FUNCAL Effect_Resource:new() (plot,res,temp,turns)",iPlot,sResourceType,bTemporary,iNumTurns);
	local tObject = self:newObject();
	--tObject._ClassName = self._ClassName;
	--setmetatable(tObject, {__index = self}); -- this should link a newly created object to table that acts as object class
	-- constructor (0 arg)
	tObject.Plot = -1;			-- what plot index
	tObject.Resource = -1;		-- resource index
	tObject.Temporary = false;	-- permanent = false, temporary = true
	tObject.TurnStart = Game.GetCurrentGameTurn();		-- turn no. when placed
	tObject.NumTurns = 0;		-- for how many turns
	tObject.TurnFinish = 0;		-- last turn the resource will be active; always TurnFinish = TurnStart + NumTurns
	tObject.Desc = "";			-- effect short description
	tObject.DescLong = "";		-- effect long description (for debug?)
	-- constructor (1 arg)
	if iPlot ~= nil then
		tObject.Plot = iPlot;			-- what plot index
		-- constructor (2 arg)
		if sResourceType ~= nil then
			tObject.Resource = GameInfo.Resources[sResourceType].Index;
			-- constructor (4 arg), must be >0 to create a temp resource, otherwise will be permanent
			if bTemporary and iNumTurns ~= nil and iNumTurns > 0 then
				tObject.Temporary = true;
				tObject.NumTurns = iNumTurns;						-- for how many turns
				tObject.TurnFinish = tObject.TurnStart + iNumTurns;	-- last turn the resource will be active
			end
		end
	end
	return tObject;
end

-- uses standard tables Resource_ValidFeatures and Resource_ValidFeatures via function MapManager():CanPlaceResource()
-- seems that this function already checks if a Resource or a City exists in a plot - it doesn't check for Districts however
-- these things do not allow for a resource to be placed: Cities, Districts, plots with existing resources
-- impassable terrain/feature - should be addressed via standard tabled (e.g. can add some Natural Wonders)
function Effect_Resource:CanPlaceResourceEffect(iPlot:number, tResEff:table)
	--dprint("FUNCAL Effect_Resource:CanPlaceResourceEffect() (plot,res,land,ocean,fw,nofw)", iPlot, tResEff.ResourceType, tResEff.RequiresLand, tResEff.RequiresOcean, tResEff.FreshWater, tResEff.NoFreshWater);
	local pPlot = Map.GetPlotByIndex(iPlot);
	if pPlot == nil then print("ERROR Effect_Resource:CanPlaceResourceEffect(): plot is nil", iPlot); return false; end  -- should never happen
	--dprint("  ...plot data (x,y,res,city,water,river)",pPlot:GetX(),pPlot:GetY(),pPlot:GetResourceType(),pPlot:IsCity(),pPlot:IsWater(),pPlot:IsRiver());
	-- first check standard tables
	local eResource:number = GameInfo.Resources[tResEff.ResourceType].Index;
	local funCanHaveResource = ( ResourceBuilder.OldCanHaveResource and ResourceBuilder.OldCanHaveResource or ResourceBuilder.CanHaveResource ); -- special compatibility fix for YnAMP
	if not funCanHaveResource(pPlot, eResource) then
		--dprint("  ...can't place: terrain/feature/city/resource problem (plot,terrain,feature)", iPlot, pPlot:GetTerrainType(), pPlot:GetFeatureType());
		return false;
	end
	-- other checks
	if pPlot:GetResourceType() ~= -1 then dprint("  ...can't place: already a resource in place (plot,res)", iPlot, pPlot:GetResourceType()); return false; end
	if pPlot:IsCity() then 				  dprint("  ...can't place: plot taken by a city (plot,city)", iPlot, Cities.GetCityInPlot(iPlot):GetName()); return false; end
	if pPlot:GetDistrictType() ~= -1 then dprint("  ...can't place: plot taken by a district (plot,dis)", iPlot, GameInfo.Districts[pPlot:GetDistrictType()].DistrictType); return false; end
	-- checks from Effect level parameters
	if tResEff.RequiresLand  and pPlot:IsWater() 							then dprint("  ...can't place: requires land, plot is water (plot,water)", iPlot, pPlot:IsWater()); return false; end
	if tResEff.RequiresOcean and pPlot:GetTerrainType() ~= g_TERRAIN_OCEAN  then dprint("  ...can't place: requires (ocean), plot is not (plot,terrain)", g_TERRAIN_OCEAN, iPlot, pPlot:GetTerrainType()); return false; end
	if tResEff.FreshWater    and not IsPlotIndexCloseToFreshWater(iPlot) 	then dprint("  ...can't place: requires fresh water, there's none (plot)", iPlot); return false; end
	if tResEff.NoFreshWater  and IsPlotIndexCloseToFreshWater(iPlot) 		then dprint("  ...can't place: must not be close to fresh water, there's some (plot)", iPlot); return false; end
	-- finally, seems that we can place it!
	dprint("  ...YES, we can place resource (plot,res,idx)", iPlot, tResEff.ResourceType, eResource);
	return true;
end


function Effect_Resource:PlaceOnMap()
	dprint("FUNCAL Effect_Resource:PlaceOnMap() (plot,res)", self.Plot, self.Resource);
	local pPlot = Map.GetPlotByIndex(self.Plot);
	--if bRealEffects then WorldBuilder.MapManager():SetResourceType(pPlot, self.Resource); end
	if bRealEffects then ResourceBuilder.SetResourceType(pPlot, self.Resource, 1); end
	-- check if placed
	local eResource:number = pPlot:GetResourceType();
	if not bRealEffects or eResource == self.Resource then dprint("  ...SUCCESS (plot) has (res)", self.Plot, eResource);
	else print("ERROR: Effect_Resource:PlaceOnMap(): failed to place (res) on (plot)", self.Resource, self.Plot); end  -- should never happen
	if self.NumTurns == 0 then self.Desc = Locale.Lookup("LOC_RNDINFO_RESOURCE_PERMANENT", Locale.Lookup(GameInfo.Resources[self.Resource].Name));
	else					   self.Desc = Locale.Lookup("LOC_RNDINFO_RESOURCE_TEMPORARY", Locale.Lookup(GameInfo.Resources[self.Resource].Name), self.NumTurns); end
	RND.UI.AddWorldViewText(0, self.Desc, self.Plot%iMapWidth, math.floor(self.Plot/iMapWidth), 0);
end

function Effect_Resource:RemoveFromMap()
	dprint("FUNCAL Effect_Resource:RemoveFromMap() (plot,res)", self.Plot, self.Resource);
	local pPlot = Map.GetPlotByIndex(self.Plot);
	local eResource:number = pPlot:GetResourceType();
	if eResource == -1 then dprint("  ...already removed (harvested?)"); return; end
	if eResource ~= self.Resource then dprint("  ...different resource in place", eResource, self.Resource); return; end
	--if bRealEffects then WorldBuilder.MapManager():SetResourceType(pPlot, -1); end
	if bRealEffects then ResourceBuilder.SetResourceType(pPlot, -1); end
	-- check if removed
	eResource = pPlot:GetResourceType();
	if not bRealEffects or eResource == -1 then dprint("  ...SUCCESS (res) removed from (plot)", self.Resource, self.Plot);
	else print("ERROR: Effect_Resource:RemoveFromMap(): failed to remove (res) from (plot)", self.Resource, self.Plot); end  -- should never happen
end

-- iterate through Temp Effects and remove ones that expired
function Effect_Resource:RemoveExpiredResources()
	dprint("FUNCAL Effect_Resource:RemoveExpiredResources() (num,turn)", table.count(tTemporaryResources), Game.GetCurrentGameTurn());
	local iCurTurn:number = Game.GetCurrentGameTurn();
	local tNotExpired:table = {};  -- will move not expired to the new one to avoid using table.remove
	for _,effect in pairs(tTemporaryResources) do
		dprint("  checking (res,plot,turn)", GameInfo.Resources[effect.Resource].ResourceType, effect.Plot, effect.TurnFinish);
		if iCurTurn < effect.TurnFinish then
			dprint("  not expired (res,plot,turn)", GameInfo.Resources[effect.Resource].ResourceType, effect.Plot, effect.TurnFinish);
			-- not expired yet
			table.insert(tNotExpired, effect);
		else
			dprint("  expired (res,plot,turn)", GameInfo.Resources[effect.Resource].ResourceType, effect.Plot, effect.TurnFinish);
			-- expired
			effect:RemoveFromMap();
		end
	end
	tTemporaryResources = tNotExpired;
end

function Effect_Resource:ClearMap()
	dprint("FUNCAL Effect_Resource:ClearMap()");
	if bMapCleared then print("WARNING Effect_Resource:ClearMap(): map has already been cleared"); return; end
	-- create a table of new disaster resources
	local tNewDisRes:table = {};
	for _,row in pairs(DB.Query("SELECT DISTINCT ResourceType FROM RNDDisasterResources WHERE ResourceClass != 0")) do
		table.insert(tNewDisRes, GameInfo.Resources[row.ResourceType].Index);
	end
	-- debug
	dprint("Found (n) new disaster resources:", table.count(tNewDisRes));
	for _,r in pairs(tNewDisRes) do dprint("  ...", GameInfo.Resources[r].ResourceType); end
	-- iterate through the map
	for i = 0, iMapSize-1 do
		local pPlot = Map.GetPlotByIndex(i);
		if pPlot and IsInTable(tNewDisRes, pPlot:GetResourceType()) then
			dprint("...clearing (x,y,res)", pPlot:GetX(), pPlot:GetY(), GameInfo.Resources[pPlot:GetResourceType()].ResourceType);
			ResourceBuilder.SetResourceType(pPlot, -1);  -- [TODO] this might change balance a little, should actually change it into one of bonus resources
		end
	end
	bMapCleared = true;
end



-- ===========================================================================
-- VFX HELPERS
-- ===========================================================================

-- time helpers
local fStartTime:number = 0;
local bTimerActive:boolean = false;
function TimerStart()
	fStartTime = Automation.GetTime();
	bTimerActive = true;
	--dprint("FUNEND TimerStart() (start,active)", fStartTime, bTimerActive);
end
function TimerWaitTillSeconds(fSec:number)
	if fSec < 0 then return; end
	if not bTimerActive then return; end  -- check to prevent from infinite loop! MUST call TimerStart first
	while Automation.GetTime() < fStartTime + fSec * 1.0 do math.sqrt(Automation.GetTime()); end  -- do NOTHING!
	--dprint("FUNEND TimerWaitTillSeconds() (lapse)", Automation.GetTime()-fStartTime);
end
function TimerStop()
	bTimerActive = false;
	--dprint("FUNEND TimerStop() (stop,active)", Automation.GetTime(), bTimerActive);
end
function WaitSeconds(fSec:number)
	if fSec < 0 then return; end
	local fStopTime:number = Automation.GetTime() + fSec * 1.0;
	while Automation.GetTime() < fStopTime do math.sqrt(Automation.GetTime()); end  -- do NOTHING!
end
--[[
function WaitSeconds(fSec:number)
	dprint("FUNCAL WaitSeconds() (sec)", fSec);
	if fSec < 0 then return; end
	TimerStart();
	for i=0,math.floor(fSec*10),1 do
		dprint("   ...waiting (sec)", i/10);
		TimerWaitTillSeconds(i/10);
	end
	TimerStop();
	--local fStopTime:number = Automation.GetTime() + fSec * 1.0;
	--while Automation.GetTime() < fStopTime do math.sqrt(Automation.GetTime()); end  -- do NOTHING!
end
--]]


-- camera helpers
local fCameraX:number, fCameraY:number = 0.0, 0.0;
local iCameraX:number, iCameraY:number = 0, 0;
function CameraFreeze()
	fCameraX, fCameraY = RND.UI.GetMapLookAtWorldTarget();
	iCameraX, iCameraY = RND.UI.GetPlotCoordFromWorld(fCameraX, fCameraY);
	dprint("FUNCAL CameraFreeze() (x,y)", iCameraX, iCameraY);
end
function CameraMoveToPlotXY(iX:number, iY:number)
	--local iWX:number, iWY:number, iWZ:number = RND.UI.GridToWorld(iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
	dprint("FUNCAL CameraMoveToPlotXY() (x,y)", iX, iY);
	RND.UI.LookAtPlot(iX, iY);
	RND.UI.SetMapZoom(0.7);
	--LuaEvents.RNDInfoPopup_CameraMove(iX,iY);
end
function CameraMoveToPlotIndex(iPlot:number)
	dprint("FUNCAL CameraMoveToPlotIndex() (plot)", iPlot);
	CameraMoveToPlotXY(iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
end
function CameraUnfreeze()
	dprint("FUNCAL CameraUnfreeze() (x,y)", iCameraX, iCameraY);
	RND.UI.LookAtPlot(iCameraX, iCameraY);
end


function CanSeePlot(x, y)
	local pPlayerVis = PlayerVisibilityManager.GetPlayerVisibility(Game.GetLocalObserver());
	if (pPlayerVis ~= nil) then return pPlayerVis:IsVisible(x, y); end
	return false;
end	


-- creates asset and sets scale; scale can vary randomly if fScaleMax is provided
function CreateAssetPreviewWithScale(sAssetType:string, fX:number, fY:number, fZ:number, fScale:number, fScaleMax:number)
	local scale:number = fScale;
	if fScaleMax ~= nil then scale = fScale + (fScaleMax-fScale)*math.random(); end
	local id:number = RND.AssetPreview.Create(sAssetType, fX, fY, fZ);
	RND.AssetPreview.SetInstanceScale(id, scale);
end

function CreateAssetPreviewRandomInCircle(sAssetType:string, fRadius:number, fWX:number, fWY:number, fWZ:number, fScale:number, fScaleMax:number)
	local dx:number, dy:number = GetRandomCoorsInCircle(fRadius);
	CreateAssetPreviewWithScale(sAssetType, fWX+dx, fWY+dy, fWZ, fScale, fScaleMax);
end


-- ===========================================================================
-- DISASTER PLOT
-- ===========================================================================

-- t.b.d.




-- ===========================================================================
--[[ GUTENBERG RICHTER
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
--]]
-- ===========================================================================
-- formula for table: sum(exp(-0,02829*magnitude+7,86))
--                            0,  10,  20,  30,  40,  50,  60,  70,  80,  90,  100
local tParamsForGutRich = {2579,4523,5987,7091,7923,8550,9022,9378,9646,9848,10000};

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


-- ===========================================================================
-- DISASTER OBJECT
--[[ DATA DESCRIPTION
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
-- ===========================================================================
local Disaster_Object = { _ClassName = "Disaster_Object", Type = "DISASTER_TYPE" };  -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Object, Class_Object);

-- loads parameters from database
-- this function assumes that Type is properly set for a disaster bo be initialized
function Disaster_Object:Initialize()
	dprint("FUNCAL Disaster_Object:Initialize() (type)", self.Type);
	local tDisaster = GameInfo.RNDDisasters[self.Type];
	if tDisaster == nil then print("ERROR: Disaster_Object:Initialize() cannot load parameters for", self.Type); return; end
	-- loaded from DB
	self.Type = tDisaster.DisasterType;
	self.Name = tDisaster.Name;								-- later change to LOC_
	--self.Description = tDisaster.Description;				-- from GameInfo; later change to LOC_
	--self.Icon = tDisaster.Icon;							-- from GameInfo; graphical sign of the disaster;
	self.Range = math.max(tDisaster.Range+iRNDConfigRange, 1);  -- determines the area of the disaster - meaning varies for each type; should be at least 1
	self.BaseProbability  = tDisaster.BaseProbability;		-- probability of an event for a tile that can spawn it per one turn * 1000000
	self.DeltaProbability = tDisaster.DeltaProbability;		-- range min/max
	self.BaseMagnitude = math.max(tDisaster.BaseMagnitude+iRNDConfigMagnitude, 20); -- magnitude of a devastation applied for a tile that started the event; should be at least 20
	self.MagnitudeMax  = math.max(tDisaster.MagnitudeMax +iRNDConfigMagnitude, 20);	-- max magnitude - no upper limit, can get 100% probabilities
	self.MagnitudeMin  = tDisaster.MagnitudeMin;			-- if gets less than that it's either bumped or stopped; even the slightest event should cause at least some damage, so default is to bump
	self.MagnitudeChange = tDisaster.MagnitudeChange;		-- magnitude change for each tile far away from starting tile
	self.MaxTurns = tDisaster.MaxTurns;						-- how many turns lasts (NOT USED)
	--self.ColorNow = tDisaster.ColorNow;					-- from GameInfo; color for the current event
	--self.ColorRisk = tDisaster.ColorRisk;					-- from GameInfo; color for a risk area; will get them later using UI.GetColorValue()
	--self.ColorHistoric = tDisaster.ColorHistoric;			-- from GameInfo; color for a historic event (NOT USED)
	self.Sound = tDisaster.Sound;							-- sound for the event
	-- operational data - SOME WILL BE LOADED IF SAVE FILES WILL BE IMPLEMENTED
	self.StartPlots = {};									-- Indices of possible starting plots
	self.NumStartPlots = 0;									-- Num of possible starting plots
	self.StartingPlot = -1;									-- Index of the starting plot for a new event
	self.StartingMagnitude = -1;							-- Event's power
	--self.HistoricEvents = {};								-- FOR FUTURE - list of old events
	self.HistoricStartingPlots = {};						-- a list of indices of starting plots from old events
	tHistoricStartingPlots[self.Type] = self.HistoricStartingPlots;	-- will be also stored in table for load/save purposes
end

-- changes parameters according to the map size of num of disasters
function Disaster_Object:AdjustProbability(fAdjustment:number)
	--self.BaseProbability = math.max(math.floor(self.BaseProbability * fAdjustment), 1);  -- we need at least 1/1000000 chance
	self.BaseProbability = math.floor(self.BaseProbability * fAdjustment);  -- we allow for 0 probabbility if someone will want to play a modpack that includes RND but doesn't want RND itself (Ananse's request)
	self.DeltaProbability = math.floor(self.DeltaProbability * fAdjustment);
end

-- iterate through entire map and find suitable StartPlots
function Disaster_Object:DetectStartPlots()
	dprint("FUNCAL Disaster_Object:DetectStartPlots() (type)", self.Type);
	self.StartPlots = {};  -- disregard any existing start plots
	for i = 0, iMapSize-1, 1 do 
		local pPlot:table = Map.GetPlotByIndex(i);
		if pPlot and self:CheckPlotForPossibleStart(pPlot) then table.insert(self.StartPlots, i); end
	end
	self.NumStartPlots = table.count(self.StartPlots);
	dprint("   ...found (num) start plots", self.NumStartPlots);
end

-- helper
function Disaster_Object:GetNumAdjacentDisasterStartPlots(iPlot:number)
	return CountAdjacentToPlotIndex(iPlot, function (iAdjPlot:number) return IsInTable(self.StartPlots, iAdjPlot); end);
end

-- Remove start tiles that have less than iMinAdjacent start tiles
-- can be used to remove singular tiles (iMinAdjacent=1) or 2-tile-areas (iMinAdjacent=2)
function Disaster_Object:RemoveStartPlots(iMinAdjacent:number)
	dprint("FUNCAL Disaster_Object:RemoveStartPlots() (class,num)", self._ClassName, self.NumStartPlots);
	local tTempStartPlots:table = {};
	for _,iPlot in pairs(self.StartPlots) do
		if self:GetNumAdjacentDisasterStartPlots(iPlot) >= iMinAdjacent then
			table.insert(tTempStartPlots, iPlot);
		else
			dprint("   ...removing plot (x,y)", iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
		end
	end
	self.StartPlots = tTempStartPlots;
	self.NumStartPlots = table.count(self.StartPlots);
	dprint("   ...after removing found (num) start plots", self.NumStartPlots);
end


-- PREVENTION - REMOVE START PLOTS
-- code to remove from StartPlots tiles that are protected from a given Disaster
-- must create an updated list of possible StartPlots
function Disaster_Object:GetStartPlotsWithPrevention()
	dprint("FUNCAL Disaster_Object:GetStartPlotsWithPrevention() (type,num)", self.Type, table.count(self.StartPlots));
	if not Prevention_Removal:HasDisasterPrevention(self.Type) then return self.StartPlots; end
	local tStartPlotsWithPrevention:table = {};
	for _,plot in pairs(self.StartPlots) do
		-- prevention from Removal class means that the plot CANNOT be a StartPlot
		if not Prevention_Removal:GetDisasterPrevention(self.Type, plot) then table.insert(tStartPlotsWithPrevention, plot); end
	end
	dprint("  ...removed (prev) plots, returning (num) plots", table.count(self.StartPlots)-table.count(tStartPlotsWithPrevention), table.count(tStartPlotsWithPrevention));
	return tStartPlotsWithPrevention;
end


function Disaster_Object:CheckIfHappened(bReallyCheck:boolean)
	dprint("FUNCAL Disaster_Object:CheckIfHappened() (type,base,delta,plots,real)", self.Type, self.BaseProbability, self.DeltaProbability, self.NumStartPlots, bReallyCheck);
	
	-- very rare, should not happen in normal circumstances but it's not an error
	if self.NumStartPlots == 0 then print("WARNING Disaster_Object:CheckIfHappened(): no start plots for disaster", self.Name); return false; end  
	
	local tStartPlotsWithPrevention:table = self:GetStartPlotsWithPrevention();
	if table.count(tStartPlotsWithPrevention) == 0 then dprint("  ...all possible start plots removed due to prevention measures"); return false; end
	
	-- generic as of now, later some specific events might require specific function at Disater level
	local iRealBase = self.BaseProbability + math.random(-self.DeltaProbability, self.DeltaProbability);  -- base is little randomized each turn different
	local iRealProb = iRealBase * table.count(tStartPlotsWithPrevention); -- self.NumStartPlots;  -- its *1000000
	--local iRand = math.random(1000000);
	dprint("  ...checking probability", string.format("%.1f%%", iRealProb/10000));
	-- it DOESN'T happen only if REAL check and BAD (>) roll
	if bReallyCheck and math.random(1000000) > iRealProb then return false; end
	
	-- generate a starting plot and magnitude
	self.StartingPlot = tStartPlotsWithPrevention[math.random(table.count(tStartPlotsWithPrevention))];  -- indices are numbered from 1..n and random returns 1..n
	--self.StartingMagnitude = self.BaseMagnitude + math.random( -self.MagnitudeMax, self.MagnitudeMax );  -- Base +/- random Range
	-- here the use of new algorithm based on Gutenberg-Richter relation
	local iRandMagn = GetRandomMagnitudeWithGutenbergRichter();
	local iMagnitude:number = iRandMagn * (self.MagnitudeMax - self.BaseMagnitude)/100;  -- scale to desired range
	iMagnitude = iMagnitude + Game.GetCurrentGameTurn() / (iTurnsForMagnitudeIncrease*(iGameSpeedMultiplier/100.0));  -- increase with game progress
	--iMagnitude = math.floor((iMagnitude*2)/10)*5;  -- round down to multiple of 5
	self.StartingMagnitude = self.BaseMagnitude + math.floor(iMagnitude);  -- round down
	dprint("  ...HAPPENED @(idx,x,y) with magn(base,rand,start)",
		self.StartingPlot, self.StartingPlot%iMapWidth, math.floor(self.StartingPlot/iMapWidth),
		self.BaseMagnitude, iRandMagn, self.StartingMagnitude);
	return true;  -- TRUE if not-really-checking or really happened
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
		for plot in PlotRingIterator(pStartingPlot, distance) do  -- we don't need starting sector nor anticlockwise - just the ring
			--dprint("  ...(ring): adding plot (idx,x,y,magn)", distance, plot:GetIndex(), plot:GetX(), plot:GetY(), iMagnitude);
			table.insert(pDisaster.Plots, plot:GetIndex());
			table.insert(pDisaster.Magnitudes, iMagnitude);
		end
	end
end	

-- main function to apply effects
-- will go through all plots
function Disaster_Object:EventExecute(tTheDisaster:table) -- so it can be called from tTheDisaster as well
end

-- show floating text above disaster plots
-- but not all - too many - every 2nd one
--[[
function Disaster_Object:AddWorldViewText(pDisaster:table)
	local pPlayerVisibility = PlayersVisibility[Game.GetLocalPlayer()];
	local sDisName:string = Locale.Lookup(pDisaster.DisasterType.Name);
	for i,iPlot in pairs(pDisaster.Plots) do
		if pPlayerVisibility:IsRevealed(iPlot) and (i%2 == 0) then
			local sInfo:string = sDisName.." [COLOR_Red]"..tostring(pDisaster.Magnitudes[i]).."[ENDCOLOR]";
			RND.UI.AddWorldViewText(0, sInfo, iPlot%iMapWidth, math.floor(iPlot/iMapWidth), 0);
		end
	end
end
--]]
-- calculate average x and y
-- when looking: move camera 2 tiles to the right (so the map will scroll to the LEFT) - there's RNDInfoPopup on the right
--[[
function Disaster_Object:GetDisasterAreaCenterPlot(pDisaster:table)
	local iX:number, iY:number = 0, 0;
	for _,iPlot in pairs(pDisaster.Plots) do
		iX = iX + iPlot%iMapWidth;
		iY = iY + math.floor(iPlot/iMapWidth);
	end
	iX = math.floor(iX / table.count(pDisaster.Plots));
	iY = math.floor(iY / table.count(pDisaster.Plots));
	return iX, iY;
end
--]]

-- VFX
-- if disaster is visible, we'll look at it
function Disaster_Object:VisualizeDisaster(pDisaster:table)
	dprint("FUNCAL Disaster_Object:VisualizeDisaster() (class)", self._ClassName);
	if pDisaster:IsDisasterVisible() then
		local iX, iY = pDisaster:GetDisasterAreaCenterPlot();
		CameraMoveToPlotXY(iX+1, iY);
	end
	RND.ModLens_SetTheDisasterHexes(false);
	pDisaster:AddWorldViewText();
end

-- VFX
function Disaster_Object:FinishVisualizeDisaster(pDisaster:table)
	dprint("FUNCAL Disaster_Object:FinishVisualizeDisaster() (class)", self._ClassName);
	RND.AssetPreview.DestroyAll();
end



-- ===========================================================================
-- EARTHQUAKE
-- ===========================================================================
local Disaster_Earthquake = { _ClassName = "Disaster_Earthquake", Type = "DISASTER_EARTHQUAKE" };  -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Earthquake, Disaster_Object);
tDisasterTypes.Disaster_Earthquake = Disaster_Earthquake;	

function Disaster_Earthquake:CheckPlotForPossibleStart(pCheckPlot:table)
	-- hills and mountains are possible starts
	if not IsPlotMountainOrHills(pCheckPlot) then return false; end
	-- ...but should eliminate lonely mountains or hills for sure
	local iAdjMH:number = CountAdjacentToPlot(pCheckPlot, IsPlotIndexMountainOrHills);
	if iAdjMH == 0 then return false; end
	-- hills must be close to each other, at least adjacent to 2 other; this will eliminate lonely ones and very short mountain ranges
	if pCheckPlot:IsHills() then return iAdjMH > 1; else return true; end
end

-- EMPIRICAL SMOOTHING - needs to be done AFTER StartPlots are ready
-- If tile is surrounded by 4 or more Earthquake tiles, consider it a StartPlot; creates a better looking "rifts" on continents
function Disaster_Earthquake:SmoothStartPlots()
	dprint("FUNCAL Disaster_Earthquake:SmoothStartPlots() (num)", self.NumStartPlots);
	local tTempStartPlots:table = {};
	for iPlot = 0, iMapSize-1, 1 do
		if (not IsInTable(self.StartPlots, iPlot)) and self:GetNumAdjacentDisasterStartPlots(iPlot) > 3 then
			dprint("   ...adding plot (x,y)", iPlot%iMapWidth, math.floor(iPlot/iMapWidth)); 
			table.insert(tTempStartPlots, iPlot);
		end
	end
	for _,iPlot in pairs(tTempStartPlots) do table.insert(self.StartPlots, iPlot); end
	--dprint("   ...added (num) tiles surrounded by 4 or more Earthquake tiles", table.count(tTempStartPlots));
	self.NumStartPlots = table.count(self.StartPlots);
	dprint("   ...after smoothing found (num) start plots", self.NumStartPlots);
end


-- VFX
function Disaster_Earthquake:VisualizeDisaster(pDisaster:table)
	dprint("FUNCAL Disaster_Earthquake:VisualizeDisaster()");

	local function PlotVFXDevastation(iX:number, iY:number)
		local pPlot = Map.GetPlot(iX,iY);
		if pPlot:IsWater() or IsPlotMountain(pPlot) then return; end;
		local fWX:number, fWY:number, fWZ:number = RND.UI.GridToWorld(iX,iY);
		fWZ = 4.0;
		CreateAssetPreviewWithScale("FX_Wonder_Pyramid_Dust_Big", fWX, fWY, fWZ, 1.7);
		CreateAssetPreviewRandomInCircle("FX_Campfire_Tribal", 30, fWX, fWY, fWZ, 1.0, 2.0);
		CreateAssetPreviewRandomInCircle("FX_Campfire_Tribal", 30, fWX, fWY, fWZ, 1.0, 2.0);
		CreateAssetPreviewRandomInCircle("FX_Campfire_Tribal", 30, fWX, fWY, fWZ, 1.0, 2.0);
		CreateAssetPreviewRandomInCircle("FX_Wonder_Work_Dust", 30,	fWX, fWY, fWZ, 0.7, 1.0);  
		CreateAssetPreviewRandomInCircle("FX_Wonder_Work_Dust", 30, fWX, fWY, fWZ, 0.7, 1.0);  
		CreateAssetPreviewRandomInCircle("FX_Wonder_Work_Dust", 30, fWX, fWY, fWZ, 0.7, 1.0);  
	end
	
	local iX:number, iY:number = pDisaster.StartingPlot%iMapWidth, math.floor(pDisaster.StartingPlot/iMapWidth);
	if pDisaster:IsDisasterVisible() then CameraMoveToPlotXY(iX+1, iY); end
	for _, iPlot in pairs(pDisaster.Plots) do
		PlotVFXDevastation(iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
	end

end


-- ===========================================================================
-- FLOOD
-- ===========================================================================
local Disaster_Flood = { _ClassName = "Disaster_Flood", Type = "DISASTER_FLOOD" };  -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Flood, Disaster_Object);
tDisasterTypes.Disaster_Flood = Disaster_Flood;	

function Disaster_Flood:CheckPlotForPossibleStart(pCheckPlot:table)
	-- Rivers - but only if another river is adjacent, and Lakes [Lakes are very rare anyway]
	-- Seems that Rivers always come in pairs or even threes due to the fact that they flow between tiles actually
	-- also, must remove plots with Mountain and Hills(!) and Snow
	-- ...and a VERY RARE case when a lake/river tile is surrounded by 6 hills/mountains (flood has nowhere to go)
	if pCheckPlot:IsHills() or IsPlotMountain(pCheckPlot) or pCheckPlot:GetTerrainType() == g_TERRAIN_SNOW then return false; end
	if pCheckPlot:IsRiver() or pCheckPlot:IsLake() then
		return CountAdjacentToPlot(pCheckPlot, IsPlotIndexMountainOrHills) ~= 6;  -- NOTE! cannot use IsPlotFlatlands because it excludes Lakes
	end
	return false;
	--return pCheckPlot:IsRiver() or pCheckPlot:IsLake();
		--if not (IsPlotMountain(pCheckPlot) or pCheckPlot:IsHills()) then 
			-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
			--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Flood");
			--table.insert(self.StartPlots, pCheckPlot:GetIndex());
			--self.NumStartPlots = self.NumStartPlots+1;
		--end
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
		local iAdjPlot = GetAdjacentPlotIndex(self.StartingPlot, direction % DirectionTypes.NUM_DIRECTION_TYPES);
		-- second plot must also be a possible starting plot!
		if IsInTable(self.StartPlots, iAdjPlot) then iSecondStartingPlot = iAdjPlot; break; end
		--local testPlot = Map.GetPlotByIndex(iAdjPlot);
		--dprint("    ...at (dir) there is (river,lake) ", direction % DirectionTypes.NUM_DIRECTION_TYPES, testPlot:IsRiver(), testPlot:IsLake());
		--if testPlot ~= nil and (testPlot:IsRiver() or testPlot:IsLake()) then
		--	iSecondStartingPlot = testPlot:GetIndex();
		--	break;
		--end
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
local Disaster_Meteor = { _ClassName = "Disaster_Meteor", Type = "DISASTER_METEOR" }; -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Meteor, Disaster_Object);
tDisasterTypes.Disaster_Meteor = Disaster_Meteor;

function Disaster_Meteor:CheckPlotForPossibleStart(pCheckPlot:table)
	-- basically Everywhere but we don't want to have empty hits in the game
	-- the condition will be: land (inc. lakes) or coastal water
	return (not pCheckPlot:IsWater()) or pCheckPlot:GetTerrainType() == g_TERRAIN_COAST or pCheckPlot:IsLake();
		--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Meteor");
		--table.insert(self.StartPlots, pCheckPlot:GetIndex());
		--s-elf.NumStartPlots = self.NumStartPlots+1;
	--end
end

-- VFX
function Disaster_Meteor:VisualizeDisaster(pDisaster:table)
	dprint("FUNCAL Disaster_Meteor:VisualizeDisaster()");

	local function PlotVFXMeteorShards(iX:number, iY:number)
		local pPlot = Map.GetPlot(iX,iY);
		if pPlot:IsWater() or IsPlotMountain(pPlot) then return; end;
		local fWX:number, fWY:number, fWZ:number = RND.UI.GridToWorld(iX,iY);
		fWZ = 5.0;
		if pPlot:IsHills() then fWZ = 7.0; end
		CreateAssetPreviewWithScale("FX_Improvement_Birth_01", fWX, fWY, fWZ, 1.2);
		CreateAssetPreviewWithScale("VIL_Tribal_Thatch_0"..math.random(1,3), fWX, fWY, fWZ, 1.2);  -- random asset, 01|02|03
		--RES_Uranium_Rock_Bld_A, B, C
		CreateAssetPreviewRandomInCircle("RES_Uranium_Rock_Bld_A", 32, fWX, fWY, fWZ, 0.8, 1.2);
		CreateAssetPreviewRandomInCircle("RES_Uranium_Rock_Bld_A", 32, fWX, fWY, fWZ, 0.8, 1.2);
		CreateAssetPreviewRandomInCircle("RES_Uranium_Rock_Bld_B", 32, fWX, fWY, fWZ, 0.8, 1.2);
		CreateAssetPreviewRandomInCircle("RES_Uranium_Rock_Bld_B", 32, fWX, fWY, fWZ, 0.8, 1.2);
		CreateAssetPreviewRandomInCircle("RES_Uranium_Rock_Bld_C", 32, fWX, fWY, fWZ, 0.8, 1.2);
		CreateAssetPreviewRandomInCircle("RES_Uranium_Rock_Bld_C", 32, fWX, fWY, fWZ, 0.8, 1.2);
	end
	
	local function PlotVFXMeteorHit(iX:number, iY:number)
		local fWX:number, fWY:number, fWZ:number = RND.UI.GridToWorld(iX,iY);
		CreateAssetPreviewWithScale("FX_District_Birth_01", fWX, fWY, 4.0, 4.0);
		CreateAssetPreviewWithScale("FX_Explo_Fuel_Metal", fWX, fWY, 4.0, 2.0);
	end
	
	local iX:number, iY:number = pDisaster.StartingPlot%iMapWidth, math.floor(pDisaster.StartingPlot/iMapWidth);
	if pDisaster:IsDisasterVisible() then CameraMoveToPlotXY(iX+1, iY); end
	PlotVFXMeteorHit(iX, iY);
	for _, iPlot in pairs(pDisaster.Plots) do
		PlotVFXMeteorShards(iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
	end
	
end


-- ===========================================================================
-- TORNADO
-- ===========================================================================
local Disaster_Tornado = { _ClassName = "Disaster_Tornado", Type = "DISASTER_TORNADO" }; -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Tornado, Disaster_Object);
tDisasterTypes.Disaster_Tornado = Disaster_Tornado;

function Disaster_Tornado:CheckPlotForPossibleStart(pCheckPlot:table)
	-- only for latitudes in range 20..60
	local iPlotAbsLat:number = math.abs( GetLatitudeForY(pCheckPlot:GetY()) );
	if iPlotAbsLat < 20 or iPlotAbsLat > 60 then return false; end
	-- Flat Land only... [DONE] must check for Natural Wonders Mountain-like as well
	--if pCheckPlot:IsWater() or pCheckPlot:IsHills() or IsPlotMountain(pCheckPlot) then return false; end
	if not IsPlotFlatlands(pCheckPlot) then return false; end
	-- ...also cannot start on the CoastLand
	if pCheckPlot:IsCoastalLand() then return false; end
	-- ...but it has to have at least 2-3 other flat tiles adjacent - so it can move!
	return CountAdjacentToPlot(pCheckPlot, IsPlotIndexFlatlands) > 2;
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
local Disaster_Tsunami = { _ClassName = "Disaster_Tsunami", Type = "DISASTER_TSUNAMI" };			-- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Tsunami, Disaster_Object);
tDisasterTypes.Disaster_Tsunami = Disaster_Tsunami;

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

--[[ Version 2 - deep ocean tiles with 2 tiles of water to the nearest land - MIGHT ADJUST TO MAP SIZE IF NECESSARY
-- TODO - eliminate 1-tile Islands from NearestLand
function Disaster_Tsunami:CheckPlotForPossibleStart(pCheckPlot:table)
	if not pCheckPlot:IsWater() then return false; end  -- land cannot generate tsunami
	if pCheckPlot:GetFeatureType() ~= g_FEATURE_NONE then return false; end  -- ALL Features on water must be taken out (e.g. Ice, Barrier Reef, Galapagos Islands)
	if pCheckPlot:GetTerrainType() ~= g_TERRAIN_OCEAN then return false; end  -- only deep ocean can generate tsunami
	-- ...but it needs to be 2 or 3 tiles from the land
	local iX, iY = pCheckPlot:GetX(), pCheckPlot:GetY();
	local pLand = pCheckPlot:GetNearestLandPlot();
	if pLand == nil then print("ERROR Disaster_Tsunami:CheckPlotForPossibleStart() cannot find Land"); return false; end
	local iDist = Map.GetPlotDistance(iX, iY, pLand:GetX(), pLand:GetY());
	if iDist ~= 3 then return false; end
	-- also, exclude tiles close to ICE (never heard of sub-polar tsunami)
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		local testPlot:table = Map.GetAdjacentPlot(iX, iY, direction);
		if testPlot and testPlot:GetFeatureType() == g_FEATURE_ICE then return false; end
	end
	return true;
end
--]]

-- Version 3
-- Ocean tiles with 2 tiles of water to the nearest land
-- Also, for simplicity Latitude < 80 (should eliminate sub-polar areas)
-- Key change - own function to calculate distance to nearest land, should disregard 1- and 2-tile islands and shorten peninsulas

function Disaster_Tsunami:InitializeNearestLand()
	self.LandTiles = {};
	for i = 0, iMapSize-1, 1 do
		local pPlot:table = Map.GetPlotByIndex(i);
		if pPlot and ( not pPlot:IsWater() ) and
			( CountAdjacentToPlot(pPlot, function (iAdjPlot:number) return Map.GetPlotByIndex(iAdjPlot):IsWater(); end) < 5 ) then
			table.insert(self.LandTiles, i);
		end
	end
end

function Disaster_Tsunami:GetDistanceToNearestLand(pStartingPlot:table)
	if not pStartingPlot:IsWater() then return 0; end
	-- iterate through Rings
	for distance = 1, math.max(iMapWidth, iMapHeight), 1 do  -- precaution so there won't be any infinite loop in case of some stupid maps
		for plot in PlotRingIterator(pStartingPlot, distance) do  -- we don't need starting sector nor anticlockwise - just the ring
			if IsInTable(self.LandTiles, plot:GetIndex()) then return distance; end  -- finish everything as soon as a tile in LandTiles is found
		end
	end
	return math.max(iMapWidth, iMapHeight) + 1;  -- stupid map
end

function Disaster_Tsunami:CheckPlotForPossibleStart(pCheckPlot:table)
	-- simple checks to eliminate easy tiles
	if not pCheckPlot:IsWater() then return false; end  -- land cannot generate tsunami
	if pCheckPlot:GetTerrainType() ~= g_TERRAIN_OCEAN then return false; end  -- only deep ocean can generate tsunami
	if pCheckPlot:GetFeatureType() ~= g_FEATURE_NONE then return false; end  -- ALL Features on water must be taken out (e.g. Ice, Barrier Reef, Galapagos Islands)
	if math.abs(GetLatitudeForY(pCheckPlot:GetY())) > 75 then return false; end  -- sub-polar caps
	-- now the difficult part
	if self.LandTiles == nil then self:InitializeNearestLand(); end
	if self:GetDistanceToNearestLand(pCheckPlot) == 3 then return true; end
	return false;
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
local Disaster_Volcano = { _ClassName = "Disaster_Volcano", Type = "DISASTER_VOLCANO" };  -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Volcano, Disaster_Object);
tDisasterTypes.Disaster_Volcano = Disaster_Volcano;

function Disaster_Volcano:CheckPlotForPossibleStart(pCheckPlot:table)
	-- only mountains are possible starts -- we EXCLUDE NATURAL WONDER type mountains
	return pCheckPlot:IsMountain();
		-- add to the list of possible starts (holds IDs so then can be used directly by Lenses)
		--dprint("Start plot(id,x,y)", pCheckPlot:GetIndex(), pCheckPlot:GetX(), pCheckPlot:GetY(), "Volcano");
		--table.insert(self.StartPlots, pCheckPlot:GetIndex());
		--self.NumStartPlots = self.NumStartPlots+1;
end

-- EMPIRICAL SMOOTHING - needs to be done AFTER StartPlots are ready
-- Volcanos allowed only in seismic areas, so must be a subset of Earthquake tiles
function Disaster_Volcano:SmoothStartPlots()
	dprint("FUNCAL Disaster_Volcano:SmoothStartPlots() (num)", self.NumStartPlots);
	local tTempStartPlots:table = {};
	for _,iPlot in pairs(self.StartPlots) do
		if IsInTable(Disaster_Earthquake.StartPlots, iPlot) then
			table.insert(tTempStartPlots, iPlot);
		else
			dprint("   ...removing plot (x,y)", iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
		end
	end
	--dprint("   ...removed (num) singulars", self.NumStartPlots-table.count(tTempStartPlots));
	self.StartPlots = tTempStartPlots;
	self.NumStartPlots = table.count(self.StartPlots);
	dprint("   ...after smoothing found (num) start plots", self.NumStartPlots);
end

-- VFX
function Disaster_Volcano:VisualizeDisaster(pDisaster:table)
	dprint("FUNCAL Disaster_Volcano:VisualizeDisaster()");

	local function PlotVFXAshCover(iX:number, iY:number)
		-- FX_Wonder_Pyramid_Dust_Big, scale 1.0, put 4
		local sAssetType:string = "FX_Wonder_Pyramid_Dust_Big";
		local fWX:number, fWY:number, fWZ:number = RND.UI.GridToWorld(iX,iY);
		fWZ = 5.0; --dx = 32.0/2; dy = 55.5/2;
		if IsPlotIndexMountain(iX+iY*iMapWidth) then fWZ = 25.0; end
		CreateAssetPreviewWithScale(sAssetType, fWX, fWY, fWZ, 1.7);
		if not Map.GetPlot(iX,iY):IsWater() then
			CreateAssetPreviewWithScale(sAssetType, fWX, fWY, fWZ, 1.8);
		end
	end
	
	local function PlotVFXVolcanoEruption(iX:number, iY:number)
		local fWX:number, fWY:number, fWZ:number = RND.UI.GridToWorld(iX,iY);
		fWY = fWY - 6.0;
		fWZ = 20.0;
		-- FX_Campfire_Tribal continuous, scale 4.0, x1 at top, nice black smoke
		-- FX_Arc_Sparks_Continuous, scale >5.0
		-- FX_Wonder_Construction_Dust continuous, scale 6.0, x1 at top, z=22 - not so good
		-- FX_Wonder_Work_Dust continuous, scale 2.0, x2 at top, z=20
		-- FX_Sawdust_Md_01 continuous, scale 5.0, x1 at top, z=20
		-- FX_AoE_Hit_Snow once, scale 2.0
		-- FX_AoE_Hit_Dirt once, scale 3.0
		-- try to place them at (0,-6) so they will cover part of the mountain (better looking)
		CreateAssetPreviewWithScale("FX_Campfire_Tribal", 			fWX, fWY, -7.0,  8.0);  -- fire is hidden, only smoke visible
		CreateAssetPreviewWithScale("FX_Campfire_Tribal", 			fWX, fWY, -6.0,  7.0);  -- fire is hidden, only smoke visible
		CreateAssetPreviewWithScale("FX_Arc_Sparks_Continuous",		fWX-1.0, fWY, fWZ+3.0, 3.0);
		CreateAssetPreviewWithScale("FX_Arc_Sparks_Continuous",		fWX+1.0, fWY, fWZ+3.0, 3.0);
		CreateAssetPreviewWithScale("FX_Wonder_Work_Dust", 			fWX-2.0, fWY-1.0, fWZ, 2.0);  
		CreateAssetPreviewWithScale("FX_Wonder_Work_Dust", 			fWX+2.0, fWY-1.0, fWZ, 2.0);  
		CreateAssetPreviewWithScale("FX_AoE_Hit_Snow", 				fWX, fWY, fWZ, 1.3);  
		CreateAssetPreviewWithScale("FX_AoE_Hit_Dirt", 				fWX, fWY-2.0, fWZ, 2.5); 
		CreateAssetPreviewWithScale("FX_Sawdust_Md_01", 			fWX, fWY, fWZ, 5.0);  
	end
	
	local iX:number, iY:number = pDisaster.StartingPlot%iMapWidth, math.floor(pDisaster.StartingPlot/iMapWidth);
	if pDisaster:IsDisasterVisible() then CameraMoveToPlotXY(iX+1, iY); end
	PlotVFXVolcanoEruption(iX, iY);
	for _, iPlot in pairs(pDisaster.Plots) do
		--if iPlot ~= pDisaster.StartingPlot then 
		PlotVFXAshCover(iPlot%iMapWidth, math.floor(iPlot/iMapWidth));-- end
	end
	
end


-- ===========================================================================
-- WILDFIRE
-- ===========================================================================
local Disaster_Wildfire = { _ClassName = "Disaster_Wildfire", Type = "DISASTER_WILDFIRE" };	 -- identifies DB record with parameters - MUST be defined in the code for each Disaster
RegisterClass(Disaster_Wildfire, Disaster_Object);
tDisasterTypes.Disaster_Wildfire = Disaster_Wildfire;

function Disaster_Wildfire:CheckPlotForPossibleStart(pCheckPlot:table)
	if not IsPlotFlammable(pCheckPlot) then return false; end
	-- ...but it has to have at least 3 other flammable adjacent so it can move
	return CountAdjacentToPlot(pCheckPlot, IsPlotIndexFlammable) > 2;
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

-- VFX
-- sequence: move camera if visible, play sound, set fire
function Disaster_Wildfire:VisualizeDisaster(pDisaster:table)
	dprint("FUNCAL Disaster_Wildfire:VisualizeDisaster()");

	local function PlotVFXSetOnFire(iX:number, iY:number)
		local sAssetType:string = "FX_Campfire_Tribal";
		local fWX:number, fWY:number, fWZ:number = RND.UI.GridToWorld(iX,iY);
		-- put randomly placed fires
		for i=1,7,1 do
			local dx:number, dy:number = GetRandomCoorsInCircle(37);
			CreateAssetPreviewWithScale(sAssetType, fWX+dx, fWY+dy, 3.5, 3.0, 5.0);
		end
	end
	
	if pDisaster:IsDisasterVisible() then
		local iX, iY = pDisaster:GetDisasterAreaCenterPlot();
		CameraMoveToPlotXY(iX+1, iY);
	end
	for _, iPlot in pairs(pDisaster.Plots) do
		PlotVFXSetOnFire(iPlot%iMapWidth, math.floor(iPlot/iMapWidth));
	end
	
end


-- ===========================================================================
-- DISASTER EVENT OBJECT
-- As for now only 1 event per turn is supported
-- But having such event object, later I could add some queue and handle more than 1
-- ===========================================================================


local tTheDisaster = {
	_ClassName = "Disaster_Event",
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
RegisterClass(tTheDisaster, Class_Object);
	
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
	local iEffCnt = table.count(self.Effects);
	
	-- PREVENTION - DAMAGE REDUCTION
	-- the code to check if iPlot is in range of any damage-reduction prevention measures
	-- if true, then iMagnReduction will be passed to the effect allowing later for display
	-- should actually be stored on Plot level
	local bActivePrevention:boolean, iPrevention:number = Prevention_Damage:GetDisasterPrevention(self.DisasterType.Type, iPlot);
	local bActiveResistant:boolean, iPreventionResistant:number = Prevention_Resistant:GetDisasterPrevention(self.DisasterType.Type, iPlot);		
	
	-- check for our own units and plots
	local sLocalOwner:string;
	local eLocalPlayer = Game.GetLocalPlayer();
	if eLocalPlayer ~= -1 then sLocalOwner = Locale.Lookup(PlayerConfigurations[eLocalPlayer]:GetCivilizationShortDescription());
	else sLocalOwner = nil; end
	
	-- 0 - check if there's an owner
	local pCity:table = nil;
	local eOwnerID, sOwnerCiv:string, sOwnerCity:string = -1, "", "";  -- will be passed to new effects
	if pPlot:IsOwned() then
		eOwnerID = pPlot:GetOwner();
		pCity = Cities.GetPlotPurchaseCity(pPlot);
		--dprint("  plot owned by (civ,city)", eOwnerID, pCity:GetID());
		sOwnerCiv = PlayerConfigurations[eOwnerID]:GetCivilizationShortDescription();  -- LOC_CIVILIZATION_AMERICA_NAME
		sOwnerCiv = Locale.Lookup(sOwnerCiv);
		sOwnerCity = Locale.Lookup(pCity:GetName());
		dprint("  plot owned by (civ,city)", sOwnerCiv, sOwnerCity);
	end
	
	-- helper
	local function CreateAndRegisterEffect(eEffectClass:number, iPrevention:number, pObject, iBuildingIndex)
		local tEffect:table = Effect_Record:new(iPlot, iMagnitude, iPrevention, eOwnerID, sOwnerCiv, sOwnerCity, sLocalOwner);
		if iBuildingIndex == nil then tEffect:AssignObject(eEffectClass, pObject, sLocalOwner, -1);
		else						  tEffect:AssignObject(eEffectClass, pObject, sLocalOwner, iBuildingIndex); end
		table.insert(self.Effects, tEffect);
	end
	
	-- 1 - check for units
	if Units.AreUnitsInPlot(iPlot) then
		for _,unit in pairs(Units.GetUnitsInPlot(iPlot)) do
			dprint("  ...found a unit", unit:GetName());
			CreateAndRegisterEffect(EffectClasses.EFFECT_UNIT, iPrevention, unit);
		end
	end
	
	-- 2 - check for improvements
	if pPlot:GetImprovementType() ~= -1 then
		dprint("  ...found an improvement", pPlot:GetImprovementType());
		CreateAndRegisterEffect(EffectClasses.EFFECT_IMPROVEMENT, iPrevention, pPlot);
	end
	
	-- 3 - check for city
	if Cities.IsCityInPlot(iPlot) then
		dprint("  ...found a city");
		-- PREVENTION for cites comes from a different class
		local bActivePopulation:boolean, iPreventionPopulation:number = Prevention_Population:GetDisasterPrevention(self.DisasterType.Type, iPlot);
		CreateAndRegisterEffect(EffectClasses.EFFECT_CITY, iPreventionPopulation, Cities.GetCityInPlot(iPlot));
	end
	
	-- 4 - check for district, no use checking if there's no city assiciated
	if pCity and pPlot:GetDistrictType() ~= -1 then
		dprint("  ...found a district", pPlot:GetDistrictType());
		-- must find which district it is
		local pDistrict:table = pCity:GetDistricts():GetDistrictAtLocation(iPlot);
		-- must be careful with WONDERS - don't know if they can be Pillaged - must CHECK LATER - yes, they can
		-- anyway, district will be registered only if NOT internal
		if not GameInfo.Districts[pDistrict:GetType()].InternalOnly then
			CreateAndRegisterEffect(EffectClasses.EFFECT_DISTRICT, iPrevention+iPreventionResistant, pDistrict);
		end
	end
		--[[
		for i=0, pCity:GetDistricts():GetNumDistricts()-1, 1 do
			dprint("  ...checking district at index", i);
			local pDistrict = pCity:GetDistricts():GetDistrictByIndex(i);
			local iX, iY = pDistrict:GetLocation();
			local iDistrictPlot = iY * iMapWidth + iX;
			dprint("  ...its location is (plot,x,y)", iDistrictPlot, iX, iY);
			if iDistrictPlot == iPlot then
				-- the district has been located - process it and then its buildings!
				-- must be careful with WONDERS - don't know if they can be Pillaged - must CHECK LATER - yes, they can
				-- anyway, district will be registered only if NOT internal
				if GameInfo.Districts[pDistrict:GetType()].InternalOnly == false then
					CreateAndRegisterEffect(EffectClasses.EFFECT_DISTRICT, iPrevention+iPreventionResistant, pDistrict);
				end
			end -- found district
		end -- district loop
	end -- check for district
	--]]
	
	-- 5 - check for buildings
	if pCity then
		local pCityBuildings:table = pCity:GetBuildings();
		for building in GameInfo.Buildings() do
			if pCityBuildings:GetBuildingLocation(building.Index) == iPlot then
				-- found building, register it
				dprint("  ...found a building (id,name)", building.Index, GameInfo.Buildings[building.Index]);
				CreateAndRegisterEffect(EffectClasses.EFFECT_BUILDING, iPrevention+iPreventionResistant, pCity, building.Index);
			end
		end
	end

	dprint("FUNEND tTheDisaster:AnalyzePlotForEffects() found (num) effects for (plot)", table.count(self.Effects)-iEffCnt, iPlot);
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


-- create a table to be saved, with only data
function tTheDisaster:GetSaveCopy()
	dprint("FUNCAL tTheDisaster:GetSaveCopy()");
	local tCopyDisaster:table = {
		IsActive 		  = self.IsActive,
		Turn 			  = self.Turn,
		Year 			  = self.Year,
		DisasterTypeStr   = self.DisasterType.Type;  -- exception here! we store string "DISASTER_" instead of an object
		StartingPlot 	  = self.StartingPlot,
		StartingMagnitude = self.StartingMagnitude,
		Plots 			  = self.Plots,
		Magnitudes 		  = self.Magnitudes,
		Effects 		  = self.Effects,
	};
	--dshowrectable(tCopyDisaster);
	return tCopyDisaster;
end

function tTheDisaster:InitFromLoadCopy(tCopyDisaster:table)
	dprint("FUNCAL tTheDisaster:InitFromLoadCopy()");
	if tCopyDisaster == nil or table.count(tCopyDisaster) == 0 then print("WARNING: tTheDisaster:InitFromLoadCopy no data provided, resetting current disaster"); return; end
	--dshowrectable(tCopyDisaster);
	self.IsActive 			= tCopyDisaster.IsActive;
	self.Turn 				= tCopyDisaster.Turn;
	self.Year 				= tCopyDisaster.Year;
	-- exception here! we store string "DISASTER_" instead of an object
	for _, disaster in pairs(tDisasterTypes) do
		if disaster.Type == tCopyDisaster.DisasterTypeStr then self.DisasterType = disaster; end
	end
	self.StartingPlot 		= tCopyDisaster.StartingPlot;
	self.StartingMagnitude 	= tCopyDisaster.StartingMagnitude;
	self.Plots 				= tCopyDisaster.Plots;
	self.Magnitudes 		= tCopyDisaster.Magnitudes;
	self.Effects 			= tCopyDisaster.Effects;
	-- now, Effects are actually objects so we must connect them to their class
	AttachClassToObjectsInTable(self.Effects);
end

function StoreDisasterIntoHistoricData()
	dprint("FUNCAL StoreDisasterIntoHistoricData()");
	
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
	--table.insert(tHistoricDisasters, tCopyDisaster);  -- [FUTURE]
	--table.insert(disaster.HistoricEvents, tCopyDisaster); -- [FUTURE]
	-- also store starting point for history
	table.insert(disaster.HistoricStartingPlots, tTheDisaster.StartingPlot);

end
	

-- checks if any of the disaster area plots is actually VISIBLE, not only revealed	
function tTheDisaster:IsDisasterVisible()
	local eLocalPlayer:number = Game.GetLocalPlayer();
	if AutoplayManager.IsActive() then
		if AutoplayManager.GetObserveAsPlayer() == PlayerTypes.NONE then return false; end
		if AutoplayManager.GetObserveAsPlayer() == PlayerTypes.OBSERVER then return true; end
		eLocalPlayer = Game.GetLocalObserver();
	end
	local pPlayerVisibility = PlayersVisibility[eLocalPlayer];
	if pPlayerVisibility == nil then print("WARNING tTheDisaster:IsDisasterVisible(): no player visibility for (player)", eLocalPlayer); return false; end
	--local pPlayerVisibility = PlayersVisibility[Game.GetLocalPlayer()];
	for _,iPlot in pairs(self.Plots) do
		if pPlayerVisibility:IsVisible(iPlot) then return true; end
	end
	return false;
end

-- show floating text above disaster plots
-- but not all - too many - every 2nd one
function tTheDisaster:AddWorldViewText()
	local pPlayerVisibility = PlayersVisibility[Game.GetLocalPlayer()];
	local sDisName:string = Locale.Lookup(self.DisasterType.Name);
	for i,iPlot in pairs(self.Plots) do
		if pPlayerVisibility:IsRevealed(iPlot) and (i%2 == 0) then
			local sInfo:string = sDisName.." [COLOR_Red]"..tostring(self.Magnitudes[i]).."[ENDCOLOR]";
			RND.UI.AddWorldViewText(0, sInfo, iPlot%iMapWidth, math.floor(iPlot/iMapWidth), 0);
		end
	end
end

-- calculate average x and y
-- when looking: move camera 2 tiles to the right (so the map will scroll to the LEFT) - there's RNDInfoPopup on the right
function tTheDisaster:GetDisasterAreaCenterPlot()
	local iX:number, iY:number = 0, 0;
	for _,iPlot in pairs(self.Plots) do
		iX = iX + iPlot%iMapWidth;
		iY = iY + math.floor(iPlot/iMapWidth);
	end
	iX = math.floor(iX / table.count(self.Plots));
	iY = math.floor(iY / table.count(self.Plots));
	return iX, iY;
end
	
	
-- main function to place resources
-- Two steps algorithm
-- 1. Place standard resources (and features) - always permanent.
-- 2. Place disaster-related resources - could perma or temp.

function Effect_Resource:PlaceNewResources()
	dprint("FUNCAL Effect_Resource:PlaceNewResources()");
	
	local tPossibleResources:table = tDisasterResources[tTheDisaster.DisasterType.Type];
	if tPossibleResources == nil then print("WARNING Effect_Resource:PlaceNewResources(): no resources registered for", tTheDisaster.DisasterType.Type); return; end

	-- change here for a different formula for no. of turns
	--local iTempResourceTurns:number = iTempResStartingTurns + math.floor(Game.GetCurrentGameTurn()/iTempResTurnsIncreasePerGameTurns);
	local function GetTempResourceTurns(bLong:boolean)
		local iBaseTurns:number = iTemporaryResourceTurns;
		if bLong then iBaseTurns = iTemporaryResourceTurnsLong; end
		iBaseTurns = math.floor(iBaseTurns * iGameSpeedMultiplier/100);
		local iDeltaTurns:number = math.floor(iTemporaryResourceTurnsDelta * iGameSpeedMultiplier/100);
		return math.random(math.max(iBaseTurns-iDeltaTurns,1), iBaseTurns+iDeltaTurns);
	end

	-- helper, returns resource class and temp/perma flag (true=temp, false=perma)
	local function GetDisasterSiteFromMagnitude(iMagnitude:number)
		-- the only chance to get PERMA SITE is when it is registered and roll is successful
		if tPossibleResources[ResourceClasses.SITE_PERMA] and iMagnitude >= 70 then
			if math.random(0,99) < iMagnitude - 20 then return ResourceClasses.SITE_PERMA; end; -- Version 2.3.0 tweak, a bit less chance
			return ResourceClasses.SITE_LARGE;  -- large, temp
		end
		-- temp site, roll for size
		--if math.random(0,99) < iMagnitude then return ResourceClasses.SITE_LARGE; end
		if iMagnitude >= 50 then return ResourceClasses.SITE_LARGE; end
		return ResourceClasses.SITE_SMALL;
	end
	
	local tResEffect:table = {};  -- will hold all newly created effects
	-- helper
	function ExecuteEffect()
		tResEffect:PlaceOnMap();
		table.insert(tTheDisaster.Effects, tResEffect);
		if tResEffect.Temporary then table.insert(tTemporaryResources, tResEffect); end
	end
	
	-- STEP 0. Placing a site is always first
	-- 0a. what type of site - depends on Magnitude
	local eSiteSize:number = GetDisasterSiteFromMagnitude(tTheDisaster.StartingMagnitude);
	dprint("  Site from magnitude (dis,magn,size)", tTheDisaster.DisasterType.Type, tTheDisaster.StartingMagnitude, eSiteSize);
	-- check if such site is registered
	local tSiteResEff = tPossibleResources[eSiteSize];
	if tSiteResEff then
		dprint("  Site registered with (res)", tSiteResEff.ResourceType);
		local iSitePlot:number = -1;
		if self:CanPlaceResourceEffect(tTheDisaster.StartingPlot, tSiteResEff) then
			iSitePlot = tTheDisaster.StartingPlot;
		else
			-- we cannot place site on the StartingPlot, find a new spot as close as possible
			dprint("  Cannot place on StartingPlot, looking for an alterntive");
			for _,iPlot in pairs(tTheDisaster.Plots) do
				if self:CanPlaceResourceEffect(iPlot, tSiteResEff) then iSitePlot = iPlot; break; end
			end
		end
		-- placing!
		if iSitePlot ~= -1 then 
			if eSiteSize == ResourceClasses.SITE_PERMA then tResEffect = self:new(iSitePlot, tSiteResEff.ResourceType);  -- perma res
			else 											tResEffect = self:new(iSitePlot, tSiteResEff.ResourceType, true, GetTempResourceTurns( eSiteSize == ResourceClasses.SITE_LARGE )); end
			ExecuteEffect();
		else
			dprint("  No suitable spot for a disaster site in the entire area");
		end
	else
		print("WARNING Effect_Resource:PlaceNewResources(): No site (size) registered for (dis)", eSiteSize, tTheDisaster.DisasterType.Type);
	end
	
	-- STEP 1. Standard resources
	-- Calculate how many rolls to do. Formula: numRolls = math.floor(numTiles/13)+1. Roll N times with average Magn probability.
	local iNumRolls:number = 1 + math.floor( table.count(tTheDisaster.Plots)/iTilesPerStandardResource );
	local iAvgMagnitude:number = 0;
	for _,m in pairs(tTheDisaster.Magnitudes) do iAvgMagnitude = iAvgMagnitude + m; end
	iAvgMagnitude = math.floor( iAvgMagnitude/table.count(tTheDisaster.Magnitudes) );
	local iNumStdResources:number = 0;
	for i = 1, iNumRolls do
		if math.random(0,99) < math.floor(iAvgMagnitude*fResourceProbabilityAdj) then iNumStdResources = iNumStdResources + 1; end
	end
	dprint("  Placing standard resources (plots,rolls,avgmagn,num)", table.count(tTheDisaster.Plots), iNumRolls, iAvgMagnitude, iNumStdResources);
	for i = 1, iNumStdResources do
		-- ok, we rolled to place some of them
		local tAllStdResEff:table = {};  -- this table will hold all pairs of {plot,resource} that can be placed within disaster area
		for _,reseff in pairs(tPossibleResources[ResourceClasses.STANDARD]) do
			for _,iPlot in pairs(tTheDisaster.Plots) do
				if self:CanPlaceResourceEffect(iPlot, reseff) then
					local validPair:table = { iPlot, reseff.ResourceType };
					table.insert(tAllStdResEff, validPair);
				end
			end
		end
		if table.count(tAllStdResEff) == 0 then
			dprint("  ...no valid pairs of plots and resources found, stopping standard resource placing", table.count(tAllStdResEff));
			break;
		end
		-- placing! find a random pair
		local idx:number = math.random(1,table.count(tAllStdResEff));
		dprint("  ...found (num) valid pairs of plots and resources and rolled (idx)", table.count(tAllStdResEff), idx);
		tResEffect = self:new(tAllStdResEff[idx][1], tAllStdResEff[idx][2]);  -- always permanent
		ExecuteEffect();
	end
	
	-- STEP 2. Disaster specific resources
	-- try to place a resource on all disaster tiles
	-- helper - temporary resources also are rolled but with boosted probability a little
	local function PlaceTemporaryResource(iPlot:number, iMagnitude:number, sResourceType:string)
		if math.random(0,99) < math.floor(iMagnitude*fResourceTemporaryAdj) then 
				tResEffect = self:new(iPlot, sResourceType, true, GetTempResourceTurns());
				ExecuteEffect();
		end
	end
	-- Magnitude decides if it's permanent or temporary
	for _,reseff in pairs(tPossibleResources[ResourceClasses.PERMANENT]) do
		dprint("  Placing disaster specific potentially permanent (res)", reseff.ResourceType);
		for i,iPlot in pairs(tTheDisaster.Plots) do
			if self:CanPlaceResourceEffect(iPlot, reseff) then  -- placing!
				-- must roll to place a permanent one
				if math.random(0,99) < math.floor(tTheDisaster.Magnitudes[i]*fResourcePermanentAdj) then
					tResEffect = self:new(iPlot, reseff.ResourceType); --, not bPermanent, GetTempResourceTurns());
					ExecuteEffect();
				else
					PlaceTemporaryResource(iPlot, tTheDisaster.Magnitudes[i], reseff.ResourceType);
				end
			end
		end
	end
	for _,reseff in pairs(tPossibleResources[ResourceClasses.TEMPORARY]) do
		dprint("  Placing disaster specific always temporary (res)", reseff.ResourceType);
		for i,iPlot in pairs(tTheDisaster.Plots) do
			if self:CanPlaceResourceEffect(iPlot, reseff) then 	-- placing!
				PlaceTemporaryResource(iPlot, tTheDisaster.Magnitudes[i], reseff.ResourceType);
				--tResEffect = self:new(iPlot, reseff.ResourceType, true, GetTempResourceTurns());
				--ExecuteEffect();
			end
		end
	end
	
end


-- ===========================================================================
-- FEATURES AND RESOURCES
-- Support functions for Wildfire
-- ===========================================================================
function OnFeatureAddedRemoved()
	dprint("FUNCAL OnFeatureAddedRemoved()");
	-- too many options to consider: Forest, Marsh, Floodplains, also what Terran below
	-- its just faster and easier to refresh StartPlots
	Disaster_Wildfire:DetectStartPlots();
	Disaster_Wildfire:RemoveStartPlots(1);
end


-- ===========================================================================
-- SAVING/LOADING PERSISTENT DATA
-- ===========================================================================
-- 1. Saving - all data is saved in SaveAllData function called in events that change the data
--   Warning! Cannot use SaveComplete - its called AFTER the actual save.
-- 2. Loading - little more complex
--   2a. Initialize - cannot use RND
--		i. get constant data (map/game parameters)
--		ii. retrieve config parameters
--		iii. initialize objects with DB data (Disasters, Resources, Buildings)
--		This step should leave all save-file related data empty, like in a newly created game
--   2b. LoadComplete
--		i. Temporary Resources
--		ii. Historic Plots
--		iii. The Disaster (with IsActive flag)
--   2c. LoadScreenClose - basically nothing to do?


-- ===========================================================================
-- Save disaster related data into Game Values
function SaveAllData()
	dprint("FUNCAL SaveAllData()");

	local function SaveDataInSlot(sSlotName:string, data)
		dprint("FUNCAL SaveDataInSlot() (slot,type)", sSlotName, type(data));
		--dshowrectable(data);
		local sData = serialize(data); -- RND.serialize(data);
		--dprint("---->>", sData);
		RND.GameConfiguration.SetValue(sSlotName, sData);
		local sCheck:string = RND.GameConfiguration.GetValue(sSlotName);
		dprint("check:", sCheck);
	end

	dprint("--- SAVING ---");
	local tData:table = {};  -- various loose data, usually not stored in tables
	tData._Name = "Real Natural Disasters";  -- mod name to identify the data set
	tData._Version = 1;  -- for future backward compatibility; indcates version of the data stored, not the mod
	tData._Turn = Game.GetCurrentGameTurn();  -- just for checking
	tData.iOrderCounter = iOrderCounter;
	SaveDataInSlot("RND_Data", tData);
	SaveDataInSlot("RND_HistoricStartingPlots", tHistoricStartingPlots);
	SaveDataInSlot("RND_TemporaryResources", tTemporaryResources);
	SaveDataInSlot("RND_TheDisaster", tTheDisaster:GetSaveCopy());
	dprint("--- END SAVING ---");
end


-- ===========================================================================
-- Load data into distasters (careful - it is BEFORE OnLoadScreenClose)
-- 1. Deserialize values using loadstring()
function OnLoadComplete()
	dprint("FUNCAL OnLoadComplete");
	
	local function LoadDataFromSlot(sSlotName:string)
		dprint("FUNCAL LoadDataFromSlot() (slot)", sSlotName);
		local sData:string = GameConfiguration.GetValue(sSlotName);
		dprint("<--", sData);
		if sData == nil then print("WARNING: LoadDataFromSlot no data in slot", sSlotName); return {}; end
		local tTable = loadstring(sData)();
		--dshowrectable(tTable);
		return tTable;
	end
	
	dprint("--- LOADING ---");
	local tData:table = LoadDataFromSlot("RND_Data");
	dprint("  ...data set (name,ver,turn)", tData._Name, tData._Version, tData._Turn);
	iOrderCounter = ( tData.iOrderCounter and tData.iOrderCounter or 1 ); -- failproof for corrupted saves
	tHistoricStartingPlots = LoadDataFromSlot("RND_HistoricStartingPlots");
	tTemporaryResources = LoadDataFromSlot("RND_TemporaryResources");
	AttachClassToObjectsInTable(tTemporaryResources);
	tTheDisaster:InitFromLoadCopy(LoadDataFromSlot("RND_TheDisaster"));
	dprint("--- END LOADING ---");
	
	-- additional load-related logic, i.e. connect HistoricStartingPlots to Disasters
	for _, disaster in pairs(tDisasterTypes) do
		disaster.HistoricStartingPlots = tHistoricStartingPlots[disaster.Type];
	end
	
	-- important! otherwise all Disaster resources will be removed
	bMapCleared = true;
	
end



-- ===========================================================================
-- GAME EVENTS
-- ===========================================================================

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
	Disaster_Meteor,
	Disaster_Volcano,
	Disaster_Wildfire,
	Disaster_Flood,
	Disaster_Tsunami,
	Disaster_Tornado,
};
local iOrderMax = table.count(tOrderOfDisasters);	-- should be 7

function OnTurnBegin()
	dprint("FUNCAL OnTurnBegin()");
	
	if Game.GetCurrentGameTurn() == GameConfiguration.GetStartTurn() then  -- always 1st turn is 'free', even when we start in later Eras
		RND.RNDInfoPopup_OpenWindow();  -- show parameters
		return;  -- so Civs won't be killed on 1st turn :)
	end
	
	-- first let's go through all of them and check if any triggers
	local iCheck = 0;  -- will be later used to update iOrderCounter
	for iCounter = iOrderCounter, iOrderCounter + iOrderMax - 1, 1 do
		iCheck = ((iCounter-1) % iOrderMax) + 1;  -- wrap index, complex because Lua tables start with index 1
		dprint("Checking (i,pos,type)", iCounter, iCheck, tOrderOfDisasters[iCheck].Type);
		local disaster = tOrderOfDisasters[iCheck];
		--if disaster:CheckIfHappened(bRealDisasters) then  -- well, the worse has happened [from Object] 'false' - not-real checking (debug), should be 'true' at the end MAIN SWICH HERE
		if disaster:CheckIfHappened(bRealDisasters) and (bRealDisasters or Game.GetCurrentGameTurn()%3 == 0) then  -- well, the worse has happened [from Object] 'false' - not-real checking (debug), should be 'true' at the end MAIN SWICH HERE
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
		------------- CATASTROPHY -------------
		tTheDisaster.DisasterType:VisualizeDisaster(tTheDisaster);
		tTheDisaster:ExecuteTheDisaster();
		---------------------------------------
		local pPlayerVisibility = PlayersVisibility[Game.GetLocalPlayer()];
		for _,effect in pairs(tTheDisaster.Effects) do
			if effect.IsDestroyed and pPlayerVisibility:IsRevealed(effect.Plot) then
				RND.UI.AddWorldViewText(0, effect.Desc, effect.Plot%iMapWidth, math.floor(effect.Plot/iMapWidth), 0);
			end
		end
	end
	
	-- ths is main functon that changes data, so we need to prepare a save
	SaveAllData();
	
end


-- ===========================================================================
-- Here we will check if some temporary resources have expired
-- Later some other time dependant functions may be added here
function OnTurnEnd()
	dprint("FUNCAL OnTurnEnd()");
	
	-- RESOURCES
	-- iterate through temporary resources and remove them if their time's up
	Effect_Resource:RemoveExpiredResources();
	
	-- FINISH CURRENT EVENT
	-- if there is an active event - place resources and store it into historic data
	if tTheDisaster.IsActive then
		tTheDisaster.DisasterType:FinishVisualizeDisaster(tTheDisaster);
		Effect_Resource:PlaceNewResources();
		StoreDisasterIntoHistoricData();
		tTheDisaster.IsActive = false;  -- deactivate event
	end
	
	-- ths is main functon that changes data, so we need to prepare a save
	SaveAllData();
	
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
		--tTheDisaster.DisasterType:VisualizeDisaster(tTheDisaster);
		RND.RNDInfoPopup_OpenWindow();
	end
end


-- ===========================================================================
-- If event has ended - remove it from the map [FUNCTION]
-- [NEXT PHASE] Continue showing (some effects?)
function OnLocalPlayerTurnEnd()
	dprint("FUNCAL OnLocalPlayerTurnEnd()");
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
-- Initialize data for this game that can be recreated
-- 1. Retrieve map size and adjust distaster parameters to fit the map [AdjustForMapSize]
-- 2. Analyze current Map [CheckPlotForPossibleStart]

function OnLoadScreenClose()
	dprint("FUNCAL OnLoadScreenClose()");
	
	-- RESOURCES
	if not bMapCleared then Effect_Resource:ClearMap(); end

end


-- ===========================================================================
-- INITIALIZE
-- Facts: DB is ready, Map is ready (created/loaded), Configuration is read (both options/saved values)
-- Initialize data for this game that can be recreated
-- 1. Retrieve map size and adjust distaster parameters to fit the map [AdjustForMapSize]
-- 2. Analyze current Map [CheckPlotForPossibleStart]
-- ===========================================================================

function Initialize_Parameters()
	dprint("FUNCAL Initialize_Parameters()");
	
	-- retrieve map and game speed parameters (constant during the game)
	iMapWidth, iMapHeight = Map.GetGridSize();
	iMapSize = iMapWidth * iMapHeight;
	fMapProbAdj = 1.0 * math.pow(iMapSize/4536, -0.55);  -- empiric formula referencing STANDARD map size, as of now: =1.0*map_ratio^(-0.55)
	iGameSpeedMultiplier = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier;
	dprint("Map parameters (width,height,size,probadj,speed) are", iMapWidth, iMapHeight, iMapSize, fMapProbAdj, iGameSpeedMultiplier);
	
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
	
end


function Initialize_Objects()
	dprint("FUNCAL Initialize_Objects()");
	
	-- load Disaster parameters from Database and adjust parameters for Range and Magnitude
	-- iterate through the map and detect possible start plots
	for _, disaster in pairs(tDisasterTypes) do
		dprint("Loading parameters for", disaster.Type);
		disaster:Initialize();
		-- debug: check if definitions are ok
		--for k,v in pairs(disaster) do dprint("  (k,v)", k, v); end
		disaster:DetectStartPlots();
	end
	-- remove singulars from some Disasters
	Disaster_Earthquake:RemoveStartPlots(1);
	Disaster_Tornado:RemoveStartPlots(1);
	Disaster_Tsunami:RemoveStartPlots(1);
	Disaster_Wildfire:RemoveStartPlots(1);
	-- additional passes for Earthquake and Volcano
	Disaster_Earthquake:SmoothStartPlots();
	Disaster_Earthquake:RemoveStartPlots(2);
	Disaster_Volcano:SmoothStartPlots();

	-- debug: probability calculations data
	dprint("Number of starting plots for each disaster type");
	for _,dis in pairs(tDisasterTypes) do dprint("  (dis,num)", dis.Type, dis.NumStartPlots); end

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
		-- debug
		--for k,v in pairs(disaster) do dprint("  (k,v)", k, v); end
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
	
	-- RESOURCES
	Effect_Resource:Initialize();
	
	-- BUILDINGS
	Prevention_Damage:Initialize();
	Prevention_Population:Initialize();
	Prevention_Removal:Initialize();
	Prevention_Insurance:Initialize();
	Prevention_Resistant:Initialize();
	
	-- debug - display prevention areas
	--Prevention_Damage:ddisplayprevmap("DISASTER_TSUNAMI");
	--Prevention_Damage:ddisplayprevmap("DISASTER_EARTHQUAKE");
	--Prevention_Population:ddisplayprevmap("DISASTER_METEOR");
	--Prevention_Removal:ddisplayprevmap("DISASTER_FLOOD");
	--Prevention_Removal:ddisplayprevmap("DISASTER_WILDFIRE");
	
end

function Initialize()
	dprint("FUNSTA Initialize()");
	
	-- this part must NOT use ExposedMembers
	--dprint("--- OBJECT CLASSES BEFORE INIT ---");
	--dshowallclasses();
	Initialize_Parameters();
	Initialize_Objects();
	--dprint("--- OBJECT CLASSES AFTER INIT ---");
	--dshowallclasses();

	-- more pre-events to check
	--Events.SaveComplete.Add( OnSaveComplete );  -- should fire before save attemp and in-between turns; it does because the game performs an auto-save
	Events.LoadComplete.Add( OnLoadComplete );  -- fires after loading a game, when it's ready to start (i.e. circle button)
	Events.LoadScreenClose.Add ( OnLoadScreenClose );   -- fires then Game is ready to begin i.e. big circle buttons appears; if loaded - fires AFTER LoadComplete
	
	-- initialize events - starting events
	--Events.LocalPlayerChanged.Add( OnLocalPlayerChanged );  -- fires in-between TurnEnd and TurnBegin
	Events.TurnBegin.Add( OnTurnBegin );  -- fires ONCE at the start of Turn
	Events.LocalPlayerTurnBegin.Add( OnLocalPlayerTurnBegin );  -- event for LOCAL player only (i.e. HUMANS), fires BEFORE PlayerTurnActivated
	--Events.PlayerTurnActivated.Add( OnPlayerTurnActivated );  -- main event for any player start (AIs, including minors), goes for playerID = 0,1,2,...
	-- initialize events - that fire AFTER custom PlayerTurnActivated()
	Events.FeatureAddedToMap.Add( OnFeatureAddedRemoved );
	Events.FeatureRemovedFromMap.Add( OnFeatureAddedRemoved );
	--Events.CityProductionCompleted.Add(	OnCityProductionCompleted );
	--Events.BuildingRemovedFromMap.Add( OnBuildingRemovedFromMap );
	-- HERE YOU PLAY GAME AS HUMAN
	-- initialize events - finishing events
	--Events.LocalPlayerTurnEnd.Add( OnLocalPlayerTurnEnd );  -- fires only for HUMANS
	--Events.PlayerTurnDeactivated.Add( OnPlayerTurnDeactivated );  -- main event for any player end (including minors)
	Events.TurnEnd.Add( OnTurnEnd );  -- fires ONCE at end of turn
	
	-- exposing functions and variables
	--if not ExposedMembers.RND then ExposedMembers.RND = {} end;
	--RND = ExposedMembers.RND;
	RND.tDisasterTypes = tDisasterTypes;
	RND.tTheDisaster   = tTheDisaster;
	
	dprint("FUNEND Initialize()");
end
Initialize();

print("OK loaded RealNaturalDisasters.lua from Real Natural Disasters");