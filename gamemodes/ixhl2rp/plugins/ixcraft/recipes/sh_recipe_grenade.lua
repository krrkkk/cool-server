
RECIPE.name = "Граната"
RECIPE.description = "Создание гранаты."
RECIPE.model = "models/weapons/w_grenade.mdl"
RECIPE.category = "Оружие"
RECIPE.requirements = {
	["scrap_metal"] = 3,
	["gunpowder"] = 2
}

RECIPE.results = {
	["grenade"] = 1
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
