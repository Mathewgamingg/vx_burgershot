Config = {}

-----------------------------------------------------------------------
--  ZAKLADNI NASTAVENI
-----------------------------------------------------------------------

-- Nazev jobu, na ktery se pak napoji tvuj bridge (ESX/QB/vlastni).
-- Pokud je Config.RequireJob = false, muze pokladnu/crafting pouzivat kdokoliv.
Config.JobName        = 'burgershot'
Config.RequireJob     = true          -- true = vyzaduje job 'burgershot' pro praci uvnitr
Config.MinGradeBoss   = 3             -- grade od ktereho je clovek "boss" (vyber penez apod.)

-- Jazyk pro vestavene texty (viz locales/*.json)
Config.Locale         = 'cs'

-- Debug rezim (kresli koule na interakcnich bodech, vypisuje do konzole)
Config.Debug          = false

-----------------------------------------------------------------------
--  INTERAKCE - 3 moznosti zobrazeni bodu
--  Kazdy bod v locations.lua ma pole `interact`, kde si vybras metodu.
--  Globalne tady zapinas/vypinas jestli je dana metoda vubec povolena.
-----------------------------------------------------------------------
Config.Interaction = {
    target  = true,   -- ox_target (najedes myski / stred obrazovky)
    text3d  = true,   -- 3D text nad bodem (vykresli se az kdyz se priblizis)
    textui  = true,   -- ox_lib textUI panel v rohu (napr. "[E] Otevrit")

    -- Vzdalenost, od ktere se text3d / textui zobrazi
    drawDistance   = 2.0,   -- na jakou vzdalenost se ukaze text/nazev
    interactDistance = 1.5, -- na jakou vzdalenost lze stisknout klavesu

    -- Klavesa pro text3d / textui interakci
    key      = 38,          -- 38 = E  (viz https://docs.fivem.net/docs/game-references/controls/)
    keyLabel = 'E',
}

-----------------------------------------------------------------------
--  POKLADNA / UCTENKY
-----------------------------------------------------------------------
Config.Register = {
    -- Zpusob platby zakaznika (hrace): 'cash' | 'bank' | 'ask'
    -- 'ask' = pri placeni se hrace zepta odkud zaplatit
    defaultPayment = 'cash',

    maxBillAmount  = 5000,   -- max castka na jednu uctenku
    societyAccount = 'burgershot', -- kam padnou penize (napoji se pres bridge)

    -- Kolik % z uctenky jde firme (zbytek muze byt "spropitne" hraci - reseno v serveru)
    societyCut     = 1.0,    -- 1.0 = 100% firme
}

-----------------------------------------------------------------------
--  NAKUP SUROVIN U NPC (dojezd autem z garaze)
-----------------------------------------------------------------------
Config.Supplies = {
    -- Predmety, ktere si lze koupit u NPC dodavatele
    items = {
        { name = 'raw_patty',   label = 'Syrove maso',   price = 5  },
        { name = 'bun',         label = 'Bulka',         price = 3  },
        { name = 'lettuce',     label = 'Salat',         price = 2  },
        { name = 'tomato',      label = 'Rajce',         price = 2  },
        { name = 'cheese',      label = 'Syr',           price = 3  },
        { name = 'cup_empty',   label = 'Prazdny kelimek', price = 1 },
        { name = 'soda_syrup',  label = 'Sirup na limo', price = 4  },
        { name = 'fries_raw',   label = 'Mrazene hranolky', price = 4 },
    },
    maxPerBuy = 100, -- max kusu na jeden nakup daneho predmetu
}

-----------------------------------------------------------------------
--  GARAZ
-----------------------------------------------------------------------
Config.Garage = {
    -- Vozidla, ktera lze vytahnout (musi mit job pokud RequireJob)
    vehicles = {
        { model = 'burrito3',  label = 'Burger Shot dodavka' },
        { model = 'faggio',    label = 'Rozvozovy skutr' },
    },
    -- Kdyz hrac vrati auto, smaze se. Kdyz odejde daleko, zustava.
    deleteOnStore = true,
    warpIntoVehicle = true, -- po vyndani auta hrace rovnou posadi
}

-----------------------------------------------------------------------
--  NPC OBJEDNAVKY (kdyz je malo hracu)
-----------------------------------------------------------------------
Config.NpcOrders = {
    enabled          = true,
    -- Aktivni jen kdyz je online mene nez tolik hracu S JOBEM burgershot
    maxJobPlayers    = 2,     -- kdyz je <= 2 zamestnancu online, lze delat NPC objednavky
    minReward        = 150,   -- odmena za splnenou objednavku (min)
    maxReward        = 400,   -- odmena (max)
    orderCooldown    = 60,    -- sekund mezi objednavkami jednoho hrace
    itemsPerOrder    = { min = 1, max = 3 }, -- kolik ruznych jidel NPC chce
    countPerItem     = { min = 1, max = 2 }, -- kolik kusu od kazdeho
    timeLimit        = 600,   -- sekund na splneni objednavky (0 = bez limitu)
    -- Predmety, ktere NPC muze chtit (musi jit vyrobit v craftingu)
    possibleItems = { 'burger', 'cheeseburger', 'fries', 'soda', 'menu_combo' },
}

-----------------------------------------------------------------------
--  BLIP NA MAPE
-----------------------------------------------------------------------
Config.Blip = {
    enabled = true,
    sprite  = 106,
    color   = 1,
    scale   = 0.8,
    label   = 'Burger Shot',
}

-----------------------------------------------------------------------
--  NOTIFIKACE (napoji se na bridge)
-----------------------------------------------------------------------
Config.UseOxLibNotify = true -- true = ox_lib notify, false = nativni GTA notifikace
