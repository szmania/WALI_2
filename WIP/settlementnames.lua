--Code used to determin problematic settlement names
	
--List of settlement names pulled from the db.
local oldsettlementsTable = {"Fort Nashwaak", "Louisbourg", "Kabul", "Ahmadnagar", "Algiers", "Niagara", "Strasbourg", "Ankara", "Arkhangelsk", 
			"Yerevan", "Astrakhan", "Vienna", "Ardabil", "Nassau", "Zahedan", "Ufa", "Munich", "Minsk", "Calcutta", "Nagpur", "Satara", "Prague", "Sarajevo", 
			"Sofia", "Arcot", "Charleston", "Trincomalee", "Tarki", "Tellico", "Bastia", "Jelgava", "Bakhchisaray", "Zagreb", "La Habana", "Punda", "Copenhagen", 
			"Cherkassk", "Paramaribo", "Cairo", "London", "Riga", "�bo", "Brussels", "St. Augustine", "Paris", "Cayenne", "Lw�w", "Genoa", "Tbilisi", "Savannah", 
			"Gibraltar", "Knife River Village", "Athens", "Antigua Guatemala", "Ahmedabad", "Hannover", "Agra", "Santo Domingo", "Pre�burg", "Fort Sault Ste. Marie", 
			"Hyderabad", "Reykjav�k", "St. Petersburg", "Dublin", "Cayuga", "Port Royal", "Tanase", "Petrovskaya Sloboda", "Srinagar", "Ust-Sysolsk", "Agvituk", 
			"Antigua", "Vilnius", "New Orleans", "Falmouth", "Goa", "Valletta", "Ujjain", "Annapolis", "Baghdad", "Fort Pontchartrain du Detroit", "Milan", "Iasi", 
			"Patras", "Tangier", "Moscow", "Mysore", "Naples", "Amsterdam", "Caracas", "Boston", "Boston", "Qu�bec", "Qu�bec", "Bogot�", "Santa Fe", "M�xico", 
			"Albany", "Plaissance", "York Factory", "Christiania", "Montr�al", "Cuttack", "Jerusalem", "Panama", "Philadelphia", "Philadelphia", "Isfahan", "Warsaw", 
			"Lisbon", "K�nigsberg", "Lahore", "Udaipur", "Cologne", "Istanbul", "Moose Factory", "Cagliari", "Turin", "Dresden", "Edinburgh", "Belgrade", "Breslau", 
			"Neroon Kot", "Madrid", "Stockholm", "Damascus", "Kazan", "Villa de Bexar", "Rome", "Klausenburg", "San Jos� de Oru�a", "Tripoli", "Tunis", "Kiev", 
			"Fort de Chartres", "Venice", "Williamsburg", "Berlin", "Gdansk", "Martinique", "Stuttgart"
			}
			
			
			local factions = CampaignUI.RetrieveFactionListForDiplomacy()
			local ct = {"pirates"}
			for k,v in pairs(factions) do
				ct[#ct+1] = k
				UpdateWALILuaLog(tostring(k))
			end
			UpdateWALILuaLog(#ct)
			for i = 1, #ct do
				tab = CampaignUI.RegionsOwnedByFactionOrByProtectorates(ct[i])
				for e = 1, #tab do
					details = CampaignUI.InitialiseRegionInfoDetails(tab[e].Address)
					UpdateWALILuaLog("\tFound details")
					local settlementName = details.Settlement
					local found = false
					for i =1, #settlementsTable do
						if settlementsTable[i] == settlementName then
							UpdateWALILuaLog("\t\tSuccessful match!")
							found = true
							break
						end
					end
					if not found then
						UpdateWALILuaLog("\t\tCould not find a match for: "..tostring(settlementName))
					end
				end
				UpdateWALILuaLog("Event end")
			end