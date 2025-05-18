
RECIPE.name = "Одежда сопротивления с комплектом брони OTA"
RECIPE.description = "Создание."
RECIPE.model = "models/tnb/items/shirt_rebeloverwatch.mdl"
RECIPE.category = "Броня"
RECIPE.requirements = {
	["cloth_scrap"] = 2,
	["sewn_cloth"] = 2,
	["refined_metal"] = 3
}

RECIPE.results = {
	["resows"] = 1
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
