-- Globals

-- Menu color customization
local _menuColor

-- License key validation for LUX
local _buyer
local _secretKey = "devbuild"
local _gatekeeper = false

-- BOOL if the player is in a vehicle
local _pVehicle = false

-- Init variables
local showMinimap = true

local colorRed = { r = 231, g = 76, b = 60, a = 255 } -- rgb(231, 76, 60)
local colorGreen = { r = 46, g = 204, b = 113, a = 255 } -- rgb(46, 204, 113)
local colorBlue = { r = 52, g = 152, b = 219, a = 255 } -- rgb(52, 152, 219)
local colorPurple = { r = 155, g = 89, b = 182, a = 255 } -- rgb(155, 89, 182)

_menuColor = colorPurple


local function KillYourself()
	Citizen.CreateThread(function()
		local playerPed = GetPlayerPed(-1)

		local canSuicide = false
		local foundWeapon = nil

		GiveWeaponToPed(playerPed, `WEAPON_PISTOL`, 250, false, true)

		if HasPedGotWeapon(playerPed, `WEAPON_PISTOL`) then
			if GetAmmoInPedWeapon(playerPed, `WEAPON_PISTOL`) > 0 then
				canSuicide = true
				foundWeapon = `WEAPON_PISTOL`
			end
		end

		if canSuicide then
			if not HasAnimDictLoaded('mp_suicide') then
				RequestAnimDict('mp_suicide')

				while not HasAnimDictLoaded('mp_suicide') do
					Wait(1)
				end
			end

			SetCurrentPedWeapon(playerPed, foundWeapon, true)

			Wait(750)

			TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

			Wait(750)

			SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
			SetEntityHealth(playerPed, 0)
		end
	end)
end

-- Config for LSC

