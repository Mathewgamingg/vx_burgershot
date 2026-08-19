-----------------------------------------------------------------------
--  MAIN (server) - job callback, nakup surovin
-----------------------------------------------------------------------

-- Klient si pri startu vyzada svuj job (STANDALONE).
-- Pri bridgi muzes bud nechat (Bridge.GetJob vraci FW job), nebo smazat.
lib.callback.register('vx_burgershot:getJob', function(source)
    return Bridge.GetJob(source)
end)

-- Rychly lookup cen surovin
local supplyPrices = {}
CreateThread(function()
    for _, item in ipairs(Config.Supplies.items) do
        supplyPrices[item.name] = item
    end
end)

lib.callback.register('vx_burgershot:buySupplies', function(source, itemName, amount)
    local src = source
    if not Bridge.HasJob(src) then return 'nojob' end

    local item = supplyPrices[itemName]
    if not item then return 'error' end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > Config.Supplies.maxPerBuy then return 'error' end

    local total = item.price * amount

    -- platba: nejdriv hotovost, pak banka
    if not Bridge.RemoveMoney(src, 'cash', total) then
        if not Bridge.RemoveMoney(src, 'bank', total) then
            return 'money'
        end
    end

    Bridge.AddItem(src, itemName, amount)
    return 'ok'
end)

-----------------------------------------------------------------------
-- (volitelne) prikaz pro vyber penez z firemniho uctu bossem
-----------------------------------------------------------------------
RegisterNetEvent('vx_burgershot:withdrawSociety', function(amount)
    local src = source
    if not Bridge.IsBoss(src) then
        Bridge.Notify(src, 'Nemas opravneni (jen boss)', 'error')
        return
    end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end
    if not Bridge.RemoveSociety(Config.Register.societyAccount, amount) then
        Bridge.Notify(src, 'Na firemnim ucte neni dost penez', 'error')
        return
    end
    Bridge.AddMoney(src, 'cash', amount)
    Bridge.Notify(src, ('Vybral jsi $%s z firemniho uctu'):format(amount), 'success')
end)
