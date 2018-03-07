--------------------------------------------------------------
-- Real Natural Disasters - Buildings and Projects
-- Author: Infixo
-- April 23, 2017 - Created
--------------------------------------------------------------


--------------------------------------------------------------
-- DISASTER RELATED BUILDINGS AND PROJECTS
-- Must define: Types, Buildings, Building_YieldChanges, BuildingPrereqs, BuildingModifiers, and a set of required Modifiers (at the end)
-- DAM: Must be on river tile, All city river-tiles get +1 prod & +1 food
-- BREAKWATERS: Harbor, Yields food/prod in coastal waters
--------------------------------------------------------------


-- BUILDNG DAM
-- Must be on river tile, All city river-tiles get +1 prod & +1 food

INSERT INTO Types (Type, Kind)
VALUES
	('BUILDING_EARLY_WARNING', 	   'KIND_BUILDING'),  -- Modern, the actual name will be different, like Disaster Research Center
	('BUILDING_FIRE_STATION', 	   'KIND_BUILDING'),  -- Industrial
	('BUILDING_EMERGENCY_SHELTER', 'KIND_BUILDING'),  -- Modern
	('BUILDING_BREAKWATERS', 	   'KIND_BUILDING'),  -- Industrial
	('BUILDING_RIVER_DAM', 		   'KIND_BUILDING'),  -- Modern
	('BUILDING_INSURANCE_COMPANY', 'KIND_BUILDING');  -- Industrial

INSERT INTO Buildings (BuildingType, PrereqTech, Cost, PrereqDistrict, RequiresAdjacentRiver, PurchaseYield, Maintenance, CitizenSlots, AdvisorType, Name, Description)
VALUES
	('BUILDING_EARLY_WARNING', 	   'TECH_RADIO',       525, 'DISTRICT_CAMPUS', 		    0, 'YIELD_GOLD', 3,    1, 'ADVISOR_GENERIC', 'LOC_BUILDING_EARLY_WARNING_NAME',     'LOC_BUILDING_EARLY_WARNING_DESCRIPTION'),
	('BUILDING_FIRE_STATION', 	   'TECH_SANITATION',  355, 'DISTRICT_ENCAMPMENT', 	    0, 'YIELD_GOLD', 2,    1, 'ADVISOR_GENERIC', 'LOC_BUILDING_FIRE_STATION_NAME',      'LOC_BUILDING_FIRE_STATION_DESCRIPTION'),
	('BUILDING_EMERGENCY_SHELTER', 'TECH_ELECTRICITY', 465, 'DISTRICT_CITY_CENTER', 	0, 'YIELD_GOLD', 2, NULL, 'ADVISOR_GENERIC', 'LOC_BUILDING_EMERGENCY_SHELTER_NAME', 'LOC_BUILDING_EMERGENCY_SHELTER_DESCRIPTION'),
	('BUILDING_BREAKWATERS', 	   'TECH_STEAM_POWER', 355, 'DISTRICT_HARBOR',          0, 'YIELD_GOLD', 2, NULL, 'ADVISOR_GENERIC', 'LOC_BUILDING_BREAKWATERS_NAME',       'LOC_BUILDING_BREAKWATERS_DESCRIPTION'),
	('BUILDING_RIVER_DAM', 		   'TECH_STEEL', 	   525, 'DISTRICT_INDUSTRIAL_ZONE', 1, 'YIELD_GOLD', 3,    1, 'ADVISOR_GENERIC', 'LOC_BUILDING_RIVER_DAM_NAME',         'LOC_BUILDING_RIVER_DAM_DESCRIPTION'),
	('BUILDING_INSURANCE_COMPANY', 'TECH_ECONOMICS',   355, 'DISTRICT_COMMERCIAL_HUB',  0, 'YIELD_GOLD', 2,    1, 'ADVISOR_GENERIC', 'LOC_BUILDING_INSURANCE_COMPANY_NAME', 'LOC_BUILDING_INSURANCE_COMPANY_DESCRIPTION');

INSERT INTO BuildingPrereqs (Building, PrereqBuilding)
VALUES
	('BUILDING_EMERGENCY_SHELTER', 'BUILDING_EARLY_WARNING'),
	('BUILDING_RIVER_DAM',         'BUILDING_FACTORY'),
	('BUILDING_INSURANCE_COMPANY', 'BUILDING_BANK');
	
