
RECIPE.name = "Дробовик"
RECIPE.description = "Создание дробовика."
RECIPE.model = "models/weapons/w_shotgun.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 2,
	["reclaimed_metal"] = 2,
	["refined_metal"] = 1,
}

RECIPE.results = {
	["shotgun"] = 1
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
