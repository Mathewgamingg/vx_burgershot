-----------------------------------------------------------------------
--  INTERAKCNI SYSTEM - 3 metody v jednom
--
--    'target'  -> ox_target (koukni na bod / najedes strdem obrazovky)
--    'text3d'  -> 3D text ve svete, objevi se az kdyz jsi blizko,
--                 nad nim je klavesa (napr. [E]) kterou to otevres
--    'textui'  -> ox_lib textUI panel v rohu, take jen kdyz jsi blizko
--
--  Kazdy bod si v locations.lua vybere, ktere metody chce (klidne vic naraz).
--  Vola se: Interactions.Register(point, onSelect)
--     point   = zaznam z Config.Locations (coords, heading, interact, label, icon)
--     onSelect= funkce co se spusti pri interakci
-----------------------------------------------------------------------

Interactions = {}

local proximityPoints = {}   -- body co potrebuji text3d nebo textui
local currentTextUI = nil    -- ktery textui je prave zobrazeny

-- Prijima interact jako STRING ('target' | 'textui' | '3dtext')
-- nebo (zpetne) jako tabulku vice hodnot. Vraci set { target=true, ... }.
local function normalizeMethods(interact)
    local out = {}
    local function add(m)
        m = tostring(m):lower()
        if m == '3dtext' or m == '3d' then m = 'text3d' end
        out[m] = true
    end
    if type(interact) == 'string' then
        add(interact)
    elseif type(interact) == 'table' then
        for _, m in ipairs(interact) do add(m) end
    else
        add('target')
    end
    return out
end

-----------------------------------------------------------------------
-- Registrace bodu
-----------------------------------------------------------------------
function Interactions.Register(point, onSelect)
    local methods = normalizeMethods(point.interact)

    -- TARGET (ox_target) --------------------------------------------
    if methods.target and Config.Interaction.target and GetResourceState('ox_target') == 'started' then
        exports.ox_target:addSphereZone({
            coords = point.coords,
            radius = 1.2,
            debug  = Config.Debug,
            options = {
                {
                    name     = ('vx_bs_%s'):format(math.random(100000, 999999)),
                    label    = point.label,
                    icon     = point.icon or 'fa-solid fa-hand',
                    distance = 2.0,
                    canInteract = function()
                        return Bridge.HasJob() or point.public == true
                    end,
                    onSelect = function() onSelect() end,
                },
            },
        })
    end

    -- TEXT3D / TEXTUI (proximity) -----------------------------------
    local wantsText3d = methods.text3d and Config.Interaction.text3d
    local wantsTextUI = methods.textui and Config.Interaction.textui
    if wantsText3d or wantsTextUI then
        proximityPoints[#proximityPoints + 1] = {
            coords   = point.coords,
            label    = point.label,
            key      = Config.Interaction.keyLabel,
            text3d   = wantsText3d,
            textui   = wantsTextUI,
            public   = point.public,
            onSelect = onSelect,
        }
    end
end

-----------------------------------------------------------------------
-- Hlavni proximity smycka (jedna pro vsechny body = vykon)
-----------------------------------------------------------------------
CreateThread(function()
    local drawDist     = Config.Interaction.drawDistance
    local interactDist = Config.Interaction.interactDistance
    local key          = Config.Interaction.key

    while true do
        local sleep = 500
        if #proximityPoints > 0 then
            local ped    = PlayerPedId()
            local pcoords = GetEntityCoords(ped)
            local nearestUI, nearestUIDist = nil, drawDist
            local anyClose = false

            for _, p in ipairs(proximityPoints) do
                local dist = #(pcoords - p.coords)
                if dist <= drawDist then
                    anyClose = true
                    local canUse = Bridge.HasJob() or p.public == true

                    -- 3D text (kresli kazdy frame kdyz blizko)
                    if p.text3d and canUse then
                        Utils.DrawText3D(
                            vector3(p.coords.x, p.coords.y, p.coords.z + 1.0),
                            ('[%s] %s'):format(p.key, p.label)
                        )
                    end

                    -- vyber nejblizsi textui bod
                    if p.textui and canUse and dist < nearestUIDist then
                        nearestUIDist = dist
                        nearestUI     = p
                    end

                    -- interakce klavesou (pro text3d i textui)
                    if canUse and dist <= interactDist and (p.text3d or p.textui) then
                        if IsControlJustReleased(0, key) then
                            p.onSelect()
                        end
                    end
                end
            end

            -- zobraz/skryj vlastni (custom) textUI panel - jen jeden, nejblizsi
            if nearestUI then
                if currentTextUI ~= nearestUI then
                    currentTextUI = nearestUI
                    TextUI.Show(nearestUI.label, nearestUI.key)
                end
            elseif currentTextUI then
                currentTextUI = nil
                TextUI.Hide()
            end

            sleep = anyClose and 0 or 400
        end
        Wait(sleep)
    end
end)

-----------------------------------------------------------------------
-- Pomocny univerzalni "crafting" vyber s obrazky (ox_lib menu)
--   recipes = seznam receptu (viz recipes.lua)
--   onCraft(recipe) = callback po vyberu
-----------------------------------------------------------------------
-- Obrazek itemu: bud z ox_inventory (web/images/<item>.png) nebo z html/images.
--   itemName  = nazev predmetu (klic obrazku v ox_inventory)
--   localFile = nazev souboru v html/images (nepovinne)
function Interactions.ItemImage(itemName, localFile)
    local cfg      = Config.Images or {}
    local oxImg    = ('nui://%s/web/images/%s.png'):format(cfg.oxResource or 'ox_inventory', itemName)
    local localImg = localFile and ('nui://vx_burgershot/html/images/%s'):format(localFile) or nil

    if (cfg.source or 'local') == 'ox_inventory' then
        return oxImg
    end
    if localImg then return localImg end
    if cfg.fallbackToLocal then return oxImg end
    return nil
end

-- Resolver obrazku pro recept (pouziva vysledny item + pripadny recipe.image)
local function resolveImage(recipe)
    return Interactions.ItemImage(recipe.result, recipe.image)
end

function Interactions.OpenRecipeMenu(title, recipes, onCraft)
    local options = {}
    for i, r in ipairs(recipes) do
        -- sestav popis surovin
        local reqLines = {}
        for _, req in ipairs(r.requires or {}) do
            reqLines[#reqLines + 1] = ('%sx %s'):format(req.amount, req.item)
        end
        options[#options + 1] = {
            title       = r.label,
            description = ('Potreba: %s'):format(#reqLines > 0 and table.concat(reqLines, ', ') or 'nic'),
            image       = resolveImage(r),
            icon        = 'fa-solid fa-utensils',
            onSelect    = function() onCraft(r) end,
        }
    end

    lib.registerContext({
        id      = 'vx_burgershot_recipes',
        title   = title,
        options = options,
    })
    lib.showContext('vx_burgershot_recipes')
end
