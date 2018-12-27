--------------------------------------------------------------
-- Real Natural Disasters - Resources
-- Author: Infixo
-- April 20, 2017 - Created
--------------------------------------------------------------


--------------------------------------------------------------
-- DISASTER RELATED RESOURCES
-- Must define: Types, Resources, Resource_ValidTerrains, Resource_ValidFeatures, Resource_YieldChanges, Resource_Harvests, and TypeTags (!) 
--------------------------------------------------------------

INSERT INTO Types (Type, Kind)
VALUES
	('RESOURCE_DISASTER_SMALL', 'KIND_RESOURCE'),
	('RESOURCE_DISASTER_LARGE', 'KIND_RESOURCE'),
	('RESOURCE_EPICENTRUM', 	'KIND_RESOURCE'),
	('RESOURCE_FLOODED_LAND',   'KIND_RESOURCE'),
	('RESOURCE_METEOR_CRATER',  'KIND_RESOURCE'),
	('RESOURCE_METEOR_SHARDS',  'KIND_RESOURCE'),
	('RESOURCE_VOLCANO_CRATER', 'KIND_RESOURCE'),
	('RESOURCE_VOLCANIC_ASH',   'KIND_RESOURCE'),
	('RESOURCE_BURNED_GROUND',  'KIND_RESOURCE'),
	('RESOURCE_BURNED_WATER',   'KIND_RESOURCE');

INSERT INTO Resources (ResourceType, Name, ResourceClassType, LakeEligible)
VALUES
	('RESOURCE_DISASTER_SMALL', 'LOC_RESOURCE_DISASTER_SMALL_NAME', 'RESOURCECLASS_BONUS', 1),
	('RESOURCE_DISASTER_LARGE', 'LOC_RESOURCE_DISASTER_LARGE_NAME', 'RESOURCECLASS_BONUS', 1),
	('RESOURCE_EPICENTRUM', 	'LOC_RESOURCE_EPICENTRUM_NAME', 	'RESOURCECLASS_BONUS', 1),
	('RESOURCE_FLOODED_LAND',   'LOC_RESOURCE_FLOODED_LAND_NAME',   'RESOURCECLASS_BONUS', 0),
	('RESOURCE_METEOR_CRATER',  'LOC_RESOURCE_METEOR_CRATER_NAME',  'RESOURCECLASS_BONUS', 1),
	('RESOURCE_METEOR_SHARDS',  'LOC_RESOURCE_METEOR_SHARDS_NAME',  'RESOURCECLASS_BONUS', 0),
	('RESOURCE_VOLCANO_CRATER', 'LOC_RESOURCE_VOLCANO_CRATER_NAME', 'RESOURCECLASS_BONUS', 0),
	('RESOURCE_VOLCANIC_ASH',   'LOC_RESOURCE_VOLCANIC_ASH_NAME',   'RESOURCECLASS_BONUS', 0),
	('RESOURCE_BURNED_GROUND',  'LOC_RESOURCE_BURNED_GROUND_NAME',  'RESOURCECLASS_BONUS', 0),
	('RESOURCE_BURNED_WATER',   'LOC_RESOURCE_BURNED_WATER_NAME',   'RESOURCECLASS_BONUS', 0);


INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_DISASTER_SMALL', TerrainType FROM Terrains WHERE Mountain = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_DISASTER_LARGE', TerrainType FROM Terrains WHERE Mountain = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_EPICENTRUM', 	 TerrainType FROM Terrains WHERE Mountain = 0 AND Water = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_FLOODED_LAND',   TerrainType FROM Terrains WHERE Mountain = 0 AND Hills = 0 AND Water = 0 AND TerrainType != 'TERRAIN_SNOW';
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_METEOR_CRATER',  TerrainType FROM Terrains WHERE Mountain = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_METEOR_SHARDS',  TerrainType FROM Terrains WHERE Mountain = 0 AND Water = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_VOLCANO_CRATER', TerrainType FROM Terrains WHERE Mountain = 0 AND Water = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_VOLCANIC_ASH',   TerrainType FROM Terrains WHERE Mountain = 0 AND Water = 0;
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_BURNED_GROUND',  TerrainType FROM Terrains WHERE TerrainType IN ('TERRAIN_GRASS','TERRAIN_GRASS_HILLS','TERRAIN_PLAINS','TERRAIN_PLAINS_HILLS');
INSERT INTO Resource_ValidTerrains SELECT 'RESOURCE_BURNED_WATER',   TerrainType FROM Terrains WHERE TerrainType IN ('TERRAIN_GRASS','TERRAIN_GRASS_HILLS','TERRAIN_PLAINS','TERRAIN_PLAINS_HILLS');

INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_DISASTER_SMALL', FeatureType FROM Features WHERE Impassable = 0;
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_DISASTER_LARGE', FeatureType FROM Features WHERE Impassable = 0;
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_EPICENTRUM', 	 FeatureType FROM Features WHERE Impassable = 0 AND Lake = 0 AND FeatureType != 'FEATURE_BARRIER_REEF';
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_FLOODED_LAND',   FeatureType FROM Features WHERE Impassable = 0 AND (Forest = 1 OR FeatureType = 'FEATURE_PANTANAL');
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_METEOR_CRATER',  FeatureType FROM Features WHERE Impassable = 0;
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_METEOR_SHARDS',  FeatureType FROM Features WHERE Impassable = 0 AND Lake = 0 AND FeatureType != 'FEATURE_BARRIER_REEF';
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_VOLCANO_CRATER', FeatureType FROM Features WHERE Impassable = 0 AND Lake = 0 AND FeatureType != 'FEATURE_BARRIER_REEF';
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_VOLCANIC_ASH',   FeatureType FROM Features WHERE Impassable = 0 AND Lake = 0 AND FeatureType != 'FEATURE_BARRIER_REEF';
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_BURNED_GROUND',  FeatureType FROM Features WHERE Impassable = 0 AND (Forest = 1 OR FeatureType = 'FEATURE_PANTANAL');
INSERT INTO Resource_ValidFeatures SELECT 'RESOURCE_BURNED_WATER',   FeatureType FROM Features WHERE Impassable = 0 AND (Forest = 1 OR FeatureType = 'FEATURE_PANTANAL');


INSERT INTO Resource_YieldChanges (ResourceType, YieldType, YieldChange)
VALUES
	('RESOURCE_DISASTER_SMALL', 'YIELD_SCIENCE', 2),
	('RESOURCE_DISASTER_SMALL', 'YIELD_CULTURE', 1),
	('RESOURCE_DISASTER_LARGE', 'YIELD_SCIENCE', 3),
	('RESOURCE_DISASTER_LARGE', 'YIELD_CULTURE', 1),
	('RESOURCE_DISASTER_LARGE', 'YIELD_FAITH',   2),
	('RESOURCE_EPICENTRUM',  	'YIELD_SCIENCE', 4),
	('RESOURCE_EPICENTRUM',  	'YIELD_CULTURE', 2),  -- how to do tourism? must use a modifier e.g. +20% [LATER]
	('RESOURCE_EPICENTRUM',  	'YIELD_FAITH',   2),
	('RESOURCE_FLOODED_LAND',   'YIELD_FOOD',    2),
	('RESOURCE_METEOR_CRATER',  'YIELD_SCIENCE', 4),
	('RESOURCE_METEOR_CRATER',  'YIELD_CULTURE', 2),  -- how to do tourism? must use a modifier e.g. +20% [LATER]
	('RESOURCE_METEOR_CRATER',  'YIELD_FAITH',   2),
	('RESOURCE_METEOR_CRATER',  'YIELD_FOOD',   -2),
	('RESOURCE_METEOR_SHARDS',  'YIELD_GOLD',    1),
	('RESOURCE_METEOR_SHARDS',  'YIELD_PRODUCTION', 1),
	('RESOURCE_VOLCANO_CRATER', 'YIELD_SCIENCE', 4),
	('RESOURCE_VOLCANO_CRATER', 'YIELD_CULTURE', 2),  -- how to do tourism? must use a modifier e.g. +20% [LATER]
	('RESOURCE_VOLCANO_CRATER', 'YIELD_FAITH',   2),
	('RESOURCE_VOLCANO_CRATER', 'YIELD_FOOD',   -2),
	('RESOURCE_VOLCANIC_ASH',   'YIELD_FOOD',    1),
	('RESOURCE_VOLCANIC_ASH',   'YIELD_PRODUCTION', 1),
	('RESOURCE_BURNED_GROUND',  'YIELD_FOOD',   -1),  -- can we actually use -1? yes, we can!
	('RESOURCE_BURNED_GROUND',  'YIELD_SCIENCE', 1),
	('RESOURCE_BURNED_WATER',   'YIELD_FOOD',    1),
	('RESOURCE_BURNED_WATER',   'YIELD_SCIENCE', 1);

