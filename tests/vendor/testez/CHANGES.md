# Vendored TestEZ

Upstream: [Roblox/testez](https://github.com/Roblox/testez) commit `26a5247631279154c74425b94583c189b8447d0f` (Apache-2.0). The license is in `LICENSE`.

Changes so `lune run tests/run` can execute the suite without Roblox Studio:

- `require(script...)` calls are string requires. Sibling modules use `./`. `init.lua` is the folder module, so its children use `@self/`, matching Roblox and Lune.
- `TestPlan` and `TestRunner` no longer call `getfenv` / `setfenv`. Open-source Luau does not have them, and `_G` is not the global environment. `LuneGlobals` publishes `describe`, `it`, and `expect` as real globals for the duration of a callback and then restores them.
- Reporters print failures instead of calling `TestService:Error`.
