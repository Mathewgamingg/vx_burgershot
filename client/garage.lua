-----------------------------------------------------------------------
--  GARAZ (client)
--  Vyndani firemniho vozidla + vraceni. Auto slouzi k dojezdu pro suroviny.
-----------------------------------------------------------------------

local spawnedVehicle = nil

local function storeVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        -- zkus nejblizsi vozidlo
        veh = spawnedVehicle
    end
    if veh and DoesEntityExist(veh) then
        if Config.Garage.deleteOnStore then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
        end
        spawnedVehicle = nil
        Bridge.Notify('Vozidlo uklizeno do garaze', 'success')
    else
        Bridge.Notify('Zadne firemni vozidlo k ulozeni', 'error')
    end
end

local function spawnVehicle(modelName, label)
    local spawn = Config.Locations.garage.spawn.coords
    -- kontrola volneho mista
    if not IsPositionOccupied(spawn.x, spawn.y, spawn.z, 3.0, false, true, true, false, false, 0, false) then
        local model = Utils.LoadModel(modelName)
        if not model then
            Bridge.Notify('Model vozidla nenalezen', 'error')
            return
        end
        local veh = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
        SetVehicleOnGroundProperly(veh)
        SetVehicleNumberPlateText(veh, 'BURGER')
        SetEntityAsMissionEntity(veh, true, true)
        SetModelAsNoLongerNeeded(model)
        spawnedVehicle = veh
        if Config.Garage.warpIntoVehicle then
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        end
        Bridge.Notify(('Vyndal jsi: %s'):format(label), 'success')
    else
        Bridge.Notify('Na vyjezdu je prekazka', 'error')
    end
end

local function openGarage()
    local options = {}
    for _, v in ipairs(Config.Garage.vehicles) do
        options[#options + 1] = {
            title    = v.label,
            icon     = 'fa-solid fa-car',
            onSelect = function() spawnVehicle(v.model, v.label) end,
        }
    end
    options[#options + 1] = {
        title    = 'Ulozit vozidlo',
        icon     = 'fa-solid fa-square-parking',
        onSelect = storeVehicle,
    }

    lib.registerContext({
        id      = 'vx_burgershot_garage',
        title   = 'Burger Shot - Garaz',
        options = options,
    })
    lib.showContext('vx_burgershot_garage')
end

CreateThread(function()
    Interactions.Register(Config.Locations.garage.marker, openGarage)
end)
