local CurrentWeather = Config.StartWeather
local baseTime = Config.BaseTime
local timeOffset = Config.TimeOffset
local freezeTime = Config.FreezeTime
local blackout = Config.Blackout
local newWeatherTimer = Config.NewWeatherTimer

--- Is the source a client or the server
--- @param src string | number - source to check
--- @return int - source
local function getSource(src)
    return src == '' and 0 or src
end

--- Does source have permissions to run admin commands
--- @param src number - Source to check
--- @return boolean - has permission
local function isAllowedToChange(src)
    return src == 0 or player.hasPermission('admin') or IsPlayerAceAllowed(src, 'command')
end

--- Sets time offset based on minutes provided
--- @param minute number - Minutes to offset by
local function shiftToMinute(minute)
    timeOffset = timeOffset - (((baseTime + timeOffset) % 60) - minute)
end

--- Sets time offset based on hour provided
--- @param hour number - Hour to offset by
local function shiftToHour(hour)
    timeOffset = timeOffset - ((((baseTime + timeOffset) / 60) % 24) - hour) * 60
end

--- Triggers event to switch weather to next stage
local function nextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY" then
        CurrentWeather = (math.random(1, 5) > 2) and "CLEARING" or "OVERCAST" -- 60/40 chance
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1, 6)
        if new == 1 then CurrentWeather = (CurrentWeather == "CLEARING") and "FOGGY" or "RAIN"
        elseif new == 2 then CurrentWeather = "CLOUDS"
        elseif new == 3 then CurrentWeather = "CLEAR"
        elseif new == 4 then CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then CurrentWeather = "SMOG"
        else CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then CurrentWeather = "CLEAR"
    else CurrentWeather = "CLEAR"
    end
    TriggerEvent("weathersync:server:RequestStateSync")
end

--- Switch to a specified weather type
--- @param weather string - Weather type from Config.AvailableWeatherTypes
--- @return boolean - success
local function setWeather(weather)
    local validWeatherType = false
    for _, weatherType in pairs(Config.AvailableWeatherTypes) do
        if weatherType == string.upper(weather) then
            validWeatherType = true
        end
    end
    if not validWeatherType then return false end
    CurrentWeather = string.upper(weather)
    newWeatherTimer = Config.NewWeatherTimer
    TriggerEvent('weathersync:server:RequestStateSync')
    return true
end

--- Sets sun position based on time to specified
--- @param hour number|string - Hour to set (0-24)
--- @param minute number|string `optional` - Minute to set (0-60)
--- @return boolean - success
local function setTime(hour, minute)
    local argh = tonumber(hour)
    local argm = tonumber(minute) or 0
    if argh == nil or argh > 24 then
        print('time.invalid')
        return false
    end
    shiftToHour((argh < 24) and argh or 0)
    shiftToMinute((argm < 60) and argm or 0)
    print('time.change', {value = argh, value2 = argm})
    TriggerEvent('weathersync:server:RequestStateSync')
    return true
end

--- Sets or toggles blackout state and returns the state
--- @param state boolean `optional` - enable blackout?
--- @return boolean - blackout state
local function setBlackout(state)
    if state == nil then state = not blackout end
    if state then blackout = true
    else blackout = false end
    TriggerEvent('weathersync:server:RequestStateSync')
    return blackout
end

--- Sets or toggles time freeze state and returns the state
--- @param state boolean `optional` - Enable time freeze?
--- @return boolean - Time freeze state
local function setTimeFreeze(state)
    if state == nil then state = not freezeTime end
    if state then freezeTime = true
    else freezeTime = false end
    TriggerEvent('weathersync:server:RequestStateSync')
    return freezeTime
end

--- Sets or toggles dynamic weather state and returns the state
--- @param state boolean `optional` - Enable dynamic weather?
--- @return boolean - Dynamic Weather state
local function setDynamicWeather(state)
    if state == nil then state = not Config.DynamicWeather end
    if state then Config.DynamicWeather = true
    else Config.DynamicWeather = false end
    TriggerEvent('weathersync:server:RequestStateSync')
    return Config.DynamicWeather
end

--- Retrieves the current time from worldtimeapi.org
--- @return number - Unix time
local function retrieveTimeFromApi(callback)
    Citizen.CreateThread(function()
        PerformHttpRequest("http://worldtimeapi.org/api/ip", function(statusCode, response)
            if statusCode == 200 then
                local data = json.decode(response)
                if data == nil or data.unixtime == nil then
                    callback(nil)
                else
                    callback(data.unixtime)
                end
            else
                callback(nil)
            end
        end, "GET", nil, nil)
    end)
