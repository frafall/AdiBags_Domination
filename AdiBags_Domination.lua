--[[
AdiBags_Domination - Adds domination socket filter to AdiBags.
Copyright 2021 Frafall (frafall@hotmail.com)

Originally by (Adibags_Legion):
Copyright 2016 Dia (mrdiablo@divine-pride.net)
All rights reserved.

Strings from: https://www.townlong-yak.com/framexml/live/GlobalStrings.lua

Github: https://github.com/frafall/AdiBags_Domination
Published on Curseforge: https://www.curseforge.com/wow/addons/adibags_domination
--]]
local _, ns = ...

local addon = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local L = setmetatable({}, {__index = addon.L})

local L_SOCKETS = "Domination Sockets"
local L_FILTER_DESC = "Group gear with domination sockets together."

local L_ENABLE_LABEL = "Enable visual group"
local L_TT_CATEGORY = "Check this if you want a section for domination sockets."

do -- Localization
    L[L_SOCKETS] = L_SOCKETS
    L[L_FILTER_DESC] = L_FILTER_DESC
    L[L_ENABLE_LABEL] = L_ENABLE_LABEL
    L[L_TT_CATEGORY] = L_TT_CATEGORY

    --[[
	local locale = GetLocale()
	if locale == "frFR" then
		L[L_TRANSMOG] = "Visuals"
	elseif locale == "deDE" then
		L[L_TRANSMOG] = "Visuals"
	elseif locale == 'ptBR' then
		L[L_TRANSMOG] = "Visuals"
	end
        --]]
end

-- The filter itself

local socketFilter = addon:RegisterFilter("DominationSocket", 95, "ABEvent-1.0")
socketFilter.uiName = L[L_SOCKETS]
socketFilter.uiDesc = L[L_FILTER_DESC]

function socketFilter:OnInitialize()
    self.db =
        addon.db:RegisterNamespace(
        "DominationSocket",
        {
            profile = {enableSockets = true},
            char = {}
        }
    )
end

local function unescape(String)
    local Result = tostring(String)
    Result = gsub(Result, "|c........", "")     -- Remove color start.
    Result = gsub(Result, "|r", "")             -- Remove color end.
    Result = gsub(Result, "|H.-|h(.-)|h", "%1") -- Remove links.
    Result = gsub(Result, "|T.-|t", "")         -- Remove textures.
    Result = gsub(Result, "{.-}", "")           -- Remove raid target icons.
    return Result
end

function socketFilter:Update()
    self:SendMessage("AdiBags_FiltersChanged")
end

function socketFilter:OnEnable()
    addon:UpdateFilters()
end

function socketFilter:OnDisable()
    addon:UpdateFilters()
end

local tip

function socketFilter:Filter(slotData)

    -- Is module active?
    if not self.db.profile.enableSockets then
        return
    end

    -- Setup tooltip
    tip = tip or CreateFrame("GameTooltip", "AdiDominationSocketTooltip", nil, "GameTooltipTemplate")
    tip:SetOwner(UIParent, "ANCHOR_NONE")

    -- Populate tooltip
    if slotData.bag == BANK_CONTAINER then
        tip:SetInventoryItem("player", BankButtonIDToInvSlotID(slotData.slot, nil))
    else
        tip:SetBagItem(slotData.bag, slotData.slot)
    end

    -- Is the item an equippable item
    local itemName = _G["AdiDominationSocketTooltipTextLeft1"]:GetText()

    if itemName and IsEquippableItem(itemName) and IsDressableItem(itemName) then

        -- Scan for "Domination Socket"
        for i = 2, tip:NumLines() do
            local t = unescape(_G["AdiDominationSocketTooltipTextLeft" .. i]:GetText())
            if t and string.find(t, EMPTY_SOCKET_DOMINATION) then   -- 
                return L[L_SOCKETS]
            end
        end
    end

    tip:Hide()
end

function socketFilter:GetOptions()
    return {
        enableSockets = {
            name = L[L_ENABLE_LABEL],
            desc = L[L_TT_CATEGORY],
            type = "toggle",
            order = 60
        }
    }, addon:GetOptionHandler(
        self,
        false,
        function()
            return self:Update()
        end
    )
end
