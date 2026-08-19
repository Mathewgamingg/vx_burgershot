# vx_burgershot 🍔

Standalone (bridge-ready) job skript pro restauraci **Burger Shot** do FiveM.

Skript je napsaný tak, aby fungoval **sám o sobě** (bez frameworku) a zároveň
byl připravený na napojení tvého vlastního **bridge** – veškerá integrace
frameworku (ESX / QBCore / Qbox / vlastní) je jen ve dvou souborech:
`bridge/client.lua` a `bridge/server.lua`. Zbytek skriptu se jich nedotýká.

---

## ✨ Co skript umí

| Funkce | Popis |
|---|---|
| **Pokladna / účtenky** | Zaměstnanec zadá částku → nejbližšímu hráči přijde účtenka → zaplatí (cash/bank). Peníze jdou na firemní účet + spropitné prodejci. |
| **Více crafting stanic** | Gril, fritéza, příprava, balení – každá má vlastní recepty. Menu ukazuje **obrázek jídla při najetí** (ox_lib context menu). |
| **Čepování pití** | Target/3D text/textUI na nápojový automat → menu s nápoji. |
| **3 způsoby interakce** | Každý bod si v configu vybere: **target** (ox_target), **3D text** nad bodem, **textUI** panel. Text/panel se ukáže **jen když se přiblížíš** a otevřeš klávesou (výchozí `E`). |
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
- **ox_lib** – *povinné* (menu s obrázky, textUI, notifikace, progressbar, callbacky).
- **ox_target** – *volitelné*. Když ho nechceš, nastav v `config/config.lua`:
  ```lua
  Config.Interaction.target = false
  ```
  a používej `text3d` / `textui`.

> Skript **nevyžaduje žádný framework**. Pro reálné peníze a inventář ho ale
> napojíš na svůj bridge – viz níže.

---

## 🔌 Napojení na bridge / framework

Vše je v `bridge/client.lua` a `bridge/server.lua`. Uvnitř funkcí jsou už
připravené příklady pro ESX i QBCore (zakomentované). Stačí odkomentovat /
přepsat vnitřek těchto funkcí:

**Server (`bridge/server.lua`)**
- `Bridge.GetJob(src)` – vrátí job hráče `{ name, grade }`
- `Bridge.AddMoney / RemoveMoney(src, account, amount)`
- `Bridge.AddSociety / GetSociety(account, amount)` – firemní účet
- `Bridge.AddItem / RemoveItem / GetItemCount(src, item, amount)` – inventář (např. `ox_inventory`)

**Client (`bridge/client.lua`)**
- `Bridge.GetJob()` / `Bridge.HasJob()` – job hráče
- `Bridge.Notify(msg, type)` – notifikace

> ⚠️ Ve **standalone** režimu jsou peníze a inventář jen simulované (na testování).
> Nejsou persistentní! Po napojení bridge se použije tvůj skutečný FW.

---

## ⚙️ Konfigurace

- `config/config.lua` – job, interakce (klávesa, vzdálenosti), pokladna, garáž, dodavatel, NPC objednávky, blip.
- `config/locations.lua` – **všechny souřadnice** a volba metody interakce pro každý bod.
- `config/recipes.lua` – crafting stanice, recepty (suroviny, čas, obrázek), nápoje, ceny.

### Změna souřadnic
Souřadnice jsou orientační (Burger Shot ve Vespucci + dodavatel na severu).
Uprav si je v `config/locations.lua` – např. přes `/coords` nebo podobný nástroj v GTA.

### Výběr metody interakce
V každém bodě v `locations.lua`:
```lua
interact = { 'target', 'textui' },  -- klidně víc naráz
```
Globálně jednotlivé metody zapínáš/vypínáš v `Config.Interaction`.

### Obrázky jídel
V `html/images/` jsou **placeholder PNG** (barevné čtverce). Nahraď je vlastními
obrázky (stejný název, např. `burger.png`) pro pěkný náhled v menu.

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
│   ├── interactions.lua  # 3 metody interakce (target/3Dtext/textUI)
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
├── html/images/          # placeholder obrázky jídel (nahraď vlastními)
└── locales/cs.json
```
