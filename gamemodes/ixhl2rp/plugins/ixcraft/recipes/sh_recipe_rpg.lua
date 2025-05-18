
RECIPE.name = "RPG"
RECIPE.description = "Создание RPG."
RECIPE.model = "models/weapons/w_rocket_launcher.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 3,
	["reclaimed_metal"] = 3,
	["refined_metal"] = 5
}

RECIPE.results = {
	["rpg"] = 1
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
