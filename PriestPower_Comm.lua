-- Communication Logic

function PriestPower_SendMessage(msg)
    -- ChatFrame1:AddMessage("PriestPower: Sending " .. msg)
    if GetNumRaidMembers() > 0 then
        SendAddonMessage(PP_PREFIX, msg, "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendAddonMessage(PP_PREFIX, msg, "PARTY")
    end
end

function PriestPower_RequestSend()
    PriestPower_SendMessage("REFRESH")
end

function PriestPower_SendSelf()
    local myName = UnitName("player")
    local assignment = PriestPower_Assignments[myName]
    local champion = "nil"
    local buff = "nil"
    
    if assignment then
        champion = assignment.Champion or "nil"
        buff = assignment.Buff or "nil"
    end
    
    PriestPower_SendMessage("SELF " .. champion .. " " .. buff)
end

function PriestPower_SendAssignment(priest, champion, buff)
    local c = champion or "nil"
    local b = buff or "nil"
    PriestPower_SendMessage("ASSIGN " .. priest .. " " .. c .. " " .. b)
end

function PriestPower_HandleMessage(msg, sender)
    -- ChatFrame1:AddMessage("PriestPower: Received " .. msg .. " from " .. sender)
    
    if msg == "REFRESH" then
        PriestPower_SendSelf()
        return
    end

    -- Try to parse SELF
    local _, _, champion, buff = string.find(msg, "^SELF (%S+) (%S+)")
    if champion then
        if champion == "nil" then champion = nil end
        if buff == "nil" then buff = nil end
        
        if not PriestPower_Assignments[sender] then
            PriestPower_Assignments[sender] = {}
        end
        PriestPower_Assignments[sender].Champion = champion
        PriestPower_Assignments[sender].Buff = buff
        
        PriestPower_UpdateUI()
        PriestPower_UpdateStatusFrame()
        return
    end

    -- Try to parse ASSIGN
    local _, _, priest, champion, buff = string.find(msg, "^ASSIGN (%S+) (%S+) (%S+)")
    if priest then
        if champion == "nil" then champion = nil end
        if buff == "nil" then buff = nil end
        
        if not PriestPower_Assignments[priest] then
            PriestPower_Assignments[priest] = {}
        end
        PriestPower_Assignments[priest].Champion = champion
        PriestPower_Assignments[priest].Buff = buff
        
        PriestPower_UpdateUI()
        PriestPower_UpdateStatusFrame()
        
        -- If I was the one assigned, echo my new state
        if priest == UnitName("player") then
            PriestPower_SendSelf()
        end
        return
    end
end
