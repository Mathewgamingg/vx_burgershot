# vx_burgershot 🍔

Standalone (bridge-ready) job skript pro restauraci **Burger Shot** do FiveM.

Skript má **vestavěný multi-framework bridge s auto-detekcí** pro
**ESX, QBCore, Qbox i ox_core** (+ automatická detekce `ox_inventory`).
Funguje i **standalone** (bez frameworku) na testování. Veškerá integrace
frameworku je jen ve dvou souborech: `bridge/client.lua` a `bridge/server.lua`.
Zbytek skriptu se jich nedotýká.

TextUI je **vlastní (custom)** přes NUI – klávesa/písmeno + popisek, které se
objeví jen když se přiblížíš. Není použité ox_lib textUI.

---

## ✨ Co skript umí

| Funkce | Popis |
|---|---|
| **Pokladna / účtenky** | Zaměstnanec zadá částku → nejbližšímu hráči přijde účtenka → zaplatí (cash/bank). Peníze jdou na firemní účet + spropitné prodejci. |
| **Více crafting stanic** | Gril, fritéza, příprava, balení – každá má vlastní recepty. Menu ukazuje **obrázek jídla při najetí** (ox_lib context menu). |
| **Čepování pití** | Target/3D text/textUI na nápojový automat → menu s nápoji. |
| **3 způsoby interakce** | Každý bod si v configu vybere: **target** (ox_target), **3D text** nad bodem, **custom textUI** (vlastní NUI panel s klávesou/písmenem). Text/panel se ukáže **jen když se přiblížíš** a otevřeš klávesou (výchozí `E`). |
| **Garáž** | Vytáhnutí firemního vozidla + uložení. Auto slouží k dojezdu pro suroviny. |
| **Dodavatel surovin (NPC)** | Dojezd autem k NPC na sever mapy, nákup surovin za peníze. |
| **NPC objednávky** | Když je online málo zaměstnanců, hráč si vezme objednávku pro NPC zákazníka, vyrobí jídlo, předá NPC a dostane odměnu. |
| **Firemní účet** | Boss (grade ≥ nastavení) může vybírat peníze z firemního účtu. |

---

## 📦 Instalace

1. Vlož složku `vx_burgershot` do `resources/`.
2. Do `server.cfg` přidej:
   ```cfg
   ensure ox_lib
   ensure ox_target      # volitelné (můžeš vypnout v configu)
   ensure vx_burgershot
   ```
3. Restart serveru.

### Závislosti
- **ox_lib** – *povinné* (menu s obrázky, notifikace, progressbar, callbacky).
- **ox_target** – *volitelné*. Když ho nechceš, nastav v `config/config.lua`:
  ```lua
  Config.Interaction.target = false
  ```
  a používej `text3d` / `textui`.
- **Framework** – ESX / QBCore / Qbox / ox_core (detekuje se automaticky). Bez FW jede standalone.

---

## 🔌 Framework (ESX / QBCore / Qbox / ox_core)

Framework se **detekuje sám**. Nemusíš nic přepisovat – bridge už umí všechny čtyři.
V `config/config.lua` můžeš detekci vynutit:

```lua
Config.Framework = 'auto'   -- 'esx' | 'qb' | 'qbx' | 'ox' | 'standalone'
Config.Inventory = 'auto'   -- 'ox' (ox_inventory) | 'native' (FW inventář)
Config.SocietyName = 'burgershot'  -- účet firmy (viz níže)
```

Co bridge řeší za tebe (soubor `bridge/server.lua`):
- **Job** – ESX `xPlayer.job`, QB/Qbox `PlayerData.job`, ox_core `group`.
- **Peníze** – `cash`/`bank` (u ESX se `cash` mapuje na `money`), přes nativní FW funkce.
- **Inventář** – `ox_inventory` pokud běží, jinak nativní FW inventář.
- **Society (účet firmy)**:
  - ESX → `esx_addonaccount` účet `society_burgershot`
  - QB/Qbox → `qb-banking` / `Renewed-Banking` / `qb-management`
  - ox → `ox_banking`
  - když daný banking chybí → interní fallback (nepersistentní).

> V konzoli po startu uvidíš: `[vx_burgershot] Framework: <fw> | ox_inventory: <bool>`.

### Předměty (items)
Nezapomeň mít předměty registrované ve svém inventáři/DB (suroviny i výsledky):
`raw_patty, bun, lettuce, tomato, cheese, cup_empty, soda_syrup, fries_raw,
cooked_patty, burger, cheeseburger, fries, onion_rings, salad, soda, cola,
water, menu_combo`. U ESX/QB je přidej do items DB, u ox_inventory do `data/items.lua`.

> ⚠️ Ve **standalone** režimu (bez FW) jsou peníze a inventář jen simulované na
> testování – nejsou persistentní.

### Vlastní / jiný bridge
Chceš úplně vlastní bridge? Přepiš jen vnitřky funkcí v `bridge/server.lua` a
`bridge/client.lua` (`Bridge.GetJob`, `Bridge.AddMoney`, `Bridge.AddItem`, …).
Zbytek skriptu volá jen tyto funkce.

