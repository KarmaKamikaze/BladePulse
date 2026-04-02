-- BladePulse_ui.lua

function BladePulse:CreateUI()
    BladePulseUI = CreateFrame("Frame", "BladePulseConfigFrame", UIParent)
    BladePulseUI:SetWidth(320)
    BladePulseUI:SetHeight(450)
    BladePulseUI:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    BladePulseUI:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    BladePulseUI:SetMovable(true)
    BladePulseUI:EnableMouse(true)
    BladePulseUI:RegisterForDrag("LeftButton")
    BladePulseUI:SetScript("OnDragStart", function() this:StartMoving() end)
    BladePulseUI:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    BladePulseUI:Hide()

    -- Title
    local title = BladePulseUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -7.5)
    title:SetText("BladePulse Settings")

    local header = BladePulseUI:CreateTexture(nil, "ARTWORK")
    header:SetHeight(40)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")

    -- Close Button (Top Right X)
    local close = CreateFrame("Button", nil, BladePulseUI, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", BladePulseUI, "TOPRIGHT", -5, -5)

    local desc = BladePulseUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("TOPLEFT", BladePulseUI, "TOPLEFT", 15, -40)
    desc:SetWidth(290)
    desc:SetJustifyH("LEFT")
    desc:SetJustifyV("TOP")
    desc:SetText("Configure which combat events trigger sounds. Enable or disable each effect and test them instantly.")

    -- Global Enable Checkbox
    local globalCheck = CreateFrame("CheckButton", nil, BladePulseUI, "UICheckButtonTemplate")
    globalCheck:SetPoint("TOPLEFT", BladePulseUI, "TOPLEFT", 15, -70)
    globalCheck:SetChecked(BladePulse_DB.globalEnabled)

    globalCheck:SetScript("OnClick", function()
        BladePulse_DB.globalEnabled = this:GetChecked()
    end)

    local globalText = BladePulseUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    globalText:SetPoint("LEFT", globalCheck, "RIGHT", 5, 0)
    globalText:SetText("Enable BladePulse")

    --------------------------------------------------
    -- Helper: Create Section
    --------------------------------------------------

    local function CreateSection(name, yOffset, dbKey, soundKey)
        local section = CreateFrame("Frame", nil, BladePulseUI)
        section:SetWidth(280)
        section:SetHeight(85)
        section:SetPoint("TOP", BladePulseUI, "TOP", 0, yOffset)
        section:SetBackdropColor(0.05, 0.05, 0.05, 0.8)

        local content = CreateFrame("Frame", nil, section)
        content:SetPoint("TOPLEFT", section, "TOPLEFT", 10, -10)
        content:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", -10, 10)

        -- Background Box
        section:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })

        section:SetBackdropColor(0, 0, 0, 0.6)

        -- Section Title
        local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetTextColor(1, 0.82, 0)
        label:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        label:SetText(name)

        -- Enable Checkbox
        local check = CreateFrame("CheckButton", nil, section, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", content, "TOPLEFT", -5, -20)
        check:SetChecked(BladePulse_DB and BladePulse_DB[dbKey .. "Enabled"])

        check:SetScript("OnClick", function()
            local btn = this
            BladePulse_DB[dbKey .. "Enabled"] = btn:GetChecked()
        end)

        local checkText = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        checkText:SetPoint("LEFT", check, "RIGHT", 5, 0)
        checkText:SetText("Enable")

        -- Test Button
        local testBtn = CreateFrame("Button", nil, section, "UIPanelButtonTemplate")
        testBtn:SetWidth(60)
        testBtn:SetHeight(20)
        testBtn:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
        testBtn:SetText("Test")

        testBtn:SetScript("OnClick", function()
            local sound = BladePulse_DB.sounds[soundKey]
            BladePulse:PlaySound(sound)
        end)
    end

    --------------------------------------------------
    -- Create Sections
    --------------------------------------------------

    CreateSection("Extra Attack", -110, "extraAttack", "extra_attack")
    CreateSection("Parry", -195, "parry", "parry")
    CreateSection("Glancing Blow", -280, "glancing", "glancing")
end


    --------------------------------------------------
    -- Create Minimap Button
    --------------------------------------------------

function BladePulse:CreateMinimapButton()
    local button = CreateFrame("Button", "BladePulseMinimapButton", Minimap)

    button:SetWidth(32)
    button:SetHeight(32)

    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Icon
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Sword_04")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Border
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(54)
    border:SetHeight(54)
    border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

    -- Positioning
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

    -- Dragging
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")

    button:SetScript("OnDragStart", function()
        this:StartMoving()
    end)

    button:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()

        local mx, my = Minimap:GetCenter()
        local bx, by = this:GetCenter()

        local angle = math.deg(math.atan2(by - my, bx - mx))
        BladePulse_DB.minimap.angle = angle

        BladePulse:UpdateMinimapPosition()
    end)

    -- Click behavior
    button:SetScript("OnClick", function()
        if BladePulseUI:IsShown() then
            BladePulseUI:Hide()
        else
            BladePulseUI:Show()
        end
    end)

    -- Tooltip
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("BladePulse")
        GameTooltip:AddLine("Click to open settings", 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    BladePulse.minimapButton = button

    BladePulse:UpdateMinimapPosition()
end


function BladePulse:UpdateMinimapPosition()
    local angle = BladePulse_DB.minimap.angle or 0

    local radius = 80
    local x = math.cos(math.rad(angle)) * radius
    local y = math.sin(math.rad(angle)) * radius

    BladePulse.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

--------------------------------------------------
-- Slash Command to Toggle UI
--------------------------------------------------

SLASH_BLADEPULSE1 = "/bp"
SlashCmdList["BLADEPULSE"] = function()
    if not BladePulseUI then
        print("BladePulse UI not loaded yet.")
        return
    end

    if BladePulseUI:IsShown() then
        BladePulseUI:Hide()
    else
        BladePulseUI:Show()
    end
end