function SwapPlayerByName( player1, player2 )
	local player1Group = 0
	local player2Group  = 0
	local player1ID = 0
	local player2ID = 0
	
	if( player1 == "%t" ) then
		player1 = GetUnitName("target")
	elseif( player2 == "%t" ) then 
		player2 = GetUnitName("target")
	end 
	
	for i=1, 40 do 
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if( name == player1 ) then 
			player1ID = i
			player1Group = subgroup
		elseif( name == player2 ) then 
			player2ID = i 
			player2Group = subgroup 
		end 
	end 
	if( player1Group == player2Group ) then 
		SendChatMessage( "Can't swap "..player1.." with "..player2.." because they are in the same group!!", "RAID", GetDefaultLanguage("player" ))
		return 
	end 
	
	if( player1Group == 0 or player2Group == 0 ) then 
		SendChatMessage( "Failed to Swap Players", "RAID", GetDefaultLanguage("player" ))
		return 
	end 
		
	SendChatMessage( "Swapping Players", "RAID", GetDefaultLanguage("player" ))
	SendChatMessage( player1.." -> Group #"..player2Group, "RAID", GetDefaultLanguage("player" ))
	SendChatMessage( player2.." -> Group #"..player1Group, "RAID", GetDefaultLanguage("player" ))
	SetRaidSubgroup( player1ID, 6 )
	SetRaidSubgroup( player2ID, 6 )
	SetRaidSubgroup( player1ID, player2Group )
	SetRaidSubgroup( player2ID, player1Group )
end 

function GetTargetGroup(target ) 
	for i=1, 40 do 
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if( name ==  target ) then 
			return subgroup 
		end 
	end 
	return 0
end 


function GiveMeShaman( group )
	local targetGroup = GetTargetGroup(GetUnitName("target"))
	local target = GetUnitName("target")
	local found = 0  
	local targetID = 0 
	local shammysOldGroup = 0 
	local groupCounts = {}
	for i=1,8 do 
		groupCounts[i] = 0 
	end 
	
	if( #group > 0  ) then 
		targetGroup = tonumber( group[1] )
	end 
	for i=1, 40 do 
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		groupCounts[subgroup] = groupCounts[subgroup] + 1 
	end 
	
	for i=1, 40 do 
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		groupCounts[subgroup] = groupCounts[subgroup] + 1 
		if( class == "Shaman" and not isDead and subgroup ~= targetGroup ) then 
			found = i 
			shammysOldGroup = subgroup 
		end 
		if( name == target ) then 
			targetID = i 
		end 
	end 
	if( targetGroup < 1 or targetGroup > 8 ) then 
		SendChatMessage( "Invalid Raid Group: "..targetGroup, "RAID", GetDefaultLanguage("player" ))
		return 
	end 
	
	if( groupCounts[targetGroup] >= 5 and #group > 0 ) then 
		SendChatMessage( "Raid Group #"..targetGroup.." is full", "RAID", GetDefaultLanguage("player" ))
		return 
	end 
	
	if( found == 0 ) then 
		SendChatMessage( "Could not find a shaman to put in Raid Group #"..targetGroup, "RAID", GetDefaultLanguage("player" ))
		return 
	end 
	if( #group == 0 ) then 
		SetRaidSubgroup( targetID, 7 )
	end 
	
	SetRaidSubgroup( found, targetGroup )
	
	if( #group == 0 ) then 
		SetRaidSubgroup( targetID, shammysOldGroup )
	end 
	
	if( #group == 0 ) then 
		SendChatMessage( "Giving a Shaman to Group #"..targetGroup.. " replacing "..target, "RAID", GetDefaultLanguage("player" ))
	else 
		SendChatMessage( "Giving a Shaman to Group #"..targetGroup, "RAID", GetDefaultLanguage("player" ))
	end 
	
end 


function SlashCmdList_AddSlashCommand(name, func, ...)
    SlashCmdList[name] = func
    local command = ''
    for i = 1, select('#', ...) do
        command = select(i, ...)
        if strsub(command, 1, 1) ~= '/' then
            command = '/' .. command
        end
        _G['SLASH_'..name..i] = command
    end
end

function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

function PutShaman( args )
	local newArgs = split( args, "%s" )
	GiveMeShaman( newArgs )
end 

function SlashRaidSwap( args ) 
	local newArgs = split( args, "%s" )
	SwapPlayerByName( newArgs[1], newArgs[2] )
end 

function MarkClass( args )
	local newArgs = split( args, "%s" )
	local currentShammy = 1
	if( #newArgs == 0 ) then 
		newArgs = {}
		newArgs[1] = "Shaman"
	end 
	for i=1, 40 do 
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
		if( string.lower(class) == string.lower(newArgs[1]) ) then 
			SetRaidTargetIcon("raid"..i, currentShammy)
			currentShammy = currentShammy + 1
		end 
	end 
end 

SlashCmdList_AddSlashCommand( "BEASTGUILD", SlashRaidSwap, "/raidswap" )
SlashCmdList_AddSlashCommand( "BEASTGUILD", PutShaman, "/putshaman" )
SlashCmdList_AddSlashCommand( "BEASTGUILD", MarkClass, "/markclass" )
