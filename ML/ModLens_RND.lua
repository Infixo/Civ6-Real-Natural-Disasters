print("Loading ModLens_RND.lua from Real Natural Disasters");
-- ===========================================================================
-- Real Natural Disasters
-- Author: Infixo
-- 2018-03-07: Created
-- ===========================================================================

local RND = ExposedMembers.RND;


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
	print(sOutStr);
end



-- ===========================================================================
-- Disaster Lens
-- ===========================================================================

local LENS_DISASTER_EVENT   = "ML_DISASTER_EVENT";   -- recent event
local LENS_DISASTER_RISK_ET = "ML_DISASTER_RISK_ET"; -- Earthquake, Tornado
local LENS_DISASTER_RISK_FT = "ML_DISASTER_RISK_FT"; -- Flood, Tsunami
local LENS_DISASTER_RISK_VW = "ML_DISASTER_RISK_VW"; -- Volcano, Wildfire



-- ===========================================================================
-- Exported functions
-- ===========================================================================

local function OnGetColorPlotTable()
    local mapWidth, mapHeight = Map.GetGridSize();
    local localPlayer   :number = Game.GetLocalPlayer();
    local localPlayerVis:table = PlayersVisibility[localPlayer];

    local BarbarianColor = UI.GetColorValue("COLOR_BARBARIAN_BARB_LENS");
    local colorPlot:table = {};
    colorPlot[BarbarianColor] = {}

    for i = 0, (mapWidth * mapHeight) - 1, 1 do
        local pPlot:table = Map.GetPlotByIndex(i);
        if localPlayerVis:IsRevealed(pPlot:GetX(), pPlot:GetY()) and plotHasBarbCamp(pPlot) then
            table.insert(colorPlot[BarbarianColor], i);
        end
    end

    return colorPlot
end



-- ===========================================================================
-- Static Definitions
-- ===========================================================================

local LensEntryDisasterEvent = {
    LensButtonText    = "LOC_HUD_DISASTER_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_LENS_TOOLTIP", -- long tooltip
    Initialize = nil,
    GetColorPlotTable = OnGetColorPlotTable
}
local LensEntryDisasterRiskET = {
    LensButtonText    = "LOC_HUD_DISASTER_ET_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_ET_LENS_TOOLTIP",
    Initialize = nil,
    GetColorPlotTable = OnGetColorPlotTable
}
local LensEntryDisasterRiskFT = {
    LensButtonText    = "LOC_HUD_DISASTER_FT_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_FT_LENS_TOOLTIP",
    Initialize = nil,
    GetColorPlotTable = OnGetColorPlotTable
}
local LensEntryDisasterRiskVW = {
    LensButtonText    = "LOC_HUD_DISASTER_VW_LENS",
    LensButtonTooltip = "LOC_HUD_DISASTER_VW_LENS_TOOLTIP",
    Initialize = nil,
    GetColorPlotTable = OnGetColorPlotTable
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