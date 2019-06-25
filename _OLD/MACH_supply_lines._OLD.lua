module(..., package.seeall)

WALI = require "WALI/WALI"
mach_lib = require "WALI/mach_lib"
mach_data = require "WALI/mach_data"
ti_lib = require "WALI/TI_lib"
mach_lib.update_mach_lua_log("test")

function supply_lines()
	mach_lib.update_mach_lua_log("MACH_supply_lines.supply_lines")

	local totalCount = 0
	local totalFound = 0
	local firstCharacter = true
	local current_faction_turn = nil
	local character_selected_event = nil
	local charDetails = nil

	local prevEffectTime = 0
	local prevCharacterAddress = nil

	local regionForcesTable = {}
	local noSupplyForces = {}
	local blockingSupplyForces = {}
	local longSupplyTable = {}
	local navalArmySupplierTable = {}



	--supplier fleet trait
	local function naval_army_supplier(context)
		mach_lib.update_mach_lua_log("test")

		local forcesListNavy = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_turn, false)
		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_turn, true)
		local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(current_faction_turn)
		local found = false
		local c = WALI_m_root:Find("MACH_NavalArmySupplier")
		local supplier_admiral_name = nil


		for i = 1, #forcesList do
			local region_key = nil
			local distance = nil
			local nearestRegionCapital = nil
			local nearest = 99999999
			local regionX = 0
			local regionY = 0
			local armyX = 0
			local armyY = 0
			local besiegedSettlements_list = mach_lib.build_besieged_settlements_list()

			for k = 1, #regions do

				forceInSettlement = armyInSettlement(current_faction_turn, forcesList[i])
				region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
				distance = mach_lib.find_distance(forcesList[i].PosX, forcesList[i].PosY, mach_data.region_capitol_coord_list[region_key][1], mach_data.region_capitol_coord_list[region_key][2])

				if #besiegedSettlements_list > 0 then
					for j = 1, #besiegedSettlements_list do
						if besiegedSettlements_list[j] ~= region_key then
							if (distance < nearest) and (distance ~= nil) and not (forceInSettlement) then
								armyX = forcesList[i].PosX
								armyY = forcesList[i].PosY
								regionX = mach_data.region_capitol_coord_list[region_key][1]
								regionY = mach_data.region_capitol_coord_list[region_key][2]
								nearest = distance
								nearestRegionCapital = region_key
							end
						end
					end
				else
					if (distance < nearest) and (distance ~= nil) and not (forceInSettlement) then
						armyX = forcesList[i].PosX
						armyY = forcesList[i].PosY
						regionX = mach_data.region_capitol_coord_list[region_key][1]
						regionY = mach_data.region_capitol_coord_list[region_key][2]
						nearest = distance
						nearestRegionCapital = region_key
					end
				end
			end

        
			--determine region_capital_distance from naval force
			if (WALI.isCharacterInSafeRegion(forcesList[i].Address) == false) then

				for j = 1, #forcesListNavy do
					distance = mach_lib.find_distance(forcesList[i].PosX, forcesList[i].PosY, forcesListNavy[j].PosX, forcesListNavy[j].PosY)

					if(distance < nearest) and (distance ~= nil) and (distance ~= 0) and not (forceInSettlement) then
						armyX = forcesList[i].PosX
						armyY = forcesList[i].PosY
						regionX = forcesListNavy[j].PosX
						regionY = forcesListNavy[j].PosY
						nearest = distance
						nearestRegionCapital = forcesListNavy[j].Name
					end
				end
			end

			if nearestRegionCapital ~= nil then
				navalArmySupplierTable = {}
				navalArmySupplierTable[i] = {}
				navalArmySupplierTable[i][1] = armyX -- army X coordinate
				navalArmySupplierTable[i][2] = armyY -- army Y coordinate
				navalArmySupplierTable[i][3] = regionX -- region X coordinate or fleet coordinate
				navalArmySupplierTable[i][4] = regionY -- region Y coordinate or fleet coordinate
				navalArmySupplierTable[i][5] = tostring(forcesList[i].Name) -- commander's name
				navalArmySupplierTable[i][6] = tostring(nearestRegionCapital) -- region's key or admiral of fleet
				navalArmySupplierTable[i][7] = nearest -- region_capital_distance between army and region capital

				local region_screen_name = nil

				for b = 1, #regionNames_list do
					if regionNames_list[b][2] == "regions_onscreen_"..nearestRegionCapital then
						region_screen_name = regionNames_list[b][4]
					end
				end

				if region_screen_name == nil then
					supplier_admiral_name = nearestRegionCapital

					for count = 1, #characterNames_list do

						y, z = string.find(supplier_admiral_name, characterNames_list[count][4], 1)

						if  not (string.find(supplier_admiral_name, characterNames_list[count][4], 1) == nil) and conditions.CharacterForename(characterNames_list[count][2], context) then

							found = true

							UIComponent(c):SetState("HasNavalArmySupplier")

							UIComponent(c):SetTooltipText("This fleet is supplying "..tostring(forcesList[i].Name).."'s army in "..tostring(forcesList[i].Location)..".")
							UIComponent(c):SetVisible(true)

						end
					end

				end

			end
		end


		return found
	end


	--calculate long supply lines
	local function affectLongSupplyLines(faction, context)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.affectLongSupplyLines")

		local long_supply_name = nil
		local found = false

		if longSupplyTable ~= nil then

			for j = 1, #longSupplyTable do

				if longSupplyTable[j][1] == faction then

					long_supply_name = nil
					long_supply_name = longSupplyTable[j][2]

					if not (long_supply_name == nil) then

						for count = 1, #characterNames_list do
							--mach_lib.update_mach_lua_log("1b")

							y, z = string.find(long_supply_name, characterNames_list[count][4], 1)

							if  not (string.find(long_supply_name, characterNames_list[count][4], 1) == nil) then
								if conditions.CharacterForename(characterNames_list[count][2], context) then
									mach_lib.update_mach_lua_log("\t\t Found matching character on map that matches character in longSupplyTable.")

									found = true
									local points = 0
									--mach_lib.update_mach_lua_log(longSupplyTable[besieged_settlements_idx][3])
									if (longSupplyTable[j][3] >= WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_1__ and longSupplyTable[j][3] < WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_2__) then
										points = 1
									elseif (longSupplyTable[j][3] >= WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_2__ and longSupplyTable[j][3] < WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_3__) then
										points = 2
									elseif (longSupplyTable[j][3] >= WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_3__ and longSupplyTable[j][3] < WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_4__) then
										points = 3
									elseif (longSupplyTable[j][3] >= WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_4__ and longSupplyTable[j][3] < WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_5__) then
										points = 4
									elseif (longSupplyTable[j][3] >= WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_5__) then
										points = 5
									end


									local good_count = conditions.CharacterTrait("C_General_LongSupply_Good", context)
									local bad_count = conditions.CharacterTrait("C_General_LongSupply_Bad", context)
									local target = points - bad_count
									local nearestCapital = nil
									mach_lib.update_mach_lua_log("\t\t Set to adjust long supply with total points:" ..tostring(points))

									--mach_lib.update_mach_lua_log("target: "..tostring(target))
									if target < 0 then
										for h = 1, math.abs(target) do
											effect.trait("C_General_LongSupply_Good", "agent", 1, 100, context)
										end
									else
										for h = 1, target do
											--mach_lib.update_mach_lua_log(conditions.CharacterTrait("C_General_LongSupply_Bad", context))

											effect.trait("C_General_LongSupply_Bad", "agent", 1, 100, context)
										end
									end
									if target > 1 then
										mach_lib.update_mach_lua_log("\t\t Added \"C_General_LongSupply_Bad_"..tostring(target).."\" trait to "..long_supply_name.." of "..tostring(faction))
									end
									--mach_lib.update_mach_lua_log(tostring(conditions.CharacterTrait("C_General_LongSupply_Bad", context)))
									--mach_lib.update_mach_lua_log(tostring(conditions.CharacterTrait("C_General_LongSupply_Good", context)))


									local found_settlement = false
									local c = WALI_m_root:Find("MACH_LongSupplyPip")

									--mach_lib.update_mach_lua_log(longSupplyTable[besieged_settlements_idx][4].."'s fleet "..bad_count)

									for h = 1, #settlementNames_list do
										--mach_lib.update_mach_lua_log("hi "..settlement_names_list[h][2].." : "..bad_count)
										--mach_lib.update_mach_lua_log(string.find(settlement_names_list[h][2], "start_pos_settlements_onscreen_name_"..regionToSettlementList[longSupplyTable[besieged_settlements_idx][4]], 1))
										--mach_lib.update_mach_lua_log(regionToSettlementList["bosnia"])
										--mach_lib.update_mach_lua_log("start_pos_settlements_onscreen_name_"..regionToSettlementList[longSupplyTable[besieged_settlements_idx][4]])
										if not (regionToSettlementList[longSupplyTable[j][4]] == nil) then
											if  not (string.find(settlementNames_list[h][2], "start_pos_settlements_onscreen_name_"..regionToSettlementList[longSupplyTable[j][4]], 1) == nil) then
												--mach_lib.update_mach_lua_log(settlement_names_list[h][2].." - "..settlement_names_list[h][4])
												nearestCapital = settlementNames_list[h][4]
												found_settlement = true
												break
											end
										end
									end
									mach_lib.update_mach_lua_log("\t\t Setting state in UI to: HasLongSuppply"..tostring(bad_count))

									UIComponent(c):SetState("HasLongSupply"..bad_count)

									if (nearestCapital ~= nil) then
										if (bad_count == 1) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..nearestCapital.." are starting to get extended.")
										elseif (bad_count == 2) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..nearestCapital.." have continued to extend.")
										elseif (bad_count == 3) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..nearestCapital.." are now long.")
										elseif (bad_count == 4) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..nearestCapital.." are very long.")
										elseif (bad_count == 5) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..nearestCapital.." are extremely long.")
										end
									else
										if (bad_count == 1) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..longSupplyTable[j][4].."'s fleet are starting to get extended.")
										elseif (bad_count == 2) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..longSupplyTable[j][4].."'s fleet have continued to extend.")
										elseif (bad_count == 3) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..longSupplyTable[j][4].."'s fleet are now long.")
										elseif (bad_count == 4) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..longSupplyTable[j][4].."'s fleet are very long.")
										elseif (bad_count == 5) then
											UIComponent(c):SetTooltipText("This army's supply lines from "..longSupplyTable[j][4].."'s fleet are extremely long.")
										end
									end
									mach_lib.update_mach_lua_log("\t\t Making pip visible for HasLongSuppply"..tostring(bad_count).." on UI.")

									UIComponent(c):SetVisible(true)

								end
							end
						end
					end
				end
			end
		end

		if found == false and (conditions.CharacterTrait("C_General_LongSupply_Bad", context) >= 1) then
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

			mach_lib.update_mach_lua_log("Removed \"C_General_LongSupply_Bad\" trait from "..foreName.." "..surName)
			local good_count = conditions.CharacterTrait("C_General_LongSupply_Good", context)
			local bad_count = conditions.CharacterTrait("C_General_LongSupply_Bad", context)
			local target = bad_count - good_count
			for h = 1, target do
				effect.trait("C_General_LongSupply_Good", "agent", 1, 100, context)
			end
		end
	end


	--determine if army is located in a settlement
	local function armyInSettlement(faction, army)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.armyInSettlement")

		local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction)

		local region_key = nil
		local distance = nil
		local army_in_settlement = false

		for k = 1, #regions do

			region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
			distance = mach_lib.find_distance(army.PosX, army.PosY, mach_data.region_capitol_coord_list[region_key][1], mach_data.region_capitol_coord_list[region_key][2])

			--mach_lib.update_mach_lua_log(army.PosX.." "..army.PosY.." "..mach_data.region_capital_coord_list[region_key][1].." "..mach_data.region_capital_coord_list[region_key][2])

			--mach_lib.update_mach_lua_log(faction_key.." - "..region_key.." region_capital_distance: "..region_capital_distance)
			if (distance < 0.001) and (distance > -0.001) and (distance ~= nil) then
				army_in_settlement = true
			end

		end

		if (army_in_settlement == true) then
			return true
		else
			return false
		end


	end


	--get region_capital_distance of enemy units from the line of supply (to determine if interrupting supply)
	local function getDistanceFromLine(slope, y_intercept, index, faction)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.getDistanceFromLine")

		local diplomacy = CampaignUI.RetrieveDiplomacyDetails(faction)
		local count = 0


		for k, v in pairs(diplomacy.AtWar) do
			if (blockingSupplyForces[k]	~= nil) then
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

							if (mach_lib.find_distance(PosX, PosY, x_intersection, y_intersection) <= WALI.MACH_distance_from_supply_line) then

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


	--get the equation and variable for the line of supply
	local function getLineEquation(index, faction)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.getLineEquation")

		local slope  = (regionForcesTable[index][2] - regionForcesTable[index][4]) / (regionForcesTable[index][1] - regionForcesTable[index][3])

		local y_intercept = regionForcesTable[index][2] - (slope * regionForcesTable[index][1])

		--mach_lib.update_mach_lua_log("slope: "..slope.." y intercept: "..y_intercept)

		getDistanceFromLine(slope, y_intercept, index, faction)
	end


	--determine closes friendly region capital to pick for line of supply beginning point
	local function determineClosestCapital(faction_key)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.determine_closest_friendly_capital")

		if character_selected_event ~= true then
			noSupplyForces[faction_key] = {}
		end
		totalCount = 0
		totalFound = 0


		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(faction_key, true)
		local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_key)


		for i = 1, #forcesList do
			local region_key = nil
			local distance = nil
			local nearestRegionCapital = nil
			local nearest = 99999999
			local regionX = 0
			local regionY = 0
			local armyX = 0
			local armyY = 0
            local besiegedSettlements_list = mach_lib.build_besieged_settlements_list()
			local forceInSettlement = armyInSettlement(faction_key, forcesList[i])

			for k = 1, #regions do

				region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
				distance = mach_lib.find_distance(forcesList[i].PosX, forcesList[i].PosY, mach_data.region_capitol_coord_list[region_key][1], mach_data.region_capitol_coord_list[region_key][2])

				if #besiegedSettlements_list > 0 then
					for j = 1, #besiegedSettlements_list do
						if besiegedSettlements_list[j] ~= region_key then
							if (distance < nearest) and (distance~=nil) and not (forceInSettlement) then

								armyX = forcesList[i].PosX
								armyY = forcesList[i].PosY
								regionX = mach_data.region_capitol_coord_list[region_key][1]
								regionY = mach_data.region_capitol_coord_list[region_key][2]
								nearest = distance
								nearestRegionCapital = region_key
							end
						end
					end
				else
					if (distance < nearest) and (distance~=nil) and not (forceInSettlement) then

						armyX = forcesList[i].PosX
						armyY = forcesList[i].PosY
						regionX = mach_data.region_capitol_coord_list[region_key][1]
						regionY = mach_data.region_capitol_coord_list[region_key][2]
						nearest = distance
						nearestRegionCapital = region_key
					end
				end


			end

			--determine region_capital_distance from naval force
			if (WALI.isCharacterInSafeRegion(forcesList[i].Address) == false) then
				local forcesListNavy = CampaignUI.RetrieveFactionMilitaryForceLists(faction_key, false)

				for j = 1, #forcesListNavy do
					distance = mach_lib.find_distance(forcesList[i].PosX, forcesList[i].PosY, forcesListNavy[j].PosX, forcesListNavy[j].PosY)

					if(distance < nearest) and (distance ~= nil) and (distance ~= 0) and not (forceInSettlement) then
						armyX = forcesList[i].PosX
						armyY = forcesList[i].PosY
						regionX = forcesListNavy[j].PosX
						regionY = forcesListNavy[j].PosY
						nearest = distance
						nearestRegionCapital = forcesListNavy[j].Name
					end
				end
			end

			if nearestRegionCapital ~= nil then
				--this is for disrupting and no supply
				regionForcesTable = {}
				regionForcesTable[i] = {}
				regionForcesTable[i][1] = armyX -- army X coordinate
				regionForcesTable[i][2] = armyY -- army Y coordinate
				regionForcesTable[i][3] = regionX -- region X coordinate
				regionForcesTable[i][4] = regionY -- region Y coordinate
				regionForcesTable[i][5] = tostring(forcesList[i].Name) -- commander's name
				regionForcesTable[i][6] = tostring(nearestRegionCapital) -- region's key or admiral of fleet
				regionForcesTable[i][7] = nearest -- region_capital_distance between army and region capital


				--determine if long supply line
				if nearest > WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_1__ and faction_key == current_faction_turn and not (forceInSettlement) then
					local found = false
					local ind = nil
					for r = 1, #longSupplyTable do
						if longSupplyTable[r][2] == tostring(forcesList[i].Name) then
							mach_lib.update_mach_lua_log("\t\t Army already in longSupplyTable. Modifying current values.")
							longSupplyTable[r][3] = nearest --region_capital_distance from region capital
							longSupplyTable[r][4] = tostring(nearestRegionCapital) --region key
							found = true
						elseif longSupplyTable[r] == nil then
							ind = r
						end
					end

					if ind == nil then
						ind = #longSupplyTable + 1
					end

					if found == false then
						mach_lib.update_mach_lua_log("\t\t Found army with long supply line. Adding to longSupplyTable.")

						--mach_lib.update_mach_lua_log("HI "..faction_key.."-"..nearest.."-"..tostring(forcesList[i].Name).."-"..tostring(nearestRegionCapital))
						longSupplyTable[ind] = {}
						mach_lib.update_mach_lua_log("\t\t\t Faction key :"..faction_key)
						longSupplyTable[ind][1] = faction_key --faction_key key
						mach_lib.update_mach_lua_log("\t\t\t Commander's name: "..tostring(forcesList[i].Name))
						longSupplyTable[ind][2] = tostring(forcesList[i].Name) --commander's name
						mach_lib.update_mach_lua_log("\t\t\t Distance from nearest supply location:"..tostring(nearest))
						longSupplyTable[ind][3] = nearest --region_capital_distance from region capital
						mach_lib.update_mach_lua_log("\t\t\t Nearest supply location:"..tostring(nearestRegionCapital))
						longSupplyTable[ind][4] = tostring(nearestRegionCapital) --region key
					end

				else
					for r = 1, #longSupplyTable do
						if longSupplyTable[r][2] == tostring(forcesList[i].Name) then
							longSupplyTable[r] = {}
						end
					end
				end

				getLineEquation(i, faction_key)


				--mach_lib.update_mach_lua_log(forcesList[i].Name.." - "..nearestRegionCapital.." is nearest. At "..nearest)
			end
		end

		if faction_key ~= current_faction_turn then

			faction_key = current_faction_turn
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(faction_key, true)
			local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction_key)

			for i = 1, #forcesList do
				local region_key = nil
				local distance = nil
				local nearestRegionCapital = nil
				local nearest = 99999999
				local regionX = 0
				local regionY = 0
				local armyX = 0
				local armyY = 0
                local besiegedSettlements_list = mach_lib.build_besieged_settlements_list()
				local forceInSettlement = armyInSettlement(faction_key, forcesList[i])


				for k = 1, #regions do
					region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
					distance = mach_lib.find_distance(forcesList[i].PosX, forcesList[i].PosY, mach_data.region_capitol_coord_list[region_key][1], mach_data.region_capitol_coord_list[region_key][2])

					if #besiegedSettlements_list > 0 then
						for j = 1, #besiegedSettlements_list do
							if besiegedSettlements_list[j] ~= region_key then
								if (distance < nearest) and (distance~=nil) and not (forceInSettlement) then
									armyX = forcesList[i].PosX
									armyY = forcesList[i].PosY
									regionX = mach_data.region_capitol_coord_list[region_key][1]
									regionY = mach_data.region_capitol_coord_list[region_key][2]
									nearest = distance
									nearestRegionCapital = region_key

								end
							end
						end
					else
						if (distance < nearest) and (distance~=nil) and not (forceInSettlement) then

							armyX = forcesList[i].PosX
							armyY = forcesList[i].PosY
							regionX = mach_data.region_capitol_coord_list[region_key][1]
							regionY = mach_data.region_capitol_coord_list[region_key][2]
							nearest = distance
							nearestRegionCapital = region_key

						end
					end


				end
				--mach_lib.update_mach_lua_log("HI "..faction_key.."-"..tostring(nearest).."-"..tostring(forcesList[i].Name).." - "..tostring(nearestRegionCapital))

				--determine region_capital_distance from naval force
				if (WALI.isCharacterInSafeRegion(forcesList[i].Address) == false) then
					local forcesListNavy = CampaignUI.RetrieveFactionMilitaryForceLists(faction_key, false)

					for j = 1, #forcesListNavy do
						distance = mach_lib.find_distance(forcesList[i].PosX, forcesList[i].PosY, forcesListNavy[j].PosX, forcesListNavy[j].PosY)

						if(distance < nearest) and (distance~=nil) and not (forceInSettlement) and (distance ~= 0) then
							armyX = forcesList[i].PosX
							armyY = forcesList[i].PosY
							regionX = forcesListNavy[j].PosX
							regionY = forcesListNavy[j].PosY
							nearest = distance
							nearestRegionCapital = forcesListNavy[j].Name
						end
					end


				end

				--determine if long supply line
				if nearest > WALI.__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_1__ and not (forceInSettlement) then

					local found = false
					local ind = nil
					for r = 1, #longSupplyTable do
						if longSupplyTable[r][2] == tostring(forcesList[i].Name) then
							longSupplyTable[r][3] = nearest --region_capital_distance from region capital
							longSupplyTable[r][4] = tostring(nearestRegionCapital) --region key
							found = true
						elseif longSupplyTable[r] == nil then
							ind = r
						end
					end


					if ind == nil then
						ind = #longSupplyTable + 1
					end

					if found == false then
						--mach_lib.update_mach_lua_log("HI "..faction_key.."-"..nearest.."-"..tostring(forcesList[i].Name).."-"..tostring(nearestRegionCapital))
						longSupplyTable[ind] = {}
						longSupplyTable[ind][1] = faction_key
						longSupplyTable[ind][2] = tostring(forcesList[i].Name)
						longSupplyTable[ind][3] = nearest
						longSupplyTable[ind][4] = nearestRegionCapital
					end
				else
					for r = 1, #longSupplyTable do
						if longSupplyTable[r][2] == tostring(forcesList[i].Name) then
							longSupplyTable[r] = {}
						end
					end

				end
			end
		end

  end




	events.UICreated[#events.UICreated+1] = function(context)
		mach_lib.update_mach_lua_log("test")

		if context.string == "Campaign UI" then
			WALI_m_root = UIComponent(context.component)
			firstCharacter = true
			prevEffectTime = 0
			prevCharacterAddress = nil
		end
	end


	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.events.FactionTurnStart")

		firstCharacter = true
		prevEffectTime = 0
		prevCharacterAddress = nil

	end


	events.CharacterTurnEnd[#events.CharacterTurnEnd+1] = function(context)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.events.CharacterTurnEnd")

		character_selected_event = false

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

			determineClosestCapital(current_faction_turn)


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
						y, z = string.find(no_supply_name, characterNames_list[count][4], 1)

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
							y, z = string.find(block_supply_name, characterNames_list[count][4], 1)

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


	--CharacterSelected event calls this
	local function startCalculating(context)
		mach_lib.update_mach_lua_log("InterruptableSupplyLines.startCalculating")

		local ETS = CampaignUI.EntityTypeSelected()

		if WALI_isOnCampMap and (conditions.CharacterType("admiral", context) or conditions.CharacterType("captain", context)) then
			naval_traits(context)

		elseif WALI_isOnCampMap and (conditions.CharacterType("General", context) or conditions.CharacterType("colonel", context)) then

			land_traits(context)
		end


	end


    events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)
        mach_lib.update_mach_lua_log("InterruptableSupplyLines.events.ComponentLClickUp")

        local IsArtillery = nil

        if WALI_isOnCampMap == true then
            local ETS = CampaignUI.EntityTypeSelected()
            if ETS.Character then
                charDetails = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
                entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(ETS.Entity, ETS.Entity)


                for k, v in pairs(charDetails) do

                    --mach_lib.update_mach_lua_log(tostring(k).."\t"..tostring(v))
                    if type(v) == "table" then

                        for kk, vv in pairs(v) do
                            --mach_lib.update_mach_lua_log("\t\t"..tostring(kk).."\t"..tostring(vv))
                            if type(vv) == "table" then
                                for kkk, vvv in pairs(vv) do
                                    --mach_lib.update_mach_lua_log("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
                                end
                            end
                        end
                    end
                end
            elseif ETS.Unit then
                --mach_lib.update_mach_lua_log("Unit table")
                charDetails = CampaignUI.InitialiseUnitDetails(ETS.Entity)
                if charDetails.IsArtillery then

                end
                for k, v in pairs(charDetails) do

                    --mach_lib.update_mach_lua_log(tostring(k).."\t"..tostring(v))
                    if type(v) == "table" then
                        for kk, vv in pairs(v) do

                            --mach_lib.update_mach_lua_log("\t\t"..tostring(kk).."\t"..tostring(vv))
                            if type(vv) == "table" then
                                for kkk, vvv in pairs(vv) do
                                    --mach_lib.update_mach_lua_log("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --
--
--	--[[
--	--Time trigger event
--	events.TimeTrigger[#events.TimeTrigger+1] = function(context)
--		if context.string == "MoveWatch_Supply" and WALI_armyIsSelected then
--
--			startCalculating(selected_character_context)
--
--		end
--	end
--	--]]


end







