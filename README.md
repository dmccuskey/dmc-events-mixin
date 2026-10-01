# dmc-events-mixin

Give any object in a Solar2D (formerly Corona SDK) app `addEventListener()`, `removeEventListener()` and `dispatchEvent()`, like a display object's.

dmc-events-mixin is [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin) packaged like the other DMC Solar2D libraries. Add it to an object in one call, or mix it into a class:

```lua
local EventsMixModule = require 'dmc_corona.dmc_events_mix'

local obj = EventsMixModule.patch()
obj:addEventListener( obj.EVENT, function( event ) print( event.type ) end )
obj:dispatchEvent( 'ready' )  --> ready
```

## Features

- Listeners are functions, or objects with a method named after the event
- Events carry a `type`, the sending object and your data, or are any table you build
- Patch an existing object, or use the mixin as a parent class ([dmc-objects](https://github.com/dmccuskey/dmc-objects), or a plain metatable)
- The event half of every dmc-objects object, and of the DMC network libraries
- Pure Lua, no plugins needed; MIT licensed

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It makes a pretend downloader that sends progress events, and listens to them with a function and with a text object on screen.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-events-mixin.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-events-mixin and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Send Events

Create `main.lua` in the project folder:

```lua
local EventsMixModule = require 'dmc_corona.dmc_events_mix'

local downloader = EventsMixModule.patch()
downloader.EVENT = 'downloader_event'  -- the name its events are sent under
downloader.PROGRESS = 'progress'       -- the types of event it sends
downloader.DONE = 'done'

local function onDownload( event )
	if event.type == downloader.PROGRESS then
		print( "progress", event.data.percent )
	elseif event.type == downloader.DONE then
		print( "done", event.target == downloader )
	end
end

downloader:addEventListener( downloader.EVENT, onDownload )

-- pretend to download: a quarter every half second
local percent = 0
timer.performWithDelay( 500, function()
	percent = percent + 25
	downloader:dispatchEvent( downloader.PROGRESS, { percent=percent } )
	if percent == 100 then
		downloader:dispatchEvent( downloader.DONE )
	end
end, 4 )
```

Open the project in the Simulator. The screen stays black; over two seconds the console shows:

```text
progress	25
progress	50
progress	75
progress	100
done	true
```

If the console shows `module 'dmc_corona.dmc_events_mix' not found` instead, `dmc_corona/` is missing from the root of the project folder.

`patch()` adds the event methods to a new table (or to the object you pass it). The downloader sends every event under one name, its `EVENT`, and tells them apart by their `type`: `dispatchEvent( type, data )` builds an event with `name`, `type`, `target` (the sender) and `data`. The listener listens to the name and checks the type.

### 3. Listen with an Object

Add this to the end of `main.lua`:

```lua
local label = display.newText( "0%", display.contentCenterX, display.contentCenterY, native.systemFont, 48 )

-- an object listener: a method named after the event
function label:downloader_event( event )
	if event.type == downloader.PROGRESS then
		self.text = event.data.percent .. "%"
	elseif event.type == downloader.DONE then
		self.text = "done"
		downloader:removeEventListener( downloader.EVENT, self )
	end
end

downloader:addEventListener( downloader.EVENT, label )
```

The Simulator restarts the app when the file is saved. The console shows the same lines, and the text in the middle of the screen counts up to 100% and then shows `done`.

An object listener is called as `label:downloader_event( event )`, the method named after the event. The downloader doesn't know it's talking to a display object: any table with that method works.

**Going further:** events of your own shape, and Solar2D-style events (`coronaEventFunc`) ([How Events Work](https://github.com/dmccuskey/lua-events-mixin#how-events-work)).

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Documentation

`require 'dmc_corona.dmc_events_mix'` returns a copy of lua-events-mixin's module (0.3.0) with `VERSION` added, so its documentation applies as written:

- [How Events Work](https://github.com/dmccuskey/lua-events-mixin#how-events-work): event names and types, the event table, listeners
- [Reference](https://github.com/dmccuskey/lua-events-mixin#reference): `patch()`, `EventsMix`, every method, and [As a Mixin](https://github.com/dmccuskey/lua-events-mixin#as-a-mixin)
- [Known Issues](https://github.com/dmccuskey/lua-events-mixin#known-issues) of the events

## Configuration

dmc-events-mixin has no settings: `dmc_corona.cfg` needs no section for it, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Development

Only `dmc_corona/dmc_events_mix.lua` and `tests/` are written in this repository. `dmc_events_mix.lua` loads the DMC boot loader and returns a copy of lua-events-mixin's module from `lib.dmc_lua.lua_events_mix`, with `VERSION`; the shared module, and the `EventsMix` mixin in it, are left as they are. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

The unit tests check the wrapper and that lua-events-mixin's fixes come through it; lua-events-mixin's full specs are in its `spec/`. They run under plain Lua 5.1 with dkjson, with stand-ins for the Solar2D globals the boot loader uses. From the repository's root folder:

```sh
tests/run_unit.sh
```

The Quick Start is the check that the package loads in Solar2D.

## License

dmc-events-mixin is released under the [MIT License](LICENSE).
