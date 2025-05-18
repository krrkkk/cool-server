
RECIPE.name = "Одежда сопротивления с доп. броней"
RECIPE.description = "Создание."
RECIPE.model = "models/tnb/items/shirt_rebel_molle.mdl"
RECIPE.category = "Броня"
RECIPE.requirements = {
	["cloth_scrap"] = 1,
	["sewn_cloth"] = 1,
	["refined_metal"] = 2
}

RECIPE.results = {
	["resmpf"] = 1
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

