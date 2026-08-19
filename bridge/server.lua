-----------------------------------------------------------------------
--  BRIDGE - SERVER (multi-framework)
--
--  Auto-detekce: ESX / QBCore / Qbox / ox_core (+ ox_inventory).
--  Vsechny serverove soubory volaji jen funkce z tabulky `Bridge`.
--  Framework-specificka logika je JEN tady.
--
--  Vynutit framework/inventar lze v config/config.lua (Config.Framework, Config.Inventory).
-----------------------------------------------------------------------

Bridge = {}

local FW          = nil     -- 'esx' | 'qb' | 'qbx' | 'ox' | 'standalone'
local USE_OX_INV  = false
local ESX, QBCore, Qbox, Ox

-- interni (nepersistentni) fallback pro standalone / chybejici society
local SA = { items = {}, society = {} }
local function saItems(src) SA.items[src] = SA.items[src] or {}; return SA.items[src] end

-----------------------------------------------------------------------
-- DETEKCE FRAMEWORKU
-----------------------------------------------------------------------
local function detectFramework()
    local forced = Config.Framework
    if forced and forced ~= 'auto' then
        FW = forced
    elseif GetResourceState('es_extended') == 'started' then
        FW = 'esx'
    elseif GetResourceState('qbx_core') == 'started' then
        FW = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        FW = 'qb'
    elseif GetResourceState('ox_core') == 'started' then
        FW = 'ox'
    else
        FW = 'standalone'
    end

    if FW == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif FW == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif FW == 'qbx' then
        Qbox = exports.qbx_core
        -- Qbox si drzi QBCore-kompatibilni core take (pro jistotu)
        if GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
        end
    elseif FW == 'ox' then
        Ox = exports.ox_core
    end

    -- inventar
    local inv = Config.Inventory or 'auto'
    if inv == 'ox' then
        USE_OX_INV = true
    elseif inv == 'native' then
        USE_OX_INV = false
    else -- auto
        USE_OX_INV = GetResourceState('ox_inventory') == 'started'
    end
    -- Qbox a ox_core prakticky vzdy jedou na ox_inventory
    if (FW == 'qbx' or FW == 'ox') and GetResourceState('ox_inventory') == 'started' then
        USE_OX_INV = true
    end

    print(('[vx_burgershot] Framework: %s | ox_inventory: %s'):format(FW, tostring(USE_OX_INV)))
end

CreateThread(function()
    Wait(500) -- pockej az nabehnou ostatni resource
    detectFramework()
end)

function Bridge.GetFramework() return FW end

-----------------------------------------------------------------------
-- INTERNI HELPERY PRO ZISKANI PLAYER OBJEKTU
-----------------------------------------------------------------------
local function esxPlayer(src) return ESX and ESX.GetPlayerFromId(src) or nil end
local function qbPlayer(src)  return QBCore and QBCore.Functions.GetPlayer(src) or nil end
local function qbxPlayer(src) return Qbox and Qbox:GetPlayer(src) or nil end
local function oxPlayer(src)  return Ox and exports.ox_core:GetPlayer(src) or nil end

-- mapovani nazvu uctu (my pouzivame 'cash' / 'bank')
local function esxAccount(acc) return acc == 'cash' and 'money' or acc end

-----------------------------------------------------------------------
-- JOB
-----------------------------------------------------------------------
function Bridge.GetJob(src)
    if FW == 'esx' then
        local xP = esxPlayer(src)
        if xP and xP.job then return { name = xP.job.name, grade = xP.job.grade } end
    elseif FW == 'qb' then
        local P = qbPlayer(src)
        if P then return { name = P.PlayerData.job.name, grade = P.PlayerData.job.grade.level } end
    elseif FW == 'qbx' then
        local P = qbxPlayer(src)
        if P then return { name = P.PlayerData.job.name, grade = P.PlayerData.job.grade.level } end
    elseif FW == 'ox' then
        local P = oxPlayer(src)
        if P then
            local grade
            -- ox_core: getGroup(name) vraci grade dane skupiny (nebo nil)
            local ok, res = pcall(function() return P.getGroup and P.getGroup(Config.JobName) end)
            if ok and type(res) == 'number' then grade = res end
            if grade == nil then
                ok, res = pcall(function() return P.hasGroup and P.hasGroup(Config.JobName) end)
                if ok and type(res) == 'number' then grade = res end
            end
            if grade then return { name = Config.JobName, grade = grade } end
            return { name = 'unemployed', grade = 0 }
        end
    end
    -- standalone fallback (uprav dle sveho whitelistu / DB)
    return { name = Config.JobName, grade = 4 }
