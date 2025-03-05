# weathersync
Synced weather and time for Ovexetended Framework :sunrise:

## Dependencies
- [ox_core]
- [ox_lib]

## Features
- Syncs the weather for all players

## Installation
### Manual
- Download the script and put it in the `[ox]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure ox_lib
ensure ox_core
ensure weathersync
```

## Configuration
You can adjust available weather and defaults in `config.lua`
to adjust weather patterns you need to modify nextWeatherStage() in `server/server.lua`



## Commands

`/freezetime` - Toggle time progression

`/freezeweather` - Toggle dynamic weather

`/weather [type]` - Set weather

`/blackout` - Toggle blackout

`/morning` - Set time to 9am

`/noon` - Set time to 12pm

`/evening` - Set time to 6pm

`/night` - Set time to 11pm

`/time [hour] (minute)` - Set time to whatever you want

## Exports

### nextWeatherStage
Triggers event to switch weather to next stage
```lua
-- LUA EXAMPLE
local success = exports["weathersync"]:nextWeatherStage();
```
```js
// JAVASCRIPT EXAMPLE
const success = global.exports["weathersync"].nextWeatherStage();
```


### setWeather [type]
Switch to a specified weather type from Config.AvailableWeatherTypes
```lua
-- LUA EXAMPLE
local success = exports["weathersync"]:setWeather("snow");
```
```js
// JAVASCRIPT EXAMPLE
const success = global.exports["weathersync"].setWeather("snow");
```


### setTime [hour] (minute)
Sets sun position based on time to specified
```lua
-- LUA EXAMPLE
local success = exports["weathersync"]:setTime(8, 10); -- 8:10 AM
```
```js
// JAVASCRIPT EXAMPLE
const success = global.exports["weathersync"].setTime(15, 30); // 3:30PM
```


### setBlackout (true|false)
Sets or toggles blackout state and returns the state
```lua
-- LUA EXAMPLE
local newStatus = exports["weathersync"]:setBlackout(); -- Toggle
```
```js
// JAVASCRIPT EXAMPLE
const newStatus = global.exports["weathersync"].setBlackout(true); // Enable
```


### setTimeFreeze (true|false)
Sets or toggles time freeze state and returns the state
```lua
-- LUA EXAMPLE
local newStatus = exports["weathersync"]:setTimeFreeze(); -- Toggle
```
```js
// JAVASCRIPT EXAMPLE
const newStatus = global.exports["weathersync"].setTimeFreeze(true); // Enable
```


### setDynamicWeather (true|false)
Sets or toggles dynamic weather state and returns the state
```lua
-- LUA EXAMPLE
local newStatus = exports["weathersync"]:setDynamicWeather(); -- Toggle
```
```js
// JAVASCRIPT EXAMPLE
const newStatus = global.exports["weathersync"].setDynamicWeather(true); // Enable
```


### getBlackoutState
Returns if blackout is enabled or disabled
```lua
-- LUA EXAMPLE
local state = exports["weathersync"]:getBlackoutState();
```
```js
// JAVASCRIPT EXAMPLE
const state = global.exports["weathersync"].getBlackoutState();
```


### getTimeFreezeState
Returns if time progression is enabled or disabled
```lua
-- LUA EXAMPLE
local state = exports["weathersync"]:getTimeFreezeState();
```
```js
// JAVASCRIPT EXAMPLE
const state = global.exports["weathersync"].getTimeFreezeState();
```


### getWeatherState
Returns the current weather type
```lua
-- LUA EXAMPLE
local currentWeather = exports["weathersync"]:getWeatherState();
```
```js
// JAVASCRIPT EXAMPLE
const currentWeather = global.exports["weathersync"].getWeatherState();
```


### getDynamicWeather
Returns if time progression is enabled or disabled
```lua
-- LUA EXAMPLE
local state = exports["weathersync"]:getDynamicWeather();
```
```js
// JAVASCRIPT EXAMPLE
const state = global.exports["weathersync"].getDynamicWeather();
```


## Events


`weathersync:server:RequestStateSync` - Sync time and weather for everyone

`weathersync:server:setWeather` [type] - Set Weather type (List in Config)

`weathersync:server:setTime` [hour] (minute) - Set simulated time

`weathersync:server:toggleBlackout` (true|false) - Enable, disable or toggle blackout

`weathersync:server:toggleFreezeTime` (true|false) (minute) - Enable, disable or toggle time progression

`weathersync:server:toggleDynamicWeather` (true|false) - Enable, disable or toggle dynamic weather

