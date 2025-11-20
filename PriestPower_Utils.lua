-- Utility Functions

function GetMaxRankSpellByName(spellName)
    local maxRank = 0;
    local maxRankSpellId = nil;
    local i = 1;

    while true do
        local spellNamei, spellRank = GetSpellName(i, BOOKTYPE_SPELL);
        if not spellNamei then
            break
        end

        if spellNamei == spellName then
            if spellRank then
                local rankNumberStr = string.sub(spellRank, 6);
                if rankNumberStr then
                    local rankNumber = tonumber(rankNumberStr);
                    if rankNumber and rankNumber > maxRank then
                        maxRank = rankNumber;
                        maxRankSpellId = i;
                    end
                end
            end
            if spellRank == '' then
                maxRankSpellId = i; 
            end
        end

        i = i + 1;
    end

    -- ChatFrame1:AddMessage("Max rank spell for " .. spellName .. ": " .. (maxRank or "none") .. " with ID: " .. (maxRankSpellId or "nil"))

    if maxRankSpellId then
        return maxRankSpellId
    end

    return nil;
end

-- Detects if a buff is present on the unit and returns the application number
function DetectBuff(unit, name, app)
    local i = 1;
    local state, apps;
    while true do
        state, apps = UnitBuff(unit, i);
        if not state then
            return false
        end
        if string.find(state, name) and ((app == apps) or (app == nil)) then
            return apps
        end
        i = i + 1;
    end
end

-- Detects if a debuff is present on the unit and returns the application number
function DetectDebuff(unit, name, app)
    local i = 1;
    local state, apps;
    while true do
        state, apps = UnitDebuff(unit, i);
        if not state then
            return false
        end
        if string.find(state, name) and ((app == apps) or (app == nil)) then
            return apps
        end
        i = i + 1;
    end
end
