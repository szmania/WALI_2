module(..., package.seeall)

function string:split(pattern)
-- split a string by a pattern
	local strStart, strEnd
	local t = {}

	strStart,strEnd = self:find(pattern)
	while strStart ~= nil do
    	t[#t+1] = self:sub(1,strStart-1)
    	self = self:sub(strEnd+1)
    	strStart,strEnd = self:find(pattern)
	end
	t[#t+1] = self
	
	return t
end

function readTSV(handle, lineNum)
    local line = handle:read("*line")
    
    if line == nil then
       	return lineNum,-1,{},0
    end
    
    local length = #line
	lineNum = lineNum + 1
	local ind, str = perpetuate.getIndentLevel(line)
	local splitValues = str:split("\t")
	return lineNum, ind, splitValues, length+1
end


function isPlayerFaction(faction)
	if CampaignUI.PlayerFactionId() == faction then
	    return true
	else
	    return false
	end
end


-- get a theatre ID by horizontal position (for armies)
function getTheatreByPosX(pos)
	if pos < -345 then
		return "1"
	elseif pos < 440 then
	    return "2"
	else
	    return "3"
	end
	return false
end


-- compares two tables and checks them for a missing savegame, returns the entry in list A
function findMissingEntry(listA,listB)
	local found = false
	for kk,vv in ipairs(listA) do
		for kk2,vv2 in ipairs(listB) do
		   	if vv.FileName == vv2.FileName then
		   		found = true
		   	end
		end
		if not found then
		   	return vv
		end
		found = false
	end
	return false
end

function fileExists(filename)
	s,f = pcall(io.open,filename,"r")
	if f == nil then
		return false
	end
	f:close()
	return true
end

function log(string)
	if alpalog == nil then
		alpalog = io.open('alpalog.txt','a')
	end
	alpalog:write(string)
	alpalog:flush()
end

function intToTabs(indentLevel)
   	local tabs = ""
   	for i = 1,indentLevel do
   	   	tabs = tabs.."\t"
   	end
   	return tabs
end

function alpaTables(thingy,depth)
  if type(thingy) == "userdata" then
  	thingy = getmetatable(thingy)
  end
  for kk,vv in pairs(thingy) do
  	for i = 1,depth do
      log("  ")
  	end
    if type(kk) == "string" then
    	log(kk..": "..type(vv))
    else
    	log(tostring(kk)..": "..type(vv))
    end
    if type(vv) == "string" then
	  log(": "..vv)
	end
	if type(vv) == "number" or type(vv) == "boolean" then
	  log(": "..tostring(vv))
	end
	log("\n")
	if type(vv) == "table" then
	  if kk ~= "_M" and kk ~= "_G" and kk ~= "__index" then
		if kk ~= "_G" then
  		  alpaTables(vv,depth+1)
		end
	  end
	end
	if type(vv) == "userdata" then
  	  alpaTables(vv,depth+1)
	end
  end
  thingy = getmetatable(thingy)
  if thingy == nil then
  	return
  end
  for kk,vv in pairs(thingy) do
  	for i = 1,depth do
      log("  ")
  	end
    if type(kk) == "string" then
    	log(kk..": "..type(vv))
    else
    	log(tostring(kk)..": "..type(vv))
    end
    if type(vv) == "string" then
	  log(": "..vv)
	end
	if type(vv) == "number" or type(vv) == "boolean" then
	  log(": "..tostring(vv))
	end
	log("\n")
	if type(vv) == "table" then
	  if kk ~= "_M" and kk ~= "_G" and kk ~= "__index" then
		if kk ~= "_G" then
  		  alpaTables(vv,depth+1)
		end
	  end
	end
	if type(vv) == "userdata" then
  	  alpaTables(vv,depth+1)
	end
  end
  
  return "\n\nalpaTables\n\n"
end


function getFactionNameFromFactionContext(context)
	for k,v in ipairs(factionsList) do
	    if conditions.FactionName(v,context) then
	        return v
	    end
	end
	return false
end


-- function to determine the current region name from settlement context
function getRegionNameFromSettlementContext(context)
   	for kk,vv in pairs(settlementToRegionList) do
   	   	if conditions.SettlementName(kk,context) then
   	   		return vv
   	   	end
   	end
end

-- function to get the current settlement name from settlement context
function getCurrentSettlement(context)
   	for kk,vv in pairs(settlementToRegionList) do
   	   	if conditions.SettlementName(kk,context) then
   	   		return kk
   	   	end
   	end
end


-- function to get the current slot name from slot context (if ID)
function getCurrentSlot(context)
   	for kk,vv in pairs(slotToRegionList) do
   	   	if conditions.SlotName(kk,context) then
   	   		return kk
   	   	end
   	end
   	return "No ID slot"
end

-- function to get the current region name from slot context (if ID)
function getRegionNameFromSlotContext(context)
   	for kk,vv in pairs(slotToRegionList) do
   	   	if conditions.SlotName(kk,context) then
   	   		return vv
   	   	end
   	end
   	return "No ID slot"
end

theatresList = {"1","2","3"}

-- list of all factions in the game
factionsList = {"afghanistan",
		"american_rebels",
		"amerind_rebels",
		"austria",
		"austrian_rebels",
		"barbary_rebels",
		"barbary_states",
		"bavaria",
		"britain",
		"british_rebels",
		"british_settler_rebels",
		"chechenya_dagestan",
		"cherokee",
		"colombia",
		"cossack_rebels",
		"courland",
		"crimean_khanate",
		"denmark",
		"dutch_rebels",
		"european_settler_rebels",
		"france",
		"french_rebels",
		"french_settler_rebels",
		"genoa",
		"georgia",
		"greece",
		"greek_rebels",
		"hannover",
		"hessen",
		"holstein_gottorp",
		"hungary",
		"huron",
		"india_settler_rebels",
		"inuit",
		"ireland",
		"iroquoi",
		"italian_rebels",
		"khanate_khiva",
		"knights_stjohn",
		"louisiana",
		"mamelukes",
		"maratha",
		"maratha_rebels",
		"mecklenburg",
		"mexico",
		"middle_east_settler_rebels",
		"morocco",
		"mughal",
		"mughal_rebels",
		"mysore",
		"naples_sicily",
		"netherlands",
		"new_spain",
		"norway",
		"ottoman_rebels",
		"ottomans",
		"papal_states",
		"persian_rebels",
		"piedmont_savoy",
		"pirates",
		"plains",
		"poland_lithuania",
		"portugal",
		"portugese_rebels",
		"powhatan",
		"prussia",
		"prussian_rebels",
		"pueblo",
		"punjab",
		"quebec",
		"russia",
		"safavids",
		"saxony",
		"scandinavian_rebels",
		"scotland",
		"sikh_rebels",
		"slavic_rebels",
		"spain",
		"spanish_rebels",
		"spanish_settler_rebels",
		"sweden",
		"swiss_confederation",
		"thirteen_colonies",
		"tuscany",
		"united_states",
		"venice",
		"virginia",
		"virginia_colonists",
		"westphalia",
		"wurttemberg"}
		
-- list of all regions in the game
regionsList = {
		"acadia",
		"afghanistan",
		"ahmadnagar",
		"algiers",
		"algonquin_territory",
		"alsace",
		"anatolia",
		"arkhangelsk",
		"armenia",
		"astrakhan",
		"austria",
		"azerbaijan",
		"bahamas",
		"baluchistan",
		"bashkira",
		"bavaria",
		"belarus",
		"bengal",
		"berar",
		"bijapur",
		"bohemia",
		"bosnia",
		"bulgaria",
		"carnatica",
		"carolinas",
		"ceylon",
		"chechenya-dagestan",
		"cherokee_territory",
		"corsica",
		"courland",
		"crimea",
		"croatia",
		"cuba",
		"curacao",
		"denmark",
		"don_voisko",
		"dutch_guyana",
		"egypt",
		"england",
		"estonia_and_livonia",
		"finland",
		"flanders",
		"florida",
		"france",
		"french_guyana",
		"galicia",
		"genoa",
		"georgia_usa",
		"georgia",
		"gibraltar",
		"great_plains",
		"greece",
		"guatemala",
		"gujarat",
		"hannover",
		"hindustan",
		"hispaniola",
		"hungary",
		"huron_territory",
		"hyderabad",
		"iceland",
		"ingria",
		"ireland",
		"iroquois_territory",
		"jamaica",
		"kaintuck_territory",
		"karelia",
		"kashmir",
		"komi",
		"labrador",
		"leeward_islands",
		"lithuania",
		"lower_louisiana",
		"maine",
		"malabar",
		"malta",
		"malwa",
		"maryland",
		"mesopotamia",
		"michigan_territory",
		"milan",
		"moldavia",
		"morea",
		"morocco",
		"muscovy",
		"mysore",
		"naples",
		"netherlands",
		"new_andalusia",
		"new_england",
		"new_france",
		"new_grenada",
		"new_mexico",
		"new_spain",
		"new_york",
		"newfoundland",
		"northwest_territories",
		"norway",
		"ontario",
		"orissa",
		"palestine",
		"panama",
		"pennsylvania",
		"persia",
		"poland",
		"portugal",
		"prussia",
		"punjab",
		"rajpootana",
		"rhineland",
		"rumelia",
		"ruperts_land",
		"sardinia",
		"savoy",
		"saxony",
		"scotland",
		"serbia",
		"silesia",
		"sindh",
		"spain",
		"sweden",
		"syria",
		"tatariya",
		"tejas",
		"the_papal_states",
		"transylvania",
		"trinidad_tobago",
		"tripoli",
		"tunis",
		"ukraine",
		"upper_louisiana",
		"venice",
		"virginia",
		"west_pommerania",
		"west_prussia",
		"windward_islands",
		"wurttemberg"
}

-- table of region->settlement name		
regionToSettlementList = {
		["acadia"]="settlement:acadia:fort_nashwaak",
		["afghanistan"]="settlement:afghanistan:kabul",
		["ahmadnagar"]="settlement:ahmadnagar:ahmadnagar",
		["algiers"]="settlement:algiers:algiers",
		["algonquin_territory"]="settlement:algonquin_territory:niagara",
		["alsace"]="settlement:alsace:strasbourg",
		["anatolia"]="settlement:anatolia:angora",
		["arkhangelsk"]="settlement:arkhangelsk:arkhangelsk",
		["armenia"]="settlement:armenia:yerevan",
		["astrakhan"]="settlement:astrakhan:astrakhan",
		["austria"]="settlement:austria:vienna",
		["azerbaijan"]="settlement:azerbaijan:ardabil",
		["bahamas"]="settlement:bahamas:nassau",
		["baluchistan"]="settlement:baluchistan:zahedan",
		["bashkira"]="settlement:bashkira:ufa",
		["bavaria"]="settlement:bavaria:munich",
		["belarus"]="settlement:belarus:minsk",
		["bengal"]="settlement:bengal:calcutta",
		["berar"]="settlement:berar:nagpur",
		["bijapur"]="settlement:bijapur:satara",
		["bohemia"]="settlement:bohemia:prague",
		["bosnia"]="settlement:bosnia:sarajevo",
		["bulgaria"]="settlement:bulgaria:sofia",
		["carnatica"]="settlement:carnatica:arcot",
		["carolinas"]="settlement:carolinas:charleston",
		["ceylon"]="settlement:ceylon:trincomalee",
		["chechenya-dagestan"]="settlement:chechenya-dagestan:tarki",
		["cherokee_territory"]="settlement:cherokee_territory:tellico",
		["corsica"]="settlement:corsica:bastia",
		["courland"]="settlement:courland:jelgava",
		["crimea"]="settlement:crimea:bakhchisaray",
		["croatia"]="settlement:croatia:zagreb",
		["cuba"]="settlement:cuba:la_habana",
		["curacao"]="settlement:curacao:punda",
		["denmark"]="settlement:denmark:copenhagen",
		["don_voisko"]="settlement:don_voisko:cherkassk",
		["dutch_guyana"]="settlement:dutch_guyana:paramaribo",
		["egypt"]="settlement:egypt:cairo",
		["england"]="settlement:england:london",
		["estonia_and_livonia"]="settlement:estonia_and_livonia:riga",
		["finland"]="settlement:finland:aabo",
		["flanders"]="settlement:flanders:brussels",
		["florida"]="settlement:florida:st_augustine",
		["france"]="settlement:france:paris",
		["french_guyana"]="settlement:french_guyana:cayenne",
		["galicia"]="settlement:galicia:lwow",
		["genoa"]="settlement:genoa:genoa",
		["georgia"]="settlement:georgia:tbilisi",
		["georgia_usa"]="settlement:georgia_usa:savannah",
		["gibraltar"]="settlement:gibraltar:gibraltar",
		["great_plains"]="settlement:great_plains:knife_river_village",
		["greece"]="settlement:greece:athens",
		["guatemala"]="settlement:guatemala:antigua_guatemala",
		["gujarat"]="settlement:gujarat:ahmedabad",
		["hannover"]="settlement:hannover:hannover",
		["hindustan"]="settlement:hindustan:agra",
		["hispaniola"]="settlement:hispaniola:santo_domingo",
		["hungary"]="settlement:hungary:pressburg",
		["huron_territory"]="settlement:huron_territory:fort_sault_ste-marie",
		["hyderabad"]="settlement:hyderabad:hyderabad",
		["iceland"]="settlement:iceland:reykjavik",
		["ingria"]="settlement:ingria:st_petersburg",
		["ireland"]="settlement:ireland:dublin",
		["iroquois_territory"]="settlement:iroquois_territory:cayuga",
		["jamaica"]="settlement:jamaica:port_royal",
		["kaintuck_territory"]="settlement:kaintuck_territory:tanase",
		["karelia"]="settlement:karelia:petrovskaya_sloboda",
		["kashmir"]="settlement:kashmir:srinagar",
		["komi"]="settlement:komi:ust_sysolsk",
		["labrador"]="settlement:labrador:agvituk",
		["leeward_islands"]="settlement:leeward_islands:antigua",
		["lithuania"]="settlement:lithuania:vilnius",
		["lower_louisiana"]="settlement:lower_louisiana:new_orleans",
		["maine"]="settlement:maine:falmouth",
		["malabar"]="settlement:malabar:goa",
		["malta"]="settlement:malta:valletta",
		["malwa"]="settlement:malwa:ujjain",
		["maryland"]="settlement:maryland:annapolis",
		["mesopotamia"]="settlement:mesopotamia:baghdad",
		["michigan_territory"]="settlement:michigan_territory:detroit",
		["milan"]="settlement:milan:milano",
		["moldavia"]="settlement:moldavia:iasi",
		["morea"]="settlement:morea:patras",
		["morocco"]="settlement:morocco:tangier",
		["muscovy"]="settlement:muscovy:moscow",
		["mysore"]="settlement:mysore:mysore",
		["naples"]="settlement:naples:naples",
		["netherlands"]="settlement:netherlands:amsterdam",
		["new_andalusia"]="settlement:new_andalusia:caracas",
		["new_england"]="settlement:new_england:boston",
		["new_france"]="settlement:new_france:quebec",
		["new_grenada"]="settlement:new_grenada:bogota",
		["new_mexico"]="settlement:new_mexico:santa_fe",
		["new_spain"]="settlement:new_spain:mexico",
		["new_york"]="settlement:new_york:albany",
		["newfoundland"]="settlement:newfoundland:plaissance",
		["northwest_territories"]="settlement:northwest_territories:york_factory",
		["norway"]="settlement:norway:christiania",
		["ontario"]="settlement:ontario:montreal",
		["orissa"]="settlement:orissa:cuttack",
		["palestine"]="settlement:palestine:jerusalem",
		["panama"]="settlement:panama:panama",
		["pennsylvania"]="settlement:pennsylvania:philadelphia",
		["persia"]="settlement:persia:isfahan",
		["poland"]="settlement:poland:warsaw",
		["portugal"]="settlement:portugal:lisbon",
		["prussia"]="settlement:prussia:konigsberg",
		["punjab"]="settlement:punjab:lahore",
		["rajpootana"]="settlement:rajpootana:udaipur",
		["rhineland"]="settlement:rhineland:koln",
		["rumelia"]="settlement:rumelia:constantinople",
		["ruperts_land"]="settlement:ruperts_land:moose_factory",
		["sardinia"]="settlement:sardinia:caligari",
		["savoy"]="settlement:savoy:turin",
		["saxony"]="settlement:saxony:dresden",
		["scotland"]="settlement:scotland:edinburgh",
		["serbia"]="settlement:serbia:belgrade",
		["silesia"]="settlement:silesia:breslau",
		["sindh"]="settlement:sindh:neroon_kot",
		["spain"]="settlement:spain:madrid",
		["sweden"]="settlement:sweden:stockholm",
		["syria"]="settlement:syria:damascus",
		["tatariya"]="settlement:tatariya:kazan",
		["tejas"]="settlement:tejas:villa_de_bexar",
		["the_papal_states"]="settlement:the_papal_states:rome",
		["transylvania"]="settlement:transylvania:kolozsvar",
		["trinidad_tobago"]="settlement:trinidad_tobago:san_jose_de_oruna",
		["tripoli"]="settlement:tripoli:tripoli",
		["tunis"]="settlement:tunis:tunis",
		["ukraine"]="settlement:ukraine:kiev",
		["upper_louisiana"]="settlement:upper_louisiana:fort_chartres",
		["venice"]="settlement:venice:venice",
		["virginia"]="settlement:virginia:williamsburg",
		["west_pommerania"]="settlement:west_pommerania:berlin",
		["west_prussia"]="settlement:west_prussia:gdansk",
		["windward_islands"]="settlement:windward_islands:martinique",
		["wurttemberg"]="settlement:wurttemberg:stuttgart"
}


-- table of settlement->region name
settlementToRegionList = {
		["settlement:acadia:fort_nashwaak"]="acadia",
		["settlement:afghanistan:kabul"]="afghanistan",
		["settlement:ahmadnagar:ahmadnagar"]="ahmadnagar",
		["settlement:algiers:algiers"]="algiers",
		["settlement:algonquin_territory:niagara"]="algonquin_territory",
		["settlement:alsace:strasbourg"]="alsace",
		["settlement:anatolia:angora"]="anatolia",
		["settlement:arkhangelsk:arkhangelsk"]="arkhangelsk",
		["settlement:armenia:yerevan"]="armenia",
		["settlement:astrakhan:astrakhan"]="astrakhan",
		["settlement:austria:vienna"]="austria",
		["settlement:azerbaijan:ardabil"]="azerbaijan",
		["settlement:bahamas:nassau"]="bahamas",
		["settlement:baluchistan:zahedan"]="baluchistan",
		["settlement:bashkira:ufa"]="bashkira",
		["settlement:bavaria:munich"]="bavaria",
		["settlement:belarus:minsk"]="belarus",
		["settlement:bengal:calcutta"]="bengal",
		["settlement:berar:nagpur"]="berar",
		["settlement:bijapur:satara"]="bijapur",
		["settlement:bohemia:prague"]="bohemia",
		["settlement:bosnia:sarajevo"]="bosnia",
		["settlement:bulgaria:sofia"]="bulgaria",
		["settlement:carnatica:arcot"]="carnatica",
		["settlement:carolinas:charleston"]="carolinas",
		["settlement:ceylon:trincomalee"]="ceylon",
		["settlement:chechenya-dagestan:tarki"]="chechenya-dagestan",
		["settlement:cherokee_territory:tellico"]="cherokee_territory",
		["settlement:corsica:bastia"]="corsica",
		["settlement:courland:jelgava"]="courland",
		["settlement:crimea:bakhchisaray"]="crimea",
		["settlement:croatia:zagreb"]="croatia",
		["settlement:cuba:la_habana"]="cuba",
		["settlement:curacao:punda"]="curacao",
		["settlement:denmark:copenhagen"]="denmark",
		["settlement:don_voisko:cherkassk"]="don_voisko",
		["settlement:dutch_guyana:paramaribo"]="dutch_guyana",
		["settlement:egypt:cairo"]="egypt",
		["settlement:england:london"]="england",
		["settlement:estonia_and_livonia:riga"]="estonia_and_livonia",
		["settlement:finland:aabo"]="finland",
		["settlement:flanders:brussels"]="flanders",
		["settlement:florida:st_augustine"]="florida",
		["settlement:france:paris"]="france",
		["settlement:french_guyana:cayenne"]="french_guyana",
		["settlement:galicia:lwow"]="galicia",
		["settlement:genoa:genoa"]="genoa",
		["settlement:georgia:tbilisi"]="georgia",
		["settlement:georgia_usa:savannah"]="georgia_usa",
		["settlement:gibraltar:gibraltar"]="gibraltar",
		["settlement:great_plains:knife_river_village"]="great_plains",
		["settlement:greece:athens"]="greece",
		["settlement:guatemala:antigua_guatemala"]="guatemala",
		["settlement:gujarat:ahmedabad"]="gujarat",
		["settlement:hannover:hannover"]="hannover",
		["settlement:hindustan:agra"]="hindustan",
		["settlement:hispaniola:santo_domingo"]="hispaniola",
		["settlement:hungary:pressburg"]="hungary",
		["settlement:huron_territory:fort_sault_ste-marie"]="huron_territory",
		["settlement:hyderabad:hyderabad"]="hyderabad",
		["settlement:iceland:reykjavik"]="iceland",
		["settlement:ingria:st_petersburg"]="ingria",
		["settlement:ireland:dublin"]="ireland",
		["settlement:iroquois_territory:cayuga"]="iroquois_territory",
		["settlement:jamaica:port_royal"]="jamaica",
		["settlement:kaintuck_territory:tanase"]="kaintuck_territory",
		["settlement:karelia:petrovskaya_sloboda"]="karelia",
		["settlement:kashmir:srinagar"]="kashmir",
		["settlement:komi:ust_sysolsk"]="komi",
		["settlement:labrador:agvituk"]="labrador",
		["settlement:leeward_islands:antigua"]="leeward_islands",
		["settlement:lithuania:vilnius"]="lithuania",
		["settlement:lower_louisiana:new_orleans"]="lower_louisiana",
		["settlement:maine:falmouth"]="maine",
		["settlement:malabar:goa"]="malabar",
		["settlement:malta:valletta"]="malta",
		["settlement:malwa:ujjain"]="malwa",
		["settlement:maryland:annapolis"]="maryland",
		["settlement:mesopotamia:baghdad"]="mesopotamia",
		["settlement:michigan_territory:detroit"]="michigan_territory",
		["settlement:milan:milano"]="milan",
		["settlement:moldavia:iasi"]="moldavia",
		["settlement:morea:patras"]="morea",
		["settlement:morocco:tangier"]="morocco",
		["settlement:muscovy:moscow"]="muscovy",
		["settlement:mysore:mysore"]="mysore",
		["settlement:naples:naples"]="naples",
		["settlement:netherlands:amsterdam"]="netherlands",
		["settlement:new_andalusia:caracas"]="new_andalusia",
		["settlement:new_england:boston"]="new_england",
		["settlement:new_france:quebec"]="new_france",
		["settlement:new_grenada:bogota"]="new_grenada",
		["settlement:new_mexico:santa_fe"]="new_mexico",
		["settlement:new_spain:mexico"]="new_spain",
		["settlement:new_york:albany"]="new_york",
		["settlement:newfoundland:plaissance"]="newfoundland",
		["settlement:northwest_territories:york_factory"]="northwest_territories",
		["settlement:norway:christiania"]="norway",
		["settlement:ontario:montreal"]="ontario",
		["settlement:orissa:cuttack"]="orissa",
		["settlement:palestine:jerusalem"]="palestine",
		["settlement:panama:panama"]="panama",
		["settlement:pennsylvania:philadelphia"]="pennsylvania",
		["settlement:persia:isfahan"]="persia",
		["settlement:poland:warsaw"]="poland",
		["settlement:portugal:lisbon"]="portugal",
		["settlement:prussia:konigsberg"]="prussia",
		["settlement:punjab:lahore"]="punjab",
		["settlement:rajpootana:udaipur"]="rajpootana",
		["settlement:rhineland:koln"]="rhineland",
		["settlement:rumelia:constantinople"]="rumelia",
		["settlement:ruperts_land:moose_factory"]="ruperts_land",
		["settlement:sardinia:caligari"]="sardinia",
		["settlement:savoy:turin"]="savoy",
		["settlement:saxony:dresden"]="saxony",
		["settlement:scotland:edinburgh"]="scotland",
		["settlement:serbia:belgrade"]="serbia",
		["settlement:silesia:breslau"]="silesia",
		["settlement:sindh:neroon_kot"]="sindh",
		["settlement:spain:madrid"]="spain",
		["settlement:sweden:stockholm"]="sweden",
		["settlement:syria:damascus"]="syria",
		["settlement:tatariya:kazan"]="tatariya",
		["settlement:tejas:villa_de_bexar"]="tejas",
		["settlement:the_papal_states:rome"]="the_papal_states",
		["settlement:transylvania:kolozsvar"]="transylvania",
		["settlement:trinidad_tobago:san_jose_de_oruna"]="trinidad_tobago",
		["settlement:tripoli:tripoli"]="tripoli",
		["settlement:tunis:tunis"]="tunis",
		["settlement:ukraine:kiev"]="ukraine",
		["settlement:upper_louisiana:fort_chartres"]="upper_louisiana",
		["settlement:venice:venice"]="venice",
		["settlement:virginia:williamsburg"]="virginia",
		["settlement:west_pommerania:berlin"]="west_pommerania",
		["settlement:west_prussia:gdansk"]="west_prussia",
		["settlement:windward_islands:martinique"]="windward_islands",
		["settlement:wurttemberg:stuttgart"]="wurttemberg"
}

-- a list of the regions to their ID slots
regionToSlotList = {
		["acadia"]="silver:acadia:central",
		["afghanistan"]="sheep:afghanistan:north",
		["ahmadnagar"]="port:ahmadnagar:bombay",
		["algiers"]="port:algiers:oran",
		["algonquin_territory"]="fur:algonquin_territory:almostisland",
		["alsace"]="town:alsace:nancy",
		["anatolia"]="port:anatolia:antalya",
		["arkhangelsk"]="fur:arkhangelsk:far_north",
		["armenia"]="town:armenia:artvin",
		["astrakhan"]="wheat:astrakhan:volga",
		["austria"]="town:austria:salzburg",
		["azerbaijan"]="town:azerbaijan:tabriz",
		["bahamas"]="port:bahamas:grand_bahama",
		["baluchistan"]="sheep:baluchistan:south",
		["bashkira"]="fur:bashkira:urals",
		["bavaria"]="town:bavaria:coburg",
		["belarus"]="town:belarus:babruysk",
		["bengal"]="town:bengal:bhagalpur",
		["berar"]="rice:berar:raipur",
		["bijapur"]="town:bijapur:kolhapur",
		["bohemia"]="iron:bohemia:ostrau",
		["bosnia"]="port:bosnia:ragusa",
		["bulgaria"]="iron:bulgaria:southwest",
		["carnatica"]="town:carnatica:cochin",
		["carolinas"]="southern_usa:carolinas:coast",
		["ceylon"]="port:ceylon:colombo",
		["chechenya-dagestan"]="sheep:chechenya-dagestan:inland",
		["cherokee_territory"]="town:cherokee_territory:casseta",
		["corsica"]="wine:corsica:east",
		["courland"]="town:courland:kuldiga",
		["crimea"]="port:crimea:sevastopol",
		["croatia"]="town:croatia:split",
		["cuba"]="port:cuba:santiago_de_cuba",
		["curacao"]="port:curacao:otrobanda",
		["denmark"]="port:denmark:aarhus",
		["don_voisko"]="wheat:don_voisko:kanev",
		["dutch_guyana"]="port:dutch_guyana:demerara",
		["egypt"]="wheat:egypt:delta",
		["england"]="town:england:cambridge",
		["estonia_and_livonia"]="town:estonia_and_livonia:narva",
		["finland"]="town:finland:vasa",
		["flanders"]="town:flanders:ghent",
		["florida"]="caribbean:florida:south",
		["france"]="town:france:dijon",
		["french_guyana"]="port:french_guyana:sinnamary",
		["galicia"]="town:galicia:rzeszow",
		["genoa"]="port:genoa:imperia",
		["georgia"]="town:georgia:suhumkale",
		["georgia_usa"]="southern_usa:georgia_usa:central",
		["gibraltar"]="port:gibraltar:sandy_bay",
		["great_plains"]="corn:great_plains:central",
		["greece"]="port:greece:piraeus",
		["guatemala"]="silver:guatemala:central",
		["gujarat"]="port:gujarat:surat",
		["hannover"]="town:hannover:braunschweig",
		["hindustan"]="town:hindustan:benares",
		["hispaniola"]="port:hispaniola:port-de-paix",
		["hungary"]="wheat:hungary:central",
		["huron_territory"]="fur:huron_territory:north",
		["hyderabad"]="wheat:hyderabad:central",
		["iceland"]="port:iceland:akureyri",
		["ingria"]="port:ingria:staraya_ladoga",
		["ireland"]="port:ireland:akureyri",
		["ireland"]="port:ireland:waterford",
		["iroquois_territory"]="town:iroquois_territory:oneida",
		["jamaica"]="port:jamaica:kingston",
		["kaintuck_territory"]="town:kaintuck_territory:sycamore_shoals",
		["karelia"]="fur:karelia:south",
		["kashmir"]="sheep:kashmir:jammu",
		["komi"]="town:komi:perm",
		["labrador"]="fur:labrador:coastcentral",
		["leeward_islands"]="port:leeward_islands:guadeloupe",
		["lithuania"]="town:lithuania:gardinas",
		["lower_louisiana"]="caribbean:lower_louisiana:coast",
		["maine"]="iron:maine:north",
		["malabar"]="port:malabar:barcelor",
		["malta"]="port:malta:marsaxlokk",
		["malwa"]="india_highlands:malwa:west",
		["maryland"]="town:maryland:baltimore",
		["mesopotamia"]="town:mesopotamia:erbil",
		["michigan_territory"]="corn:michigan_territory:south",
		["milan"]="town:milan:cremona",
		["moldavia"]="iron:moldavia:carpatians",
		["morea"]="town:morea:corinth",
		["morocco"]="town:morocco:fes",
		["muscovy"]="town:muscovy:bryansk",
		["mysore"]="town:mysore:bangalore",
		["naples"]="town:naples:palermo",
		["netherlands"]="town:netherlands:utrecht",
		["new_andalusia"]="caribbean:new_andalusia:barinas",
		["new_england"]="port:new_england:plymouth",
		["new_france"]="port:new_france:tadoussac",
		["new_grenada"]="port:new_grenada:cartagena",
		["new_mexico"]="southern_usa:new_mexico:south",
		["new_spain"]="town:new_spain:guadalajara",
		["new_york"]="port:new_york:new_york",
		["newfoundland"]="port:newfoundland:st_johns",
		["northwest_territories"]="fur:northwest_territories:east",
		["norway"]="port:norway:bergen",
		["ontario"]="fur:ontario:ottawa_r",
		["orissa"]="town:orissa:sambalpur",
		["palestine"]="port:palestine:gaza",
		["panama"]="caribbean:panama:costa_rica",
		["pennsylvania"]="sheep:pennsylvania:scranton",
		["persia"]="town:persia:teheran",
		["poland"]="town:poland:cracow",
		["portugal"]="port:portugal:porto",
		["prussia"]="town:prussia:tannenberg",
		["punjab"]="town:punjab:kasur",
		["rajpootana"]="town:rajpootana:shahpura",
		["rhineland"]="town:rhineland:marburg",
		["rumelia"]="port:rumelia:thessaloniki",
		["ruperts_land"]="port:ruperts_land:fort_albany",
		["sardinia"]="silver:sardinia:iglesias",
		["savoy"]="port:savoy:niece",
		["saxony"]="town:saxony:leipzig",
		["scotland"]="port:scotland:glasgow",
		["serbia"]="silver:serbia:south",
		["silesia"]="town:silesia:gleiwitz",
		["sindh"]="rice:sindh:south",
		["spain"]="town:spain:sevilla",
		["sweden"]="town:sweden:uppsala",
		["syria"]="port:syria:beirut",
		["tatariya"]="fur:tatariya:kazan",
		["tejas"]="corn:tejas:south",
		["the_papal_states"]="town:the_papal_states:siena",
		["transylvania"]="iron:transylvania:south",
		["trinidad_tobago"]="port:trinidad_tobago:puerto_de_espana",
		["tripoli"]="port:tripoli:surt",
		["tunis"]="port:tunis:safaqis",
		["ukraine"]="town:ukraine:kharkov",
		["upper_louisiana"]="corn:upper_louisiana:south",
		["venice"]="town:venice:verona",
		["virginia"]="southern_usa:virginia:central",
		["west_pommerania"]="port:west_pommerania:rostock",
		["west_prussia"]="town:west_prussia:elblag",
		["windward_islands"]="port:windward_islands:barbados",
		["wurttemberg"]="town:wurttemberg:heidelberg"
}


-- a list of id slots to regions
slotToRegionList = {
		["silver:acadia:central"]="acadia",
		["sheep:afghanistan:north"]="afghanistan",
		["port:ahmadnagar:bombay"]="ahmadnagar",
		["port:algiers:oran"]="algiers",
		["fur:algonquin_territory:almostisland"]="algonquin_territory",
		["town:alsace:nancy"]="alsace",
		["port:anatolia:antalya"]="anatolia",
		["fur:arkhangelsk:far_north"]="arkhangelsk",
		["town:armenia:artvin"]="armenia",
		["wheat:astrakhan:volga"]="astrakhan",
		["town:austria:salzburg"]="austria",
		["town:azerbaijan:tabriz"]="azerbaijan",
		["port:bahamas:grand_bahama"]="bahamas",
		["sheep:baluchistan:south"]="baluchistan",
		["fur:bashkira:urals"]="bashkira",
		["town:bavaria:coburg"]="bavaria",
		["town:belarus:babruysk"]="belarus",
		["town:bengal:bhagalpur"]="bengal",
		["rice:berar:raipur"]="berar",
		["town:bijapur:kolhapur"]="bijapur",
		["iron:bohemia:ostrau"]="bohemia",
		["port:bosnia:ragusa"]="bosnia",
		["iron:bulgaria:southwest"]="bulgaria",
		["town:carnatica:cochin"]="carnatica",
		["southern_usa:carolinas:coast"]="carolinas",
		["port:ceylon:colombo"]="ceylon",
		["sheep:chechenya-dagestan:inland"]="chechenya-dagestan",
		["town:cherokee_territory:casseta"]="cherokee_territory",
		["wine:corsica:east"]="corsica",
		["town:courland:kuldiga"]="courland",
		["port:crimea:sevastopol"]="crimea",
		["town:croatia:split"]="croatia",
		["port:cuba:santiago_de_cuba"]="cuba",
		["port:curacao:otrobanda"]="curacao",
		["port:denmark:aarhus"]="denmark",
		["wheat:don_voisko:kanev"]="don_voisko",
		["port:dutch_guyana:demerara"]="dutch_guyana",
		["wheat:egypt:delta"]="egypt",
		["town:england:cambridge"]="england",
		["town:estonia_and_livonia:narva"]="estonia_and_livonia",
		["town:finland:vasa"]="finland",
		["town:flanders:ghent"]="flanders",
		["caribbean:florida:south"]="florida",
		["town:france:dijon"]="france",
		["port:french_guyana:sinnamary"]="french_guyana",
		["town:galicia:rzeszow"]="galicia",
		["port:genoa:imperia"]="genoa",
		["town:georgia:suhumkale"]="georgia",
		["southern_usa:georgia_usa:central"]="georgia_usa",
		["port:gibraltar:sandy_bay"]="gibraltar",
		["corn:great_plains:central"]="great_plains",
		["port:greece:piraeus"]="greece",
		["silver:guatemala:central"]="guatemala",
		["port:gujarat:surat"]="gujarat",
		["town:hannover:braunschweig"]="hannover",
		["town:hindustan:benares"]="hindustan",
		["port:hispaniola:port-de-paix"]="hispaniola",
		["wheat:hungary:central"]="hungary",
		["fur:huron_territory:north"]="huron_territory",
		["wheat:hyderabad:central"]="hyderabad",
		["port:iceland:akureyri"]="iceland",
		["port:ingria:staraya_ladoga"]="ingria",
		["port:ireland:akureyri"]="ireland",
		["port:ireland:waterford"]="ireland",
		["town:iroquois_territory:oneida"]="iroquois_territory",
		["port:jamaica:kingston"]="jamaica",
		["town:kaintuck_territory:sycamore_shoals"]="kaintuck_territory",
		["fur:karelia:south"]="karelia",
		["sheep:kashmir:jammu"]="kashmir",
		["town:komi:perm"]="komi",
		["fur:labrador:coastcentral"]="labrador",
		["port:leeward_islands:guadeloupe"]="leeward_islands",
		["town:lithuania:gardinas"]="lithuania",
		["caribbean:lower_louisiana:coast"]="lower_louisiana",
		["iron:maine:north"]="maine",
		["port:malabar:barcelor"]="malabar",
		["port:malta:marsaxlokk"]="malta",
		["india_highlands:malwa:west"]="malwa",
		["town:maryland:baltimore"]="maryland",
		["town:mesopotamia:erbil"]="mesopotamia",
		["corn:michigan_territory:south"]="michigan_territory",
		["town:milan:cremona"]="milan",
		["iron:moldavia:carpatians"]="moldavia",
		["town:morea:corinth"]="morea",
		["town:morocco:fes"]="morocco",
		["town:muscovy:bryansk"]="muscovy",
		["town:mysore:bangalore"]="mysore",
		["town:naples:palermo"]="naples",
		["town:netherlands:utrecht"]="netherlands",
		["caribbean:new_andalusia:barinas"]="new_andalusia",
		["port:new_england:plymouth"]="new_england",
		["port:new_france:tadoussac"]="new_france",
		["port:new_grenada:cartagena"]="new_grenada",
		["southern_usa:new_mexico:south"]="new_mexico",
		["town:new_spain:guadalajara"]="new_spain",
		["port:new_york:new_york"]="new_york",
		["port:newfoundland:st_johns"]="newfoundland",
		["fur:northwest_territories:east"]="northwest_territories",
		["port:norway:bergen"]="norway",
		["fur:ontario:ottawa_r"]="ontario",
		["town:orissa:sambalpur"]="orissa",
		["port:palestine:gaza"]="palestine",
		["caribbean:panama:costa_rica"]="panama",
		["sheep:pennsylvania:scranton"]="pennsylvania",
		["town:persia:teheran"]="persia",
		["town:poland:cracow"]="poland",
		["port:portugal:porto"]="portugal",
		["town:prussia:tannenberg"]="prussia",
		["town:punjab:kasur"]="punjab",
		["town:rajpootana:shahpura"]="rajpootana",
		["town:rhineland:marburg"]="rhineland",
		["port:rumelia:thessaloniki"]="rumelia",
		["port:ruperts_land:fort_albany"]="ruperts_land",
		["silver:sardinia:iglesias"]="sardinia",
		["port:savoy:niece"]="savoy",
		["town:saxony:leipzig"]="saxony",
		["port:scotland:glasgow"]="scotland",
		["silver:serbia:south"]="serbia",
		["town:silesia:gleiwitz"]="silesia",
		["rice:sindh:south"]="sindh",
		["town:spain:sevilla"]="spain",
		["town:sweden:uppsala"]="sweden",
		["port:syria:beirut"]="syria",
		["fur:tatariya:kazan"]="tatariya",
		["corn:tejas:south"]="tejas",
		["town:the_papal_states:siena"]="the_papal_states",
		["iron:transylvania:south"]="transylvania",
		["port:trinidad_tobago:puerto_de_espana"]="trinidad_tobago",
		["port:tripoli:surt"]="tripoli",
		["port:tunis:safaqis"]="tunis",
		["town:ukraine:kharkov"]="ukraine",
		["corn:upper_louisiana:south"]="upper_louisiana",
		["town:venice:verona"]="venice",
		["southern_usa:virginia:central"]="virginia",
		["port:west_pommerania:rostock"]="west_pommerania",
		["town:west_prussia:elblag"]="west_prussia",
		["port:windward_islands:barbados"]="windward_islands",
		["town:wurttemberg:heidelberg"]="wurttemberg"
}










