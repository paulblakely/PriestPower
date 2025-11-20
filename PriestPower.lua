PriestPower = {}
local timeSinceLastUpdate = 0
local wasInGroup = false

function PriestPower_OnLoad()
    this:RegisterEvent("PLAYER_LOGIN")
    this:RegisterEvent("CHAT_MSG_ADDON")
    this:RegisterEvent("RAID_ROSTER_UPDATE")
    this:RegisterEvent("PARTY_MEMBERS_CHANGED")
    
    SlashCmdList["PRIESTPOWER"] = PriestPower_SlashCommand
    SLASH_PRIESTPOWER1 = "/prp"
    SLASH_PRIESTPOWER2 = "/priestpower"

    RefreshSpells()
    
    DEFAULT_CHAT_FRAME:AddMessage("PriestPower Loaded. Type /prp to open.")
end

function PriestPower_OnEvent(event)
    if event == "PLAYER_LOGIN" then
        PriestPower_ScanRaid()
        if GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 then
            wasInGroup = true
            PriestPower_RequestSend()
        end
    elseif event == "CHAT_MSG_ADDON" and arg1 == PP_PREFIX then
        PriestPower_HandleMessage(arg2, arg4) -- msg, sender
    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        PriestPower_ScanRaid()
        
        local isInGroup = (GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0)
        if isInGroup and not wasInGroup then
            PriestPower_RequestSend()
        end
        wasInGroup = isInGroup
        
        PriestPower_UpdateUI()
        PriestPower_UpdateStatusFrame()
    end
end

function PriestPower_OnUpdate(elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate > UPDATE_INTERVAL then
        PriestPower_UpdateStatusFrame()
        timeSinceLastUpdate = 0
    end
end

function PriestPower_SlashCommand(msg)
    msg = tostring(msg or "")
    if string.lower(msg) == "print" then
        local channel = "SAY"
        local numRaid = tonumber(GetNumRaidMembers()) or 0
        local numParty = tonumber(GetNumPartyMembers()) or 0
        
        if numRaid > 0 then
            channel = "RAID"
        elseif numParty > 0 then
            channel = "PARTY"
        else
            channel = nil -- Print locally
        end

        local hasAssignments = false
        local output = "PriestPower Assignments:"
        
        if type(PriestPower_Assignments) ~= "table" then
            PriestPower_Assignments = {}
        end
        
        -- Sort priests for consistent output
        local sortedPriests = {}
        for priest, _ in pairs(PriestPower_Assignments) do
            table.insert(sortedPriests, priest)
        end
        
        -- Safe sort handling mixed types
        table.sort(sortedPriests, function(a, b) 
            return tostring(a) < tostring(b) 
        end)

        -- Check if we have any assignments first
        for _, priest in ipairs(sortedPriests) do
            local assignment = PriestPower_Assignments[priest]
            if type(assignment) == "table" and (assignment.Champion or assignment.Buff) then
                hasAssignments = true
                break
            end
        end

        if hasAssignments and channel then
             SendChatMessage("PriestPower Assignments:", channel)
        end

        for _, priest in ipairs(sortedPriests) do
            local assignment = PriestPower_Assignments[priest]
            if type(assignment) == "table" and (assignment.Champion or assignment.Buff) then
                local line = tostring(priest) .. ": "
                if assignment.Champion then
                    line = line .. tostring(assignment.Champion)
                else
                    line = line .. "No Champion"
                end
                
                if assignment.Buff and BUFFS[assignment.Buff] then
                    line = line .. " (" .. tostring(BUFFS[assignment.Buff].name) .. ")"
                end
                
                if channel then
                    SendChatMessage(line, channel)
                else
                    output = output .. "\n" .. line
                end
            end
        end

        if not hasAssignments then
            if channel then
                SendChatMessage("PriestPower: No assignments set.", channel)
            else
                DEFAULT_CHAT_FRAME:AddMessage("PriestPower: No assignments set.")
            end
        elseif not channel then
            DEFAULT_CHAT_FRAME:AddMessage(output)
        end
    elseif PriestPowerFrame:IsVisible() then
        PriestPowerFrame:Hide()
    else
        PriestPower_ScanRaid() -- Ensure we have the latest roster
        PriestPowerFrame:Show()
        PriestPower_UpdateUI()
    end
end