print("Loading InGameExp.lua from Real Natural Disasters.");
-- ===========================================================================
-- Real Natural Disasters
-- Author: Infixo
-- Created: March 31st, 2017
-- Expose UI context function to use them in other scripts
-- ===========================================================================

function GetCityPlots(pCity:table)
	contextCity = CityManager.GetCity(pCity:GetOwner(), pCity:GetID());
	return Map.GetCityPlots():GetPurchasedPlots(contextCity);
end

function Initialize()

	if not ExposedMembers.RND then ExposedMembers.RND = {} end;
	-- functions
	ExposedMembers.RND.GetCityPlots			= GetCityPlots;
	-- objects
	ExposedMembers.RND.Calendar				= Calendar;
	ExposedMembers.RND.GameConfiguration	= GameConfiguration;
	ExposedMembers.RND.MapConfiguration		= MapConfiguration;
	ExposedMembers.RND.UI 					= UI;
	ExposedMembers.RND.UILens 				= UILens;
	ExposedMembers.RND.AssetPreview			= AssetPreview;
end
Initialize();

print("Finished loading InGameExp.lua from Real Natural Disasters.");