INSERT INTO Resource_Harvests (ResourceType, YieldType, Amount, PrereqTech)
VALUES 
	('RESOURCE_DISASTER_SMALL', 'YIELD_SCIENCE', 30, 'TECH_WRITING'),
	('RESOURCE_DISASTER_SMALL', 'YIELD_CULTURE', 15, 'TECH_WRITING'),
	('RESOURCE_DISASTER_LARGE', 'YIELD_SCIENCE', 50, 'TECH_WRITING'),
	('RESOURCE_DISASTER_LARGE', 'YIELD_CULTURE', 15, 'TECH_WRITING'),
	('RESOURCE_DISASTER_LARGE', 'YIELD_FAITH',   20, 'TECH_ASTROLOGY'),
	('RESOURCE_FLOODED_LAND',   'YIELD_FOOD',    40, 'TECH_IRRIGATION'),
	('RESOURCE_METEOR_SHARDS',  'YIELD_GOLD',    20, 'TECH_MINING'),
	('RESOURCE_METEOR_SHARDS',  'YIELD_PRODUCTION', 20, 'TECH_MINING'),
	('RESOURCE_VOLCANIC_ASH',   'YIELD_FOOD',    20, 'TECH_IRRIGATION'),
	('RESOURCE_VOLCANIC_ASH',   'YIELD_PRODUCTION', 20, 'TECH_MASONRY'),
	('RESOURCE_BURNED_GROUND',  'YIELD_SCIENCE', 20, 'TECH_WRITING'),
	('RESOURCE_BURNED_WATER',   'YIELD_FOOD',    10, 'TECH_IRRIGATION'),
	('RESOURCE_BURNED_WATER',   'YIELD_SCIENCE', 20, 'TECH_WRITING'),
	-- perma sites, Version 2.3.0, are problematic late game because often block development of cities
	('RESOURCE_EPICENTRUM', 'YIELD_SCIENCE', 30, 'TECH_SANITATION'),
	('RESOURCE_EPICENTRUM', 'YIELD_CULTURE', 15, 'TECH_SANITATION'),
	('RESOURCE_EPICENTRUM', 'YIELD_FAITH', 15, 'TECH_SANITATION'),
	('RESOURCE_METEOR_CRATER', 'YIELD_SCIENCE', 30, 'TECH_SANITATION'),
	('RESOURCE_METEOR_CRATER', 'YIELD_CULTURE', 15, 'TECH_SANITATION'),
	('RESOURCE_METEOR_CRATER', 'YIELD_FAITH', 15, 'TECH_SANITATION'),
	('RESOURCE_VOLCANO_CRATER', 'YIELD_SCIENCE', 30, 'TECH_SANITATION'),
	('RESOURCE_VOLCANO_CRATER', 'YIELD_CULTURE', 15, 'TECH_SANITATION'),
	('RESOURCE_VOLCANO_CRATER', 'YIELD_FAITH',   15, 'TECH_SANITATION');

	
--------------------------------------------------------------
-- MAPPING TO DISASTERS
-- Columns: DisasterType, ResourceType, NumCopies, Temporary, RequiresLand (0/1), RequiresLake (0/1), RequiresSea (0/1)
-- (not used)NumCopies: 0 multiple randomly placed, 1 only one
-- Temporary: 0 depends on Magnitude, 1 always temporary
-- Class: 0 - standard game resource, 1/2 - disaster specific temp/perma, 3/4 - disaster site small/large temporary, 5 - perma disaster site
--------------------------------------------------------------