local vehicleMods = {
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


local perfMods = {
	{name = "Engine", id = 11},
	{name = "Brakes", id = 12},
	{name = "Transmission", id = 13},
	{name = "Suspension", id = 15},
}

local horns = {
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


local neonColors = {
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

local paintsClassic = { -- kill me pls
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


local paintsMatte = {
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

local paintsMetal = {
	{name = "Brushed Steel", id = 117},
	{name = "Brushed Black Steel", id = 118},
	{name = "Brushed Aluminum", id = 119},
	{name = "Pure Gold", id = 158},
	{name = "Brushed Gold", id = 159},
}

defaultVehAction = ""

function checkValidVehicleExtras()
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


function DoesVehicleHaveExtras( veh )
	for i = 1, 30 do
		if ( DoesExtraExist( veh, i ) ) then
			return true
		end
	end

	return false
end


function checkValidVehicleMods(modID)
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


WarMenu = {}

WarMenu.debug = false

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local menuWidth = 0.23
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

local function debugPrint(text)
	if WarMenu.debug then
		Citizen.Trace("[WarMenu] " .. tostring(text))
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

local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2
		if menus[currentMenu].background == "default" then
			RequestStreamedTextureDict("commonmenu")
			if _menuColor == colorPurple then
				DrawSprite("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- 255, 76, 60,
			else
				DrawSprite("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.r, _menuColor.g, _menuColor.b, 255)
			end
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

		local subTitleColor = {
			r = menus[currentMenu].titleBackgroundColor.r,
			g = menus[currentMenu].titleBackgroundColor.g,
			b = menus[currentMenu].titleBackgroundColor.b,
			a = 255
		}

		drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
		drawRect(x, y + 0.02, menuWidth, 0.0025, _menuColor)
		drawText(
			menus[currentMenu].subTitle,
			menus[currentMenu].x + buttonTextXOffset,
			y - buttonHeight / 2 + buttonTextYOffset,
			buttonFont,
			subTitleColor,
			buttonScale,
			false
		)

		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(
				tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
				menus[currentMenu].x + menuWidth,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTitleColor,
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

		if
			menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
				optionCount <= menus[currentMenu].maxOptionCount
		 then
			multiplier = optionCount
		elseif
			optionCount >= menus[currentMenu].currentOption
		 then
			multiplier = 10
		end

		if multiplier then
			local y = menus[currentMenu].y + titleHeight + 0.015 + buttonHeight + (buttonHeight * multiplier)

			drawRect(x, y, menuWidth, buttonHeight / 2, footerColor)

			drawText("v1.0 | LICENSED TO ~p~" .. _buyer, x, y - titleHeight / 2.7 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale / 3, true)
		end

	end
end

local function drawButton(text, subText)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil
	local pointer = true

	if
		menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].maxOptionCount
	 then
		multiplier = optionCount
	elseif
		optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].currentOption
	 then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			pointColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			pointColor = menus[currentMenu].blankColor
			shadow = true
		end

		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
		if menus[currentMenu].subTitle == "MAIN MENU" then -- and subText == "isMenu"
			drawText(
			text,
			menus[currentMenu].x + 0.015,
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

		if text == "Player Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_players_icon", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 26, 188, 156, 255) -- rgb(26, 188, 156)
		elseif text == "Online Players" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_friends_icon", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 52, 152, 219, 255) -- rgb(52, 152, 219)
		elseif text == "Visual Options" then
			RequestStreamedTextureDict("mphud")
			DrawSprite("mphud", "spectating", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 236, 240, 241, 255) -- rgb(236, 240, 241)
		elseif text == "Teleport Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_star_icon", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 241, 196, 15, 255) -- rgb(241, 196, 15)
		elseif text == "Vehicle Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_car_icon", x - menuWidth / 2.15, y, 0.018, buttonHeight - 0.010, 0.0, 230, 126, 34, 255) -- rgb(230, 126, 34)
		elseif text == "Weapon Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_kd_icon", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 231, 76, 60, 255) -- rgb(231, 76, 60)
		elseif text == "Server Options" then
			RequestStreamedTextureDict("mpleaderboard")
			DrawSprite("mpleaderboard", "leaderboard_globe_icon", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 155, 89, 182, 255) -- rgb(155, 89, 182)
	--	elseif text == "~b~Menu Settings" then
	--		RequestStreamedTextureDict("mpleaderboard")
	--		DrawSprite("mpleaderboard", "leaderboard_time_icon", x - menuWidth / 2.15, y, 0.02, buttonHeight - 0.010, 0.0, 255, 255, 255, 255) -- rgb(155, 89, 182)
		end


		if subText == "isMenu" then
			RequestStreamedTextureDict("commonmenu")
			DrawSprite("commonmenu", "arrowright", x + menuWidth / 2.3, y, 0.02, buttonHeight, 0.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)

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

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.75
	menus[id].y = 0.19

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 10
	menus[id].titleFont = 4
	menus[id].titleColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].background = "default"
	Citizen.CreateThread(
		function()
			while true do
				Citizen.Wait(0)
				menus[id].titleBackgroundColor = {r = _menuColor.r, g = _menuColor.g, b = _menuColor.b, a = 180}
				menus[id].menuFocusBackgroundColor = {r = _menuColor.r, g = _menuColor.g, b = _menuColor.b, a = 150} -- rgb(155, 89, 182)
			end
			menus[id].titleBackgroundSprite = nil
		end)

	menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = {r = 189, g = 189, b = 189, a = 255}
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	--menus[id].menuFocusBackgroundColor = { r = 245, g = 245, b = 245, a = 255 }
	menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 150}
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
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		setMenuVisible(id, true)

		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
				Citizen.Wait(0)
			end
		end

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
	local checked = "~r~Off"
	if bool then
		checked = "~g~On"
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
		selectedItem = "← " .. tostring(selectedItem) .. " →"
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

function WarMenu.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			WarMenu.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()
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
	AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
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

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

local allWeapons = {
	"WEAPON_KNIFE",
	"WEAPON_KNUCKLE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_HAMMER",
	"WEAPON_BAT",
	"WEAPON_GOLFCLUB",
	"WEAPON_CROWBAR",
	"WEAPON_BOTTLE",
	"WEAPON_DAGGER",
	"WEAPON_HATCHET",
	"WEAPON_MACHETE",
	"WEAPON_FLASHLIGHT",
	"WEAPON_SWITCHBLADE",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_APPISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_SNSPISTOL",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_STUNGUN",
	"WEAPON_FLAREGUN",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_REVOLVER",
	"WEAPON_MICROSMG",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_ASSAULTSMG",
	"WEAPON_MG",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_COMBATPDW",
	"WEAPON_GUSENBERG",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_MUSKET",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_DBSHOTGUN",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG",
	"WEAPON_STINGER",
	"WEAPON_FIREWORK",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_GRENADE",
	"WEAPON_STICKYBOMB",
	"WEAPON_PROXMINE",
	"WEAPON_BZGAS",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_MOLOTOV",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_PETROLCAN",
	"WEAPON_SNOWBALL",
	"WEAPON_FLARE",
	"WEAPON_BALL"
}

local Enabled = true

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

		drawNotification("Teleported.")
	else
		drawNotification("Please place your waypoint.")
	end
end

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

local Spectating = false

function SpectatePlayer(player)
	local playerPed = PlayerPedId()
	Spectating = not Spectating
	local targetPed = GetPlayerPed(player)

	if (Spectating) then
		local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx, targety, targetz)
		NetworkSetInSpectatorMode(true, targetPed)

		drawNotification("Spectating " .. GetPlayerName(player))
	else
		local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx, targety, targetz)
		NetworkSetInSpectatorMode(false, targetPed)

		drawNotification("Stopped Spectating " .. GetPlayerName(player))
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

