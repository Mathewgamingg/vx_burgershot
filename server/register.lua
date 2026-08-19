-----------------------------------------------------------------------
--  POKLADNA / UCTENKY (server)
--  Zamestnanec vytvori uctenku -> zakaznikovi prijde -> zaplati/odmitne.
-----------------------------------------------------------------------

local pendingBills = {}   -- [billId] = { seller, target, amount, description }
local billCounter  = 0

local function getPlayerName(src)
    local name = GetPlayerName(src) or 'Zamestnanec'
    return name
end

RegisterNetEvent('vx_burgershot:createBill', function(target, amount, description)
    local src = source
    target = tonumber(target)
    amount = math.floor(tonumber(amount) or 0)

    if not Bridge.HasJob(src) then
        Bridge.Notify(src, 'Nemas opravneni pouzivat pokladnu', 'error')
        return
    end
    if amount <= 0 or amount > Config.Register.maxBillAmount then
        Bridge.Notify(src, 'Neplatna castka', 'error')
        return
    end
    if not target or target == src then
        Bridge.Notify(src, 'Neplatny zakaznik', 'error')
        return
    end
    -- overeni ze target je opravdu online a blizko
    local sped = GetPlayerPed(src)
    local tped = GetPlayerPed(target)
    if tped == 0 then
        Bridge.Notify(src, 'Zakaznik neni dostupny', 'error')
        return
    end
    local dist = #(GetEntityCoords(sped) - GetEntityCoords(tped))
    if dist > 6.0 then
        Bridge.Notify(src, 'Zakaznik je moc daleko', 'error')
        return
    end

    billCounter = billCounter + 1
    local billId = billCounter
    pendingBills[billId] = {
        seller      = src,
        target      = target,
        amount      = amount,
        description = description or 'Objednavka',
    }

    TriggerClientEvent('vx_burgershot:receiveBill', target, {
        billId      = billId,
        amount      = amount,
        description = description or 'Objednavka',
        seller      = getPlayerName(src),
    })
end)

RegisterNetEvent('vx_burgershot:payBill', function(billId, method)
    local src  = source
    local bill = pendingBills[billId]
    if not bill or bill.target ~= src then return end

    method = (method == 'bank') and 'bank' or 'cash'
    local paid = Bridge.RemoveMoney(src, method, bill.amount)
    if not paid then
        -- zkus druhy ucet
        local alt = (method == 'cash') and 'bank' or 'cash'
        paid = Bridge.RemoveMoney(src, alt, bill.amount)
    end

    if not paid then
        Bridge.Notify(src, 'Nemas dostatek penez', 'error')
        Bridge.Notify(bill.seller, 'Zakaznik nema dost penez', 'error')
        return
    end

    -- penize firme (a pripadne cast prodejci)
    local societyAmount = math.floor(bill.amount * Config.Register.societyCut)
    Bridge.AddSociety(Config.Register.societyAccount, societyAmount)
    local tip = bill.amount - societyAmount
    if tip > 0 then
        Bridge.AddMoney(bill.seller, 'cash', tip)
    end

    Bridge.Notify(src, ('Zaplatil jsi $%s'):format(bill.amount), 'success')
    Bridge.Notify(bill.seller, ('Zakaznik zaplatil $%s'):format(bill.amount), 'success')
    pendingBills[billId] = nil
end)

RegisterNetEvent('vx_burgershot:declineBill', function(billId)
    local src  = source
    local bill = pendingBills[billId]
    if not bill or bill.target ~= src then return end
    Bridge.Notify(bill.seller, 'Zakaznik odmitl zaplatit', 'error')
    pendingBills[billId] = nil
end)

-- uklid uctenek pri odchodu hrace
AddEventHandler('playerDropped', function()
    local src = source
    for id, bill in pairs(pendingBills) do
        if bill.target == src or bill.seller == src then
            pendingBills[id] = nil
        end
    end
end)
