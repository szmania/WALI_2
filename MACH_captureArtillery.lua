--CaptureArtillery
local winner_factionKey = nil
local loser_factionKey = nil
local attacker_Surname = nil
local defender_Surname = nil
local attacker_character_context = nil
local defender_character_context = nil
local attacker_Region = nil
local defender_Region = nil
local prevUnitCompletedBattle_context = nil
local battleBelligerentsProcessed = false
local winnerUnitSeen = false
local loserUnitSeen = false
local prevBattleTime = nil
local totalGunsTaken = 0
local popup_battle_results_open = false
local unit_list_visible = false
local art_num_sold = 0
local this_battle_art_num_sold = 0
local adjustTreasuryValue = 0
local this_battle_adjustTreasuryValue = 0
local sold_art = false
local research_increase = false
local researchPoints = 0
local this_battle_researchPoints = 0


results_init = nil

local regionsTable = {}
local artilleryForcesTable = {}
local foughtInLastBattleTable = {}
local beginArtilleryTable = {}


--captures artillery abandoned on battlefield
function capture_artillery()
  mach_lib.set_mach_log_func_name("MACH_captureArtillery.capture_artillery")
  
  mach_lib.update_mach_lua_log("Initializing Machiavelli's Mods.")

	local attacker_factionKey = nil
	local defender_factionKey = nil

  local function initialize_capture_artillery()
    mach_lib.msg_box("Machiavelli's \"Capture Artillery mod\" successfully activated!\n")
  end

	--sell artillery that is not matched in winner's army
	local function sell_artillery(recruitCost, menLost, defaultUnitSize, faction)
		mach_lib.update_mach_lua_log("CaptureArtillery.sell_artillery")

		local percentLost = menLost / defaultUnitSize 
		
		if (percentLost > 1) then
			percentLost = 1
		end
		
		local money = recruitCost * percentLost
		adjustTreasuryValue = math.floor(adjustTreasuryValue + money)
		this_battle_adjustTreasuryValue = math.floor(adjustTreasuryValue + money)
		sold_art = true
		art_num_sold = mach_lib.get_artillery_num_from_men_count(menLost)
		this_battle_art_num_sold = mach_lib.get_artillery_num_from_men_count(menLost)
		
	end
	
	--increase military reasearch for gentlmen for every 4 guns caught that were not matched by winner army
	local function research_artillery(numOfGuns, faction)
		mach_lib.update_mach_lua_log("CaptureArtillery.research_artillery")

		local points = math.floor(numOfGuns / 5)
		researchPoints = researchPoints + points
		this_battle_researchPoints = this_battle_researchPoints + points
		research_increase = true
	end

	--popup dialogue telling the number of artillery caught
	--not used as the number is now posted in battle results panel
	local function capture_art_notice(gunsTaken)
		mach_lib.update_mach_lua_log("CaptureArtillery.capture_art_notice")

		local utils = require("Utilities")
		local panel_manager = utils.Require("panelmanager")
		panel_manager.OpenPanel("dialogue_box", true, "Initialise", "You have captured enemy artillery.\n"..gunsTaken.." artillery pieces.")
	end

	
	--determines if passed in faction key is loser faction of fought battle
	local function isLoserFaction(faction_key)
		mach_lib.update_mach_lua_log("CaptureArtillery.isLoserFaction")

		if tostring(loser_factionKey) == tostring(faction_key) then
			return true
		end
		local diplomacy = CampaignUI.RetrieveDiplomacyDetails(faction_key)
		for kk, vv in pairs(diplomacy.AtWar) do
			if tostring(kk) == tostring(winner_factionKey) then
				return true
			end
		end
		
		return false
	end
	
	
	--adjustments are made here between artillery units and their guns
	local function artillery_adjustment( defeatedUnit_key, defeatedUnit_location, defeatedUnit_PosX, defeatedUnit_PosY, defeatedUnit_Guns, defeatedUnit_Address, defeatedUnit_Nation, defeatedUnit_numGunsLost, defeatedUnit_RecruitCost, defeatedUnit_MenLost, defeatedUnit_defaultUnitSize)
		mach_lib.update_mach_lua_log("CaptureArtillery.artillery_adjustment")

		totalGunsTaken = totalGunsTaken + defeatedUnit_numGunsLost
		
		mach_lib.update_mach_lua_log("\t\t Number of guns to adjust for: "..defeatedUnit_numGunsLost)
		--mach_lib.update_mach_lua_log("VARIABLES PASSED IN: "..tostring(defeatedUnit_key).." - "..tostring(defeatedUnit_location).."-"..tostring(defeatedUnit_PosX).." - "..tostring(defeatedUnit_PosY).." - "..tostring(defeatedUnit_Guns).." - "..tostring(defeatedUnit_numGunsLost))

		local found = false
		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(winner_factionKey, true)
		local matchTable= {}
		local a = 1
		local foundNum = 0
		mach_lib.update_mach_lua_log("4")

		for n = 1, #forcesList do
			--mach_lib.update_mach_lua_log("3a")

			local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[n].Address, forcesList[n].Address)
			--mach_lib.update_mach_lua_log("3")

			for k,v in pairs(entities.Units) do
				--mach_lib.update_mach_lua_log("2")

				if v.IsArtillery then	
					--mach_lib.update_mach_lua_log("1")

					local distance = mach_lib.find_distance(defeatedUnit_PosX, defeatedUnit_PosY, forcesList[n].PosX, forcesList[n].PosY)
					mach_lib.update_mach_lua_log("\t\t Found winnerious artillery unit distance from captured artillery unit: "..distance)
					
					if ((artyToGunType_list[v.UnitRecord.Key] == artyToGunType_list[defeatedUnit_key]) or (v.UnitRecord.Key == defeatedUnit_key)) and (distance < 4) then
						mach_lib.update_mach_lua_log("\t\t Found similar unit NEAR unit "..tostring(defeatedUnit_key).." - "..tostring(defeatedUnit_location).." - "..defeatedUnit_PosX.." - "..defeatedUnit_PosY)
						mach_lib.update_mach_lua_log("\t\t MATCH: " .. tostring(v.Address).." - "..v.UnitRecord.Key.." - "..forcesList[n].Location.." - "..forcesList[n].PosX.." - "..forcesList[n].PosY)
						


						found = true
						foundNum = foundNum + 1
						matchTable[a] = {}
						matchTable[a][1] = tostring(v.Address) -- match address
						
						local unit_replenish_number = WALI.GetUnitReplenishable(v.Address, optionalHeader)
						
						if (unit_replenish_number == false) then
							matchTable[a][2] = 0
						elseif (unit_replenish_number  == true) then
							matchTable[a][2] = 1
						else 
							matchTable[a][2] = tostring(unit_replenish_number)
						end

						matchTable[a][3] = v  --unit object

						a = a + 1
					end
				end
			end
		end


		if (found==false) then
			mach_lib.update_mach_lua_log("\t\t Could not find similar gun types in winnerious army.")

			if ((defeatedUnit_numGunsLost / 5) >= 1) then
				mach_lib.update_mach_lua_log("\t\t Giving artillery research points.")
				research_artillery(defeatedUnit_numGunsLost, winner_factionKey)
			end	
			mach_lib.update_mach_lua_log("\t\t Selling captured artillery for money.")
			sell_artillery(defeatedUnit_RecruitCost, defeatedUnit_MenLost, defeatedUnit_defaultUnitSize, winner_factionKey)
		end
		
		if(foundNum > 0) then
			mach_lib.update_mach_lua_log("\t\t Ccould find similar gun types in winnerious army.")

			local index = 1
			local m = 0
			while(m < tonumber(defeatedUnit_numGunsLost)) do

				if (index == foundNum) then
					if( tonumber(matchTable[index][2]) > tonumber(matchTable[1][2])) then
						index = 1
						
					end
				elseif (index < foundNum) then
					local num = index + 1

					if( tonumber(matchTable[index][2]) > tonumber(matchTable[num][2])) then
					--if ( tonumber(matchTable[index][2]) > tonumber(matchTable[index+1][2])) then
						index = index + 1

					end

				else
					index = 1
				end

				local numGunsTotal = mach_lib.get_artillery_num_from_men_count(matchTable[index][2]) + 1
				local unitReplenishTotal = (numGunsTotal * 5) - 1
				matchTable[index][2] = unitReplenishTotal	
				
				--mach_lib.update_mach_lua_log(numGunsTotal.." - "..matchTable[index][1])
				WALI.SetUnitReplenishable(matchTable[index][1], unitReplenishTotal, optionalHeader)
				WALI.SetMaximumUnitSize(matchTable[index][1], unitReplenishTotal, optionalHeader)
				--mach_lib.update_mach_lua_log("HEY "..(matchTable[index][3].Men).." - "..unitReplenishTotal)
							
				mach_lib.update_mach_lua_log("\t\t Men to replenish to: "..unitReplenishTotal..". Number of enemy guns taken: "..defeatedUnit_numGunsLost)
				index = index + 1	
				m = m + 1
			end
		
		end		

	end

	

	--compare artilleryForcesTable table with the artillery units on the map
	local function findArtyUnitsWithLosses()
		mach_lib.update_mach_lua_log("CaptureArtillery.findArtyUnitsWithLosses")

		--mach_lib.update_mach_lua_log("Comparing artilleryForcesTable")
				

		for j = 1, #artilleryForcesTable do	

			--mach_lib.update_mach_lua_log("HJERE:"..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]))	
			local found = false
			local lossGuns = false
			local numGunsLost = 0
			local numMenLost = 0
			local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
			local faction_isLoserFaction = isLoserFaction(tostring(artilleryForcesTable[j][1]))
			
			--mach_lib.update_mach_lua_log("HERE "..tostring(artilleryForcesTable[j][11]).."-"..tostring(artilleryForcesTable[j][1]).."-"..tostring(artilleryForcesTable[j][2]).."-"..tostring(artilleryForcesTable[j][4]).."-"..tostring(artilleryForcesTable[j][8]))
			
			for k2, v2 in pairs(faction_list) do
				local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(v2.Key, true)
				for i = 1, #forcesList do
					local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
					for k,v in pairs(entities.Units) do
						found = false
						if v.IsArtillery then
									
							if tostring(artilleryForcesTable[j][11]) == tostring(v.Address) then
								found = true							
						
								if tostring(artilleryForcesTable[j][6]) <= tostring(v.Men) then					
									lossGuns = false

								elseif tonumber(artilleryForcesTable[j][6]) > tonumber(v.Men) then
								
									if tonumber(mach_lib.get_artillery_num_from_men_count(artilleryForcesTable[j][6])) > mach_lib.get_artillery_num_from_men_count(v.Men) then
										numGunsLost = tonumber(mach_lib.get_artillery_num_from_men_count(artilleryForcesTable[j][6])) - mach_lib.get_artillery_num_from_men_count(v.Men)
										numMenLost = artilleryForcesTable[j][6] - v.Men
										lossGuns = true
									end
									
								end
										
										
								break		
							end
						
						end				
					end
					
					if (found==true) then
						break
					end
				end
				if (found==true) then
					break
				end
			end

			--mach_lib.update_mach_lua_log("HJERE:"..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]))	

			--mach_lib.update_mach_lua_log("HERE "..tostring(found).." - "..tostring(lossGuns).."-"..table.getn(artilleryForcesTable))

			if (found==false)  then

				numGunsLost = mach_lib.get_artillery_num_from_men_count(artilleryForcesTable[j][6])
				numMenLost = artilleryForcesTable[j][6]

				
					--mach_lib.update_mach_lua_log("NOT FOUND: "..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]))

					
					--mach_lib.update_mach_lua_log("WINNER: "..tostring(winner_factionKey))
					--mach_lib.update_mach_lua_log("LOSER: "..tostring(loser_factionKey))
				
					
				if tostring(winner_factionKey) == tostring(artilleryForcesTable[j][1]) then
					--mach_lib.update_mach_lua_log("Unit is part of winner faction: "..tostring(artilleryForcesTable[j][1]))
				elseif (faction_isLoserFaction) then
					mach_lib.update_mach_lua_log("Artillery unit is part of loser faction and doesn't exist any more: "..tostring(artilleryForcesTable[j][1]))
					
					--mach_lib.update_mach_lua_log("ARGUMENTS PASSED IN: "..artilleryForcesTable[j][2]..artilleryForcesTable[j][4])

					artillery_adjustment( artilleryForcesTable[j][2], artilleryForcesTable[j][4], artilleryForcesTable[j][9], artilleryForcesTable[j][10], artilleryForcesTable[j][7], artilleryForcesTable[j][11], artilleryForcesTable[j][1], numGunsLost, artilleryForcesTable[j][12], numMenLost, artilleryForcesTable[j][13])			

				end

	
			elseif (found == true) and (artilleryForcesTable[j][8] == true) then
				
				if (faction_isLoserFaction) then
					numGunsLost = tonumber(mach_lib.get_artillery_num_from_men_count(artilleryForcesTable[j][6]))
					numMenLost = artilleryForcesTable[j][6]
					mach_lib.update_mach_lua_log("Loser unit is fixed artillery. Therefore it lost all its guns unable to retreat: "..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]).." - "..tostring(artilleryForcesTable[j][5]).." - "..tostring(artilleryForcesTable[j][6]))
					artillery_adjustment( artilleryForcesTable[j][2], artilleryForcesTable[j][4],artilleryForcesTable[j][9], artilleryForcesTable[j][10], artilleryForcesTable[j][7], artilleryForcesTable[j][11], artilleryForcesTable[j][1], numGunsLost, artilleryForcesTable[j][12], numMenLost, artilleryForcesTable[j][13])			

				end

	
			elseif (found == true) and (lossGuns == true) then						
				--mach_lib.update_mach_lua_log("WINNER: "..tostring(winner_factionKey))
				--mach_lib.update_mach_lua_log("LOSER: "..tostring(loser_factionKey))

				if tostring(winner_factionKey) == tostring(artilleryForcesTable[j][1]) then
					--mach_lib.update_mach_lua_log("Unit is part of winner faction: "..tostring(artilleryForcesTable[j][1]))
				elseif (faction_isLoserFaction) then
					mach_lib.update_mach_lua_log("LOSER LOST GUNS but still exists: "..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]).." - "..tostring(artilleryForcesTable[j][5]).." - "..tostring(artilleryForcesTable[j][6]))
					artillery_adjustment( artilleryForcesTable[j][2], artilleryForcesTable[j][4],artilleryForcesTable[j][9], artilleryForcesTable[j][10], artilleryForcesTable[j][7], artilleryForcesTable[j][11], artilleryForcesTable[j][1], numGunsLost, artilleryForcesTable[j][12], numMenLost, artilleryForcesTable[j][13])			

					--mach_lib.update_mach_lua_log("Unit is part of loser faction AND LOST GUNS: "..tostring(artilleryForcesTable[j][1]))
				end				
			end
		end
		

	end

	
	--create artilleryForcesTable table, which has all artillery units on map in it
	local function create_artilleryForcesTable()
		mach_lib.update_mach_lua_log("CaptureArtillery.create_artilleryForcesTable")

		artilleryForcesTable = {}

		local a = 1
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k2, v2 in pairs(faction_list) do		
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(v2.Key, true)
			for i = 1, #forcesList do
				local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
				for k,v in pairs(entities.Units) do
					if v.IsArtillery then
						mach_lib.update_mach_lua_log("\t\t Found artillery unit to add to table.")

						artilleryForcesTable[a] = {}
						mach_lib.update_mach_lua_log("\t\t\t Adding faction key: "..tostring(v2.Key))
						artilleryForcesTable[a][1] = tostring(v2.Key) -- faction key
						
						mach_lib.update_mach_lua_log("\t\t\t Adding unit key: "..tostring(v.UnitRecord.Key))
						artilleryForcesTable[a][2] = tostring(v.UnitRecord.Key) -- unit key
						
						mach_lib.update_mach_lua_log("\t\t\t Adding commander's name: "..tostring(v.CommandersName))
						artilleryForcesTable[a][3] = tostring(v.CommandersName) -- commanders name
						
						mach_lib.update_mach_lua_log("\t\t\t Adding location: "..tostring(forcesList[i].Location))
						artilleryForcesTable[a][4] = tostring(forcesList[i].Location) -- location
						
						mach_lib.update_mach_lua_log("\t\t\t Adding replenishment size: "..tostring(WALI.GetUnitReplenishable(v.Address, optionalHeader)))
						artilleryForcesTable[a][5] = tostring(WALI.GetUnitReplenishable(v.Address, optionalHeader)) -- replenishment size
						
						mach_lib.update_mach_lua_log("\t\t\t Adding unit size: "..tostring(v.Men))
						artilleryForcesTable[a][6] = tostring(v.Men) -- unit size
						artilleryForcesTable[a][7] = tostring(v.UnitRecord.Guns) -- number of artillery
						artilleryForcesTable[a][8] = tostring(v.IsFixedArtillery) -- is fixed artillery
						artilleryForcesTable[a][9] = tostring(forcesList[i].PosX) -- Position X
						artilleryForcesTable[a][10] = tostring(forcesList[i].PosY) -- Position Y
						artilleryForcesTable[a][11] = tostring(v.Address) -- Unit address
						artilleryForcesTable[a][12] = tostring(v.RecruitCost) -- Unit recruitment cost
						artilleryForcesTable[a][13] = tostring(v.UnitRecord.Men) -- Unit default unit size
						--mach_lib.update_mach_lua_log("HERE - "..tostring(artilleryForcesTable[a][1]))
						a = a + 1
					end
				end
			end
		end
		mach_lib.update_mach_lua_log("\t\t Finished creating artilleryForcesTable!")

		
	end

	
	
	--adds artillery captured details to battle results panel
	local function showBattleResults()
		mach_lib.update_mach_lua_log("CaptureArtillery.showBattleResults")

		local captured_art_text = nil
		
		local popup_battle_results = UIComponent( WALI_m_root:Find( "popup_battle_results" ) )
		local resultsOfBattle = popup_battle_results:LuaCall("ReturnBattleResults")

		if(resultsOfBattle.sea_battle == false) then
			
			local captured_column_header = UIComponent( popup_battle_results:Find( "TX_Captured" ) )
			captured_column_header:SetStateText("Artillery Captured")
			captured_column_header:Resize(120, captured_column_header:Height())
			captured_column_header:SetVisible(true)
				

			for i = 1, #resultsOfBattle.alliances do
				captured_art_text = UIComponent( popup_battle_results:Find( "dy_team"..i.."_captured") )
					
				if (i == resultsOfBattle.players_alliance_index) then
					if (resultsOfBattle.is_winner == true) then

						captured_art_text:SetStateText(totalGunsTaken) 
						if (sold_art==true) and (totalGunsTaken > 0) then
							captured_art_text:SetTooltipText(this_battle_art_num_sold.." of these artillery pieces were sold for a value of "..this_battle_adjustTreasuryValue ..". "..this_battle_researchPoints.." military research points were distributed among the gentlemen of your faction.")
						elseif (sold_art==false) and (totalGunsTaken > 0) then
							captured_art_text:SetTooltipText(totalGunsTaken.." of these artillery pieces were dispered among your artillery forces.")
						end
					else
						captured_art_text:SetStateText(0) 
					end
				else
					if (resultsOfBattle.is_winner == false) then

						captured_art_text:SetStateText(totalGunsTaken) 
						if (sold_art==true) and (totalGunsTaken > 0) then
							captured_art_text:SetTooltipText(this_battle_art_num_sold.." of these artillery pieces were sold for a value of "..this_battle_adjustTreasuryValue ..". "..this_battle_researchPoints.." military research points were distributed among the gentlemen of your faction.")
						elseif (sold_art==false) and (totalGunsTaken > 0) then
							captured_art_text:SetTooltipText(totalGunsTaken.." of these artillery pieces were dispered among your artillery forces.")
						end
					else
						captured_art_text:SetStateText(0) 
					end

				end
				captured_art_text:SetVisible(true)
			end


		end



	end
	
	
	
	--set all artillery units to have 1000 guns in order for the unit size to affect the deployed artillery gun number
	local function setAllArtyToOneThousand()
		mach_lib.update_mach_lua_log("CaptureArtillery.setAllArtyToOneThousand")

		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k2, v2 in pairs(faction_list) do		
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(v2.Key, true)
			for i = 1, #forcesList do
				local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
				for k,v in pairs(entities.Units) do
					if v.IsArtillery then
						local alphaPointer = WALI.GetAlphaPointer(v.Address, optionalHeader)					
						WALI.SetArtillery(alphaPointer, 1000)
					end
				end
			end
		end
	end

	
	local function setNewArtyToOneThousand()
		mach_lib.update_mach_lua_log("CaptureArtillery.setNewArtyToOneThousand")
				
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		local found = false

		for k2, v2 in pairs(faction_list) do
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(v2.Key, true)
			for i = 1, #forcesList do
				local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
				for k,v in pairs(entities.Units) do
					if v.IsArtillery then
						for j = 1, #artilleryForcesTable do	
							if tostring(artilleryForcesTable[j][11]) == tostring(v.Address) then
								found = true
							end
						end
						
						if (found == false) then
							local alphaPointer = WALI.GetAlphaPointer(v.Address, optionalHeader)					
							WALI.SetArtillery(alphaPointer, 1000)
						end
						
					end	
				end
			end
		end
	end
		

	
	--units completed battle event to find when a battle ends
	events.UnitCompletedBattle[#events.UnitCompletedBattle+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.UnitCompletedBattle")

		--mach_lib.update_mach_lua_log(tostring(CampaignUI.UnitScaleFactor()))
		--mach_lib.update_mach_lua_log("BEGIN: "..tostring(winnerUnitSeen).."-"..tostring(loserUnitSeen).."-"..tostring(battleBelligerentsProcessed))
		--mach_lib.update_mach_lua_log("completed bat-"..tostring(winnerUnitSeen).."-"..tostring(loserUnitSeen).."-"..tostring(prevBattleTime).."-"..tostring(battleBelligerentsProcessed))
		
		if conditions.UnitWonBattle(context) and winnerUnitSeen == true and (os.date("%M") - prevBattleTime > 1) then
			battleBelligerentsProcessed = true
			winner_factionKey = nil
			loser_factionKey = nil		
		end
		
		if battleBelligerentsProcessed == true then
			if conditions.UnitWonBattle(context) then
				battleBelligerentsProcessed = false
				winner_factionKey = nil
				loser_factionKey = nil	
				totalGunsTaken = 0	
				this_battle_adjustTreasuryValue = 0 
				this_battle_art_num_sold = 0
				this_battle_researchPoints = 0
			end
		end
		
		if (winnerUnitSeen == false or loserUnitSeen == false) and battleBelligerentsProcessed == false then
	
	
			if winnerUnitSeen == false and loserUnitSeen == false then
				mach_lib.update_mach_lua_log("\t\t TEST 1")
				findArtyUnitsWithLosses()
				create_artilleryForcesTable()


			end
			
			if conditions.UnitWonBattle(context) then						
				winnerUnitSeen = true
				prevBattleTime = os.date("%M")
				
			elseif not conditions.UnitWonBattle(context) then	
				loserUnitSeen = true
				
			end
			
			if winnerUnitSeen == true and loserUnitSeen == true then
				battleBelligerentsProcessed = true
				winnerUnitSeen = false
				loserUnitSeen = false
				--mach_lib.update_mach_lua_log("Loser and Victor seen.")
			end

		end

		--mach_lib.update_mach_lua_log("END: "..tostring(winnerUnitSeen).."-"..tostring(loserUnitSeen).."-"..tostring(battleBelligerentsProcessed))
	end

	
	--character completed battle event to determine winner and sometimes loser faction
	events.CharacterCompletedBattle[#events.CharacterCompletedBattle+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.CharacterCompletedBattle")

		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		
		for k, v in pairs(faction_list) do

			if conditions.CharacterFactionName(v.Key, context) then
				--mach_lib.update_mach_lua_log("Character completed battle and belongs to faction: "..tostring(v.Key))
				
				if conditions.CharacterWonBattle(context) then
					winner_factionKey = v.Key
					mach_lib.update_mach_lua_log("\t\t Winner Faction Key: "..winner_factionKey)
					if winnerUnitSeen == true then
						winnerUnitSeen = false
					end
				else
					loser_factionKey = v.Key
					mach_lib.update_mach_lua_log("\t\t Loser Faction Key: "..loser_factionKey)

					--mach_lib.update_mach_lua_log("Loser faction: "..tostring(v.Key)) 
				end
				
				if conditions.CharacterWasAttacker(context) then
					--mach_lib.update_mach_lua_log("Character attacker faction name: "..tostring(v.Key)) 
					attacker_factionKey = v.Key
					mach_lib.update_mach_lua_log("\t\t Attacker faction key: "..attacker_factionKey)

					attacker_character_context = context
				else 
					--mach_lib.update_mach_lua_log("Character defender faction name: "..tostring(v.Key)) 
					defender_factionKey = v.Key
					mach_lib.update_mach_lua_log("\t\t Defender faction key: "..defender_factionKey)
					defender_character_context = context
				end
				
				
			end
		end
		
	

	end

	
	--event to catch time triggers
	--time trigger to update artillery captured results when unit battle details panel is opened
	events.TimeTrigger[#events.TimeTrigger+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.TimeTrigger")

		if context.string == "unit_list_panel_closed" then
			local popup_battle_results = UIComponent( WALI_m_root:Find( "popup_battle_results" ) )
			local battle_results = UIComponent(popup_battle_results:Find("battle_results"))
		
			if(battle_results:Visible()) then
				showBattleResults()
			else
				scripting.game_interface:add_time_trigger("unit_list_panel_closed", 0.01)
			end
		end
	end
	
	
	--left mouse click event to trigger time trigger for battle results panel
	events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.ComponentLClickUp")

		if(popup_battle_results_open == true) then
			local popup_battle_results = UIComponent( WALI_m_root:Find( "popup_battle_results" ) )
			local battle_results = UIComponent(popup_battle_results:Find("battle_results"))
			
			if(battle_results:Visible()) and (unit_list_visible == true ) then
				unit_list_visible = false
			end
			
			local remaining_header	= UIComponent( popup_battle_results:Find( "remaining_tx" ) )
			
			if(remaining_header:Visible()) and (unit_list_visible == false) then
				unit_list_visible = true
				scripting.game_interface:add_time_trigger("unit_list_panel_closed", 0.1)
			end
		end
	
	end
	
	
	--panel closed campaign event to determine when battle results panel is closed
	events.PanelClosedCampaign[#events.PanelClosedCampaign+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.PanelClosedCampaign")

		if conditions.IsComponentType("popup_battle_results", context) then
			popup_battle_results_open = false
			totalGunsTaken = 0	

		end

	end


	--panel opened campaign event to determine when battle results panel is opened
	events.PanelOpenedCampaign[#events.PanelOpenedCampaign+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.PanelOpenedCampaign")

		if conditions.IsComponentType("popup_battle_results", context) then	
			popup_battle_results_open = true		
			showBattleResults()	



		end
		

		--something about artillery in the unit info popup
		if conditions.IsComponentType("UnitInfoPopup", context) then
			--mach_lib.update_mach_lua_log("here")

			local g_stats_artillery	= UIComponent( WALI_m_root:Find( "stats_artillery" ) )
			local g_stats_artillery_guns_value	= UIComponent( UIComponent( g_stats_artillery:Find( "guns" ) ):Find( "dy_value" ) )
				
			local g_stats_men = UIComponent(WALI_m_root:Find( "dy_men" ) )
			local artilleryToShow = mach_lib.get_artillery_num_from_men_count(g_stats_men:GetStateText())
			g_stats_artillery_guns_value:SetStateText( tostring(artilleryToShow) )	
		end		


	end
	
	
	--unit created event to trigger setAllArtyToOneThousand function to adjust new artillery unit gun number
	events.UnitCreated[#events.UnitCreated+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.UnitCreated")

		if conditions.UnitCategory("artillery", context) then
			setNewArtyToOneThousand()
			--setAllArtyToOneThousand()
		end
	end
	
	
	--character turn end event to increase research points for gentlemen for artillery captured
	events.CharacterTurnEnd[#events.CharacterTurnEnd+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.CharacterTurnEnd")

		mach_lib.update_mach_lua_log(winner_factionKey.."-"..research_increase)
		if conditions.CharacterFactionName(winner_factionKey, context) and conditions.CharacterType("gentleman", context) and (research_increase == true) then

			local agentlist = CampaignUI.RetrieveFactionAgentsList(winner_factionKey)
			for k, v in pairs(agentlist) do
				local gentlemanCount = 0
				if(v.AgentType=="Gentleman") then
					gentlemanCount =  gentlemanCount + 1				
				end
			end
			
			local points_per_gentleman = 0
			if(gentlemanCount < researchPoints) then
				points_per_gentleman = researchPoints / gentlemanCount 
				points_per_gentleman = points_per_gentleman + (researchPoints % gentlemanCount)
				effect.trait("C_Gent_Research_Military", "agent", points_per_gentleman, 100, context)
			else
				points_per_gentleman = researchPoints % gentlemanCount
				effect.trait("C_Gent_Research_Military", "agent", points_per_gentleman, 100, context)
			end
			
			researchPoints = researchPoints - points_per_gentleman



			--effect.trait("C_Gent_Research_Military", "agent", researchPoints, 100, context)
		end
	end
	
	
	--faction turn end event to increase treasury for sold artillery pieces
	events.FactionTurnEnd[#events.FactionTurnEnd+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.FactionTurnEnd")

		mach_lib.update_mach_lua_log(winner_factionKey.." "..sold_art)
		if conditions.FactionName(winner_factionKey, context) and (sold_art == true) then
			effect.adjust_treasury(adjustTreasuryValue, context)
		end
	end
	

	--UI created event to create artilleryForcesTable table and call setAllArtyToOneThousand function
	events.UICreated[#events.UICreated+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.UICreated")

		if context.string == "Campaign UI" then
			setAllArtyToOneThousand()
			create_artilleryForcesTable()	
			
		end
	
	
	end


	--faction turn start event to refresh artilleryForcesTable table
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.FactionTurnStart")

		create_artilleryForcesTable()
		adjustTreasuryValue = 0
		sold_art = false
		art_num_sold = 0
		research_increase = false
		researchPoints = 0
		if winnerUnitSeen == true then
			winnerUnitSeen = false
		end
	end

	
	--settlement attacked event to also refresh artilleryForcesTable
	events.CampaignSettlementAttacked[#events.CampaignSettlementAttacked+1] = function(context)
		mach_lib.update_mach_lua_log("CaptureArtillery.events.CampaignSettlementAttacked")

		create_artilleryForcesTable()
	end
	

	

	

end




