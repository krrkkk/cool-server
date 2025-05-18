
RECIPE.name = "Пистолет"
RECIPE.description = "Создание пистолета."
RECIPE.model = "models/weapons/w_pistol.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 1,
	["reclaimed_metal"] = 1,
	["weapon_magazinepp"] = 1
}

RECIPE.results = {
	["pistol"] = 1
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
