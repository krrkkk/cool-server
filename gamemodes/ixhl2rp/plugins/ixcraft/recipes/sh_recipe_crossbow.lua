
RECIPE.name = "Арбалет"
RECIPE.description = "Создание арбалета."
RECIPE.model = "models/weapons/w_crossbow.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 3,
	["reclaimed_metal"] = 1,
	["scrap_electronics"] = 1,
	["weapon_scope"] = 1
}

RECIPE.results = {
	["crossbow"] = 1
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
