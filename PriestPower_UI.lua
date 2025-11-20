-- UI Logic

function PriestPower_UpdateUI()
    local scrollChild = getglobal("PriestPowerFrameScrollFrameScrollChild")
    local previousFrame = nil
    
    -- Hide all existing rows first (simplified cleanup)
    local i = 1
    while true do
        local frame = getglobal("PriestPowerRow"..i)
        if not frame then break end
        frame:Hide()
        i = i + 1
    end

    -- Empty State
    local emptyStateMsg = getglobal("PriestPowerEmptyStateMsg")
    if not emptyStateMsg then
        emptyStateMsg = scrollChild:CreateFontString("PriestPowerEmptyStateMsg", "OVERLAY", "GameFontNormal")
        emptyStateMsg:SetPoint("TOP", scrollChild, "TOP", 0, -50)
        emptyStateMsg:SetWidth(400)
        emptyStateMsg:SetJustifyH("CENTER")
    end

    if table.getn(PriestPower_Roster) == 0 then
        emptyStateMsg:SetText("PriestPower can only be used in a group or raid.")
        emptyStateMsg:Show()
        return
    else
        emptyStateMsg:Hide()
    end
    
    for i, priestName in ipairs(PriestPower_Roster) do
        local frameName = "PriestPowerRow"..i
        local frame = getglobal(frameName)
        if not frame then
            frame = CreateFrame("Frame", frameName, scrollChild)
            frame:SetWidth(430)
            frame:SetHeight(30)
            
            -- Priest Name
            local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", frame, "LEFT", 5, 0)
            text:SetText(priestName)
            frame.nameText = text
            
            -- Champion Dropdown
            local championDropdown = getglobal(frameName.."Champion")
            if not championDropdown then
                championDropdown = CreateFrame("Frame", frameName.."Champion", frame, "UIDropDownMenuTemplate")
                championDropdown:SetPoint("LEFT", text, "RIGHT", -10, 0)
                UIDropDownMenu_SetWidth(120, championDropdown)
                frame.championDropdown = championDropdown
            end
            championDropdown.priestName = priestName
            UIDropDownMenu_Initialize(championDropdown, PriestPower_ChampionDropdown_Initialize)
            
            -- Buff Dropdown
            local buffDropdown = getglobal(frameName.."Buff")
            if not buffDropdown then
                buffDropdown = CreateFrame("Frame", frameName.."Buff", frame, "UIDropDownMenuTemplate")
                buffDropdown:SetPoint("LEFT", championDropdown, "RIGHT", -20, 0)
                UIDropDownMenu_SetWidth(120, buffDropdown)
                frame.buffDropdown = buffDropdown
            end
            buffDropdown.priestName = priestName
            UIDropDownMenu_Initialize(buffDropdown, PriestPower_BuffDropdown_Initialize)

            -- Buff Icon
            local buffIcon = getglobal(frameName.."BuffIcon")
            if not buffIcon then
                buffIcon = frame:CreateTexture(frameName.."BuffIcon", "ARTWORK")
                buffIcon:SetWidth(20)
                buffIcon:SetHeight(20)
                buffIcon:SetPoint("LEFT", buffDropdown, "RIGHT", 5, 0)
                frame.buffIcon = buffIcon
            end
        end
        
        frame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i-1)*30)
        frame:Show()
        
        -- Update values
        local assignment = PriestPower_Assignments[priestName]
        if assignment then
            UIDropDownMenu_SetText(assignment.Champion or "Select Champion", frame.championDropdown)
            if assignment.Buff and BUFFS[assignment.Buff] then
                local buffData = BUFFS[assignment.Buff]
                UIDropDownMenu_SetText(buffData.name, frame.buffDropdown)
                frame.buffIcon:SetTexture(buffData.icon)
                frame.buffIcon:Show()
            else
                UIDropDownMenu_SetText("Select Buff", frame.buffDropdown)
                frame.buffIcon:Hide()
            end
        else
            UIDropDownMenu_SetText("Select Champion", frame.championDropdown)
            UIDropDownMenu_SetText("Select Buff", frame.buffDropdown)
            frame.buffIcon:Hide()
        end
        
        previousFrame = frame
    end
end

function PriestPower_ChampionDropdown_OnClick(arg1, arg2)
    local currentBuff = nil
    if PriestPower_Assignments[arg1] then
        currentBuff = PriestPower_Assignments[arg1].Buff
    end
    PriestPower_SetAssignment(arg1, arg2, currentBuff)
    CloseDropDownMenus()
end

function PriestPower_ChampionDropdown_Initialize()
    local dropdown = getglobal(UIDROPDOWNMENU_INIT_MENU)
    local priestName = dropdown.priestName
    if not priestName then return end
    
    local info = {}
    info.func = PriestPower_ChampionDropdown_OnClick
    info.arg1 = priestName
    
    info.text = "None"
    info.arg2 = nil
    UIDropDownMenu_AddButton(info)
    
    local numRaid = GetNumRaidMembers()
    if numRaid > 0 then
        for i=1, numRaid do
            local name = GetRaidRosterInfo(i)
            if name ~= priestName then
                info.text = name
                info.arg2 = name
                UIDropDownMenu_AddButton(info)
            end
        end
    else
        if priestName ~= UnitName("player") then 
            info.text = UnitName("player")
            info.arg2 = UnitName("player")
            UIDropDownMenu_AddButton(info)
        end
        local numParty = GetNumPartyMembers()
        for i=1, numParty do
            local name = UnitName("party"..i)
            if name ~= priestName then
                info.text = name
                info.arg2 = name
                UIDropDownMenu_AddButton(info)
            end
        end
    end
end

function PriestPower_BuffDropdown_OnClick(arg1, arg2)
    local currentChampion = nil
    if PriestPower_Assignments[arg1] then
        currentChampion = PriestPower_Assignments[arg1].Champion
    end
    PriestPower_SetAssignment(arg1, currentChampion, arg2)
    PriestPower_UpdateUI()
end

function PriestPower_BuffDropdown_Initialize()
    local dropdown = getglobal(UIDROPDOWNMENU_INIT_MENU)
    local priestName = dropdown.priestName
    if not priestName then return end
    
    local info = {}
    info.func = PriestPower_BuffDropdown_OnClick
    info.arg1 = priestName
    
    info.text = "None"
    info.arg2 = nil
    UIDropDownMenu_AddButton(info)
    
    for _, buffKey in ipairs(BUFF_ORDER) do
        local buffData = BUFFS[buffKey]
        info.icon = buffData.icon
        info.text = buffData.name
        info.arg2 = buffData.id
        UIDropDownMenu_AddButton(info)
    end
end
