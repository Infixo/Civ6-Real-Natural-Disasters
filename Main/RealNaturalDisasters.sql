--------------------------------------------------------------
-- Real Natural Disasters
-- Author: Infixo
-- March 28, 2017 - Created, risk only colors
-- March 31, 2017 - Added separated colors for active events
-- April  1, 2017 - Disaster parameters added
--------------------------------------------------------------
INSERT INTO Colors (Type,Red,Green,Blue,Alpha)
VALUES
	('COLOR_DISASTER_EARTHQUAKE', 		1.0, 0.0, 0.0, 0.9),
	('COLOR_DISASTER_EARTHQUAKE_RISK', 	0.9, 0.0, 0.0, 0.7),
	('COLOR_DISASTER_FLOOD', 			0.0, 0.4, 1.0, 0.8),
	('COLOR_DISASTER_FLOOD_RISK', 		0.0, 0.5, 0.9, 0.6),
	--('COLOR_DISASTER_METEOR', 			0.3, 0.3, 0.3, 0.8),
	('COLOR_DISASTER_METEOR', 			1.0, 0.9, 0.5, 0.9), -- RELIGION_ISLAM
	('COLOR_DISASTER_METEOR_RISK', 		0.4, 0.4, 0.4, 0.6),
	('COLOR_DISASTER_TORNADO', 			0.7, 0.5, 0.8, 0.6),
	('COLOR_DISASTER_TORNADO_RISK', 	0.7, 0.5, 0.8, 0.4),
	('COLOR_DISASTER_TSUNAMI', 			0.1, 0.0, 0.8, 0.7),
	('COLOR_DISASTER_TSUNAMI_RISK', 	0.0, 0.0, 0.8, 0.5),
	--('COLOR_DISASTER_TSUNAMI_RISK', 	0.2, 0.2, 0.5, 0.8),  -- PLAYER_NORWAY
	('COLOR_DISASTER_VOLCANO', 			0.8, 0.0, 0.1, 0.8),
	('COLOR_DISASTER_VOLCANO_RISK', 	0.6, 0.1, 0.5, 0.8),  -- PLAYER_INDIA
	--('COLOR_DISASTER_VOLCANO_RISK', 	0.8, 0.0, 0.1, 0.6),
	('COLOR_DISASTER_WILDFIRE', 		1.0, 0.3, 0.1, 0.8),
	('COLOR_DISASTER_WILDFIRE_RISK',	1.0, 0.5, 0.0, 0.5),  -- UNINVITING_APPEAL
	('COLOR_DISASTER_EVENT', 			1.0, 0.9, 0.5, 1.0); -- RELIGION_ISLAM
	
	--('COLOR_DISASTER_WILDFIRE_RISK', 	1.0, 0.3, 0.1, 0.6);

-- interesting colors to use
/*
COLOR_RELIGION_HINDUISM	166,255,107,255 - nice green
COLOR_RELIGION_ISLAM	255,242,115,255 - yellow pale
COLOR_UNINVITING_APPEAL	255,128,0,128   - orange!
COLOR_BREATHTAKING_APPEAL	0,191,0,128 - pure green
COLOR_CHARMING_APPEAL	128,255,128,128 - light green
COLOR_DISGUSTING_APPEAL	255,0,0,128     - light red
COLOR_PLAYER_NORWAY_PRIMARY	42,51,128,255 - nice blue for tsunami!
COLOR_PLAYER_ARABIA_PRIMARY	251,228,104,255 - strong yello, for drought!
COLOR_PLAYER_INDIA_PRIMARY	146,36,121,255 - pink (volcano?)
*/


