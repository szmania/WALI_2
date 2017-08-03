module(..., package.seeall)

mach_data = require "WALI/MACH_data"
ti_lib = require "WALI/TI_lib"

machLog_funcName = ""
machLogFile = "data/WALI/Logs/MACH_log.txt"
debugMode = true

-- Build artillery to gun type list
-- @return: artillery type to gun type list
function build_artillery_to_gun_type_list()
	machLog_funcName = "MACH_lib.build_artillery_to_gun_type_list"
	update_mach_lua_log("Building artyToGunType_list[] list.")

  local artyToGunType_list = {}
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/ArtyToGunType.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		artyToGunType_list[count] = line:split("\"")
		count = count + 1
	end
	file:close()
  return artyToGunType_list
end


-- Build settlement besieged list list
-- @return: settlement besieged list
function build_besieged_settlements_list()
  machLog_funcName = "build_besieged_settlements_list"
	update_mach_lua_log("determineBesiegedSettlements: Building beseiged settlement list.")

	besiegedSettlements_list = {}
  local besiegedSettlements_list = {}
	local region_key = nil
	local distance = nil
	local army_besiege_settlement = false
	
	local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
	for kk, vv in pairs(faction_list) do

		local diplomacy = CampaignUI.RetrieveDiplomacyDetails(vv.Key)	
		
		for k, v in pairs(diplomacy.AtWar) do
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(k, true)
			
			for i = 1, #forcesList do
				army = forcesList[i]

				local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(vv.Key)

				for k = 1, #regions do

					region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
					distance = mach_lib.find_distance(army.PosX, army.PosY, region_capital_coord_list[region_key][1], region_capital_coord_list[region_key][2])		
				
					if (distance < 1.5) and (distance > -1.5) and (distance ~= nil) then

						army_besiege_settlement = true
						besiegedSettlements_list[#besiegedSettlements_list + 1] = region_key

					end

				end

			end
		end		
	end
end


-- Build character names localisation list
-- @return: character localisation names list
function build_character_names_list()
	machLog_funcName = "MACH_lib.build_character_names_list"
	update_mach_lua_log("Building characterNames_list[] list.")

  local characterNames_list = {}
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/CharacterNames.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		characterNames_list[count] = line:split("\"")
		count = count + 1
	end
	file:close()
  return characterNames_list
end

-- Build region names localisation list
-- @return: region localisation names list
function build_region_names_list()
  machLog_funcName = "MACH_lib.build_region_names_list"
	update_mach_lua_log("Building regionNames_list[] list.")
	
  local regionNames_list = {}
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/RegionNames.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		regionNames_list[count] = line:split("\"")
		count = count + 1
	end
	file:close()
  return regionNames_list
end


-- Build settlement names localisation list
-- @return: settlement localisation names list
function build_settlement_names_list()
	machLog_funcName = "MACH_lib.build_settlement_names_list"
	update_mach_lua_log("Building settlementNames_list[] list.")
  
  local settlementNames_list = {}
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/SettlementNames.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		settlementNames_list[count] = line:split("\"")
		--update_mach_lua_log(settlementNames_list[count][2])
		count = count + 1
	end
	file:close()
  return settlementNames_list
end



--Creates a new MACH log in the logging directory

-- Creates MACH log
function create_mach_lua_log()
	local ErrorLog = io.open(machLogFile,"w")
	local DateAndTime = os.date("%H:%M.%S")
	ErrorLog:write("Log Created: "..DateAndTime)
	ErrorLog:close()
end



-- Find distance from (x1, y1) to (x2, y2)
-- @param x1: x1 coordinate
-- @param y1: y1 coordinate
-- @param x2: x2 coordinate
-- @param y2: y2 coordinate
-- @return distance as double
function find_distance( x1, y1, x2, y2 )
      local dx = x1 - x2
      local dy = y1 - y2
      return math.sqrt ( dx * dx + dy * dy )
end


-- Determine number of artillery an artillery unit has according to its number of men
-- @param men: number of men as integer
-- @return: number of artillery pieces as integer
function get_artillery_num_from_men_count(men)
	-- FIND REMAINDER EQUATION: a - math.floor(a/b)*b
	men = tonumber(men)
	if(men > 0) and (men < 7) then
		return 1
	elseif(men == 7) then
		return 2
	end
  
  
	--determine for 5 and remainder
	local remainder = 0
	remainder = men - (math.floor(men / 5) * 5)
		
	if(remainder == 0) then
		return men / 5
	elseif(remainder == 1) then
		return math.floor(men / 5)
	elseif(remainder > 1) then
		--if math.floor(men / 5) < math.floor(men / 4) then
		--	return math.floor(men / 5)
		--else
		--	return math.floor(men / 4)
		--end
		return math.floor((men / 5)) + 1

  end
end

-- Get current slot id from slot context
-- @param slot_context: Slot context
-- @return: slot id as string
function get_current_slot(slot_context)
  LastSearchSlot = "town:england:cambridge"

  if conditions.SlotName(LastSearchSlot, slot_context) then
    return LastSearchSlot
  end
  for kk, vv in pairs(mach_data.slotsList) do
    if conditions.SlotName(kk, slot_context) then
      LastSearchSlot = kk
      return kk
    end
  end
  return "No ID slot"
end


-- return factionsList list from TI_lib.lua
-- @return: list of factions
function get_factions_list()
	return ti_lib.factionsList
end



function isINF(value)
  return value == math.huge or value == -math.huge
end

function isNAN(value)
  return value ~= value
end

-- Pop up message box.
-- @param msg: String to display in pop up message box.
function msg_box(msg)
    local utils = require("Utilities")
		local panel_manager = utils.Require("panelmanager")
    panel_manager.OpenPanel("dialogue_box", true, "Initialise", msg)
end

-- Round value to given decimal places
-- @param num: value to be rounded as dboule
-- @param idp: number of decimal places as integer
-- @return: rounded value
function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end


-- This function prints all global variables to MACH log
-- @param obj: Object to check globals for.
-- @param str: Name of object to check.
local seen={}

function output_globals_to_log(obj,str)

	seen[t]=true
	local s={}
	local n=0
	for k in pairs(obj) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		update_mach_lua_log(tostring(str).."- "..tostring(v))
		v=t[v]
		if type(v)=="table" and not seen[v] then
			outpu_globals_to_log(v,str.."\t")
		end
	end
end

-- Set Debug Mode.
-- @param value: boolean value to set for debugging and logging. Must be set to true for logging.
function set_debug(value)
  debugMode = value
end

-- Set MACH log function name prefix for logging.
-- @param name: Function name as string.
function set_mach_log_func_name(name)
  machLog_funcName = name
end


-- Writes to the MACH log file
-- @param update_arg: what to write to mach log file as string
function update_mach_lua_log(update_arg)
	if not debugMode then
		return 
	end
	local DateAndTime = os.date("%H:%M.%S")
  local funcName = machLog_funcName
	local U_Log = io.open(machLogFile,"a")

	if type(update_arg) ~= "nil" then
    U_Log:write("\n["..DateAndTime.."]\t\t"..tostring(funcName)..": "..tostring(update_arg))
	elseif type(update_arg) == "nil" then
		U_Log:write("\n["..DateAndTime.."]\t\tLogging error: input type nil")
	end
	U_Log:close()
end



