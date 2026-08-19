-----------------------------------------------------------------------
--  CUSTOM TEXTUI (client) - vlastni NUI panel
--  Ukazuje klavesu (pismeno) + popisek. Zobrazi se jen kdyz jsi blizko
--  (rizeno z interactions.lua). Nezavisle na ox_lib textUI.
-----------------------------------------------------------------------

TextUI = {}

local shown        = false
local currentLabel = nil

-- position: 'right-center' | 'left-center' | 'top-center' | 'bottom-center'
function TextUI.Show(label, key, position)
    if shown and currentLabel == label then return end
    shown = true
    currentLabel = label
    SendNUIMessage({
        action   = 'showTextUI',
        label    = label,
        key      = key or Config.Interaction.keyLabel,
        position = position or Config.Interaction.textuiPosition or 'right-center',
    })
end

function TextUI.Hide()
    if not shown then return end
    shown = false
    currentLabel = nil
    SendNUIMessage({ action = 'hideTextUI' })
end

-- schovat pri stopu resource (aby nezustal viset panel)
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SendNUIMessage({ action = 'hideTextUI' })
    end
end)
