
---@class TextUIOptions
---@field position? 'right-center' | 'left-center' | 'top-center' | 'bottom-center';
---@field icon? string | {[1]: IconProp, [2]: string};
---@field iconColor? string;
---@field style? string | table;
---@field alignIcon? 'top' | 'center';

local isOpen = false
local currentText

local function hasInteract()
    return GetResourceState('lulu_interact') == 'started'
end

---@param text string
---@param options? TextUIOptions
function lib.showTextUI(text, options)
    if currentText == text then return end

    currentText = text

    if hasInteract() then
        local key = string.match(text, "%[([^%]]+)%]")
        local cleanText = text
        if key then
            local escapedKey = string.gsub(key, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
            cleanText = string.gsub(text, "%[" .. escapedKey .. "%]", "")
            cleanText = string.gsub(cleanText, "^%s*(.-)%s*$", "%1")
        else
            key = 'E'
        end

        local ok = pcall(function()
            exports['lulu_interact']:ShowTextUI({{ key = key, text = cleanText }})
        end)

        if ok then
            isOpen = true
            return
        end
    end

    options = options or {}
    options.position = options.position or 'right-center'
    options.text = text

    SendNUIMessage({
        action = 'textUi',
        data = options
    })

    isOpen = true
end

function lib.hideTextUI()
    if hasInteract() then
        pcall(function()
            exports['lulu_interact']:HideTextUI()
        end)
    end

    SendNUIMessage({
        action = 'textUiHide'
    })

    isOpen = false
    currentText = nil
end

---@return boolean, string | nil
function lib.isTextUIOpen()
    return isOpen, currentText
end

