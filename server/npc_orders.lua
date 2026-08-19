-----------------------------------------------------------------------
--  NPC OBJEDNAVKY (server)
--  Vygeneruje objednavku, overi splneni, vyplati odmenu.
-----------------------------------------------------------------------

local activeOrders = {}   -- [src] = { orderId, items = {{item,label,amount}}, reward }
local lastOrderAt  = {}   -- [src] = os.time (cooldown)
local orderCounter = 0

local cfg = Config.NpcOrders

local function itemLabel(itemName)
    -- najdi label z receptu (kvuli hezkemu zobrazeni)
    for _, station in pairs(Config.CraftStations) do
        for _, r in ipairs(station.recipes) do
            if r.result == itemName then return r.label end
        end
    end
    for _, r in ipairs(Config.Drinks.recipes) do
        if r.result == itemName then return r.label end
    end
    return itemName
end

local function generateOrder()
    local pool = cfg.possibleItems
    local numItems = math.random(cfg.itemsPerOrder.min, cfg.itemsPerOrder.max)
    local chosen = {}
    local used = {}
    for _ = 1, numItems do
        local pick = pool[math.random(#pool)]
        if not used[pick] then
            used[pick] = true
            chosen[#chosen + 1] = {
                item   = pick,
                label  = itemLabel(pick),
                amount = math.random(cfg.countPerItem.min, cfg.countPerItem.max),
            }
        end
    end
    if #chosen == 0 then
        chosen[1] = { item = pool[1], label = itemLabel(pool[1]), amount = 1 }
    end
    return chosen
end

lib.callback.register('vx_burgershot:requestNpcOrder', function(source)
    local src = source
    if not cfg.enabled then return 'disabled' end
    if not Bridge.HasJob(src) then return 'nojob' end
    if activeOrders[src] then return 'busy' end

    -- jen kdyz je malo zamestnancu online
    if Bridge.CountJobPlayers() > cfg.maxJobPlayers then return 'toomany' end

    -- cooldown
    local now = os.time()
    if lastOrderAt[src] and (now - lastOrderAt[src]) < cfg.orderCooldown then
        return 'cooldown'
    end

    orderCounter = orderCounter + 1
    local order = {
        orderId = orderCounter,
        items   = generateOrder(),
        reward  = math.random(cfg.minReward, cfg.maxReward),
        created = now,
    }
    activeOrders[src] = order
    lastOrderAt[src] = now

    return {
        orderId = order.orderId,
        items   = order.items,
        reward  = order.reward,
    }
end)

lib.callback.register('vx_burgershot:deliverNpcOrder', function(source, orderId)
    local src   = source
    local order = activeOrders[src]
    if not order or order.orderId ~= orderId then return 'error' end

    -- casovy limit
    if cfg.timeLimit and cfg.timeLimit > 0 then
        if (os.time() - order.created) > cfg.timeLimit then
            activeOrders[src] = nil
            Bridge.Notify(src, 'Objednavka propadla (cas vyprsel)', 'error')
            return 'error'
        end
    end

    -- overeni, ze hrac ma vsechny polozky
    local ok = Bridge.HasItems(src, order.items)
    if not ok then return 'missing' end

    -- odeber vyrobene jidlo
    for _, it in ipairs(order.items) do
        if not Bridge.RemoveItem(src, it.item, it.amount) then
            return 'missing'
        end
    end

    -- vyplat odmenu (hraci + trochu firme)
    Bridge.AddMoney(src, 'cash', order.reward)
    Bridge.AddSociety(Config.Register.societyAccount, math.floor(order.reward * 0.25))

    activeOrders[src] = nil
    return 'ok'
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeOrders[src] = nil
    lastOrderAt[src]  = nil
end)