-- Residual definition of all available boosts
CREATE TABLE RNDDisasters (
	DisasterType	Text NOT NULL,
	Name 			Text NOT NULL,			
	Description 	Text NOT NULL,		
	Icon 			Text NOT NULL,
	Range 			INTEGER NOT NULL DEFAULT 0,		-- 0 means - number of rings depends on magnitude
	BaseProbability	INTEGER NOT NULL DEFAULT 0,		-- probability of an event for a tile that can spawn it per one turn * 1000000
	DeltaProbability INTEGER NOT NULL DEFAULT 0,	-- range min/max
	BaseMagnitude 	INTEGER NOT NULL DEFAULT 50,	-- magnitude of a devastation applied for a tile that started the event
	MagnitudeMax 	INTEGER NOT NULL DEFAULT 100,
	MagnitudeMin 	INTEGER NOT NULL DEFAULT 0,		-- if gets less than that it's either bumped or stopped
	MagnitudeChange INTEGER NOT NULL DEFAULT 0,		-- the further from epicenter, the lower magnitude
	MaxTurns 		INTEGER NOT NULL DEFAULT 1,		-- how many turns lasts (NOY USED)
	ColorNow 		Text NOT NULL,					-- color for the current event
	ColorRisk 		Text NOT NULL, 					-- color for a risk area; will get them later using UI.GetColorValue()
	ColorHistoric 	Text NOT NULL,					-- color for a historic event
	Sound			Text NOT NULL,					-- what sound to play
	PRIMARY KEY (DisasterType),
	FOREIGN KEY (ColorNow)
		REFERENCES Colors (Type) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (ColorRisk)
		REFERENCES Colors (Type) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (ColorHistoric)
		REFERENCES Colors (Type) ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO RNDDisasters
VALUES
	("DISASTER_EARTHQUAKE","Earthquake","Earthquake description","ICON_DISASTER_EARTHQUAKE", 3, 115, 20, 50,  90, 20, -10, 1,
		"COLOR_DISASTER_EARTHQUAKE","COLOR_DISASTER_EARTHQUAKE_RISK","COLOR_DISASTER_EARTHQUAKE_RISK", "Disaster_Event_Shot"),
	("DISASTER_FLOOD",     "Flood",     "Flood description",     "ICON_DISASTER_FLOOD",      2,  65, 15, 30,  70, 20,  -5, 1,
		"COLOR_DISASTER_FLOOD",     "COLOR_DISASTER_FLOOD_RISK",     "COLOR_DISASTER_FLOOD_RISK",      "Disaster_Event_Bell"),
	("DISASTER_METEOR",    "Meteor",    "Meteor description",    "ICON_DISASTER_METEOR",     2,   3,  1, 60, 100, 20, -10, 1,
		"COLOR_DISASTER_METEOR",    "COLOR_DISASTER_METEOR_RISK",    "COLOR_DISASTER_METEOR_RISK",     "Disaster_Event_Shot"),
	("DISASTER_TORNADO",   "Tornado",   "Tornado description",   "ICON_DISASTER_TORNADO",    5,  30,  6, 40,  80, 20,  -5, 1,
		"COLOR_DISASTER_TORNADO",   "COLOR_DISASTER_TORNADO_RISK",   "COLOR_DISASTER_TORNADO_RISK",    "Disaster_Event_Bell"),
	("DISASTER_TSUNAMI",   "Tsunami",   "Tsunami description",   "ICON_DISASTER_TSUNAMI",    5, 100, 20, 50,  90, 20,  -5, 1,
		"COLOR_DISASTER_TSUNAMI",   "COLOR_DISASTER_TSUNAMI_RISK",   "COLOR_DISASTER_TSUNAMI_RISK",    "Disaster_Event_Siren"),
	("DISASTER_VOLCANO",   "Volcano",   "Volcano description",   "ICON_DISASTER_VOLCANO",    2, 155, 30, 70, 100, 20, -20, 1,
		"COLOR_DISASTER_VOLCANO",   "COLOR_DISASTER_VOLCANO_RISK",   "COLOR_DISASTER_VOLCANO_RISK",    "Disaster_Event_Shot"),
	("DISASTER_WILDFIRE",  "Wildfire",  "Wildfire description",  "ICON_DISASTER_WILDFIRE",   4,  90, 20, 30,  70, 20,  -5, 1,
		"COLOR_DISASTER_WILDFIRE",  "COLOR_DISASTER_WILDFIRE_RISK",  "COLOR_DISASTER_WILDFIRE_RISK",   "Disaster_Event_Siren");
