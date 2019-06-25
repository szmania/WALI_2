


--unused code bits
--[[
		if noSupplyForces[faction_key] ~= nil then
			if #noSupplyForces[faction_key] > 0 then

				for m = 1, #noSupplyForces[faction_key] do
					WALI.UpdateWALILuaLog(tostring(m)..":"..tostring(noSupplyForces[faction_key][m][1]).."-"..tostring(noSupplyForces[faction_key][m][2]).."-"..tostring(noSupplyForces[faction_key][m][3]))
				end
			end
		end
	--]]



	
--[[--------------------------------------------------------------------------------
		TEST CODE
----------------------------------------------------------------------------------]]
--[[

events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)
	local IsArtillery = nil

	if wali_is_on_campaign_map == true then
		local ETS = CampaignUI.EntityTypeSelected()
		if ETS.Character then
			WALI.UpdateWALILuaLog("Char table")
			character_details = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
			entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(ETS.Entity, ETS.Entity)
			for k, v in pairs(character_details) do
			
				WALI.UpdateWALILuaLog(tostring(k).."\t"..tostring(v))
				if type(v) == "table" then
				
					for kk, vv in pairs(v) do
						WALI.UpdateWALILuaLog("\t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then
							for kkk, vvv in pairs(vv) do
								WALI.UpdateWALILuaLog("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							end
						end
					end
				end
			end
		elseif ETS.Unit then
			WALI.UpdateWALILuaLog("Unit table")
			character_details = CampaignUI.InitialiseUnitDetails(ETS.Entity)
			for k, v in pairs(character_details) do
				WALI.UpdateWALILuaLog(tostring(k).."\t"..tostring(v))				
				if type(v) == "table" then
					for kk, vv in pairs(v) do					
						WALI.UpdateWALILuaLog("\t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then
							for kkk, vvv in pairs(vv) do
								WALI.UpdateWALILuaLog("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							end
						end
					end
				end
			end
		end
	end
end	
--]]


--[[

					--MY CODE
					--TESTING ARTILLERY
					if k == "IsArtillery" then
						if v == true then
							IsArtillery = true
						else 
							IsArtillery = false
						end
					end

					if k == "Address" and IsArtillery == true then
						--WALI.UpdateWALILuaLog("ADDRESS: "..tostring(k).."\t"..tostring(v))
						alphaPointer = WALI.GetAlphaPointer(v, optionalHeader)
						WALI.UpdateWALILuaLog("ALPHA POINTER ADDRESS: "..tostring(alphaPointer))
						SetArtillery(alphaPointer, 20)
					end
					
					--END OF MY CODE
--]]

		--[[
		local card_manager = UICardManager(false)
		local exchange_group	= UIComponent( __wali_m_root__:Find( "exchange_group" ) )
		local unit_list = {}
		local dropped_unit = nil
			local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists("france", true)
			for i = 1, #forcesList do
				local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[i].Address, forcesList[i].Address)
				for k,v in pairs(entities.Units) do
					if v.IsArtillery then

						unit_list[#unit_list + 1] = v.Address

						if (dropped_unit ~= nil) then
							WALI.UpdateWALILuaLog(tostring(CampaignUI.CanUnitsMerge(v.Address, dropped_unit)))
						end
						exchange_group:Adopt(v.Address)


						card_manager:AddCard(UIComponent(v.Address))
													WALI.UpdateWALILuaLog("here")	
					end
				end
			end
			
			
				for m = 1, #unit_list do
					WALI.UpdateWALILuaLog(unit_list[m])
				end
				
		WALI.UpdateWALILuaLog("there")	

		CampaignUI.MergeUnits(unit_list)
		
		--]]


			--[[
			
			local regionsList = CampaignUI.RetrieveVisibleEntityDetails()
			
			WALI.UpdateWALILuaLog(UIComponent(regionsList.Entity):Position())
			if type(regionsList) == "table" then 
				for k,v in pairs(regionsList) do
					WALI.UpdateWALILuaLog("\t"..tostring(k).."\t"..tostring(v))
					if type(v) == "table" then 
						for kk,vv in pairs(v) do
							WALI.UpdateWALILuaLog("\t\t"..tostring(kk).."\t"..tostring(vv))
							if type(vv) == "table" then 
								for kkk,vvv in pairs(vv) do
									WALI.UpdateWALILuaLog("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							--local settlementDetails = CampaignUI.InitialiseSettlementInfoDetails(vv)
							--WALI.UpdateWALILuaLog(settlementDetails)
								end
							end
						end
					end
				end
			end
			
			--]]
			
			
				--[[
	events.WorldCreated[#events.WorldCreated+1] = function(context)

	end
	--]]
	
			--[[
		if wali_is_on_campaign_map == true then
			local regions = CampaignUI.RegionsOwnedByFactionOrByProtectorates("france")
			--WALI.UpdateWALILuaLog(regions[k].Name)
			for k = 1, #regions do

				local details = CampaignUI.InitialiseRegionInfoDetails(regions[k].Address)
				if type(details) == "table" then 
					for k, v in pairs(details) do
						WALI.UpdateWALILuaLog(tostring(k).."\t"..tostring(v))
						if type(v) == "table" then
							for kk, vv in pairs(v) do
								WALI.UpdateWALILuaLog(tostring(kk).."\t\t"..tostring(vv))
								if type(vv) == "table" then
									for kkk, vvv in pairs(vv) do
										WALI.UpdateWALILuaLog(tostring(kkk).."\t\t\t"..tostring(vvv))
										if type(vvv) == "table" then
											for kkk, vvv in pairs(vv) do
												WALI.UpdateWALILuaLog(tostring(kkk).."\t\t\t"..tostring(vvv))
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
		
		--]]
		
		
		--[[
		--show battle results tables
			for k,v in pairs(resultsOfBattle) do
				WALI.UpdateWALILuaLog("\t"..tostring(k).."\t"..tostring(v))
				if type(v) == "table" then 
					for kk,vv in pairs(v) do
						WALI.UpdateWALILuaLog("\t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then 
							for kkk, vvv in pairs(vv) do
								WALI.UpdateWALILuaLog("\t\t\t"..tostring(kkk).."\t"..tostring(vvv))
								if type(vvv) == "table" then 
									for kkkk, vvvv in pairs(vvv) do
										WALI.UpdateWALILuaLog("\t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
										if type(vvvv) == "table" then 
											for kkkkk, vvvvv in pairs(vvvv) do
												WALI.UpdateWALILuaLog("\t\t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
											end
										end
									end
								end
							end						
						end
					end
				end

			end
			--]]
			
			
			--[[
			local prisoners_land_battle = UIComponent(__wali_m_root__:Find("prisoners_land_battle"))
			WALI.UpdateWALILuaLog(CampaignUI.PlayerFactionId().."-"..victor_Faction_Key)
			if(CampaignUI.PlayerFactionId() == victor_Faction_Key) then

				prisoners_land_battle:LuaCall("Initialise", true, 2000, 20000)
			else
				prisoners_land_battle:LuaCall("Initialise", false, 2000, 20000)
			end
			prisoners_land_battle:PropagateVisibility(true)
			--]]
			
			
			--[[
		--example of how you can make AI build fort.
		--character pointer of general is needed
		events.ComponentLClickUp[#events.ComponentLClickUp+1] = function(context)

		
			local ETS = CampaignUI.EntityTypeSelected()
			if ETS.Character then
				--WALI.UpdateWALILuaLog("Char table")
				character_details = CampaignUI.InitialiseCharacterDetails(ETS.Entity)
				--WALI.UpdateWALILuaLog(character_details.Address)
				--CampaignUI.BuildFort(character_details.Address)
				local info = CampaignUI.ReviewPanelInfo()
				WALI.UpdateWALILuaLog(info.commander)
				if info.commander ~= nil then
					CampaignUI.BuildFort(info.commander)
				end
			end
				
		end
			
			--]]