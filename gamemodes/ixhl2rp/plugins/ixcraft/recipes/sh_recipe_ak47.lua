
RECIPE.name = "AK-47"
RECIPE.description = "Создание AK-47."
RECIPE.model = "models/csgo/weapons/w_rif_ak47.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["wood_piece"] = 1,
	["scrap_metal"] = 1,
	["reclaimed_metal"] = 3,
	["weapon_magazine"] = 1
}

RECIPE.results = {
	["ak47"] = 1
}
RECIPE.tools = {
	"tools"
}

RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "Вам нужно быть рядом с верстаком."
end)
