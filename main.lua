local CreateThread = Citizen.CreateThread

LUX = {}

function LUX:CheckName(str) 
	if string.len(str) > 16 then
		fmt = string.sub(str, 1, 16)
		return tostring(fmt .. "...")
	else
		return str
	end
end

local contributors = {
	{"leuit#0100", "Development & Design"},
	{"Joeyarrabi#7440", "Menu Reference"}
}

LUX.Math = {}
LUX.Player = {
	inVehicle = false,
	isNoclipping = false,
}

local NoclipSpeed = 1
local oldSpeed = 1

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

AddTextEntry('notification_buffer', '~a~')
AddTextEntry('text_buffer', '~a~')
AddTextEntry('preview_text_buffer', '~a~')
AddTextEntry('keyboard_title_buffer', '~a~')

-- Classes
-- > Gatekeeper
Gatekeeper = {}

-- Fullscreen Notification builder
local _notifTitle = "~p~LUX MENU"
local _notifMsg = "We must authenticate your license before you proceed"
local _notifMsg2 = "~g~Please enter your unique key code"
local _errorCode = 0

local _blackAmount = 0 
-- Get other player data
local function GetPlayerMoney(player)
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

local ratio = GetAspectRatio(true)
local mult = 10^3
local floor = math.floor
local unpack = table.unpack

local streamedTxtSize

local txtRatio = {}

local function DrawSpriteScaled(textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha)
	-- calculate the height of a sprite using aspect ratio and hash it in memory
	local index = tostring(textureName)
	
	if not txtRatio[index] then
		txtRatio[index] = {}
		local res = GetTextureResolution(textureDict, textureName)
		
		txtRatio[index].ratio = (res[2] / res[1])
		txtRatio[index].height = floor(((width * txtRatio[index].ratio) * ratio) * mult + 0.5) / mult
		DrawSprite(textureDict, textureName, screenX, screenY, width, txtRatio[index].height, heading, red, green, blue, alpha)
	end
	
	DrawSprite(textureDict, textureName, screenX, screenY, width, txtRatio[index].height, heading, red, green, blue, alpha)
end

local function RequestControlOnce(entity)
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
	WEAPON_COMBATPISTOL = {"Combat Pistol", "w_pi_combatpistol", "mpweaponscommon_small", "w_hg"},
	WEAPON_PISTOL = {"Pistol", "w_pi_pistol", "mpweaponsgang1_small", "w_hg"},
	WEAPON_APPISTOL = {"AP Pistol", "w_pi_apppistol", "mpweaponsgang1_small", "w_hg"},
	WEAPON_STUNGUN = {"Stungun", "w_pi_stungun", "mpweaponsgang0_small", "w_hg"},

	-- Assault Rifles
	WEAPON_CARBINERIFLE = {"Carbine Rifle", "w_ar_carbinerifle", "mpweaponsgang0_small", "w_ar"},

	-- Shotguns
	WEAPON_PUMPSHOTGUN = {"Pump Shotgun", "w_sg_pumpshotgun", "mpweaponscommon_small", "w_sg"},
	WEAPON_SAWNOFFSHOTGUN = {"Sawed Off", "w_sg_sawnoff", "mpweaponsgang1", "w_sg"},

	-- SMGs / MGs
	WEAPON_MICROSMG = {"Micro SMG", "w_sb_microsmg", "mpweaponscommon_small", "w_sb"}
}

local onlinePlayerSelected = {} -- used for Online Players menu

--Fast Run/Swim Options
local HealthCB = {50, 100, 150, 200}
local HealthCBWords = {"25%", "50%", "75%", "100%"}
-- Default
local SetHealthValue = 200

--local selectedIndex = 1

local FastCB = {1.0, 1.09, 1.19, 1.29, 1.39, 1.49}
local FastCBWords = {"Default", "+20%", "+40%", "+60%", "+80%", "+100%"}

local selFastRunIndex = 1

local currentMods = nil
local EngineUpgrade = {-1, 0, 1, 2, 3}
local VehicleUpgradeWords = {

	{"Default", "Level 1"},
	{"Default", "Level 1", "Level 2"},
	{"Default", "Level 1", "Level 2", "Level 3"},
	{"Default", "Level 1", "Level 2", "Level 3", "Level 4"},

}



local _weaponSprite = ""

local themeColors = {
	red = { r = 231, g = 76, b = 60, a = 255 },  -- rgb(231, 76, 60)
	orange = { r = 230, g = 126, b = 34, a = 255 }, -- rgb(230, 126, 34)
	yellow = { r = 241, g = 196, b = 15, a = 255 }, -- rgb(241, 196, 15)
	green = { r = 26, g = 188, b = 156, a = 255 }, -- rgb(26, 188, 156)
	blue = { r = 52, g = 152, b = 219, a = 255 }, -- rgb(52, 152, 219)
	purple = { r = 155, g = 89, b = 182, a = 255 }, -- rgb(155, 89, 182)
	white = { r = 236, g = 240, b = 241, a = 255} -- rgb(236, 240, 241)
}
-- Set a default menu theme
_menuColor.base = themeColors.purple

local dynamicColorTheme = false

local texture_preload = {
	"commonmenu",
	"heisthud",
	"mpweaponscommon",
	"mpweaponscommon_small",
	"mpweaponsgang0_small",
	"mpweaponsgang1_small",
	"mpweaponsgang0",
	"mpweaponsgang1",
	"mpweaponsunusedfornow",
	"mpleaderboard",
	"mphud",
	"mparrow",
	"shared",
}

local function PreloadTextures()
	
	--print("^7Preloading texture dictionaries...")
	for i = 1, #texture_preload do
		RequestStreamedTextureDict(texture_preload[i])
	end

end

PreloadTextures()

local function KillYourselfThread()
	local playerPed = PlayerPedId()
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
end

local validResources = {}
local validResourceEvents = {}
local validResourceServerEvents = {}

local function KillYourself()
	CreateThread(KillYourselfThread)
end

local function GetResources()
    local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