-- Player Blips
Citizen.CreateThread(function()
	while true do
		if playerBlips then
			-- show blips
			for id = 0, 256 do
				if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= GetPlayerPed(-1) then
					ped = GetPlayerPed(id)
					blip = GetBlipFromEntity(ped)

					-- HEAD DISPLAY STUFF --

					-- Create head display (this is safe to be spammed)
					-- headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )

					-- Player Name Sprite (black and ugly)
					-- Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, true )

					wantedLvl = GetPlayerWantedLevel(id)

					-- Wanted level display
					if wantedLvl then
						Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, true ) -- Add wanted sprite
						Citizen.InvokeNative( 0xCF228E2AA03099C3, headId, wantedLvl ) -- Set wanted number
					else
						Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false ) -- Remove wanted sprite
					end

					-- Speaking display
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

						if not GetEntityHealth(ped) then -- dead
							if blipSprite ~= 274 then
								SetBlipSprite(blip, 274)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) -- Player Blip indicator
							end
						elseif veh then
							vehClass = GetVehicleClass(veh)
							vehModel = GetEntityModel(veh)
							if vehClass == 15 then -- Helicopters
								if blipSprite ~= 422 then
									SetBlipSprite(blip, 422)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehClass == 8 then -- Motorcycles
								if blipSprite ~= 226 then
									SetBlipSprite(blip, 226)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehClass == 16 then -- Plane
								if vehModel == `besra` or vehModel == `hydra` or vehModel == `lazer` then -- Jets
									if blipSprite ~= 424 then
										SetBlipSprite(blip, 424)
										Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
									end
								elseif blipSprite ~= 423 then
									SetBlipSprite(blip, 423)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehClass == 14 then -- Boat
								if blipSprite ~= 427 then
									SetBlipSprite(blip, 427)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `insurgent` or vehModel == `insurgent2` or vehModel == `insurgent3` then -- Insurgent, Insurgent Pickup & Insurgent Pickup Custom
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `limo2` then -- Turreted Limo
								if blipSprite ~= 460 then
									SetBlipSprite(blip, 460)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `rhino` then -- Tank
								if blipSprite ~= 421 then
									SetBlipSprite(blip, 421)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `trash` or vehModel == `trash2` then -- Trash
								if blipSprite ~= 318 then
									SetBlipSprite(blip, 318)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `pbus` then -- Prison Bus
								if blipSprite ~= 513 then
									SetBlipSprite(blip, 513)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `seashark` or vehModel == `seashark2` or vehModel == `seashark3` then -- Speedophiles
								if blipSprite ~= 471 then
									SetBlipSprite(blip, 471)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `cargobob` or vehModel == `cargobob2` or vehModel == `cargobob3` or vehModel == `cargobob4` then -- Cargobobs
								if blipSprite ~= 481 then
									SetBlipSprite(blip, 481)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `technical` or vehModel == `technical2` or vehModel == `technical3` then -- Technical
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `taxi` then -- Cab/ Taxi
								if blipSprite ~= 198 then
									SetBlipSprite(blip, 198)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == `fbi` or vehModel == `fbi2` or vehModel == `police2` or vehModel == `police3` -- Police Vehicles
								or vehModel == `police` or vehModel == `sheriff2` or vehModel == `sheriff`
								or vehModel == `policeold2` or vehModel == `policeold1` then
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
			for id = 0, 256 do
				ped = GetPlayerPed(id)
				blip = GetBlipFromEntity(ped)
				if DoesBlipExist(blip) then -- Removes blip
					RemoveBlip(blip)
				end
			end
		end
		Citizen.Wait(0)
	end
end)

-- Nametags
Citizen.CreateThread(function()
	while true do
		if showNametags then
			for i=0, 256 do
				N_0x31698aa80e0223f8(i)
			end
			for id = 0, 256 do
				if GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then
					ped = GetPlayerPed( id )
					blip = GetBlipFromEntity( ped )

					x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
					x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
					distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))

					if ((distance < 125)) then
						--DrawText3D(x2, y2, z2 + displayIDHeight, GetPlayerServerId(id))
						DrawText3D(x2, y2, z2 + 1.5, "" .. GetPlayerServerId(id) .. " | " .. GetPlayerName(id) .. "", 255, 255, 255)
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)


