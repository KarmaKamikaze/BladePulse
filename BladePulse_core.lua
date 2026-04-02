-- BladePulse_core.lua

BladePulse = {}
BladePulse.frame = CreateFrame("Frame")

-- Default settings
local defaults = {
    globalEnabled = true,
    parryEnabled = true,
    glancingEnabled = true,
    extraAttackEnabled = true,
    sounds = {
        parry = "parry.mp3",
        glancing = "glancing.mp3",
        extra_attack = "extra_attack.mp3"
    },
    minimap = {
        angle = 0
    }
}


-- Utility: Deep copy defaults
local function CopyDefaults(src, dst)
    if type(src) ~= "table" then return {} end
    if type(dst) ~= "table" then dst = {} end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end

    return dst
end


-- Initialize SavedVariables
function BladePulse:InitializeDB()
    if not BladePulse_DB then
        BladePulse_DB = {}
    end

    BladePulse_DB = CopyDefaults(defaults, BladePulse_DB)
end

-- Play sound helper
function BladePulse:PlaySound(file)
    local path = "Interface\\AddOns\\BladePulse\\sounds\\" .. file
    PlaySoundFile(path)
end

-- Find text in combat log message (case-insensitive)
function BladePulse:MsgContains(msg, text)
    return string.find(string.lower(msg), string.lower(text), 1, true)
end


function BladePulse:OnEvent(event)
    if event == "VARIABLES_LOADED" then
        self:InitializeDB()
        self:CreateUI()
        self.CreateMinimapButton()
        return
    end

    if not BladePulse_DB.globalEnabled then return end

    local msg = arg1
    if not msg then return end

    -- DEBUG (enable this to inspect combat log)
    -- print("EVENT:", event, "MSG:", msg)

    -- =========================
    -- MELEE EVENTS
    -- =========================

    if event == "CHAT_MSG_COMBAT_SELF_HITS" or event == "CHAT_MSG_COMBAT_SELF_MISSES" then
        -- Parry detection
        if BladePulse_DB.parryEnabled and self:MsgContains(msg, "parries") then
            self:PlaySound(BladePulse_DB.sounds.parry)
            return
        end

        -- Glancing detection
        if BladePulse_DB.glancingEnabled and self:MsgContains(msg, "glancing") then
            self:PlaySound(BladePulse_DB.sounds.glancing)
            return
        end
    end


    -- =========================
    -- SPELL / PROC EVENTS
    -- =========================

    if event == "CHAT_MSG_SPELL_SELF_BUFF" then
        -- Extra attack detection
        if BladePulse_DB.extraAttackEnabled and self:MsgContains(msg, "extra attack") then
            self:PlaySound(BladePulse_DB.sounds.extra_attack)
            return
        end
    end

end

-- Crits
-- Flouish wumpwumpwumpwump spin around
-- crit > 2000: R2D2 whine sound (settable number)


BladePulse.frame:RegisterEvent("VARIABLES_LOADED")
BladePulse.frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
BladePulse.frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
BladePulse.frame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")

BladePulse.frame:SetScript("OnEvent", function()
    BladePulse:OnEvent(event)
end)