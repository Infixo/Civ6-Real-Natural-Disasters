print("Loading ModLens_RND.lua from Real Natural Disasters version "..GlobalParameters.RND_VERSION_MAJOR.."."..GlobalParameters.RND_VERSION_MINOR.."."..GlobalParameters.RND_VERSION_PATCH);
-- ===========================================================================
-- Real Natural Disasters
-- Author: Infixo
-- 2018-03-07: Created
-- ===========================================================================

local RND = ExposedMembers.RND;


-- ===========================================================================
-- Disaster Lens
-- ===========================================================================

local LENS_DISASTER_EVENT   = "ML_DISASTER_EVENT";   -- recent event
local LENS_DISASTER_RISK_ET = "ML_DISASTER_RISK_ET"; -- Earthquake, Tornado
local LENS_DISASTER_RISK_FT = "ML_DISASTER_RISK_FT"; -- Flood, Tsunami
local LENS_DISASTER_RISK_VW = "ML_DISASTER_RISK_VW"; -- Volcano, Wildfire


-- ===========================================================================
-- Functions to actually show hexes (exported functions)

-- helper - returns a subset of plots Indices that are revealed to the player
function GetOnlyRevealedTiles(pPlots:table, ePlayer:number)
	local tRevealed:table = {};
	local pPlayerVisibility = PlayersVisibility[ePlayer];
	for _,idx in pairs(pPlots) do
		if pPlayerVisibility:IsRevealed(idx) then table.insert(tRevealed, idx); end
	end
	return tRevealed;
end

-- helper
function SetDisasterAnyHexes(pDisaster:table, bShowAttackRange:boolean)
	--dprint("Showing hexes for (dis) with (col)", pDisaster.Name, pDisaster.ColorRisk);
	local ePlayer = Game.GetLocalPlayer();
	local tStartPlotsWithPrevention:table = pDisaster:GetStartPlotsWithPrevention();
	if #tStartPlotsWithPrevention > 0 then
		--dprint("...showing (n) hexes", #tStartPlotsWithPrevention);
		local tOnlyRevealedTiles:table = GetOnlyRevealedTiles(tStartPlotsWithPrevention, ePlayer);
		local sColorRisk:string = GameInfo.RNDDisasters[pDisaster.Type].ColorRisk;  -- we can get rid of Color data in Disaster objects
		UILens.SetLayerHexesColoredArea(
			LensLayers.HEX_COLORING_APPEAL_LEVEL,
			ePlayer,
			tOnlyRevealedTiles,
			UI.GetColorValue(sColorRisk));
		if bShowAttackRange then
			UILens.ClearLayerHexes(LensLayers.ATTACK_RANGE);
			UILens.SetLayerHexesArea(LensLayers.ATTACK_RANGE, ePlayer, tOnlyRevealedTiles);
		end
	--else
		--dprint("...nothing to show");
	end
	if table.count(pDisaster.HistoricStartingPlots) > 0 then
		--dprint("...showing (n) historic start hexes", table.count(pDisaster.HistoricStartingPlots));
		--UILens.ClearLayerHexes(LensLayers.ATTACK_RANGE);
		--UILens.SetLayerHexesArea(LensLayers.ATTACK_RANGE, ePlayer, GetOnlyRevealedTiles(pDisaster.HistoricStartingPlots, ePlayer));
		--UILens.ClearLayerHexes(LensLayers.HEX_COLORING_GREAT_PEOPLE);
		UILens.SetLayerHexesArea(LensLayers.HEX_COLORING_GREAT_PEOPLE, ePlayer, GetOnlyRevealedTiles(pDisaster.HistoricStartingPlots, ePlayer));
	--else
		--dprint("...nothing to show for historic hexes");
	end
end

function SetTheDisasterHexes()
	--dprint("FUNCAL SetTheDisasterHexes()");
	--if not RND.tTheDisaster.IsActive then return; end
	local ePlayer = Game.GetLocalPlayer();
	-- show all plots with white borders
	if table.count(RND.tTheDisaster.Plots) > 0 then
		--dprint("...showing (n) active disaster hexes", table.count(RND.tTheDisaster.Plots));
		--local eColorNow = UI.GetColorValue(RND.tTheDisaster.DisasterType.ColorNow);
		local tRevealedPlots = GetOnlyRevealedTiles(RND.tTheDisaster.Plots, ePlayer);
		UILens.SetLayerHexesColoredArea(LensLayers.HEX_COLORING_APPEAL_LEVEL, ePlayer, tRevealedPlots,
											UI.GetColorValue( GameInfo.RNDDisasters[ RND.tTheDisaster.DisasterType.Type ].ColorNow ));
		UILens.ClearLayerHexes(LensLayers.HEX_COLORING_GREAT_PEOPLE);
		UILens.SetLayerHexesArea(LensLayers.HEX_COLORING_GREAT_PEOPLE, ePlayer, tRevealedPlots);
	--else
		--dprint("...nothing to show");
	end
	-- check if we can show StartingPlot with special distinction
	if PlayersVisibility[ePlayer]:IsRevealed(RND.tTheDisaster.StartingPlot) then
		UILens.ClearLayerHexes(LensLayers.MOVEMENT_ZONE_OF_CONTROL);
		UILens.SetLayerHexesArea(LensLayers.MOVEMENT_ZONE_OF_CONTROL, ePlayer, {RND.tTheDisaster.StartingPlot}); 
	end
	-- show all historic disasters
	--UILens.ClearLayerHexes(LensLayers.ATTACK_RANGE);
	for _, disaster in pairs(RND.tDisasterTypes) do
		local tRevealedPlots = GetOnlyRevealedTiles(disaster.HistoricStartingPlots, ePlayer);
		UILens.SetLayerHexesColoredArea(LensLayers.HEX_COLORING_APPEAL_LEVEL, ePlayer, tRevealedPlots, UI.GetColorValue( GameInfo.RNDDisasters[disaster.Type].ColorNow ));
		--UILens.SetLayerHexesArea(LensLayers.ATTACK_RANGE, ePlayer, tRevealedPlots);
	end
end

function SetDisasterEventHexes()
	--dprint("FUNCAL SetDisasterETHexes()");
	SetTheDisasterHexes();
	LuaEvents.RNDInfoPopup_OpenWindow();	
end

function SetDisasterETHexes()
	--dprint("FUNCAL SetDisasterETHexes()");
	UILens.ClearLayerHexes(LensLayers.HEX_COLORING_GREAT_PEOPLE);  -- historic
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Earthquake, true);
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Tornado, false);
end

