-----------------------------------------------------------------------
--  CLIENT UTILS - pomocne funkce
-----------------------------------------------------------------------

Utils = {}

-- Vykresli 3D text ve svete
function Utils.DrawText3D(coords, text, scale)
    scale = scale or 0.35
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(x, y)
    -- lehke pozadi
    local factor = (#text) / 370
    DrawRect(x, y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
end

-- Notifikace ze serveru
RegisterNetEvent('vx_burgershot:notify', function(msg, type)
    Bridge.Notify(msg, type)
end)

-- Bezpecne nacteni modelu
function Utils.LoadModel(model)
    if type(model) == 'string' then model = joaat(model) end
    if not IsModelValid(model) then return nil end
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50); timeout = timeout + 1
    end
    return model
end

-- Nacteni animacniho slovniku
function Utils.LoadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 100 do
        Wait(50); timeout = timeout + 1
    end
end
