
function surprise_attack()
	mach_lib.update_mach_lua_log("SurpriseAttack")


	local armyInfoTableForTurn = {}

	local atWarWith = {}
	
	local faction_turn = nil
	
	
	function create_armyInfoTableForTurn()
		mach_lib.update_mach_lua_log("SurpriseAttack.create_armyInfoTableForTurn")

	
		local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_turn, true)
		for i = 1, #forcesList do
			local charDetails = CampaignUI.InitialiseCharacterDetails(forcesList[i].Address)
			--for k,v in pairs(entities.Units) do

			armyInfoTableForTurn[i] = {}
			armyInfoTableForTurn[i][1] = charDetails.ActionPoints --starting action points
			armyInfoTableForTurn[i][2] = forcesList[i].Name --General's Name
			armyInfoTableForTurn[i][3] = forcesList[i].Location --army location
			armyInfoTableForTurn[i][4] = current_faction_turn --army faction
			armyInfoTableForTurn[i][5] = forcesList[i].Address --character address


			mach_lib.update_mach_lua_log("here: "..current_faction_turn.." - "..forcesList[i].Name.." - "..charDetails.ActionPoints.." - "..forcesList[i].Location)	
			scripting.game_interface:add_time_trigger("MoveWatch", .5)
			--end
		end
	end


	--[[
	Description:
		Time trigger event
	--]]
	events.TimeTrigger[#events.TimeTrigger+1] = function(context)
		mach_lib.update_mach_lua_log("SurpriseAttack.events.TimeTrigger")

		--context.string is the name passed when the trigger was fired (see line 563)
		
		--[[
		if context.string == "MoveWatch" then

			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(current_faction_turn, true)
			for i = 1, #forcesList do

				local charDetails = CampaignUI.InitialiseCharacterDetails(forcesList[i].Address)

				if current_faction_turn == armyInfoTableForTurn[forcesList[i].Address][4] then							
					scripting.game_interface:add_time_trigger("MoveWatch", .5)
				else
					break
				end	
				
				mach_lib.update_mach_lua_log("called")	
			
				for j = 1, #armyInfoTableForTurn do
					if (armyInfoTableForTurn[j][5] == forcesList[i].Address) and (armyInfoTableForTurn[j][1] > charDetails.ActionPoints) then
						mach_lib.update_mach_lua_log("HELLO")	
					end
				end


			end

		end

		--]]
	end

	
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		mach_lib.update_mach_lua_log("SurpriseAttack.events.FactionTurnStart")

		--mach_lib.update_mach_lua_log(context.string)
		--create_armyInfoTableForTurn()
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k, v in pairs(faction_list) do
			if conditions.FactionName(v.Key, context) then
				faction_turn = v.Key
				mach_lib.update_mach_lua_log("Current faction turn: "..tostring(faction_turn))
			end
		end
		
	end

	
	events.PanelOpenedCampaign[#events.PanelOpenedCampaign+1] = function(context)
		mach_lib.update_mach_lua_log("SurpriseAttack.events.PanelOpenedCampaign")

		if conditions.IsComponentType("move_options", context) then
			--mach_lib.update_mach_lua_log("here")
			--CampaignUI.DeclareWarInstant(CampaignUI.PlayerFactionId(), "prussia")
			
			local diplomacy = CampaignUI.RetrieveDiplomacyDetails(current_faction_turn)
			
			local count = 1
			for k, v in pairs(diplomacy.AtWar) do
				atWarWith[count] = k
				count = count + 1
				--mach_lib.update_mach_lua_log("before "..k)		
			end
		end
	end
	
	
	events.PanelClosedCampaign[#events.PanelClosedCampaign+1] = function(context)
		mach_lib.update_mach_lua_log("SurpriseAttack.events.PanelClosedCampaign")

		if conditions.IsComponentType("diplomacy_panel", context) then
			mach_lib.update_mach_lua_log("here BOSS")
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
					--mach_lib.update_mach_lua_log("after "..k)	
				end
			end
			

		end
	end


	events.UICreated[#events.UICreated+1] = function(context)
		mach_lib.update_mach_lua_log("SurpriseAttack.events.UICreated")

			
		local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
		for k, v in pairs(faction_list) do
			--mach_lib.update_mach_lua_log(v.Key)
			if conditions.FactionName(v.Key, context) then
				faction_turn = v.Key
				--mach_lib.update_mach_lua_log(faction_turn)
			end
		end
	end

end



