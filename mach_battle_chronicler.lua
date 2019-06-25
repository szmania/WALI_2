module(..., package.seeall)

mach = require "WALI/mach"
mach_lib = require "WALI/mach_lib"
mach_data = require "WALI/mach_data"
mach_classes = require "WALI/mach_classes"


function mach_battle_chronicler()
	mach_lib.update_mach_lua_log("Activating Machiavelli's 'Battle Chronicler'")

    mach.__mach_features_enabled__[#mach.__mach_features_enabled__+1] = "MACH Battle Chronicler"
    local __current_battle__ = nil
    local __winner_unit_seen__ = false
    local __loser_unit_seen__ = false
    local __rebel_character_completed_battle__ = false


    function _get_battle_message_image(battle)
        mach_lib.update_mach_lua_log('Getting battle message image.')
        local image = nil
        if battle.is_naval_battle then
            if battle.is_major_battle then
                image = "data/ui/EventPics/european/naval loose.tga"
            else
                image = "data/ui/EventPics/european/naval_win.tga"
            end
        elseif battle.is_siege then
            if battle.defender_culture == 'middle_east' or battle.defender_culture == 'indian' then
                image = "data/ui/EventPics/middle_east/besieged-3asian.tga"
            elseif battle.defender_culture == 'tribal' then
                image = "data/ui/EventPics/tribal_playable/nat_captured.tga"
            else
                image = "data/ui/EventPics/european/besieged-3.tga"
            end
        else
            if battle.winner_culture == 'middle_east' or battle.winner_culture == 'indian' then
                image = "data/ui/EventPics/middle_east/afterbatle ottoman.tga"
            elseif battle.winner_culture == 'tribal' then
                image = "data/ui/EventPics/tribal_playable/nat_afterbatle.tga"
            else
                image = "data/ui/EventPics/european/afterbatle eu.tga"
            end
        end
        mach_lib.update_mach_lua_log(string.format('Battle message image gotten: "%s"', image))
        return image
    end


    function _get_battle_message_title_and_text(battle)
        mach_lib.update_mach_lua_log('Getting battle message text.')
        local title = "A battle has occurred:"
        local major_str = ''
        if battle.is_major_battle then
            title = "A major battle has taken place:"
            major_str = "major "
        end
        title = title..'\nThe '..battle.battle_name

        local winner_faction_names_str = _get_faction_names_str(battle.winner_faction_ids)
        local winner_commander_names_str = _get_commander_names_str(battle.winner_full_commander_names)
        local loser_faction_names_str = _get_faction_names_str(battle.loser_faction_ids)
        local loser_commander_names_str = _get_commander_names_str(battle.loser_full_commander_names)

        local text = ''
        if not battle.is_siege then
            text = string.format('The %s: \n\nWe have received a message from a courier telling us of a %sbattle that has taken place in %s.', battle.battle_name, major_str, battle.location)
        else
            text = string.format('The %s: \n\nWe have received a message from a courier telling us of a %sbattle that has occurred in and around the vicinity of %s.', battle.battle_name, major_str, battle.besieged_settlement_name)
            if battle.winner_is_attacker then
                text = text..string.format('\n\nThe city of %s has been captured after an assault on that city!', battle.besieged_settlement_name)
            else
                text = text..string.format('\n\nThe city of %s was under siege, but the siege has been lifted after a battle!', battle.besieged_settlement_name)
            end
        end

        local winner_details_str = _get_side_details_str(true, battle, winner_faction_names_str, winner_commander_names_str)
        text = text..winner_details_str
        text = text..'\n\nUnits lost by victors:'
        local winner_unit_details_str = _get_unit_details_str(true, battle)
        text = text..winner_unit_details_str

        local loser_details_str = _get_side_details_str(false, battle, loser_faction_names_str, loser_commander_names_str)
        text = text..loser_details_str
        text = text..'\n\nUnits lost by losers:'
        local loser_unit_details_str = _get_unit_details_str(false, battle)
        text = text..loser_unit_details_str

        if not battle.is_naval_battle then
            text = text..string.format('\n\nTotal soldier casualties in this battle: %s \nTotal soldier(s) engaged in this battle: %s', battle.total_soldier_casualties, battle.pre_battle_soldiers)
        else
            text = text..string.format('\n\nTotal ship casualties in this battle: %s \nTotal ship(s) engaged in this battle: %s ', battle.total_ship_casualties, battle.pre_battle_ships)
            if battle.pre_battle_soldiers > 0 then
                text = text..string.format('\n\nTotal soldier casualties embarked on ship(s) in this battle: %s \nTotal soldier(s) embarked on ship(s) engaged in this battle: %s ', battle.total_soldier_casualties, battle.pre_battle_soldiers)
            end
        end
        mach_lib.update_mach_lua_log('Finished getting Battle message text.')
        return title, text
    end


    function _get_commander_names_str(commander_names)
        mach_lib.update_mach_lua_log('Getting commander names str from commander name list.')
        local commander_names_str = ''
        for commander_name_idx = 1, #commander_names do
            local commander_name = commander_names[commander_name_idx]
            if commander_name_idx == 1 then
                commander_names_str = commander_name
--            elseif commander_name_idx == #commander_names then
--                commander_names_str = commander_names_str.." and "..commander_name
            else
                commander_names_str = commander_names_str.." and "..commander_name
            end
        end
        if commander_names_str == '' then
            commander_names_str = 'an unknown commander'
        end

        mach_lib.update_mach_lua_log(string.format('Finished getting commander names str from commander name list: "%s"', commander_names_str))
        return commander_names_str
    end


    function _get_faction_names_str(faction_ids)
        mach_lib.update_mach_lua_log('Getting faction names str from faction ids list.')
        local faction_names_str = ''
        for faction_id_idx = 1, #faction_ids do
            local faction_id = faction_ids[faction_id_idx]
            if faction_id_idx == 1 then
                faction_names_str = mach_lib.get_faction_screen_name_from_faction_id(faction_id)
            else
                faction_names_str = faction_names_str..", "..mach_lib.get_faction_screen_name_from_faction_id(faction_id)
            end
        end
        mach_lib.update_mach_lua_log(string.format('Finished getting faction names str from faction ids list: "%s"', faction_names_str))
        if faction_names_str == '' then
            faction_names_str = 'Rebels'
        end
        return faction_names_str
    end


    local function _get_pre_and_post_battle_loser_military_forces(pre_battle_winner_military_force, pre_battle_all_factions_military_forces_list, post_battle_all_factions_military_forces_list)
        mach_lib.update_mach_lua_log(string.format('Getting battle loser military forces for winner faction "%s"', pre_battle_winner_military_force.faction_id))
        mach_lib.update_mach_lua_log(pre_battle_winner_military_force.faction_id)
--        local diplomacy_details = CampaignUI.RetrieveDiplomacyDetails(pre_battle_winner_military_force.faction_id)
        local pre_battle_loser_military_forces = {}
        local post_battle_loser_military_forces = {}
        local faction_ids_at_war_with_faction = mach_lib.get_faction_ids_at_war_with_faction(pre_battle_winner_military_force.faction_id)
        for _, enemy_faction_id in pairs(faction_ids_at_war_with_faction) do
            mach_lib.update_mach_lua_log(string.format('Enemy faction id searching as a possible battle opponent "%s" to battle won by "%s".', enemy_faction_id, pre_battle_winner_military_force.faction_id))

            local pre_battle_enemy_military_forces = pre_battle_all_factions_military_forces_list[enemy_faction_id]

            local post_battle_enemy_military_forces = post_battle_all_factions_military_forces_list[enemy_faction_id]
            for _, pre_battle_enemy_military_force in pairs(pre_battle_enemy_military_forces) do
                local post_battle_enemy_military_force = post_battle_enemy_military_forces[pre_battle_enemy_military_force.address]
                if not post_battle_enemy_military_force then
                    mach_lib.update_mach_lua_log('post battle enemy military force not exists!!!!')
                end
                mach_lib.update_mach_lua_log(' ')
                mach_lib.update_mach_lua_log(string.format('current faction turn: %s', mach_lib.__current_faction_turn_id__))
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.commander_name)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.commander_name)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.commander_type)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.commander_type)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.is_naval)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.is_naval)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.pos_x)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.pos_x)
                mach_lib.update_mach_lua_log(pre_battle_winner_military_force.pos_y)
                mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.pos_y)

                if post_battle_enemy_military_force then
                    mach_lib.update_mach_lua_log('enemy soldier counts, pre battle')
                    mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.num_of_soldiers)
                    mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.num_of_units)
                    mach_lib.update_mach_lua_log(pre_battle_enemy_military_force.num_of_ships)
                    mach_lib.update_mach_lua_log('enemy soldier counts, post battle')
                    mach_lib.update_mach_lua_log(post_battle_enemy_military_force.num_of_soldiers)
                    mach_lib.update_mach_lua_log(post_battle_enemy_military_force.num_of_units)
                    mach_lib.update_mach_lua_log(post_battle_enemy_military_force.num_of_ships)
                end

                mach_lib.update_mach_lua_log(' ')

                if (pre_battle_winner_military_force.is_naval == pre_battle_enemy_military_force.is_naval) and
                        (
                            (pre_battle_winner_military_force.is_rebel and not post_battle_enemy_military_force) or
                            (
                            pre_battle_winner_military_force.is_naval and
                                    (mach_lib.find_distance(pre_battle_winner_military_force.pos_x, pre_battle_winner_military_force.pos_y, pre_battle_enemy_military_force.pos_x, pre_battle_enemy_military_force.pos_y) < 90)) or
                            (
                                not pre_battle_winner_military_force.is_naval and
                                        (mach_lib.find_distance(pre_battle_winner_military_force.pos_x, pre_battle_winner_military_force.pos_y, pre_battle_enemy_military_force.pos_x, pre_battle_enemy_military_force.pos_y) < 30))) and
                        (
                        (not post_battle_enemy_military_force) or
                                (
                                post_battle_enemy_military_force and
                                    (
                                    (post_battle_enemy_military_force.num_of_soldiers < pre_battle_enemy_military_force.num_of_soldiers) or
                                    (post_battle_enemy_military_force.num_of_ships < pre_battle_enemy_military_force.num_of_ships)))) then

                    pre_battle_loser_military_forces[#pre_battle_loser_military_forces+1] = pre_battle_enemy_military_force

                    mach_lib.update_mach_lua_log("pre battle loser military commander "..pre_battle_enemy_military_force.commander_name)
                    mach_lib.update_mach_lua_log("pre battle loser num_of_soldiers "..tostring(pre_battle_enemy_military_force.num_of_soldiers))
                    mach_lib.update_mach_lua_log("pre battle loser num_of_units "..tostring(pre_battle_enemy_military_force.num_of_units))

                    if post_battle_enemy_military_force then
                        post_battle_loser_military_forces[#post_battle_loser_military_forces+1] = post_battle_enemy_military_force
                        mach_lib.update_mach_lua_log("post battle loser military commander "..post_battle_enemy_military_force.commander_name)
                        mach_lib.update_mach_lua_log("post battle loser num_of_soldiers "..tostring(post_battle_enemy_military_force.num_of_soldiers))
                        mach_lib.update_mach_lua_log("post battle loser num_of_units "..tostring(post_battle_enemy_military_force.num_of_units))
                    end
                end
            end
        end
        if #pre_battle_loser_military_forces == 0 and #post_battle_loser_military_forces == 0 then
            mach_lib.update_mach_lua_log("Error, couldn't find loser military forces!")
        end

        mach_lib.update_mach_lua_log(string.format('Finished getting battle loser military forces for winner "%s", enemy number of forces found "%s".', pre_battle_winner_military_force.faction_id, #pre_battle_loser_military_forces))
        return pre_battle_loser_military_forces, post_battle_loser_military_forces
    end


    function _get_side_details_str(is_winner, battle, faction_names_str, commander_names_str)
        mach_lib.update_mach_lua_log("Getting side details string.")
        mach_lib.update_mach_lua_log(string.format('is_winner: "%s", faction_names_str: "%s", commander_names_str: "%s"', tostring(is_winner), faction_names_str, commander_names_str))

        local side_details_str = ''
        local side_description_str = ''
        local unit_type_str = ''
        local forces_casualties_number_str = 0
        local forces_total_number_str = 0
        local soldiers_on_ships_casualties_number = 0
        local soldiers_on_ships_total_number = 0

        if not battle.is_naval_battle then
            unit_type_str = 'soldiers'
            if is_winner then
                side_description_str = 'victors'
--                mach_lib.update_mach_lua_log('testing')
                if battle.pre_battle_winner_soldiers == 0 then
--                    mach_lib.update_mach_lua_log('testing 2')

                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
--                    mach_lib.update_mach_lua_log('testing a3')

                    forces_casualties_number_str = battle.winner_soldier_casualties
                    forces_total_number_str = battle.pre_battle_winner_soldiers
--                    mach_lib.update_mach_lua_log('testing 3')

                end
--                side_details_str = string.format('\n\nThe victors (%s), under the command of %s, lost %s soldier(s) out of %s soldier(s).', winner_faction_names_str, winner_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            else
                side_description_str = 'losers'
                if battle.pre_battle_loser_soldiers == 0 then
                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
                    forces_casualties_number_str = battle.loser_soldier_casualties
                    forces_total_number_str = battle.pre_battle_loser_soldiers
                end
--                side_details_str = string.format('\n\nThe vanquished (%s), under the command of %s, lost %s soldier(s) out of %s soldier(s).', loser_faction_names_str, loser_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            end
        else
            unit_type_str = 'ships'
            if is_winner then
                side_description_str = 'victors'
                if battle.pre_battle_winner_ships == 0 then
                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
                    forces_casualties_number_str = battle.winner_ship_casualties
                    forces_total_number_str = battle.pre_battle_winner_ships
                    if battle.pre_battle_winner_soldiers then
                        soldiers_on_ships_casualties_number = battle.winner_soldier_casualties
                        soldiers_on_ships_total_number =  battle.pre_battle_winner_soldiers
                    end
                end
--                side_details_str = string.format('\n\nThe victors (%s), under the command of %s, lost %s ship(s) out of %s ship(s).', winner_faction_names_str, winner_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            else
                side_description_str = 'losers'
                if battle.pre_battle_loser_ships == 0 then
                    forces_casualties_number_str = 'an unknown number of'
                    forces_total_number_str = 'an unknown number of'
                else
                    forces_casualties_number_str = battle.loser_ship_casualties
                    forces_total_number_str =  battle.pre_battle_loser_ships
                    if battle.pre_battle_loser_soldiers then
                        soldiers_on_ships_casualties_number = battle.loser_soldier_casualties
                        soldiers_on_ships_total_number =  battle.pre_battle_loser_soldiers
                    end
                end
--                side_details_str = string.format('\n\nThe vanquished (%s), under the command of %s, lost %s ship(s) out of %s ship(s).', loser_faction_names_str, loser_commander_names_str, forces_number_casualties_str, forces_total_number_str)
            end
        end
--        mach_lib.update_mach_lua_log('testing 4')
--        mach_lib.update_mach_lua_log(side_description_str)
--        mach_lib.update_mach_lua_log(faction_names_str)
--        mach_lib.update_mach_lua_log(commander_names_str)
--        mach_lib.update_mach_lua_log(forces_casualties_number_str)
--        mach_lib.update_mach_lua_log(unit_type_str)
--        mach_lib.update_mach_lua_log(forces_total_number_str)

        side_details_str = string.format('\n\nThe %s (%s), under the command of %s, lost %s %s(s) out of %s %s(s).', side_description_str, faction_names_str, commander_names_str, forces_casualties_number_str, unit_type_str, forces_total_number_str, unit_type_str)

        if soldiers_on_ships_total_number > 0 then
            side_details_str = side_details_str..string.format('\nThe %s (%s), under the command of %s, lost %s soldier(s) out of %s soldier(s) embarked on ship(s).', side_description_str, faction_names_str, commander_names_str, soldiers_on_ships_casualties_number, soldiers_on_ships_total_number)
        end

        mach_lib.update_mach_lua_log(string.format('Finished getting side details string: "%s"', side_details_str))
        return side_details_str
    end


    function _get_unit_details_str(is_winner, battle)
        mach_lib.update_mach_lua_log('Getting unit details str for message box.')
        local casualties_list = {}
        local side_faction_ids = {}

        if is_winner then
            side_faction_ids = battle.winner_faction_ids
            if not battle.is_naval_battle then
                casualties_list = battle.winner_unit_casualties_list
            else
                casualties_list = mach_lib.concat_tables(battle.winner_ship_casualties_list, battle.winner_unit_casualties_list)
            end
        else
            side_faction_ids = battle.loser_faction_ids
            if not battle.is_naval_battle then
                casualties_list = battle.loser_unit_casualties_list
            else
                casualties_list = mach_lib.copy_table(battle.loser_ship_casualties_list)
                for side_faction_idx=1, #side_faction_ids do
                    local side_faction_id = side_faction_ids[side_faction_idx]
                    if battle.loser_unit_casualties_list[side_faction_id] then
                        for unit_address, unit in  pairs(battle.loser_unit_casualties_list[side_faction_id]) do
                            casualties_list[side_faction_idx][unit_address] = unit
                        end
                    end
                end
            end
        end

        local unit_details_str = ''

        for side_faction_idx=1, #side_faction_ids do
            local side_faction_id = side_faction_ids[side_faction_idx]
            if casualties_list[side_faction_id] then
                unit_details_str = unit_details_str..string.format('\n- %s:', mach_lib.get_faction_screen_name_from_faction_id(side_faction_id))
                mach_lib.update_mach_lua_log('shower')
                mach_lib.update_mach_lua_log(side_faction_id)
                mach_lib.update_mach_lua_log(#casualties_list[side_faction_id])
                for address, unit in  pairs(casualties_list[side_faction_id]) do
                    mach_lib.update_mach_lua_log(address)
                    mach_lib.update_mach_lua_log('something')
                    mach_lib.update_mach_lua_log(unit.unit_name)
                    if unit.regiment_name then
                        if unit.is_naval then
                            if not unit.regiment_name == '' then
                                unit_details_str = unit_details_str..string.format('\n- * "%s" (%s of %s Guns, %s Men)', unit.regiment_name, unit.unit_name, unit.guns, unit.men)
                            else
                                unit_details_str = unit_details_str..string.format('\n- * (%s of %s Guns, %s Men)', unit.unit_name, unit.guns, unit.men)
                            end
                        else
                            if not unit.regiment_name == '' then
                                unit_details_str = unit_details_str..string.format('\n- * "%s" (%s)', unit.regiment_name, unit.unit_name)
                            else
                                unit_details_str = unit_details_str..string.format('\n- * (%s)', unit.unit_name)
                            end
                        end
                        if unit.commander_name ~= '' then
                            unit_details_str = unit_details_str..string.format(' commanded by "%s"', unit.commander_name)
                        end
                    end
                end
                unit_details_str = unit_details_str..'\n'
            end
        end
        mach_lib.update_mach_lua_log(string.format('Finished getting unit details str for message box: "%s"', unit_details_str))
        return unit_details_str
    end


    function _populate_character_info_popup_with_battle_history()
        mach_lib.update_mach_lua_log(string.format('Populating character info popup with battle history.'))
        local military_force = {}
        local entity_type_selected = CampaignUI.EntityTypeSelected()
        if entity_type_selected.Unit or entity_type_selected.Character then
            local character_details = mach_lib.get_character_details_from_entity_type_selected(entity_type_selected)
            if not character_details.IsNaval then
                military_force = mach_classes.Army:new(character_details)
            else
                military_force = mach_classes.Navy:new(character_details)
            end
        elseif entity_type_selected.Settlement then
            military_force = mach_lib.get_army_in_settlement_address(entity_type_selected.Entity)
        end

        local q_character_name = UIComponent(mach_lib.__wali_m_root__:Find("name_textbox"))
        local pop_up_charater_name = q_character_name:GetStateText()
        local utils = require("Utilities")

        local character_battles = mach_lib.get_battles_with_character_name(pop_up_charater_name, military_force.faction_id)
        local battle_history_str = 'Character Battle History\n\n'
        for character_battle_idx, character_battle in pairs(character_battles) do
            if mach_lib.is_value_in_table(military_force.faction_id, character_battle.winner_faction_ids) then
                battle_history_str = battle_history_str..'* '..character_battle.battle_name..' (Victor)\n\n'
            else
                battle_history_str = battle_history_str..'* '..character_battle.battle_name..' (Loser)\n\n'
            end
        end
        if battle_history_str ~= 'Character Battle History\n\n' then
            local char_portrait = UIComponent(mach_lib.__wali_m_root__:Find("char_portrait"))
            char_portrait:SetTooltipText(tostring(battle_history_str))
        end
        mach_lib.update_mach_lua_log(string.format('Finished populating character info popup with battle history.'))
        return true
    end

    function _populate_unit_info_popup_with_battle_history()
        mach_lib.update_mach_lua_log(string.format('Populating unit info popup with battle history.'))
        local military_force = {}
        local entity_type_selected = CampaignUI.EntityTypeSelected()
        if entity_type_selected.Unit or entity_type_selected.Character then
            local character_details = mach_lib.get_character_details_from_entity_type_selected(entity_type_selected)
            if not character_details.IsNaval then
                military_force = mach_classes.Army:new(character_details)
            else
                military_force = mach_classes.Navy:new(character_details)
            end
        elseif entity_type_selected.Settlement then
            military_force = mach_lib.get_army_in_settlement_address(entity_type_selected.Entity)
        end

        local g_my_unit_name = UIComponent(mach_lib.__wali_m_root__:Find("name_textbox"))
        local pop_up_unit_regiment_name = g_my_unit_name:GetStateText()
        local g_unit_type = UIComponent(mach_lib.__wali_m_root__:Find("tx_unit-type"))
        local pop_up_unit_name = g_unit_type:GetStateText()
        local g_stats_men = UIComponent(mach_lib.__wali_m_root__:Find("dy_men"))
        local pop_up_unit_men = tostring(g_stats_men:GetStateText())
        local g_stats_experience = UIComponent(mach_lib.__wali_m_root__:Find("dy_experience"))
        local pop_up_unit_experience = g_stats_experience:CurrentState()
        local utils = require("Utilities")

        for unit_idx, unit in pairs(military_force.units) do
            local unit_men
            if unit.unit_scale ~= nil then
                unit_men = tostring(utils.TruncToInt(unit.men * unit.unit_scale))
            else
                unit_men = tostring(utils.TruncToInt(unit.men))
            end
            mach_lib.update_mach_lua_log('bugger4')
            mach_lib.update_mach_lua_log(pop_up_unit_regiment_name)
            mach_lib.update_mach_lua_log(unit.regiment_name)
            mach_lib.update_mach_lua_log(pop_up_unit_name)
            mach_lib.update_mach_lua_log(unit.unit_name)
            mach_lib.update_mach_lua_log(pop_up_unit_men)
            mach_lib.update_mach_lua_log(unit_men)
            mach_lib.update_mach_lua_log(pop_up_unit_experience)
            mach_lib.update_mach_lua_log(unit.experience)
            mach_lib.update_mach_lua_log('bugger5')

            if pop_up_unit_regiment_name == unit.regiment_name and pop_up_unit_name == unit.unit_name and pop_up_unit_men == unit_men and pop_up_unit_experience == tostring(unit.experience) then
                mach_lib.update_mach_lua_log('crap')
                local g_textview = UIComponent(mach_lib.__wali_m_root__:Find("TextView"))
                local g_textview_text = UIComponent(mach_lib.__wali_m_root__:Find("Text"))
                local unit_battles = mach_lib.get_battles_with_unit_id(unit.unit_id, unit.faction_id)
                local battle_history_str = 'Unit Battle History\n'
                for unit_battle_idx, unit_battle in pairs(unit_battles) do
                    if mach_lib.is_value_in_table(unit.faction_id, unit_battle.winner_faction_ids) then
                        battle_history_str = battle_history_str..'* '..unit_battle.battle_name..' (Victor)\n'
                    else
                        battle_history_str = battle_history_str..'* '..unit_battle.battle_name..' (Loser)\n'
                    end
                end
                if battle_history_str ~= 'Unit Battle History\n' then
                    g_textview_text:SetStateText(tostring(battle_history_str..'\n\n'..g_textview_text:GetStateText()))
                    break
                end
            end
        end
        mach_lib.update_mach_lua_log(string.format('Finished populating unit info popup with battle history.'))
        return true
    end


    local function _show_battle_message_box(battle)
        mach_lib.update_mach_lua_log("Showing battle message box.")
        battle.message_auto_show = false
        battle.message_screen_height = 960
        battle.message_screen_width = 1280
        battle.message_icon = "data/ui/eventicons/news.tga"
        battle.message_event = ""
        battle.message_image = _get_battle_message_image(battle)
        battle.message_title, battle.message_text = _get_battle_message_title_and_text(battle)
        battle.message_data = {SubTitle = "", MoviePath = "", PosX = battle.pos_x, PosY = battle.pos_y, PosZ = 0}
        battle.message_layout = "standard"
        battle.message_requires_response = false
        if not battle.is_player_battle then
            mach_lib.show_message_box(battle.message_auto_show, battle.message_screen_height, battle.message_screen_width, battle.message_icon, battle.message_text, battle.message_event, battle.message_image, battle.message_title, battle.message_data, battle.message_layout, battle.message_requires_response)
        else
            mach_lib.update_mach_lua_log('Is Player Battle, will not show Battle Message Box.')
        end
        mach_lib.update_mach_lua_log("Finished showing battle message box.")
    end


    local function on_campaign_settlement_attacked(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - CampaignSettlementAttacked")
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished CampaignSettlementAttacked")
    end


    local function on_character_completed_battle(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - CharacterCompletedBattle")

        if __winner_unit_seen__ == false and __loser_unit_seen__ == false then
            mach_lib.update_mach_lua_log("New battle to process.")
--            if conditions.CharacterWonBattle(context) then
--                mach_lib.update_mach_lua_log("Character won battle.")
--            else
--                mach_lib.update_mach_lua_log("Character lost battle.")
--            end
            __current_battle__ = mach_classes.Battle:new()
            mach_lib.update_mach_lua_log('Adding time trigger of 0.01 seconds')
            mach_lib.scripting.game_interface:add_time_trigger("battle_processing_completed", 0.01)
        end

        local character_details = mach_lib.get_character_details_from_character_context(context, "CharacterCompletedBattle")

        local faction_id = mach_lib.get_faction_id_from_context(context, "CharacterCompletedBattle")

        if string.find(faction_id, 'rebels') then
            __rebel_character_completed_battle__ = true
        else
            __rebel_character_completed_battle__ = false
        end

        local post_battle_military_force = nil
        if not character_details then
--            mach_lib.update_mach_lua_log('tank')
            post_battle_military_force = mach_classes.Army:new(nil, faction_id, context)
        else
--            mach_lib.update_mach_lua_log('tank2')
            if not character_details.IsNaval then
                post_battle_military_force = mach_classes.Army:new(character_details, faction_id)
            else
                post_battle_military_force = mach_classes.Navy:new(character_details, faction_id)
            end
        end

        local is_attacker = nil;
        if conditions.CharacterWasAttacker(context) then
            mach_lib.update_mach_lua_log("Character was attacker during battle.")
            is_attacker = true
        else
            mach_lib.update_mach_lua_log("Character was defender during battle.")
            is_attacker = false
        end

        if conditions.CharacterWonBattle(context) then
            mach_lib.update_mach_lua_log("Character won battle.")
            local pre_battle_winner_military_force = nil
            if not character_details then
                pre_battle_winner_military_force = post_battle_military_force
            else
                pre_battle_winner_military_force = mach_data.__all_factions_military_forces_list__[faction_id][post_battle_military_force.address]
            end
            __current_battle__:add_winner_military_force(pre_battle_winner_military_force, true, is_attacker)
            __current_battle__:add_winner_military_force(post_battle_military_force, false, is_attacker)
            __winner_unit_seen__ = true
        else
            mach_lib.update_mach_lua_log("Character lost battle.")
            local pre_battle_loser_military_force = nil
            if not character_details then
                pre_battle_loser_military_force = post_battle_military_force
            else
                pre_battle_loser_military_force = mach_data.__all_factions_military_forces_list__[faction_id][post_battle_military_force.address]
            end
            __current_battle__:add_loser_military_force(pre_battle_loser_military_force, true, is_attacker)
            __current_battle__:add_loser_military_force(post_battle_military_force, false, is_attacker)
            __loser_unit_seen__ = true
        end

        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished CharacterCompletedBattle")
    end


    local function on_faction_turn_start(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - FactionTurnStart")
        __winner_unit_seen__ = false
        __loser_unit_seen__ = false
        __rebel_character_completed_battle__ = false
    end


    local function on_garrison_residence_captured(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - GarrisonResidenceCaptured")

    end


    local function on_panel_opened_campaign(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - PanelOpenedCampaign")
        --Show battle history in unit info popup
        if conditions.IsComponentType("UnitInfoPopup", context) or conditions.IsComponentType("CharacterInfoUnitInfoPopup", context) then
            mach_lib.update_mach_lua_log('Showing UnitInfoPopup or CharacterInfoUnitInfoPopup')
            if not _populate_unit_info_popup_with_battle_history() then
                mach_lib.update_mach_lua_log("Error, could not populate unit info pop-up!")
            end
        elseif conditions.IsComponentType('CharacterInfoPopup', context) then
            if not _populate_character_info_popup_with_battle_history() then
                mach_lib.update_mach_lua_log("Error, could not populate character info pop-up!")
            end
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished PanelOpenedCampaign")
    end


    local function on_time_trigger(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - TimeTrigger")
        if context.string == "battle_processing_completed" then
            if __winner_unit_seen__ == true then
                mach_lib.update_mach_lua_log('Battle winner unit seen.')
                if __loser_unit_seen__ == false then
                    mach_lib.update_mach_lua_log('Battle losers not seen, getting post battle all factions forces to find losers.')
                    local post_battle_all_factions_military_forces_list = mach_lib.get_all_factions_military_forces()
                    local pre_battle_loser_military_forces, post_battle_loser_military_forces = _get_pre_and_post_battle_loser_military_forces(__current_battle__.pre_battle_winner_military_forces[1], mach_data.__all_factions_military_forces_list__, post_battle_all_factions_military_forces_list)
                    for pre_battle_loser_military_forces_idx = 1, #pre_battle_loser_military_forces do
                        local pre_battle_loser_military_force = pre_battle_loser_military_forces[pre_battle_loser_military_forces_idx]
                        __current_battle__:add_loser_military_force(pre_battle_loser_military_force, true)
                    end
                    for post_battle_loser_military_forces_idx = 1, #post_battle_loser_military_forces do
                        local post_battle_loser_military_force = post_battle_loser_military_forces[post_battle_loser_military_forces_idx]
                        __current_battle__:add_loser_military_force(post_battle_loser_military_force, false)
                    end
                end

                __winner_unit_seen__ = false
                __loser_unit_seen__ = false
                __rebel_character_completed_battle__ = false

                _show_battle_message_box(__current_battle__)

                mach_data.__battles_list__[#mach_data.__battles_list__+1] = __current_battle__

                for participant_faction_id, participant_faction_id in pairs(mach_lib.concat_tables(__current_battle__.winner_faction_ids, __current_battle__.loser_faction_ids)) do
                    mach_lib.update_mach_lua_log('fart')
                    mach_lib.update_mach_lua_log(participant_faction_id)
                    mach_data.__all_factions_military_forces_list__[participant_faction_id] = mach_lib.get_faction_military_forces(participant_faction_id)
                end
                mach_lib.update_mach_lua_log("Finished processing battle.")
            end
        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished TimeTrigger")
    end


    local function on_ui_created(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - UICreated")
    end


    local function on_unit_completed_battle(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - UnitCompletedBattle")
        if __rebel_character_completed_battle__ then
            local unit_culture = mach_lib.get_unit_culture_from_unit_context(context)
            if conditions.UnitWonBattle(context) then
                __current_battle__.winner_faction_ids = mach_lib.update_numbered_list(__current_battle__.winner_faction_ids, 'rebels')
                __current_battle__.winner_culture = unit_culture
                if not __current_battle__.is_naval_battle then
                    __current_battle__.pre_battle_winner_units = __current_battle__.pre_battle_winner_units + 1
                else
                    __current_battle__.pre_battle_winner_ships = __current_battle__.pre_battle_winner_ships + 1
                end
            else
                __current_battle__.loser_faction_ids = mach_lib.update_numbered_list(__current_battle__.loser_faction_ids, 'rebels')
                __current_battle__.loser_culture = unit_culture
                if not __current_battle__.is_naval_battle then
                    __current_battle__.pre_battle_loser_units = __current_battle__.pre_battle_loser_units + 1
                else
                    __current_battle__.pre_battle_loser_ships = __current_battle__.pre_battle_loser_ships + 1
                end
            end
            if not __current_battle__.is_naval_battle then
                __current_battle__.pre_battle_units = __current_battle__.pre_battle_units + 1
            else
                __current_battle__.pre_battle_ships = __current_battle__.pre_battle_ships + 1
            end
        end

--        if not conditions.UnitWonBattle(context) then
--
--        end
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - Finished UnitCompletedBattle")
    end


    events.PreBattle[#events.PreBattle+1] = function(context)
        mach_lib.update_mach_lua_log("Machiavelli's Battle Chronicler - PreBattle")
    end

    events.DummyEvent[#events.DummyEvent+1] = function(context)
        mach_lib.update_mach_lua_log("DummyEvent")
        if conditions.UnitWonBattle(context) then
            mach_lib.update_mach_lua_log("dummy event2")
        end
    end

    mach_lib.scripting.AddEventCallBack("CampaignSettlementAttacked", on_campaign_settlement_attacked)
    mach_lib.scripting.AddEventCallBack("CharacterCompletedBattle", on_character_completed_battle)
    mach_lib.scripting.AddEventCallBack("FactionTurnStart", on_faction_turn_start)
    mach_lib.scripting.AddEventCallBack("GarrisonResidenceCaptured", on_garrison_residence_captured)
    mach_lib.scripting.AddEventCallBack("PanelOpenedCampaign", on_panel_opened_campaign)
    mach_lib.scripting.AddEventCallBack("TimeTrigger", on_time_trigger) 
    mach_lib.scripting.AddEventCallBack("UICreated", on_ui_created)
    mach_lib.scripting.AddEventCallBack("UnitCompletedBattle", on_unit_completed_battle)
end






