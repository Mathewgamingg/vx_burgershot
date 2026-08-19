-----------------------------------------------------------------------
--  POKLADNA / UCTENKY (client)
--  Zamestnanec zada castku -> nejblizsimu hraci prijde uctenka -> zaplati.
-----------------------------------------------------------------------

-- Najdi nejblizsiho hrace (do 4m)
local function getClosestPlayer(maxDist)
    maxDist = maxDist or 4.0
    local ped     = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local closest, closestDist = nil, maxDist
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local target = GetPlayerPed(pid)
            local dist   = #(pcoords - GetEntityCoords(target))
            if dist < closestDist then
                closestDist = dist
                closest     = GetPlayerServerId(pid)
            end
        end
    end
    return closest
end

local function openRegister()
    local target = getClosestPlayer(4.0)
    if not target then
        Bridge.Notify('Zadny zakaznik poblizu', 'error')
        return
    end

    local input = lib.inputDialog('Pokladna - uctenka', {
        { type = 'number', label = 'Castka ($)', icon = 'dollar-sign', required = true, min = 1, max = Config.Register.maxBillAmount },
        { type = 'input',  label = 'Za co (nepovinne)', icon = 'burger', max = 40 },
    })
    if not input then return end

    local amount = math.floor(tonumber(input[1]) or 0)
    if amount <= 0 then
        Bridge.Notify('Neplatna castka', 'error')
        return
    end

    TriggerServerEvent('vx_burgershot:createBill', target, amount, input[2] or 'Objednavka')
    Bridge.Notify('Uctenka odeslana zakaznikovi', 'inform')
end

-- Zakaznikovi prijde uctenka
RegisterNetEvent('vx_burgershot:receiveBill', function(data)
    local desc = ('%s\nCastka: $%s\nProdejce: %s'):format(data.description or 'Objednavka', data.amount, data.seller or 'Burger Shot')
    local alert = lib.alertDialog({
        header  = 'Burger Shot - uctenka',
        content = desc,
        centered = true,
        cancel  = true,
        labels  = { confirm = 'Zaplatit', cancel = 'Odmitnout' },
    })
    if alert == 'confirm' then
        TriggerServerEvent('vx_burgershot:payBill', data.billId, 'cash')
    else
        TriggerServerEvent('vx_burgershot:declineBill', data.billId)
    end
end)

CreateThread(function()
    for _, point in ipairs(Config.Locations.registers) do
        Interactions.Register(point, openRegister)
    end
end)
