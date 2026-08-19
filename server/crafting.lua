-----------------------------------------------------------------------
--  CRAFTING (server) - overeni surovin, odebrani, pridani vysledku
--  Chrani pred podvrzenim: server si sam najde recept dle stanice+vysledku.
-----------------------------------------------------------------------

-- Sestav rychly lookup: [stationKey][resultItem] = recipe
local recipeLookup = {}

CreateThread(function()
    for stationKey, station in pairs(Config.CraftStations) do
        recipeLookup[stationKey] = {}
        for _, r in ipairs(station.recipes) do
            recipeLookup[stationKey][r.result] = r
        end
    end
    -- drinks jako zvlast "stanice"
    recipeLookup['drinks'] = {}
    for _, r in ipairs(Config.Drinks.recipes) do
        recipeLookup['drinks'][r.result] = r
    end
end)

lib.callback.register('vx_burgershot:craft', function(source, stationKey, resultItem)
    local src = source

    if not Bridge.HasJob(src) then return 'nojob' end

    local station = recipeLookup[stationKey]
    if not station then return 'error' end
    local recipe = station[resultItem]
    if not recipe then return 'error' end

    -- kontrola surovin
    local ok = Bridge.HasItems(src, recipe.requires or {})
    if not ok then return 'missing' end

    -- odeber suroviny
    for _, req in ipairs(recipe.requires or {}) do
        if not Bridge.RemoveItem(src, req.item, req.amount) then
            return 'missing'
        end
    end

    -- pridej vysledek
    Bridge.AddItem(src, recipe.result, recipe.amount or 1)
    return 'ok'
end)
