module(..., package.seeall)


function CreateNewOutLog()
	local ErrorLog = io.open("data/WALI/Logs/out_log.txt","w")
	local DateAndTime = os.date("%H:%M.%S")
	ErrorLog:write("Log Created: "..DateAndTime)
	ErrorLog:close()
end


--Writes to the MACH log file
function UpdateOutLog(update_arg)
	local DateAndTime = os.date("%H:%M.%S")
	local U_Log = io.open("data/WALI/Logs/out_log.txt","a")
	if type(update_arg) ~= "nil" then
		U_Log:write("\n["..DateAndTime.."]\t\t"..tostring(update_arg))
	elseif type(update_arg) == "nil" then
		U_Log:write("\n["..DateAndTime.."]\t\tLogging error: input type nil")
	end
	U_Log:close()
end


function kostas(msg)
	UpdateOutLog("[kostas]"..tostring(msg))
end

function design(msg)
	UpdateOutLog("[design]"..tostring(msg))
end

function tom(msg)
	UpdateOutLog("[tom]"..tostring(msg))
end

function ting(msg)
	UpdateOutLog("[ting]"..tostring(msg))
end

function dylan(msg)
	UpdateOutLog("[dylan]"..tostring(msg))
end

function shane(msg)
	UpdateOutLog("[shane]"..tostring(msg))
end