CREATE TABLE RNDDisasterResources (
	DisasterType	TEXT NOT NULL REFERENCES RNDDisasters (DisasterType) ON DELETE CASCADE ON UPDATE CASCADE,
	ResourceType	TEXT NOT NULL REFERENCES Resources (ResourceType) ON DELETE CASCADE ON UPDATE CASCADE,
	ResourceClass	INTEGER NOT NULL CHECK (ResourceClass IN (0,1,2,3,4,5)) DEFAULT 0,
	RequiresLand	BOOLEAN NOT NULL CHECK (RequiresLand IN (0,1)) DEFAULT 0,  -- this resource MUST be on Land tile
	RequiresOcean	BOOLEAN NOT NULL CHECK (RequiresLand IN (0,1)) DEFAULT 0,  -- this resource MUST be on Ocean tile
	FreshWater		BOOLEAN NOT NULL CHECK (FreshWater IN (0,1)) DEFAULT 0,  -- this resource MUST be close to Ferash Water
	NoFreshWater	BOOLEAN NOT NULL CHECK (FreshWater IN (0,1)) DEFAULT 0,  -- this resource CANNOT be close to Fresh Water
	PRIMARY KEY (DisasterType, ResourceType)
);

-- register disaster specific resources
INSERT INTO RNDDisasterResources 
VALUES
	-- disaster specific resources
	('DISASTER_FLOOD', 		'RESOURCE_FLOODED_LAND',   	1, 1, 0, 0, 0),
	('DISASTER_METEOR', 	'RESOURCE_METEOR_SHARDS',  	2, 1, 0, 0, 0),
	('DISASTER_VOLCANO', 	'RESOURCE_VOLCANIC_ASH',   	2, 1, 0, 0, 0),
	('DISASTER_WILDFIRE', 	'RESOURCE_BURNED_GROUND',  	1, 1, 0, 0, 1),
	('DISASTER_WILDFIRE', 	'RESOURCE_BURNED_WATER',   	2, 1, 0, 1, 0),
	-- perma sites
	('DISASTER_EARTHQUAKE', 'RESOURCE_EPICENTRUM', 		5, 1, 0, 0, 0),
	('DISASTER_METEOR', 	'RESOURCE_METEOR_CRATER',  	5, 0, 0, 0, 0),
	('DISASTER_VOLCANO', 	'RESOURCE_VOLCANO_CRATER', 	5, 1, 0, 0, 0),
	-- disaster sites
	('DISASTER_EARTHQUAKE', 'RESOURCE_DISASTER_SMALL', 	3, 1, 0, 0, 0),
	('DISASTER_EARTHQUAKE', 'RESOURCE_DISASTER_LARGE', 	4, 1, 0, 0, 0),
	('DISASTER_METEOR', 	'RESOURCE_DISASTER_SMALL', 	3, 0, 0, 0, 0),
	('DISASTER_METEOR', 	'RESOURCE_DISASTER_LARGE', 	4, 0, 0, 0, 0),
	('DISASTER_TORNADO', 	'RESOURCE_DISASTER_SMALL', 	3, 1, 0, 0, 0),
	('DISASTER_TORNADO', 	'RESOURCE_DISASTER_LARGE', 	4, 1, 0, 0, 0),
	('DISASTER_TSUNAMI', 	'RESOURCE_DISASTER_SMALL', 	3, 0, 1, 0, 0),
	('DISASTER_TSUNAMI', 	'RESOURCE_DISASTER_LARGE', 	4, 0, 1, 0, 0),
	('DISASTER_VOLCANO', 	'RESOURCE_DISASTER_SMALL', 	3, 1, 0, 0, 0),
	('DISASTER_VOLCANO', 	'RESOURCE_DISASTER_LARGE', 	4, 1, 0, 0, 0);

