-----------------------------------------------------------------------
--  LOKACE / INTERAKCNI BODY
--
--  Kazdy bod ma:
--    coords   = vector3(...)         -- pozice
--    heading  = float                -- natoceni (pro text3d popisek / vehicle spawn)
--    interact = Config.Interact.TARGET  -- JEDNA z konstant (viz config.lua)
--    label    = 'Text v panelu'
--    icon     = 'fa-...'             -- ikonka pro ox_target/textui
--
--  interact - pouzij jednu z konstant (definovane v config.lua -> Config.Interact):
--    Config.Interact.TARGET  = ox_target (koukni na bod)
--    Config.Interact.TEXTUI  = vlastni textUI panel s klavesou (kdyz jsi blizko)
--    Config.Interact.TEXT3D  = 3D text nad bodem s klavesou (kdyz jsi blizko)
--
--  Souradnice jsou pro klasicky Burger Shot (Vespucci) - klidne si uprav
--  pres /coords nebo podobny nastroj primo v GTA.
-----------------------------------------------------------------------

Config.Locations = {

    ----------------------------------------------------------------
    -- POKLADNA (kasa) - hrac zada castku, zakaznik zaplati
    ----------------------------------------------------------------
    registers = {
        {
            coords   = vector3(-1194.19, -893.13, 13.99),
            heading  = 125.0,
            interact = Config.Interact.TARGET,
            label    = 'Pokladna',
            icon     = 'fa-solid fa-cash-register',
        },
        {
            coords   = vector3(-1196.72, -894.98, 13.99),
            heading  = 125.0,
            interact = Config.Interact.TEXTUI,
            label    = 'Pokladna',
            icon     = 'fa-solid fa-cash-register',
        },
    },

    ----------------------------------------------------------------
    -- CRAFTING STANICE - vice mist, kazde umi jinou skupinu jidel
    -- `station` odkazuje na klic v recipes.lua (Config.CraftStations)
    ----------------------------------------------------------------
    crafting = {
        {
            coords   = vector3(-1198.31, -899.24, 13.99),
            heading  = 35.0,
            station  = 'grill',      -- burgery, maso
            interact = Config.Interact.TARGET,
            label    = 'Gril',
            icon     = 'fa-solid fa-fire-burner',
        },
        {
            coords   = vector3(-1200.83, -898.10, 13.99),
            heading  = 35.0,
            station  = 'fryer',      -- hranolky, smazene
            interact = Config.Interact.TEXT3D,
            label    = 'Frytovaci kos',
            icon     = 'fa-solid fa-bacon',
        },
        {
            coords   = vector3(-1201.90, -895.60, 13.99),
            heading  = 35.0,
            station  = 'prep',       -- priprava (salaty, obalovani)
            interact = Config.Interact.TEXTUI,
            label    = 'Priprava jidla',
            icon     = 'fa-solid fa-kitchen-set',
        },
        {
            coords   = vector3(-1193.30, -899.50, 13.99),
            heading  = 305.0,
            station  = 'packing',    -- kompletace menu / baleni
            interact = Config.Interact.TARGET,
            label    = 'Baleni / Menu',
            icon     = 'fa-solid fa-box',
        },
    },

    ----------------------------------------------------------------
    -- CEPOVANI PITI (drinks) - target na napojovy automat
    ----------------------------------------------------------------
    drinks = {
        {
            coords   = vector3(-1191.98, -897.05, 13.99),
            heading  = 305.0,
            interact = Config.Interact.TARGET,
            label    = 'Napojovy automat',
            icon     = 'fa-solid fa-glass-water',
        },
        {
            coords   = vector3(-1190.44, -898.60, 13.99),
            heading  = 305.0,
            interact = Config.Interact.TEXTUI,
            label    = 'Napojovy automat',
            icon     = 'fa-solid fa-glass-water',
        },
    },

    ----------------------------------------------------------------
    -- GARAZ - vyndani / vraceni vozidla
    ----------------------------------------------------------------
    garage = {
        marker = {  -- misto kde se otevre menu garaze
            coords   = vector3(-1170.50, -885.40, 13.80),
            heading  = 40.0,
            interact = Config.Interact.TARGET,
            label    = 'Garaz',
            icon     = 'fa-solid fa-warehouse',
        },
        spawn = {   -- kam se auto vyspawnuje
            coords   = vector4(-1174.90, -890.10, 13.30, 130.0),
        },
    },

    ----------------------------------------------------------------
    -- NPC DODAVATEL SUROVIN - dojezd autem
    ----------------------------------------------------------------
    supplier = {
        ped      = 'mp_m_shopkeep_01',
        coords   = vector4(-89.60, 6494.30, 30.49, 45.0), -- sever mapy (Paleto oblast)
        interact = Config.Interact.TEXT3D,
        label    = 'Dodavatel surovin',
        icon     = 'fa-solid fa-truck',
        blip     = { sprite = 478, color = 5, label = 'Dodavatel surovin' },
    },

    ----------------------------------------------------------------
    -- NPC OBJEDNAVKY - pult kde si hrac vezme objednavku pro NPC
    ----------------------------------------------------------------
    npcOrderDesk = {
        coords   = vector3(-1188.90, -892.10, 13.99),
        heading  = 305.0,
        interact = Config.Interact.TEXTUI,
        label    = 'Objednavky (NPC)',
        icon     = 'fa-solid fa-clipboard-list',
    },

    ----------------------------------------------------------------
    -- MISTO VYDEJE NPC OBJEDNAVEK (kam prijde NPC zakaznik pro jidlo)
    ----------------------------------------------------------------
    npcDeliveryPoints = {
        vector4(-1183.90, -890.90, 13.99, 210.0),
        vector4(-1185.40, -894.30, 13.99, 210.0),
    },
}