---

## ⚙️ Konfigurace

- `config/config.lua` – job, interakce (klávesa, vzdálenosti), pokladna, garáž, dodavatel, NPC objednávky, blip.
- `config/locations.lua` – **všechny souřadnice** a volba metody interakce pro každý bod.
- `config/recipes.lua` – crafting stanice, recepty (suroviny, čas, obrázek), nápoje, ceny.

### Změna souřadnic
Souřadnice jsou orientační (Burger Shot ve Vespucci + dodavatel na severu).
Uprav si je v `config/locations.lua` – např. přes `/coords` nebo podobný nástroj v GTA.

### Výběr metody interakce
U každého bodu v `locations.lua` napíšeš **jednu** hodnotu:
```lua
interact = 'target',   -- 'target' | 'textui' | '3dtext'
```
- `'target'` – ox_target (koukni na bod)
- `'textui'` – vlastní textUI panel s klávesou (ukáže se když jsi blízko)
- `'3dtext'` – 3D text nad bodem s klávesou (ukáže se když jsi blízko)

Globálně jednotlivé metody můžeš zapnout/vypnout v `Config.Interaction`.

### Obrázky jídel
Výchozí nastavení **tahá obrázky přímo z `ox_inventory`** (jeho `web/images/<item>.png`),
takže se použijí ty samé obrázky, co už máš u předmětů v inventáři – nemusíš nic kopírovat.

```lua
Config.Images = {
    source     = 'ox_inventory', -- 'ox_inventory' | 'local'
    oxResource = 'ox_inventory', -- kdyby sis fork přejmenoval
    fallbackToLocal = true,
}
```

- `source = 'ox_inventory'` → obrázek = `nui://ox_inventory/web/images/<item>.png` (název podle výsledného itemu).
- `source = 'local'` → použijí se obrázky z `html/images/` (pole `image` u receptu). V `html/images/` jsou přiložené **placeholder PNG**, nahraď je vlastními.

---

## 💡 Další vylepšení, která můžeme přidat

Pár nápadů, jak to posunout dál (klidně řekni co chceš a doděláme):

1. **Boss menu** – najímání/vyhazování zaměstnanců, nastavení platů, statistiky tržeb, výběr z firemního účtu přes UI (teď je jen event).
2. **Skladové zásoby firmy** – suroviny se berou ze společného skladu (stash), ne z osobního inventáře; dodavatel doplňuje sklad.
3. **Kvalita/čerstvost jídla** – jídlo má „freshness" a po čase se kazí; mini-hra (skillcheck) při vaření ovlivní kvalitu a tím cenu.
4. **Skillcheck / mini-hry** při grilování a čepování (ox_lib `skillCheck`) místo prostého progressbaru.
5. **Denní výplaty a docházka** – clock in/out, odpracované hodiny, automatická výplata.
6. **Rozvoz (delivery job)** – NPC objednávky s dojezdem na adresu autem/skútrem, odměna dle vzdálenosti a času.
7. **Reputace / levelování zaměstnance** – s levelem se odemykají lepší recepty a vyšší odměny.
8. **Drive-thru** – okénko s targetom pro obsluhu aut, fronta NPC vozidel.
9. **Uniforma / převlékárna** – outfity přes skinchanger, oblečení podle gradu.
10. **Efekty jídla** – jídlo doplňuje hlad/žízeň (napojení na status systém), různé buffy.
11. **Interaktivní propy** – umístění hotového jídla na tác/pult jako fyzický objekt, který zákazník sebere.
12. **Statistiky & leaderboard** – kdo prodal nejvíc, nejlepší zaměstnanec týdne.
13. **Zvuky a animace** – zvuk grilu, fritézy, čepování; lepší animace scén.
14. **Anti-abuse** – limity na počet účtenek/min, log transakcí do Discordu (webhook).
15. **Ceník / menu tabule** – NUI tabule s aktuálním menu a cenami pro zákazníky.

---

## 🗂️ Struktura

```
vx_burgershot/
├── fxmanifest.lua
├── config/
│   ├── config.lua        # hlavní nastavení
│   ├── locations.lua     # souřadnice + metody interakce
│   └── recipes.lua       # crafting stanice, recepty, nápoje
├── bridge/
│   ├── client.lua        # <- napojení frameworku (client)
│   └── server.lua        # <- napojení frameworku (server)
├── client/
│   ├── utils.lua
│   ├── textui.lua        # vlastni (custom) NUI textUI
│   ├── interactions.lua  # 3 metody interakce (target/3Dtext/custom textUI)
│   ├── crafting.lua
│   ├── drinks.lua
│   ├── register.lua      # pokladna/účtenky
│   ├── garage.lua
│   ├── npc_orders.lua
│   └── main.lua          # blip, dodavatel
├── server/
│   ├── crafting.lua
│   ├── register.lua
│   ├── npc_orders.lua
│   └── main.lua
├── html/
│   ├── ui.html           # custom textUI
│   ├── style.css
│   ├── script.js
│   └── images/           # placeholder obrázky jídel (nahraď vlastními)
└── locales/cs.json
```
