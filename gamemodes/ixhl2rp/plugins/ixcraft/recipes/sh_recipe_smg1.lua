
RECIPE.name = "MP7"
RECIPE.description = "Создание MP7."
RECIPE.model = "models/weapons/w_smg1.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 1,
	["reclaimed_metal"] = 1,
	["weapon_magazinepp"] = 1
}

RECIPE.results = {
	["smg1"] = 1
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
