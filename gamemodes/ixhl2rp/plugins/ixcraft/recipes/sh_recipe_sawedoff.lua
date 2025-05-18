
RECIPE.name = "SAWEDOFF"
RECIPE.description = "Создание SAWEDOFF."
RECIPE.model = "models/csgo/weapons/w_shot_sawedoff.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 2,
	["reclaimed_metal"] = 2
}

RECIPE.results = {
	["sawedoff"] = 1
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
