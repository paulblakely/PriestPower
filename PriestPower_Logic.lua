-- Core Logic

PriestPower_Assignments = {} -- { PriestName = { Champion = "Name", Buff = "SpellID" } }
spellIds = {}

function RefreshSpells()    
    spellIds["Proclaim Champion"] = GetMaxRankSpellByName("Proclaim Champion")
    spellIds["Empower Champion"] = GetMaxRankSpellByName("Empower Champion")
    spellIds["Champion's Grace"] = GetMaxRankSpellByName("Champion's Grace")
    spellIds["Champion's Bond"] = GetMaxRankSpellByName("Champion's Bond")
end

function Cast(spellName)
    if not spellIds[spellName] then 
        local spell = GetMaxRankSpellByName(spellName)
        if spell then
            spellIds[spellName] = spell
        else
            ChatFrame1:AddMessage("Spell not found: " .. spellName)
            return 
        end
    end
    CastSpell(spellIds[spellName], BOOKTYPE_SPELL)
end

function PriestPower_SetAssignment(priest, champion, buff)
    if not PriestPower_Assignments[priest] then
        PriestPower_Assignments[priest] = {}
    end
    
    if champion == "" then champion = nil end
    if buff == "" then buff = nil end
    
    if champion then PriestPower_Assignments[priest].Champion = champion end
    if buff then PriestPower_Assignments[priest].Buff = buff end
    
    -- If setting to nil, we should clear the assignment in the table too
    if champion == nil then PriestPower_Assignments[priest].Champion = nil end
    if buff == nil then PriestPower_Assignments[priest].Buff = nil end
    
    -- Sync to raid
    PriestPower_SendAssignment(priest, PriestPower_Assignments[priest].Champion, PriestPower_Assignments[priest].Buff)
    
    PriestPower_UpdateUI()
    PriestPower_UpdateStatusFrame()
end
