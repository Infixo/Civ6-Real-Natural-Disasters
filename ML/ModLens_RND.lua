print("Loading ModLens_RND.lua from Real Natural Disasters version "..GlobalParameters.RND_VERSION_MAJOR.."."..GlobalParameters.RND_VERSION_MINOR.."."..GlobalParameters.RND_VERSION_PATCH);
-- ===========================================================================
-- Real Natural Disasters
-- Author: Infixo
-- 2018-03-07: Created
-- ===========================================================================

if ExposedMembers.RND == nil then ExposedMembers.RND = {} end;
local RND = ExposedMembers.RND;


-- ===========================================================================
-- Disaster Lens
-- ===========================================================================

local LENS_DISASTER_EVENT   = "ML_DISASTER_EVENT";   -- recent event
local LENS_DISASTER_RISK_ET = "ML_DISASTER_RISK_ET"; -- Earthquake, Tornado
local LENS_DISASTER_RISK_FT = "ML_DISASTER_RISK_FT"; -- Flood, Tsunami
local LENS_DISASTER_RISK_VW = "ML_DISASTER_RISK_VW"; -- Volcano, Wildfire

-- Gathering Storm patch change - LensLayers is no more used
local m_HexColoringGreatPeople  : number = UILens.CreateLensLayerHash("Hex_Coloring_Great_People"); -- m_HexColoringGreatPeople
local m_HexColoringAppeal : number = UILens.CreateLensLayerHash("Hex_Coloring_Appeal_Level"); -- m_HexColoringAppeal
local m_AttackRange = UILens.CreateLensLayerHash("Attack_Range"); -- m_AttackRange
local m_MovementZoneOfControl : number = UILens.CreateLensLayerHash("Movement_Zone_Of_Control"); -- m_MovementZoneOfControl
--g_HexColoringAttack = UILens.CreateLensLayerHash("Hex_Coloring_Attack");
--local m_MovementRange : number = UILens.CreateLensLayerHash("Movement_Range");


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
	--print("Showing hexes for (dis) with (col)", pDisaster.Name, pDisaster.ColorRisk);
	local ePlayer = Game.GetLocalPlayer();
	local tStartPlotsWithPrevention:table = pDisaster:GetStartPlotsWithPrevention();
	if #tStartPlotsWithPrevention > 0 then
		local tOnlyRevealedTiles:table = GetOnlyRevealedTiles(tStartPlotsWithPrevention, ePlayer);
		local sColorRisk:string = GameInfo.RNDDisasters[pDisaster.Type].ColorRisk;  -- we can get rid of Color data in Disaster objects
		--print("...showing (x/n) hexes", #tOnlyRevealedTiles, #tStartPlotsWithPrevention, "with color", sColorRisk);
		UILens.SetLayerHexesColoredArea(
			m_HexColoringAppeal,
			ePlayer,
			tOnlyRevealedTiles,
			UI.GetColorValue(sColorRisk));
		if bShowAttackRange then
			UILens.ClearLayerHexes(m_AttackRange);
			UILens.SetLayerHexesArea(m_AttackRange, ePlayer, tOnlyRevealedTiles);
		end
	--else
		--dprint("...nothing to show");
	end
	if table.count(pDisaster.HistoricStartingPlots) > 0 then
		--dprint("...showing (n) historic start hexes", table.count(pDisaster.HistoricStartingPlots));
		--UILens.ClearLayerHexes(m_AttackRange);
		--UILens.SetLayerHexesArea(m_AttackRange, ePlayer, GetOnlyRevealedTiles(pDisaster.HistoricStartingPlots, ePlayer));
		--UILens.ClearLayerHexes(m_HexColoringGreatPeople);
		UILens.SetLayerHexesArea(m_HexColoringGreatPeople, ePlayer, GetOnlyRevealedTiles(pDisaster.HistoricStartingPlots, ePlayer));
	--else
		--dprint("...nothing to show for historic hexes");
	end
end

function SetTheDisasterHexes(bShowHistory:boolean)
	--dprint("FUNCAL SetTheDisasterHexes()");
	--if not RND.tTheDisaster.IsActive then return; end
	local ePlayer = Game.GetLocalPlayer();
	-- show all plots with white borders
	if table.count(RND.tTheDisaster.Plots) > 0 then
		--dprint("...showing (n) active disaster hexes", table.count(RND.tTheDisaster.Plots));
		--local eColorNow = UI.GetColorValue(RND.tTheDisaster.DisasterType.ColorNow);
		local tRevealedPlots = GetOnlyRevealedTiles(RND.tTheDisaster.Plots, ePlayer);
		UILens.SetLayerHexesColoredArea(m_HexColoringAppeal, ePlayer, tRevealedPlots,
											UI.GetColorValue( GameInfo.RNDDisasters[ RND.tTheDisaster.DisasterType.Type ].ColorNow ));
		UILens.ClearLayerHexes(m_HexColoringGreatPeople);
		UILens.SetLayerHexesArea(m_HexColoringGreatPeople, ePlayer, tRevealedPlots);
	--else
		--dprint("...nothing to show");
	end
	-- check if we can show StartingPlot with special distinction
	if PlayersVisibility[ePlayer]:IsRevealed(RND.tTheDisaster.StartingPlot) then
		UILens.ClearLayerHexes(m_MovementZoneOfControl);
		UILens.SetLayerHexesArea(m_MovementZoneOfControl, ePlayer, {RND.tTheDisaster.StartingPlot}); 
	end
	if not bShowHistory then return; end
	-- show all historic disasters
	--UILens.ClearLayerHexes(m_AttackRange);
	for _, disaster in pairs(RND.tDisasterTypes) do
		local tRevealedPlots = GetOnlyRevealedTiles(disaster.HistoricStartingPlots, ePlayer);
		UILens.SetLayerHexesColoredArea(m_HexColoringAppeal, ePlayer, tRevealedPlots, UI.GetColorValue( GameInfo.RNDDisasters[disaster.Type].ColorNow ));
		--UILens.SetLayerHexesArea(m_AttackRange, ePlayer, tRevealedPlots);
	end
end
RND.ModLens_SetTheDisasterHexes = SetTheDisasterHexes;

function SetDisasterEventHexes()
	--print("FUNCAL SetDisasterETHexes()");
	SetTheDisasterHexes(true);
	LuaEvents.RNDInfoPopup_OpenWindow();	
end

function SetDisasterETHexes()
	--print("FUNCAL SetDisasterETHexes()");
	UILens.ClearLayerHexes(m_HexColoringGreatPeople);  -- historic
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Earthquake, true);
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Tornado, false);
end

function SetDisasterFTHexes()
	--print("FUNCAL SetDisasterFTHexes()");
	UILens.ClearLayerHexes(m_HexColoringGreatPeople);  -- historic
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Flood, true);
	SetDisasterAnyHexes(RND.tDisasterTypes.Disaster_Tsunami, false);
end

function SetDisasterVWHexes()
	--print("FUNCAL SetDisasterVWHexes()");
	UILens.ClearLayerHexes(m_HexColoringGreatPeople);  -- historic
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