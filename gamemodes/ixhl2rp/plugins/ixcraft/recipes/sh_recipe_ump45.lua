
RECIPE.name = "UMP-45"
RECIPE.description = "Создание UMP-45."
RECIPE.model = "models/csgo/weapons/w_smg_ump45.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 3,
	["reclaimed_metal"] = 3,
	["weapon_magazinepp"] = 1
}
RECIPE.results = {
	["ump"] = 1
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