function SetDisasterFTHexes()
	---dprint("FUNCAL SetDisasterFTHexes()");
	UILens.ClearLayerHexes(LensLayers.HEX_COLORING_GREAT_PEOPLE);  -- historic
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Flood, true);
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Tsunami, false);
end

function SetDisasterVWHexes()
	--dprint("FUNCAL SetDisasterVWHexes()");
	UILens.ClearLayerHexes(LensLayers.HEX_COLORING_GREAT_PEOPLE);  -- historic
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Volcano, false);
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Wildfire, true);
end


-- ===========================================================================
-- Static Definitions
-- ===========================================================================

local LensEntryDisasterEvent = {
    LensButtonText    = "LOC_HUD_DISASTER_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_LENS_TOOLTIP",
    Initialize = nil,
    --GetColorPlotTable = nil, 
	NonStandardFunction = SetDisasterEventHexes,
	SortOrder = 20
}
local LensEntryDisasterRiskET = {
    LensButtonText    = "LOC_HUD_DISASTER_ET_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_ET_LENS_TOOLTIP",
    Initialize = nil,
    --GetColorPlotTable = nil,
	NonStandardFunction = SetDisasterETHexes,
	SortOrder = 21
}
local LensEntryDisasterRiskFT = {
    LensButtonText    = "LOC_HUD_DISASTER_FT_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_FT_LENS_TOOLTIP",
    Initialize = nil,
    --GetColorPlotTable = nil,
	NonStandardFunction = SetDisasterFTHexes,
	SortOrder = 22
}
local LensEntryDisasterRiskVW = {
    LensButtonText    = "LOC_HUD_DISASTER_VW_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_VW_LENS_TOOLTIP",
    Initialize = nil,
    --GetColorPlotTable = nil,
	NonStandardFunction = SetDisasterVWHexes,
	SortOrder = 23
}