end

function Bridge.HasJob(src)
    if not Config.RequireJob then return true end
    local job = Bridge.GetJob(src)
    return job and job.name == Config.JobName
end

function Bridge.IsBoss(src)
    local job = Bridge.GetJob(src)
    return job and job.name == Config.JobName and (job.grade or 0) >= Config.MinGradeBoss
end

function Bridge.CountJobPlayers()
    local count = 0
    for _, pid in ipairs(GetPlayers()) do
        local job = Bridge.GetJob(tonumber(pid))
        if job and job.name == Config.JobName then count = count + 1 end
    end
    return count
end

-----------------------------------------------------------------------
-- PENIZE (cash / bank)
-----------------------------------------------------------------------
function Bridge.AddMoney(src, account, amount)
    amount = math.floor(amount)
    if amount <= 0 then return false end

    if FW == 'esx' then
        local xP = esxPlayer(src); if not xP then return false end
        xP.addAccountMoney(esxAccount(account), amount)
        return true
    elseif FW == 'qb' or FW == 'qbx' then
        local P = (FW == 'qbx') and qbxPlayer(src) or qbPlayer(src)
        if not P then return false end
        P.Functions.AddMoney(account, amount, 'burgershot')
        return true
    elseif FW == 'ox' then
        -- cash i bank pres ox_inventory 'money' (pripadne ox_banking pro bank)
        if account == 'bank' and GetResourceState('ox_banking') == 'started' then
            local ok = pcall(function() exports.ox_banking:addAccountBalance(src, amount) end)
            if ok then return true end
        end
        if GetResourceState('ox_inventory') == 'started' then
            return exports.ox_inventory:AddItem(src, 'money', amount)
        end
        return false
    end

    -- standalone
    TriggerClientEvent('vx_burgershot:notify', src, ('Obdrzel jsi $%s'):format(amount), 'success')
    return true
end

function Bridge.RemoveMoney(src, account, amount)
    amount = math.floor(amount)
    if amount <= 0 then return false end

    if FW == 'esx' then
        local xP = esxPlayer(src); if not xP then return false end
        local acc = xP.getAccount(esxAccount(account))
        if acc and acc.money >= amount then
            xP.removeAccountMoney(esxAccount(account), amount)
            return true
        end
        return false
    elseif FW == 'qb' or FW == 'qbx' then
        local P = (FW == 'qbx') and qbxPlayer(src) or qbPlayer(src)
        if not P then return false end
        return P.Functions.RemoveMoney(account, amount, 'burgershot') and true or false
    elseif FW == 'ox' then
        if GetResourceState('ox_inventory') == 'started' then
            local has = exports.ox_inventory:GetItemCount(src, 'money')
            if has >= amount then
                return exports.ox_inventory:RemoveItem(src, 'money', amount)
            end
        end
        return false
    end

    -- standalone (nekontroluje zustatek)
    return true
end

-----------------------------------------------------------------------
-- SOCIETY (firemni ucet) - best-effort dle frameworku
-----------------------------------------------------------------------
function Bridge.AddSociety(account, amount)
    amount = math.floor(amount)
    if amount == 0 then return true end

    if FW == 'esx' and GetResourceState('esx_addonaccount') == 'started' then
        local ok = false
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(acc)
            if acc then acc.addMoney(amount); ok = true end
        end)
        if ok then return true end
    elseif (FW == 'qb' or FW == 'qbx') then
        if GetResourceState('qb-banking') == 'started' then
            local ok = pcall(function() exports['qb-banking']:AddMoney(account, amount, 'burgershot') end)
            if ok then return true end
        elseif GetResourceState('Renewed-Banking') == 'started' then
            local ok = pcall(function() exports['Renewed-Banking']:addAccountMoney(account, amount) end)
            if ok then return true end
        elseif GetResourceState('qb-management') == 'started' then
            local ok = pcall(function() exports['qb-management']:AddMoney(account, amount) end)
            if ok then return true end
        end
    elseif FW == 'ox' and GetResourceState('ox_banking') == 'started' then
        local ok = pcall(function() exports.ox_banking:addAccountBalance(account, amount) end)
        if ok then return true end
    end

    -- fallback interni
    SA.society[account] = (SA.society[account] or 0) + amount
    return true
