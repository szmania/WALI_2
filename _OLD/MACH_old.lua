
module(..., package.seeall)


WALI = require "WALI/WALI"
library = require "WALI/TI_lib"
local scripting = require "EpisodicScripting"

local WALI_m_root = nil --the UI root
local WALI_isOnCampMap = false
local current_faction_key_name = nil

local CharacterNames = {}
local RegionNames = {}
local SettlementNames = {}
local besieged_region_table = {}

--build character names localisationlist
function BuildCharNamesList()
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/CharacterNames.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		CharacterNames[count] = line:split("\"")
		count = count + 1
	end
	file:close()
end


--build region names localisation list
function BuildRegionNamesList()
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/RegionNames.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		RegionNames[count] = line:split("\"")
		count = count + 1
	end
	file:close()
end


--build settlement names localisation list
function BuildSettlementNamesList()
	local count = 1
	local line = 0
	local file = io.open("data/WALI/Misc/SettlementNames.txt", "r")	
	while true do	
		line = file:read("*line")
		if line == nil then 
			break 
		end
		SettlementNames[count] = line:split("\"")
		--WALI.UpdateWALILuaLog(SettlementNames[count][2])
		count = count + 1
	end
	file:close()
end


--determine if an army is besieging a settlement
function determineBesiegedSettlements()

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
					distance = find_distance(army.PosX, army.PosY, region_capital_coord_list[region_key][1], region_capital_coord_list[region_key][2])		
				
					if (distance < 1.5) and (distance > -1.5) and (distance ~= nil) then

						army_besiege_settlement = true
						besieged_region_table[#besieged_region_table + 1] = region_key

					end

				end

			end
		end		
	end

end



--initialize UIComponent and determine if WALI is on Campaign map
events.UICreated[#events.UICreated+1] = function(context)

	if context.string == "Campaign UI" then
		WALI_isOnCampMap = true
		WALI_m_root = UIComponent(context.component)
	end	

	current_faction_key_name = CampaignUI.PlayerFactionId()
end

events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
	--WALI.UpdateWALILuaLog(context.string)
	--create_armyInfoTableForTurn()
	local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
	for k, v in pairs(faction_list) do
		if conditions.FactionName(v.Key, context) then
			current_faction_key_name = v.Key
		end
	end
	
end


--CaptureArtillery


local victor_Faction_Key = nil
local loser_Faction_Key = nil
local attacker_Surname = nil
local defender_Surname = nil
local attacker_character_context = nil
local defender_character_context = nil
local attacker_Region = nil
local defender_Region = nil
local prevUnitCompletedBattle_context = nil
local battleBelligerentsDone = false
local victorSeen = false
local loserSeen = false
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
function CaptureArtillery()

	local attacker_Faction_Key = nil
	local defender_Faction_Key = nil


	--sell artillery that is not matched in victor's army
	local function sell_artillery(recruitCost, menLost, defaultUnitSize, faction)
		local percentLost = menLost / defaultUnitSize 
		
		if (percentLost > 1) then
			percentLost = 1
		end
		
		local money = recruitCost * percentLost
		adjustTreasuryValue = math.floor(adjustTreasuryValue + money)
		this_battle_adjustTreasuryValue = math.floor(adjustTreasuryValue + money)
		sold_art = true
		art_num_sold = determineArtNum(menLost)
		this_battle_art_num_sold = determineArtNum(menLost)
		
	end
	
	--increase military reasearch for gentlmen for every 4 guns caught that were not matched by victor army
	local function research_artillery(numOfGuns, faction)
		local points = math.floor(numOfGuns / 5)
		researchPoints = researchPoints + points
		this_battle_researchPoints = this_battle_researchPoints + points
		research_increase = true
	end

	--popup dialogue telling the number of artillery caught
	--not used as the number is now posted in battle results panel
	local function capture_art_notice(gunsTaken)
		local utils = require("Utilities")
		local panel_manager = utils.Require("panelmanager")
		panel_manager.OpenPanel("dialogue_box", true, "Initialise", "You have captured enemy artillery.\n"..gunsTaken.." artillery pieces.")
	end

	
	--determines if passed in faction_key key is loser faction_key of fought battle
	local function is_loser_faction(faction_key)
	
		if tostring(loser_Faction_Key) == tostring(faction_key) then
			return true
		end
		local diplomacy = CampaignUI.RetrieveDiplomacyDetails(faction_key)
		for kk, vv in pairs(diplomacy.AtWar) do
			if tostring(kk) == tostring(victor_Faction_Key) then
				return true
			end
		end
		
		return false
	end
	
	
	--adjustments are made here between artillery units and their guns
	local function artillery_adjustment( defeatedUnit_key, defeatedUnit_location, defeatedUnit_PosX, defeatedUnit_PosY, defeatedUnit_Guns, defeatedUnit_Address, defeatedUnit_Nation, defeatedUnit_numGunsLost, defeatedUnit_RecruitCost, defeatedUnit_MenLost, defeatedUnit_defaultUnitSize)
		
		totalGunsTaken = totalGunsTaken + defeatedUnit_numGunsLost
		
		WALI.UpdateWALILuaLog("Number of guns to adjust for: "..defeatedUnit_numGunsLost)
		--WALI.UpdateWALILuaLog("VARIABLES PASSED IN: "..tostring(defeatedUnit_key).." - "..tostring(defeatedUnit_location).."-"..tostring(defeatedUnit_PosX).." - "..tostring(defeatedUnit_PosY).." - "..tostring(defeatedUnit_Guns).." - "..tostring(defeatedUnit_numGunsLost))


		local found = false
		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(victor_Faction_Key, true)
		local matchTable= {}
		local a = 1
		local foundNum = 0
		
		for n = 1, #forcesList do
			local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[n].Address, forcesList[n].Address)
			for k,v in pairs(entities.Units) do

				if v.IsArtillery then	
				
					local distance = find_distance(defeatedUnit_PosX, defeatedUnit_PosY, forcesList[n].PosX, forcesList[n].PosY)
					--WALI.UpdateWALILuaLog("region_capital_distance "..region_capital_distance.."-"..victor_Faction_Key.."-"..defeatedUnit_Nation)
					
					if ((artilleryToGunType[v.UnitRecord.Key] == artilleryToGunType[defeatedUnit_key]) or (v.UnitRecord.Key == defeatedUnit_key)) and (distance < 4) then
						--WALI.UpdateWALILuaLog("Found similar unit NEAR unit "..tostring(defeatedUnit_key).." - "..tostring(defeatedUnit_location).." - "..defeatedUnit_PosX.." - "..defeatedUnit_PosY)
						--WALI.UpdateWALILuaLog("MATCH: " .. tostring(v.Address).." - "..v.UnitRecord.Key.." - "..forcesList[n].Location.." - "..forcesList[n].PosX.." - "..forcesList[n].PosY)
						


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
			if ((defeatedUnit_numGunsLost / 5) >= 1) then
				research_artillery(defeatedUnit_numGunsLost, victor_Faction_Key)
			end	
			
			sell_artillery(defeatedUnit_RecruitCost, defeatedUnit_MenLost, defeatedUnit_defaultUnitSize, victor_Faction_Key)
		end
		
		if(foundNum > 0) then
		

			
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

				local numGunsTotal = determineArtNum(matchTable[index][2]) + 1
				local unitReplenishTotal = (numGunsTotal * 5) - 1
				matchTable[index][2] = unitReplenishTotal	
				
				--WALI.UpdateWALILuaLog(numGunsTotal.." - "..matchTable[index][1])
				WALI.SetUnitReplenishable(matchTable[index][1], unitReplenishTotal, optionalHeader)
				WALI.SetMaximumUnitSize(matchTable[index][1], unitReplenishTotal, optionalHeader)
				--WALI.UpdateWALILuaLog("HEY "..(matchTable[index][3].Men).." - "..unitReplenishTotal)
							
				WALI.UpdateWALILuaLog("Men to replenish to: "..unitReplenishTotal..". Number of enemy guns taken: "..defeatedUnit_numGunsLost)
				index = index + 1	
				m = m + 1
			end
		
		end		

	end

	

	--compare artilleryForcesTable table with the artillery units on the map
	local function compare_artilleryForcesTable()
		--WALI.UpdateWALILuaLog("Comparing artilleryForcesTable")
				

		for j = 1, #artilleryForcesTable do	

			--WALI.UpdateWALILuaLog("HJERE:"..tostring(artilleryForcesTable[besieged_settlements_idx][1]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][2]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][3]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][4]))
			local found = false
			local lossGuns = false
			local numGunsLost = 0
			local numMenLost = 0
			local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
			
			--WALI.UpdateWALILuaLog("HERE "..tostring(artilleryForcesTable[besieged_settlements_idx][11]).."-"..tostring(artilleryForcesTable[besieged_settlements_idx][1]).."-"..tostring(artilleryForcesTable[besieged_settlements_idx][2]).."-"..tostring(artilleryForcesTable[besieged_settlements_idx][4]).."-"..tostring(artilleryForcesTable[besieged_settlements_idx][8]))
			
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
								
									if tonumber(determineArtNum(artilleryForcesTable[j][6])) > determineArtNum(v.Men) then
										numGunsLost = tonumber(determineArtNum(artilleryForcesTable[j][6])) - determineArtNum(v.Men)
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

			--WALI.UpdateWALILuaLog("HJERE:"..tostring(artilleryForcesTable[besieged_settlements_idx][1]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][2]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][3]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][4]))

			--WALI.UpdateWALILuaLog("HERE "..tostring(found).." - "..tostring(lossGuns).."-"..table.getn(artilleryForcesTable))

			if (found==false)  then

				numGunsLost = determineArtNum(artilleryForcesTable[j][6])
				numMenLost = artilleryForcesTable[j][6]

				
					--WALI.UpdateWALILuaLog("NOT FOUND: "..tostring(artilleryForcesTable[besieged_settlements_idx][1]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][2]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][3]).." - "..tostring(artilleryForcesTable[besieged_settlements_idx][4]))

					
					--WALI.UpdateWALILuaLog("WINNER: "..tostring(victor_Faction_Key))
					--WALI.UpdateWALILuaLog("LOSER: "..tostring(loser_Faction_Key))
				
					
					if tostring(victor_Faction_Key) == tostring(artilleryForcesTable[j][1]) then
						--WALI.UpdateWALILuaLog("Unit is part of victor faction_key: "..tostring(artilleryForcesTable[besieged_settlements_idx][1]))
					elseif (is_loser_faction(tostring(artilleryForcesTable[j][1]))) then
						WALI.UpdateWALILuaLog("Artillery unit is part of loser faction_key and doesn't exist any more: "..tostring(artilleryForcesTable[j][1]))
						
						--WALI.UpdateWALILuaLog("ARGUMENTS PASSED IN: "..artilleryForcesTable[besieged_settlements_idx][2]..artilleryForcesTable[besieged_settlements_idx][4])

						artillery_adjustment( artilleryForcesTable[j][2], artilleryForcesTable[j][4],artilleryForcesTable[j][9], artilleryForcesTable[j][10], artilleryForcesTable[j][7], artilleryForcesTable[j][11], artilleryForcesTable[j][1], numGunsLost, artilleryForcesTable[j][12], numMenLost, artilleryForcesTable[j][13])			


					end
					

					
				--end

	
			elseif (found == true) and (artilleryForcesTable[j][8] == true) then
				
				if (is_loser_faction(tostring(artilleryForcesTable[j][1]))) then
					numGunsLost = tonumber(determineArtNum(artilleryForcesTable[j][6]))
					numMenLost = artilleryForcesTable[j][6]
					WALI.UpdateWALILuaLog("Loser is fixed artillery. Therefore it lost all guns: "..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]).." - "..tostring(artilleryForcesTable[j][5]).." - "..tostring(artilleryForcesTable[j][6]))
					artillery_adjustment( artilleryForcesTable[j][2], artilleryForcesTable[j][4],artilleryForcesTable[j][9], artilleryForcesTable[j][10], artilleryForcesTable[j][7], artilleryForcesTable[j][11], artilleryForcesTable[j][1], numGunsLost, artilleryForcesTable[j][12], numMenLost, artilleryForcesTable[j][13])			

				end

	
			elseif (found == true) and (lossGuns == true) then						
				--WALI.UpdateWALILuaLog("WINNER: "..tostring(victor_Faction_Key))
				--WALI.UpdateWALILuaLog("LOSER: "..tostring(loser_Faction_Key))

				if tostring(victor_Faction_Key) == tostring(artilleryForcesTable[j][1]) then
					--WALI.UpdateWALILuaLog("Unit is part of victor faction_key: "..tostring(artilleryForcesTable[besieged_settlements_idx][1]))
				elseif (is_loser_faction(tostring(artilleryForcesTable[j][1]))) then
					WALI.UpdateWALILuaLog("LOSER LOST GUNS but still exists: "..tostring(artilleryForcesTable[j][1]).." - "..tostring(artilleryForcesTable[j][2]).." - "..tostring(artilleryForcesTable[j][3]).." - "..tostring(artilleryForcesTable[j][4]).." - "..tostring(artilleryForcesTable[j][5]).." - "..tostring(artilleryForcesTable[j][6]))
					artillery_adjustment( artilleryForcesTable[j][2], artilleryForcesTable[j][4],artilleryForcesTable[j][9], artilleryForcesTable[j][10], artilleryForcesTable[j][7], artilleryForcesTable[j][11], artilleryForcesTable[j][1], numGunsLost, artilleryForcesTable[j][12], numMenLost, artilleryForcesTable[j][13])			

					--WALI.UpdateWALILuaLog("Unit is part of loser faction_key AND LOST GUNS: "..tostring(artilleryForcesTable[besieged_settlements_idx][1]))
				end				
			end
		end
		

	end

	
	--create artilleryForcesTable table, which has all artillery units on map in it
	local function create_artilleryForcesTable()

		--WALI.UpdateWALILuaLog("Creating artilleryForcesTable")
		artilleryForcesTable = {}

		local a = 1
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k2, v2 in pairs(faction_list) do		
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(v2.Key, true)
			for i = 1, #forcesList do
				local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
				for k,v in pairs(entities.Units) do
					if v.IsArtillery then
						artilleryForcesTable[a] = {}
						artilleryForcesTable[a][1] = tostring(v2.Key) -- faction_key key
						artilleryForcesTable[a][2] = tostring(v.UnitRecord.Key) -- unit key
						artilleryForcesTable[a][3] = tostring(v.CommandersName) -- commanders name
						artilleryForcesTable[a][4] = tostring(forcesList[i].Location) -- location
						artilleryForcesTable[a][5] = tostring(WALI.GetUnitReplenishable(v.Address, optionalHeader)) -- replenishment size
						artilleryForcesTable[a][6] = tostring(v.Men) -- unit size
						artilleryForcesTable[a][7] = tostring(v.UnitRecord.Guns) -- number of artillery
						artilleryForcesTable[a][8] = tostring(v.IsFixedArtillery) -- is fixed artillery
						artilleryForcesTable[a][9] = tostring(forcesList[i].PosX) -- Position X
						artilleryForcesTable[a][10] = tostring(forcesList[i].PosY) -- Position Y
						artilleryForcesTable[a][11] = tostring(v.Address) -- Unit address
						artilleryForcesTable[a][12] = tostring(v.RecruitCost) -- Unit recruitment cost
						artilleryForcesTable[a][13] = tostring(v.UnitRecord.Men) -- Unit default unit size
						--WALI.UpdateWALILuaLog("HERE - "..tostring(artilleryForcesTable[a][1]))
						a = a + 1
					end
				end
			end
		end
		
		
	end

	
	
	--adds artillery captured details to battle results panel
	local function ShowBattleResults()
		local captured_art_text = nil
		
		local popup_battle_results = UIComponent( WALI_m_root:Find( "popup_battle_results" ) )
		local resultsOfBattle = popup_battle_results:LuaCall("ReturnBattleResults")

		if(resultsOfBattle.sea_battle == false) then
			
			local captured_column_header = UIComponent( popup_battle_results:Find( "TX_Captured" ) )
			captured_column_header:SetStateText("Artillery Captured")
			captured_column_header:Resize(120, captured_column_header:Height())
			captured_column_header:SetVisible(true)
				

			for i = 1, #resultsOfBattle.alliances do
				captured_art_text	=  UIComponent( popup_battle_results:Find( "dy_team"..i.."_captured") )
					
				if (i == resultsOfBattle.players_alliance_index) then
					if (resultsOfBattle.is_winner == true) then

						captured_art_text:SetStateText(totalGunsTaken) 
						if (sold_art==true) and (totalGunsTaken > 0) then
							captured_art_text:SetTooltipText(this_battle_art_num_sold.." of these artillery pieces were sold for a value of "..this_battle_adjustTreasuryValue ..". "..this_battle_researchPoints.." military research points were distributed among the gentlemen of your faction_key.")
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
							captured_art_text:SetTooltipText(this_battle_art_num_sold.." of these artillery pieces were sold for a value of "..this_battle_adjustTreasuryValue ..". "..this_battle_researchPoints.." military research points were distributed among the gentlemen of your faction_key.")
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
	local function ArtilleryThousand()
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

	

	
	--units completed battle event to find when a battle ends
	events.UnitCompletedBattle[#events.UnitCompletedBattle+1] = function(context)
		--WALI.UpdateWALILuaLog(tostring(CampaignUI.UnitScaleFactor()))
		--WALI.UpdateWALILuaLog("BEGIN: "..tostring(victorSeen).."-"..tostring(loserSeen).."-"..tostring(battleBelligerentsDone))
		--WALI.UpdateWALILuaLog("completed bat-"..tostring(victorSeen).."-"..tostring(loserSeen).."-"..tostring(prevBattleTime).."-"..tostring(battleBelligerentsDone))
		
		if conditions.UnitWonBattle(context) and victorSeen == true and (os.date("%M") - prevBattleTime > 1) then
			battleBelligerentsDone = true
			winner_Faction_Key = nil
			loser_Faction_Key = nil		
		end
		
		if battleBelligerentsDone == true then
			if conditions.UnitWonBattle(context) then
				battleBelligerentsDone = false
				winner_Faction_Key = nil
				loser_Faction_Key = nil	
				totalGunsTaken = 0	
				this_battle_adjustTreasuryValue = 0 
				this_battle_art_num_sold = 0
				this_battle_researchPoints = 0
			end
		end
		
		if (victorSeen == false or loserSeen == false) and battleBelligerentsDone == false then
	
	
			if victorSeen == false and loserSeen == false then
				WALI.UpdateWALILuaLog("BATTLE ENDED")
				compare_artilleryForcesTable()
				create_artilleryForcesTable()
			end
			
			if conditions.UnitWonBattle(context) then						
				victorSeen = true
				prevBattleTime = os.date("%M")
				
			elseif not conditions.UnitWonBattle(context) then	
				loserSeen = true
				
			end
			
			if victorSeen == true and loserSeen == true then
				battleBelligerentsDone = true
				victorSeen = false
				loserSeen = false
				--WALI.UpdateWALILuaLog("Loser and Victor seen.")
			end

		end

		--WALI.UpdateWALILuaLog("END: "..tostring(victorSeen).."-"..tostring(loserSeen).."-"..tostring(battleBelligerentsDone))
	end

	
	--character completed battle event to determine victor and sometimes loser faction_key
	events.CharacterCompletedBattle[#events.CharacterCompletedBattle+1] = function(context)
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k, v in pairs(faction_list) do

			if conditions.CharacterFactionName(v.Key, context) then
				--WALI.UpdateWALILuaLog("Character completed battle and belongs to faction_key: "..tostring(v.Key))
				
				if conditions.CharacterWonBattle(context) then
					victor_Faction_Key = v.Key
					if victorSeen == true then
						victorSeen = false
					end
					--WALI.UpdateWALILuaLog("Victor faction_key: "..tostring(v.Key))
				else
					loser_Faction_Key = v.Key
					--WALI.UpdateWALILuaLog("Loser faction_key: "..tostring(v.Key))
				end
				
				if conditions.CharacterWasAttacker(context) then
					--WALI.UpdateWALILuaLog("Character attacker faction_key name: "..tostring(v.Key))
					attacker_Faction_Key = v.Key
					attacker_character_context = context
				else 
					--WALI.UpdateWALILuaLog("Character defender faction_key name: "..tostring(v.Key))
					defender_Faction_Key = v.Key
					defender_character_context = context
				end
				
				
			end
		end
		
		--loop to spit out attacker and defender region
		for key2, value2 in pairs(regionsTable) do
			--WALI.UpdateWALILuaLog("region: "..tostring(value2))			
			if conditions.CharacterInRegion(value2, context)  then
				--WALI.UpdateWALILuaLog("character in region name: "..tostring(value2)) 
				if conditions.CharacterWasAttacker(context) then
					attacker_Region = value2
					WALI.UpdateWALILuaLog("attacker region: "..tostring(value2)) 
				elseif not conditions.CharacterWasAttacker(context) then
					defender_Region = value2
					WALI.UpdateWALILuaLog("defender region: "..tostring(value2)) 
				end
			end					
		end		

	end

	
	--event to catch time triggers
	--time trigger to update artillery captured results when unit battle details panel is opened
	events.TimeTrigger[#events.TimeTrigger+1] = function(context)

		if context.string == "unit_list_panel_closed" then
			local popup_battle_results = UIComponent( WALI_m_root:Find( "popup_battle_results" ) )
			local battle_results = UIComponent(popup_battle_results:Find("battle_results"))
		
			if(battle_results:Visible()) then
				ShowBattleResults()
			else
				scripting.game_interface:add_time_trigger("unit_list_panel_closed", 0.01)
			end
		end
	end
	
	
	--left mouse click event to trigger time trigger for battle results panel
	events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)
	
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

		if conditions.IsComponentType("popup_battle_results", context) then
			popup_battle_results_open = false
			totalGunsTaken = 0	

		end

	end




	--panel opened campaign event to determine when battle results panel is opened
	events.PanelOpenedCampaign[#events.PanelOpenedCampaign+1] = function(context)
	
		if conditions.IsComponentType("popup_battle_results", context) then	
			popup_battle_results_open = true		
			ShowBattleResults()	



		end
		

		--something about artillery in the unit info popup
		if conditions.IsComponentType("UnitInfoPopup", context) then
			--WALI.UpdateWALILuaLog("here")

			local g_stats_artillery	= UIComponent( WALI_m_root:Find( "stats_artillery" ) )
			local g_stats_artillery_guns_value	= UIComponent( UIComponent( g_stats_artillery:Find( "guns" ) ):Find( "dy_value" ) )
				
			local g_stats_men = UIComponent(WALI_m_root:Find( "dy_men" ) )
			local artilleryToShow = determineArtNum(g_stats_men:GetStateText())
			g_stats_artillery_guns_value:SetStateText( tostring(artilleryToShow) )	
		end		


	end
	
	
	
	
	--unit created event to trigger ArtilleryThousand function to adjust new artillery unit gun number
	events.UnitCreated[#events.UnitCreated+1] = function(context)	
		if conditions.UnitCategory("artillery", context) then
			ArtilleryThousand()
		end
	end
	
	--character turn end event to increase research points for gentlemen for artillery captured
	events.CharacterTurnEnd[#events.CharacterTurnEnd+1] = function(context)
		WALI.UpdateWALILuaLog(victor_Faction_Key.."-"..research_increase)
		if conditions.CharacterFactionName(victor_Faction_Key, context) and conditions.CharacterType("gentleman", context) and (research_increase == true) then

			local agentlist = CampaignUI.RetrieveFactionAgentsList(victor_Faction_Key)
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
	
	--faction_key turn end event to increase treasury for sold artillery pieces
	events.FactionTurnEnd[#events.FactionTurnEnd+1] = function(context)
		WALI.UpdateWALILuaLog(victor_Faction_Key.." "..sold_art)
		if conditions.FactionName(victor_Faction_Key, context) and (sold_art == true) then
			effect.adjust_treasury(adjustTreasuryValue, context)
		end
	end
	

	--UI created event to create artilleryForcesTable table and call ArtilleryThousand function
	events.UICreated[#events.UICreated+1] = function(context)
	
		if context.string == "Campaign UI" then
			ArtilleryThousand()
			create_artilleryForcesTable()	
			
		end
	
	
	end


	--faction_key turn start event to refresh artilleryForcesTable table
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		create_artilleryForcesTable()
		adjustTreasuryValue = 0
		sold_art = false
		art_num_sold = 0
		research_increase = false
		researchPoints = 0
		if victorSeen == true then
			victorSeen = false
		end
	end

	
	--settlement attacked event to also refresh artilleryForcesTable
	events.CampaignSettlementAttacked[#events.CampaignSettlementAttacked+1] = function(context)
		create_artilleryForcesTable()
	end
	

	

	

end




--InterruptableSupplyLines
local distance_from_supply_line = 1.5


function InterruptableSupplyLines()

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
	function naval_army_supplier(context)


		
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

			for k = 1, #regions do

				region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
				distance = find_distance(forcesList[i].PosX, forcesList[i].PosY, region_capital_coord_list[region_key][1], region_capital_coord_list[region_key][2])		
				
				if #besieged_region_table > 0 then
					for j = 1, #besieged_region_table do		
						if besieged_region_table[j] ~= region_key then
							if (distance < nearest) and (distance ~= nil) and not (determineInSettlement(current_faction_turn, forcesList[i])) then

								armyX = forcesList[i].PosX
								armyY = forcesList[i].PosY
								regionX = region_capital_coord_list[region_key][1]
								regionY = region_capital_coord_list[region_key][2]
								nearest = distance
								nearestRegionCapital = region_key
							end
						end
					end
				else
					if (distance < nearest) and (distance ~= nil) and not (determineInSettlement(current_faction_turn, forcesList[i])) then


						armyX = forcesList[i].PosX
						armyY = forcesList[i].PosY
						regionX = region_capital_coord_list[region_key][1]
						regionY = region_capital_coord_list[region_key][2]
						nearest = distance
						nearestRegionCapital = region_key
					end
				end
				

			end
	


			--determine region_capital_distance from naval force
			if (WALI.isCharacterInSafeRegion(forcesList[i].Address) == false) then

				for j = 1, #forcesListNavy do
					distance = find_distance(forcesList[i].PosX, forcesList[i].PosY, forcesListNavy[j].PosX, forcesListNavy[j].PosY)		
					
					if(distance < nearest) and (distance ~= nil) and (distance ~= 0) and not (determineInSettlement(current_faction_turn, forcesList[i])) then
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

				for b = 1, #RegionNames do
					if RegionNames[b][2] == "regions_onscreen_"..nearestRegionCapital then
						region_screen_name = RegionNames[b][4]
					end
				end
		
				if region_screen_name == nil then
					supplier_admiral_name = nearestRegionCapital
					
					for count = 1, #CharacterNames do
					
						y, z = string.find(supplier_admiral_name, CharacterNames[count][4], 1)
						
						if  not (string.find(supplier_admiral_name, CharacterNames[count][4], 1) == nil) and conditions.CharacterForename(CharacterNames[count][2], context) then																					

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
	function effectLongSupplyLines(faction, context)
		local long_supply_name = nil
		local found = false
		if longSupplyTable ~= nil then

			for j = 1, #longSupplyTable do
				if longSupplyTable[j][1] == faction then			
					long_supply_name = nil
					long_supply_name = longSupplyTable[j][2]
					
					if not (long_supply_name == nil) then
						for count = 1, #CharacterNames do
							y, z = string.find(long_supply_name, CharacterNames[count][4], 1)
								
							if  not (string.find(long_supply_name, CharacterNames[count][4], 1) == nil) then														
								if conditions.CharacterForename(CharacterNames[count][2], context) then	
									found = true
									local points = 0
									--WALI.UpdateWALILuaLog(longSupplyTable[besieged_settlements_idx][3])
									if (longSupplyTable[j][3] > 20 and longSupplyTable[j][3] < 25) then
										points = 1
									elseif (longSupplyTable[j][3] > 25 and longSupplyTable[j][3] < 30) then
										points = 2
									elseif (longSupplyTable[j][3] > 30 and longSupplyTable[j][3] < 35) then
										points = 3
									elseif (longSupplyTable[j][3] > 35 and longSupplyTable[j][3] < 40) then
										points = 4
									elseif (longSupplyTable[j][3] > 40) then
										points = 5
									end
									
									
									local good_count = conditions.CharacterTrait("C_General_LongSupply_Good", context)
									local bad_count = conditions.CharacterTrait("C_General_LongSupply_Bad", context)
									local target = (good_count + points) - bad_count	
									local nearestCapital = nil
									
									
									if target < 0 then
										for h = 1, math.abs(target) do
											effect.trait("C_General_LongSupply_Good", "agent", 1, 100, context)
										end
									else
										for h = 1, target do
											effect.trait("C_General_LongSupply_Bad", "agent", 1, 100, context)
										end
									end
									WALI.UpdateWALILuaLog("Added \"C_General_LongSupply_Bad_"..math.abs(bad_count - good_count).."\" trait to "..long_supply_name)

									local found_settlement = false
									local c = WALI_m_root:Find("MACH_LongSupplyPip")

									--WALI.UpdateWALILuaLog(longSupplyTable[besieged_settlements_idx][4].."'s fleet "..bad_count)
									
									for h = 1, #SettlementNames do
										--WALI.UpdateWALILuaLog("hi "..SettlementNames[h][2].." : "..bad_count)
										--WALI.UpdateWALILuaLog(string.find(SettlementNames[h][2], "start_pos_settlements_onscreen_name_"..regionToSettlementList[longSupplyTable[besieged_settlements_idx][4]], 1))
										--WALI.UpdateWALILuaLog(regionToSettlementList["bosnia"])
										--WALI.UpdateWALILuaLog("start_pos_settlements_onscreen_name_"..regionToSettlementList[longSupplyTable[besieged_settlements_idx][4]])
										if not (regionToSettlementList[longSupplyTable[j][4]] == nil) then
											if  not (string.find(SettlementNames[h][2], "start_pos_settlements_onscreen_name_"..regionToSettlementList[longSupplyTable[j][4]], 1) == nil) then
												--WALI.UpdateWALILuaLog(SettlementNames[h][2].." - "..SettlementNames[h][4])
												nearestCapital = SettlementNames[h][4]
												found_settlement = true
												break
											end
										end
									end
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
			for count = 1, #CharacterNames do																				
				if conditions.CharacterForename(CharacterNames[count][2], context) then	
					foreName = CharacterNames[count][4]
				end
			end
			for count = 1, #CharacterNames do																				
				if conditions.CharacterSurname(CharacterNames[count][2], context) then	
					surName = CharacterNames[count][4]
				end
			end
			
			WALI.UpdateWALILuaLog("Removed \"C_General_LongSupply_Bad\" trait from "..foreName.." "..surName)
			local good_count = conditions.CharacterTrait("C_General_LongSupply_Good", context)
			local bad_count = conditions.CharacterTrait("C_General_LongSupply_Bad", context)
			local target = bad_count - good_count									
			for h = 1, target do
				effect.trait("C_General_LongSupply_Good", "agent", 1, 100, context)
			end
		end
	end
	
	
	--determine if army is located in a settlement
	function determineInSettlement(faction, army)

		local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(faction)

		local region_key = nil
		local distance = nil
		local army_in_settlement = false

		for k = 1, #regions do

			region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
			distance = find_distance(army.PosX, army.PosY, region_capital_coord_list[region_key][1], region_capital_coord_list[region_key][2])		

			--WALI.UpdateWALILuaLog(army.PosX.." "..army.PosY.." "..region_capital_coord_list[region_key][1].." "..region_capital_coord_list[region_key][2])

			--WALI.UpdateWALILuaLog(faction_key.." - "..region_key.." region_capital_distance: "..region_capital_distance)
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
	function GetDistanceFromLine(slope, y_intercept, index, faction)
		
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


				if not (((regionForcesTable[index][1] - regionForcesTable[index][3] > -0.001) and (regionForcesTable[index][1] - regionForcesTable[index][3] < 0.001)) and ((regionForcesTable[index][2] - regionForcesTable[index][4] > -0.001) and (regionForcesTable[index][2] - regionForcesTable[index][4] < 0.001))) and not (determineInSettlement(k, forcesList[i])) then

					local inverse_slope = ((regionForcesTable[index][1] - regionForcesTable[index][3]) / (regionForcesTable[index][2] - regionForcesTable[index][4])) * -1
					local enemy_y_intercept = PosY - (PosX * inverse_slope)
					local x_intersection = (y_intercept - enemy_y_intercept) / (inverse_slope - slope)			
					local y_intersection = (x_intersection * slope) + y_intercept
					

					if (((x_intersection <= regionForcesTable[index][1]) and (x_intersection >= regionForcesTable[index][3])) or ((x_intersection <= regionForcesTable[index][3]) and (x_intersection >= regionForcesTable[index][1]))) then

						if (((y_intersection <= regionForcesTable[index][2]) and (y_intersection >= regionForcesTable[index][4])) or ((y_intersection <= regionForcesTable[index][4]) and (y_intersection >= regionForcesTable[index][2]))) then
					
							--adust region_capital_distance from supply line here
							if (find_distance(PosX, PosY, x_intersection, y_intersection) < distance_from_supply_line) then
								
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
									WALI.UpdateWALILuaLog(num..": "..forcesList[i].Name.." is blocking the supply lines of "..regionForcesTable[index][5])
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
											--WALI.UpdateWALILuaLog("eeerereef "..k.."-"..faction_key.." - "..forcesList[i].Name)
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
	function GetLineEquation(index, faction)

		local slope  = (regionForcesTable[index][2] - regionForcesTable[index][4]) / (regionForcesTable[index][1] - regionForcesTable[index][3])
		
		local y_intercept = regionForcesTable[index][2] - (slope * regionForcesTable[index][1])
		
		--WALI.UpdateWALILuaLog("slope: "..slope.." y intercept: "..y_intercept)
		
		GetDistanceFromLine(slope, y_intercept, index, faction)
	end
	

	--determine closes friendly region capital to pick for line of supply beginning point
	function determineClosestCapital(current_faction_key)



		if character_selected_event ~= true then
			noSupplyForces[current_faction_key] = {}
		end
		totalCount = 0
		totalFound = 0
		
		
		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_key, true)
		local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(current_faction_key)

		
		for i = 1, #forcesList do
			local region_key = nil
			local distance = nil
			local nearestRegionCapital = nil
			local nearest = 99999999
			local regionX = 0
			local regionY = 0
			local armyX = 0
			local armyY = 0

			for k = 1, #regions do

				region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
				distance = find_distance(forcesList[i].PosX, forcesList[i].PosY, region_capital_coord_list[region_key][1], region_capital_coord_list[region_key][2])		
				
				if #besieged_region_table > 0 then
					for j = 1, #besieged_region_table do		
						if besieged_region_table[j] ~= region_key then
							if (distance < nearest) and (distance~=nil) and not (determineInSettlement(current_faction_key, forcesList[i])) then

								armyX = forcesList[i].PosX
								armyY = forcesList[i].PosY
								regionX = region_capital_coord_list[region_key][1]
								regionY = region_capital_coord_list[region_key][2]
								nearest = distance
								nearestRegionCapital = region_key
							end
						end
					end
				else
					if (distance < nearest) and (distance~=nil) and not (determineInSettlement(current_faction_key, forcesList[i])) then

						armyX = forcesList[i].PosX
						armyY = forcesList[i].PosY
						regionX = region_capital_coord_list[region_key][1]
						regionY = region_capital_coord_list[region_key][2]
						nearest = distance
						nearestRegionCapital = region_key
					end
				end
				

			end
			
			--determine region_capital_distance from naval force
			if (WALI.isCharacterInSafeRegion(forcesList[i].Address) == false) then
				local forcesListNavy = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_key, false)

				for j = 1, #forcesListNavy do
					distance = find_distance(forcesList[i].PosX, forcesList[i].PosY, forcesListNavy[j].PosX, forcesListNavy[j].PosY)		
					
					if(distance < nearest) and (distance ~= nil) and (distance ~= 0) and not (determineInSettlement(current_faction_key, forcesList[i])) then
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
				if nearest > 20 and current_faction_key == current_faction_turn and not (determineInSettlement(current_faction_key, forcesList[i])) then
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
						
						--WALI.UpdateWALILuaLog("HI "..current_faction_key.."-"..nearest.."-"..tostring(forcesList[i].Name).."-"..tostring(nearestRegionCapital))
						longSupplyTable[ind] = {}
						longSupplyTable[ind][1] = current_faction_key --faction_key key
						longSupplyTable[ind][2] = tostring(forcesList[i].Name) --commander's name
						longSupplyTable[ind][3] = nearest --region_capital_distance from region capital
						longSupplyTable[ind][4] = tostring(nearestRegionCapital) --region key
					end
				
				else
					for r = 1, #longSupplyTable do
						if longSupplyTable[r][2] == tostring(forcesList[i].Name) then
							longSupplyTable[r] = {}
						end
					end
				end
				
				GetLineEquation(i, current_faction_key)
				
							
				--WALI.UpdateWALILuaLog(forcesList[i].Name.." - "..nearestRegionCapital.." is nearest. At "..nearest)
			end
		end
		
		if current_faction_key ~= current_faction_turn then

			current_faction_key = current_faction_turn
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_key, true)
			local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(current_faction_key)

		
			for i = 1, #forcesList do
				local region_key = nil
				local distance = nil
				local nearestRegionCapital = nil
				local nearest = 99999999
				local regionX = 0
				local regionY = 0
				local armyX = 0
				local armyY = 0

				for k = 1, #regions do
					region_key = CampaignUI.RegionKeyFromAddress(regions[k].Address)
					distance = find_distance(forcesList[i].PosX, forcesList[i].PosY, region_capital_coord_list[region_key][1], region_capital_coord_list[region_key][2])		
					
					if #besieged_region_table > 0 then
						for j = 1, #besieged_region_table do		
							if besieged_region_table[j] ~= region_key then
								if (distance < nearest) and (distance~=nil) and not (determineInSettlement(current_faction_key, forcesList[i])) then
									armyX = forcesList[i].PosX
									armyY = forcesList[i].PosY
									regionX = region_capital_coord_list[region_key][1]
									regionY = region_capital_coord_list[region_key][2]
									nearest = distance
									nearestRegionCapital = region_key

								end
							end
						end
					else
						if (distance < nearest) and (distance~=nil) and not (determineInSettlement(current_faction_key, forcesList[i])) then

							armyX = forcesList[i].PosX
							armyY = forcesList[i].PosY
							regionX = region_capital_coord_list[region_key][1]
							regionY = region_capital_coord_list[region_key][2]
							nearest = distance
							nearestRegionCapital = region_key

						end
					end
					

				end
				--WALI.UpdateWALILuaLog("HI "..current_faction_key.."-"..tostring(nearest).."-"..tostring(forcesList[i].Name).." - "..tostring(nearestRegionCapital))
				
				--determine region_capital_distance from naval force
				if (WALI.isCharacterInSafeRegion(forcesList[i].Address) == false) then
					local forcesListNavy = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_key, false)

					for j = 1, #forcesListNavy do
						distance = find_distance(forcesList[i].PosX, forcesList[i].PosY, forcesListNavy[j].PosX, forcesListNavy[j].PosY)		
						
						if(distance < nearest) and (distance~=nil) and not (determineInSettlement(current_faction_key, forcesList[i])) and (distance ~= 0) then
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
				if nearest > 20 and not (determineInSettlement(current_faction_key, forcesList[i])) then

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
						--WALI.UpdateWALILuaLog("HI "..current_faction_key.."-"..nearest.."-"..tostring(forcesList[i].Name).."-"..tostring(nearestRegionCapital))
						longSupplyTable[ind] = {}
						longSupplyTable[ind][1] = current_faction_key
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
	
		if context.string == "Campaign UI" then
			WALI_m_root = UIComponent(context.component)
			firstCharacter = true
			
			BuildCharNamesList()
			BuildRegionNamesList()
			BuildSettlementNamesList()
			prevEffectTime = 0
			prevCharacterAddress = nil
		end


	end
	
	

	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		firstCharacter = true
		prevEffectTime = 0
		prevCharacterAddress = nil

	end
	


	events.CharacterTurnEnd[#events.CharacterTurnEnd+1] = function(context)

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
			
			determineBesiegedSettlements()
	
			determineClosestCapital(current_faction_turn, besieged_region_table)
	
			
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
			for count = 1, #CharacterNames do
			
				if not (totalFound >= totalCount) and not (noSupplyForces[current_faction_turn] == nil) then
					for j = 1, #noSupplyForces[current_faction_turn] do
						no_supply_name = noSupplyForces[current_faction_turn][j][1]
						y, z = string.find(no_supply_name, CharacterNames[count][4], 1)
						
						if not (string.find(no_supply_name, CharacterNames[count][4], 1) == nil) then
							
							if conditions.CharacterForename(CharacterNames[count][2], context) then
							
								--if (conditions.CharacterTrait("C_General_Logistician_Bad", context) < 1) then
									WALI.UpdateWALILuaLog("Added \"C_General_Logistician_Bad\" trait to "..no_supply_name)
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
							y, z = string.find(block_supply_name, CharacterNames[count][4], 1)
						
							if  not (string.find(block_supply_name, CharacterNames[count][4], 1) == nil) then														
								if conditions.CharacterForename(CharacterNames[count][2], context) then	
									
									--if (conditions.CharacterTrait("C_General_Logistician_Good", context) < 1) then
									WALI.UpdateWALILuaLog("Added \"C_General_Logistician_Good\" trait to "..block_supply_name)
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
				for count = 1, #CharacterNames do																				
					if conditions.CharacterForename(CharacterNames[count][2], context) then	
						foreName = CharacterNames[count][4]
					end
				end
				for count = 1, #CharacterNames do																				
					if conditions.CharacterSurname(CharacterNames[count][2], context) then	
						surName = CharacterNames[count][4]
					end
				end
				
				WALI.UpdateWALILuaLog("Removed \"C_General_Logistician_Bad\" trait from "..foreName.." "..surName)
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
				for count = 1, #CharacterNames do																				
					if conditions.CharacterForename(CharacterNames[count][2], context) then	
						foreName = CharacterNames[count][4]
					end
				end
				for count = 1, #CharacterNames do																				
					if conditions.CharacterSurname(CharacterNames[count][2], context) then	
						surName = CharacterNames[count][4]
					end
				end
				
				WALI.UpdateWALILuaLog("Removed \"C_General_Logistician_Good\" trait from "..foreName.." "..surName)
				local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
				local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
				local target = good_count - bad_count
				for h = 1, target do
					effect.trait("C_General_Logistician_Bad", "agent", 1, 100, context)
				end

			end
			
			effectLongSupplyLines(current_faction_turn, context)
		end


	end

	

	events.CharacterSelected[#events.CharacterSelected+1] = function(context)
	
		character_selected_event = true

		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k, v in pairs(faction_list) do
			if conditions.CharacterFactionName(v.Key,context) then
				current_faction_turn = v.Key	
			end
		end
	

		if WALI_isOnCampMap and (conditions.CharacterType("admiral", context) or conditions.CharacterType("captain", context)) then
			local ETS = CampaignUI.EntityTypeSelected()
			
			if conditions.CharacterType("admiral", context) then
				charDetails = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
				CharacterAddress, WALI_previouslySelectedCharacterPointer = ETS.Entity
			elseif conditions.CharacterType("captain", context) then
				local unitDetails = CampaignUI.InitialiseUnitDetails(ETS.Entity)
				charDetails =  CampaignUI.InitialiseCharacterDetails(unitDetails.CharacterPtr)
				CharacterAddress, WALI_previouslySelectedCharacterPointer = unitDetails.CharacterPtr
			end
			determineBesiegedSettlements()
			
			local found = naval_army_supplier(context)

			if found == true then
				local good_count = conditions.CharacterTrait("C_Admiral_NavalArmySupplier_Good", context)
				local bad_count = conditions.CharacterTrait("C_Admiral_NavalArmySupplier_Bad", context)
				local target = 1 - good_count
				if good_count <= 0 then

					for h = 1, target do
						effect.trait("C_Admiral_NavalArmySupplier_Good", "agent", 1, 100, context)
						WALI.UpdateWALILuaLog("Added \"C_Admiral_NavalArmySupplier_Good_"..math.abs(target).."\" trait to "..charDetails.Name)
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
						WALI.UpdateWALILuaLog("Removed \"C_Admiral_NavalArmySupplier_Good_"..math.abs(target).."\" trait from "..charDetails.Name)

					end
				end
			end	

	
		elseif WALI_isOnCampMap and (conditions.CharacterType("General", context) or conditions.CharacterType("colonel", context)) then
		
			
			local ETS = CampaignUI.EntityTypeSelected()
			
			if conditions.CharacterType("General", context) then
				charDetails = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
				CharacterAddress, WALI_previouslySelectedCharacterPointer = ETS.Entity
			elseif conditions.CharacterType("colonel", context) then
				local unitDetails = CampaignUI.InitialiseUnitDetails(ETS.Entity)
				charDetails =  CampaignUI.InitialiseCharacterDetails(unitDetails.CharacterPtr)
				CharacterAddress, WALI_previouslySelectedCharacterPointer = unitDetails.CharacterPtr
			end

			local diplomacy = CampaignUI.RetrieveDiplomacyDetails(current_faction_turn)
			

			determineBesiegedSettlements()

			for k, v in pairs(diplomacy.AtWar) do	

				determineClosestCapital(k)			
			end
			
			
			local c = WALI_m_root:Find("MACH_LogisticsPip")
			


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

			for count = 1, #CharacterNames do
			

				if not (totalBlockSupplyFound >= totalBlockSupply) and not (blockingSupplyForces[current_faction_turn] == nil) then

					for j = 1, #blockingSupplyForces[current_faction_turn] do
						block_supply_name = blockingSupplyForces[current_faction_turn][j][1]
						if not (block_supply_name == nil) then
							y, z = string.find(block_supply_name, CharacterNames[count][4], 1)
					
							if  not (string.find(block_supply_name, CharacterNames[count][4], 1) == nil) then														
								if conditions.CharacterForename(CharacterNames[count][2], context) then	
									
									UIComponent(c):SetState("BlockLogistics")
									local region_screen_name = nil
									
									for b = 1, #RegionNames do
										if RegionNames[b][2] == "regions_onscreen_"..blockingSupplyForces[current_faction_turn][j][4] then
											region_screen_name = RegionNames[b][4]
										end
									end
									if region_screen_name ~= nil then
										UIComponent(c):SetTooltipText("This army has severed the logistics of "..blockingSupplyForces[current_faction_turn][j][3].."'s force from "..region_screen_name..".", true)
									else
										UIComponent(c):SetTooltipText("This army has severed the logistics of "..blockingSupplyForces[current_faction_turn][j][3].."'s force from "..blockingSupplyForces[current_faction_turn][j][4].."'s fleet", true)
									end
									UIComponent(c):SetVisible(true)
									
									
									
									if prevEffectTime ~= 0 then
										if (((os.clock() - prevEffectTime) > 2) and CharacterAddress == prevCharacterAddress) or (CharacterAddress ~= prevCharacterAddress) then
											prevEffectTime = os.clock()
											prevCharacterAddress = CharacterAddress
											--if (conditions.CharacterTrait("C_General_Logistician_Good", context) < 1) then
											WALI.UpdateWALILuaLog("Added \"C_General_Logistician_Good\" trait to "..block_supply_name)

											local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
											local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
											local target = (bad_count+1) - good_count									
											for h = 1, target do
												effect.trait("C_General_Logistician_Good", "agent", 1, 100, context)
											end									
											--end
											WALI.UpdateWALILuaLog(conditions.CharacterTrait("C_General_Logistician_Good", context).."-"..conditions.CharacterTrait("C_General_Logistician_Bad", context))
											totalBlockSupplyFound = totalBlockSupplyFound + 1
											foundSupplyGood = true
											break
										end
									else

										prevEffectTime = os.clock()
										prevCharacterAddress = CharacterAddress
										--if (conditions.CharacterTrait("C_General_Logistician_Good", context) < 1) then
										WALI.UpdateWALILuaLog("Added \"C_General_Logistician_Good\" trait to "..block_supply_name)

										local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
										local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
										local target = (bad_count+1) - good_count									
										for h = 1, target do
											--WALI.UpdateWALILuaLog("loop"..h)
											effect.trait("C_General_Logistician_Good", "agent", 1, 100, context)
										end									
										--end
										--WALI.UpdateWALILuaLog(conditions.CharacterTrait("C_General_Logistician_Good", context).."-"..conditions.CharacterTrait("C_General_Logistician_Bad", context))
										totalBlockSupplyFound = totalBlockSupplyFound + 1
										foundSupplyGood = true
										break
										
									end
			
								end

							end	
						end

					end
					if foundSupplyGood == true then
						break
					end
				end

			end
				
			
			--[[
			if (foundSupplyBad == false) and (conditions.CharacterTrait("C_General_Logistician_Bad", context) >= 1) then	
				UIComponent(mach_logistics_pip):SetVisible(false)
				repeat
					effect.trait("C_General_Logistician_Good", "agent", 1, 100, context)
				until (conditions.CharacterTrait("C_General_Logistician_Good", context) == 0)

			end
			--]]
			if (foundSupplyGood == false) and (conditions.CharacterTrait("C_General_Logistician_Good", context) >= 1) then	
				--WALI.UpdateWALILuaLog("3333")
				if prevEffectTime ~= 0 then
					--WALI.UpdateWALILuaLog("jrer")
					if (((os.clock() - prevEffectTime) > 2) and CharacterAddress == prevCharacterAddress) or (CharacterAddress ~= prevCharacterAddress) then
						
						prevEffectTime = os.clock()
						prevCharacterAddress = CharacterAddress
					
						UIComponent(c):SetVisible(false)
						WALI.UpdateWALILuaLog("Removed \"C_General_Logistician_Good\" trait from "..charDetails.Name)
						local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
						local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
						local target = good_count - bad_count
						for h = 1, target do
							effect.trait("C_General_Logistician_Bad", "agent", 1, 100, context)
						end
					end
				else
					--WALI.UpdateWALILuaLog("5555")
					prevEffectTime = os.clock()
					prevCharacterAddress = CharacterAddress
				
					UIComponent(c):SetVisible(false)
					WALI.UpdateWALILuaLog("Removed \"C_General_Logistician_Good\" trait from "..charDetails.Name)
					
					local good_count = conditions.CharacterTrait("C_General_Logistician_Good", context)
					local bad_count = conditions.CharacterTrait("C_General_Logistician_Bad", context)
					local target = good_count - bad_count
					for h = 1, target do
						effect.trait("C_General_Logistician_Bad", "agent", 1, 100, context)
					end
				end

			end



			--WALI.UpdateWALILuaLog("here")
			--WALI.UpdateWALILuaLog(tostring(conditions.CharacterTrait("C_General_Logistician_Good", context) == 1).."-"..tostring(conditions.CharacterTrait("C_General_Logistician_Bad", context) == 1))

			local adjustedToolTip = false
			if (conditions.CharacterTrait("C_General_Logistician_Bad", context) >= 1) and (UIComponent(c):Visible() ~= true) then
				
				UIComponent(c):SetState("SeveredLogistics")

				if noSupplyForces[current_faction_turn] ~= nil then
					for count = 1, #CharacterNames do
						local loopNum = nil
						
						if #noSupplyForces[current_faction_turn] < 1 then
							loopNum = 1
						else
							loopNum = #noSupplyForces[current_faction_turn]
						end
						
						for j = 1, loopNum do
							local no_supply_name = nil


							no_supply_name = noSupplyForces[current_faction_turn][j][1]
							--WALI.UpdateWALILuaLog("hello")
							if (no_supply_name ~= nil) then

								y, z = string.find(no_supply_name, CharacterNames[count][4], 1)
							
								if (string.find(no_supply_name, CharacterNames[count][4], 1) ~= nil) then														
									if conditions.CharacterForename(CharacterNames[count][2], context) then	
										local region_screen_name = nil
										for b = 1, #RegionNames do
											if RegionNames[b][2] == "regions_onscreen_"..noSupplyForces[current_faction_turn][j][2] then
												region_screen_name = RegionNames[b][4]
											end
										end
										
										if region_screen_name ~= nil then
									
											UIComponent(c):SetTooltipText("An enemy force under the command of "..noSupplyForces[current_faction_turn][j][3].." has severed the logistics of this army from its supply base in "..region_screen_name..".")
										else
											UIComponent(c):SetTooltipText("An enemy force under the command of "..noSupplyForces[current_faction_turn][j][3].." has severed the logistics of this army from its supply by "..blockingSupplyForces[current_faction_turn][j][4].."'s fleet.")

										end
										
										adjustedToolTip = true
										
										break
										
									end
								end
							end
						end
						
						if adjustedToolTip == true then
							break
						end
					end
				else
					UIComponent(c):SetTooltipText("An enemy force has severed the logistics of this army.")
				end

				UIComponent(c):SetVisible(true)	
			end
			
			effectLongSupplyLines(current_faction_turn, context)


		end
	end


end




function SurpriseAttack()

	local armyInfoTableForTurn = {}

	local atWarWith = {}
	
	local faction_turn = nil
	
	
	function create_armyInfoTableForTurn()
	
		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_turn, true)
		for i = 1, #forcesList do
			local charDetails = CampaignUI.InitialiseCharacterDetails(forcesList[i].Address)
			--for k,v in pairs(entities.Units) do

			armyInfoTableForTurn[i] = {}
			armyInfoTableForTurn[i][1] = charDetails.ActionPoints --starting action points
			armyInfoTableForTurn[i][2] = forcesList[i].Name --General's Name
			armyInfoTableForTurn[i][3] = forcesList[i].Location --army location
			armyInfoTableForTurn[i][4] = current_faction_turn --army faction_key
			armyInfoTableForTurn[i][5] = forcesList[i].Address --character address


			WALI.UpdateWALILuaLog("here: "..current_faction_turn.." - "..forcesList[i].Name.." - "..charDetails.ActionPoints.." - "..forcesList[i].Location)	
			scripting.game_interface:add_time_trigger("MoveWatch", .5)
			--end
		end
	end


	--[[
	Description:
		Time trigger event
	--]]
	events.TimeTrigger[#events.TimeTrigger+1] = function(context)
		--context.string is the name passed when the trigger was fired (see line 563)
		
		--[[
		if context.string == "MoveWatch" then

			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_turn, true)
			for i = 1, #forcesList do

				local character_details = CampaignUI.InitialiseCharacterDetails(forcesList[i].Address)

				if current_faction_turn == armyInfoTableForTurn[forcesList[i].Address][4] then							
					scripting.game_interface:add_time_trigger("MoveWatch", .5)
				else
					break
				end	
				
				WALI.UpdateWALILuaLog("called")	
			
				for besieged_settlements_idx = 1, #armyInfoTableForTurn do
					if (armyInfoTableForTurn[besieged_settlements_idx][5] == forcesList[i].Address) and (armyInfoTableForTurn[besieged_settlements_idx][1] > character_details.ActionPoints) then
						WALI.UpdateWALILuaLog("HELLO")	
					end
				end


			end

		end

		--]]
	end

	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		--WALI.UpdateWALILuaLog(context.string)
		--create_armyInfoTableForTurn()
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k, v in pairs(faction_list) do
			if conditions.FactionName(v.Key, context) then
				faction_turn = v.Key
				WALI.UpdateWALILuaLog(faction_turn)
			end
		end
		
	end

	events.PanelOpenedCampaign[#events.PanelOpenedCampaign+1] = function(context)
	
		if conditions.IsComponentType("move_options", context) then
			--WALI.UpdateWALILuaLog("here")
			--CampaignUI.DeclareWarInstant(CampaignUI.PlayerFactionId(), "prussia")
			
			local diplomacy = CampaignUI.RetrieveDiplomacyDetails(current_faction_turn)
			
			local count = 1
			for k, v in pairs(diplomacy.AtWar) do
				atWarWith[count] = k
				count = count + 1
				--WALI.UpdateWALILuaLog("before "..k)		
			end
		end
	end
	
	events.PanelClosedCampaign[#events.PanelClosedCampaign+1] = function(context)
	
		if conditions.IsComponentType("diplomacy_panel", context) then
			WALI.UpdateWALILuaLog("here BOSS")
			--CampaignUI.DeclareWarInstant(CampaignUI.PlayerFactionId(), "prussia")
			
			local diplomacy = CampaignUI.RetrieveDiplomacyDetails(current_faction_turn)
			
			for k, v in pairs(diplomacy.AtWar) do						

				local found = false
				for j = 1, #atWarWith do
					if (atWarWith[j] == k) then
						found = true
					end
				end
				if (found == false) then
					--WALI.UpdateWALILuaLog("after "..k)	
				end
			end
			

		end
	end

	

	events.UICreated[#events.UICreated+1] = function(context)
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k, v in pairs(faction_list) do
			--WALI.UpdateWALILuaLog(v.Key)
			if conditions.FactionName(v.Key, context) then
				faction_turn = v.Key
				--WALI.UpdateWALILuaLog(faction_turn)
			end
		end
	end

end



--function to give attrition to AI units. This extends the Supply and Demand mod to include AI units.

function AI_Attrition()

	
	
	--########################
	--Variable Declaration
	--########################
	--table containing all player owned and allied regions
	safeRegionsAndSettlements = {}
	
	


	--[[--------------------------------------------------------------------------------
		Subsection C (ii):
			Attrition Calculations
	----------------------------------------------------------------------------------]]
	--[[
	Description:
		Faction Turn Start event.  From here attrition calculations are made
	--]]
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		if conditions.TurnNumber(context) >= 0 then
		

			--WALI.UpdateWALILuaLog("faction_key key namne: "..current_faction_key_name)
			
			updateSafeRegionsAndSettlements()
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_key_name, true)
			for i = 1, #forcesList do
				if not isRegionAttritionSafe(forcesList[i].Location) and not isLocationAFort(forcesList[i].Location) then

					local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
					for k,v in pairs(entities.Units) do

						local damage, reference = calculateAttritionDamage(v.Men)

						--WALI.UpdateWALILuaLog(tostring(v.Address).." - "..damage.." - ".."Unit: "..tostring(v.Name).."Commanders Name: "..tostring(v.CommandersName).."Random number reference: "..tostring(reference))
						WALI.SetCurrentUnitSize(v.Address, damage, "Unit: "..tostring(v.Name).."Commanders Name: "..tostring(v.CommandersName).."Random number reference: "..tostring(reference))
						
						--WALI.UpdateWALILuaLog("hi2: "..forcesList[i].Name.." - "..v.Name.." - "..v.CommandersName.." - "..forcesList[i].Location.." - "..damage.." - "..reference.." - "..tostring(v.Address))

					end
				else

				end
			end
		end
	end
	
		
	events.UICreated[#events.UICreated+1] = function(context)
		--Make sure the battle UI isn't after loading, then update safe region and settlements; This accounts for
		--loading save games, returning from battles and starting new games
		if context.string == "Campaign UI" then
			OK, Error = pcall(updateSafeRegionsAndSettlements)
			if not OK then
				WALI.UpdateWALILuaLog(Error)
			end
		end
	end

	--[[--------------------------------------------------------------------------------
		Subsection C (iii):
			Attrition helper functions
	----------------------------------------------------------------------------------]]
	--[[
	Description:
		Calculates attrition damage based on attrition variables read from a config file.
	Arguments:
		Number currentUnitSize
			Current size of unit to calculate damage for
	Returns:
		New size of unit (post damage)
	--]]
	function calculateAttritionDamage(currentUnitSize)

		local randNum = WALI.getRandomNumber(true)
		while randNum > WALI.WALI_AI_attritionMaxRate or randNum < WALI.WALI_AI_attritionMinRate do
			randNum = WALI.getRandomNumber(true)
		end
		return currentUnitSize - math.ceil(currentUnitSize / 100 * randNum), randNum
	end

	
	
		
	--[[
	Description:
		Finds out if a region is attrition safe (i.e. owned by player or an ally)
	Arguments:
		String region
			Name of the region
	Returns:
		True if owned, else false
	--]]
	function isRegionAttritionSafe(region)
		for i = 0, #safeRegionsAndSettlements do
			if safeRegionsAndSettlements[i] == region then
				return true
			end
		end
		return false
	end
	
	--[[
	Description:
		Updates the list of player owned and allied regions. Should be called on game load, turn start and when campaign is entered
	Arguments:
		n/a
	Returns:
		n/a
	--]]
	function updateSafeRegionsAndSettlements()

		safeRegionsAndSettlements = {}
		_regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(current_faction_key_name)

		local i = 1
		for k = 1, #_regions do
			safeRegionsAndSettlements[i] = _regions[k].Name
			i = i + 1
			safeRegionsAndSettlements[i] = CampaignUI.InitialiseRegionInfoDetails(_regions[k].Address).Settlement
			i = i + 1
		end
		
		--get allied regions
		local playerDiplomacyDetails = CampaignUI.RetrieveDiplomacyDetails(current_faction_key_name)
		--Update("Looping through allies")
		for k,v in pairs(playerDiplomacyDetails.Allies) do
			local thisFactionsRegions = CampaignUI.RegionsOwnedByFactionOrByProtectorates(k)
			for kk, vv in pairs(thisFactionsRegions) do
				safeRegionsAndSettlements[i] = thisFactionsRegions[kk].Name
				i = i + 1
			end
		end
	end

	
	--[[
	Description:
		Finds out if a region is a fort (will return true for cities with fort in the name, 
		that shouldn't be an issue though)
	Arguments:
		String location
			Name of the location
	Returns:
		True if owned, else false
	--]]
	function isLocationAFort(location)
		if not (string.find(location, "Fort") == nil) then
			return true
		end
	end
	
end

