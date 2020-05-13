local ZkyTargetBar = LibStub("AceAddon-3.0"):NewAddon("ZkyTargetBar", "AceConsole-3.0", "AceEvent-3.0")

local count = {}

function ZkyTargetBar:OnInitialize()
    ZkyTargetBar:SetupOptions()
    
    ZkyTargetBar.NextTime = 0
    ZkyTargetBar.MainFrame = CreateFrame("Frame", "ZkyTargetBarUI", UIParent);
    
    ZkyTargetBar.MainFrame:ClearAllPoints()
    if ZkyTargetBar.db.profile.position ~= nil then
        ZkyTargetBar.MainFrame:SetPoint("BOTTOMLEFT", ZkyTargetBar.db.profile.position.x, ZkyTargetBar.db.profile.position.y)
    else
        ZkyTargetBar.MainFrame:SetPoint("CENTER", UIParent)
    end
    
    ZkyTargetBar.MainFrame:EnableMouse(true)
    ZkyTargetBar.MainFrame:SetMovable(true)
    ZkyTargetBar.MainFrame:SetHeight(1)
    ZkyTargetBar.MainFrame:SetWidth(1)
    
    ZkyTargetBar.IconFrames = {}
	for i = 1, 8 do
		ZkyTargetBar.IconFrames[i] = ZkyTargetBar:CreateIconFrame(i, ZkyTargetBar.MainFrame)
	end
    
    ZkyTargetBar:DoLayout()
    ZkyTargetBar:CheckHide()
    ZkyTargetBar.MainFrame:SetScript("OnUpdate", ZkyTargetBar.OnUpdate)
    ZkyTargetBar:RegisterEvent("PLAYER_TARGET_CHANGED", ZkyTargetBar.Check)
    
    ZkyTargetBar.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    ZkyTargetBar.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    ZkyTargetBar.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function ZkyTargetBar:RefreshConfig()
    ZkyTargetBar:DoLayout()
    ZkyTargetBar:UpdateTextPosition()
    ZkyTargetBar:CheckHide()
end

function ZkyTargetBar:OnUpdate()
    local currentTime = GetTime()
    if currentTime < ZkyTargetBar.NextTime then
        return
    end
    ZkyTargetBar.NextTime = currentTime + 0.25
    
    ZkyTargetBar:Check()
    ZkyTargetBar:CheckHide()
end

function ZkyTargetBar:Check()
    ZkyTargetBar:CheckCount()
    ZkyTargetBar:CheckPlayerTarget()
end

function ZkyTargetBar:CheckCount()
    for i = 1, 8 do
        count[i] = 0
	end
    
    if ZkyTargetBar.db.profile.showInRaid and IsInRaid() then
        for i = 1, 40 do  
            ZkyTargetBar:CheckCountUnit("raid"..i)
        end
    elseif ZkyTargetBar.db.profile.showInParty and IsInGroup() then
        ZkyTargetBar:CheckCountUnit("player")
        for i = 1, 4 do  
            ZkyTargetBar:CheckCountUnit("party"..i)
        end
    elseif ZkyTargetBar.db.profile.showSolo then
        ZkyTargetBar:CheckCountUnit("player")
    end    
    
    for i = 1, 8 do
        ZkyTargetBar.IconFrames[i].Text:SetText(count[i])
	end
end

function ZkyTargetBar:CheckCountUnit(unit)
    if not UnitExists(unit) or not UnitExists(unit.."target") then
        return
    end
    
    for i = 1, 8 do
        if GetRaidTargetIndex(unit.."target") == i then
            count[i] = count[i] + 1
        end
	end
end

function ZkyTargetBar:CheckPlayerTarget()
    local size = 24 * ZkyTargetBar.db.profile.scale
    local playerTargetIconId = nil

    if (UnitExists('playertarget')) then
        -- print('UnitExists: ' .. 'true')
        local targetId = GetRaidTargetIndex("playertarget")
        if(targetId) then
            print('GetRaidTargetIndex: ' .. GetRaidTargetIndex("playertarget"))
        end
    end

    if UnitExists("playertarget") then
        playerTargetIconId = GetRaidTargetIndex("playertarget")
        if playerTargetIconId then
            ZkyTargetBar.IconFrames[playerTargetIconId].Texture:SetWidth(size / 2)
            ZkyTargetBar.IconFrames[playerTargetIconId].Texture:SetHeight(size / 2)
            ZkyTargetBar.IconFrames[playerTargetIconId]:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
                insets = {left = 4, right = 4, top = 4, bottom = 4},
            })
        end
    end
    
    for i = 1, 8 do
        if i ~= playerTargetIconId then
            ZkyTargetBar.IconFrames[i].Texture:SetWidth(size)
            ZkyTargetBar.IconFrames[i].Texture:SetHeight(size)
            ZkyTargetBar.IconFrames[i]:SetBackdrop(nil)
        end
        ZkyTargetBar.IconFrames[i].Text:SetText(count[i])
	end
