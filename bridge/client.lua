-----------------------------------------------------------------------
--  BRIDGE - CLIENT
--
--  Toto je JEDINE misto, ktere musis upravit az napojis svuj framework
--  (ESX / QBCore / Qbox / vlastni bridge).
--
--  Vsechny ostatni soubory volaji pouze funkce z tabulky `Bridge`.
--  Ted je to STANDALONE - funguje samo, ale job/penize jsou jen simulovane
--  pres server callbacky. Az budes mit bridge, prepis vnitrek techto funkci.
-----------------------------------------------------------------------

Bridge = {}

-- Lokalni cache dat hrace (job apod.)
local playerData = {
    job = { name = 'unemployed', grade = 0 },
    loaded = false,
}

-----------------------------------------------------------------------
-- NOTIFIKACE
-----------------------------------------------------------------------
function Bridge.Notify(msg, type, title)
    type = type or 'inform'
    if Config.UseOxLibNotify and lib and lib.notify then
        lib.notify({ title = title or 'Burger Shot', description = msg, type = type })
    else
        -- nativni fallback
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(msg)
        DrawNotification(false, true)
    end
end

-----------------------------------------------------------------------
-- JOB / DATA HRACE
--   -> Pri bridgi tady vrat realny job z frameworku.
-----------------------------------------------------------------------
function Bridge.GetJob()
    return playerData.job
end

function Bridge.HasJob()
    if not Config.RequireJob then return true end
    return playerData.job and playerData.job.name == Config.JobName
end

function Bridge.IsBoss()
    return playerData.job and playerData.job.name == Config.JobName
        and (playerData.job.grade or 0) >= Config.MinGradeBoss
end

-- STANDALONE: job si natahneme ze serveru (server rozhodne dle DB/whitelistu).
-- Pri bridgi tuhle cast smaz a napln playerData z frameworku (napr. ESX event).
CreateThread(function()
    while not (lib and lib.callback) do Wait(100) end
    local job = lib.callback.await('vx_burgershot:getJob', false)
    if job then playerData.job = job end
    playerData.loaded = true
end)

-- Umoznuje serveru pushnout aktualizaci jobu (napr. po povyseni)
RegisterNetEvent('vx_burgershot:setJob', function(job)
    if job then playerData.job = job end
end)

--[[  PRIKLAD NAPOJENI NA ESX:
    ESX = exports['es_extended']:getSharedObject()
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        playerData.job = xPlayer.job
    end)
    RegisterNetEvent('esx:setJob', function(job)
        playerData.job = job
    end)
    function Bridge.GetJob() return ESX.GetPlayerData().job end
--]]

--[[  PRIKLAD NAPOJENI NA QBCore:
    QBCore = exports['qb-core']:GetCoreObject()
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        playerData.job = { name = job.name, grade = job.grade.level }
    end)
--]]

-----------------------------------------------------------------------
-- SERVER CALLBACK helper (pres ox_lib)
-----------------------------------------------------------------------
function Bridge.Callback(name, ...)
    return lib.callback.await(name, false, ...)
end

-----------------------------------------------------------------------
-- PROGRESSBAR (vyroba jidla apod.)
-----------------------------------------------------------------------
function Bridge.Progress(data)
    -- data: { label, duration, anim, prop, canCancel }
    if lib and lib.progressBar then
        return lib.progressBar({
            duration    = data.duration,
            label       = data.label,
            useWhileDead = false,
            canCancel   = data.canCancel ~= false,
            disable     = { car = true, move = true, combat = true },
            anim        = data.anim,
            prop        = data.prop,
        })
    else
        Wait(data.duration)
        return true
    end
end

return Bridge
