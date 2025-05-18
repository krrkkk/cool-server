
RECIPE.name = "Одежда медика сопротивления"
RECIPE.description = "Создание."
RECIPE.model = "models/tnb/items/shirt_rebel1.mdl"
RECIPE.category = "Броня"
RECIPE.requirements = {
	["cloth_scrap"] = 1,
	["sewn_cloth"] = 1,
	["scrap_metal"] = 1
}

RECIPE.results = {
	["resmed"] = 1
}

RECIPE.tools = {
	"sewing_kit"
}

RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "Вам нужно быть рядом с верстаком."
end)