end


function ZkyTargetBar:DoLayout()
    
    local x = 0
    local y = 0
    
    local nn = math.pow(2, (ZkyTargetBar.db.profile.layout or 3) % 4)
    
    local size = 24 * ZkyTargetBar.db.profile.scale or 1
                
    for i = 1, 8 do
		local iconFrame = ZkyTargetBar.IconFrames[i];
        iconFrame:SetWidth(size)
        iconFrame:SetHeight(size)
        iconFrame.Texture:SetWidth(size)
        iconFrame.Texture:SetHeight(size)
        
        iconFrame:SetPoint("CENTER", ZkyTargetBar.MainFrame, x, y)
        x = x - size
        if i % nn == 0 then
            x = 0
            y = y + size
        end
	end
end

function ZkyTargetBar:Target(iconId)

    for i = 1, 40 do
        if ZkyTargetBar:TargetByUnit("raid"..i, iconId) then
            return;
        end
    end
    
    for i = 1, 4 do
        if ZkyTargetBar:TargetByUnit("party"..i, iconId) then
            return;
        end
    end

    if ZkyTargetBar:TargetByUnit("player", iconId) then
        return;
    end
  
    if ZkyTargetBar.db.profile.playErrorSound then
        PlaySound(846)
    end
end

function ZkyTargetBar:TargetByUnit(unit, iconId)
        
    if UnitExists(unit) and GetRaidTargetIndex(unit) == iconId then
		ZkyTargetBar.IconFrames[iconId]:SetAttribute("macrotext", "/target " .. unit)
        return 1;
    end
            
    if UnitExists(unit.."target") and GetRaidTargetIndex(unit.."target") == iconId then
		ZkyTargetBar.IconFrames[iconId]:SetAttribute("macrotext", "/target " .. unit.."target")
        return 1;
    end
    
    return nil;
end


function ZkyTargetBar:CreateIconFrame(iconId)

    local iconFrame = CreateFrame("Button", "ZkyTargetBarButton" .. iconId, ZkyTargetBar.MainFrame, "SecureUnitButtonTemplate")

    iconFrame:SetPoint("CENTER", ZkyTargetBar.MainFrame)
    iconFrame:SetWidth(24)
    iconFrame:SetHeight(24)

    iconFrame.Texture = iconFrame:CreateTexture(nil, "OVERLAY")
    iconFrame.Texture:SetWidth(24)
    iconFrame.Texture:SetHeight(24)
    iconFrame.Texture:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    iconFrame.Texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")   
    SetRaidTargetIconTexture(iconFrame.Texture, iconId)
        
    iconFrame.Text = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    iconFrame.Text:SetPoint("TOP", iconFrame, "BOTTOM", ZkyTargetBar.db.profile.textPosition.x, ZkyTargetBar.db.profile.textPosition.y)
    if ZkyTargetBar.db.profile.hideText then
        iconFrame.Text:Hide();
    end
    
	iconFrame:SetMovable(true)
	iconFrame:SetUserPlaced(true)
	iconFrame:SetAttribute("type", "macro")
    iconFrame:RegisterForClicks("LeftButtonDown")
                
    iconFrame:SetScript("OnMouseDown", function(self)
        if not ZkyTargetBar.db.profile.locked then
            ZkyTargetBar.MainFrame:StartMoving()
        end
        if IsShiftKeyDown() then
            SetRaidTarget("target", iconId)
        else
            ZkyTargetBar:Target(iconId)
        end
    end)
    iconFrame:SetScript("OnMouseUp", function(self)
        ZkyTargetBar.MainFrame:StopMovingOrSizing()
        
        if not ZkyTargetBar.db.profile.position then
            ZkyTargetBar.db.profile.position = {}
        end
        ZkyTargetBar.db.profile.position.x = ZkyTargetBar.MainFrame:GetLeft()
        ZkyTargetBar.db.profile.position.y = ZkyTargetBar.MainFrame:GetBottom()
    end)

    return iconFrame;
end

function ZkyTargetBar:UpdateTextPosition()
    for i = 1, 8 do
		local iconFrame = ZkyTargetBar.IconFrames[i];
        if ZkyTargetBar.db.profile.hideText then
            iconFrame.Text:Hide();
        else
            iconFrame.Text:Show();
            iconFrame.Text:SetPoint("TOP", iconFrame, "BOTTOM", ZkyTargetBar.db.profile.textPosition.x, ZkyTargetBar.db.profile.textPosition.y)
        end
    end
end

function ZkyTargetBar:CheckHide()

    local show = false

    if IsInRaid() then
        show = ZkyTargetBar.db.profile.showInRaid
    elseif IsInGroup() then
        show = ZkyTargetBar.db.profile.showInParty
    else
        show = ZkyTargetBar.db.profile.showSolo
    end

    if show then
        ZkyTargetBar.MainFrame:Show();
    else
        ZkyTargetBar.MainFrame:Hide();
    end
end
