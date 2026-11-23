# Robo-Vac

You are a robot vacuum in a one-room house. Dust settles on the floor. Drive over it to fill the bin, stand on the blue **SELL** dock to turn dust into coins, and spend coins on a larger bin. Coins, bin level, and unsold dust are saved with `DataStoreService`. If DataStore is unavailable (Studio with API access off, or an unpublished place), the same data stays in memory until the server stops. There are no game passes or developer products.

## Play in Studio

Install [Rokit](https://github.com/rojo-rbx/rokit), then from this repository:

```bash
rokit install
rojo plugin install
rojo serve
```

In Roblox Studio, open the Rojo plugin and connect. Press Play.

Drive with the normal character controls. The avatar is hidden and a vacuum disc is welded to it; jumping is disabled. The HUD shows coins, how full the bin is, and the bin upgrade. A full bin stops collecting until you sell or buy more space.

To keep progress after you stop Play, publish the place and enable **Game Settings → Security → Enable Studio Access to API Services**. Otherwise Robo-Vac prints a warning and keeps the session in memory.

## Tests

Unit tests cover the dust payout, bin capacity, and upgrade cost. They run on [Lune](https://github.com/lune-org/lune) with TestEZ, with no Studio process.

```bash
rokit install
lune run tests/run
```

Run that from the repository root.

Lint and format:

```bash
selene src tests
stylua --check src tests
```

Build the place file (CI uploads this as an artifact; it is gitignored):

```bash
rojo build default.project.json -o RoboVac.rbxl
```

## Layout

- `src/shared` — pure game rules (`Bin`, `DustEconomy`, `Upgrades`, `SaveData`)
- `src/server` — room, dust, selling, the upgrade remote, DataStore
- `src/client` — coins and bin HUD
- `tests` — TestEZ specs and `tests/run.luau`
