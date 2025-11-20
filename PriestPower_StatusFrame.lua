-- Status Frame Logic

function PriestPower_UpdateStatusFrame()
    local statusFrame = getglobal("PriestPowerStatusFrame")
    
    -- Hide if not in group/raid
    if GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then
        statusFrame:Hide()
        return
    end

    local myName = UnitName("player")
    local assignment = PriestPower_Assignments[myName]
    local statusTexture = getglobal("PriestPowerStatusFrameStatusTexture")
    local statusText = getglobal("PriestPowerStatusFrameText")
    local iconTexture = getglobal("PriestPowerStatusFrameIconTexture")
    
    if not assignment or not assignment.Champion or assignment.Champion == "" then
        statusFrame:Hide()
        return
    end
    
    statusFrame:Show()
    statusText:SetText(assignment.Champion)
    
    -- Update Icon
    if assignment.Buff and BUFFS[assignment.Buff] then
        iconTexture:SetTexture(BUFFS[assignment.Buff].icon)
    else
        iconTexture:SetTexture(CHAMPION.icon) -- Default icon
    end
    
    -- Check buffs
    local championName = assignment.Champion
    local assignedBuffKey = assignment.Buff
    
    -- Find the champion unit
    local unitID = nil
    if UnitName("target") == championName then
        unitID = "target"
    else
        for i = 1, GetNumRaidMembers() do
            local name, _, _, _, _ = GetRaidRosterInfo(i)
            if name == championName then
                unitID = "raid"..i
                break
            end
        end
        if not unitID then
            for i = 1, GetNumPartyMembers() do
                if UnitName("party"..i) == championName then
                    unitID = "party"..i
                    break
                end
            end
        end
        if not unitID and UnitName("player") == championName then
            unitID = "player"
        end
    end
    
    if not unitID or not UnitExists(unitID) then
        -- Target not found (out of range or offline)
        statusTexture:SetTexture(0.5, 0.5, 0.5, 1.0) -- Grey
        return
    end
    
    local hasProclaim = DetectBuff(unitID, CHAMPION.icon)
    local hasAssignedBuff = false
    if assignedBuffKey and BUFFS[assignedBuffKey] then
        hasAssignedBuff = DetectBuff(unitID, BUFFS[assignedBuffKey].icon)
    end

    if hasProclaim and (not assignedBuffKey or hasAssignedBuff) then
        statusTexture:SetTexture(0, 1, 0, 1.0) -- Green: Championed, and has the correct buff or no buff is needed
    elseif hasProclaim and not hasAssignedBuff then
        statusTexture:SetTexture(1, 1, 0, 1.0) -- Yellow: Championed, but missing the assigned buff
    else
        statusTexture:SetTexture(1, 0, 0, 1.0) -- Red: Not championed
    end
end

function PriestPower_StatusFrame_OnClick()
    local myName = UnitName("player")
    local assignment = PriestPower_Assignments[myName]
    
    if not assignment or not assignment.Champion then
        DEFAULT_CHAT_FRAME:AddMessage("PriestPower: No champion assigned.")
        return
    end
    
    local championName = assignment.Champion
    local assignedBuffKey = assignment.Buff
    
    -- Find the champion unit
    local unitID = nil
    if UnitName("target") == championName then
        unitID = "target"
    else
        for i = 1, GetNumRaidMembers() do
            local name, _, _, _, _ = GetRaidRosterInfo(i)
            if name == championName then
                unitID = "raid"..i
                break
            end
        end
        if not unitID then
            for i = 1, GetNumPartyMembers() do
                if UnitName("party"..i) == championName then
                    unitID = "party"..i
                    break
                end
            end
        end
        if not unitID and UnitName("player") == championName then
            unitID = "player"
        end
    end

    
    if not unitID or not UnitExists(unitID) then
        DEFAULT_CHAT_FRAME:AddMessage("PriestPower: Could not find " .. championName .. " in your party or raid.")
        return
    end

    

    if (not DetectBuff(unitID, CHAMPION.icon)) then
        ChatFrame1:AddMessage("PriestPower: Champion not buffed. Casting " .. CHAMPION.name)
        Cast(CHAMPION.spell)
        SpellTargetUnit(unitID)
    elseif assignedBuffKey and BUFFS[assignedBuffKey] then
        local buffData = BUFFS[assignedBuffKey]
        if (not DetectBuff(unitID, buffData.icon)) then
            ChatFrame1:AddMessage("PriestPower: Buff not buffed. Casting " .. buffData.name)
            Cast(buffData.spell)
            SpellTargetUnit(unitID)
        end
    end
    
    SpellStopTargeting()
end