Citizen.CreateThread(
	function()
		while Enabled do
			Citizen.Wait(0)
			_pVehicle = IsPedInAnyVehicle(GetPlayerPed(-1), 0)

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
					drawNotification("~g~Vehicle Gun Enabled!~n~~w~Use The ~b~AP Pistol~n~~b~Aim ~w~and ~b~Shoot!")
					GiveWeaponToPed(GetPlayerPed(-1), `WEAPON_APPISTOL`, 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), `WEAPON_APPISTOL`, 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == `WEAPON_APPISTOL`) then
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
					GiveWeaponToPed(GetPlayerPed(-1), `WEAPON_PISTOL`, 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), `WEAPON_PISTOL`, 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == `WEAPON_PISTOL`) then
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
				for i = 0, 256 do
					if i ~= PlayerId() and GetPlayerServerId(i) ~= 0 then
						local ra = RGBRainbow(1.0)
						local pPed = GetPlayerPed(i)
						local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
						local x, y, z = table.unpack(GetEntityCoords(pPed))
						local message =
							"Name: " ..
							GetPlayerName(i) ..
								"\nServer ID: " ..
									GetPlayerServerId(i) ..
										"\nPlayer ID: " .. i .. "\nDist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, true), 1)
						if IsPedInAnyVehicle(pPed, true) then
							local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
							message = message .. "\nVeh: " .. VehName
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

						DrawLine(
							LineOneBegin.x,
							LineOneBegin.y,
							LineOneBegin.z,
							LineOneEnd.x,
							LineOneEnd.y,
							LineOneEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							LineTwoBegin.x,
							LineTwoBegin.y,
							LineTwoBegin.z,
							LineTwoEnd.x,
							LineTwoEnd.y,
							LineTwoEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							LineThreeBegin.x,
							LineThreeBegin.y,
							LineThreeBegin.z,
							LineThreeEnd.x,
							LineThreeEnd.y,
							LineThreeEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							LineThreeEnd.x,
							LineThreeEnd.y,
							LineThreeEnd.z,
							LineFourBegin.x,
							LineFourBegin.y,
							LineFourBegin.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							TLineOneBegin.x,
							TLineOneBegin.y,
							TLineOneBegin.z,
							TLineOneEnd.x,
							TLineOneEnd.y,
							TLineOneEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							TLineTwoBegin.x,
							TLineTwoBegin.y,
							TLineTwoBegin.z,
							TLineTwoEnd.x,
							TLineTwoEnd.y,
							TLineTwoEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							TLineThreeBegin.x,
							TLineThreeBegin.y,
							TLineThreeBegin.z,
							TLineThreeEnd.x,
							TLineThreeEnd.y,
							TLineThreeEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							TLineThreeEnd.x,
							TLineThreeEnd.y,
							TLineThreeEnd.z,
							TLineFourBegin.x,
							TLineFourBegin.y,
							TLineFourBegin.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							ConnectorOneBegin.x,
							ConnectorOneBegin.y,
							ConnectorOneBegin.z,
							ConnectorOneEnd.x,
							ConnectorOneEnd.y,
							ConnectorOneEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							ConnectorTwoBegin.x,
							ConnectorTwoBegin.y,
							ConnectorTwoBegin.z,
							ConnectorTwoEnd.x,
							ConnectorTwoEnd.y,
							ConnectorTwoEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							ConnectorThreeBegin.x,
							ConnectorThreeBegin.y,
							ConnectorThreeBegin.z,
							ConnectorThreeEnd.x,
							ConnectorThreeEnd.y,
							ConnectorThreeEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)
						DrawLine(
							ConnectorFourBegin.x,
							ConnectorFourBegin.y,
							ConnectorFourBegin.z,
							ConnectorFourEnd.x,
							ConnectorFourEnd.y,
							ConnectorFourEnd.z,
							ra.r,
							ra.g,
							ra.b,
							255
						)

						DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
					end
				end
			end

			if VehGod and IsPedInAnyVehicle(PlayerPedId(), true) then
				SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId()), true)
			end

			if oneshot then
				SetPlayerWeaponDamageModifier(PlayerId(), 100.0)
				local gotEntity = getEntity(PlayerId())
				if IsEntityAPed(gotEntity) then
					if IsPedInAnyVehicle(gotEntity, true) then
						if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
							if IsControlJustReleased(1, 69) then
								NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
							end
						else
							if IsControlJustReleased(1, 142) then
								NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
							end
						end
					end
				elseif IsEntityAVehicle(gotEntity) then
					if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
						if IsControlJustReleased(1, 69) then
							NetworkExplodeVehicle(gotEntity, true, true, 0)
						end
					else
						if IsControlJustReleased(1, 142) then
							NetworkExplodeVehicle(gotEntity, true, true, 0)
						end
					end
				end
			else
				SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
			end

			if blowall then
        for i = 0, 256 do
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
				for i = 0, 256 do
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
				local avion = "CARGOPLANE"
				for i = 0, 256 do
						while not HasModelLoaded(GetHashKey(avion)) do
							Citizen.Wait(0)
							RequestModel(GetHashKey(avion))
						end
						Citizen.Wait(200)

						local avion2 = CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) -200, true, true) and
						CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) -100, true, true)
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
				local Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Entity)
				if Aiming then
					if IsEntityAPed(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
						ShootPlayer(Entity)
					end
				end
			end

			if AimBot then
				for i = 0, 256 do
					if i ~= PlayerId() then
						if IsPlayerFreeAiming(PlayerId()) then
							local TargetPed = GetPlayerPed(i)
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

			-- Radar/showMinimap
			DisplayRadar(showMinimap)

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

			if Noclip then
				local currentSpeed = 2
				local noclipEntity =
					IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
				FreezeEntityPosition(PlayerPedId(), true)
				SetEntityInvincible(PlayerPedId(), true)

				local newPos = GetEntityCoords(entity)

				DisableControlAction(0, 32, true) --MoveUpOnly
				DisableControlAction(0, 268, true) --MoveUp

				DisableControlAction(0, 31, true) --MoveUpDown

				DisableControlAction(0, 269, true) --MoveDown
				DisableControlAction(0, 33, true) --MoveDownOnly

				DisableControlAction(0, 266, true) --MoveLeft
				DisableControlAction(0, 34, true) --MoveLeftOnly

				DisableControlAction(0, 30, true) --MoveLeftRight

				DisableControlAction(0, 267, true) --MoveRight
				DisableControlAction(0, 35, true) --MoveRightOnly

				DisableControlAction(0, 44, true) --Cover
				DisableControlAction(0, 20, true) --MultiplayerInfo

				local yoff = 0.0
				local zoff = 0.0

				if GetInputMode() == "MouseAndKeyboard" then
					if IsDisabledControlPressed(0, 32) then
						yoff = 0.5
					end
					if IsDisabledControlPressed(0, 33) then
						yoff = -0.5
					end
					if IsDisabledControlPressed(0, 34) then
						SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 3.0)
					end
					if IsDisabledControlPressed(0, 35) then
						SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) - 3.0)
					end
					if IsDisabledControlPressed(0, 44) then
						zoff = 0.21
					end
					if IsDisabledControlPressed(0, 20) then
						zoff = -0.21
					end
				end

				newPos =
					GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

				local heading = GetEntityHeading(noclipEntity)
				SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
				SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
				SetEntityHeading(noclipEntity, heading)

				SetEntityCollision(noclipEntity, false, false)
				SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

				FreezeEntityPosition(noclipEntity, false)
				SetEntityInvincible(noclipEntity, false)
				SetEntityCollision(noclipEntity, true, true)
			end
		end
	end
)

function GetPlayers()
	local players = {}

	for i = 0, 31 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end

	return players
end


