-- Roster Management

PriestPower_Roster = {}

function PriestPower_ScanRaid()
    PriestPower_Roster = {}
    local addedPriests = {}
    local numRaid = GetNumRaidMembers()    
    if numRaid > 0 then
        for i = 1, numRaid do
            local name, _, _, _, class = GetRaidRosterInfo(i)
            if (class == "PRIEST" or class == "Priest") and not addedPriests[name] then
                table.insert(PriestPower_Roster, name)
                addedPriests[name] = true
            end
        end
    else
        -- Party or Solo
        local numParty = GetNumPartyMembers()        
        
        -- Check self
        local _, class = UnitClass("player")
        if class == "PRIEST" then
            local playerName = UnitName("player")
            if not addedPriests[playerName] then
                table.insert(PriestPower_Roster, playerName)
                addedPriests[playerName] = true
            end
        end
        
        -- Check party
        if numParty > 0 then
            for i = 1, numParty do
                local _, partyClass = UnitClass("party"..i)
                if partyClass == "PRIEST" then
                    local partyMemberName = UnitName("party"..i)
                    if not addedPriests[partyMemberName] then
                        table.insert(PriestPower_Roster, partyMemberName)
                        addedPriests[partyMemberName] = true
                    end
                end
            end
        end
    end
    
    -- If not in group/raid, clear roster to enforce empty state
    if numRaid == 0 and GetNumPartyMembers() == 0 then
        PriestPower_Roster = {}
    end

    table.sort(PriestPower_Roster)

    -- Prune assignments for priests who are no longer in the group
    if PriestPower_Assignments then
        local rosterSet = {}
        for _, name in ipairs(PriestPower_Roster) do
            rosterSet[name] = true
        end
        
        for name, _ in pairs(PriestPower_Assignments) do
            if not rosterSet[name] then
                PriestPower_Assignments[name] = nil
            end
        end
    end
end
