-----------------------------------------------------------------------
--  CRAFTING (client)
--  Vice stanic, kazda ma svoje recepty. Menu ukazuje obrazky pri najeti.
-----------------------------------------------------------------------

local function craftRecipe(stationKey, recipe)
    -- overeni surovin resi server (kvuli cheatum), tady jen progressbar + request
    local ok = Bridge.Progress({
        duration = recipe.time or 4000,
        label    = ('Pripravuji: %s'):format(recipe.label),
        canCancel = true,
        anim = { dict = 'amb@prop_human_bbq@male@base', clip = 'base' },
    })
    if not ok then
        Bridge.Notify('Vyroba zrusena', 'error')
        return
    end

    local result = Bridge.Callback('vx_burgershot:craft', stationKey, recipe.result)
    if result == 'ok' then
        Bridge.Notify(('Vyrobeno: %s'):format(recipe.label), 'success')
    elseif result == 'missing' then
        Bridge.Notify('Nemas dostatek surovin', 'error')
    elseif result == 'nojob' then
        Bridge.Notify('Nemas na tohle opravneni', 'error')
    else
        Bridge.Notify('Vyroba selhala', 'error')
    end
end

local function openStation(stationKey)
    local station = Config.CraftStations[stationKey]
    if not station then return end
    Interactions.OpenRecipeMenu(station.label, station.recipes, function(recipe)
        craftRecipe(stationKey, recipe)
    end)
end

-- Registrace vsech crafting bodu
CreateThread(function()
    for _, point in ipairs(Config.Locations.crafting) do
        Interactions.Register(point, function()
            openStation(point.station)
        end)
    end
end)
