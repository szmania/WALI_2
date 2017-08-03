
	function SortAndRemoveExcessiveFiles(files)
	  table.sort(files, function(lhs, rhs)
		return rhs.Date < lhs.Date
	  end)
	  if #files > 900 then
		for i = 1, #files - 900 do
		  table.remove(files)
		end
	  end
	  return files
	end
		UpdateMACHLuaLog("hi")
		--[[
		for key,value in pairs(conditions) do
			UpdateMACHLuaLog("conditions."..key)
		end
		
		--]]

		--[[

		for key,value in pairs(events) do
			UpdateMACHLuaLog("events."..key)
		end


		funcInfo = debug.getinfo(CampaignUI.RetrieveDiplomaticStanceString)
		UpdateMACHLuaLog(tostring(funcInfo))
		for k, v in pairs(funcInfo) do
			UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
		end
		
		for i = 1, 10 do
			name, val = debug.getlocal(CampaignUI.RetrieveDiplomaticStanceString, 1)
			UpdateMACHLuaLog(tostring(name))
		end
		
		--for key,value in pairs(CampaignUI) do
		
		argsGotten = getArgs(CampaignUI.RetrieveDiplomaticStanceString)
		--UpdateMACHLuaLog("CampaignUI." .. key)
		UpdateMACHLuaLog(tostring(argsGotten))
		for k, v in pairs(argsGotten) do
			UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
		end

		--end
		
		for k,v in pairs(getparams(CampaignUI.RetrieveDiplomaticStanceString)) do
			UpdateMACHLuaLog("l:"..tostring(k).." - "..tostring(v))
		end
		--]]
		UpdateMACHLuaLog("hi2")

		--local regionDetails = CampaignUI.EntityTypeSelected()
		--local regionDetails = CampaignUI.InitialiseCharacterDetails(forcesList[1].Address)
		--local regionDetails = CampaignUI.FactionDetails(CampaignUI.PlayerFactionId())
		--local regionDetails = CampaignUI.RetrieveVisibleEnitityDetails()

		--local regionDetails = CampaignUI.BuildingDetails("trading_port", CampaignUI.PlayerFactionId(), "new_york", "port:new_york:new_york")
		UpdateMACHLuaLog("bye")
		--UpdateMACHLuaLog(rea)
		--local regionDetails = CampaignUI.InitialiseRegionInfoDetails(regionsOwned_v.Address)
		
		--UpdateMACHLuaLog(regionsOwned_v.Address)
		--UpdateMACHLuaLog("\t\t "..tostring(regionDetails))
		--local regionDetails = CampaignUI.FortDetails("wooden_artillery_fort", CampaignUI.PlayerFactionId(), "carolinas", "fort:carolinas:east")

		--local regionDetails = CampaignUI.RetrieveFactionMilitaryForceLists(CampaignUI.PlayerFactionId(), true)
		UpdateMACHLuaLog("bye3")

