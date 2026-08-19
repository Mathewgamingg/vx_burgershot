-----------------------------------------------------------------------
--  CEPOVANI PITI (client)
--  Target / text3d / textui na napojovy automat -> menu s napoji.
-----------------------------------------------------------------------

local function pourDrink(recipe)
    local ok = Bridge.Progress({
        duration = recipe.time or 3000,
        label    = ('Cepuji: %s'):format(recipe.label),
        canCancel = true,
        anim = { dict = 'mp_arresting', clip = 'a_uncuff', flag = 49 },
    })
    if not ok then
        Bridge.Notify('Cepovani zruseno', 'error')
        return
    end

    local result = Bridge.Callback('vx_burgershot:craft', 'drinks', recipe.result)
    if result == 'ok' then
        Bridge.Notify(('Naliti: %s'):format(recipe.label), 'success')
    elseif result == 'missing' then
        Bridge.Notify('Chybi ti kelimek nebo sirup', 'error')
    elseif result == 'nojob' then
        Bridge.Notify('Nemas na tohle opravneni', 'error')
    else
        Bridge.Notify('Cepovani selhalo', 'error')
    end
end

local function openDrinks()
    Interactions.OpenRecipeMenu(Config.Drinks.label, Config.Drinks.recipes, pourDrink)
end

CreateThread(function()
    for _, point in ipairs(Config.Locations.drinks) do
        Interactions.Register(point, openDrinks)
    end
end)
