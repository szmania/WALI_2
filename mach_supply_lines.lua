module(..., package.seeall)

WALI = require "WALI/WALI"
mach_lib = require "WALI/mach_lib"
mach_data = require "WALI/mach_data"
mach_classes = require "WALI/mach_classes"
ti_lib = require "WALI/TI_lib"

__enemy_faction_armies_with_supply_lines__ = {}


function mach_supply_lines()
	mach_lib.update_mach_lua_log("Activating Machiavelli's supply lines")


    mach.__mach_features_enabled__[#mach.__mach_features_enabled__+1] = "MACH Supply Lines"

    local scripting = require "EpisodicScripting"

	local totalCount = 0
	local totalFound = 0
	local firstCharacter = true
	local current_faction_turn = nil
	local __character_selected_event__ = nil
	local character_details = nil

	local prevEffectTime = 0
	local prevCharacterAddress = nil

	local regionForcesTable = {}
	local noSupplyForces = {}
	local blockingSupplyForces = {}
	local long_supply_army_table = {}
	local navalArmySupplierTable = {}

    local faction_armies_with_supply_lines = {}
    local faction_army_supplies = {}

--    local function collect_long_supply_line_armies(faction_key, army, nearest_distance, nearest_region_capitol, army_is_in_settlement)
--        --determine if long supply line
--        if nearest_distance > WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_1__ and faction_key == current_faction_turn and not (army_is_in_settlement) then
--            local found = false
--            local ind = nil
--            for r = 1, #long_supply_army_table do
--                if long_supply_army_table[r][2] == tostring(army.Name) then
--                    mach_lib.update_mach_lua_log("\t\t Army already in long_supply_army_table. Modifying current values.")
--                    long_supply_army_table[r][3] = nearest_distance --region_capital_distance from region capital
--                    long_supply_army_table[r][4] = tostring(nearest_region_capitol) --region key
--                    found = true
--                elseif long_supply_army_table[r] == nil then
--                    ind = r
--                end
--            end
--
--            if ind == nil then
--                ind = #long_supply_army_table + 1
--            end
--
--            if found == false then
--                mach_lib.update_mach_lua_log("Found army with long supply line. Adding to long_supply_army_table.")
--
--                --mach_lib.update_mach_lua_log("HI "..faction_key.."-"..nearest.."-"..tostring(military_forces_list[i].Name).."-"..tostring(nearest_friendly_region_capital))
--                long_supply_army_table[ind] = {}
--                mach_lib.update_mach_lua_log("\t\t\t Faction key :"..faction_key)
--                long_supply_army_table[ind][1] = faction_key --faction_key key
--                mach_lib.update_mach_lua_log("\t\t\t Commander's name: "..tostring(army.Name))
--                long_supply_army_table[ind][2] = tostring(army.Name) --commander's name
--                mach_lib.update_mach_lua_log("\t\t\t Distance from nearest supply location:"..tostring(nearest_distance))
--                long_supply_army_table[ind][3] = nearest_distance --region_capital_distance from region capital
--                mach_lib.update_mach_lua_log("\t\t\t Nearest supply location:"..tostring(nearest_region_capitol))
--                long_supply_army_table[ind][4] = tostring(nearest_region_capitol) --region key
--            end
--
--        else
--            for r = 1, #long_supply_army_table do
--                if long_supply_army_table[r][2] == tostring(army.Name) then
--                    long_supply_army_table[r] = {}
--                end
--            end
--        end
--
--    end

--    local function get_character_details_from_character_context(context)
--        mach_lib.update_mach_lua_log("Getting character details")
--
--        local ETS = CampaignUI.EntityTypeSelected()
--        local CharacterAddress = nil
--        local __MACH_PREVIOUSLY_SELECTED_CHARACTER_POINTER__ = nil
--        if conditions.CharacterType("admiral", context) then
--            mach_lib.update_mach_lua_log("Character is a admiral.")
--            character_details = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
--            CharacterAddress, previously_selected_character_pointer = ETS.Entity
--        elseif conditions.CharacterType("captain", context) then
--            mach_lib.update_mach_lua_log("Character is a captain.")
--            local unit_details = CampaignUI.InitialiseUnitDetails(ETS.Entity)
--            character_details =  CampaignUI.InitialiseCharacterDetails(unit_details.CharacterPtr)
--            CharacterAddress, previously_selected_character_pointer = unit_details.CharacterPtr
--        elseif conditions.CharacterType("General", context) then
--            mach_lib.update_mach_lua_log("Character is a General.")
--            character_details = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
--            CharacterAddress, previously_selected_character_pointer = ETS.Entity
--        elseif conditions.CharacterType("colonel", context) then
--            mach_lib.update_mach_lua_log("Character is a colonel.")
--            local unit_details = CampaignUI.InitialiseUnitDetails(ETS.Entity)
--            character_details =  CampaignUI.InitialiseCharacterDetails(unit_details.CharacterPtr)
--            CharacterAddress, previously_selected_character_pointer = unit_details.CharacterPtr
--        end
--        return CharacterAddress, previously_selected_character_pointer
--    end

    -- naval traits start
    local function add_naval_military_character_traits(context)
        mach_lib.update_mach_lua_log("Adding naval military character traits (admiral and captain).")

        local character_details = mach_lib.get_character_details_from_character_context(context, "CharacterSelected")
        local character_address, character_pointer = get_character_address_and_pointer(context)
        local entity_type_selected = CampaignUI.EntityTypeSelected()

        --local besiegedSettlements_list = mach_lib.build_besieged_settlements_list()

        local found = naval_army_supplier(context)

        if found == true then
            local good_count = conditions.CharacterTrait("C_Admiral_NavalArmySupplier_Good", context)
            local bad_count = conditions.CharacterTrait("C_Admiral_NavalArmySupplier_Bad", context)
            local target = 1 - good_count

            if good_count <= 0 then

                for h = 1, target do
                    effect.trait("C_Admiral_NavalArmySupplier_Good", "agent", 1, 100, context)
                    --effect.trait("C_Admiral_NavalArmySupplier_Good", "agent", 1, 100, context)al_NavalArmySupplier_Good_
                    mach_lib.update_mach_lua_log("Added \"C_Admir"..math.abs(target).."\" trait to ".. character_details.Name)
                end
            end
        elseif found == false then
            local good_count = conditions.CharacterTrait("C_Admiral_NavalArmySupplier_Good", context)
            local bad_count = conditions.CharacterTrait("C_Admiral_NavalArmySupplier_Bad", context)
            local target = good_count

            if good_count > 0 then

                for h = 1, target do
                    effect.remove_trait("C_Admiral_NavalArmySupplier_Good", "agent", context)

                    --effect.trait("C_Admiral_NavalArmySupplier_Bad", "agent", 1, 100, context)
                    mach_lib.update_mach_lua_log("Removed \"C_Admiral_NavalArmySupplier_Good_"..math.abs(target).."\" trait from ".. character_details.Name)

                end
            end
        end
    end


    --get region_capital_distance of enemy units from the line of supply (to determine if interrupting supply)
    local function collect_enemy_armies_cutting_off_supply_line(slope, y_intercept, index, faction)
        mach_lib.update_mach_lua_log("Gathering enemy armies cutting off supply line.")

        local diplomacy = CampaignUI.RetrieveDiplomacyDetails(faction)
        local count = 0

        for k, v in pairs(diplomacy.AtWar) do
            if (blockingSupplyForces[k] ~= nil) then
                for p = 1, #blockingSupplyForces[k] do
                    count = count + 1
                end
            else
                blockingSupplyForces[k] = {}
            end

            local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(k, true)
            for i = 1, #forcesList do
                local PosX = forcesList[i].PosX
                local PosY = forcesList[i].PosY

                if not (((regionForcesTable[index][1] - regionForcesTable[index][3] > -0.001) and (regionForcesTable[index][1] - regionForcesTable[index][3] < 0.001)) and ((regionForcesTable[index][2] - regionForcesTable[index][4] > -0.001) and (regionForcesTable[index][2] - regionForcesTable[index][4] < 0.001))) and not (armyInSettlement(k, forcesList[i])) then
                    local inverse_slope = ((regionForcesTable[index][1] - regionForcesTable[index][3]) / (regionForcesTable[index][2] - regionForcesTable[index][4])) * -1
                    local enemy_y_intercept = PosY - (PosX * inverse_slope)
                    local x_intersection = (y_intercept - enemy_y_intercept) / (inverse_slope - slope)
                    local y_intersection = (x_intersection * slope) + y_intercept

                    if (((x_intersection <= regionForcesTable[index][1]) and (x_intersection >= regionForcesTable[index][3])) or ((x_intersection <= regionForcesTable[index][3]) and (x_intersection >= regionForcesTable[index][1]))) then

                        if (((y_intersection <= regionForcesTable[index][2]) and (y_intersection >= regionForcesTable[index][4])) or ((y_intersection <= regionForcesTable[index][4]) and (y_intersection >= regionForcesTable[index][2]))) then

                            if (mach_lib.find_distance(PosX, PosY, x_intersection, y_intersection) <= WALI.__MACH_MAX_DISTANCE_ALLOWED_FROM_ENEMY_SUPPLY_LINE__) then

                                local duplicate = false
                                local ind = nil
                                if noSupplyForces[faction] == nil or #noSupplyForces[faction] == 0 then
                                    noSupplyForces[faction] = {}
                                    ind = 1
                                else
                                    if #noSupplyForces[faction] > 0 then
                                        ind = #noSupplyForces[faction]+1
                                        for m = 1, #noSupplyForces[faction] do
                                            if noSupplyForces[faction][m][1] == regionForcesTable[index][5] then
                                                duplicate = true
                                            end
                                        end
                                    end
                                end
                                if duplicate == false then
                                    local num = totalCount + 1
                                    mach_lib.update_mach_lua_log(num..": "..forcesList[i].Name.." is blocking the supply lines of "..regionForcesTable[index][5])
                                    noSupplyForces[faction][ind] = {}
                                    noSupplyForces[faction][ind][1] = regionForcesTable[index][5]
                                    noSupplyForces[faction][ind][2] = regionForcesTable[index][6]
                                    noSupplyForces[faction][ind][3] = forcesList[i].Name
                                end


                                local foundMatch = false
                                if #blockingSupplyForces[k] > 0 then
                                    for p = 1, #blockingSupplyForces[k] do
                                        if blockingSupplyForces[k][p][1] == forcesList[i].Name then
                                            foundMatch = true
                                        end
                                    end
                                end
                                if foundMatch == false then

                                    if #blockingSupplyForces[k] > 0 then
                                        local fixed = false
                                        for p = 1,  #blockingSupplyForces[k] do

                                            if blockingSupplyForces[k][p][1] == nil then
                                                fixed = true
                                                blockingSupplyForces[k][p] = {}
                                                blockingSupplyForces[k][p][1] = forcesList[i].Name
                                                blockingSupplyForces[k][p][2] = CampaignUI.CurrentTurn()
                                                blockingSupplyForces[k][p][3] = regionForcesTable[index][5]
                                                blockingSupplyForces[k][p][4] = regionForcesTable[index][6]
                                            end
                                        end
                                        if fixed == false then
                                            local ind = #blockingSupplyForces[k] + 1
                                            blockingSupplyForces[k][ind] = {}
                                            blockingSupplyForces[k][ind][1] = forcesList[i].Name
                                            blockingSupplyForces[k][ind][2] = CampaignUI.CurrentTurn()
                                            blockingSupplyForces[k][ind][3] = regionForcesTable[index][5]
                                            blockingSupplyForces[k][ind][4] = regionForcesTable[index][6]
                                        end
                                    else
                                        blockingSupplyForces[k][1] = {}
                                        blockingSupplyForces[k][1][1] = forcesList[i].Name
                                        blockingSupplyForces[k][1][2] = CampaignUI.CurrentTurn()
                                        blockingSupplyForces[k][1][3] = regionForcesTable[index][5]
                                        blockingSupplyForces[k][1][4] = regionForcesTable[index][6]
                                    end
                                end
                                totalCount = totalCount + 1
                            else


                                if #blockingSupplyForces[k] > 0 then
                                    for p = 1, #blockingSupplyForces[k] do
                                        if blockingSupplyForces[k][p][1] == forcesList[i].Name and not blockingSupplyForces[k][p][2] == CampaignUI.CurrentTurn() then
                                            --mach_lib.update_mach_lua_log("eeerereef "..k.."-"..faction_key.." - "..forcesList[i].Name)
                                            blockingSupplyForces[k][p][1] = nil
                                        elseif blockingSupplyForces[k][p][1] == forcesList[i].Name and k == CampaignUI.PlayerFactionId() then
                                            blockingSupplyForces[k][p][1] = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    end


    local function _get_nearest_friendly_fleet(army)
        mach_lib.update_mach_lua_log("Getting nearest friendly fleet from army under command of: ".. army.commander_name)

        local friendly_fleet_distance = false
        local nearest_friendly_fleet_commander = nil
        local nearest_friendly_fleet = nil
        local nearest_friendly_fleet_distance = 99999999
        local nearest_friendly_fleet_x = 0
        local nearest_friendly_fleet_y = 0
        local army_x = 0
        local army_y = 0

--        mach_lib.output_table_to_mach_log(army)

        --determine region_capital_distance from naval force

        local faction_naval_forces = mach_lib.get_faction_naval_forces(army.faction_key)

--            local naval_forces = CampaignUI.RetrieveFactionMilitaryForceLists(faction_key, false)
        for faction_naval_forces_key, faction_naval_force in pairs(faction_naval_forces) do

            friendly_fleet_distance = mach_lib.find_distance(army.pos_x, army.pos_y, faction_naval_force.pos_x, faction_naval_force.pos_y)

            if(friendly_fleet_distance < nearest_friendly_fleet_distance) and (friendly_fleet_distance ~= nil) and (friendly_fleet_distance ~= 0) then
                nearest_friendly_fleet = faction_naval_force
                nearest_friendly_fleet_distance = friendly_fleet_distance
                nearest_friendly_fleet_commander = nearest_friendly_fleet.commander_name
                mach_lib.update_mach_lua_log(string.format('Found new closer fleet to army under command of "%s". Fleet is under command of "%s" at distance %s.',
                        army.commander_name, nearest_friendly_fleet_commander, nearest_friendly_fleet_distance))
            end
        end
        if nearest_friendly_fleet then
            mach_lib.update_mach_lua_log(string.format('Nearest friendly fleet to army under command of "%s" is under command of "%s" at distance %s.',
                army.commander_name, nearest_friendly_fleet_commander, nearest_friendly_fleet_distance))
            return nearest_friendly_fleet, nearest_friendly_fleet_distance
        end
        mach_lib.update_mach_lua_log(string.format('No nearest friendly fleet to army under command of "%s".',
            army.commander_name))
        return nearest_friendly_fleet, nearest_friendly_fleet_distance
    end


    local function _get_nearest_friendly_region_capital(army)
        mach_lib.update_mach_lua_log("Getting nearest friendly region capital to army under command of: "..army.commander_name)

        local supplier = nil
        local nearest_region_capital = nil
        local nearest_region_capital_distance = 99999999
        local nearest_region_obj = nil
        local region_x = 0
        local region_y = 0
        local army_x = 0
        local army_y = 0
        local friendly_regions = mach_lib.get_friendly_regions(army.faction_key)
        local besieged_settlements = mach_lib.convert_array_to_set(mach_lib.get_besieged_settlements())

        for friendly_regions_key, friendly_regions_value in pairs(friendly_regions) do
            mach_lib.update_mach_lua_log(string.format('Determining if region "%s" is closest to army under the command of "%s"',
                friendly_regions_value.region_key, army.commander_name))

            local region_capital_obj = friendly_regions_value
            local region_capital_distance = mach_lib.find_distance(army.obj.PosX, army.obj.PosY, mach_data.region_capital_coord_list[region_capital_obj.region_key][1], mach_data.region_capital_coord_list[region_capital_obj.region_key][2])

            if not besieged_settlements[region_capital_obj.region_key] and (region_capital_distance < nearest_region_capital_distance and region_capital_distance ~= nil) then
                mach_lib.update_mach_lua_log(string.format('Found closer friendly region capital to army under command of "%s". Region is "%s" and region capital is "%s" at distance %s.',
                    army.commander_name, region_capital_obj.region_key, region_capital_obj.name, region_capital_distance))
                nearest_region_capital_distance = region_capital_distance
                nearest_region_capital = region_capital_obj.name
                nearest_region_obj = region_capital_obj
            end
        end
        mach_lib.update_mach_lua_log(string.format('Nearest friendly region capital to army under command of "%s" is "%s" at distance "%s"',
                army.commander_name, nearest_region_capital, nearest_region_capital_distance))

        return nearest_region_obj, nearest_region_capital_distance
    end


    local function _get_nearest_friendly_region_capital_or_friendly_fleet(army)
        mach_lib.update_mach_lua_log(string.format('Getting nearest friendly region capital or friendly fleet to army under command of "%s"',
            army.commander_name))
        local nearest_friendly_region_capital, nearest_region_capital_distance = _get_nearest_friendly_region_capital(army)
        local nearest_friendly_fleet, nearest_friendly_fleet_distance = _get_nearest_friendly_fleet(army)

        if not nearest_friendly_fleet_distance or (nearest_friendly_region_capital and nearest_region_capital_distance and nearest_region_capital_distance <= nearest_friendly_fleet_distance) then
            mach_lib.update_mach_lua_log(string.format('Nearest is a friendly region capital called "%s" at distance: %s', nearest_friendly_region_capital.name, nearest_region_capital_distance))
            return nearest_friendly_region_capital, nearest_region_capital_distance
        elseif nearest_friendly_fleet and nearest_friendly_fleet_distance and nearest_friendly_fleet_distance < nearest_region_capital_distance then
            mach_lib.update_mach_lua_log(string.format('Nearest is a friendly fleet under the command of "%s" at distance: %s', nearest_friendly_fleet.commander_name, nearest_friendly_fleet_distance))
            return nearest_friendly_fleet, nearest_friendly_fleet_distance
        else
            mach_lib.update_mach_lua_log('ERROR: Nearest is neither friendly region capital or friendly fleet!')
            return nil, 99999999
        end
    end


    --determine closes friendly region capital to pick for line of supply beginning point
    local function _get_faction_armies_supply_lines_and_suppliers(faction_key)
        mach_lib.update_mach_lua_log("Getting armies supply lines and suppliers for faction_key: "..tostring(faction_key))

        local faction_army_forces = mach_lib.get_faction_army_forces(faction_key)
        local faction_armies_with_supply_lines = {}
        for faction_army_force_key, army in pairs(faction_army_forces) do
            local region_key = false
            local distance = false
            local nearest_region_capital = false
            local nearest_distance = 99999999
            local regionX = 0
            local regionY = 0
            local armyX = 0
            local armyY = 0
            local supplier = nil
            local supplier_distance = nil

            if army.is_in_settlement == false and army.is_on_fleet == false then
                supplier, supplier_distance = _get_nearest_friendly_region_capital_or_friendly_fleet(army)
                local supplied_armies_idx = #supplier.supplied_armies+1
                supplier.supplied_armies[supplied_armies_idx] = {}
                supplier.supplied_armies[supplied_armies_idx]['supplied_army'] = army
                supplier.supplied_armies[supplied_armies_idx]['supplied_distance'] = supplier_distance
                army.supplier = supplier
                faction_armies_with_supply_lines[#faction_armies_with_supply_lines+1] = army
                mach_lib.update_mach_lua_log(string.format('Finished getting supply lines and suppliers for army under command of "%s"',
                    army.commander_name))

            elseif army.is_in_settlement == true then
                mach_lib.update_mach_lua_log(string.format('Army under command of "%s" is in settlement region id "%s". Ignoring.',
                army.commander_name, army.settlement_in_region_id))

            elseif army.is_on_fleet == true then
                mach_lib.update_mach_lua_log(string.format('Army under command of "%s" is on a fleet under the command of "%s". Ignoring.',
                    army.commander_name, army.fleet_on.commander_name))
            end
        end
        mach_lib.update_mach_lua_log(string.format('Total "%s" army supply lines: %s', faction_key, #faction_armies_with_supply_lines))
        mach_lib.update_mach_lua_log("Finished getting armies supply lines and suppliers for faction_key: "..tostring(faction_key))
        return faction_armies_with_supply_lines
    end


    local function _get_enemy_armies_supply_lines_and_suppliers(faction_key)
        mach_lib.update_mach_lua_log("Getting enemy armies supply lines and suppliers of faction_key: "..tostring(faction_key))
        local diplomacy = CampaignUI.RetrieveDiplomacyDetails(faction_key)
        --local besiegedSettlements_list = mach_lib.build_besieged_settlements_list()
        local enemy_faction_armies_with_supply_lines = {}
        local total_enemy_faction_armies_with_supply_lines = 0

        for enemy_faction_key, v in pairs(diplomacy.AtWar) do
            local faction_armies_with_supply_lines = {}
            faction_armies_with_supply_lines = _get_faction_armies_supply_lines_and_suppliers(enemy_faction_key)
            enemy_faction_armies_with_supply_lines = mach_lib.concat_tables(enemy_faction_armies_with_supply_lines, faction_armies_with_supply_lines)
            total_enemy_faction_armies_with_supply_lines = total_enemy_faction_armies_with_supply_lines + #faction_armies_with_supply_lines
        end
        mach_lib.update_mach_lua_log("Finished getting ENEMY armies supply lines and suppliers of faction_key: "..tostring(faction_key))
        mach_lib.update_mach_lua_log(string.format("Total enemy army supply lines: %s", total_enemy_faction_armies_with_supply_lines))
        return enemy_faction_armies_with_supply_lines
    end


    --land traits start
    local function _add_army_intercepting_supply_pip(enemy_army_with_supply_lines_intercepted)
        mach_lib.update_mach_lua_log("Adding army intercepting supply pip.")
--        local character_details = mach_lib.get_character_details_from_character_context(character_context)

--        character_address, previously_selected_character_pointer = get_character_address(context)
--        local character_address, character_pointer = get_character_address_and_pointer(character_context)
--
--        mach_lib.update_mach_lua_log("char address: "..character_address)
--        mach_lib.update_mach_lua_log("char pointer: "..character_pointer)

        local mach_logistics_pip = mach_lib.__wali_m_root__:Find("MACH_LogisticsPip")
        UIComponent(mach_logistics_pip):SetState("BlockLogistics")

        UIComponent(mach_logistics_pip):SetTooltipText(string.format('This army is disrupting the supply line of the force under the command of "%s" and its supplier "%s".',
            enemy_army_with_supply_lines_intercepted.commander_name, enemy_army_with_supply_lines_intercepted.supplier.name))

        UIComponent(mach_logistics_pip):SetVisible(true)
        mach_lib.update_mach_lua_log("Finished adding army intercepting supply pip.")


--        local no_supply_name = nil
--        local block_supply_name = nil
--
--        local totalBlockSupplyFound = 0
--        local totalBlockSupply = 0
--
--        if blockingSupplyForces[current_faction_turn] ~= nil then
--            for j = 1, #blockingSupplyForces[current_faction_turn] do
--                if blockingSupplyForces[current_faction_turn][j][1] ~= nil then
--                    totalBlockSupply = totalBlockSupply + 1
--                end
--            end
--        end

--        _get_nearest_friendly_region_capital()
--
--
--        local foundSupplyGood = false
--        local foundSupplyBad = false
--
--        for count = 1, #character_names_list do
--
--
--            if not (totalBlockSupplyFound >= totalBlockSupply) and not (blockingSupplyForces[current_faction_turn] == nil) then
--
--                for j = 1, #blockingSupplyForces[current_faction_turn] do
--                    block_supply_name = blockingSupplyForces[current_faction_turn][j][1]
--                    if not (block_supply_name == nil) then
--                        local y, z = string.find(block_supply_name, character_names_list[count][4], 1)
--
--                        if  not (string.find(block_supply_name, character_names_list[count][4], 1) == nil) then
--                            if conditions.CharacterForename(character_names_list[count][2], character_context) then
--
--                                UIComponent(mach_logistics_pip):SetState("BlockLogistics")
--                                local region_screen_name = nil
--
--                                for b = 1, #region_names_list do
--                                    if region_names_list[b][2] == "regions_onscreen_"..blockingSupplyForces[current_faction_turn][j][4] then
--                                        region_screen_name = region_names_list[b][4]
--                                    end
--                                end
--                                if region_screen_name ~= nil then
--                                    UIComponent(mach_logistics_pip):SetTooltipText("This army has severed the logistics of "..blockingSupplyForces[current_faction_turn][j][3].."'s force from "..region_screen_name..".", true)
--                                else
--                                    UIComponent(mach_logistics_pip):SetTooltipText("This army has severed the logistics of "..blockingSupplyForces[current_faction_turn][j][3].."'s force from "..blockingSupplyForces[current_faction_turn][j][4].."'s fleet", true)
--                                end
--                                UIComponent(mach_logistics_pip):SetVisible(true)
--
--
--
--                                if prevEffectTime ~= 0 then
--                                    if (((os.clock() - prevEffectTime) > 2) and character_address == prevCharacterAddress) or (character_address ~= prevCharacterAddress) then
--                                        prevEffectTime = os.clock()
--                                        prevCharacterAddress = character_address
--                                        --if (conditions.CharacterTrait("C_General_Logistician_Good", context) < 1) then
--                                        mach_lib.update_mach_lua_log("Added \"C_General_Logistician_Good\" trait to "..block_supply_name)
--
--                                        local good_count = conditions.CharacterTrait("C_General_Logistician_Good", character_context)
--                                        local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", character_context)
--                                        local target = (bad_count+1) - good_count
--                                        for h = 1, target do
--                                            effect.trait("C_General_Logistician_Good", "agent", 1, 100, character_context)
--                                        end
--                                        --end
--                                        mach_lib.update_mach_lua_log(conditions.CharacterTrait("C_General_Logistician_Good", character_context).."-"..conditions.CharacterTrait("C_General_Logistician_Bad", character_context))
--                                        totalBlockSupplyFound = totalBlockSupplyFound + 1
--                                        foundSupplyGood = true
--                                        break
--                                    end
--                                else
--
--                                    prevEffectTime = os.clock()
--                                    prevCharacterAddress = character_address
--                                    --if (conditions.CharacterTrait("C_General_Logistician_Good", context) < 1) then
--                                    mach_lib.update_mach_lua_log("Added \"C_General_Logistician_Good\" trait to "..block_supply_name)
--
--                                    local good_count = conditions.CharacterTrait("C_General_Logistician_Good", character_context)
--                                    local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", character_context)
--                                    local target = (bad_count+1) - good_count
--                                    for h = 1, target do
--                                        --mach_lib.update_mach_lua_log("loop"..h)
--                                        effect.trait("C_General_Logistician_Good", "agent", 1, 100, character_context)
--                                    end
--                                    --end
--                                    --mach_lib.update_mach_lua_log(conditions.CharacterTrait("C_General_Logistician_Good", context).."-"..conditions.CharacterTrait("C_General_Logistician_Bad", context))
--                                    totalBlockSupplyFound = totalBlockSupplyFound + 1
--                                    foundSupplyGood = true
--                                    break
--
--                                end
--
--                            end
--
--                        end
--                    end
--
--                end
--                if foundSupplyGood == true then
--                    break
--                end
--            end
--
--        end



--        if (foundSupplyGood == false) and (conditions.CharacterTrait("C_General_Logistician_Good", character_context) >= 1) then
--            --mach_lib.update_mach_lua_log("3333")
--            if prevEffectTime ~= 0 then
--                --mach_lib.update_mach_lua_log("jrer")
--                if (((os.clock() - prevEffectTime) > 2) and character_address == prevCharacterAddress) or (character_address ~= prevCharacterAddress) then
--
--                    prevEffectTime = os.clock()
--                    prevCharacterAddress = character_address
--
--                    UIComponent(mach_logistics_pip):SetVisible(false)
--                    mach_lib.update_mach_lua_log("Removed \"C_General_Logistician_Good\" trait from ".. character_details.Name)
--                    local good_count = conditions.CharacterTrait("C_General_Logistician_Good", character_context)
--                    local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", character_context)
--                    local target = good_count - bad_count
--                    for h = 1, target do
--                        effect.trait("C_General_Logistician_Bad", "agent", 1, 100, character_context)
--                    end
--                end
--            else
--                --mach_lib.update_mach_lua_log("5555")
--                prevEffectTime = os.clock()
--                prevCharacterAddress = character_address
--
--                UIComponent(mach_logistics_pip):SetVisible(false)
--                mach_lib.update_mach_lua_log("Removed \"C_General_Logistician_Good\" trait from ".. character_details.Name)
--
--                local good_count = conditions.CharacterTrait("C_General_Logistician_Good", character_context)
--                local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", character_context)
--                local target = good_count - bad_count
--                for h = 1, target do
--                    effect.trait("C_General_Logistician_Bad", "agent", 1, 100, character_context)
--                end
--            end
--
--        end
--
--
--
--        --mach_lib.update_mach_lua_log("here")
--        --mach_lib.update_mach_lua_log(tostring(conditions.CharacterTrait("C_General_Logistician_Good", context) == 1).."-"..tostring(conditions.CharacterTrait("C_General_Logistician_Bad", context) == 1))
--
--        local adjustedToolTip = false
--        if (conditions.CharacterTrait("C_General_Logistician_Bad", character_context) >= 1) and (UIComponent(mach_logistics_pip):Visible() ~= true) then
--
--            UIComponent(mach_logistics_pip):SetState("SeveredLogistics")
--
--            if noSupplyForces[current_faction_turn] ~= nil then
--                for count = 1, #character_names_list do
--                    local loopNum = nil
--
--                    if #noSupplyForces[current_faction_turn] < 1 then
--                        loopNum = 1
--                    else
--                        loopNum = #noSupplyForces[current_faction_turn]
--                    end
--
--                    for j = 1, loopNum do
--                        local no_supply_name = nil
--
--
--                        no_supply_name = noSupplyForces[current_faction_turn][j][1]
--                        --mach_lib.update_mach_lua_log("hello")
--                        if (no_supply_name ~= nil) then
--
--                            local y, z = string.find(no_supply_name, character_names_list[count][4], 1)
--
--                            if (string.find(no_supply_name, character_names_list[count][4], 1) ~= nil) then
--                                if conditions.CharacterForename(character_names_list[count][2], character_context) then
--                                    local region_screen_name = nil
--                                    for b = 1, #region_names_list do
--                                        if region_names_list[b][2] == "regions_onscreen_"..noSupplyForces[current_faction_turn][j][2] then
--                                            region_screen_name = region_names_list[b][4]
--                                        end
--                                    end
--
--                                    if region_screen_name ~= nil then
--                                        UIComponent(mach_logistics_pip):SetTooltipText("An enemy force under the command of "..noSupplyForces[current_faction_turn][j][3].." has severed the logistics of this army from its supply base in "..region_screen_name..".")
--                                    else
--                                        UIComponent(mach_logistics_pip):SetTooltipText("An enemy force under the command of "..noSupplyForces[current_faction_turn][j][3].." has severed the logistics of this army from its supply by "..blockingSupplyForces[current_faction_turn][j][4].."'s fleet.")
--                                    end
--
--                                    adjustedToolTip = true
--
--                                    break
--
--                                end
--                            end
--                        end
--                    end
--
--                    if adjustedToolTip == true then
--                        break
--                    end
--                end
--            else
--                UIComponent(mach_logistics_pip):SetTooltipText("An enemy force has severed the logistics of this army.")
--            end
--
--            UIComponent(mach_logistics_pip):SetVisible(true)
--        end
--
--        affectLongSupplyLines(current_faction_turn, character_context)

    end


    local function _get_enemy_armies_with_supply_lines_intercepted_by_army(army, enemy_faction_armies_with_supply_lines)
        mach_lib.update_mach_lua_log(string.format('Getting any of %s enemy armies with supply lines intercepted by army under command of "%s".',
            #enemy_faction_armies_with_supply_lines, army.commander_name))
        local enemy_army_supply_lines_intercepted = {}
        for enemy_faction_army_with_supply_line_idx = 1, #enemy_faction_armies_with_supply_lines do
            local enemy_faction_army_with_supply_line = enemy_faction_armies_with_supply_lines[enemy_faction_army_with_supply_line_idx]

            mach_lib.update_mach_lua_log(enemy_faction_army_with_supply_line.commander_name)
            mach_lib.update_mach_lua_log(enemy_faction_army_with_supply_line.pos_x)
            mach_lib.update_mach_lua_log(enemy_faction_army_with_supply_line.pos_y)
            mach_lib.update_mach_lua_log(enemy_faction_army_with_supply_line.supplier.pos_x)
            mach_lib.update_mach_lua_log(enemy_faction_army_with_supply_line.supplier.pos_y)

            local enemy_supply_line_slope = mach_lib.get_line_slope(enemy_faction_army_with_supply_line.pos_x,
                enemy_faction_army_with_supply_line.pos_y, enemy_faction_army_with_supply_line.supplier.pos_x,
                enemy_faction_army_with_supply_line.supplier.pos_y)

            local enemy_supply_line_y_intercept = mach_lib.get_line_y_intercept(enemy_faction_army_with_supply_line.pos_x,
                enemy_faction_army_with_supply_line.pos_y, enemy_supply_line_slope)

            local interception_line_slope = mach_lib.get_perpendicular_line_slope(enemy_supply_line_slope)

            local interception_line_y_intercept = mach_lib.get_line_y_intercept(army.pos_x, army.pos_y,
                interception_line_slope)

            local interception_pos_x, interception_pos_y = mach_lib.get_intersection_point_of_two_lines(enemy_supply_line_slope,
                enemy_supply_line_y_intercept, army.pos_x, interception_line_slope, interception_line_y_intercept)

            local distance_between_army_and_enemy_supply_line = mach_lib.find_distance(army.pos_x, army.pos_y, interception_pos_x,
                interception_pos_y)

            mach_lib.update_mach_lua_log(string.format('Army under the command of "%s" is distance of "%s" from supply line between army under command of "%s" and its supplier "%s"',
                army.commander_name, distance_between_army_and_enemy_supply_line, enemy_faction_army_with_supply_line.commander_name,
                enemy_faction_army_with_supply_line.supplier.name))

            if distance_between_army_and_enemy_supply_line <= WALI.__MACH_MAX_DISTANCE_ALLOWED_FROM_ENEMY_SUPPLY_LINE__ then
                mach_lib.update_mach_lua_log(string.format('Army under the command of "%s" is intercepting enemy supply line between army under command of "%s" and its supplier "%s"',
                    army.commander_name, enemy_faction_army_with_supply_line.commander_name,
                    enemy_faction_army_with_supply_line.supplier.name))
                enemy_army_supply_lines_intercepted[#enemy_army_supply_lines_intercepted+1] = enemy_faction_army_with_supply_line
            else
                mach_lib.update_mach_lua_log(string.format('Army under the command of "%s" distance from enemy supply line of army under command of "%s" is greater than max distance allowed of "%s"',
                    army.commander_name, enemy_faction_army_with_supply_line.commander_name,
                    WALI.__MACH_MAX_DISTANCE_ALLOWED_FROM_ENEMY_SUPPLY_LINE__))
            end
        end
        mach_lib.update_mach_lua_log(string.format('Army under the command of "%s" is intercepting %s enemy supply lines',
            army.commander_name, #enemy_army_supply_lines_intercepted))
        return enemy_army_supply_lines_intercepted
    end

        --CharacterSelected event calls this
    local function _add_army_supply_line_traits(character_context, faction_key, enemy_faction_armies_with_supply_lines)
        mach_lib.update_mach_lua_log("Adding army suppy line traits.")

--        local enemy_faction_armies_with_supply_lines = {}
--        local enemy_faction_army_suppliers = {}

        local army = mach_lib.get_army_from_character_context(character_context)

--        enemy_faction_armies_with_supply_lines, enemy_faction_army_suppliers = _get_enemy_armies_supply_lines_and_suppliers(faction_key)

        if #enemy_faction_armies_with_supply_lines > 0 then
            local enemy_armies_with_supply_lines_intercepted =  _get_enemy_armies_with_supply_lines_intercepted_by_army(
                army, enemy_faction_armies_with_supply_lines)
            if #enemy_armies_with_supply_lines_intercepted > 0 then
                for enemy_armies_with_supply_lines_intercepted_idx = 1, #enemy_armies_with_supply_lines_intercepted do
                    enemy_army_with_supply_lines_intercepted = enemy_armies_with_supply_lines_intercepted[enemy_armies_with_supply_lines_intercepted_idx]
                    _add_army_intercepting_supply_pip(enemy_army_with_supply_lines_intercepted)
                -- if mach_lib.is_character_admiral(character_context) or mach_lib.is_character_naval_captain(character_context) then
    --                mach_lib.update_mach_lua_log("Character is admiral or naval captain.")
    --                add_naval_military_character_traits(character_context)
    --            elseif mach_lib.is_character_general(character_context) or mach_lib.is_character_colonel(character_context) then
    --                mach_lib.update_mach_lua_log("Character is General or colonel.")
    --            end
                end
            else
                mach_lib.update_mach_lua_log("Army is not intercepting any enemy supply lines.")
            end
        else
            mach_lib.update_mach_lua_log("No enemy faction armies with supply lines to intercept!")
        end

        --                    local slope  = (regionForcesTable[force_num][2] - regionForcesTable[force_num][4]) / (regionForcesTable[force_num][1] - regionForcesTable[force_num][3])
        --
        --                    local y_intercept = regionForcesTable[force_num][2] - (slope * regionForcesTable[force_num][1])
        --
        --                    --mach_lib.update_mach_lua_log("slope: "..slope.." y intercept: "..y_intercept)
        --
        --                    collect_enemy_armies_cutting_off_supply_line(slope, y_intercept, force_num, army.faction_key)

--        collect_long_supply_line_armies(faction_key, army.obj, supplier_distance, supplier, army.is_in_settlement)


        --        if mach_lib.__wali_is_on_campaign_map__ and
--

--        local ETS = CampaignUI.EntityTypeSelected()
--        if mach_lib.__wali_is_on_campaign_map__ and (conditions.CharacterType("admiral", context) or conditions.CharacterType("captain", context)) then
--            mach_lib.update_mach_lua_log("Character is a admiral or a captain.")
--            add_naval_traits(context)
--        elseif mach_lib.__wali_is_on_campaign_map__ and (conditions.CharacterType("General", context) or conditions.CharacterType("colonel", context)) then
--            mach_lib.update_mach_lua_log("Character is a General or a colonel.")
--            _add_army_intercepting_supply_pip(context)
--        end
    end


    local function on_ui_created(context)
        mach_lib.update_mach_lua_log("Machiavelli's Supply Lines - UI Created.")

        if context.string == "Campaign UI" then
            local faction_key = mach_lib.get_faction_id_from_context(context, "UICreated")
            __enemy_faction_armies_with_supply_lines__  = _get_enemy_armies_supply_lines_and_suppliers(faction_key)
        end

    end


    events.CharacterSelected[#events.CharacterSelected+1] = function(context)
        mach_lib.update_mach_lua_log("Machiavelli's Supply Lines - Character selected.")

--        mach_lib.update_mach_lua_log(tostring(debug.traceback()))
        __selected_character_context__ = context

        local ETS = CampaignUI.EntityTypeSelected()
        __MACH_ARMY_IS_SELECTED__ = true

        if __MACH_PREVIOUSLY_SELECTED_CHARACTER_POINTER__ ~= ETS.Entity then
            __MACH_IS_FIRST_CLICK_ON_ARMY__ = true
        end
        __MACH_PREVIOUSLY_SELECTED_CHARACTER_POINTER__ = ETS.Entity

        __PREV_CALL_TIME__ = os.time()
        __PREV_CONTEXT__ = context

        __character_selected_event__ = true

        mach_lib.update_mach_lua_log("Enemy faction armies with supply lines: "..tostring(#__enemy_faction_armies_with_supply_lines__))
        local current_faction = mach_lib.get_faction_id_from_context(context, "CharacterSelected")
        if _add_army_supply_line_traits(context, current_faction, __enemy_faction_armies_with_supply_lines__) then
        end


--        current_faction_turn = mach_lib.get_current_faction(context)


--        if __MACH_IS_FIRST_CLICK_ON_ARMY__ then
--            --scripting.game_interface:add_time_trigger("MoveWatch_Supply", .5)
--        end
    end


    events.CharacterTurnEnd[#events.CharacterTurnEnd+1] = function(context)
        mach_lib.update_mach_lua_log("Character Turn has Ended.")

        __character_selected_event__ = false

        if (firstCharacter == true) then
            firstCharacter = false
            totalCount = 0
            totalFound = 0
            local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
            for k, v in pairs(faction_list) do
                if conditions.CharacterFactionName(v.Key,context) then
                    current_faction_turn = v.Key
                end
            end

            local diplomacy = CampaignUI.RetrieveDiplomacyDetails(current_faction_turn)
            local regionsBesieged = {}

            --local besiegedSettlements_list = mach_lib.build_besieged_settlements_list()

--            _get_faction_armies_supply_lines_and_suppliers(current_faction_turn)

        end




        local no_supply_name = nil
        local block_supply_name = nil

        local totalBlockSupplyFound = 0
        local totalBlockSupply = 0

        if blockingSupplyForces[current_faction_turn] ~= nil then
            for j = 1, #blockingSupplyForces[current_faction_turn] do
                if blockingSupplyForces[current_faction_turn][j][1] ~= nil then
                    totalBlockSupply = totalBlockSupply + 1
                end
            end
        end



        local foundSupplyGood = false
        local foundSupplyBad = false
        if ((conditions.CharacterType("General", context)) or (conditions.CharacterType("colonel", context))) then
            for count = 1, #characterNames_list do

                if not (totalFound >= totalCount) and not (noSupplyForces[current_faction_turn] == nil) then
                    for j = 1, #noSupplyForces[current_faction_turn] do
                        no_supply_name = noSupplyForces[current_faction_turn][j][1]
                        local y, z = string.find(no_supply_name, characterNames_list[count][4], 1)

                        if not (string.find(no_supply_name, characterNames_list[count][4], 1) == nil) then

                            if conditions.CharacterForename(characterNames_list[count][2], context) then

                                --if (conditions.CharacterTrait("C_General_Logistician_Bad", context) < 1) then
                                mach_lib.update_mach_lua_log("Added \"C_General_Logistician_Bad\" trait to "..no_supply_name)
                                local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
                                local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
                                local target = (good_count+1) - bad_count
                                local loop = 0
                                for h = 1, target do
                                    effect.trait("C_General_Logistician_Bad", "agent", 1, 100, context)
                                end
                                --end

                                totalFound = totalFound + 1
                                foundSupplyBad = true
                                if totalFound == totalCount then
                                    break
                                end
                            end
                        end

                    end

                end


                if not (totalBlockSupplyFound >= totalBlockSupply) and not (blockingSupplyForces[current_faction_turn] == nil) then

                    for j = 1, #blockingSupplyForces[current_faction_turn] do
                        block_supply_name = blockingSupplyForces[current_faction_turn][j][1]
                        if not (block_supply_name == nil) then
                            local y, z = string.find(block_supply_name, characterNames_list[count][4], 1)

                            if  not (string.find(block_supply_name, characterNames_list[count][4], 1) == nil) then
                                if conditions.CharacterForename(characterNames_list[count][2], context) then

                                    --if (conditions.CharacterTrait("C_General_Logistician_Good", context) < 1) then
                                    mach_lib.update_mach_lua_log("Added \"C_General_Logistician_Good\" trait to "..block_supply_name)
                                    local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
                                    local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
                                    local target = (bad_count+1) - good_count
                                    for h = 1, target do
                                        effect.trait("C_General_Logistician_Good", "agent", 1, 100, context)
                                    end

                                    --end
                                    totalBlockSupplyFound = totalBlockSupplyFound + 1
                                    foundSupplyGood = true

                                    if totalBlockSupplyFound == totalBlockSupply then
                                        break
                                    end
                                end

                            end
                        end

                    end

                    if totalBlockSupplyFound == totalBlockSupply then
                        break
                    end
                end

            end



            if (foundSupplyBad == false) and (conditions.CharacterTrait("C_General_Logistician_Bad", context) >= 1) then
                local foreName = nil
                local surName = nil
                for count = 1, #characterNames_list do
                    if conditions.CharacterForename(characterNames_list[count][2], context) then
                        foreName = characterNames_list[count][4]
                    end
                end
                for count = 1, #characterNames_list do
                    if conditions.CharacterSurname(characterNames_list[count][2], context) then
                        surName = characterNames_list[count][4]
                    end
                end

                mach_lib.update_mach_lua_log("Removed \"C_General_Logistician_Bad\" trait from "..foreName.." "..surName)
                local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
                local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
                local target = bad_count - good_count
                for h = 1, target do
                    effect.trait("C_General_Logistician_Good", "agent", 1, 100, context)
                end

            end

            if (foundSupplyGood == false) and (conditions.CharacterTrait("C_General_Logistician_Good", context) >= 1) then
                local foreName = nil
                local surName = nil
                for count = 1, #characterNames_list do
                    if conditions.CharacterForename(characterNames_list[count][2], context) then
                        foreName = characterNames_list[count][4]
                    end
                end
                for count = 1, #characterNames_list do
                    if conditions.CharacterSurname(characterNames_list[count][2], context) then
                        surName = characterNames_list[count][4]
                    end
                end

                mach_lib.update_mach_lua_log("Removed \"C_General_Logistician_Good\" trait from "..foreName.." "..surName)
                local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
                local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
                local target = good_count - bad_count
                for h = 1, target do
                    effect.trait("C_General_Logistician_Bad", "agent", 1, 100, context)
                end

            end

            affectLongSupplyLines(current_faction_turn, context)
        end


    end


    scripting.AddEventCallBack("UICreated", on_ui_created)

end






