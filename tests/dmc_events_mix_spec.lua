--====================================================================--
-- tests/dmc_events_mix_spec.lua
--
-- Unit tests for dmc-events-mixin, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-events-mixin has the full specs; these check the wrapper, and
-- that lua-events-mixin's fixes come through it
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local EventsMixModule, LuaEventsMix

function suite_setup()
	EventsMixModule = require 'dmc_corona.dmc_events_mix'
	LuaEventsMix = require 'lib.dmc_lua.lua_events_mix'
end



--====================================================================--
--== Tests


function test_module()
	assert_equal( 'table', type( EventsMixModule ) )
	assert_equal( '0.2.0', EventsMixModule.VERSION )
	assert_equal( '0.3.0', EventsMixModule.__version )
end

-- a copy, so the shared module isn't changed; the mixin itself is shared
function test_copy_of_shared_module()
	assert_not_equal( LuaEventsMix, EventsMixModule )
	assert_nil( LuaEventsMix.VERSION )
	assert_equal( LuaEventsMix.EventsMix, EventsMixModule.EventsMix )
	assert_equal( LuaEventsMix.patch, EventsMixModule.patch )
	assert_equal( LuaEventsMix.coronaEventFunc, EventsMixModule.coronaEventFunc )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

-- the Quick Start's function listener
function test_function_listener()
	local obj = EventsMixModule.patch()
	obj.EVENT = 'downloader_event'
	local got
	obj:addEventListener( obj.EVENT, function( event ) got = event end )
	obj:dispatchEvent( 'progress', { percent=25 } )
	assert_equal( 'downloader_event', got.name )
	assert_equal( 'progress', got.type )
	assert_equal( obj, got.target )
	assert_equal( 25, got.data.percent )
end

-- the Quick Start's object listener, which removes itself
function test_object_listener()
	local obj = EventsMixModule.patch()
	obj.EVENT = 'downloader_event'
	local label = { count=0 }
	function label:downloader_event( event )
		self.count = self.count + 1
		obj:removeEventListener( obj.EVENT, self )
	end
	obj:addEventListener( obj.EVENT, label )
	obj:dispatchEvent( 'done' )
	obj:dispatchEvent( 'done' )
	assert_equal( 1, label.count )
end

-- patch() of an existing object keeps its fields
function test_patch_object()
	local obj = { name='downloader' }
	assert_equal( obj, EventsMixModule.patch( obj ) )
	assert_equal( 'downloader', obj.name )
	assert_equal( 'function', type( obj.addEventListener ) )
end

-- lua-events-mixin 0.3.0: it raised an error before
function test_remove_with_no_listeners()
	local obj = EventsMixModule.patch()
	obj:removeEventListener( obj.EVENT, function() end )
end

-- lua-events-mixin 0.3.0: patched objects lacked these
function test_patch_create_methods()
	local obj = EventsMixModule.patch()
	assert_equal( 'function', type( obj.createEvent ) )
	assert_equal( 'function', type( obj.createCallback ) )
end
