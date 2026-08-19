-----------------------------------------------------------------------
--  NPC OBJEDNAVKY (client)
--  Kdyz je malo hracu-zamestnancu online, muze si hrac vzit objednavku
--  pro NPC zakaznika. Vyrobi jidlo -> preda NPC -> dostane odmenu.
-----------------------------------------------------------------------

local activeOrder = nil      -- { orderId, items, reward }
local customerPed = nil

local customerModels = {
    'a_m_y_business_01', 'a_f_y_business_02', 'a_m_m_business_01',
    'a_f_y_hipster_01', 'a_m_y_hipster_01', 'a_f_m_business_02',
}

local function cleanupCustomer()
    if customerPed and DoesEntityExist(customerPed) then
        local ped = customerPed
        CreateThread(function()
            local dict = 'move_m@confident'
            TaskWanderStandard(ped, 10.0, 10)
            Wait(8000)
            if DoesEntityExist(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                DeleteEntity(ped)
            end
        end)
    end
    customerPed = nil
    activeOrder = nil
end

local function spawnCustomer()
    local points = Config.Locations.npcDeliveryPoints
    local pt = points[math.random(#points)]
    local model = Utils.LoadModel(customerModels[math.random(#customerModels)])
    if not model then return end
    local ped = CreatePed(4, model, pt.x, pt.y, pt.z - 1.0, pt.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(model)
    customerPed = ped

    -- popisek nad NPC + target na predani
    if GetResourceState('ox_target') == 'started' and Config.Interaction.target then
        exports.ox_target:addLocalEntity(ped, {
            {
                name  = 'vx_bs_deliver',
                label = 'Predat objednavku',
                icon  = 'fa-solid fa-bag-shopping',
                distance = 2.0,
                onSelect = function() deliverOrder() end,
            },
        })
    end
    return ped
end

function deliverOrder()
    if not activeOrder then return end
    local ok = Bridge.Progress({
        duration = 2500,
        label    = 'Predavam objednavku...',
        canCancel = true,
    })
    if not ok then return end

    local result = Bridge.Callback('vx_burgershot:deliverNpcOrder', activeOrder.orderId)
    if result == 'ok' then
        Bridge.Notify(('Objednavka predana! Odmena: $%s'):format(activeOrder.reward), 'success')
        if customerPed and DoesEntityExist(customerPed) then
            FreezeEntityPosition(customerPed, false)
            if GetResourceState('ox_target') == 'started' then
                exports.ox_target:removeLocalEntity(customerPed, 'vx_bs_deliver')
            end
        end
        cleanupCustomer()
    elseif result == 'missing' then
        Bridge.Notify('Nemas vyrobene vsechny polozky objednavky', 'error')
    else
        Bridge.Notify('Predani selhalo', 'error')
    end
end

local function showOrderDetails()
    if not activeOrder then return end
    local lines = {}
    for _, it in ipairs(activeOrder.items) do
        lines[#lines + 1] = ('%sx %s'):format(it.amount, it.label or it.item)
    end
    lib.alertDialog({
        header  = 'Aktivni objednavka',
        content = ('Zakaznik chce:\n%s\n\nOdmena: $%s\nPredej u zakaznika, ktery ceka.'):format(
            table.concat(lines, '\n'), activeOrder.reward),
        centered = true,
    })
end

local function requestOrder()
    if activeOrder then
        showOrderDetails()
        return
    end
    local result = Bridge.Callback('vx_burgershot:requestNpcOrder')
    if type(result) == 'table' then
        activeOrder = result
        spawnCustomer()
        Bridge.Notify('Nova objednavka! Vyrob jidlo a predej zakaznikovi.', 'success')
        showOrderDetails()
    elseif result == 'busy' then
        Bridge.Notify('Uz mas aktivni objednavku', 'error')
    elseif result == 'toomany' then
        Bridge.Notify('Je online moc zamestnancu - obsluhuj hrace', 'inform')
    elseif result == 'cooldown' then
        Bridge.Notify('Chvili pockej nez si vezmes dalsi objednavku', 'error')
    elseif result == 'disabled' then
        Bridge.Notify('NPC objednavky jsou vypnute', 'error')
    else
        Bridge.Notify('Nepodarilo se ziskat objednavku', 'error')
    end
end

CreateThread(function()
    if not Config.NpcOrders.enabled then return end
    Interactions.Register(Config.Locations.npcOrderDesk, requestOrder)
end)

-- uklid pri stopu resource
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if customerPed and DoesEntityExist(customerPed) then DeleteEntity(customerPed) end
end)