INSERT INTO Building_YieldChanges (BuildingType,YieldType,YieldChange)
VALUES
	('BUILDING_EARLY_WARNING',     'YIELD_SCIENCE',    3),
	('BUILDING_FIRE_STATION',      'YIELD_PRODUCTION', 2),
	('BUILDING_EMERGENCY_SHELTER', 'YIELD_CULTURE',    2),
	('BUILDING_EMERGENCY_SHELTER', 'YIELD_FAITH',      2),
	('BUILDING_RIVER_DAM',         'YIELD_PRODUCTION', 3),
	('BUILDING_INSURANCE_COMPANY', 'YIELD_FAITH',      2);


--------------------------------------------------------------
-- MAPPING TO DISASTERS
-- Parameters table
-- Columns: DisasterType, BuildingType, PreventionClass, Value, Range
-- PreventionClass: 1 - Reduce Magnitude (damage), 2 - Reduce Magnitude (pop loss), 3 - Prevent Disaster (remove start plots), 4 - Insurance
-- Range: we could use 0 as indicator ‘City Limits’
--------------------------------------------------------------


CREATE TABLE RNDDisasterBuildings (
	DisasterType	TEXT NOT NULL REFERENCES RNDDisasters (DisasterType) ON DELETE CASCADE ON UPDATE CASCADE,
	BuildingType	TEXT NOT NULL REFERENCES Buildings (BuildingType) ON DELETE CASCADE ON UPDATE CASCADE,
	PreventionClass	INTEGER NOT NULL CHECK (PreventionClass IN (1,2,3,4)) DEFAULT 1,
	Range	INTEGER NOT NULL DEFAULT 0,
	Value	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY (DisasterType, BuildingType, PreventionClass)
);

INSERT INTO RNDDisasterBuildings
VALUES
	('DISASTER_TSUNAMI',  'BUILDING_BREAKWATERS',  1, 2, -20),
	('DISASTER_WILDFIRE', 'BUILDING_FIRE_STATION', 3, 2,   0),
	('DISASTER_FLOOD', 	  'BUILDING_RIVER_DAM',    3, 3,   0);

INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_EARLY_WARNING',     1,  6, -10 FROM RNDDisasters;
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_FIRE_STATION',      1, -1, -10 FROM RNDDisasters;
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_EMERGENCY_SHELTER', 2, -1, -20 FROM RNDDisasters;
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_INSURANCE_COMPANY', 4, -1,   0 FROM RNDDisasters;

-------TESTING---------
/*
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_PALACE', 1, 1, -13 FROM RNDDisasters; 
delete from RNDDisasterBuildings where BuildingType = 'BUILDING_PALACE' and DisasterType IN ('DISASTER_VOLCANO', 'DISASTER_TSUNAMI');
INSERT INTO RNDDisasterBuildings VALUES ('DISASTER_FLOOD', 'BUILDING_PALACE', 3, 0, 0);  -- remove flood
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_MONUMENT', 3, 2, 0 FROM RNDDisasters;  -- remove more dis
delete from RNDDisasterBuildings where BuildingType = 'BUILDING_MONUMENT' and DisasterType IN ('DISASTER_FLOOD', 'DISASTER_TORNADO');
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_MONUMENT', 1, 2, -6 FROM RNDDisasters; 
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_GRANARY', 1, -1, -14 FROM RNDDisasters; 
delete from RNDDisasterBuildings where BuildingType = 'BUILDING_GRANARY' and DisasterType IN ('DISASTER_EARTHQUAKE', 'DISASTER_WILDFIRE');
INSERT INTO RNDDisasterBuildings SELECT DisasterType, 'BUILDING_GRANARY', 2, -1, -12 FROM RNDDisasters; -- protect pop
*/
	
--------------------------------------------------------------
-- BUILDING_RIVER_DAM
--------------------------------------------------------------

