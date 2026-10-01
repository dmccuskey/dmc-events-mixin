# Changelog

## 0.2.0 (2026-10-01)

### Changed

- The events are now lua-events-mixin 0.3.0's, from DMC-Lua-Library's `lib.dmc_lua.lua_events_mix` (it was 0.2.2): `require 'dmc_corona.dmc_events_mix'` returns a copy of it, so the shared module is left as it is. From lua-events-mixin 0.3.0:
  - `removeEventListener()` no longer raises an error when nothing listens to the name.
  - Patched objects have `createEvent()` and `createCallback()`.
  - A listener added during a dispatch isn't called in it, and one removed during a dispatch isn't called either.
  - Objects whose `tostring()` matched no longer replace each other as listeners.
  - `setDebug()` prints each dispatch.
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION` in the table the module returns (`__version` is lua-events-mixin's).
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 0.1.0

- First release: lua-events-mixin packaged for Solar2D.
