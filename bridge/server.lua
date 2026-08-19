-----------------------------------------------------------------------
--  BRIDGE - SERVER
--
--  JEDINE misto k uprave pri napojeni frameworku na serverove strane.
--  Vsechny server soubory volaji jen funkce z tabulky `Bridge`.
--
--  STANDALONE rezim: penize a predmety jsou reseny "na oko" pres jednoduche
--  ulozene tabulky + event do klienta (aby to slo testovat bez frameworku).
--  Pri bridgi prepis vnitrky funkci na sve exporty (AddMoney, AddItem, ...).
-----------------------------------------------------------------------

Bridge = {}

-----------------------------------------------------------------------
-- STANDALONE fallback ulozice (jen aby to fungovalo bez FW).
-- POZOR: neni to persistentni! Slouzi jen k testovani.
-----------------------------------------------------------------------
local SA = {
    jobs    = {},  -- [src] = { name, grade }
    items   = {},  -- [src] = { [item] = count }
    society = {},  -- [account] = balance
}

local function saItems(src)
    SA.items[src] = SA.items[src] or {}
    return SA.items[src]
end

-----------------------------------------------------------------------
-- JOB
--   Pri bridgi: vrat realny job hrace z frameworku.
-----------------------------------------------------------------------
function Bridge.GetJob(src)
    -- STANDALONE: default job. Uprav si dle sveho whitelistu / DB.
    return SA.jobs[src] or { name = Config.JobName, grade = 4 }
    --[[ ESX:
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer and { name = xPlayer.job.name, grade = xPlayer.job.grade } or nil
    ]]
    --[[ QBCore:
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and { name = Player.PlayerData.job.name, grade = Player.PlayerData.job.grade.level } or nil
    ]]
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

-- Kolik zamestnancu s jobem je online (pro NPC objednavky)
function Bridge.CountJobPlayers()
    local count = 0
    for _, pid in ipairs(GetPlayers()) do
        local job = Bridge.GetJob(tonumber(pid))
        if job and job.name == Config.JobName then count = count + 1 end
    end
    return count
end

-----------------------------------------------------------------------
-- PENIZE
-----------------------------------------------------------------------
function Bridge.AddMoney(src, account, amount)
    amount = math.floor(amount)
    if amount <= 0 then return false end
    -- STANDALONE: jen posli notifikaci klientovi
    TriggerClientEvent('vx_burgershot:notify', src, ('Obdrzel jsi $%s'):format(amount), 'success')
    return true
    --[[ ESX:  ESX.GetPlayerFromId(src).addAccountMoney(account, amount) ]]
    --[[ QB:   QBCore.Functions.GetPlayer(src).Functions.AddMoney(account, amount) ]]
end

function Bridge.RemoveMoney(src, account, amount)
    amount = math.floor(amount)
    if amount <= 0 then return false end
    -- STANDALONE: vzdy true (nekontroluje zustatek). Pri bridgi kontroluj!
    return true
    --[[ ESX:
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.getAccount(account).money >= amount then
            xPlayer.removeAccountMoney(account, amount); return true
        end
        return false
    ]]
end

-----------------------------------------------------------------------
-- SOCIETY (firemni ucet)
-----------------------------------------------------------------------
function Bridge.AddSociety(account, amount)
    SA.society[account] = (SA.society[account] or 0) + math.floor(amount)
    --[[ ESX society / qb-management / renewed-banking - dle tveho bridge ]]
    return true
end

function Bridge.GetSociety(account)
    return SA.society[account] or 0
end

-----------------------------------------------------------------------
-- INVENTAR
-----------------------------------------------------------------------
function Bridge.GetItemCount(src, item)
    -- STANDALONE
    return saItems(src)[item] or 0
    --[[ ox_inventory: return exports.ox_inventory:GetItemCount(src, item) ]]
    --[[ ESX: local x=ESX.GetPlayerFromId(src); local i=x.getInventoryItem(item); return i and i.count or 0 ]]
end

function Bridge.AddItem(src, item, amount)
    amount = amount or 1
    -- STANDALONE
    local inv = saItems(src)
    inv[item] = (inv[item] or 0) + amount
    TriggerClientEvent('vx_burgershot:notify', src, ('+%sx %s'):format(amount, item), 'success')
    return true
    --[[ ox_inventory: return exports.ox_inventory:AddItem(src, item, amount) ]]
end

function Bridge.RemoveItem(src, item, amount)
    amount = amount or 1
    -- STANDALONE
    local inv = saItems(src)
    if (inv[item] or 0) < amount then return false end
    inv[item] = inv[item] - amount
    return true
    --[[ ox_inventory: return exports.ox_inventory:RemoveItem(src, item, amount) ]]
end

-- Ma hrac vsechny suroviny? (vraci true/false)
function Bridge.HasItems(src, list)
    for _, req in ipairs(list) do
        if Bridge.GetItemCount(src, req.item) < req.amount then
            return false, req.item
        end
    end
    return true
end

-----------------------------------------------------------------------
-- NOTIFIKACE (na server strane spustit klientskou notifikaci)
-----------------------------------------------------------------------
function Bridge.Notify(src, msg, type)
    TriggerClientEvent('vx_burgershot:notify', src, msg, type or 'inform')
end

return Bridge
