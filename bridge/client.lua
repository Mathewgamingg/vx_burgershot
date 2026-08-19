-----------------------------------------------------------------------
--  BRIDGE - CLIENT (multi-framework)
--
--  Job hrace si klient bere ze serveru (callback 'vx_burgershot:getJob'),
--  aby byl klient nezavisly na frameworku. Pri zmene jobu (FW event) si
--  job jen znovu vyzada. Notifikace se snazi pouzit FW/ox_lib, jinak nativni.
-----------------------------------------------------------------------

Bridge = {}

local playerData = { job = { name = 'unemployed', grade = 0 }, loaded = false }

-----------------------------------------------------------------------
-- NOTIFIKACE
-----------------------------------------------------------------------
function Bridge.Notify(msg, type, title)
    type = type or 'inform'
    if Config.UseOxLibNotify and lib and lib.notify then
        lib.notify({ title = title or 'Burger Shot', description = msg, type = type })
        return
    end
    -- framework fallbacky
    if GetResourceState('es_extended') == 'started' then
        TriggerEvent('esx:showNotification', msg)
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        local qbType = (type == 'inform') and 'primary' or type
        TriggerEvent('QBCore:Notify', msg, qbType)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(msg)
        DrawNotification(false, true)
    end
end

-----------------------------------------------------------------------
-- JOB
-----------------------------------------------------------------------
function Bridge.GetJob() return playerData.job end

function Bridge.HasJob()
    if not Config.RequireJob then return true end
    return playerData.job and playerData.job.name == Config.JobName
end

function Bridge.IsBoss()
    return playerData.job and playerData.job.name == Config.JobName
        and (playerData.job.grade or 0) >= Config.MinGradeBoss
end

local function refreshJob()
    if not (lib and lib.callback) then return end
    local job = lib.callback.await('vx_burgershot:getJob', false)
    if job then playerData.job = job end
    playerData.loaded = true
end

-- pocatecni nacteni
CreateThread(function()
    while not (lib and lib.callback) do Wait(100) end
    Wait(600) -- pockej az server detekuje framework
    refreshJob()
end)

-- server muze job pushnout primo
RegisterNetEvent('vx_burgershot:setJob', function(job)
    if job then playerData.job = job end
end)

-- Znovu-nacteni jobu pri FW udalostech (klient zustava agnosticky) ----
RegisterNetEvent('esx:playerLoaded',            function() refreshJob() end)
RegisterNetEvent('esx:setJob',                  function() refreshJob() end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded',function() refreshJob() end)
RegisterNetEvent('QBCore:Client:OnJobUpdate',   function() refreshJob() end)
RegisterNetEvent('qbx_core:client:playerLoaded',function() refreshJob() end)
RegisterNetEvent('ox:playerLoaded',             function() refreshJob() end)
RegisterNetEvent('ox:setGroup',                 function() refreshJob() end)
RegisterNetEvent('ox:setActiveGroup',           function() refreshJob() end)

-----------------------------------------------------------------------
-- SERVER CALLBACK helper (ox_lib)
-----------------------------------------------------------------------
function Bridge.Callback(name, ...)
    return lib.callback.await(name, false, ...)
end

-----------------------------------------------------------------------
-- PROGRESSBAR
-----------------------------------------------------------------------
function Bridge.Progress(data)
    if lib and lib.progressBar then
        return lib.progressBar({
            duration     = data.duration,
            label        = data.label,
            useWhileDead = false,
            canCancel    = data.canCancel ~= false,
            disable      = { car = true, move = true, combat = true },
            anim         = data.anim,
            prop         = data.prop,
        })
    else
        Wait(data.duration)
        return true
    end
end

return Bridge
