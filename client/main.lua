-----------------------------------------------------------------------
--  MAIN (client) - blip, dodavatel surovin, bootstrap
-----------------------------------------------------------------------

-- BLIP restaurace ------------------------------------------------------
CreateThread(function()
    if not Config.Blip.enabled then return end
    local ref = Config.Locations.registers[1].coords
    local blip = AddBlipForCoord(ref.x, ref.y, ref.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
end)

-----------------------------------------------------------------------
-- DODAVATEL SUROVIN (NPC) - dojezd autem, nakup surovin
-----------------------------------------------------------------------
local function buySupplies()
    local options = {}
    for _, item in ipairs(Config.Supplies.items) do
        options[#options + 1] = {
            title       = item.label,
            description = ('Cena: $%s / ks'):format(item.price),
            image       = Interactions.ItemImage(item.name),
            icon        = 'fa-solid fa-box',
            onSelect = function()
                local input = lib.inputDialog(item.label, {
                    { type = 'number', label = 'Pocet', min = 1, max = Config.Supplies.maxPerBuy, default = 10, required = true },
                })
                if not input then return end
                local amount = math.floor(tonumber(input[1]) or 0)
                if amount <= 0 then return end
                local res = Bridge.Callback('vx_burgershot:buySupplies', item.name, amount)
                if res == 'ok' then
                    Bridge.Notify(('Koupeno %sx %s'):format(amount, item.label), 'success')
                elseif res == 'money' then
                    Bridge.Notify('Nemas dost penez', 'error')
                elseif res == 'nojob' then
                    Bridge.Notify('Nemas na tohle opravneni', 'error')
                else
                    Bridge.Notify('Nakup selhal', 'error')
                end
            end,
        }
    end
    lib.registerContext({
        id = 'vx_burgershot_supplies',
        title = 'Dodavatel surovin',
        options = options,
    })
    lib.showContext('vx_burgershot_supplies')
end

CreateThread(function()
    local s = Config.Locations.supplier

    -- ped
    local model = Utils.LoadModel(s.ped)
    if model then
        local ped = CreatePed(4, model, s.coords.x, s.coords.y, s.coords.z - 1.0, s.coords.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetModelAsNoLongerNeeded(model)

        -- interakce (target/text3d/textui) - vytvorime "point" ze supplier configu
        Interactions.Register({
            coords   = vector3(s.coords.x, s.coords.y, s.coords.z),
            interact = s.interact,
            label    = s.label,
            icon     = s.icon,
        }, buySupplies)
    end

    -- blip dodavatele
    if s.blip then
        local blip = AddBlipForCoord(s.coords.x, s.coords.y, s.coords.z)
        SetBlipSprite(blip, s.blip.sprite)
        SetBlipColour(blip, s.blip.color)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(s.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end)
