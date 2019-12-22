----------------------    
---   leuit#0100   ---
----------------------
IsInputDisabled = function(a) return Citizen.InvokeNative(0xA571D46727E2B718, a) end
	
local rscName = GetCurrentResourceName()

local blacklistedEvents = {
	"anticheese",
	"anticheat",
	"antilynx",
	"discordbot",
	"EasyAdmin:CaptureScreenshot",
	"screenshot",
}

local registeredEvents = {}
local registeredServerEvents = {}

local RegisterEventHandler = AddEventHandler
AddEventHandler = function(eventName, eventRoutine)
	local eventNameLower = eventName:lower()
	for i, v in ipairs(blacklistedEvents) do
		if eventNameLower:find(v:lower()) then
			print("^1Blocked blacklisted event handler ^3" .. eventName .. " ^1in resource ^0" .. rscName)
			return
		end
	end

	local handler = RegisterEventHandler(eventName, eventRoutine)
	registeredEvents[handler.key] = handler.name
	print("^4Logging registered event handlers...")
	return handler
end

local SendServerEvent = TriggerServerEvent
TriggerServerEvent = function(eventName, ...)
	local payload = msgpack.pack({...})
	local eventNameLower = eventName:lower()

	registeredServerEvents[eventName] = payload
	
	for i, v in ipairs(blacklistedEvents) do
		if eventNameLower:find(v:lower()) then
			print("^1Blocked blacklisted server event ^3" .. eventName .. " ^1in resource ^0" .. rscName)
			return
		end
	end

	return TriggerServerEventInternal(eventName, payload, payload:len())

end

local ShowRadar = DisplayRadar
DisplayRadar = function(bool, pass)
	if pass then
		ShowRadar(bool)
	end
end

RegisterNetEvent(rscName .. ".query")
RegisterEventHandler(rscName .. ".query", function(query)

	if query == "global" or "globals" then
		print("^3Global query results from ^4" .. rscName)
		for k, v in pairs(_G) do
			print(k, v)
		end
	end

end)

RegisterNetEvent(rscName .. ".verify")
RegisterEventHandler(rscName .. ".verify", function(cb)
	cb(rscName)
end)

RegisterNetEvent(rscName .. ".getEvents")
RegisterEventHandler(rscName .. ".getEvents", function(cb)
	cb(rscName, registeredEvents)
end)

RegisterNetEvent(rscName .. ".getServerEvents")
RegisterEventHandler(rscName .. ".getServerEvents", function(cb)
	cb(rscName, registeredServerEvents)
end)