--[[
		--local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(CampaignUI.PlayerFactionId(), true)
		--for n = 1, #forcesList do
		--local entities = CampaignUI.RetrieveGameCore()
		local regions_list = CampaignUI.RetrieveFactionRegionList(CampaignUI.PlayerFactionId())

		--local entities = CampaignUI.RetrieveContainedEntitiesFromCharacter(forcesList[n].Address, forcesList[n].Address)
		for k, v in pairs(regions_list) do
			--UpdateMACHLuaLog("building data")
			UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
			if type(v) == "table" then
				for kk, vv in pairs(v) do
					UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
					if type(vv) == "table" then
						for kkk, vvv in pairs(vv) do
							UpdateMACHLuaLog("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							if type(vvv) == "table" then
								for kkkk, vvvv in pairs(vvv) do
									UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
									if type(vvvv) == "table" then
										for kkkkk, vvvvv in pairs(vvvv) do
											UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
											if type(vvvvv) == "table" then
												for kkkkkk, vvvvvv in pairs(vvvvv) do
													UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
		end
		--end

	
	--]]
	

--[[		

			--scripting.game_interface:add_marker("test11", "fmv_cross2", 10, 50, 2, true)
			--scripting.game_interface:set_marker_active("test11", true)
			UpdateMACHLuaLog("SLECTED FORT")
			scripting.game_interface:force_declare_war("france", "austria")
			UpdateMACHLuaLog("SLECTED FORTB")

			scripting.game_interface:grant_unit("settlement:new_england:boston", "euro_militia_infantry")
			UpdateMACHLuaLog("SLECTED FORTA")

			local entities_inview = CampaignUI.RetrieveVisibleEnitityDetails()
			UpdateMACHLuaLog("SLECTED FORT 0")

			local fort_effects = CampaignUI.FortEffects(ETS.Entity, "wooden_artillery_fort")
			UpdateMACHLuaLog("SLECTED FORT 1")

			local fort_details = CampaignUI.FortDetails(ETS.Entity, "wooden_artillery_fort")
			UpdateMACHLuaLog("SLECTED FORT 2")

			for k, v in pairs(entities_inview.Forts) do
				UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(k).."\t"..tostring(v))

				if type(v) == "table" then
					for kk, vv in pairs(v) do
						UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then
							for kkk, vvv in pairs(vv) do
								UpdateMACHLuaLog("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
								if type(vvv) == "table" then
									for kkkk, vvvv in pairs(vvv) do
										UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
										if type(vvvv) == "table" then
											for kkkkk, vvvvv in pairs(vvvv) do
												UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
												if type(vvvvv) == "table" then
													for kkkkkk, vvvvvv in pairs(vvvvv) do
														UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
			end
		
			UpdateMACHLuaLog("SLECTED UNIT")
			while true do
				CampaignUI.NextAutoEntitySelection()

				ETS = CampaignUI.EntityTypeSelected()

				for k, v in pairs(ETS) do
					UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
					if type(v) == "table" then
						for kk, vv in pairs(v) do
							UpdateMACHLuaLog("\t\t TEST: \t"..tostring(kk).."\t"..tostring(vv))
							UpdateMACHLuaLog("SELECTED FORT: ")

							UpdateMACHLuaLog("SELECTED FORT: "..toString(ETS.Entity))
						end
					end
					
				end
			end
			
			if CampaignUI.SlotKeyFromAddress(ETS.Entity) ~= nil then
				UpdateMACHLuaLog("Slot key: "..tostring(CampaignUI.SlotKeyFromAddress(ETS.Entity)))
			end
		end

		--if ETS.Fort then
		--local fortDetails = CampaignUI.FortDetails(ETS.Entity, "wooden_artillery_fort")
		UpdateMACHLuaLog("FORT DATA")
		if ETS.Slot then
			if CampaignUI.SlotKeyFromAddress(ETS.Entity) ~= nil then
				UpdateMACHLuaLog("Slot key: "..tostring(CampaignUI.SlotKeyFromAddress(ETS.Entity)))
			end
		end
		--local fortDetails = CampaignUI.RetrieveVisibleEnitityDetails()
		for k, v in pairs(ETS) do
			--UpdateMACHLuaLog("building data")
			UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
			if type(v) == "table" then
				for kk, vv in pairs(v) do
					UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
					if type(vv) == "table" then
						for kkk, vvv in pairs(vv) do
							UpdateMACHLuaLog("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							if type(vvv) == "table" then
								for kkkk, vvvv in pairs(vvv) do
									UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
									if type(vvvv) == "table" then
										for kkkkk, vvvvv in pairs(vvvv) do
											UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
											if type(vvvvv) == "table" then
												for kkkkkk, vvvvvv in pairs(vvvvv) do
													UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
		end
		UpdateMACHLuaLog("building data")

		for k, v in pairs(ETS.Entity) do
			UpdateMACHLuaLog("building data")
			UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
			if type(v) == "table" then
				for kk, vv in pairs(v) do
					UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
					if type(vv) == "table" then
						for kkk, vvv in pairs(vv) do
							UpdateMACHLuaLog("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							if type(vvv) == "table" then
								for kkkk, vvvv in pairs(vvv) do
									UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
									if type(vvvv) == "table" then
										for kkkkk, vvvvv in pairs(vvvv) do
											UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
											if type(vvvvv) == "table" then
												for kkkkkk, vvvvvv in pairs(vvvvv) do
													UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
		end
		--]]

		--[[
		if CampaignUI.FactionDetails(CampaignUI.PlayerFactionId()) ~= nil then

			for regionsOwned_k, regionsOwned_v in pairs(CampaignUI.RegionsOwnedByFactionOrByProtectorates(CampaignUI.PlayerFactionId())) do
				--UpdateMACHLuaLog("\t\t regionsOwned_k:"..tostring(regionsOwned_k).."\t regionsOwned_v:"..tostring(regionsOwned_v))

				if not regionsOwned_v.OwnedByProtectorate and done == false then
					done = true
					
				--]]
					--local regions_list = CampaignUI.RetrieveFactionRegionList(faction_turn)
					--local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(faction_turn, true)
					--for i = 1, #regions_list do
						--UpdateMACHLuaLog(regions_list[i])
						--local regionDetails = CampaignUI.RetrieveFactionAgentsList(CampaignUI.PlayerFactionId())
					--local regionDetails = CampaignUI.InitialiseRegionInfoDetails(regionsOwned_v.Address)
		
		--local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(CampaignUI.PlayerFactionId(), true)


--[[
			local faction_list = CampaignUI.RetrieveFactionListForDiplomacy()
			for k, v in pairs(faction_list) do
				local faction_details = CampaignUI.FactionDetails(v.Key)
				UpdateMACHLuaLog(tostring(v.Key).." - "..tostring(faction_details.Address))
			end
			
			local file_extension, path = CampaignUI.FileExtenstionAndPathForWriteClass("save_game")
			UpdateMACHLuaLog("hi")
			local files = SortAndRemoveExcessiveFiles(CampaignUI.EnumerateCampaignSaves(path, "*".. file_extension))

			for i = 1, #files do
				UpdateMACHLuaLog(tostring(files[i].Path))

				extendedSaveInfo = CampaignUI.GetExtendedSaveGameInfo(files[i].Path)

				--local gameInfo = CampaignUI.GetCurrentGameInfo()
				for k,v in pairs(extendedSaveInfo) do
				
				
					--UpdateMACHLuaLog("_G."..tostring(k).." = "..tostring(v))
					UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))

					if type(v) == "table" then

						for kk, vv in pairs(v) do
							--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).." = "..tostring(vv))

							UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
							if type(vv) == "table" then

								for kkk, vvv in pairs(vv) do
									--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).." = "..tostring(vvv))

									UpdateMACHLuaLog("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
									if type(vvv) == "table" then

										for kkkk, vvvv in pairs(vvv) do
											--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).." = "..tostring(vvvv))

											UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
											if type(vvvv) == "table" then

												for kkkkk, vvvvv in pairs(vvvv) do
													--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).." = "..tostring(vvvvv))

													UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
													if type(vvvvv) == "table" then
														for kkkkkk, vvvvvv in pairs(vvvvv) do
															--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).."."..tostring(kkkkkk).." = "..tostring(vvvvvv))

															UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
															if type(vvvvvv) == "table" then
																for kkkkkkk, vvvvvvv in pairs(vvvvvv) do
																	--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).."."..tostring(kkkkkk).."."..tostring(kkkkkkk).." = "..tostring(vvvvvvv))

																	UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
																	if type(vvvvvvv) == "table" then
																		for kkkkkkkk, vvvvvvvv in pairs(vvvvvvv) do
																			--UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).."."..tostring(kkkkkk).."."..tostring(kkkkkkk).."."..tostring(kkkkkkkk).." = "..tostring(vvvvvvvv))

																			UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
								end

							end
						end
					end

				end
			end