local function VerifyResource(resourceName)
	TriggerEvent(resourceName .. ".verify", function(resource) validResources[#validResources + 1] = resource end)
end

for i, v in ipairs(GetResources()) do
	VerifyResource(v)
end


local function RefreshResourceData()
	for i, v in ipairs(validResources) do 
		TriggerEvent(v .. ".getEvents", function(rscName, events) validResourceEvents[rscName] = events end)
		--TriggerEvent(v .. ".getServerEvents", function(rscName, events) validResourceServerEvents[rscName] = events end)
	end
end

RefreshResourceData()

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

function LUX.Game.GetVehicleProperties(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}

		for id=0, 12 do
			if DoesExtraExist(vehicle, id) then
				local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
				extras[tostring(id)] = state
			end
		end

		return {
			model             = GetEntityModel(vehicle),

			plate             = LUX.Math.Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = LUX.Math.Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = LUX.Math.Round(GetVehicleEngineHealth(vehicle), 1),

			fuelLevel         = LUX.Math.Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = LUX.Math.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleLivery(vehicle)
		}
	else
		return
	end
end


-- Config for LSC
local LSC = {}

LSC.vehicleMods = {
	{name = "Spoilers", id = 0, meta = "modSpoilers"},
	{name = "Front Bumper", id = 1, meta = "modFrontBumper"},
	{name = "Rear Bumper", id = 2, meta = "modRearBumper"},
	{name = "Side Skirt", id = 3, meta = "modSideSkirt"},
	{name = "Exhaust", id = 4, meta = "modExhaust"},
	{name = "Frame", id = 5, meta = "modFrame"},
	{name = "Grille", id = 6, meta = "modGrille"},
	{name = "Hood", id = 7, meta = "modHood"},
	{name = "Fender", id = 8, meta = "modFender"},
	{name = "Right Fender", id = 9, meta = "modRightFender"},
	{name = "Roof", id = 10, meta = "modRoof"},
	{name = "Vanity Plates", id = 26, meta = "modVanityPlate"},
	{name = "Trim", id = 27, meta = "modTrim"},
	{name = "Ornaments", id = 28, meta = "modOrnaments"},
	{name = "Dashboard", id = 29, meta = "modDashboard"},
	{name = "Dial", id = 30, meta = "modDial"},
	{name = "Door Speaker", id = 31, meta = "modDoorSpeaker"},
	{name = "Seats", id = 32, meta = "modSeats"},
	{name = "Steering Wheel", id = 33, meta = "modSteeringWheel"},
	{name = "Shifter Leavers", id = 34, meta = "modShifterLeavers"},
	{name = "Plaques", id = 35, meta = "modPlaques"},
	{name = "Speakers", id = 36, meta = "modSpeakers"},
	{name = "Trunk", id = 37, meta = "modTrunk"},
	{name = "Hydraulics", id = 38, meta = "modHydraulics"},
	{name = "Engine Block", id = 39, meta = "modEngineBlock"},
	{name = "Air Filter", id = 40, meta = "modAirFilter"},
	{name = "Struts", id = 41, meta = "modStruts"},
	{name = "Arch Cover", id = 42, meta = "modArchCover"},
	{name = "Aerials", id = 43, meta = "modAerials"},
	{name = "Trim 2", id = 44, meta = "modTrimB"},
	{name = "Tank", id = 45, meta = "modTank"},
	{name = "Windows", id = 46, meta = "modWindows"},
	{name = "Livery", id = 48, meta = "modLivery"},
	{name = "Horns", id = 14, meta = "modHorns"},
	{name = "Wheels", id = 23, meta = "modFrontWheels"},
	{name = "Back Wheels", id = 24, meta = "modBackWheels"},
	-- {name = "Wheel Types", id = "wheeltypes"},
	-- {name = "Extras", id = "extra"},
	-- {name = "Neons", id = "neon"},
	-- {name = "Paint", id = "paint"},
}

LSC.perfMods = {
	{name = "Engine", id = 11, meta = "modEngine"},
	{name = "Brakes", id = 12, meta = "modBrakes"},
	{name = "Transmission", id = 13, meta = "modTransmission"},
	{name = "Suspension", id = 15, meta = "modSuspension"},
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

LSC.WheelType = {"Sport", "Muscle", "Lowrider", "SUV", "Offroad", "Tuner", "Bike Wheels", "High End"}

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

function LSC.GetHornName(index)
	if (index == 0) then
		return "Truck Horn"
	elseif (index == 1) then
		return "Cop Horn"
	elseif (index == 2) then
		return "Clown Horn"
	elseif (index == 3) then
		return "Musical Horn 1"
	elseif (index == 4) then
		return "Musical Horn 2"
	elseif (index == 5) then
		return "Musical Horn 3"
	elseif (index == 6) then
		return "Musical Horn 4"
	elseif (index == 7) then
		return "Musical Horn 5"
	elseif (index == 8) then
		return "Sad Trombone"
	elseif (index == 9) then
		return "Classical Horn 1"
	elseif (index == 10) then
		return "Classical Horn 2"
	elseif (index == 11) then
		return "Classical Horn 3"
	elseif (index == 12) then
		return "Classical Horn 4"
	elseif (index == 13) then
		return "Classical Horn 5"
	elseif (index == 14) then
		return "Classical Horn 6"
	elseif (index == 15) then
		return "Classical Horn 7"
	elseif (index == 16) then
		return "Scale - Do"
	elseif (index == 17) then
		return "Scale - Re"
	elseif (index == 18) then
		return "Scale - Mi"
	elseif (index == 19) then
		return "Scale - Fa"
	elseif (index == 20) then
		return "Scale - Sol"
	elseif (index == 21) then
		return "Scale - La"
	elseif (index == 22) then
		return "Scale - Ti"
	elseif (index == 23) then
		return "Scale - Do"
	elseif (index == 24) then
		return "Jazz Horn 1"
	elseif (index == 25) then
		return "Jazz Horn 2"
	elseif (index == 26) then
		return "Jazz Horn 3"
	elseif (index == 27) then
		return "Jazz Horn Loop"
	elseif (index == 28) then
		return "Star Spangled Banner 1"
	elseif (index == 29) then
		return "Star Spangled Banner 2"
	elseif (index == 30) then
		return "Star Spangled Banner 3"
	elseif (index == 31) then
		return "Star Spangled Banner 4"
	elseif (index == 32) then
		return "Classical Horn 8 Loop"
	elseif (index == 33) then
		return "Classical Horn 9 Loop"
	elseif (index == 34) then
		return "Classical Horn 10 Loop"
	elseif (index == 35) then
		return "Classical Horn 8"
	elseif (index == 36) then
		return "Classical Horn 9"
	elseif (index == 37) then
		return "Classical Horn 10"
	elseif (index == 38) then
		return "Funeral Loop"
	elseif (index == 39) then
		return "Funeral"
	elseif (index == 40) then
		return "Spooky Loop"
	elseif (index == 41) then
		return "Spooky"
	elseif (index == 42) then
		return "San Andreas Loop"
	elseif (index == 43) then
		return "San Andreas"
	elseif (index == 44) then
		return "Liberty City Loop"
	elseif (index == 45) then
		return "Liberty City"
	elseif (index == 46) then
		return "Festive 1 Loop"
	elseif (index == 47) then
		return "Festive 1"
	elseif (index == 48) then
		return "Festive 2 Loop"
	elseif (index == 49) then
		return "Festive 2"
	elseif (index == 50) then
		return "Festive 3 Loop"
	elseif (index == 51) then
		return "Festive 3"
	else
		return "Unknown Horn"
	end
end

function LSC.UpdateMods()
	currentMods = LUX.Game.GetVehicleProperties(LUX.Player.Vehicle)
	--SetVehicleModKit(LUX.Player.Vehicle, 0)
end

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
---------------------
--  Vehicle Class  --
---------------------
local function SpawnLocalVehicle(modelName)
	if IsModelValid(modelName) and IsModelAVehicle(modelName) then
		RequestModel(modelName)

		while not HasModelLoaded(modelName) do
			Wait(100)
		end

		local vehicle = CreateVehicle(GetHashKey(modelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, false)

		SetPedIntoVehicle(PlayerPedId(), vehicle, -1)

		SetEntityAsNoLongerNeeded(vehicle)

		SetModelAsNoLongerNeeded(modelName)
	end
end


local VehicleClass = {}

-- VEHICLES LISTS
VehicleClass.compacts = {
    {"BLISTA"},
    {"BRIOSO", "sssa_dlc_stunt"},
    {"DILETTANTE", "sssa_default", "dilettan"},
    -- {"DILETTANTE2"},
    {"ISSI2", "sssa_default"},
    {"ISSI3", "sssa_dlc_assault"},
    {"ISSI4"},
    {"ISSI5"},
    {"ISSI6"},
    {"PANTO", "sssa_dlc_hipster"},
    {"PRAIRIE"},
    {"RHAPSODY"},
}

VehicleClass.sedans = {
    {"ASEA"},
    {"ASEA2"},
    {"ASTEROPE"},
    {"COG55"},
    {"COG552"},
    {"COGNOSCENTI"},
    {"COGNOSCENTI2"},
    {"EMPEROR"},
    {"EMPEROR2"},
    {"EMPEROR3"},
    {"FUGITIVE"},
    {"GLENDALE"},
    {"INGOT"},
    {"INTRUDER"},
    {"LIMO2"},
    {"PREMIER"},
    {"PRIMO"},
    {"PRIMO2"},
    {"REGINA"},
    {"ROMERO"},
    {"SCHAFTER2"},
    {"SCHAFTER5"},
    {"SCHAFTER6"},
    {"STAFFORD"},
    {"STANIER"},
    {"STRATUM"},
    {"STRETCH"},
    {"SUPERD"},
    {"SURGE"},
    {"TAILGATER"},
    {"WARRENER"},
    {"WASHINGTON"},
}

VehicleClass.suvs = {
    {"BALLER"},
    {"BALLER2"},
    {"BALLER3"},
    {"BALLER4"},
    {"BALLER5"},
    {"BALLER6"},
    {"BJXL"},
    {"CAVALCADE"},
    {"CAVALCADE2"},
    {"CONTENDER"},
    {"DUBSTA"},
    {"DUBSTA2"},
    {"FQ2"},
    {"GRANGER"},
    {"GRESLEY"},
    {"HABANERO"},
    {"HUNTLEY"},
    {"LANDSTALKER"},
    {"MESA"},
    {"MESA2"},
    {"PATRIOT"},
    {"PATRIOT2"},
    {"RADI"},
    {"ROCOTO"},
    {"SEMINOLE"},
    {"SERRANO"},
    {"TOROS"},
    {"XLS"},
    {"XLS2"},
}

VehicleClass.coupes = {
    {"COGCABRIO"},
    {"EXEMPLAR"},
    {"F620"},
    {"FELON"},
    {"FELON2"},
    {"JACKAL"},
    {"ORACLE"},
    {"ORACLE2"},
    {"SENTINEL"},
    {"SENTINEL2"},
    {"WINDSOR"},
    {"WINDSOR2"},
    {"ZION"},
    {"ZION2"},
}

VehicleClass.muscle = {
    {"BLADE"},
    {"BUCCANEER"},
    {"BUCCANEER2"},
    {"CHINO"},
    {"CHINO2"},
    {"CLIQUE"},
    {"COQUETTE3"},
    {"DEVIANT"},
    {"DOMINATOR"},
    {"DOMINATOR2"},
    {"DOMINATOR3"},
    {"DOMINATOR4"},
    {"DOMINATOR5"},
    {"DOMINATOR6"},
    {"DUKES"},
    {"DUKES2"},
    {"ELLIE"},
    {"FACTION"},
    {"FACTION2"},
    {"FACTION3"},
    {"GAUNTLET"},
    {"GAUNTLET2"},
    {"HERMES"},
    {"HOTKNIFE"},
    {"HUSTLER"},
    {"IMPALER"},
    {"IMPALER2"},
    {"IMPALER3"},
    {"IMPALER4"},
    {"IMPERATOR"},
    {"IMPERATOR2"},
    {"IMPERATOR3"},
    {"LURCHER"},
    {"MOONBEAM"},
    {"MOONBEAM2"},
    {"NIGHTSHADE"},
    {"PHOENIX"},
    {"PICADOR"},
    {"RATLOADER"},
    {"RATLOADER2"},
    {"RUINER"},
    {"RUINER2"},
    {"RUINER3"},
    {"SABREGT"},
    {"SABREGT2"},
    {"SLAMVAN"},
    {"SLAMVAN2"},
    {"SLAMVAN3"},
    {"SLAMVAN4"},
    {"SLAMVAN5"},
    {"SLAMVAN6"},
    {"STALION"},
    {"STALION2"},
    {"TAMPA"},
    {"TAMPA3"},
    {"TULIP"},
    {"VAMOS"},
    {"VIGERO"},
    {"VIRGO"},
    {"VIRGO2"},
    {"VIRGO3"},
    {"VOODOO"},
    {"VOODOO2"},
    {"YOSEMITE"},
}

VehicleClass.sportsclassics = {
    {"ARDENT"},
    {"BTYPE"},
    {"BTYPE2"},
    {"BTYPE3"},
    {"CASCO"},
    {"CHEBUREK"},
    {"CHEETAH2"},
    {"COQUETTE2"},
    {"DELUXO"},
    {"FAGALOA"},
    {"FELTZER3"},
    {"GT500"},
    {"INFERNUS2"},
    {"JB700"},
    {"JESTER3"},
    {"MAMBA"},
    {"MANANA"},
    {"MICHELLI"},
    {"MONROE"},
    {"PEYOTE"},
    {"PIGALLE"},
    {"RAPIDGT3"},
    {"RETINUE"},
    {"SAVESTRA"},
    {"STINGER"},
    {"STINGERGT"},
    {"STROMBERG"},
    {"SWINGER"},
    {"TORERO"},
    {"TORNADO"},
    {"TORNADO2"},
    {"TORNADO3"},
    {"TORNADO4"},
    {"TORNADO5"},
    {"TORNADO6"},
    {"TURISMO2"},
    {"VISERIS"},
    {"Z190"},
    {"ZTYPE"},
}

VehicleClass.sports = {
    {"ALPHA"},
    {"BANSHEE", "lgm_default"},
    {"BESTIAGTS"},
    {"BLISTA2"},
    {"BLISTA3"},
    {"BUFFALO"},
    {"BUFFALO2"},
    {"BUFFALO3"},
    {"CARBONIZZARE"},
    {"COMET2"},
    {"COMET3"},
    {"COMET4"},
    {"COMET5"},
    {"COQUETTE"},
    {"ELEGY"},
    {"ELEGY2"},
    {"FELTZER2"},
    {"FLASHGT"},
    {"FUROREGT"},
    {"FUSILADE"},
    {"FUTO"},
    {"GB200"},
    {"HOTRING"},
    {"ITALIGTO"},
    {"JESTER"},
    {"JESTER2"},
    {"KHAMELION"},
    {"KURUMA"},
    {"KURUMA2"},
    {"LYNX"},
    {"MASSACRO"},
    {"MASSACRO2"},
    {"NEON"},
    {"NINEF"},
    {"NINEF2"},
    {"OMNIS"},
    {"PARIAH"},
    {"PENUMBRA"},
    {"RAIDEN"},
    {"RAPIDGT"},
    {"RAPIDGT2"},
    {"RAPTOR"},
    {"REVOLTER"},
    {"RUSTON"},
    {"SCHAFTER2"},
    {"SCHAFTER3"},
    {"SCHAFTER4"},
    {"SCHAFTER5"},
    {"SCHLAGEN"},
    {"SCHWARZER"},
    {"SENTINEL3"},
    {"SEVEN70"},
    {"SPECTER"},
    {"SPECTER2"},
    {"SULTAN"},
    {"SURANO"},
    {"TAMPA2"},
    {"TROPOS"},
    {"VERLIERER2"},
    {"ZR380"},
    {"ZR3802"},
    {"ZR3803"},
}

VehicleClass.super = {
    {"ADDER", "lgm_default"},
    {"AUTARCH", "lgm_default"},
    {"BANSHEE2"},
    {"BULLET"},
    {"CHEETAH"},
    {"CYCLONE"},
    {"DEVESTE"},
    {"ENTITYXF"},
    {"ENTITY2"},
    {"FMJ"},
    {"GP1"},
    {"INFERNUS"},
    {"ITALIGTB"},
    {"ITALIGTB2"},
    {"LE7B"},
    {"NERO"},
    {"NERO2"},
    {"OSIRIS"},
    {"PENETRATOR"},
    {"PFISTER811"},
    {"PROTOTIPO"},
    {"REAPER"},
    {"SC1"},
    {"SCRAMJET"},
    {"SHEAVA"},
    {"SULTANRS"},
    {"T20"},
    {"TAIPAN"},
    {"TEMPESTA"},
    {"TEZERACT"},
    {"TURISMOR"},
    {"TYRANT"},
    {"TYRUS"},
    {"VACCA"},
    {"VAGNER"},
    {"VIGILANTE"},
    {"VISIONE"},
    {"VOLTIC"},
    {"VOLTIC2"},
    {"XA21"},
    {"ZENTORNO"},
}

VehicleClass.motorcycles = {
    {"AKUMA"},
    {"AVARUS"},
    {"BAGGER"},
    {"BATI"},
    {"BATI2"},
    {"BF400"},
    {"CARBONRS"},
    {"CHIMERA"},
    {"CLIFFHANGER"},
    {"DAEMON"},
    {"DAEMON2"},
    {"DEFILER"},
    {"DEATHBIKE"},
    {"DEATHBIKE2"},
    {"DEATHBIKE3"},
    {"DIABLOUS"},
    {"DIABLOUS2"},
    {"DOUBLE"},
    {"ENDURO"},
    {"ESSKEY"},
    {"FAGGIO"},
    {"FAGGIO2"},
    {"FAGGIO3"},
    {"FCR"},
    {"FCR2"},
    {"GARGOYLE"},
    {"HAKUCHOU"},
    {"HAKUCHOU2"},
    {"HEXER"},
    {"INNOVATION"},
    {"LECTRO"},
    {"MANCHEZ"},
    {"NEMESIS"},
    {"NIGHTBLADE"},
    {"OPPRESSOR"},
    {"OPPRESSOR2"},
    {"PCJ"},
    {"RATBIKE"},
    {"RUFFIAN"},
    {"SANCHEZ"},
    {"SANCHEZ2"},
    {"SANCTUS"},
    {"SHOTARO"},
    {"SOVEREIGN"},
    {"THRUST"},
    {"VADER"},
    {"VINDICATOR"},
    {"VORTEX"},
    {"WOLFSBANE"},
    {"ZOMBIEA"},
    {"ZOMBIEB"},
}

VehicleClass.offroad = {
    {"BFINJECTION"},
    {"BIFTA"},
    {"BLAZER"},
    {"BLAZER2"},
    {"BLAZER3"},
    {"BLAZER4"},
    {"BLAZER5"},
    {"BODHI2"},
    {"BRAWLER"},
    {"BRUISER"},
    {"BRUISER2"},
    {"BRUISER3"},
    {"BRUTUS"},
    {"BRUTUS2"},
    {"BRUTUS3"},
    {"CARACARA"},
    {"DLOADER"},
    {"DUBSTA3"},
    {"DUNE"},
    {"DUNE2"},
    {"DUNE3"},
    {"DUNE4"},
    {"DUNE5"},
    {"FREECRAWLER"},
    {"INSURGENT"},
    {"INSURGENT2"},
    {"INSURGENT3"},
    {"KALAHARI"},
    {"KAMACHO"},
    {"MARSHALL"},
    {"MENACER"},
    {"MESA3"},
    {"MONSTER"},
    {"MONSTER3"},
    {"MONSTER4"},
    {"MONSTER5"},
    {"NIGHTSHARK"},
    {"RANCHERXL"},
    {"RANCHERXL2"},
    {"RCBANDITO"},
    {"REBEL"},
    {"REBEL2"},
    {"RIATA"},
    {"SANDKING"},
    {"SANDKING2"},
    {"TECHNICAL"},
    {"TECHNICAL2"},
    {"TECHNICAL3"},
    {"TROPHYTRUCK"},
    {"TROPHYTRUCK2"},
}

VehicleClass.industrial = {
    {"BULLDOZER"},
    {"CUTTER"},
    {"DUMP"},
    {"FLATBED"},
    {"GUARDIAN"},
    {"HANDLER"},
    {"MIXER"},
    {"MIXER2"},
    {"RUBBLE"},
    {"TIPTRUCK"},
    {"TIPTRUCK2"},
}

VehicleClass.utility = {
    {"AIRTUG"},
    {"CADDY"},
    {"CADDY2"},
    {"CADDY3"},
    {"DOCKTUG"},
    {"FORKLIFT"},
    {"TRACTOR2"},
    {"TRACTOR3"},
    {"MOWER"},
    {"RIPLEY"},
    {"SADLER"},
    {"SADLER2"},
    {"SCRAP"},
    {"TOWTRUCK"},
    {"TOWTRUCK2"},
    {"TRACTOR"},
    {"UTILLITRUCK"},
    {"UTILLITRUCK2"},
    {"UTILLITRUCK3"},
    {"ARMYTRAILER"},
    {"ARMYTRAILER2"},
    {"FREIGHTTRAILER"},
    {"ARMYTANKER"},
    {"TRAILERLARGE"},
    {"DOCKTRAILER"},
    {"TR3"},
    {"TR2"},
    {"TR4"},
    {"TRFLAT"},
    {"TRAILERS"},
    {"TRAILERS4"},
    {"TRAILERS2"},
    {"TRAILERS3"},
    {"TVTRAILER"},
    {"TRAILERLOGS"},
    {"TANKER"},
    {"TANKER2"},
    {"BALETRAILER"},
    {"GRAINTRAILER"},
    {"BOATTRAILER"},
    {"RAKETRAILER"},
    {"TRAILERSMALL"},
}

VehicleClass.vans = {
    {"BISON"},
    {"BISON2"},
    {"BISON3"},
    {"BOBCATXL"},
    {"BOXVILLE"},
    {"BOXVILLE2"},
    {"BOXVILLE3"},
    {"BOXVILLE4"},
    {"BOXVILLE5"},
    {"BURRITO"},
    {"BURRITO2"},
    {"BURRITO3"},
    {"BURRITO4"},
    {"BURRITO5"},
    {"CAMPER"},
    {"GBURRITO"},
    {"GBURRITO2"},
    {"JOURNEY"},
    {"MINIVAN"},
    {"MINIVAN2"},
    {"PARADISE"},
    {"PONY"},
    {"PONY2"},
    {"RUMPO"},
    {"RUMPO2"},
    {"RUMPO3"},
    {"SPEEDO"},
    {"SPEEDO2"},
    {"SPEEDO4"},
    {"SURFER"},
    {"SURFER2"},
    {"TACO"},
    {"YOUGA"},
    {"YOUGA2"},
}

VehicleClass.cycles = {
    {"BMX"},
    {"CRUISER"},
    {"FIXTER"},
    {"SCORCHER"},
    {"TRIBIKE"},
    {"TRIBIKE2"},
    {"TRIBIKE3"},
}

VehicleClass.boats = {
    {"DINGHY"},
    {"DINGHY2"},
    {"DINGHY3"},
    {"DINGHY4"},
    {"JETMAX"},
    {"MARQUIS"},
    {"PREDATOR"},
    {"SEASHARK"},
    {"SEASHARK2"},
    {"SEASHARK3"},
    {"SPEEDER"},
    {"SPEEDER2"},
    {"SQUALO"},
    {"SUBMERSIBLE"},
    {"SUBMERSIBLE2"},
    {"SUNTRAP"},
    {"TORO"},
    {"TORO2"},
    {"TROPIC"},
    {"TROPIC2"},
    {"TUG"},
}

VehicleClass.helicopters = {
    {"AKULA"},
    {"ANNIHILATOR"},
    {"BUZZARD"},
    {"BUZZARD2"},
    {"CARGOBOB"},
    {"CARGOBOB2"},
    {"CARGOBOB3"},
    {"CARGOBOB4"},
    {"FROGGER"},
    {"FROGGER2"},
    {"HAVOK"},
    {"HUNTER"},
    {"MAVERICK"},
    {"POLMAV"},
    {"SAVAGE"},
    {"SEASPARROW"},
    {"SKYLIFT"},
    {"SUPERVOLITO"},
    {"SUPERVOLITO2"},
    {"SWIFT"},
    {"SWIFT2"},
    {"VALKYRIE"},
    {"VALKYRIE2"},
    {"VOLATUS"},
}

VehicleClass.planes = {
    {"ALPHAZ1"},
    {"AVENGER"},
    {"AVENGER2"},
    {"BESRA"},
    {"BLIMP"},
    {"BLIMP2"},
    {"BLIMP3"},
    {"BOMBUSHKA"},
    {"CARGOPLANE"},
    {"CUBAN800"},
    {"DODO"},
    {"DUSTER"},
    {"HOWARD"},
    {"HYDRA"},
    {"JET"},
    {"LAZER"},
    {"LUXOR"},
    {"LUXOR2"},
    {"MAMMATUS"},
    {"MICROLIGHT"},
    {"MILJET"},
    {"MOGUL"},
    {"MOLOTOK"},
    {"NIMBUS"},
    {"NOKOTA"},
    {"PYRO"},
    {"ROGUE"},
    {"SEABREEZE"},
    {"SHAMAL"},
    {"STARLING"},
    {"STRIKEFORCE"},
    {"STUNT"},
    {"TITAN"},
    {"TULA"},
    {"VELUM"},
    {"VELUM2"},
    {"VESTRA"},
    {"VOLATOL"},
}
    
VehicleClass.service = {
    {"AIRBUS"},
    {"BRICKADE"},
    {"BUS"},
    {"COACH"},
    {"PBUS2"},
    {"RALLYTRUCK"},
    {"RENTALBUS"},
    {"TAXI"},
    {"TOURBUS"},
    {"TRASH"},
    {"TRASH2"},
    {"WASTELANDER"},
    {"AMBULANCE"},
    {"FBI"},
    {"FBI2"},
    {"FIRETRUK"},
    {"LGUARD"},
    {"PBUS"},
    {"POLICE"},
    {"POLICE2"},
    {"POLICE3"},
    {"POLICE4"},
    {"POLICEB"},
    {"POLICEOLD1"},
    {"POLICEOLD2"},
    {"POLICET"},
    {"POLMAV"},
    {"PRANGER"},
    {"PREDATOR"},
    {"RIOT"},
    {"RIOT2"},
    {"SHERIFF"},
    {"SHERIFF2"},
    {"APC"},
    {"BARRACKS"},
    {"BARRACKS2"},
    {"BARRACKS3"},
    {"BARRAGE"},
    {"CHERNOBOG"},
    {"CRUSADER"},
    {"HALFTRACK"},
    {"KHANJALI"},
    {"RHINO"},
    {"SCARAB"},
    {"SCARAB2"},
    {"SCARAB3"},
    {"THRUSTER"},
    {"TRAILERSMALL2"},
}
    
VehicleClass.commercial = {
    {"BENSON"},
    {"BIFF"},
    {"CERBERUS"},
    {"CERBERUS2"},
    {"CERBERUS3"},
    {"HAULER"},
    {"HAULER2"},
    {"MULE"},
    {"MULE2"},
    {"MULE3"},
    {"MULE4"},
    {"PACKER"},
    {"PHANTOM"},
    {"PHANTOM2"},
    {"PHANTOM3"},
    {"POUNDER"},
    {"POUNDER2"},
    {"STOCKADE"},
    {"STOCKADE3"},
    {"TERBYTE"},
    {"CABLECAR"},
    {"FREIGHT"},
    {"FREIGHTCAR"},
    {"FREIGHTCONT1"},
    {"FREIGHTCONT2"},
    {"FREIGHTGRAIN"},
    {"METROTRAIN"},
    {"TANKERCAR"},
}

---------------------
--  LuxUI Class  --
---------------------

LuxUI = {}

LuxUI.debug = false

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local aspectRatio = GetAspectRatio(true)
local screenResolution = GetActiveScreenResolution()

local menuWidth = 0.19 -- old version was 0.23
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local separatorHeight = 0.0025

local buttonHeight = 0.038
local buttonFont = 4
local buttonScale = 0.375
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.0065
local buttonSpriteXOffset = 0.011
local buttonSpriteScale = { x = 0.016, y = 0 }

local fontHeight = GetTextScaleHeight(buttonScale, buttonFont)

local sliderWidth = (menuWidth / 4)

local sliderHeight = 0.014

local knobWidth = 0.002
local knobHeight = 0.014

local sliderFontScale = 0.275
local sliderFontHeight = GetTextScaleHeight(sliderFontScale, buttonFont)


local toggleInnerWidth = 0.008
local toggleInnerHeight = 0.014
local toggleOuterWidth = 0.01125
local toggleOuterHeight = 0.020

-- Vehicle preview, PlayerInfo, etc
local previewWidth = 0.100

local frameWidth = 0.004

local footerHeight = 0.023

------------------------
-- Notification Class --
------------------------

local t
local pow = function(num, pow) return num ^ pow end
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local abs = math.abs
local asin  = math.asin

------------------------------------------------------------------------
-- t = time == how much time has to pass for the tweening to complete --
-- b = begin == starting property value								  --
-- c = change == ending - beginning									  --
-- d = duration == running time. How much time has passed *right now* --
------------------------------------------------------------------------

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
	offsetX = 0.095, -- 0.0525
	offsetY = 0.009875, -- 0.01
	-- Draw below footer
	footerYOffset = 0,
	-- Sprite
	dict = 'commonmenu',
	sprite = 'header_gradient_script',
	font = 4,
	width = menuWidth + frameWidth, 
	height = 0.023, -- magic 0.8305 -- 0.011625
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
	BeginTextCommandLineCount("notification_buffer")
	SetTextFont(notifyBody.font)
	SetTextScale(notifyBody.scale, notifyBody.scale)
	SetTextWrap(v.x, v.x + notifyBody.width / 2)
	AddTextComponentSubstringPlayerName(text)
	local nbrLines = GetTextScreenLineCount(v.x - notifyBody.offsetX, v.y - notifyBody.height)
	return nbrLines
end

-- Thread content
local function MakeRoomThread(v, from, to, duration)
	local notif = v
	local beginVal = from
	local endVal = to
	local change = endVal - beginVal

	local timer = 0
	
	local function SetTimer()
		timer = GetGameTimer()
	end
	
	local function GetTimer()
		return GetGameTimer() - timer
	end

	local new_what
	SetTimer()
	local isMoving = true
	while isMoving do
		new_what = outCubic(GetTimer(), beginVal, change, duration)
		if notif.y < endVal then
			notif.y = new_what
		else
			notif.y = endVal
			isMoving = false
			break
		end
		Wait(5)
	end

	-- print("make room done")
end

-- Animating the 'push' transition of NotifyPrioritize
local function NotifyMakeRoom(v, from, to, duration)
	CreateThread(function()
		return MakeRoomThread(v, from, to, duration)
	end)
end

-- Does nothing right now; not used
local function NotifyGetResolutionConfiguration()
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	local minimapTopX, minimapTopY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
	ResetScriptGfxAlign()
	
	local w, h = GetActiveScreenResolution()
	
	return { x = minimapTopX, y = minimapTopY }
end

-- Pushes previous notifications down. Showing the incoming notification on top
local function NotifyPrioritize(v, id, duration)
	for i, _ in pairs(v) do
		if i ~= id then
			if v[i].draw then
				NotifyMakeRoom(v[i], v[i].y, v[i].y + ((notifyBody.height + ((v[id].lines - 1) * notifyBody.height)) + notifyBody.gap), duration)
			end
		end
	end
end

local fontHeight = GetTextScaleHeight(notifyBody.scale, notifyBody.font)

local properties = { -- 0.72
	x = 0.78 + menuWidth / 2, 
	y = 1.0, 
	notif = {}, 
	offset = NotifyPrioritize,
}

local sound_type = {
	['success'] = { name = "CHALLENGE_UNLOCKED", set = "HUD_AWARDS"},
	['info'] = { name = "FocusIn", set = "HintCamSounds" },
	['error'] = { name = "CHECKPOINT_MISSED", set = "HUD_MINI_GAME_SOUNDSET"},
}

local draw_type = {
	['success'] = { color = themeColors.green, dict = "commonmenu", sprite = "shop_tick_icon", size = 0.016},
	['info'] = { color = themeColors.blue, dict = "shared", sprite = "info_icon_32", size = 0.012},
	['error'] = { color = themeColors.red, dict = "commonmenu", sprite = "shop_lock", size = 0.016},
}

-- Text render wrapper for dynamic animation
local function NotifyDrawText(v, text)
	SetTextFont(notifyBody.font)
	SetTextScale(notifyBody.scale, notifyBody.scale)
	SetTextWrap(v.x, v.x + (menuWidth / 2))
	SetTextColour(255, 255, 255, v.opacity)

	BeginTextCommandDisplayText("notification_buffer")
	AddTextComponentSubstringPlayerName("    " .. text)
	EndTextCommandDisplayText(v.x - notifyBody.width / 2 + frameWidth / 2 + buttonTextXOffset, v.y - notifyBody.gap) -- (notifyBody.height / 2 - fontHeight / 2)
end

-- DrawSpriteScaled and DrawRect wrapper for dynamic animation
local function NotifyDrawBackground(v)
	-- Background
	DrawRect(v.x, v.y + ((v.lines - 1) * (notifyBody.height / 2)) + notifyBody.gap, notifyBody.width, notifyBody.height + ((v.lines - 1) * notifyBody.height), draw_type[v.type].color.r, draw_type[v.type].color.g, draw_type[v.type].color.b, v.opacity - 100) --57,55,91
	DrawSpriteScaled(draw_type[v.type].dict, draw_type[v.type].sprite, v.x - notifyBody.width / 2 + 0.008, v.y + notifyBody.gap, draw_type[v.type].size, nil, 0.0, 255, 255, 255, v.opacity)
	-- Highlight
	-- DrawRect(v.x - 0.0025 - (notifyBody.width / 2), v.y + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding) / 2, 0.005, notifyBody.height + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding), draw_type[v.type].r, draw_type[v.type].g, draw_type[v.type].b, v.opacity) -- 116, 92, 151
	
	
	--DrawRect(minimap.x, minimap.y, 0.01, 0.015, 255, 255, 255, v.opacity)
	--DrawSpriteScaled(body.dict, body.sprite, v.x - 0.045, v.y, 0.010, 0.04, 0, 255, 255, 255, v.opacity - 50)
end

local function NotifyFormat(inputString, ...)
	local format = string.format
	text = format(inputString, ...)
	return text
end

local notifyPreviousText = nil

local notifyQueue = 0

-- Free up the `p.notif` table if notification is no longer being drawn on screen
local function NotifyRecycle()
	--local disposeList = {}
	local notif = properties.notif

	-- print("^3NotifyRecycle: ^0Old table size: ^3" .. #p.notif)

	local drawnTable = {}

	-- allocate notifications currently on screen to drawnTable
	for i, _ in pairs(notif) do
		if notif[i].draw then
			drawnTable[i] = notif[i]
		end
	end

	-- remove notifications if they aren't drawing; shrinks size of table
	notif = drawnTable


	-- print("^3NotifyRecycle: ^0New table size: ^3" .. #p.notif)
	-- print("^3NotifyRecycle: ^4Returning: ^3" .. #p.notif + 1)
	return #notif + 1
end

-- Responsible for making sure the notification 'stick' to the menu footer
local function NotifyRecalibrate()
	local p = properties
	local stackIndex = 0

	for id, _ in pairs(p.notif) do
		if p.notif[id].draw then
			stackIndex = stackIndex + 1
		end
	end

	-- print("^5Recalibrate:^0 table size is " .. stackIndex)

	for id, _ in pairs(p.notif) do
		if p.notif[id].draw then
			if p.notif[id].tin then p.notif[id].tin = false end
			-- if p.notif[id].makeRoom then p.notif[id].makeRoom = false end

			-- print("^5Recalibrate ID: ^0" .. id)
			p.notif[id].y = (p.y - notifyBody.footerYOffset) + ((notifyBody.height + ((p.notif[id].lines - 1) * notifyBody.height) + notifyBody.gap) * (stackIndex - 1))
		
			stackIndex = stackIndex - 1
		end
	end
end

-- Define thread function
local function NotifyNewThread(options)
	local text = options.text or notifyDefault.text
	local transition = options.transition or notifyDefault.transition
	local timeout = options.timeout or notifyDefault.timeout
	local type = options.type or notifyDefault.type
	local sound = sound_type[type]
	
	local p = properties

	local nbrLines = NotifyCountLines(p, text)

	local beginY = 0.0
	local beginAlpha = 0
	
	-- garbage queueing system :)
	notifyQueue = notifyQueue + transition
	Wait(notifyQueue - transition)
	
	local id = NotifyRecycle()

	--print("^3-------- Notification " .. id .. " " .. type .. "--------")
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

	p.offset(p.notif, id, transition) --(0.05 * (id - 1)) 

	
	-- Drawing
	local function NotifyDraw()
		SetScriptGfxDrawOrder(5)
		while p.notif[id].draw do
			if LuxUI.IsAnyMenuOpened() then
				NotifyDrawBackground(p.notif[id])
				NotifyDrawText(p.notif[id], text)
			end
			Wait(0)
		end
	
		-- Schedule notification for garbage collection
		p.notif[id].dispose = true
	end
	CreateThread(NotifyDraw)

	-- Transition In
	local function NotifyFadeIn()
		local change = p.y - notifyBody.footerYOffset

		local timer = 0
	
		local function SetTimerIn() -- set the timer to 0
			timer = GetGameTimer()
		end
	
		local function GetTimerIn() -- gets the timer (counts up)
			return GetGameTimer() - timer
		end
		
		PlaySoundFrontend(-1, sound.name, sound.set, true)
	
		SetTimerIn() -- reset current timer to 0
		while p.notif[id].tin do
			local tinY = outCubic(GetTimerIn(), beginY, change, transition)
			local tinAlpha = inOutCubic(GetTimerIn(), beginAlpha, 255, transition)
	
			if p.notif[id].y >= change then
				p.notif[id].y = change
				p.notif[id].tin = false
				break
			else
				p.notif[id].y = tinY
				p.notif[id].opacity = floor(tinAlpha + 0.5)
			end
			Wait(5)
		end
		notifyQueue = notifyQueue - transition
		p.notif[id].opacity = 255
	end
	CreateThread(NotifyFadeIn)

	-- Fade out wait timeout
	Wait(timeout + transition)
	p.notif[id].beginOut = true
	p.notif[id].tout = true
	
	-- Fade out
	local function NotifyFadeOut()
		local timer = 0
	
		local function SetTimerOut(ms)
			timer = GetGameTimer() - ms
		end
	
		local function GetTimerOut()
			return GetGameTimer() - timer
		end
	
		while p.notif[id].draw do
			while p.notif[id].tout do
				
				if p.notif[id].beginOut then 
					SetTimerOut(0)
					p.notif[id].beginOut = false 
				end
	
				local opa = inOutCubic(GetTimerOut(), 255, -510, transition)
				if opa <= 0 then
	
					p.notif[id].tout = false
					p.notif[id].draw = false
	
					break
				else
					p.notif[id].opacity = floor(opa + 0.5)
				end
				Wait(5)
			end
			
			Wait(5)
		end
	end
	CreateThread(NotifyFadeOut)
	

end


local function debugPrint(text)
	if LuxUI.debug then
		Citizen.Trace("[LuxUI] " .. text)
	end
end

local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
	end
end

local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end

local function setMenuVisible(id, visible, restoreIndex)
	if id and menus[id] then
		setMenuProperty(id, "visible", visible)
		setMenuProperty(id, "currentOption", 1)

		if restoreIndex then
			setMenuProperty(id, "currentOption", menus[id].storedOption)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuProperty(currentMenu, "storedOption", menus[currentMenu].currentOption)
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end

		
		if dynamicColorTheme then

			if isMenuVisible("SelfMenu") then
				_menuColor.base = themeColors.green
			elseif isMenuVisible("OnlinePlayersMenu") then
				_menuColor.base = themeColors.blue
			elseif isMenuVisible("VisualMenu") then
				_menuColor.base = themeColors.white
			elseif isMenuVisible("TeleportMenu") then
				_menuColor.base = themeColors.yellow
			elseif isMenuVisible("LocalVehicleMenu") then
				_menuColor.base = themeColors.orange
			elseif isMenuVisible("LocalWepMenu") then
				_menuColor.base = themeColors.red
			elseif isMenuVisible("LuxMainMenu") then
				_menuColor.base = themeColors.purple 
			end
		end
	end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale / aspectRatio, scale)

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
	BeginTextCommandDisplayText("text_buffer")
	AddTextComponentString(text)
	EndTextCommandDisplayText(x, y)
end

local function drawPreviewText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale / aspectRatio, scale)

	if shadow then
		SetTextDropShadow(2, 2, 0, 0, 0)
	end

	if menus[currentMenu] then
		if center then
			SetTextCentre(center)
		elseif alignRight then
			local rX = menus[currentMenu].x - frameWidth / 2 - frameWidth - previewWidth / 2
			SetTextWrap(rX, rX + previewWidth / 2 - buttonTextXOffset / 2)
			SetTextRightJustify(true)
		end
	end
	BeginTextCommandDisplayText("preview_text_buffer")
	AddTextComponentString(text)
	EndTextCommandDisplayText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

-- [NOTE] MenuDrawTitle
local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2
		if menus[currentMenu].background == "default" then
			if _menuColor.base == themeColors.purple then
				drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
			else
				DrawSpriteScaled("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- 255, 76, 60,
				DrawSpriteScaled("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			end
		elseif menus[currentMenu].background == "weaponlist" then
			if _menuColor.base == themeColors.purple then
				DrawSpriteScaled("heisthud", "main_gradient", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 255, 255, 140) -- 255, 76, 60,
			else
				DrawSpriteScaled("heisthud", "main_gradient", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			end
			 -- rgb(155, 89, 182)
		elseif menus[currentMenu].titleBackgroundSprite then
			DrawSpriteScaled(
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
			drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
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

		-- Header
		drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].menuFrameColor)
		-- Separator
		drawRect(x, y + (buttonHeight / 2) + (separatorHeight / 2), menuWidth, separatorHeight, _menuColor.base)

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

local welcomeMsg = true

local function drawFooter()
	if menus[currentMenu] then
		local multiplier = nil
		local x = menus[currentMenu].x + menuWidth / 2
		-- local y = menus[currentMenu].y + titleHeight - 0.015 + buttonHeight + menus[currentMenu].maxOptionCount * buttonHeight
		-- DrawSpriteScaled("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- r = 231, g = 76, b = 60
		local footerColor = menus[currentMenu].menuFrameColor

		if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
			multiplier = optionCount
		elseif optionCount >= menus[currentMenu].currentOption then
			multiplier = 10
		end

		if multiplier then
			local y = menus[currentMenu].y + titleHeight + buttonHeight + separatorHeight + (buttonHeight * multiplier) --0.015

			-- Footer
			drawRect(x, y + (footerHeight / 2), menuWidth, footerHeight, footerColor)

			local yFrame = menus[currentMenu].y + titleHeight + ((buttonHeight + separatorHeight + (buttonHeight * multiplier) + footerHeight) / 2)
			local frameHeight = buttonHeight + separatorHeight + footerHeight + (buttonHeight * multiplier)
			-- Frame Left
			drawRect(x - menuWidth / 2, yFrame, frameWidth, frameHeight, footerColor)
			-- Frame Right
			drawRect(x + menuWidth / 2, yFrame, frameWidth, frameHeight, footerColor)

			drawText(menus[currentMenu].version, menus[currentMenu].x + buttonTextXOffset, y - separatorHeight + (footerHeight / 2 - fontHeight / 2), menus[currentMenu].titleFont, {r = 255, g = 255, b = 255, a = 128}, buttonScale, false)
			drawText(menus[currentMenu].branding, x, y - separatorHeight + (footerHeight / 2 - fontHeight / 2), menus[currentMenu].titleFont, menus[currentMenu].titleColor, buttonScale, false, false, true)
			
			local offset = 1.0 - (y + footerHeight / 2 + notifyBody.height)

			if notifyBody.footerYOffset ~= offset then
				notifyBody.footerYOffset = offset
				NotifyRecalibrate()
			end
		end

		if welcomeMsg then
			welcomeMsg = false
			LuxUI.SendNotification({text = "LUX is currently in beta! If you experience any issues, please contact leuit#0100 on Discord!", type = "info"})
		end
	end
end

local function drawButton(text, subText, color, subcolor)
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
		local y = menus[currentMenu].y + titleHeight + buttonHeight + 0.0025 + (buttonHeight * multiplier) - buttonHeight / 2 -- 0.0025 is the offset for the line under subTitle
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = color or menus[currentMenu].menuFocusTextColor
			pointColor = menus[currentMenu].menuFocusPointerColor
			subTextColor = subcolor or menus[currentMenu].menuSubTextColor
			selectionColor = { r = 255, g = 255, b = 255, a = 255 }
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = color or menus[currentMenu].menuTextColor
			pointColor = menus[currentMenu].menuInvisibleColor
			subTextColor = subcolor or menus[currentMenu].menuSubTextColor
			selectionColor = menus[currentMenu].menuInvisibleColor
			--shadow = true
		end

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

			if text == "Self Options" then
				-- w/h = 0.02
				DrawSpriteScaled("mpleaderboard", "leaderboard_players_icon", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 26, 188, 156, 255) -- rgb(26, 188, 156)
			elseif text == "Online Options" then
				DrawSpriteScaled("mpleaderboard", "leaderboard_friends_icon", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 52, 152, 219, 255) -- rgb(52, 152, 219)
			elseif text == "Visual Options" then
				DrawSpriteScaled("mphud", "spectating", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 236, 240, 241, 255) -- rgb(236, 240, 241)
			elseif text == "Teleport Options" then
				DrawSpriteScaled("mpleaderboard", "leaderboard_star_icon", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 241, 196, 15, 255) -- rgb(241, 196, 15)
			elseif text == "Vehicle Options" then
				DrawSpriteScaled("mpleaderboard", "leaderboard_transport_car_icon", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 230, 126, 34, 255) -- rgb(230, 126, 34)
			elseif text == "Weapon Options" then
				DrawSpriteScaled("mpleaderboard", "leaderboard_kd_icon", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 231, 76, 60, 255) -- rgb(231, 76, 60)
			elseif text == "Server Options" then
				DrawSpriteScaled("mpleaderboard", "leaderboard_globe_icon", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 155, 89, 182, 255) -- rgb(155, 89, 182)
			end
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

		if subText == "isMenu" then
			DrawSpriteScaled("mparrow", "mp_arrowlarge", x + menuWidth / 2.25, y, 0.008, nil, 0.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)
			-- menus[currentMenu].title = ""
		elseif subText == "isWeapon" then
			menus[currentMenu].background = "weaponlist"
			local x = menus[currentMenu].x + menuWidth / 2
			local y = menus[currentMenu].y + (titleHeight / 2)
			for hash, v in pairs(t_Weapons) do
				if text == v[1] then
					SetScriptGfxDrawOrder(50)
					DrawSpriteScaled(v[3], v[2], x, y, 0.12, nil, 0.0, selectionColor.r, selectionColor.g, selectionColor.b, selectionColor.a)
				end
			end
		elseif subText == "toggleOff" then
			x = x + menuWidth / 2 - frameWidth / 2 - toggleOuterWidth / 2 - buttonTextXOffset
			drawRect(x, y, toggleOuterWidth, toggleOuterHeight, menus[currentMenu].buttonSubBackgroundColor)
			-- drawRect(x, y, toggleInnerWidth, toggleInnerHeight, {r = 90, g = 90, b = 90, a = 230})
		elseif subText == "toggleOn" then
			x = x + menuWidth / 2 - frameWidth / 2 - toggleOuterWidth / 2 - buttonTextXOffset
			drawRect(x, y, toggleOuterWidth, toggleOuterHeight, menus[currentMenu].buttonSubBackgroundColor)
			DrawSpriteScaled("commonmenu", "shop_tick_icon", x, y, 0.020, nil, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			--drawRect(x, y, toggleInnerWidth, toggleInnerHeight, _menuColor.base) -- 26, 188, 156, 255
		elseif subText == "danger" then
			DrawSpriteScaled("commonmenu", "mp_alerttriangle", x + menuWidth / 2.35, y, 0.021, nil, 0.0, 255, 255, 255, 255)
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

local function drawComboBox(text, subText, color, subcolor)
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
		local y = menus[currentMenu].y + titleHeight + buttonHeight + 0.0025 + (buttonHeight * multiplier) - buttonHeight / 2 -- 0.0025 is the offset for the line under subTitle
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = color or menus[currentMenu].menuFocusTextColor
			pointColor = menus[currentMenu].menuFocusPointerColor
			subTextColor = subcolor or menus[currentMenu].menuSubTextColor
			selectionColor = { r = 255, g = 255, b = 255, a = 255 }
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = color or menus[currentMenu].menuTextColor
			pointColor = menus[currentMenu].menuInvisibleColor
			subTextColor = subcolor or menus[currentMenu].menuSubTextColor
			selectionColor = menus[currentMenu].menuInvisibleColor
			--shadow = true
		end

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
			
			-- menus[currentMenu].title = ""
		if subText then
			--DrawSpriteScaled("mparrow", "mp_arrowlarge", x + menuWidth / 2.25, y, 0.008, nil, 0.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)			
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

-- Invokes NotifyNewThread
function LuxUI.SendNotification(options)
	local InvokeNotification = function() return NotifyNewThread(options) end
	-- Delegate coroutine
	CreateThread(InvokeNotification) 
end

function LuxUI.CreateMenu(id, title)
	-- Default settings
	menus[id] = {}
	menus[id].title = title
	menus[id].subTitle = "MAIN MENU"
	menus[id].branding = "LUX MENU"
	menus[id].version = "v1.0b"

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.78
    menus[id].y = 0.19
    
    menus[id].width = menuWidth

	menus[id].currentOption = 1
	menus[id].storedOption = 1 -- This is used when going back to previous menu
	menus[id].maxOptionCount = 10
	menus[id].titleFont = 4
	menus[id].titleColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].background = "default"
	menus[id].titleBackgroundColor = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 180}

	
	menus[id].menuTextColor = {r = 220, g = 220, b = 220, a = 255}
	menus[id].menuSubTextColor = {r = 140, g = 140, b = 140, a = 255}
	
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuFocusBackgroundColor = {r = 23, g = 28, b = 29, a = 240} -- rgb(31, 32, 34) rgb(155, 89, 182) #9b59b6
	menus[id].menuFocusPointerColor = {r = 255, g = 255, b = 255, a = 128}

	menus[id].menuBackgroundColor = {r = 18, g = 20, b = 20, a = 240} -- #121212
	menus[id].menuFrameColor = {r = 0, g = 0, b = 0, a = 255}
	menus[id].menuInvisibleColor = { r = 0, g = 0, b = 0, a = 0 }

	menus[id].buttonSubBackgroundColor = {r = 35, g = 39, b = 40, a = 255}

	menus[id].subTitleBackgroundColor = {
		r = menus[id].menuBackgroundColor.r,
		g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b,
		a = 255
	}

	menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"} --https://pastebin.com/0neZdsZ5
end

function LuxUI.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		LuxUI.CreateMenu(id, menus[parent].title)

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
		
		setMenuProperty(id, "buttonSubBackgroundColor", menus[parent].buttonSubBackgroundColor)
	end
end

function LuxUI.CurrentMenu()
	return currentMenu
end

function LuxUI.OpenMenu(id)
	if id and menus[id] then
		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
				Citizen.Wait(0)
			end
		end
		
		setMenuVisible(id, true)
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
	end
end

function LuxUI.IsMenuOpened(id)
	return isMenuVisible(id)
end

function LuxUI.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then
			return true
		end
	end

	return false
end

function LuxUI.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end

function LuxUI.CloseMenu()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
		end
	end
end

function LuxUI.Button(text, subText, color, subcolor)

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText, color, subcolor)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				return true
			end
		end

		return false
	end

end

-- Button with a slider
function LuxUI.Slider(text, items, selectedIndex, callback, vehicleMod)
	local itemsCount = #items
	local selectedItem = items[selectedIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if vehicleMod then
		selectedIndex = selectedIndex + 2
	end

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if LuxUI.SliderInternal(text, items, itemsCount, selectedIndex) then
		callback(selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if selectedIndex > 1 then selectedIndex = selectedIndex - 1 end
		elseif currentKey == keys.right then
            if selectedIndex < itemsCount then selectedIndex = selectedIndex + 1 end
		end
	end
	
	callback(selectedIndex)
	return false
end

local function drawButtonSlider(text, items, itemsCount, selectedIndex)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil

	if (menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount) and (optionCount <= menus[currentMenu].maxOptionCount) then
		multiplier = optionCount
	elseif (optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount) and (optionCount <= menus[currentMenu].currentOption) then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + 0.0025 + (buttonHeight * multiplier) - buttonHeight / 2 -- 0.0025 is the offset for the line under subTitle
		
		local backgroundColor = menus[currentMenu].menuBackgroundColor
		local textColor = menus[currentMenu].menuTextColor
		local subTextColor = menus[currentMenu].menuSubTextColor
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		end

		local sliderColorBase = menus[currentMenu].buttonSubBackgroundColor
		local sliderColorKnob = {r = 90, g = 90, b = 90, a = 255}
		local sliderColorText = {r = 206, g = 206, b = 206, a = 200}

		if selectedIndex > 1 then
			sliderColorBase = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 50}
			sliderColorKnob = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 140}
			sliderColorText = _menuColor.base
		end

		local sliderOverlayWidth = sliderWidth / (itemsCount - 1)
		
		-- Button
		drawRect(x, y, menuWidth, buttonHeight, backgroundColor) -- Button Rectangle -2.15

		-- Button text
		drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow) -- Text

		
		-- Slider left
        drawRect(x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - sliderWidth / 2, y, sliderWidth, sliderHeight, sliderColorBase)
		-- Slider right
		drawRect(x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - (sliderOverlayWidth / 2) * (itemsCount - selectedIndex), y, sliderOverlayWidth * (itemsCount - selectedIndex), sliderHeight, menus[currentMenu].buttonSubBackgroundColor)
		-- Slider knob
		drawRect(x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - sliderWidth - (knobWidth / 2) + (sliderOverlayWidth) * (selectedIndex - 1), y, knobWidth, knobHeight, sliderColorKnob)

		-- Slider value text
		drawText(items[selectedIndex], x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - sliderWidth / 2, y + separatorHeight / 2 - (buttonHeight / 2 - sliderFontHeight / 2), buttonFont, sliderColorText, sliderFontScale, true, shadow) -- Current Item Text
	end
end

function LuxUI.SliderInternal(text, items, itemsCount, selectedIndex)
	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButtonSlider(text, items, itemsCount, selectedIndex)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		
		return false
	end
end

function LuxUI.MenuButton(text, id)
	if menus[id] then
		if LuxUI.Button(text, "isMenu") then
			setMenuVisible(id, true)
			return true
		end
	end

	return false
end

function LuxUI.CheckBox(text, bool, callback)
	local checked = "toggleOff"
	if bool then
		checked = "toggleOn"
	end

	if LuxUI.Button(text, checked) then
		bool = not bool

		callback(bool)

		return true
	end

	return false
end

function LuxUI.ComboBoxInternal(text, selectedItem)
	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawComboBox(text, selectedItem)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		
		return false
	end
end

function LuxUI.ComboBox(text, items, selectedIndex, callback, vehicleMod)
	local itemsCount = #items
	local selectedItem = items[selectedIndex]
	local selectedItemText = ''
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if selectedIndex == nil then
		callback(0)
		return false
	end

	if vehicleMod then
		selectedIndex = selectedIndex + 1
		selectedItem = items[selectedIndex]
	end


	if itemsCount > 1 and isCurrent then
		selectedItemText = "Type: " .. tostring(selectedItem)
	end

	if LuxUI.ComboBoxInternal(text, selectedItemText) then
		callback(selectedIndex, selectedItem)
		return true
	end

	if isCurrent then
		if currentKey == keys.left then
			if selectedIndex > 1 then selectedIndex = selectedIndex - 1 end
		elseif currentKey == keys.right then
			if selectedIndex < itemsCount then selectedIndex = selectedIndex + 1 end
		end
	end

	callback(selectedIndex, selectedItem)

	return false
end

local DrawPlayerInfo = {
	pedHeadshot = false,
	previous = -1,
	txd = "null",
	handle = nil,
}

function LuxUI.DrawPlayerInfo(player)
	-- Handles running code only once per user. Will run once per `SelectedPlayer` change
	if DrawPlayerInfo.currentPlayer ~= player then

		-- Current player selected
		DrawPlayerInfo.currentPlayer = player

		-- Drawing coordinates
		DrawPlayerInfo.mugshotWidth = buttonHeight / aspectRatio
		DrawPlayerInfo.mugshotHeight = DrawPlayerInfo.mugshotWidth * aspectRatio
		DrawPlayerInfo.x = menus[currentMenu].x - frameWidth / 2 - frameWidth - previewWidth / 2 
		DrawPlayerInfo.y = menus[currentMenu].y + titleHeight
		
		-- Player init
		DrawPlayerInfo.playerPed = GetPlayerPed(DrawPlayerInfo.currentPlayer)
		DrawPlayerInfo.playerName = LUX:CheckName(GetPlayerName(DrawPlayerInfo.currentPlayer))

		local function RegisterPedHandle()

			if DrawPlayerInfo.handle and IsPedheadshotValid(DrawPlayerInfo.handle) then
				UnregisterPedheadshot(DrawPlayerInfo.handle)
				DrawPlayerInfo.handle = nil
				DrawPlayerInfo.txd = "null"
			end

			-- Get the ped headshot image.
			DrawPlayerInfo.handle = RegisterPedheadshot(DrawPlayerInfo.playerPed)

			while not IsPedheadshotReady(DrawPlayerInfo.handle) or not IsPedheadshotValid(DrawPlayerInfo.handle) do
				Wait(50)
			end

			if IsPedheadshotReady(DrawPlayerInfo.handle) and IsPedheadshotValid(DrawPlayerInfo.handle) then
				DrawPlayerInfo.txd = GetPedheadshotTxdString(DrawPlayerInfo.handle)
				DrawPlayerInfo.pedHeadshot = true
				return
			else
				DrawPlayerInfo.pedHeadshot = false
				return
			end
		end
		CreateThread(RegisterPedHandle)
	end
	
	-- Pull coordinates from client (self)
	local client = GetEntityCoords(PlayerPedId())
	local cx, cy, cz = client[1], client[2], client[3]
	-- Pull coordinates from target (player)
	local target = GetEntityCoords(DrawPlayerInfo.playerPed)
	local tx, ty, tz = target[1], target[2], target[3]
	
	-- infoBox = {
	-- 	tostring("Name: " .. LUX:CheckName(GetPlayerName(data))),
	-- 	tostring("Server ID: " .. GetPlayerServerId(data)),
	-- 	tostring("Player ID: ~t~" .. GetPlayerFromServerId(GetPlayerServerId(data))),
	-- 	tostring("Distance: ~f~" .. math.round(#(vector3(cx, cy, cz) - vector3(tx, ty, tz)), 1)),
	-- 	tostring("Status: " .. (IsPedDeadOrDying(dataPed, 1) and "~r~Dead " or "~g~Alive")),
	-- 	tostring("Task: " .. LUX.Game:GetPedStatus(dataPed)),
	-- }

	-- [ NOTE ] refactor infoData into DrawPlayerInfo

	-- Define our infoData table
	local infoData = {}

	-- Get the vehicle model name instead of the label text to support custom vehicles
	local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(DrawPlayerInfo.playerPed)))
	
	-- Should work, but my local server isn't using MP peds, so I need to test once exec is updated.
	-- using `playerPed` instead of `player` for now
	local playerHealth = GetEntityHealth(DrawPlayerInfo.playerPed) - 100

	-- Update player armour every draw
	local playerArmour = GetPedArmour(DrawPlayerInfo.playerPed)

	-- Update player distance every draw
	local playerDistance = math.round(#(vector3(cx, cy, cz) - vector3(tx, ty, tz)), 1)

	-- Highlife staff query
	local highlifeRank = DecorGetInt(DrawPlayerInfo.playerPed, 'Player.Rank')

	-- Player Vehicle
	infoData[1] = {}
	infoData[1][1] = "Vehicle"
	infoData[1][2] = vehicleName == "CARNOTFOUND" and "~r~NONE" or vehicleName
	
	-- Player Health
	infoData[2] = {}
	infoData[2][1] = "Health"
	infoData[2][2] = IsPedDeadOrDying(DrawPlayerInfo.playerPed, 1) and "~r~DEAD" or playerHealth

	-- Player Armour
	infoData[3] = {}
	infoData[3][1] = "Armour"
	infoData[3][2] = playerArmour

	-- Player Distance
	infoData[4] = {}
	infoData[4][1] = "Distance"
	infoData[4][2] = playerDistance

	infoData[5] = {}
	infoData[5][1] = "Rank"
	infoData[5][2] = highlifeRank
	
	-- local infoData = {
	-- 	tostring("Name: " .. LUX:CheckName(GetPlayerName(data))),
	-- 	tostring("Server ID: " .. GetPlayerServerId(data)),
	-- 	tostring("Player ID: ~t~" .. GetPlayerFromServerId(GetPlayerServerId(data))),
	-- 	tostring("Distance: ~f~" .. math.round(#(vector3(cx, cy, cz) - vector3(tx, ty, tz)), 1)),
	-- 	tostring("Status: " .. (IsPedDeadOrDying(dataPed, 1) and "~r~Dead " or "~g~Alive")),
	-- 	tostring("Task: " .. vehicleName),
	-- }

	
	-- drawRect(DrawPlayerInfo.x, DrawPlayerInfo.y + footerHeight / 2, previewWidth, footerHeight, { r = 0, b = 0, g = 0, a = 255 })
	
	-- Header box
	drawRect(DrawPlayerInfo.x, DrawPlayerInfo.y + DrawPlayerInfo.mugshotHeight / 2, previewWidth, DrawPlayerInfo.mugshotHeight, { r = 0, g = 0, b = 0, a = 255 })
	drawText(DrawPlayerInfo.playerName, DrawPlayerInfo.x + DrawPlayerInfo.mugshotWidth + buttonTextXOffset / 2 - previewWidth / 2, DrawPlayerInfo.y - separatorHeight + (buttonHeight / 2 - fontHeight / 2), buttonFont, _menuColor.base, buttonScale, false, false)
	
	-- Ped preview
	if DrawPlayerInfo.pedHeadshot == true and IsPedheadshotValid(DrawPlayerInfo.handle) then
		DrawSprite(DrawPlayerInfo.txd, DrawPlayerInfo.txd, DrawPlayerInfo.x - previewWidth / 2 + DrawPlayerInfo.mugshotWidth / 2, DrawPlayerInfo.y + DrawPlayerInfo.mugshotHeight / 2, DrawPlayerInfo.mugshotWidth, DrawPlayerInfo.mugshotHeight, 0.0, 255, 255, 255, 255)
	end
	
	-- Separator
	drawRect(DrawPlayerInfo.x, DrawPlayerInfo.y + DrawPlayerInfo.mugshotHeight + separatorHeight / 2, previewWidth, separatorHeight, _menuColor.base)
	
	-- Content
	for i = 1, #infoData do
		local multiplier = i
		local text = infoData[i]
		-- Draw content background
		drawRect(DrawPlayerInfo.x, DrawPlayerInfo.y + buttonHeight + separatorHeight + footerHeight * multiplier - footerHeight / 2, previewWidth, footerHeight, menus[currentMenu].menuBackgroundColor)
		-- Draw info title (left)
		drawText(text[1], DrawPlayerInfo.x - previewWidth / 2 + buttonTextXOffset / 2, DrawPlayerInfo.y + buttonHeight + separatorHeight + footerHeight * (multiplier - 1) - separatorHeight + (footerHeight / 2 - fontHeight / 2), buttonFont, menus[currentMenu].menuTextColor, buttonScale, false, false)
		-- Draw info description (right)
		drawPreviewText(tostring(text[2]), DrawPlayerInfo.x + buttonTextXOffset, DrawPlayerInfo.y + buttonHeight + separatorHeight + footerHeight * (multiplier - 1) - separatorHeight + (footerHeight / 2 - fontHeight / 2), buttonFont, menus[currentMenu].menuTextColor, buttonScale, false, false, true)
		
	end

end

function LuxUI.DrawVehiclePreview(vehClass)
	local previewX = menus[currentMenu].x - frameWidth / 2
	local previewY = menus[currentMenu].y + titleHeight / 2 + previewWidth
	local class = VehicleClass[vehClass]
	local index = menus[currentMenu].currentOption
	
	if class and index then
		RequestStreamedTextureDict(class[index][2])
		if HasStreamedTextureDictLoaded(class[index][2]) then
			DrawSpriteScaled(class[index][2], class[index][3] or class[index][1], (previewX - previewWidth / 2) - frameWidth, previewY, 0.1, nil, 0.0, 255, 255, 255, 255)
		end
		drawRect((previewX - previewWidth / 2) - frameWidth, previewY + previewWidth / 3 + footerHeight, previewWidth, footerHeight, menus[currentMenu].menuFrameColor)
	end
end

function LuxUI.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			LuxUI.CloseMenu()
		else
			SetScriptGfxDrawOrder(15)
			-- drawTitle()
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
					setMenuVisible(menus[currentMenu].previousMenu, true, true)
				else
					LuxUI.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function LuxUI.SetMenuWidth(id, width)
	setMenuProperty(id, "width", width)
end

function LuxUI.SetMenuX(id, x)
	setMenuProperty(id, "x", x)
end

function LuxUI.SetMenuY(id, y)
	setMenuProperty(id, "y", y)
end

function LuxUI.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, "maxOptionCount", count)
end

function LuxUI.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end

function LuxUI.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"titleBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
	)
end

function LuxUI.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end

function LuxUI.SetSubTitle(id, text)
	setMenuProperty(id, "subTitle", string.upper(text))
end

function LuxUI.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"menuBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
	)
end

function LuxUI.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end

function LuxUI.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
end

function LuxUI.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end

function LuxUI.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
end

local function KeyboardInput(title, initialText, bufferSize)
	local editing, finished, cancelled, notActive = 0, 1, 2, 3

	BeginTextCommandDisplayText("keyboard_title_buffer")
	AddTextComponentSubstringPlayerName(title)
	EndTextCommandDisplayText(0, 0)
	DisplayOnscreenKeyboard(false, "keyboard_title_buffer", "", initialText, "", "", "", bufferSize)

	while UpdateOnscreenKeyboard() == editing do
		HideHudAndRadarThisFrame()
		Wait(0)
	end

	if GetOnscreenKeyboardResult() then return GetOnscreenKeyboardResult() end
	
end

local function DrawText3D(x, y, z, text, r, g, b)
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
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

local function DrawText3DFill(x, y, z, text, r, g, b)
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
	EndTextCommandDisplayText(0.0, 0.0)
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
		LuxUI.SendNotification({text = "You must place a waypoint", type = 'error'})
	end
end

local Spectating = false

local function SpectatePlayer(player)

	Spectating = not Spectating

	local targetPed = GetPlayerPed(player)

	if (Spectating) then
		RequestCollisionAtCoord(GetEntityCoords(targetPed, false))
		NetworkSetInSpectatorMode(true, targetPed)

		--LuxUI.SendNotification("Started spectating ~b~" .. GetPlayerName(player))
	else
		RequestCollisionAtCoord(GetEntityCoords(targetPed, false))
		NetworkSetInSpectatorMode(false, targetPed)

		--LuxUI.SendNotification("Stopped spectating ~b~" .. GetPlayerName(player))
	end
end

function ShootPlayer(player)
	local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(), head.x, head.y, head.z, true)
end

local Vehicle = {}

function Vehicle.MaxTuning(vehicle)
	SetVehicleModKit(0) -- This needs to be set to unlock modification


	SetVehicleMod(vehicle, tuneMods["Engine"], GetNumVehicleMods(vehicle, tuneMods["Engine"]) - 1)
end

function DelVeh(veh)
	SetEntityAsMissionEntity(Object, 1, 1)
	DeleteEntity(Object)
	SetEntityAsMissionEntity(GetVehiclePedIsIn(PlayerPedId(), false), 1, 1)
	DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
end

function Clean(veh)
	SetVehicleDirtLevel(veh, 15.0)
end

function Clean2(veh)
	SetVehicleDirtLevel(veh, 1.0)
end


local entityEnumerator = {
	__gc = function(enum)
	  	if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
	  	end
	  	enum.destructor = nil
	  	enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
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

local function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

local function RequestControl(entity)
	local Waiting = 0
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) do
		Waiting = Waiting + 100
		Citizen.Wait(100)
		if Waiting > 5000 then
			LuxUI.SendNotification("Hung for 5 seconds, killing to prevent issues...")
		end
	end
end

local function getEntity(player)
	local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
	return entity
end

-- Thread that handles all menu toggles (Godmode, ESP, etc)
local function MenuToggleThread()
	while isMenuEnabled do
		-- Radar/showMinimap
		DisplayRadar(showMinimap, 1)
		LUX.Player.inVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)

		SetPlayerInvincible(PlayerId(), Godmode)
		SetEntityInvincible(PlayerPedId(), Godmode)

		SetEntityVisible(PlayerPedId(), not Invisible, 0)

		SetPedCanRagdoll(PlayerPedId(), not RagdollToggle)

		if Crosshair then
			ShowHudComponentThisFrame(14)
		end

		if playerBlips then
			-- show blips
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				local ped = GetPlayerPed(id)
				if ped ~= PlayerPedId() then
					local blip = GetBlipFromEntity(ped)

					-- HEAD DISPLAY STUFF --

					-- Create head display (this is safe to be spammed)
					-- headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )

					-- Speaking display
					-- I need to move this over to name tag code
					-- if NetworkIsPlayerTalking(id) then
					-- 	Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, true ) -- Add speaking sprite
					-- else
					-- 	Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, false ) -- Remove speaking sprite
					-- end

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
							x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
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
		end

		if showNametags then
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
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

		if SuperJump then
			SetSuperJumpThisFrame(PlayerId())
		end

		if InfStamina then
			RestorePlayerStamina(PlayerId(), 1.0)
		end

		SetRunSprintMultiplierForPlayer(PlayerId(), FastCB[selFastRunIndex])
		SetPedMoveRateOverride(PlayerPedId(), FastCB[selFastRunIndex])

		if VehicleGun then
			local VehicleGunVehicle = "Freight"
			local playerPedPos = GetEntityCoords(PlayerPedId(), true)
			if (IsPedInAnyVehicle(PlayerPedId(), true) == false) then
				GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
				SetPedAmmo(PlayerPedId(), GetHashKey("WEAPON_APPISTOL"), 999999)
				if (GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_APPISTOL")) then
					if IsPedShooting(PlayerPedId()) then
						while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
							Citizen.Wait(0)
							RequestModel(GetHashKey(VehicleGunVehicle))
						end
						local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(PlayerPedId())), playerPedPos.y + (5 * GetEntityForwardY(PlayerPedId())), playerPedPos.z + 2.0, GetEntityHeading(PlayerPedId()), true, true)
						SetEntityAsNoLongerNeeded(veh)
						SetVehicleForwardSpeed(veh, 150.0)
					end
				end
			end
		end

		if DeleteGun then
			local gotEntity = getEntity(PlayerId())
			if (IsPedInAnyVehicle(PlayerPedId(), true) == false) then
				LuxUI.SendNotification("~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!")
				GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_PISTOL"), 999999, false, true)
				SetPedAmmo(PlayerPedId(), GetHashKey("WEAPON_PISTOL"), 999999)
				if (GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_PISTOL")) then
					if IsPlayerFreeAiming(PlayerId()) then
						if IsEntityAPed(gotEntity) then
							if IsPedInAnyVehicle(gotEntity, true) then
								if IsControlJustReleased(1, 142) then
									SetEntityAsMissionEntity(GetVehiclePedIsIn(gotEntity, true), 1, 1)
									DeleteEntity(GetVehiclePedIsIn(gotEntity, true))
									SetEntityAsMissionEntity(gotEntity, 1, 1)
									DeleteEntity(gotEntity)
									LuxUI.SendNotification("~g~Deleted!") -- (icon, type, sender, text)
								end
							else
								if IsControlJustReleased(1, 142) then
									SetEntityAsMissionEntity(gotEntity, 1, 1)
									DeleteEntity(gotEntity)
									LuxUI.SendNotification("~g~Deleted!")
								end
							end
						else
							if IsControlJustReleased(1, 142) then
								SetEntityAsMissionEntity(gotEntity, 1, 1)
								DeleteEntity(gotEntity)
								LuxUI.SendNotification("~g~Deleted!")
							end
						end
					end
				end
			end
		end

		if destroyvehicles then
			for vehicle in EnumerateVehicles() do
				if (vehicle ~= GetVehiclePedIsIn(PlayerPedId(), false)) then
					NetworkRequestControlOfEntity(vehicle)
					SetVehicleUndriveable(vehicle,true)
					SetVehicleEngineHealth(vehicle, 100)
				end
			end
		end


		if explodevehicles then
			for vehicle in EnumerateVehicles() do
				if (vehicle ~= GetVehiclePedIsIn(PlayerPedId(), false)) then
					NetworkRequestControlOfEntity(vehicle)
					NetworkExplodeVehicle(vehicle, true, true, false)
				end
			end
		end

		if esp then
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				if id ~= PlayerId() and GetPlayerServerId(id) ~= 0 then
					local ra = {r = 255, g = 255, b = 255, a = 255}
					local pPed = GetPlayerPed(id)
					local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
					local x, y, z = table.unpack(GetEntityCoords(pPed))
					local message = 
						"Name: \t\t" .. GetPlayerName(id) ..
						"\nServer ID: \t" .. GetPlayerServerId(id) ..
						"\nPlayer ID: \t" .. id .. 
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
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
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
				NoclipSpeed = NoclipSpeed * 5
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
		
		Citizen.Wait(0)
	end
end
CreateThread(MenuToggleThread)


-- Menu runtime for drawing and handling input
local function MenuRuntimeThread()
	FreezeEntityPosition(entity, false)
	local currentItemIndex = 1
	local selectedItemIndex = 1

	-- MAIN MENU
	LuxUI.CreateMenu("LuxMainMenu", "LUX MENU")
	LuxUI.SetSubTitle("LuxMainMenu", "Main Menu")

	-- MAIN MENU CATEGORIES
	LuxUI.CreateSubMenu("SelfMenu", "LuxMainMenu", "Self Options")
	LuxUI.CreateSubMenu('OnlinePlayersMenu', 'LuxMainMenu', "Online Options")
	LuxUI.CreateSubMenu("VisualMenu", "LuxMainMenu", "Visual Options")
	LuxUI.CreateSubMenu("TeleportMenu", "LuxMainMenu", "Teleport Menu")
	
	-- MAIN MENU > Vehicle Options
	LuxUI.CreateSubMenu("LocalVehicleMenu", "LuxMainMenu", "Vehicle Options")
	-- MAIN MENU > Vehicle Options > Vehicle Spawner
	LuxUI.CreateSubMenu("LocalVehicleSpawner", "LocalVehicleMenu", "Vehicle Spawner")
	-- MAIN MENU > Vehicle Options > Vehicle Spawner > $class
	LuxUI.CreateSubMenu("localcompacts", "LocalVehicleSpawner", "Compacts")
	LuxUI.CreateSubMenu("localsedans", "LocalVehicleSpawner", "Sedans")
	LuxUI.CreateSubMenu("localsuvs", "LocalVehicleSpawner", "SUVs")
	LuxUI.CreateSubMenu("localcoupes", "LocalVehicleSpawner", "Coupes")
	LuxUI.CreateSubMenu("localmuscle", "LocalVehicleSpawner", "Muscle")
	LuxUI.CreateSubMenu("localsportsclassics", "LocalVehicleSpawner", "Sports Classics")
	LuxUI.CreateSubMenu("localsports", "LocalVehicleSpawner", "Sports")
	LuxUI.CreateSubMenu("localsuper", "LocalVehicleSpawner", "Super")
	LuxUI.CreateSubMenu("localmotorcycles", "LocalVehicleSpawner", "Motorcycles")
	LuxUI.CreateSubMenu("localoffroad", "LocalVehicleSpawner", "Off-Road")
	LuxUI.CreateSubMenu("localindustrial", "LocalVehicleSpawner", "Industrial")
	LuxUI.CreateSubMenu("localutility", "LocalVehicleSpawner", "Utility")
	LuxUI.CreateSubMenu("localvans", "LocalVehicleSpawner", "Vans")
	LuxUI.CreateSubMenu("localcycles", "LocalVehicleSpawner", "Cycles")
	LuxUI.CreateSubMenu("localboats", "LocalVehicleSpawner", "Boats")
	LuxUI.CreateSubMenu("localhelicopters", "LocalVehicleSpawner", "Helicopters")
	LuxUI.CreateSubMenu("localplanes", "LocalVehicleSpawner", "Planes")
	LuxUI.CreateSubMenu("localservice", "LocalVehicleSpawner", "Service")
	LuxUI.CreateSubMenu("localcommercial", "LocalVehicleSpawner", "Commercial")
	
	LuxUI.CreateSubMenu("LocalWepMenu", "LuxMainMenu", "Weapon Options")
	LuxUI.CreateSubMenu("ServerMenu", "LuxMainMenu", "Server Menu")
	LuxUI.CreateSubMenu("Griefer", "LuxMainMenu", "Griefer Options")
	LuxUI.CreateSubMenu("MenuSettings", "LuxMainMenu", "Menu Settings")
	
	LuxUI.CreateSubMenu('LSC', 'LocalVehicleMenu', "Los Santos Customs")
	LuxUI.CreateSubMenu('lsc_bodywork', 'LSC', 'Bodywork')
	LuxUI.CreateSubMenu('lsc_performance', 'LSC', 'Performance Tuning')

	-- ONLINE PLAYERS MENU
	LuxUI.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayersMenu', "Player Options")
	
	-- ONLINE PLAYERS > PLAYER > WEAPON OPTIONS MENU
	LuxUI.CreateSubMenu('OnlineWepMenu', 'PlayerOptionsMenu', 'Weapon Menu')
	LuxUI.CreateSubMenu('OnlineWepCategory', 'OnlineWepMenu', 'Give Weapon')
	LuxUI.CreateSubMenu("OnlineMeleeWeapons", "OnlineWepCategory", "Melee Weapons")
	LuxUI.CreateSubMenu("OnlineSidearmWeapons", "OnlineWepCategory", "Sidearms")
	LuxUI.CreateSubMenu("OnlineAutorifleWeapons", "OnlineWepCategory", "Automatic Rifles")
	LuxUI.CreateSubMenu("OnlineShotgunWeapons", "OnlineWepCategory", "Shotguns")
	
	
	LuxUI.CreateSubMenu('OnlineVehicleMenuPlayer', 'PlayerOptionsMenu', "Vehicle Options")
	LuxUI.CreateSubMenu('ESXMenuPlayer', 'PlayerOptionsMenu', "ESX Options")

	LuxUI.CreateSubMenu("LocalWepCategory", "LocalWepMenu", "Give Weapon")
	LuxUI.CreateSubMenu("LocalMeleeWeapons", "LocalWepCategory", "Melee Weapons")
	LuxUI.CreateSubMenu("LocalSidearmWeapons", "LocalWepCategory", "Sidearms")
	LuxUI.CreateSubMenu("LocalAutorifleWeapons", "LocalWepCategory", "Automatic Rifles")
	LuxUI.CreateSubMenu("LocalShotgunWeapons", "LocalWepCategory", "Shotguns")
	LuxUI.CreateSubMenu("LocalSmgWeapons", "LocalWepCategory", "SMGs/LMGs")
	
	LuxUI.CreateSubMenu("ServerResources", "ServerMenu", "Server Resources")
	LuxUI.CreateSubMenu('ResourceData', "ServerResources", "Resource Data")
	LuxUI.CreateSubMenu('ResourceCEvents', 'ResourceData', 'Event Handlers')
	LuxUI.CreateSubMenu('ResourceSEvents', 'ResourceData', 'Server Events')
	LuxUI.CreateSubMenu("ESXBoss", "ServerMenu", "ESX Boss Menus")
	LuxUI.CreateSubMenu("ESXMoney", "ServerMenu", "ESX Money Options")
	LuxUI.CreateSubMenu("ESXMisc", "ServerMenu", "ESX Misc Options")
	LuxUI.CreateSubMenu("ESXDrugs", "ServerMenu", "ESX Drugs")
	LuxUI.CreateSubMenu("MiscServerOptions", "ServerMenu", "Misc Server Options")
	LuxUI.CreateSubMenu("VRPOptions", "ServerMenu", "VRP Server Options")
	
	LuxUI.CreateSubMenu("MenuSettingsColor", "MenuSettings", "Change Menu Color")
	LuxUI.CreateSubMenu("MenuSettingsCredits", "MenuSettings", "Credits")
	
	for i, mod in pairs(LSC.vehicleMods) do
		LuxUI.CreateSubMenu(mod.meta, 'lsc_bodywork', mod.name)

		if mod.id == "paint" then
			LuxUI.CreateSubMenu("primary", mod.id, "Primary Paint")
			LuxUI.CreateSubMenu("secondary", mod.id, "Secondary Paint")

			LuxUI.CreateSubMenu("rimpaint", mod.id, "Wheel Paint")

			LuxUI.CreateSubMenu("classic1", "primary", "Classic Paint")
			LuxUI.CreateSubMenu("metallic1", "primary", "Metallic Paint")
			LuxUI.CreateSubMenu("matte1", "primary", "Matte Paint")
			LuxUI.CreateSubMenu("metal1", "primary", "Metal Paint")
			LuxUI.CreateSubMenu("classic2", "secondary", "Classic Paint")
			LuxUI.CreateSubMenu("metallic2", "secondary", "Metallic Paint")
			LuxUI.CreateSubMenu("matte2", "secondary", "Matte Paint")
			LuxUI.CreateSubMenu("metal2", "secondary", "Metal Paint")

			LuxUI.CreateSubMenu("classic3", "rimpaint", "Classic Paint")
			LuxUI.CreateSubMenu("metallic3", "rimpaint", "Metallic Paint")
			LuxUI.CreateSubMenu("matte3", "rimpaint", "Matte Paint")
			LuxUI.CreateSubMenu("metal3", "rimpaint", "Metal Paint")

		end
	end

	local SelectedPlayer = nil
	local SelectedResource = nil

	while isMenuEnabled do
		ped = PlayerPedId()
		LUX.Player.Vehicle = GetVehiclePedIsUsing(ped)

		if IsDisabledControlJustPressed(0, LUX.Keys["DELETE"]) then
			--GateKeep()
			LuxUI.OpenMenu("LuxMainMenu")
		end

		if LuxUI.IsMenuOpened("LuxMainMenu") then
			if LuxUI.MenuButton("Self Options", "SelfMenu") then end
			if LuxUI.MenuButton("Online Options", "OnlinePlayersMenu") then end
			if LuxUI.MenuButton("Visual Options", "VisualMenu") then end
			if LuxUI.MenuButton("Teleport Options", "TeleportMenu") then end
			if LuxUI.MenuButton("Vehicle Options", "LocalVehicleMenu") then end
			if LuxUI.MenuButton("Weapon Options", "LocalWepMenu") then end
			if LuxUI.MenuButton("Server Options", "ServerMenu") then end
			if LuxUI.MenuButton("~r~Grief Menu", "LuxMainMenu") then end
			if LuxUI.MenuButton("~b~Menu Settings", "MenuSettings") then end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("SelfMenu") then

			if LuxUI.Button("Max Health") then
				SetEntityHealth(PlayerPedId(), 200)
			end
			
			if LuxUI.Button("Max Armour") then
				SetPedArmour(PlayerPedId(), 200)
			end

			if LuxUI.Button("Suicide") then
				KillYourself()
			end

			if LuxUI.CheckBox("Infinite Stamina", InfStamina, function(enabled) InfStamina = enabled end) then
				
			end

			if LuxUI.CheckBox("No Ragdoll", RagdollToggle, function(enabled) RagdollToggle = enabled end) then end
			
			if LuxUI.Slider("Move Speed", FastCBWords, selFastRunIndex, function(selectedIndex)
				if selFastRunIndex ~= selectedIndex then 
					selFastRunIndex = selectedIndex
				end
			end) then end
			
			if LuxUI.CheckBox("~r~Godmode", Godmode, function(enabled) Godmode = enabled end) then

			end

			if LuxUI.CheckBox("~r~Super Jump", SuperJump, function(enabled) SuperJump = enabled end) then

			end

			if LuxUI.CheckBox("~r~Invisible", Invisible, function(enabled) Invisible = enabled end) then

			end

			if LuxUI.CheckBox("~r~Noclip", LUX.Player.isNoclipping, function(enabled) 
				LUX.Player.isNoclipping = enabled 
				if LUX.Player.isNoclipping then
					SetEntityVisible(PlayerPedId(), false, false)
				else
					SetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), 0), GetGameplayCamRot(2), 2, 1)
					SetEntityVisible(GetVehiclePedIsIn(PlayerPedId(), 0), true, false)
					SetEntityVisible(PlayerPedId(), true, false)
				end
			end) then end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("TeleportMenu") then
			if LuxUI.Button("Teleport to waypoint") then
				TeleportToWaypoint()
			 end
	
			 LuxUI.Display()
		elseif LuxUI.IsMenuOpened("VisualMenu") then
			-- if
			-- 	LuxUI.CheckBox(
			-- 	"TriggerBot",
			-- 	TriggerBot,
			-- 	function(enabled)
			-- 	TriggerBot = enabled
			-- 	end)
			-- then
			-- elseif
			-- 	LuxUI.CheckBox(
			-- 	"AimBot",
			-- 	AimBot,
			-- 	function(enabled)
			-- 	AimBot = enabled
			-- 	end)
			-- then

			if LuxUI.CheckBox("ESP", esp, function(enabled) esp = enabled end) then end
			if LuxUI.CheckBox("Force Crosshair", Crosshair, function(enabled) Crosshair = enabled end) then end
			if LuxUI.CheckBox("Force Minimap", showMinimap, function(enabled) showMinimap = enabled end) then end
			if LuxUI.CheckBox("Force Player Blips", playerBlips, function(enabled) playerBlips = enabled end) then end
			if LuxUI.CheckBox("Force Gamertags", showNametags, function(enabled) showNametags = enabled end) then end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("Griefer") then
			
			if
				LuxUI.CheckBox(
				"~r~Explode All",
				blowall,
				function(enabled)
				blowall = enabled
				end)
			then
			elseif
				LuxUI.CheckBox(
				"~r~Overload Client Stream",
				nuke,
				function(enabled)
				nuke = enabled
				end)
			then
			elseif
				LuxUI.CheckBox(
				"~r~Trigger Malicious ESX",
				esxdestroy,
				function(enabled)
				esxdestroy = enabled
				end)
			then
			elseif
				LuxUI.CheckBox(
				"~r~Crash Server/Clients",
				servercrasher,
				function(enabled)
				servercrasher = enabled
				end)
			then
			end
			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalWepMenu") then
			if LuxUI.MenuButton("Spawn Weapon", "LocalWepCategory") then
			end

			if LuxUI.Button("~g~Give All Weapons") then
				for hash, v in pairs(t_Weapons) do
					PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 256, false, false)
				end
			end
			
			if LuxUI.Button("~r~Remove All Weapons") then
				for hash, v in pairs(t_Weapons) do
					RemoveWeaponFromPed(PlayerPedId(), GetHashKey(hash))
				end
			end

			if LuxUI.Button("Remove all weapons from everyone") then
				local plist = GetActivePlayers()
				for i = 1, #plist do
					local id = plist[i]
					for hash, v in pairs(t_Weapons) do
						RemoveWeaponFromPed(GetPlayerPed(id), GetHashKey(hash))
					end
				end
			end

			if LuxUI.Button("Set current weapon ammo") then
				local _, weaponHash = GetCurrentPedWeapon(PlayerPedId())
				local amount = KeyboardInput("Ammo amount", "", 3)
				local ammo = floor(tonumber(amount) + 0.5)
				SetPedAmmo(PlayerPedId(), weaponHash, ammo)
			end

			if LuxUI.CheckBox("Infinite Ammo", InfAmmo, function(enabled) InfAmmo = enabled SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo) end) then end	
			if LuxUI.CheckBox("Vehicle Gun", VehicleGun, function(enabled) VehicleGun = enabled end) then end		
			if LuxUI.CheckBox("Delete Gun", DeleteGun, function(enabled)DeleteGun = enabled end) then end

			LuxUI.Display()
			-- [NOTE] Local Weapon Menu
		elseif LuxUI.IsMenuOpened("LocalWepCategory") then
			LuxUI.MenuButton("Melee Weapons", "LocalMeleeWeapons")
			LuxUI.MenuButton("Sidearms", "LocalSidearmWeapons")
			LuxUI.MenuButton("Auto Rifles", "LocalAutorifleWeapons")
			LuxUI.MenuButton("Shotguns", "LocalShotgunWeapons")
			LuxUI.MenuButton("SMGs/LMGs", "LocalSmgWeapons")

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalMeleeWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_me" then
					if LuxUI.Button(v[1], "isWeapon") then
						PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 0, false, false)
					end
				end
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalSidearmWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_hg" then
					if LuxUI.Button(v[1], "isWeapon") then
						PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 32, false, false)
					end
				end
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalAutorifleWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_ar" then
					if LuxUI.Button(v[1], "isWeapon") then
						PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 60, false, false)
					end
				end
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalShotgunWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_sg" then
					if LuxUI.Button(v[1], "isWeapon") then
						PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 18, false, false)
					end
				end
			end

			LuxUI.Display()	
		elseif LuxUI.IsMenuOpened("LocalSmgWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_sb" then
					if LuxUI.Button(v[1], "isWeapon") then
						PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), GetHashKey(hash), 60, false, false)
					end
				end
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalVehicleMenu") then

			if LuxUI.MenuButton("Vehicle Spawner", "LocalVehicleSpawner") then
			end
			if LuxUI.Button("Repair Vehicle") then
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
				SetVehicleFixed(vehicle)
				SetVehicleLights(vehicle, 0)
				SetVehicleBurnout(vehicle, false)
				SetVehicleLightsMode(vehicle, 0)
			end
			if LuxUI.Button("Delete Vehicle") then
				if LUX.Player.inVehicle then
					DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
				else
					LuxUI.SendNotification({text = "You must be in a vehicle", type = "error"})
				end
			end
			if LuxUI.Button("ESX Give Ownership") then
				if LUX.Player.inVehicle then
					local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
					SetVehicleNumberPlateText(vehicle, exports.esx_vehicleshop:GeneratePlate())
					local vehicleProps = LUX.Game.GetVehicleProperties(vehicle)
					TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicleProps)
					--TriggerServerEvent('esx_givecarkeys:setVehicleOwned', vehicleProps)
				else
					LuxUI.SendNotification({text = "You must be in a vehicle", type = "error"})
				end
			end
			if LuxUI.Button("ESX Sell Vehicle") then
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
				local vehicleProps = LUX.Game.GetVehicleProperties(vehicle)
				ESX.TriggerServerCallback('esx_vehicleshop:resellVehicle', function(vehicleSold)

					if vehicleSold then
						ESX.Game.DeleteVehicle(vehicle)
						ESX.ShowNotification("Vehicle sold")
					else
						ESX.ShowNotification("Nacho Vehicle")
					end

				end, vehicleProps.plate, vehicleProps.model)
			end
			if LuxUI.MenuButton("LS Customs", "LSC") then end
			if LuxUI.Button("Flip Vehicle") then
				local playerPed = PlayerPedId()
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				if IsPedInAnyVehicle(PlayerPedId(), 0) then
					if (GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), 0), -1) == PlayerPedId()) then
						SetVehicleOnGroundProperly(playerVeh)
						--LuxUI.SendNotification({text = "Your vehicle was flipped", type = 'success'})
					else
						LuxUI.SendNotification({text = "You must be the driver of the vehicle", type = 'error'})
					end
				else
					LuxUI.SendNotification({text = "You must be in a vehicle to flip", type = 'error'})
				end
			end
			if LuxUI.Button("Change License Plate") then
				local playerPed = PlayerPedId()
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				local result = KeyboardInput("Enter new plate text", "", 8)
				if result then
					SetVehicleNumberPlateText(playerVeh, result)
				end
			end
			if LuxUI.Button("Max Tuning") then
				Vehicle.MaxTuning(GetVehiclePedIsUsing(PlayerPedId()))
			end
			if LuxUI.CheckBox("Rainbow Vehicle Colour", RainbowVeh, function(enabled) RainbowVeh = enabled end) then 
			end
			if LuxUI.CheckBox("Ghetto Police Car", ghettopolice, function(enabled) ghettopolice = enabled end) then
			end
			if LuxUI.Button("Make vehicle dirty") then
				SetVehicleDirtLevel(GetVehiclePedIsIn(PlayerPedId(), false), 0.0)
				Clean(GetVehiclePedIsUsing(PlayerPedId()))
				LuxUI.SendNotification("Vehicle is now dirty")
			end
			if LuxUI.Button("Make vehicle clean") then
				Clean2(GetVehiclePedIsUsing(PlayerPedId()))
				LuxUI.SendNotification("Vehicle is now clean")
			end
			if LuxUI.CheckBox("Seatbelt", Seatbelt, 
					function(enabled) 
						Seatbelt = enabled 
						SetPedCanBeKnockedOffVehicle(PlayerPedId(), Seatbelt) 
					end) 
				then
			end
			if LuxUI.CheckBox("Vehicle Godmode", VehGod,
					function(enabled)
						VehGod = enabled
					end) 
				then
			end
			if LuxUI.CheckBox("Speedboost ~g~SHIFT ~r~CTRL", VehSpeed,
					function(enabled)
					VehSpeed = enabled
					end)
				then
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LocalVehicleSpawner") then
			if LuxUI.Button("Spawn Vehicle by Hash") then
				local modelName = KeyboardInput("Enter vehicle spawn name", "", 12)
				if not modelName then -- Do nothing in case of accidentel press or change of mind
				elseif IsModelValid(modelName) and IsModelAVehicle(modelName) then
					RequestModel(modelName)

					while not HasModelLoaded(modelName) do
						Wait(100)
					end

					local vehicle = CreateVehicle(GetHashKey(modelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, false)

					SetPedIntoVehicle(PlayerPedId(), vehicle, -1)

					SetEntityAsNoLongerNeeded(vehicle)

					SetModelAsNoLongerNeeded(modelName)
				else
					LuxUI.SendNotification({text = string.format("~o~%s ~s~is not a valid vehicle", modelName), type = 'error'})
				end
			end
			if LuxUI.MenuButton("Compacts", "localcompacts") then end
			if LuxUI.MenuButton("Sedans", "localsedans") then end
			if LuxUI.MenuButton("SUVs", "localsuvs") then end
			if LuxUI.MenuButton("Coupes", 'localcoupes') then end
			if LuxUI.MenuButton("Muscle", 'localmuscle') then end
			if LuxUI.MenuButton("Sports Classics", 'localsportsclassics') then end
			if LuxUI.MenuButton("Sports", 'localsports') then end
			if LuxUI.MenuButton("Super", 'localsuper') then end
			if LuxUI.MenuButton('Motorcycles', 'localmotorcycles') then end
			if LuxUI.MenuButton('Off-Road', 'localoffroad') then end
			if LuxUI.MenuButton('Industrial', 'localindustrial') then end
			if LuxUI.MenuButton('Utility', 'localutility') then end
			if LuxUI.MenuButton('Vans', 'localvans') then end
			if LuxUI.MenuButton('Cycles', 'localcycles') then end
			if LuxUI.MenuButton('Boats', 'localboats') then end
			if LuxUI.MenuButton('Helicopters', 'localhelicopters') then end
			if LuxUI.MenuButton('Planes', 'localplanes') then end
			if LuxUI.MenuButton('Service/Emergency/Military', 'localservice') then end
			if LuxUI.MenuButton('Commercial/Trains', 'localcommercial') then end
			--LuxUI.DrawVehiclePreview()
			LuxUI.Display()
		elseif LuxUI.IsMenuOpened('localcompacts') then
			for i = 1, #VehicleClass.compacts do
				local modelName = VehicleClass.compacts[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if LuxUI.Button(vehname) then
					SpawnLocalVehicle(modelName)
				end
			end

			LuxUI.DrawVehiclePreview('compacts')
			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("LSC") then
			if LUX.Player.inVehicle then
				if LuxUI.MenuButton("Bodywork", "lsc_bodywork") then
					LSC.UpdateMods()
				end
				if LuxUI.MenuButton("Performance Tuning", "lsc_performance") then
					LSC.UpdateMods()
				end
			else
				if LuxUI.Button("No vehicle found") then
				end
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("lsc_bodywork") then
			local installed = currentMods
			if LUX.Player.inVehicle then
				for i, type in pairs(LSC.vehicleMods) do
					SetVehicleModKit(LUX.Player.Vehicle, 0)
					local modCount = GetNumVehicleMods(LUX.Player.Vehicle, type.id)
					if modCount > 0 then
						if type.meta == "modFrontWheels" or type.meta == "modBackWheels" then
							if LuxUI.ComboBox(type.name, LSC.WheelType, installed['wheels'], function(selectedIndex, selectedItem)
								selectedIndex = selectedIndex - 1
								installed['wheels'] = selectedIndex
								SetVehicleWheelType(LUX.Player.Vehicle, selectedIndex)
								LuxUI.SetSubTitle(type.meta, selectedItem .. " Wheels")
							end, true) then
								if modCount > 0 then
									setMenuVisible(type.meta, true)
								end
							end
						else
							if LuxUI.MenuButton(type.name, type.meta) then end
						end
					end
				end
			else
				if LuxUI.Button("No vehicle found") then
				end
			end
			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("lsc_performance") then
			local installed = currentMods
			if LUX.Player.inVehicle then
				SetVehicleModKit(LUX.Player.Vehicle, 0)
				for i, type in pairs(LSC.perfMods) do
					local modCount = GetNumVehicleMods(LUX.Player.Vehicle, type.id)
					if modCount > 0 then
						if LuxUI.Slider(type.name, VehicleUpgradeWords[modCount], installed[type.meta], function(selectedIndex)
							selectedIndex = selectedIndex - 2
							installed[type.meta] = selectedIndex
							SetVehicleMod(LUX.Player.Vehicle, type.id, selectedIndex, false)
						end, true) then end
					end
				end

				if LuxUI.CheckBox("Turbo", installed['modTurbo'], function(enabled)
					installed['modTurbo'] = enabled
					ToggleVehicleMod(LUX.Player.Vehicle, 18, enabled)
				end) then end
			else
				if LuxUI.Button("No vehicle found") then
				end
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("ServerMenu") then
			if LuxUI.MenuButton("Resource List", "ServerResources") then end
			if LuxUI.MenuButton("ESX Boss Options", "ESXBoss") then end
			if LuxUI.MenuButton("ESX Money Options", "ESXMoney") then end
			if LuxUI.MenuButton("ESX Misc Options", "ESXMisc") then end
			if LuxUI.MenuButton("ESX Drug Options", "ESXDrugs") then end
			if LuxUI.MenuButton("VRP Options", "VRPOptions") then end
			if LuxUI.MenuButton("Misc Options", "MiscServerOptions") then end

			LuxUI.Display()
			
		elseif LuxUI.IsMenuOpened("MenuSettings") then
			if LuxUI.MenuButton("Change Color Theme", "MenuSettingsColor") then
			end
			if LuxUI.MenuButton("Credits", "MenuSettingsCredits") then
			end
			if LuxUI.Button("~r~Kill Menu") then
				isMenuEnabled = false
			end
			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("MenuSettingsColor") then
			if LuxUI.CheckBox("Dynamic Theme", dynamicColorTheme, function(enabled) dynamicColorTheme = enabled end) then
			end
			if LuxUI.Button("Red", nil, themeColors.red) then
				_menuColor.base = themeColors.red
			end
			if LuxUI.Button("Orange", nil, themeColors.orange) then
				_menuColor.base = themeColors.orange
			end
			if LuxUI.Button("Yellow", nil, themeColors.yellow) then
				_menuColor.base = themeColors.yellow
			end
			if LuxUI.Button("Green", nil, themeColors.green) then
				_menuColor.base = themeColors.green
			end
			if LuxUI.Button("Blue", nil, themeColors.blue) then
				_menuColor.base = themeColors.blue
			end
			if LuxUI.Button("Purple", nil, themeColors.purple) then
				_menuColor.base = themeColors.purple
			end

			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("MenuSettingsCredits") then
			for _, v in pairs(contributors) do 
				if LuxUI.Button(v[1], v[2]) then end 
			end
			
			LuxUI.Display()
		elseif LuxUI.IsMenuOpened("ServerResources") then
			for _, resource in pairs(validResources) do
				if LuxUI.MenuButton(resource, 'ResourceData') then
					SelectedResource = resource
				end
			end
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened('ResourceData') then
			LuxUI.SetSubTitle('ResourceData', SelectedResource .. " > Data")
			if LuxUI.MenuButton('Event Handlers', 'ResourceCEvents') then end
			--if LuxUI.MenuButton('Server Events', 'ResourceSEvents') then end
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened('ResourceCEvents') then
			LuxUI.SetSubTitle('ResourceCEvents', SelectedResource .. " > Data > Event Handlers")
			for key, name in pairs(validResourceEvents[SelectedResource]) do
				if LuxUI.Button(name) then
					print(key)
				end
			end
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened('ResourceSEvents') then
			LuxUI.SetSubTitle('ResourceSEvents', SelectedResource .. " > Data > Server Events")
			for name, payload in pairs(validResourceServerEvents[SelectedResource]) do
				if LuxUI.Button(name) then
					print(payload)
				end
			end
		
		elseif LuxUI.IsMenuOpened("ESXBoss") then

			if LuxUI.Button("~c~Mechanic~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","mecano",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~b~Police~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","police",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~r~Ambulance~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","ambulance",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~y~Taxi~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","taxi",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~g~Real Estate~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","realestateagent",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~p~Gang~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","gang",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~o~Car Dealer~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","cardealer",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			elseif LuxUI.Button("~y~Banker~s~ Boss Menu") then
				TriggerEvent("esx_society:openBossMenu","banker",function(data, menu)menu.close() end)
				setMenuVisible(currentMenu, false)
			end

			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("ESXMoney") then

			if LuxUI.Button("~g~ESX ~y~Caution Give Back") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('esx_jobs:caution', 'give_back', result, 0, 0)
				end
			elseif LuxUI.Button("~g~ESX ~y~TruckerJob Pay") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('esx_truckerjob:pay', result)
				end
			elseif LuxUI.Button("~g~ESX ~y~Admin Give Bank") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('AdminMenu:giveBank', result)
				end
			elseif LuxUI.Button("~g~ESX ~y~Admin Give Cash") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('AdminMenu:giveCash', result)
				end
			elseif LuxUI.Button("~g~ESX ~y~GOPostalJob Pay") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent("esx_gopostaljob:pay", result)
				end
			elseif LuxUI.Button("~g~ESX ~y~BankerJob Pay") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent("esx_banksecurity:pay", result)
				end
			elseif LuxUI.Button("~g~ESX ~y~Slot Machine") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent("esx_slotmachine:sv:2", result)
				end
			end

			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("ESXMisc") then

			if LuxUI.Button("~w~Set hunger to ~g~100%") then
				TriggerEvent("esx_status:set", "hunger", 1000000)
			elseif LuxUI.Button("~w~Set thirst to ~g~100%") then
				TriggerEvent("esx_status:set", "thirst", 1000000)
			elseif LuxUI.Button("~g~ESX ~y~Revive ID") then
				local id = KeyboardInput("Enter Player ID", "", 1000)
				if id then
					TriggerServerEvent("esx_ambulancejob:revive", GetPlayerServerId(id))
					TriggerServerEvent("whoapd:revive", GetPlayerServerId(id))
					TriggerServerEvent("paramedic:revive", GetPlayerServerId(id))
					TriggerServerEvent("ems:revive", GetPlayerServerId(id))
				end
			elseif LuxUI.Button("~g~ESX ~r~SEND EVERYONE A BILL") then
				local amount = KeyboardInput("Enter Amount", "", 100000000)
				  local name = KeyboardInput("Enter the name of the Bill", "", 100000000)
				  if amount and name then
					for i = 0, 256 do
						  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", name, amount)
					end
				end
			elseif LuxUI.Button("~g~ESX ~b~Handcuff ID") then
				local id = KeyboardInput("Enter Player ID", "", 3)
				if id then
					TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(id))
				end
			elseif LuxUI.Button("~g~ESX ~w~Get all licenses") then
				TriggerServerEvent('esx_dmvschool:addLicense', dmv)
				TriggerServerEvent('esx_dmvschool:addLicense', drive)
				TriggerServerEvent('esx_dmvschool:addLicense', drive_bike)
				TriggerServerEvent('esx_dmvschool:addLicense', drive_truck)
			end

			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("MiscServerOptions") then

			if LuxUI.Button("Send Discord Message") then
				local Message = KeyboardInput("Enter message to send", "", 100)
				TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
				LuxUI.SendNotification({text = "Sent message:~n~" .. Message .. "", type = "success"})
			elseif LuxUI.Button("Trigger Event") then
				local _eventType = KeyboardInput("Enter event type (Client/Server)", "", 10)
				local eventType = string.lower(_eventType)

				local eventName = KeyboardInput("Enter event name", "", 25)
				local eventArg = KeyboardInput("Enter event argument (Only one argument is supported)", "", 25)
				if eventType == "client" then
					TriggerEvent(eventName, eventArg)
				elseif eventType == "server" then
					TriggerServerEvent(eventName, eventArg)
				end
			elseif LuxUI.Button("Send ambulance alert on waypoint") then
				local playerPed = PlayerPedId()
				if DoesBlipExist(GetFirstBlipInfoId(8)) then
					local blipIterator = GetBlipInfoIdIterator(8)
					local blip = GetFirstBlipInfoId(8, blipIterator)
					WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
					TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', "medical attention required: unconscious citizen!", WaypointCoords)
					LuxUI.SendNotification("~g~Ambulance alert sent to waypoint!")
				else
					LuxUI.SendNotification("~r~No waypoint set!")
				end

			elseif LuxUI.Button("~g~gcPhone ~w~Spoof message") then
				local transmitter = KeyboardInput("Enter transmitting phone number", "", 10)
				local receiver = KeyboardInput("Enter receiving phone number", "", 10)
				local message = KeyboardInput("Enter message to send", "", 100)
				if transmitter then
					if receiver then
						if message then
							TriggerServerEvent('gcPhone:_internalAddMessage', transmitter, receiver, message, 0)
						else
							LuxUI.SendNotification("~r~You must specify a message.")
						end
					else
						LuxUI.SendNotification("~r~You must specify a receiving number.")
					end
				else
					LuxUI.SendNotification("~r~You must specify a transmitting number.")
				end
			elseif LuxUI.Button("Spoof Chat Message") then
				local name = KeyboardInput("Enter chat sender name", "", 15)
				local message = KeyboardInput("Enter your message to send", "", 70)
				if name and message then
					TriggerEvent('chat:addMessage', -1, { args = { name, message }, color = { 255, 255, 255 } })
				end
			elseif LuxUI.Button("~g~MUG ~w~Give item") then
				local itemName = KeyboardInput("Enter item name", "", 20)
				if itemName then
					TriggerServerEvent('esx_mugging:giveItems', (itemName))
					LuxUI.SendNotification("Successfully given item ~g~" .. itemName)
				else
					LuxUI.SendNotification("~r~You must specify an item")
				end
			end

			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("VRPOptions") then

			if LuxUI.Button("~r~VRP ~s~Give Money ~ypayGarage") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100)
				if result then
					TriggerServerEvent("lscustoms:payGarage", {costs = -result})
				end
			elseif LuxUI.Button("~r~VRP ~g~WIN ~s~Slot Machine") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100)
				if result then
					TriggerServerEvent("vrp_slotmachine:server:2", result)
				end
			elseif LuxUI.Button("~r~VRP ~s~Get driving license") then
				TriggerServerEvent("dmv:success")
			elseif LuxUI.Button("~r~VRP ~s~Bank Deposit") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result then
					TriggerServerEvent("bank:deposit", result)
				end
			elseif LuxUI.Button("~r~VRP ~s~Bank Withdraw ") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result then
					TriggerServerEvent("bank:withdraw", result)
				end
			end

			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("ESXDrugs") then

			if LuxUI.Button("~g~Harvest ~g~Weed") then
				TriggerServerEvent("esx_drugs:startHarvestWeed")
			elseif LuxUI.Button("~g~Transform ~g~Weed ") then
				TriggerServerEvent("esx_drugs:startTransformWeed")
			elseif LuxUI.Button("~g~Sell ~g~Weed") then
				TriggerServerEvent("esx_drugs:startSellWeed")
			elseif LuxUI.Button("~w~Harvest ~w~Coke") then
				TriggerServerEvent("esx_drugs:startHarvestCoke")
			elseif LuxUI.Button("~w~Transform ~w~Coke") then
				TriggerServerEvent("esx_drugs:startTransformCoke")
			elseif LuxUI.Button("~w~Sell ~w~Coke") then
				TriggerServerEvent("esx_drugs:startSellCoke")
			elseif LuxUI.Button("~r~Harvest Meth") then
				TriggerServerEvent("esx_drugs:startHarvestMeth")
			elseif LuxUI.Button("~r~Transform Meth") then
				TriggerServerEvent("esx_drugs:startTransformMeth")
			elseif LuxUI.Button("~r~Sell Meth") then
				TriggerServerEvent("esx_drugs:startSellMeth")
			elseif LuxUI.Button("~p~Harvest Opium") then
				TriggerServerEvent("esx_drugs:startHarvestOpium")
			elseif LuxUI.Button("~p~Transform Opium") then
				TriggerServerEvent("esx_drugs:startTransformOpium")
			elseif LuxUI.Button("~p~Sell Opium") then
				TriggerServerEvent("esx_drugs:startSellOpium")
			elseif LuxUI.Button("~g~Money Wash") then
				TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
			elseif LuxUI.Button("~r~Stop all ~c~Drugs") then
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
				LuxUI.SendNotification("~r~Everything is now stopped")
			elseif LuxUI.CheckBox("~r~Blow Drugs Up",
				BlowDrugsUp,
				function(enabled)
					BlowDrugsUp = enabled
				end)
			then
			end

			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlinePlayersMenu") then
			onlinePlayerSelected = {}
			
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				onlinePlayerSelected[i] = id -- equivalent to table.insert(table, value) but faster

				if LuxUI.MenuButton("~b~" .. GetPlayerServerId(id) .. "~w~   " .. GetPlayerName(id), 'PlayerOptionsMenu') then
					SelectedPlayer = id
				end
			end

			local index = menus[currentMenu].currentOption

			LuxUI.DrawPlayerInfo(onlinePlayerSelected[index])
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("PlayerOptionsMenu") then
			LuxUI.SetSubTitle("PlayerOptionsMenu", "Player Options [" .. GetPlayerName(SelectedPlayer) .. "]")
			
			if LuxUI.Button("Spectate", (Spectating and "~g~[SPECTATING]")) then
				SpectatePlayer(SelectedPlayer)
			end

			if LuxUI.Button("Ragdoll") then
				SetPedToRagdoll(GetPlayerPed(SelectedPlayer), 3000, 1, 1, true, true, false)
			end

			if LuxUI.Button("Teleport To Player") then
				LUX.Game:TeleportToPlayer(SelectedPlayer)
			end

			if LuxUI.MenuButton("Weapon Menu", "OnlineWepMenu") then end
			if LuxUI.MenuButton("Vehicle Menu", "OnlineVehicleMenuPlayer") then end
			if LuxUI.MenuButton("~b~ESX Options", "ESXMenuPlayer") then end
			if LuxUI.Button("~r~Silent Explode") then
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, false, true, 0)
			end
			if LuxUI.Button("~y~Explode") then
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, true, false, 100000.0)
			end
			if LuxUI.Button("Give All Weapons") then
				for hash, v in pairs(t_Weapons) do
					GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 255, false, false)
				end
			end
			if LuxUI.Button("Remove All Weapons") then
				RemoveAllPedWeapons(GetPlayerPed(SelectedPlayer), true)
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("ESXMenuPlayer") then
			if LuxUI.Button("~g~ESX ~s~Send Bill") then
				local amount = KeyboardInput("Enter Amount", "", 10)
				local name = KeyboardInput("Enter the name of the Bill", "", 25)
				if amount and name then
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(SelectedPlayer), "Purposeless", name, amount)
				end
			elseif LuxUI.Button("~g~ESX ~s~Handcuff Player") then
				TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(SelectedPlayer))
			elseif LuxUI.Button("~g~ESX ~s~Revive player") then
				TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
			elseif LuxUI.Button("~g~ESX ~s~Unjail player") then
				TriggerServerEvent("esx_jail:unjailQuest", GetPlayerServerId(SelectedPlayer))
				TriggerServerEvent("js:removejailtime", GetPlayerServerId(SelectedPlayer))
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineWepMenu") then
			LuxUI.SetSubTitle("OnlineWepMenu", "Weapon Options - " .. GetPlayerName(SelectedPlayer) .. "")
			LuxUI.MenuButton("Give Weapon", "OnlineWepCategory")

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineWepCategory") then
			LuxUI.SetSubTitle("OnlineWepCategory", "Give Weapon - " .. GetPlayerName(SelectedPlayer) .. "")

			LuxUI.MenuButton("Melee Weapons", "OnlineMeleeWeapons")
			LuxUI.MenuButton("Sidearms", "OnlineSidearmWeapons")
			LuxUI.MenuButton("Auto Rifles", "OnlineAutorifleWeapons")
			LuxUI.MenuButton("Shotguns", "OnlineShotgunWeapons")

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineMeleeWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_me" then
					if LuxUI.Button(v[1], "isWeapon") then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 0, false, false)
					end
				end
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineSidearmWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_hg" then
					if LuxUI.Button(v[1], "isWeapon") then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 32, false, false)
					end
				end
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineAutorifleWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_ar" then
					if LuxUI.Button(v[1], "isWeapon") then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 60, false, false)
					end
				end
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineShotgunWeapons") then
			for hash, v in pairs(t_Weapons) do
				if v[4] == "w_sg" then
					if LuxUI.Button(v[1], "isWeapon") then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(hash), 18, false, false)
					end
				end
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		
		elseif LuxUI.IsMenuOpened("OnlineVehicleMenuPlayer") then
			LuxUI.SetSubTitle("OnlineVehicleMenuPlayer", "Vehicle Options [" .. GetPlayerName(SelectedPlayer) .. "]")
			if LuxUI.Button("Spawn Vehicle") then
				local ModelName = KeyboardInput("Enter Vehicle Model Name", "", 12)
				if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
					RequestModel(ModelName)
					while not HasModelLoaded(ModelName) do
						Citizen.Wait(0)
					end

					local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(GetPlayerPed(SelectedPlayer)), GetEntityHeading(GetPlayerPed(SelectedPlayer)), true, true)

					SetPedIntoVehicle(GetPlayerPed(SelectedPlayer), veh, -1)
					LuxUI.SendNotification({text = NotifyFormat("Successfully spawned ~b~%s ~s~on ~t~%s", string.lower(GetDisplayNameFromVehicleModel(ModelName)), GetPlayerName(SelectedPlayer)), type = "info"})
				else
					LuxUI.SendNotification("~r~Model is not valid!")
				end
			end
			if LuxUI.Button("Spawn Owned Vehicle") then
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
					local vehicleProps = LUX.Game.GetVehicleProperties(veh)
					TriggerServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
					TriggerServerEvent('esx_givecarkeys:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
					TriggerServerEvent('garage:addKeys', newPlate)
					SetPedIntoVehicle(GetPlayerPed(SelectedPlayer), veh, -1)
				else
					LuxUI.SendNotification({ text = "Vehicle model " .. ModelName .. " does not exist!", type = "error"})
				end
			end
			if LuxUI.Button("Kick From Vehicle") then
				ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
			end
			if LuxUI.Button("Destroy Engine") then

				local playerPed = GetPlayerPed(SelectedPlayer)

				NetworkRequestControlOfEntity(GetVehiclePedIsIn(playerPed))

				SetVehicleUndriveable(GetVehiclePedIsIn(playerPed),true)
				SetVehicleEngineHealth(GetVehiclePedIsIn(playerPed), 100)
			end
			if LuxUI.Button("Explode on Impact") then

				local ped = GetPlayerPed(SelectedPlayer)
				local veh = GetVehiclePedIsIn(ped, 0)

				RequestControlOnce(veh)

				SetVehicleOutOfControl(veh, false, true)
			end
			if LuxUI.Button("Repair Vehicle") then
				NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
				SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false))
				SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0.0)
				SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
				SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), false)
				Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
			end
			if LuxUI.Button("Vandalize Car") then
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
				LuxUI.SendNotification("~g~Vehicle Fucked Up!")
			end

			LuxUI.DrawPlayerInfo(SelectedPlayer)
			LuxUI.Display()
		end

		for i, mods in pairs(LSC.vehicleMods) do
			if mods.meta == "modHorns" then
				if LuxUI.IsMenuOpened(mods.meta) then
					for j = 0, 51, 1 do
						if j == currentMods[mods.meta] then
							if LuxUI.Button(LSC.GetHornName(j), "Installed", nil, _menuColor.base) then 
								RemoveVehicleMod(LUX.Player.Vehicle, mods.id)
								LSC.UpdateMods()
							end
						else
							if LuxUI.Button(LSC.GetHornName(j), "Not Installed") then 
								SetVehicleMod(LUX.Player.Vehicle, mods.id, j)
								LSC.UpdateMods()
							end
						end
					end
					LuxUI.Display()
				end
			elseif mods.meta == "modFrontWheels" or mods.meta == "modBackWheels" then
				if LuxUI.IsMenuOpened(mods.meta) then
					local modCount = GetNumVehicleMods(LUX.Player.Vehicle, mods.id)
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(LUX.Player.Vehicle, mods.id, j)
						if modName then
							if j == currentMods[mods.meta] then
								if LuxUI.Button(GetLabelText(modName), "Installed", nil, _menuColor.base) then 
									RemoveVehicleMod(LUX.Player.Vehicle, mods.id)
									LSC.UpdateMods()
								end
							else
								if LuxUI.Button(GetLabelText(modName), "Not Installed") then 
									SetVehicleMod(LUX.Player.Vehicle, mods.id, j)
									LSC.UpdateMods()
								end
							end
						end
					end
					LuxUI.Display()
				end
			else
				if LuxUI.IsMenuOpened(mods.meta) then
					local modCount = GetNumVehicleMods(LUX.Player.Vehicle, mods.id)
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(LUX.Player.Vehicle, mods.id, j)
						if modName then
							if j == currentMods[mods.meta] then
								if LuxUI.Button(GetLabelText(modName), "Installed", nil, _menuColor.base) then 
									RemoveVehicleMod(LUX.Player.Vehicle, mods.id)
									LSC.UpdateMods()
								end
							else
								if LuxUI.Button(GetLabelText(modName), "Not Installed") then 
									SetVehicleMod(LUX.Player.Vehicle, mods.id, j)
									LSC.UpdateMods()
								end
							end
						end
					end
					LuxUI.Display()
				end
			end
		end
		
		Wait(0)
	end
end
CreateThread(MenuRuntimeThread)


local function GateKeep()
	local name = GetPlayerName(PlayerId())
	_buyer = "leuit"
	if _gatekeeper then
		if name == _buyer and GetCurrentLanguage() == 0 then
			LuxUI.OpenMenu("LuxMainMenu")
			--LuxUI.SendNotification({text = "This is hopefully going to make it all the way to a multiline so I can finish my damn notification"})	

		else
			_auth = false
			LuxUI.SendNotification("~r~ERROR: ~w~You don't appear to own ~h~LUX MENU")
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
