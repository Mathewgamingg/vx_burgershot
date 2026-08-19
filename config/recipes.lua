-----------------------------------------------------------------------
--  CRAFTING STANICE A RECEPTY
--
--  Kazda stanice (grill/fryer/prep/packing) ma seznam receptu.
--  Recept:
--    result   = 'item_name'         -- co vznikne
--    amount   = 1                   -- kolik kusu vznikne
--    label    = 'Nazev'            -- zobrazeny nazev
--    image    = 'burger.png'        -- obrazek (html/images/), ukaze se v menu pri najeti
--    time     = 5000                -- doba vyroby v ms (progressbar)
--    requires = { {item=, amount=}} -- suroviny potreba
--
--  Obrazky: nahraj PNG do html/images/. Nazev bez cesty.
--  V ox_lib menu se obrazek zobrazi jako nahled polozky.
-----------------------------------------------------------------------

Config.CraftStations = {

    -----------------------------------------------------------------
    -- GRIL - burgery a maso
    -----------------------------------------------------------------
    grill = {
        label = 'Gril',
        recipes = {
            {
                result = 'cooked_patty', amount = 1, label = 'Grilovane maso',
                image = 'cooked_patty.png', time = 4000,
                requires = { { item = 'raw_patty', amount = 1 } },
            },
            {
                result = 'burger', amount = 1, label = 'Burger',
                image = 'burger.png', time = 6000,
                requires = {
                    { item = 'cooked_patty', amount = 1 },
                    { item = 'bun',          amount = 1 },
                    { item = 'lettuce',      amount = 1 },
                },
            },
            {
                result = 'cheeseburger', amount = 1, label = 'Cheeseburger',
                image = 'cheeseburger.png', time = 7000,
                requires = {
                    { item = 'cooked_patty', amount = 1 },
                    { item = 'bun',          amount = 1 },
                    { item = 'cheese',       amount = 1 },
                    { item = 'tomato',       amount = 1 },
                },
            },
        },
    },

    -----------------------------------------------------------------
    -- FRYTOVACI KOS - hranolky, smazene
    -----------------------------------------------------------------
    fryer = {
        label = 'Frytovaci kos',
        recipes = {
            {
                result = 'fries', amount = 1, label = 'Hranolky',
                image = 'fries.png', time = 5000,
                requires = { { item = 'fries_raw', amount = 1 } },
            },
            {
                result = 'onion_rings', amount = 1, label = 'Cibulove krouzky',
                image = 'onion_rings.png', time = 5000,
                requires = { { item = 'fries_raw', amount = 1 } },
            },
        },
    },

    -----------------------------------------------------------------
    -- PRIPRAVA - salaty apod.
    -----------------------------------------------------------------
    prep = {
        label = 'Priprava jidla',
        recipes = {
            {
                result = 'salad', amount = 1, label = 'Salat',
                image = 'salad.png', time = 4000,
                requires = {
                    { item = 'lettuce', amount = 1 },
                    { item = 'tomato',  amount = 1 },
                },
            },
        },
    },

    -----------------------------------------------------------------
    -- BALENI / MENU - kompletace vysledneho menu
    -----------------------------------------------------------------
    packing = {
        label = 'Baleni / Menu',
        recipes = {
            {
                result = 'menu_combo', amount = 1, label = 'Combo Menu',
                image = 'menu_combo.png', time = 3000,
                requires = {
                    { item = 'cheeseburger', amount = 1 },
                    { item = 'fries',        amount = 1 },
                    { item = 'soda',         amount = 1 },
                },
            },
        },
    },
}

-----------------------------------------------------------------------
--  CEPOVANI PITI - napojovy automat (drinks)
--  Stejny format jako recepty, jen zvlast pro automat.
-----------------------------------------------------------------------
Config.Drinks = {
    label = 'Napojovy automat',
    recipes = {
        {
            result = 'soda', amount = 1, label = 'Limonada',
            image = 'soda.png', time = 3000,
            requires = {
                { item = 'cup_empty',  amount = 1 },
                { item = 'soda_syrup', amount = 1 },
            },
        },
        {
            result = 'cola', amount = 1, label = 'Cola',
            image = 'cola.png', time = 3000,
            requires = {
                { item = 'cup_empty',  amount = 1 },
                { item = 'soda_syrup', amount = 1 },
            },
        },
        {
            result = 'water', amount = 1, label = 'Voda',
            image = 'water.png', time = 2000,
            requires = { { item = 'cup_empty', amount = 1 } },
        },
    },
}

-----------------------------------------------------------------------
--  PRODEJNI CENY (pro NPC objednavky / navrh cen na uctenku)
--  Jen orientacni - hrac na uctenku muze zadat cokoliv.
-----------------------------------------------------------------------
Config.MenuPrices = {
    burger       = 12,
    cheeseburger = 15,
    fries        = 8,
    onion_rings  = 8,
    salad        = 10,
    soda         = 5,
    cola         = 5,
    water        = 3,
    menu_combo   = 25,
}