INSERT INTO GameModifiers (ModifierId) VALUES ('RIVER_DAM_YIELD_FOOD'), ('RIVER_DAM_YIELD_PRODUCTION');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
VALUES
	('RIVER_DAM_YIELD_FOOD', 	   'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_RIVER_DAM_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	('RIVER_DAM_YIELD_PRODUCTION', 'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_RIVER_DAM_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	('RIVER_DAM_YIELD_FOOD_MODIFIER', 		'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_ADJACENT_TO_RIVER_REQUIREMENTS'),  -- can't set permanent because can be pillaged
	('RIVER_DAM_YIELD_PRODUCTION_MODIFIER', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_ADJACENT_TO_RIVER_REQUIREMENTS');  -- can't set permanent because can be pillaged

-- Important: MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD - tiles with Districts DON'T get any bonus (e.g. City Center nor IZ where Dam was built);	
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES
	('RIVER_DAM_YIELD_FOOD',       			'ModifierId', 'RIVER_DAM_YIELD_FOOD_MODIFIER'),
	('RIVER_DAM_YIELD_PRODUCTION', 			'ModifierId', 'RIVER_DAM_YIELD_PRODUCTION_MODIFIER'),
	('RIVER_DAM_YIELD_FOOD_MODIFIER', 		'YieldType',  'YIELD_FOOD'),
	('RIVER_DAM_YIELD_FOOD_MODIFIER', 		'Amount',     '1'),
	('RIVER_DAM_YIELD_PRODUCTION_MODIFIER', 'YieldType',  'YIELD_PRODUCTION'),
	('RIVER_DAM_YIELD_PRODUCTION_MODIFIER', 'Amount',     '1');

-- Requirement city has river dam
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)		 VALUES ('CITY_HAS_RIVER_DAM_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES ('CITY_HAS_RIVER_DAM_REQUIREMENTS', 'REQUIRES_CITY_HAS_RIVER_DAM');
INSERT INTO Requirements (RequirementId, RequirementType)				 VALUES ('REQUIRES_CITY_HAS_RIVER_DAM', 'REQUIREMENT_CITY_HAS_BUILDING');
INSERT INTO RequirementArguments (RequirementId, Name, Value)			 VALUES ('REQUIRES_CITY_HAS_RIVER_DAM', 'BuildingType', 'BUILDING_RIVER_DAM');


--------------------------------------------------------------
-- BUILDING_BREAKWATERS
--------------------------------------------------------------

INSERT INTO GameModifiers (ModifierId) VALUES ('BREAKWATERS_YIELD_FOOD'), ('BREAKWATERS_YIELD_PRODUCTION');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
VALUES
	('BREAKWATERS_YIELD_FOOD', 	     'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_BREAKWATERS_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	('BREAKWATERS_YIELD_PRODUCTION', 'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_BREAKWATERS_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	('BREAKWATERS_YIELD_FOOD_MODIFIER', 	  'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_ADJACENT_TO_HARBOR_REQUIREMENTS'),  -- can't set permanent because can be pillaged
	('BREAKWATERS_YIELD_PRODUCTION_MODIFIER', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_ADJACENT_TO_HARBOR_REQUIREMENTS');  -- can't set permanent because can be pillaged

-- Important: MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD - tiles with Districts DON'T get any bonus (e.g. City Center nor IZ where Dam was built);	
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES
	('BREAKWATERS_YIELD_FOOD',       		  'ModifierId', 'BREAKWATERS_YIELD_FOOD_MODIFIER'),
	('BREAKWATERS_YIELD_PRODUCTION', 		  'ModifierId', 'BREAKWATERS_YIELD_PRODUCTION_MODIFIER'),
	('BREAKWATERS_YIELD_FOOD_MODIFIER', 	  'YieldType',  'YIELD_FOOD'),
	('BREAKWATERS_YIELD_FOOD_MODIFIER', 	  'Amount',     '1'),
	('BREAKWATERS_YIELD_PRODUCTION_MODIFIER', 'YieldType',  'YIELD_PRODUCTION'),
	('BREAKWATERS_YIELD_PRODUCTION_MODIFIER', 'Amount',     '1');

-- Requirement City has Breakwaters
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)		 VALUES ('CITY_HAS_BREAKWATERS_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES ('CITY_HAS_BREAKWATERS_REQUIREMENTS', 'REQUIRES_CITY_HAS_BREAKWATERS');
INSERT INTO Requirements (RequirementId, RequirementType)				 VALUES ('REQUIRES_CITY_HAS_BREAKWATERS', 'REQUIREMENT_CITY_HAS_BUILDING');
INSERT INTO RequirementArguments (RequirementId, Name, Value)			 VALUES ('REQUIRES_CITY_HAS_BREAKWATERS', 'BuildingType', 'BUILDING_BREAKWATERS');

-- Requirement Plot is adjacent to Harbor
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)		 VALUES ('PLOT_ADJACENT_TO_HARBOR_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES ('PLOT_ADJACENT_TO_HARBOR_REQUIREMENTS', 'REQUIRES_PLOT_ADJACENT_TO_HARBOR');
INSERT INTO Requirements (RequirementId, RequirementType)				 VALUES ('REQUIRES_PLOT_ADJACENT_TO_HARBOR', 'REQUIREMENT_PLOT_ADJACENT_DISTRICT_TYPE_MATCHES');
INSERT INTO RequirementArguments (RequirementId, Name, Value)			 VALUES ('REQUIRES_PLOT_ADJACENT_TO_HARBOR', 'DistrictType', 'DISTRICT_HARBOR');


--------------------------------------------------------------
-- BUILDING_INSURANCE_COMPANY
-- Cost of insurance increases with Districts (counting buildings doesn't work)
-- Also, some special districts could get extra cost (e.g. Airport, Spaceport)
-- Lots of modifiers to define
--------------------------------------------------------------

-- WORKING when CITY_HAS_INSURANCE_COMPANY_REQUIREMENTS is applied
INSERT INTO GameModifiers (ModifierId)
VALUES
	('INSURANCE_COST_2_DISTRICTS'),
	('INSURANCE_COST_3_DISTRICTS'),
	('INSURANCE_COST_4_DISTRICTS');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
VALUES
	-- these modifiers will attach an actual set of cost-generating modifiers once the city builds an insurance company
	('INSURANCE_COST_2_DISTRICTS', 'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_INSURANCE_COMPANY_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	('INSURANCE_COST_3_DISTRICTS', 'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_INSURANCE_COMPANY_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	('INSURANCE_COST_4_DISTRICTS', 'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'CITY_HAS_INSURANCE_COMPANY_REQUIREMENTS'),  -- WORKING FOR SUBJECT
	-- these modifiers will actually add cost when number of districts increases
	('INSURANCE_COST_2_DISTRICTS_MODIFIER', 'MODIFIER_BUILDING_YIELD_CHANGE', 0, 0, 'CITY_HAS_ATLEAST_2_DISTRICTS_REQUIREMENTS', NULL),  -- WORKING AS OWNER REQ
	('INSURANCE_COST_3_DISTRICTS_MODIFIER', 'MODIFIER_BUILDING_YIELD_CHANGE', 0, 0, 'CITY_HAS_ATLEAST_3_DISTRICTS_REQUIREMENTS', NULL),  -- WORKING AS OWNER REQ
	('INSURANCE_COST_4_DISTRICTS_MODIFIER', 'MODIFIER_BUILDING_YIELD_CHANGE', 0, 0, 'CITY_HAS_ATLEAST_4_DISTRICTS_REQUIREMENTS', NULL);  -- WORKING AS OWNER REQ
	
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES
	-- attaching a real one
	('INSURANCE_COST_2_DISTRICTS', 'ModifierId', 'INSURANCE_COST_2_DISTRICTS_MODIFIER'),
	('INSURANCE_COST_3_DISTRICTS', 'ModifierId', 'INSURANCE_COST_3_DISTRICTS_MODIFIER'),
	('INSURANCE_COST_4_DISTRICTS', 'ModifierId', 'INSURANCE_COST_4_DISTRICTS_MODIFIER'),
	-- real cost generating modifiers
	('INSURANCE_COST_2_DISTRICTS_MODIFIER', 'BuildingType', 'BUILDING_INSURANCE_COMPANY'),
	('INSURANCE_COST_2_DISTRICTS_MODIFIER', 'YieldType',    'YIELD_GOLD'),
	('INSURANCE_COST_2_DISTRICTS_MODIFIER', 'Amount',       '-1'),
	('INSURANCE_COST_3_DISTRICTS_MODIFIER', 'BuildingType', 'BUILDING_INSURANCE_COMPANY'),
	('INSURANCE_COST_3_DISTRICTS_MODIFIER', 'YieldType',    'YIELD_GOLD'),
	('INSURANCE_COST_3_DISTRICTS_MODIFIER', 'Amount',       '-2'),
	('INSURANCE_COST_4_DISTRICTS_MODIFIER', 'BuildingType', 'BUILDING_INSURANCE_COMPANY'),
	('INSURANCE_COST_4_DISTRICTS_MODIFIER', 'YieldType',    'YIELD_GOLD'),
	('INSURANCE_COST_4_DISTRICTS_MODIFIER', 'Amount',       '-3');

-- Requirement city has insurance building WORKING for subjects of GameModifiers
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) 		 VALUES ('CITY_HAS_INSURANCE_COMPANY_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES ('CITY_HAS_INSURANCE_COMPANY_REQUIREMENTS', 'REQUIRES_CITY_HAS_INSURANCE_COMPANY');
INSERT INTO Requirements (RequirementId, RequirementType) 				 VALUES ('REQUIRES_CITY_HAS_INSURANCE_COMPANY', 'REQUIREMENT_CITY_HAS_BUILDING');
INSERT INTO RequirementArguments (RequirementId, Name, Value) 			 VALUES ('REQUIRES_CITY_HAS_INSURANCE_COMPANY', 'BuildingType', 'BUILDING_INSURANCE_COMPANY');
	
-- Requirements for counting - at least N districts - WORKING FOR SUBJECT AND OWNER
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES
	('CITY_HAS_ATLEAST_2_DISTRICTS_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL'),
	('CITY_HAS_ATLEAST_3_DISTRICTS_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL'),
	('CITY_HAS_ATLEAST_4_DISTRICTS_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES
	('CITY_HAS_ATLEAST_2_DISTRICTS_REQUIREMENTS', 'REQUIRES_CITY_HAS_ATLEAST_2_DISTRICTS'),
	('CITY_HAS_ATLEAST_3_DISTRICTS_REQUIREMENTS', 'REQUIRES_CITY_HAS_ATLEAST_3_DISTRICTS'),
	('CITY_HAS_ATLEAST_4_DISTRICTS_REQUIREMENTS', 'REQUIRES_CITY_HAS_ATLEAST_4_DISTRICTS');
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES
	('REQUIRES_CITY_HAS_ATLEAST_2_DISTRICTS', 'REQUIREMENT_COLLECTION_COUNT_ATLEAST'),
	('REQUIRES_CITY_HAS_ATLEAST_3_DISTRICTS', 'REQUIREMENT_COLLECTION_COUNT_ATLEAST'),
	('REQUIRES_CITY_HAS_ATLEAST_4_DISTRICTS', 'REQUIREMENT_COLLECTION_COUNT_ATLEAST');
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES
	('REQUIRES_CITY_HAS_ATLEAST_2_DISTRICTS', 'CollectionType', 'COLLECTION_CITY_DISTRICTS'),
	('REQUIRES_CITY_HAS_ATLEAST_2_DISTRICTS', 'Count', '2'),
	('REQUIRES_CITY_HAS_ATLEAST_3_DISTRICTS', 'CollectionType', 'COLLECTION_CITY_DISTRICTS'),
	('REQUIRES_CITY_HAS_ATLEAST_3_DISTRICTS', 'Count', '3'),
	('REQUIRES_CITY_HAS_ATLEAST_4_DISTRICTS', 'CollectionType', 'COLLECTION_CITY_DISTRICTS'),
	('REQUIRES_CITY_HAS_ATLEAST_4_DISTRICTS', 'Count', '4');
	
	
--------------------------------------------------------------
-- CITY PROJECT
-- Cost should be around 500 (base 50) in Modern, 800 (base 63) in Atomic, 1300 (base 92) in Information
-- Cost progression:
-- Ancient = 10
-- Classical = 32
-- Medieval = 47 (32*1,47)
-- Renaissance = 67 (47*1,43)
-- Industrial = 82 (67*1,22)
-- Modern = 102 (82*1,24)
-- Atomic = 127 (102*1,25)
-- Information = 141 (127(1,11)
-- ProjectCompletionModifiers: will not use that table as it affects only single city where project was completed
-- In Atomic/Information cities have 40-80 prod/turn, a building cost 500-600, so it takes 7-12 turns to build
-- Additional 10% cost is ~50-60 prod, so it's 4-7 prod/turn; set for 5
--------------------------------------------------------------

-- Project definition
INSERT INTO Types (Type, Kind) VALUES ('PROJECT_DISASTER_RESISTANCE', 'KIND_PROJECT');
INSERT INTO Projects (ProjectType, Name, ShortName, Description, Cost, CostProgressionModel, CostProgressionParam1, MaxPlayerInstances, AdvisorType, PrereqTech)
VALUES ('PROJECT_DISASTER_RESISTANCE', 'LOC_PROJECT_DISASTER_RESISTANCE_NAME', 'LOC_PROJECT_DISASTER_RESISTANCE_SHORT_NAME', 'LOC_PROJECT_DISASTER_RESISTANCE_DESCRIPTION',
			50, 'COST_PROGRESSION_GAME_PROGRESS', 1500, 1, 'ADVISOR_GENERIC', 'TECH_STEEL'); --'TECH_STEEL');  -- tech NULL is for TESTING, Modern Era
-- negative values are not supported
INSERT INTO Project_YieldConversions (ProjectType, YieldType, PercentOfProductionRate)
VALUES ('PROJECT_DISASTER_RESISTANCE', 'YIELD_SCIENCE', 50);  -- should get approx. 1/4 of an Atomic tech, so ~350 beakers

-- WORKING Modifier for attaching an actual working modifier to all cities that have completed the project
-- Uses game provided MODIFIER_ALL_CITIES_ATTACH_MODIFIER
INSERT INTO GameModifiers (ModifierId) VALUES ('DISASTER_RESISTANT_BUILDING_PRODUCTION');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
VALUES ('DISASTER_RESISTANT_BUILDING_PRODUCTION', 'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, NULL, 'PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE_REQUIREMENTS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('DISASTER_RESISTANT_BUILDING_PRODUCTION', 'ModifierId', 'PROJECT_DISASTER_RESISTANCE_COMPLETED_MODIFIER');

-- WORKING Modifier changes all building production in a specific city
-- EFFECT_ADJUST_BUILDING_PRODUCTION = yield adjustment e.g. +15% prod, BUT it's for a SPECIFIC Building! cannot use it
-- EFFECT_ADJUST_CITY_PRODUCTION_BUILDING = yield change e.g. +2 prod
INSERT INTO Types (Type, Kind) VALUES ('MODIFIER_SINGLE_CITY_ADJUST_CITY_PRODUCTION_BUILDING', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_SINGLE_CITY_ADJUST_CITY_PRODUCTION_BUILDING', 'COLLECTION_OWNER', 'EFFECT_ADJUST_CITY_PRODUCTION_BUILDING');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
VALUES ('PROJECT_DISASTER_RESISTANCE_COMPLETED_MODIFIER', 'MODIFIER_SINGLE_CITY_ADJUST_CITY_PRODUCTION_BUILDING', 1, 1, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('PROJECT_DISASTER_RESISTANCE_COMPLETED_MODIFIER', 'Amount', '-5');  -- always yield change (like in CS bonuses)

-- Requirement for project completion
INSERT INTO RequirementSets (RequirementSetId,RequirementSetType)		VALUES ('PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId,RequirementId)	VALUES ('PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE_REQUIREMENTS', 'REQUIRES_PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE');
INSERT INTO Requirements (RequirementId,RequirementType)				VALUES ('REQUIRES_PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE', 'REQUIREMENT_PLAYER_HAS_COMPLETED_PROJECT');
INSERT INTO RequirementArguments (RequirementId,Name,Value)				VALUES ('REQUIRES_PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE', 'ProjectType', 'PROJECT_DISASTER_RESISTANCE'),
																			   ('REQUIRES_PLAYER_COMPLETED_PROJECT_DISASTER_RESISTANCE', 'MinimumCompletions', '1');