--]]
--[[

--[[
	events.FactionTurnStart[#events.FactionTurnStart+1] = function(context)

	
		UpdateMACHLuaLog("\t\t TEST: Running Test() function")

		local factionsList = CampaignUI.RetrieveFactionListForDiplomacy()
		UpdateMACHLuaLog("\t\t TEST: ".."getting faction list")

		for k, v in pairs(factionsList) do
			if conditions.FactionName(v.Key, context) then
				faction_turn = v.Key
				UpdateMACHLuaLog("\t\t TEST faction turn: "..tostring(faction_turn))

			end
		end
	end

	events.SlotTurnStart[#events.SlotTurnStart + 1] = function(context)

		UpdateMACHLuaLog("SlotTurnStart")

		--local firstETS = CampaignUI.NextAutoSettlementSelection("carolinas")


		UpdateMACHLuaLog("here2")
		UpdateMACHLuaLog("here3")
		local ETS = nil
		
		while true do
			CampaignUI.NextAutoEntitySelection()

			ETS = CampaignUI.EntityTypeSelected()

			for k, v in pairs(ETS) do
				UpdateMACHLuaLog("\t\t TEST: \t"..tostring(k).."\t"..tostring(v))
				if type(v) == "table" then
					for kk, vv in pairs(v) do
						UpdateMACHLuaLog("\t\t TEST: \t"..tostring(kk).."\t"..tostring(vv))
						UpdateMACHLuaLog("SELECTED FORT: ")

						UpdateMACHLuaLog("SELECTED FORT: "..toString(ETS.Entity))
					end
				end
				
			end
		end

		UpdateMACHLuaLog("SLOT TURN START")
		if conditions.SlotType("port", context) then
			UpdateMACHLuaLog("FOUND FORT SLOT")

		end

        if conditions.BuildingTypeExistsAtSlot("university", context) then
			UpdateMACHLuaLog("FOUND")

			local currentSlot = getCurrentSlot(context)

			UpdateMACHLuaLog("wooden_artillery_fort - SLOT: "..currentSlot)

        end
		if conditions.BuildingTypeExistsAtSlot("western_artillery_fort", context) then
			UpdateMACHLuaLog("FOUND")

			local currentSlot = getCurrentSlot(context)

			UpdateMACHLuaLog("western_artillery_fort - SLOT: "..currentSlot)

        end
		
		if conditions.BuildingTypeExistsAtSlot("star_fort", context) then
			UpdateMACHLuaLog("FOUND")

			local currentSlot = getCurrentSlot(context)

			UpdateMACHLuaLog("star_fort - SLOT: "..currentSlot)

        end

	end
--]]

--[[
	events.FactionTurnStart[#events.FactionTurnStart + 1] = function(context)
		for k,v in pairs(_G) do
			UpdateMACHLuaLog("_G."..tostring(k).." = "..tostring(v))

			if type(v) == "table" and k ~= "_G" and k ~= "package" then

				for kk, vv in pairs(v) do
					UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).." = "..tostring(vv))

					--UpdateMACHLuaLog("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
					if type(vv) == "table" and k ~= "_G" and k ~= "_M" and k ~= "__index" then

						for kkk, vvv in pairs(vv) do
							UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).." = "..tostring(vvv))

							--UpdateMACHLuaLog("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
							if type(vvv) == "table" then

								for kkkk, vvvv in pairs(vvv) do
									UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).." = "..tostring(vvvv))

									--UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
									if type(vvvv) == "table" and kkkk ~= "package" then

									--if type(vvvv) == "table" then
										for kkkkk, vvvvv in pairs(vvvv) do
											UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).." = "..tostring(vvvvv))

											--UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
											if type(vvvvv) == "table" then
												for kkkkkk, vvvvvv in pairs(vvvvv) do
													UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).."."..tostring(kkkkkk).." = "..tostring(vvvvvv))

													--UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
													if type(vvvvvv) == "table" then
														for kkkkkkk, vvvvvvv in pairs(vvvvvv) do
															UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).."."..tostring(kkkkkk).."."..tostring(kkkkkkk).." = "..tostring(vvvvvvv))

															--UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
															if type(vvvvvvv) == "table" then
																for kkkkkkkk, vvvvvvvv in pairs(vvvvvvv) do
																	UpdateMACHLuaLog("_G."..tostring(k).."."..tostring(kk).."."..tostring(kkk).."."..tostring(kkkk).."."..tostring(kkkkk).."."..tostring(kkkkkk).."."..tostring(kkkkkkk).."."..tostring(kkkkkkkk).." = "..tostring(vvvvvvvv))

																	--UpdateMACHLuaLog("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
						end

					end
				end
			end
		end
	end
--]]	

