function test()
	function getFunctionData(key, thingy) 
    mach_lib.update_mach_lua_log("Finding functions for "..tostring(key))
		for k,v in pairs(thingy) do
			mach_lib.update_mach_lua_log(tostring(key).."."..tostring(k).." = "..tostring(v))

			if k ~= "_G" and k ~= "_M" and k ~= "__index" and k ~= "package" then
				if type(v) == "table" then
					getFunctionData(tostring(key).."."..tostring(k), v)
				elseif type(v) == "function" then
					for kk,vv in pairs(debug.getinfo(v)) do
						mach_lib.update_mach_lua_log(tostring(key).."."..tostring(k).."."..tostring(kk).." = "..tostring(vv))
					end
				
				end		
			end
		end
	end
	

	
	
	events.ComponentLClickUp[#events.ComponentLClickUp + 1] = function(context)
		--mach_lib.update_mach_lua_log("Traceback: "..debug.traceback("msg", 10))
	
		local ETS = CampaignUI.EntityTypeSelected()
		mach_lib.update_mach_lua_log("clicked")
		if ETS.Fort then
			mach_lib.update_mach_lua_log("IsFort")

			--mach_lib.update_mach_lua_log("ETS.Entity: "..tostring(ETS.Entity))
			--out.shane("fart")
			getFunctionData("context", context)

			for key,value in pairs(defined) do
				mach_lib.update_mach_lua_log("defined."..key.." = "..tostring(value))
			end
			


		--local details = CampaignUI.InitialiseUnitDetails(ETS.Entity)

		--local buildingRecordDetails = CampaignUI.BuildingRecordDetails("trading_port", CampaignUI.PlayerFactionId(), "new_york", "port:new_york:new_york")
		--local details = CampaignUI.BuildingBrowserDetails("new_york")

		--local buildingDetails = CampaignUI.BuildingDetails("trading_port", CampaignUI.PlayerFactionId(), "new_york", "port:new_york:new_york")
		--mach_lib.update_mach_lua_log("bulding position"..tostring(buldingDetails.PosX)..","..tostring(buildingDetails.PosY))
		--local fortDetails = CampaignUI.BuildingDetails(ETS.Entity)
		--mach_lib.update_mach_lua_log("fort position"..tostring(fortDetails.PosX)..","..tostring(fortDetails.PosY))
		--if CampaignUI.FactionDetails("britain") ~= nil then

			--for regionsOwned_k, regionsOwned_v in pairs(CampaignUI.RegionsOwnedByFactionOrByProtectorates("britain")) do

				--if not regionsOwned_v.OwnedByProtectorate then
					--local details = CampaignUI.InitialiseRegionInfoDetails(regionsOwned_v.Address)
		--local details = CampaignUI.BuildingBrowserDetails(regionsOwned_v.Address)
		--mach_lib.update_mach_lua_log("hi")
			--local forcesList = CampaignUI.RetrieveFactionMilitaryForceLists(CampaignUI.PlayerFactionId(), true)
			--for i = 1, #forcesList do
				--local charDetails = CampaignUI.InitialiseCharacterDetails(forcesList[i].Address)

			for k, v in pairs(ETS) do
				mach_lib.update_mach_lua_log("\t\t TEST: \t\t"..tostring(k).."\t"..tostring(v))
				if type(v) == "table" then
					for kk, vv in pairs(v) do
						mach_lib.update_mach_lua_log("\t\t TEST: \t\t"..tostring(kk).."\t"..tostring(vv))
						if type(vv) == "table" then
							for kkk, vvv in pairs(vv) do
								mach_lib.update_mach_lua_log("\t\t TEST: \t\t\t"..tostring(kkk).."\t"..tostring(vvv))
								if type(vvv) == "table" then
									for kkkk, vvvv in pairs(vvv) do
										mach_lib.update_mach_lua_log("\t\t TEST: \t\t\t\t"..tostring(kkkk).."\t"..tostring(vvvv))
										if type(vvvv) == "table" then
											for kkkkk, vvvvv in pairs(vvvv) do
												mach_lib.update_mach_lua_log("\t\t TEST: \t\t\t\t"..tostring(kkkkk).."\t"..tostring(vvvvv))
												if type(vvvvv) == "table" then
													for kkkkkk, vvvvvv in pairs(vvvvv) do
														mach_lib.update_mach_lua_log("\t\t TEST: \t\t\t\t"..tostring(kkkkkk).."\t"..tostring(vvvvvv))
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
					--end
				--end
--]]
		end
	end
end

