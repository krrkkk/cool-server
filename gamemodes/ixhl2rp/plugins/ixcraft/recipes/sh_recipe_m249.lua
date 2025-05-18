
RECIPE.name = "M249"
RECIPE.description = "Создание M249."
RECIPE.model = "models/csgo/weapons/w_mach_m249.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 4,
	["reclaimed_metal"] = 3,
	["refined_metal"] = 2,
	["weapon_magazinehg"] = 1
}

RECIPE.results = {
	["m249"] = 1
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

