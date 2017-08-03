module(..., package.seeall)

WALI = require "WALI/WALI"
mach_lib = require "WALI/MACH_lib"
mach_data = require "WALI/MACH_data"
ti_lib = require "WALI/TI_lib"

local scripting = require "EpisodicScripting"
local utils = require("utilities")
local core = require("CoreUtils")
--local out = require("out")

mach_lib.set_debug(true)

local WALI_m_root = nil --the UI root
local WALI_isOnCampMap = false
local WALI_isFirstClickOnArmy = false
local WALI_armyIsSelected = false
local WALI_previouslySelectedCharacterPointer = nil
local playerFactionId = nil
local prevContext = nil
local prevCallTime = nil
local selectedCharacterContext = nil
local env = ""
local configError = ""
local configFile = ""


local characterNames_list = {}
local regionNames_list = {}
local settlementNames_list = {}
local artyToGunType_list = {}
--local besiegedSettlements_list = {}


-- Initialise MACH 
function initialise_mach()
  mach_lib.create_mach_lua_log()
  --mach_lib.machLog_funcName("MACH.initialise_mach")
  mach_lib.set_mach_log_func_name("MACH.initialise_mach")
  
  mach_lib.update_mach_lua_log("Initializing Machiavelli's Mods.")
  
  characterNames_list = mach_lib.build_character_names_list()
  regionNames_list = mach_lib.build_region_names_list()
  settlementNames_list = mach_lib.build_settlement_names_list()
  artyToGunType_list = mach_lib.build_artillery_to_gun_type_list()
end


-- This function executes when a character is selected on the campaign map
-- @param contect: character context
local function on_character_selected(context)
  mach_lib.set_mach_log_func_name("MACH.on_character_selected")
	mach_lib.update_mach_lua_log("Character Selected.")

	selectedCharacterContext = context
end

-- This function executes when the left mouse button click is released
-- @param contect: mouse click context
local function on_component_left_click_up(context)
  mach_lib.set_mach_log_func_name("MACH.on_component_left_click_up")

	mach_lib.update_mach_lua_log("Left Mouse Click Event.")

	if WALI_isOnCampMap then
		local ETS = CampaignUI.EntityTypeSelected()
		if not ETS.Character and not ETS.Unit then
			WALI_isFirstClickOnArmy = false
			WALI_armyIsSelected = false
			--set this to nil here in case player clicks army X -> other non-army object -> army x again,
			--in which case checks would fail
			WALI_previouslySelectedCharacterPointer = nil
		end
	end
end


-- This function executes on faction turn start.
-- @param contect: faction context
local function on_faction_turn_start(context)
  mach_lib.set_mach_log_func_name("MACH.on_faction_turn_start")
  mach_lib.update_mach_lua_log("Faction turn start.")
  
	--create_armyInfoTableForTurn()
	local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
	for k, v in pairs(faction_list) do
		if conditions.FactionName(v.Key, context) then
			playerFactionId = v.Key
			mach_lib.update_mach_lua_log("\t\t Current Faction Turn: "..playerFactionId)

		end
	end

end



-- This function executes when UI is created
-- @param contect: UI context
local function on_ui_created(context)
  mach_lib.set_mach_log_func_name("MACH.on_ui_created")
	mach_lib.update_mach_lua_log("UI Created.")

	if context.string == "Campaign UI" then
		WALI_isOnCampMap = true
		WALI_m_root = UIComponent(context.component)
	end	

	playerFactionId = CampaignUI.PlayerFactionId()
		
	mach_lib.update_mach_lua_log("Building global lists.")

end


scripting.AddEventCallBack("CharacterSelected", on_character_selected)
scripting.AddEventCallBack("ComponentLClickUp", on_component_left_click_up)
scripting.AddEventCallBack("FactionTurnStart", on_faction_turn_start)
scripting.AddEventCallBack("UICreated", on_ui_created)