-- minimappanel.lua
if g_ModLenses ~= nil then
    g_ModLenses[LENS_DISASTER_EVENT]   = LensEntryDisasterEvent;
    g_ModLenses[LENS_DISASTER_RISK_ET] = LensEntryDisasterRiskET;
    g_ModLenses[LENS_DISASTER_RISK_FT] = LensEntryDisasterRiskFT;
    g_ModLenses[LENS_DISASTER_RISK_VW] = LensEntryDisasterRiskVW;
end


-- modallenspanel.lua
if g_ModLensModalPanel ~= nil then
	-- recent event (all colors bright)
    g_ModLensModalPanel[LENS_DISASTER_EVENT] = {};
    g_ModLensModalPanel[LENS_DISASTER_EVENT].LensTextKey = "LOC_HUD_DISASTER_LENS";
    g_ModLensModalPanel[LENS_DISASTER_EVENT].Legend = {
        {"LOC_TOOLTIP_DISASTER_RISK_METEOR",     UI.GetColorValue("COLOR_DISASTER_METEOR")},
        {"LOC_TOOLTIP_DISASTER_RISK_EARTHQUAKE", UI.GetColorValue("COLOR_DISASTER_EARTHQUAKE")},
        {"LOC_TOOLTIP_DISASTER_RISK_TORNADO",    UI.GetColorValue("COLOR_DISASTER_TORNADO")},
        {"LOC_TOOLTIP_DISASTER_RISK_FLOOD",      UI.GetColorValue("COLOR_DISASTER_FLOOD")},
        {"LOC_TOOLTIP_DISASTER_RISK_TSUNAMI",    UI.GetColorValue("COLOR_DISASTER_TSUNAMI")},
        {"LOC_TOOLTIP_DISASTER_RISK_VOLCANO",    UI.GetColorValue("COLOR_DISASTER_VOLCANO")},
        {"LOC_TOOLTIP_DISASTER_RISK_WILDFIRE",   UI.GetColorValue("COLOR_DISASTER_WILDFIRE")}
    };
	-- Earthquake, Tornado
    g_ModLensModalPanel[LENS_DISASTER_RISK_ET] = {};
    g_ModLensModalPanel[LENS_DISASTER_RISK_ET].LensTextKey = "LOC_HUD_DISASTER_ET_LENS";
    g_ModLensModalPanel[LENS_DISASTER_RISK_ET].Legend = {
        {"LOC_TOOLTIP_DISASTER_RISK_EARTHQUAKE", UI.GetColorValue("COLOR_DISASTER_EARTHQUAKE_RISK")},
        {"LOC_TOOLTIP_DISASTER_RISK_TORNADO",    UI.GetColorValue("COLOR_DISASTER_TORNADO_RISK")}
    };
	-- Flood, Tsunami
    g_ModLensModalPanel[LENS_DISASTER_RISK_FT] = {};
    g_ModLensModalPanel[LENS_DISASTER_RISK_FT].LensTextKey = "LOC_HUD_DISASTER_FT_LENS";
    g_ModLensModalPanel[LENS_DISASTER_RISK_FT].Legend = {
        {"LOC_TOOLTIP_DISASTER_RISK_FLOOD",   UI.GetColorValue("COLOR_DISASTER_FLOOD_RISK")},
        {"LOC_TOOLTIP_DISASTER_RISK_TSUNAMI", UI.GetColorValue("COLOR_DISASTER_TSUNAMI_RISK")}
    };
	-- Volcano, Wildfire
    g_ModLensModalPanel[LENS_DISASTER_RISK_VW] = {};
    g_ModLensModalPanel[LENS_DISASTER_RISK_VW].LensTextKey = "LOC_HUD_DISASTER_VW_LENS";
    g_ModLensModalPanel[LENS_DISASTER_RISK_VW].Legend = {
        {"LOC_TOOLTIP_DISASTER_RISK_VOLCANO",  UI.GetColorValue("COLOR_DISASTER_VOLCANO_RISK")},
        {"LOC_TOOLTIP_DISASTER_RISK_WILDFIRE", UI.GetColorValue("COLOR_DISASTER_WILDFIRE_RISK")}
    };
end



print("OK loaded ModLens_RND.lua from Real Natural Disasters");