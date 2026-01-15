-- UI Logic

function PriestPower_UpdateUI()
    local scrollChild = getglobal("PriestPowerFrameScrollFrameScrollChild")
    local previousFrame = nil
    
    -- Close any open dropdowns to prevent stale data
    CloseDropDownMenus()
    
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
                
                -- Override the button script to open our custom frame
                local button = getglobal(frameName.."ChampionButton")
                if button then
                    -- Capture priestName locally for the closure
                    local pName = priestName 
                    button:SetScript("OnClick", function()
                        -- 'this' refers to the button
                        PriestPower_OpenSelectionMenu(this:GetParent(), pName)
                    end)
                end
            end
            championDropdown.priestName = priestName
            -- No initialization needed for custom frame approach
            
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

-- Legacy function removed

function PriestPower_SelectionButton_OnClick()
    local button = this
    local priestName = button.proposingPriest
    local selectedChampion = button.championName
    
    local currentBuff = nil
    if PriestPower_Assignments[priestName] then
        currentBuff = PriestPower_Assignments[priestName].Buff
    end
    
    PriestPower_SetAssignment(priestName, selectedChampion, currentBuff)
    
    -- Update the dropdown text immediately
    local frameIndex = 1
    while true do
        local frame = getglobal("PriestPowerRow"..frameIndex)
        if not frame then break end
        if frame.nameText:GetText() == priestName then
             UIDropDownMenu_SetText(selectedChampion or "Select Champion", frame.championDropdown)
             break
        end
        frameIndex = frameIndex + 1
    end
    
    PriestPowerSelectionFrame:Hide()
end

function PriestPower_OpenSelectionMenu(dropdownFrame, priestName)
    local frame = PriestPowerSelectionFrame
    local scrollChild = getglobal("PriestPowerSelectionFrameScrollFrameScrollChild")
    
    -- Clear existing buttons
    local i = 1
    while true do
        local btn = getglobal("PriestPowerSelectionButton"..i)
        if not btn then break end
        btn:Hide()
        i = i + 1
    end
    
    local function CreateOrGetButton(index, text, value)
        local btnName = "PriestPowerSelectionButton"..index
        local btn = getglobal(btnName)
        if not btn then
            btn = CreateFrame("Button", btnName, scrollChild)
            btn:SetWidth(150)
            btn:SetHeight(20)
            
            local fontString = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            fontString:SetPoint("LEFT", btn, "LEFT", 5, 0)
            btn:SetFontString(fontString)
            
            btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            btn:SetScript("OnClick", PriestPower_SelectionButton_OnClick)
        end
        
        btn:SetText(text)
        btn.proposingPriest = priestName
        btn.championName = value
        btn:Show()
        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -(index-1)*20)
        return btn
    end

    local btnIndex = 1
    
    -- Add "None" option
    CreateOrGetButton(btnIndex, "None", nil)
    btnIndex = btnIndex + 1
    
    local numRaid = GetNumRaidMembers()
    if numRaid > 0 then
        for i=1, numRaid do
            local name = GetRaidRosterInfo(i)
            if name ~= priestName then
                CreateOrGetButton(btnIndex, name, name)
                btnIndex = btnIndex + 1
            end
        end
    else
        if priestName ~= UnitName("player") then
            CreateOrGetButton(btnIndex, UnitName("player"), UnitName("player"))
            btnIndex = btnIndex + 1
        end
        local numParty = GetNumPartyMembers()
        for i=1, numParty do
            local name = UnitName("party"..i)
            if name ~= priestName then
                CreateOrGetButton(btnIndex, name, name)
                btnIndex = btnIndex + 1
            end
        end
    end
    
    -- Update ScrollChild height so scrolling actually happens
    scrollChild:SetHeight((btnIndex - 1) * 20)
    
    frame:Show()
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