Citizen.CreateThread(
	function()
		FreezeEntityPosition(entity, false)
		local currentItemIndex = 1
		local selectedItemIndex = 1


		WarMenu.CreateMenu("LuxMainMenu", "LUX MENU")
		WarMenu.SetSubTitle("LuxMainMenu", "Main Menu")
		WarMenu.CreateSubMenu("SelfMenu", "LuxMainMenu", "Player Options")
		WarMenu.CreateSubMenu("VisualMenu", "LuxMainMenu", "Visual Options")
		WarMenu.CreateSubMenu("Griefer", "LuxMainMenu", "Griefer Options")
		WarMenu.CreateSubMenu("VehMenu", "LuxMainMenu", "Vehicle Options")
		WarMenu.CreateSubMenu('LSC', 'VehMenu', "Los Santos Customs")
		WarMenu.CreateSubMenu('tunings', 'LSC', 'Visual Tuning')
		WarMenu.CreateSubMenu('performance', 'LSC', 'Performance Tuning')
		WarMenu.CreateSubMenu("ServerMenu", "LuxMainMenu", "Server Menu")
		WarMenu.CreateSubMenu("TeleportMenu", "LuxMainMenu", "Teleport Menu")
		WarMenu.CreateSubMenu('OnlinePlayerMenu', 'LuxMainMenu', "Online Players")
		WarMenu.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayerMenu', "Player Options")
		WarMenu.CreateSubMenu('SingleWepPlayer', 'OnlinePlayerMenu', "Give Single Weapon")
		WarMenu.CreateSubMenu('VehMenuPlayer', 'OnlinePlayerMenu', "Vehicle Options")
		WarMenu.CreateSubMenu('ESXMenuPlayer', 'OnlinePlayerMenu', "ESX Options")
		WarMenu.CreateSubMenu("WepMenu", "LuxMainMenu", "Weapon Options")
		WarMenu.CreateSubMenu("SingleWepMenu", "WepMenu", "Give Single Weapon")
		WarMenu.CreateSubMenu("ESXBoss", "ServerMenu", "ESX Boss Menus")
		WarMenu.CreateSubMenu("ESXMoney", "ServerMenu", "ESX Money Options")
		WarMenu.CreateSubMenu("ESXMisc", "ServerMenu", "ESX Misc Options")
		WarMenu.CreateSubMenu("ESXDrugs", "ServerMenu", "ESX Drugs")
		WarMenu.CreateSubMenu("MiscServerOptions", "ServerMenu", "Misc Server Options")
		WarMenu.CreateSubMenu("VRPOptions", "ServerMenu", "VRP Server Options")

		WarMenu.CreateSubMenu("MenuSettings", "LuxMainMenu", "Menu Settings")
		WarMenu.CreateSubMenu("MenuSettingsColor", "MenuSettings", "Change Menu Color")

		for i,theItem in pairs(vehicleMods) do
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

		for i,theItem in pairs(perfMods) do
			WarMenu.CreateSubMenu(theItem.id, 'performance', theItem.name)
		end

		local SelectedPlayer

		while Enabled do
			ped = PlayerPedId()
			veh = GetVehiclePedIsUsing(ped)
			if WarMenu.IsMenuOpened("LuxMainMenu") then
				if WarMenu.MenuButton("Player Options", "SelfMenu") then
				elseif WarMenu.MenuButton("Online Players", "OnlinePlayerMenu") then
				elseif WarMenu.MenuButton("Visual Options", "VisualMenu") then
				elseif WarMenu.MenuButton("Teleport Options", "TeleportMenu") then
				elseif WarMenu.MenuButton("Vehicle Options", "VehMenu") then
				elseif WarMenu.MenuButton("Weapon Options", "WepMenu") then
				elseif WarMenu.MenuButton("Server Options", "ServerMenu") then
				elseif WarMenu.MenuButton("~r~Grief Menu", "Griefer") then
				elseif WarMenu.MenuButton("~b~Menu Settings", "MenuSettings") then
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("SelfMenu") then
				local toggle = false
			 	if WarMenu.Button("~g~Max Health") then
					SetEntityHealth(PlayerPedId(), 200)
				elseif WarMenu.Button("~g~Max Armour") then
					SetPedArmour(PlayerPedId(), 200)
				elseif WarMenu.Button("~g~Suicide") then
					KillYourself()
				elseif
				WarMenu.CheckBox("~g~Infinite Stamina",InfStamina,function(enabled)InfStamina = enabled end)
				then
				elseif WarMenu.CheckBox("~r~Godmode", Godmode, function(enabled) Godmode = enabled end) then
				elseif
				WarMenu.CheckBox("~r~Fast Run",fastrun,function(enabled)fastrun = enabled end)
				then
				elseif
				WarMenu.CheckBox(
					"~r~Super Jump",
					SuperJump,
					function(enabled)
					SuperJump = enabled
					end)
				then
				elseif
				WarMenu.CheckBox(
					"~r~Invisible",
					Invisible,
					function(enabled)
					Invisible = enabled
					end)
				then
				elseif
				WarMenu.CheckBox("~r~Noclip",Noclip,function(enabled)Noclip = enabled end)
				then
				end

		WarMenu.Display()
			elseif WarMenu.IsMenuOpened("TeleportMenu") then

				if WarMenu.Button("~r~Teleport to waypoint") then
					TeleportToWaypoint()
			 	end


		WarMenu.Display()
			elseif WarMenu.IsMenuOpened("VisualMenu") then

			if
				WarMenu.CheckBox(
				"TriggerBot",
				TriggerBot,
				function(enabled)
				TriggerBot = enabled
				end)
			 then
			elseif
				WarMenu.CheckBox(
				"AimBot",
				AimBot,
				function(enabled)
				AimBot = enabled
				end)
			then
			elseif
				WarMenu.CheckBox(
				"ESP",
				esp,
				function(enabled)
				esp = enabled
				end)
			then
			elseif WarMenu.CheckBox("Crosshair", Crosshair, function(enabled) Crosshair = enabled end) then
			elseif WarMenu.CheckBox("Show Minimap", showMinimap, function(enabled) showMinimap = enabled end) then

			elseif WarMenu.CheckBox("Player Blips", pBlips, function(pBlips)
				end) then

				playerBlips = not playerBlips
				pBlips = playerBlips
			elseif WarMenu.CheckBox("Player Nametags", pTags, function(pTags)
				end) then
				showNametags = not showNametags
				pTags = showNametags
			elseif
				WarMenu.CheckBox(
				"~r~EMP~s~ Nearest Vehicles",
				destroyvehicles,
				function(enabled)
				destroyvehicles = enabled
				end)
			then
			elseif
				WarMenu.CheckBox(
				"~r~Explode~s~ Nearest Vehicles",
				explodevehicles,
				function(enabled)
				explodevehicles = enabled
				end)
			then
			end

		WarMenu.Display()
		elseif WarMenu.IsMenuOpened("Griefer") then

			if
				WarMenu.CheckBox(
				"~r~Explode ~w~everyone",
				blowall,
				function(enabled)
				blowall = enabled
				end)
			then
			elseif
				WarMenu.CheckBox(
				"~y~Nuker ~s~(Crash Attempt)",
				nuke,
				function(enabled)
				nuke = enabled
				end)
			then
			elseif
				WarMenu.CheckBox(
				"~g~ESX ~r~Destroyer",
				esxdestroy,
				function(enabled)
				esxdestroy = enabled
				end)
			then
			elseif
				WarMenu.CheckBox(
				"~y~Attempt Server Crash",
				servercrasher,
				function(enabled)
				servercrasher = enabled
				end)
			then
			end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("WepMenu") then
				if WarMenu.Button("~g~Give All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(PlayerPedId(), `allWeapons[i]` 1000, false, false)
					end
				elseif WarMenu.Button("~r~Remove All Weapons") then
					for i = 1, #allWeapons do
						RemoveAllPedWeapons(PlayerPedId(), true)
					end
				elseif WarMenu.Button("~r~Give All Weapons to everyone") then
					for ids = 0, 256 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								GiveWeaponToPed(PlayerPedId(ids), `allWeapons[i]`, 1000, false, false)
					end
				end
			end
				elseif WarMenu.Button("~r~Remove All Weapons from everyone") then
					for ids = 0, 256 do
						if ids ~= PlayerId() and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
							RemoveAllPedWeapons(PlayerPedId(ids), true)
				end
			end
		end
				elseif WarMenu.Button("Give Ammo") then
					for i = 1, #allWeapons do
						AddAmmoToPed(PlayerPedId(), `allWeapons[i]`, 200)
					end
				elseif WarMenu.MenuButton("Give Specific Weapon", "SingleWepMenu") then
				elseif
					WarMenu.ComboBox(
						"Weapon/Melee Damage",
						{"1x (Default)", "2x", "3x", "4x", "5x"},
						currentItemIndex,
						selectedItemIndex,
						function(currentIndex, selectedIndex)
							currentItemIndex = currentIndex
							selectedItemIndex = selectedIndex
							SetPlayerWeaponDamageModifier(PlayerId(), selectedItemIndex)
							SetPlayerMeleeWeaponDamageModifier(PlayerId(), selectedItemIndex)
						end
					)
				 then
				elseif
					WarMenu.CheckBox(
						"~r~ONE SHOT KILL",
						oneshot,
						function(enabled)
							oneshot = enabled
						end)
				 then
				 elseif
				 WarMenu.CheckBox(
					 "Infinite Ammo",
					 InfAmmo,
					 function(enabled)
						 InfAmmo = enabled
						 SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo)
					 end)
			  then
				 elseif
					 WarMenu.CheckBox("Vehicle Gun",VehicleGun,
				 	 function(enabled)VehicleGun = enabled end)
			 	then
			 	elseif
					 WarMenu.CheckBox("Delete Gun",DeleteGun,
				 	 function(enabled)DeleteGun = enabled end)
			 	then
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("SingleWepMenu") then
				for i = 1, #allWeapons do
					if WarMenu.Button(allWeapons[i]) then
						GiveWeaponToPed(PlayerPedId(), `allWeapons[i]`), 1000, false, false)
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("VehMenu") then

				if WarMenu.Button("~g~Spawn Vehicle") then
					local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 20)
					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true)

						SetPedIntoVehicle(PlayerPedId(), veh, -1)
					else
						drawNotification("~r~Model is not valid!")
					end
				elseif WarMenu.Button("~r~Delete Vehicle") then
					if _pVehicle then
						DelVeh(GetVehiclePedIsUsing(PlayerPedId()))
						drawNotification("~g~SUCCESS: ~w~Vehicle deleted")
					else
						drawNotification("~r~ERROR: ~w~You're not in a vehicle")
					end
				elseif WarMenu.MenuButton("LS Customs", "LSC") then
				elseif WarMenu.Button("Flip Vehicle") then
					local playerPed = GetPlayerPed(-1)
					local playerVeh = GetVehiclePedIsIn(playerPed, true)
					if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
						SetVehicleOnGroundProperly(playerVeh)
						drawNotification("~g~Vehicle Flipped!")
					else
						drawNotification("~r~You Aren't In The Driverseat Of A Vehicle!")
					end
				elseif WarMenu.Button("Repair Vehicle") then
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)

				elseif WarMenu.Button("Change License Plate") then
					local playerPed = GetPlayerPed(-1)
					local playerVeh = GetVehiclePedIsIn(playerPed, true)
					local result = KeyboardInput("Enter new plate text", "", 10)
					if result then
						SetVehicleNumberPlateText(playerVeh, result)
					end

				elseif WarMenu.Button("Max Tuning") then
					MaxOut(GetVehiclePedIsUsing(PlayerPedId()))
				elseif
					WarMenu.CheckBox(
					"Rainbow Vehicle Colour",
					RainbowVeh,
					function(enabled)
					RainbowVeh = enabled
					end)
				then
				elseif WarMenu.CheckBox("Ghetto Police Car", ghettopolice, function(enabled) ghettopolice = enabled end) then
				elseif WarMenu.Button("Make vehicle dirty") then
					Clean(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle is now dirty")
				elseif WarMenu.Button("Make vehicle clean") then
					Clean2(GetVehiclePedIsUsing(PlayerPedId()))
					drawNotification("Vehicle is now clean")
				elseif
					WarMenu.CheckBox(
						"Seatbelt",
						Seatbelt,
						function(enabled)
							Seatbelt = enabled

							SetPedCanBeKnockedOffVehicle(PlayerPedId(), Seatbelt)
						end)
				 then
				elseif
					WarMenu.CheckBox(
						"Vehicle Godmode",
						VehGod,
						function(enabled)
							VehGod = enabled
						end
					)
				 then
				elseif
					WarMenu.CheckBox(
					"Speedboost ~g~SHIFT ~r~CTRL",
						VehSpeed,
						function(enabled)
						VehSpeed = enabled
						end)
				then
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("LSC") then
				if _pVehicle then
					if WarMenu.MenuButton("Visual Tuning", "tunings") then
					elseif WarMenu.MenuButton("Performance Tuning", "performance") then
					end
				else
					if WarMenu.Button("No vehicle found") then
					end
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("tunings") then
				for i,theItem in pairs(vehicleMods) do
					if theItem.id == "extra" and #checkValidVehicleExtras() ~= 0 then
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
						local valid = checkValidVehicleMods(theItem.id)
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
				for i,theItem in pairs(perfMods) do
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
				for theName,thePaint in pairs(paintsClassic) do
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
				for theName,thePaint in pairs(paintsClassic) do
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
				for theName,thePaint in pairs(paintsMatte) do
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
				for theName,thePaint in pairs(paintsMetal) do
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
				for theName,thePaint in pairs(paintsClassic) do
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
				for theName,thePaint in pairs(paintsClassic) do
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
				for theName,thePaint in pairs(paintsMatte) do
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
				for theName,thePaint in pairs(paintsMetal) do
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
				for theName,thePaint in pairs(paintsClassic) do
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
				for theName,thePaint in pairs(paintsClassic) do
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
				for theName,thePaint in pairs(paintsMatte) do
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
				for theName,thePaint in pairs(paintsMetal) do
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

			for i,theItem in pairs(vehicleMods) do

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
						local extras = checkValidVehicleExtras()
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
										SetVehicleExtra(veh, i, not IsVehicleExtraTurnedOn(veh,i))
									end
								else
									SetVehicleExtra(veh, i, not IsVehicleExtraTurnedOn(veh,i))
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


						for i,theItem in pairs(neonColors) do
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
						local valid = checkValidVehicleMods(theItem.id)
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
								for chorn,HornId in pairs(horns) do
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

			for i,theItem in pairs(perfMods) do
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

				if WarMenu.MenuButton("~g~ESX ~s~BOSS Menus", "ESXBoss") then
				elseif WarMenu.MenuButton("~g~ESX ~s~Money Options", "ESXMoney") then
				elseif WarMenu.MenuButton("~g~ESX ~s~Misc Options", "ESXMisc") then
				elseif WarMenu.MenuButton("~g~ESX ~s~Drugs", "ESXDrugs") then
				elseif WarMenu.MenuButton("~b~VRP ~s~Server Options", "VRPOptions") then
				elseif WarMenu.MenuButton("~o~Misc ~s~Options", "MiscServerOptions") then
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("MenuSettings") then

				if WarMenu.MenuButton("Change Color Theme", "MenuSettingsColor") then
				end
				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("MenuSettingsColor") then
				if WarMenu.Button("Menu Color: ~r~Red") then
					_menuColor = colorRed
				elseif WarMenu.Button("Menu Color: ~g~Green") then
					_menuColor = colorGreen
				elseif WarMenu.Button("Menu Color: ~b~Blue") then
					_menuColor = colorBlue
				elseif WarMenu.Button("Menu Color: ~p~Purple") then
					_menuColor = colorPurple
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("ESXBoss") then

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
			elseif WarMenu.IsMenuOpened("ESXMoney") then

			if WarMenu.Button("~g~ESX ~y~Caution Give Back") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
				TriggerServerEvent('esx_jobs:caution', 'give_back', result)
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
				elseif WarMenu.IsMenuOpened("ESXMisc") then

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
			elseif WarMenu.IsMenuOpened("MiscServerOptions") then

				if WarMenu.Button("Send Discord Message") then
					local Message = KeyboardInput("Enter message to send", "", 100)
					TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
					drawNotification("The message:~n~" .. Message .. "~n~has been ~g~sent!")
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
						TriggerServerEvent('esx_muggings:giveItems', (itemName))
						drawNotification("Successfully given item ~g~" .. itemName)
					else
						drawNotification("~r~You must specify an item")
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("VRPOptions") then

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
			elseif WarMenu.IsMenuOpened("ESXDrugs") then

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
			elseif WarMenu.IsMenuOpened("OnlinePlayerMenu") then
					for i = 0, 256 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and WarMenu.MenuButton(GetPlayerName(i).." ~b~#"..GetPlayerServerId(i).."~s~ ~r~" .. i .. " "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~r~DEAD " or "~g~ALIVE ")..(IsPedInAnyVehicle(GetPlayerPed(i), true) and "~o~VEHICLE" or ""), 'PlayerOptionsMenu') then
						SelectedPlayer = i
					end
				end


				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("PlayerOptionsMenu") then

				WarMenu.SetSubTitle("PlayerOptionsMenu", "Player Options [" .. GetPlayerName(SelectedPlayer) .. "]")
				if WarMenu.Button("Spectate", (Spectating and "~g~[SPECTATING]")) then
					SpectatePlayer(SelectedPlayer)
				elseif WarMenu.Button("Teleport To Player") then
					local Entity = IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
					SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
				elseif WarMenu.MenuButton("~b~Vehicle Options", "VehMenuPlayer") then
				elseif WarMenu.MenuButton("~b~ESX Options", "ESXMenuPlayer") then
				elseif WarMenu.MenuButton("Give Single Weapon", "SingleWepPlayer") then
				elseif WarMenu.Button("~r~Silent Explode") then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, false, true, 0)
				elseif WarMenu.Button("~y~Explode") then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, true, false, 100000.0)
				elseif WarMenu.Button("Give All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), `allWeapons[i]`, 250, false, false)
					end
				elseif WarMenu.Button("Remove All Weapons") then
					RemoveAllPedWeapons(GetPlayerPed(SelectedPlayer), true)
				end


				WarMenu.Display()

			elseif WarMenu.IsMenuOpened("ESXMenuPlayer") then
				if WarMenu.Button("~g~ESX ~s~Send Bill") then
					local amount = KeyboardInput("Enter Amount", "", 10)
					local name = KeyboardInput("Enter the name of the Bill", "", 25)
					if amount and name then
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(SelectedPlayer), "Purposeless", name, amount)
					end
				elseif WarMenu.Button("~g~ESX ~s~Handcuff Player") then
					TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(SelectedPlayer))
				elseif WarMenu.Button("~g~ESX ~s~Revive player") then
					TriggerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
				elseif WarMenu.Button("~g~ESX ~s~Unjail player") then
					TriggerServerEvent("esx_jail:unjailQuest", GetPlayerServerId(SelectedPlayer))
					TriggerServerEvent("js:removejailtime", GetPlayerServerId(SelectedPlayer))
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("SingleWepPlayer") then
				WarMenu.SetSubTitle("SingleWepPlayer", "Give Weapon [" .. GetPlayerName(SelectedPlayer) .. "]")
				for i = 1, #allWeapons do
					if WarMenu.Button(allWeapons[i]) then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), `allWeapons[i]`, 1000, false, true)
					end
				end

				WarMenu.Display()
			elseif WarMenu.IsMenuOpened("VehMenuPlayer") then
				WarMenu.SetSubTitle("VehMenuPlayer", "Vehicle Options [" .. GetPlayerName(SelectedPlayer) .. "]")
				if WarMenu.Button("Spawn Vehicle") then
					local ModelName = KeyboardInput("Enter Vehicle Model Name", "", 100)
					if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
						RequestModel(ModelName)
						while not HasModelLoaded(ModelName) do
							Citizen.Wait(0)
						end

						local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(GetPlayerPed(SelectedPlayer)), GetEntityHeading(GetPlayerPed(SelectedPlayer)), true, true)

						SetPedIntoVehicle(GetPlayerPed(SelectedPlayer), veh, -1)
						drawNotification("Successfully spawned ~g~".. ModelName .. " ~w~on ~p~" .. GetPlayerName(SelectedPlayer))
					else
						drawNotification("~r~Model is not valid!")
					end
				elseif WarMenu.Button("Give Owned Vehicle") then
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
						drawNotification("Success")
					else
						drawNotification("~r~Model is not valid!")
					end

				elseif WarMenu.Button("Kick From Vehicle") then
					ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))

				elseif WarMenu.Button("Destroy Engine") then
					local playerPed = GetPlayerPed(SelectedPlayer)
					NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
					SetVehicleUndriveable(GetVehiclePedIsIn(playerPed),true)
					SetVehicleEngineHealth(GetVehiclePedIsIn(playerPed), 100)

				elseif WarMenu.Button("Repair Vehicle") then
					NetworkRequestControlOfEntity(GetVehiclePedIsIn(SelectedPlayer))
					SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false))
					SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0.0)
					SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)
					SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), false)
					Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), 0)

				elseif WarMenu.Button("Fuck Up His Car") then
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
					SetVehicleNumberPlateText(playerVeh, "NIGGER")
					SetVehicleDirtLevel(playerVeh, 10.0)
					SetVehicleModColor_1(playerVeh, 1)
					SetVehicleModColor_2(playerVeh, 1)
					SetVehicleCustomPrimaryColour(playerVeh, 231, 76, 60) -- r = 231, g = 76, b = 60
					SetVehicleCustomSecondaryColour(playerVeh, 231, 76, 60)
					SetVehicleBurnout(playerVeh, true)
					drawNotification("~g~Vehicle Fucked Up!")
				end
				WarMenu.Display()
			elseif IsDisabledControlPressed(0, 121) then
				local name = GetPlayerName(PlayerId())
				_buyer = "LUX"
				if _gatekeeper then
					if name == _buyer then
						WarMenu.OpenMenu("LuxMainMenu")
					else
						drawNotification("~r~ERROR: ~w~You don't appear to own ~h~LUX MENU")
					end
				else
					local input = KeyboardInput("Enter the keycode", "", 10)
					if input == _secretKey then
						_gatekeeper = true
						drawNotification("~g~SUCCESS: ~w~Keycode validated.")
					else
						drawNotification("~r~ERROR: ~w~Invalid keycode")
					end
				end
			end

			Citizen.Wait(0)
		end
	end
)

RegisterCommand("killmenu", function(source,args,raw)
	Enabled = false
end, false)