end

-- EVENTS
RegisterNetEvent('weathersync:server:RequestStateSync', function()
    TriggerClientEvent('weathersync:client:SyncWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('weathersync:client:SyncTime', -1, baseTime, timeOffset, freezeTime)
end)

RegisterNetEvent('weathersync:server:setWeather', function(weather)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local success = setWeather(weather)
        if src > 0 then
            if (success) then TriggerClientEvent('ox_lib:notify', src, { title = locale('weather.updated'), type = 'success', })
            else TriggerClientEvent('ox_lib:notify', src, { title = locale('weather.invalid'), type = 'error', })
            end
        end
    end
end)

RegisterNetEvent('weathersync:server:setTime', function(hour, minute)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local success = setTime(hour, minute)
        if src > 0 then
            if (success) then TriggerClientEvent('ox_lib:notify', src, { title = locale('time.change'), type = 'success', })
            else TTriggerClientEvent('ox_lib:notify', src, { title = locale('time.invalid'), type = 'error', })
            end
        end
    end
end)
RegisterNetEvent('weathersync:server:toggleBlackout', function(state)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local newstate = setBlackout(state)
        if src > 0 then
            if (newstate) then TriggerClientEvent('ox_lib:notify', src, { title = locale('blackout.enabled'), type = 'success', })
            else TriggerClientEvent('ox_lib:notify', src, { title = locale('blackout.disabled'), type = 'error', })
            end
        end
    end
end)

RegisterNetEvent('weathersync:server:toggleFreezeTime', function(state)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local newstate = setTimeFreeze(state)
        if src > 0 then
            if (newstate) then TriggerClientEvent('ox_lib:notify', src, { title = locale('time.now_frozen'), type = 'success', })
            else TriggerClientEvent('ox_lib:notify', src, { title = locale('time.now_unfrozen'), type = 'error', })
            end
        end
    end
end)

RegisterNetEvent('weathersync:server:toggleDynamicWeather', function(state)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local newstate = setDynamicWeather(state)
        if src > 0 then
            if (newstate) then TriggerClientEvent('ox_lib:notify', src, { title = locale('weather.now_unfrozen'), type = 'error', })
            else TriggerClientEvent('ox_lib:notify', src, { title = locale('weather.now_frozen'), type = 'success', })
            end
        end
    end
end)

-- COMMANDS
lib.addCommand('freezetime', {
    help = 'help.freezecommand',
    params = {},
    restricted = 'admin'
}, function(source)
    local newstate = setTimeFreeze()
    if source > 0 then
        if (newstate) then return TriggerClientEvent('ox_lib:notify', source, { title = locale('time.frozenc'), type = 'success', }) end
        return TriggerClientEvent('ox_lib:notify', source, { title = locale('time.unfrozenc'), type = 'error', })
    end
    if (newstate) then return print('time.now_frozen') end
    return print('time.now_unfrozen')
end)

lib.addCommand('freezeweather', {
    help = 'help.freezeweathercommand',
    params = {},
    restricted = 'admin'
}, function(source)
    local newstate = setDynamicWeather()
    if source > 0 then
        if (newstate) then return TriggerClientEvent('ox_lib:notify', source, { title = locale('dynamic_weather.enabled'), type = 'success', }) end
        return TriggerClientEvent('ox_lib:notify', source, { title = locale('dynamic_weather.disabled'), type = 'error', })
    end
    if (newstate) then return print('weather.now_unfrozen') end
    return print('weather.now_frozen')
end)

lib.addCommand('weather', {
    help = 'Set the server weather',
    restricted = 'admin',
    params = {
        { name = 'weatherType', help = 'Type of weather to set',
            type = 'string'
        }
    }
}, function(source, args)
    local success = setWeather(args.weatherType)
    
    if source > 0 then
        if success then
            lib.notify({
                title = locale('Weather Changed'),
                description = string.format('Weather will change to %s', string.lower(args.weatherType)),
                type = 'success'
            })
            return
        end
        
        lib.notify({
            title = locale('Error'),
            description = 'Invalid weather type',
            type = 'error'
        })
        return
    end
end)

lib.addCommand('blackout', {
    help = 'help.blackoutcommand',
    params = {},
    restricted = 'admin'
}, function(source)
    local newstate = setBlackout()
    if source > 0 then
        if (newstate) then return TriggerClientEvent('ox_lib:notify', source, { title = locale('blackout.enabledc'), type = 'success'}) end
        return TriggerClientEvent('ox_lib:notify', source, { title = locale('blackout.disabledc'), type = 'success', })
    end
    if (newstate) then return print('blackout.enabled') end
    return print('blackout.disabled')
end)

lib.addCommand('morning', {
    help = 'help.morningcommand',
    params = {},
    restricted = 'admin'
}, function(source)
    setTime(9, 0)
    if source > 0 then return TriggerClientEvent('ox_lib:notify', source, { title = locale('time.morning'), type = 'success', }) end
end)

lib.addCommand('noon', {
    help = 'help.nooncommand',
    params = {},
    restricted = 'admin'
}, function(source)
    setTime(12, 0)
    if source > 0 then return TriggerClientEvent('ox_lib:notify', source, { title = locale('time.noon'), type = 'success', }) end
end)

lib.addCommand('evening', {
    help = 'help.eveningcommand',
    params = {},
    restricted = 'admin'
}, function(source)
    setTime(18, 0)
    if source > 0 then return TriggerClientEvent('ox_lib:notify', source, { title = locale('time.evening'), type = 'success', }) end
end)

lib.addCommand('night', {
    help = 'help.nightcommand',
    params = {},
    restricted = 'admin'
}, function(source)
    setTime(23, 0)
    if source > 0 then return TriggerClientEvent('ox_lib:notify', source, { title = locale('time.night'), type = 'success', }) end
end)

lib.addCommand('time', {
    help = 'Set the server time',
    restricted = 'admin',
    params = { { name = 'hours', help = 'Hour to set (0-23)', type = 'number' }, { name = 'minutes', help = 'Minutes to set (0-59)', type = 'number', optional = true } }
}, function(source, args)
    local success = setTime(args.hours, args.minutes)
    if source > 0 then
        if success then
            lib.notify({ title = locale('Time Changed'), description = string.format('Time set to %s:%s', args.hours, args.minutes or "00"), type = 'success' })
            return
        end
        lib.notify({ title = locale('Error'), description = 'Invalid time format', type = 'error' })
        return
    end
end)

-- THREAD LOOPS
CreateThread(function()
    local previous = 0
    local realTimeFromApi = nil
    local failedCount = 0

    while true do
        Wait(0)
        local newBaseTime = os.time(os.date("!*t")) / 2 + 360 --Set the server time depending of OS time
        if Config.RealTimeSync then
            newBaseTime = os.time(os.date("!*t")) --Set the server time depending of OS time
            if realTimeFromApi == nil then
                retrieveTimeFromApi(function(unixTime)
                    realTimeFromApi = unixTime -- Set the server time depending on real-time retrieved from API
                end)
            end
            while realTimeFromApi == nil do
                if failedCount > 10 then
                    print("Failed to retrieve real time from API, falling back to local time")
                    break
                end
                failedCount = failedCount + 1
                Wait(100)
            end
            if realTimeFromApi ~= nil then
                newBaseTime = realTimeFromApi
            end
        end
        if (newBaseTime % 60) ~= previous then --Check if a new minute is passed
            previous = newBaseTime % 60 --Only update time with plain minutes, seconds are handled in the client
            if freezeTime then
                timeOffset = timeOffset + baseTime - newBaseTime
            end
            baseTime = newBaseTime
        end
    end
end)

CreateThread(function()
    while true do
        Wait(2000)--Change to send every minute in game sync
        TriggerClientEvent('weathersync:client:SyncTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        TriggerClientEvent('weathersync:client:SyncWeather', -1, CurrentWeather, blackout)
    end
end)

CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Wait((1000 * 60) * Config.NewWeatherTimer)
        if newWeatherTimer == 0 then
            if Config.DynamicWeather then
                nextWeatherStage()
            end
            newWeatherTimer = Config.NewWeatherTimer
        end
    end
end)

-- EXPORTS
exports('nextWeatherStage', nextWeatherStage)
exports('setWeather', setWeather)
exports('setTime', setTime)
exports('setBlackout', setBlackout)
exports('setTimeFreeze', setTimeFreeze)
exports('setDynamicWeather', setDynamicWeather)
exports('getBlackoutState', function() return blackout end)
exports('getTimeFreezeState', function() return freezeTime end)
exports('getWeatherState', function() return CurrentWeather end)
exports('getDynamicWeather', function() return Config.DynamicWeather end)

exports('getTime', function()
    local hour = math.floor(((baseTime+timeOffset)/60)%24)
    local minute = math.floor((baseTime+timeOffset)%60)

    return hour,minute
end)