end

function Bridge.GetSociety(account)
    if FW == 'esx' and GetResourceState('esx_addonaccount') == 'started' then
        local bal = nil
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(acc)
            if acc then bal = acc.money end
        end)
        if bal then return bal end
    elseif (FW == 'qb' or FW == 'qbx') and GetResourceState('qb-banking') == 'started' then
        local bal
        pcall(function() bal = exports['qb-banking']:GetAccountBalance(account) end)
        if bal then return bal end
    end
    return SA.society[account] or 0
end

function Bridge.RemoveSociety(account, amount)
    amount = math.floor(amount)
    if amount <= 0 then return false end
    if Bridge.GetSociety(account) < amount then return false end

    if FW == 'esx' and GetResourceState('esx_addonaccount') == 'started' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(acc)
            if acc then acc.removeMoney(amount) end
        end)
        return true
    elseif (FW == 'qb' or FW == 'qbx') and GetResourceState('qb-banking') == 'started' then
        local ok = pcall(function() exports['qb-banking']:RemoveMoney(account, amount, 'burgershot') end)
        if ok then return true end
    elseif FW == 'ox' and GetResourceState('ox_banking') == 'started' then
        local ok = pcall(function() exports.ox_banking:removeAccountBalance(account, amount) end)
        if ok then return true end
    end

    SA.society[account] = (SA.society[account] or 0) - amount
    return true
end

-----------------------------------------------------------------------
-- INVENTAR
-----------------------------------------------------------------------
function Bridge.GetItemCount(src, item)
    if USE_OX_INV then
        return exports.ox_inventory:GetItemCount(src, item) or 0
    end
    if FW == 'esx' then
        local xP = esxPlayer(src); if not xP then return 0 end
        local it = xP.getInventoryItem(item)
        return it and it.count or 0
    elseif FW == 'qb' or FW == 'qbx' then
        local P = (FW == 'qbx') and qbxPlayer(src) or qbPlayer(src)
        if not P then return 0 end
        local it = P.Functions.GetItemByName(item)
        return it and it.amount or 0
    end
    -- standalone
    return saItems(src)[item] or 0
end

function Bridge.AddItem(src, item, amount)
    amount = amount or 1
    if USE_OX_INV then
        return exports.ox_inventory:AddItem(src, item, amount) and true or false
    end
    if FW == 'esx' then
        local xP = esxPlayer(src); if not xP then return false end
        xP.addInventoryItem(item, amount); return true
    elseif FW == 'qb' or FW == 'qbx' then
        local P = (FW == 'qbx') and qbxPlayer(src) or qbPlayer(src)
        if not P then return false end
        return P.Functions.AddItem(item, amount) and true or false
    end
    -- standalone
    local inv = saItems(src); inv[item] = (inv[item] or 0) + amount
    TriggerClientEvent('vx_burgershot:notify', src, ('+%sx %s'):format(amount, item), 'success')
    return true
end

function Bridge.RemoveItem(src, item, amount)
    amount = amount or 1
    if USE_OX_INV then
        return exports.ox_inventory:RemoveItem(src, item, amount) and true or false
    end
    if FW == 'esx' then
        local xP = esxPlayer(src); if not xP then return false end
        local it = xP.getInventoryItem(item)
        if not it or it.count < amount then return false end
        xP.removeInventoryItem(item, amount); return true
    elseif FW == 'qb' or FW == 'qbx' then
        local P = (FW == 'qbx') and qbxPlayer(src) or qbPlayer(src)
        if not P then return false end
        return P.Functions.RemoveItem(item, amount) and true or false
    end
    -- standalone
    local inv = saItems(src)
    if (inv[item] or 0) < amount then return false end
    inv[item] = inv[item] - amount; return true
end

function Bridge.HasItems(src, list)
    for _, req in ipairs(list) do
        if Bridge.GetItemCount(src, req.item) < req.amount then
            return false, req.item
        end
    end
    return true
end

-----------------------------------------------------------------------
-- NOTIFIKACE
-----------------------------------------------------------------------
function Bridge.Notify(src, msg, type)
    TriggerClientEvent('vx_burgershot:notify', src, msg, type or 'inform')
end

return Bridge
