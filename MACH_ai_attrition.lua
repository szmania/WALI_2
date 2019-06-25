--function to give attrition to AI units. This extends the Supply and Demand mod to include AI units.
function ai_attrition()

	
	
	--########################
	--Variable Declaration
	--########################
	--table containing all player owned and allied regions
	mach_lib.update_mach_lua_log("AI_Attrition")

	safe_regions_and_settlements = {}
	


	--[[--------------------------------------------------------------------------------
		Subsection C (ii):
			Attrition Calculations
	----------------------------------------------------------------------------------]]
	--[[
	Description:
		Faction Turn Start event.  From here attrition calculations are made
	--]]
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)
		mach_lib.update_mach_lua_log("AI_Attrition.events.FactionTurnStart")

	
		if conditions.TurnNumber(context) >= 0 then
		

			--mach_lib.update_mach_lua_log("faction_key key namne: "..__player_faction_id__)
			
			mach_lib.update_safe_regions_and_settlements()
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(__player_faction_id__, true)
			for i = 1, #forcesList do
				if not isRegionAttritionSafe(forcesList[i].Location) and not isLocationAFort(forcesList[i].Location) then

					local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
					for k,v in pairs(entities.Units) do

						local damage, reference = calculateAttritionDamage(v.Men)

						--mach_lib.update_mach_lua_log(tostring(v.Address).." - "..damage.." - ".."Unit: "..tostring(v.Name).."Commanders Name: "..tostring(v.CommandersName).."Random number reference: "..tostring(reference))
						WALI.SetCurrentUnitSize(v.Address, damage, "Unit: "..tostring(v.Name).."Commanders Name: "..tostring(v.CommandersName).."Random number reference: "..tostring(reference))
						
						--mach_lib.update_mach_lua_log("hi2: "..forcesList[i].Name.." - "..v.Name.." - "..v.CommandersName.." - "..forcesList[i].Location.." - "..damage.." - "..reference.." - "..tostring(v.Address))

					end
				else

				end
			end
		end
	end
	
		
--	events.UICreated[#events.UICreated+1] = function(context)
--		mach_lib.update_mach_lua_log("AI_Attrition.events.UICreated")
--
--		--Make sure the battle UI isn't after loading, then update safe region and settlements; This accounts for
--		--loading save games, returning from battles and starting new games
--		if context.string == "Campaign UI" then
--			OK, Error = pcall(updateSafeRegionsAndSettlements)
--			if not OK then
--				mach_lib.update_mach_lua_log(Error)
--			end
--		end
--	end

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
		mach_lib.update_mach_lua_log("AI_Attrition.calculateAttritionDamage")

		local randNum = WALI.getRandomNumber(true)
		while randNum > WALI.WALI_AI_attritionMaxRate or randNum < WALI.WALI.MACH_AI_attritionMinRate do
			randNum = WALI.getRandomNumber(true)
		end
		return currentUnitSize - math.ceil(currentUnitSize / 100 * randNum), randNum
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
		mach_lib.update_mach_lua_log("AI_Attrition.isLocationAFort")

		if not (string.find(location, "Fort") == nil) then
			return true
		end
	end
	
end



