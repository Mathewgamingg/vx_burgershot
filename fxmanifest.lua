fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vx_burgershot'
author 'vx'
description 'Burger Shot restaurace - standalone (bridge-ready) job script'
version '1.0.0'

-- Doporucene zavislosti (nejsou tvrde vyzadovane, ale doporuceny):
--   ox_lib      -> menu s obrazky, textUI, notifikace, progressbar, callbacky
--   ox_target   -> target interakce (volitelne, lze vypnout v configu)
-- Pokud nechces ox_target, nastav Config.Interaction.target = false a pouzij 3Dtext / textUI.

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'config/locations.lua',
    'config/recipes.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/utils.lua',
    'client/interactions.lua',
    'client/crafting.lua',
    'client/drinks.lua',
    'client/register.lua',
    'client/garage.lua',
    'client/npc_orders.lua',
    'client/main.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/crafting.lua',
    'server/register.lua',
    'server/npc_orders.lua',
    'server/main.lua',
}

files {
    'locales/*.json',
    'html/images/*.png',
}

-- ox_lib lokalizace (volitelne)
-- ox_lib_locale 'cs'