-- Meteor: reveals metal resources [Gold, Platinum, Lead]
INSERT INTO RNDDisasterResources (DisasterType, ResourceType)
SELECT 'DISASTER_METEOR', ResourceType FROM Resources 
WHERE ResourceType IN ('RESOURCE_COPPER','RESOURCE_MERCURY','RESOURCE_SILVER','RESOURCE_ALUMINUM','RESOURCE_IRON','RESOURCE_URANIUM','RESOURCE_GOLD','RESOURCE_PLATINUM','RESOURCE_LEAD');

-- Volcano: reveals metal resources [Gold, Platinum, Lead]
INSERT INTO RNDDisasterResources (DisasterType, ResourceType)
SELECT 'DISASTER_VOLCANO', ResourceType FROM Resources 
WHERE ResourceType IN ('RESOURCE_COPPER','RESOURCE_MERCURY','RESOURCE_SILVER','RESOURCE_ALUMINUM','RESOURCE_IRON','RESOURCE_URANIUM','RESOURCE_GOLD','RESOURCE_PLATINUM','RESOURCE_LEAD');
	
-- Flood: farm-type resource (Wheat, Rice) or feature Marsh (grassland only) [TODO LATER], or Fish in the lake [Salmon, Caviar]
INSERT INTO RNDDisasterResources (DisasterType, ResourceType)
SELECT 'DISASTER_FLOOD', ResourceType
FROM Improvement_ValidResources
WHERE ImprovementType IN ('IMPROVEMENT_FARM', 'IMPROVEMENT_FISHING_BOATS') AND
	ResourceType IN (SELECT ResourceType FROM Resources WHERE LakeEligible = 1);
	
-- Earthquake: all from the ground
INSERT INTO RNDDisasterResources (DisasterType, ResourceType)
SELECT 'DISASTER_EARTHQUAKE', ResourceType
FROM Improvement_ValidResources
WHERE ImprovementType IN ('IMPROVEMENT_MINE', 'IMPROVEMENT_QUARRY');
	
-- Tsunami: land tiles - same as Flood, sea tiles - Fishing Boats type
INSERT INTO RNDDisasterResources (DisasterType, ResourceType)
SELECT 'DISASTER_TSUNAMI', ResourceType
FROM Improvement_ValidResources
WHERE ImprovementType IN ('IMPROVEMENT_FARM', 'IMPROVEMENT_FISHING_BOATS');
	
-- Wildfire: Camp type, Plantation type, Pasture type
INSERT INTO RNDDisasterResources (DisasterType, ResourceType)
SELECT 'DISASTER_WILDFIRE', ResourceType
FROM Improvement_ValidResources
WHERE ImprovementType IN ('IMPROVEMENT_PLANTATION', 'IMPROVEMENT_PASTURE', 'IMPROVEMENT_CAMP');


--------------------------------------------------------------
-- TYPE TAGS at the end so we can use recently populated RNDDisasterResources
--------------------------------------------------------------
	
INSERT INTO TypeTags (Tag, Type) SELECT 'CLASS_SCIENCE', ResourceType FROM Resource_YieldChanges
	WHERE YieldType = 'YIELD_SCIENCE' AND ResourceType IN (SELECT DISTINCT ResourceType FROM RNDDisasterResources WHERE ResourceClass != 0);
INSERT INTO TypeTags (Tag, Type) SELECT 'CLASS_CULTURE', ResourceType FROM Resource_YieldChanges
	WHERE YieldType = 'YIELD_CULTURE' AND ResourceType IN (SELECT DISTINCT ResourceType FROM RNDDisasterResources WHERE ResourceClass != 0);
INSERT INTO TypeTags (Tag, Type) SELECT 'CLASS_FOOD', ResourceType FROM Resource_YieldChanges
	WHERE YieldType = 'YIELD_FOOD' AND ResourceType IN (SELECT DISTINCT ResourceType FROM RNDDisasterResources WHERE ResourceClass != 0) AND YieldChange > 0;
INSERT INTO TypeTags (Tag, Type) SELECT 'CLASS_PRODUCTION', ResourceType FROM Resource_YieldChanges
	WHERE YieldType = 'YIELD_PRODUCTION' AND ResourceType IN (SELECT DISTINCT ResourceType FROM RNDDisasterResources WHERE ResourceClass != 0) AND YieldChange > 0;
