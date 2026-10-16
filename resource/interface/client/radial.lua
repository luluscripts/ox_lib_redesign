
---@class RadialItem
---@field icon string | {[1]: IconProp, [2]: string};
---@field label string
---@field menu? string
---@field onSelect? fun(currentMenu: string | nil, itemIndex: number) | string
---@field [string] any
---@field keepOpen? boolean
---@field iconWidth? number
---@field iconHeight? number

---@class RadialMenuItem: RadialItem
---@field id string

---@class RadialMenuProps
---@field id string
---@field items RadialItem[]
---@field [string] any

local isOpen = false

---@type table<string, RadialMenuProps>
local menus = {}

---@type RadialMenuItem[]
local menuItems = {}

local function nuiItems(items)
    local result = {}
    for i = 1, #items do
        local item = items[i]
        result[i] = {
            icon      = item.icon,
            label     = item.label,
            isMore    = item.isMore,
            menu      = item.menu,
            iconWidth = item.iconWidth,
            iconHeight= item.iconHeight,
        }
    end
    return result
end

---@type table<{id: string, option: string}>
local menuHistory = {}

---@type RadialMenuProps?
local currentRadial = nil

---@param id string?
---@param option number?
local function showRadial(id, option)
    local radial = id and menus[id]

    if id and not radial then
        return error('No radial menu with such id found.')
    end

    currentRadial = radial

    TriggerEvent('lustt-radial:open', nuiItems(radial and radial.items or menuItems), radial and true or nil, option)
end

local function refreshRadial(menuId)
    if not isOpen then return end

    if currentRadial and menuId then
        if menuId == currentRadial.id then
            return showRadial(menuId)
        else
            for i = 1, #menuHistory do
                local subMenu = menuHistory[i]

                if subMenu.id == menuId then
                    local parent = menus[subMenu.id]

                    for j = 1, #parent.items do
                        if parent.items[j].menu == currentRadial.id then
                            return
                        end
                    end

                    currentRadial = parent

                    for j = #menuHistory, i, -1 do
                        menuHistory[j] = nil
                    end

                    return showRadial(currentRadial.id)
                end
            end
        end

        return
    end

    table.wipe(menuHistory)
    showRadial()
end

---@param radial RadialMenuProps
function lib.registerRadial(radial)
    menus[radial.id] = radial
    radial.resource = GetInvokingResource()

    if currentRadial then
        refreshRadial(radial.id)
    end
end

function lib.getCurrentRadialId()
    return currentRadial and currentRadial.id
end

function lib.hideRadial()
    if not isOpen then return end

    TriggerEvent('lustt-radial:close')
    table.wipe(menuHistory)

    isOpen = false
    currentRadial = nil
end

---@param items RadialMenuItem | RadialMenuItem[]
function lib.addRadialItem(items)
    local menuSize = #menuItems
    local invokingResource = GetInvokingResource()

    items = table.type(items) == 'array' and items or { items }

    for i = 1, #items do
        local item = items[i]
        item.resource = invokingResource

        if menuSize == 0 then
            menuSize += 1
            menuItems[menuSize] = item
        else
            for j = 1, menuSize do
                if menuItems[j].id == item.id then
                    menuItems[j] = item
                    break
                end

                if j == menuSize then
                    menuSize += 1
                    menuItems[menuSize] = item
                end
            end
        end
    end

    if isOpen and not currentRadial then
        refreshRadial()
    end
end

---@param id string
function lib.removeRadialItem(id)
    local menuItem

    for i = 1, #menuItems do
        menuItem = menuItems[i]

        if menuItem.id == id then
            table.remove(menuItems, i)
            break
        end
    end

    if not isOpen then return end

    refreshRadial(id)
end

---@return boolean
function lib.isRadialOpen()
    return isOpen
end

function lib.clearRadialItems()
    table.wipe(menuItems)

    if isOpen and not currentRadial then
        refreshRadial()
    end
end

RegisterNUICallback('radialClick', function(index, cb)
    cb(1)

    local itemIndex = index + 1
    local item, currentMenu

    if currentRadial then
        item = currentRadial.items[itemIndex]
        currentMenu = currentRadial.id
    else
        item = menuItems[itemIndex]
    end

    local menuResource = currentRadial and currentRadial.resource or item.resource

    if item.menu then
        menuHistory[#menuHistory + 1] = { id = currentRadial and currentRadial.id, option = item.menu }
        showRadial(item.menu)
    elseif not item.keepOpen then
        lib.hideRadial()
    end

    local onSelect = item.onSelect

    if onSelect then
        if type(onSelect) == 'string' then
            return exports[menuResource][onSelect](0, currentMenu, itemIndex)
        end

        onSelect(currentMenu, itemIndex)
    end
end)

RegisterNUICallback('radialBack', function(_, cb)
    cb(1)

    local numHistory = #menuHistory
    local lastMenu = numHistory > 0 and menuHistory[numHistory]

    if not lastMenu then return end

    menuHistory[numHistory] = nil

    if lastMenu.id then
        return showRadial(lastMenu.id, lastMenu.option)
    end

    currentRadial = nil

    TriggerEvent('lustt-radial:open', nuiItems(menuItems), nil, lastMenu.option)
end)

RegisterNUICallback('radialClose', function(_, cb)
    cb(1)

    if not isOpen then return end

    lib.resetNuiFocus()

    isOpen = false
    currentRadial = nil
end)

RegisterNUICallback('radialTransition', function(_, cb)
    Wait(100)

    if not isOpen then return cb(false) end

    cb(true)
end)

local isDisabled = false

---@param state boolean
function lib.disableRadial(state)
    isDisabled = state

    if isOpen and state then
        return lib.hideRadial()
    end
end


exports('getRadialItems', function()
    return nuiItems(menuItems)
end)

exports('radialItemClicked', function(index)
    local itemIndex = index + 1
    local item, currentMenu

    if currentRadial then
        item = currentRadial.items[itemIndex]
        currentMenu = currentRadial.id
    else
        item = menuItems[itemIndex]
    end

    if not item then return end

    local menuResource = currentRadial and currentRadial.resource or item.resource

    if item.menu then
        menuHistory[#menuHistory + 1] = { id = currentRadial and currentRadial.id, option = item.menu }
        local radial = menus[item.menu]
        if radial then
            currentRadial = radial
            TriggerEvent('lustt-radial:open', nuiItems(radial.items), true, nil)
        end
    elseif not item.keepOpen then
        TriggerEvent('lustt-radial:close')
        isOpen = false
        lib.resetNuiFocus()
        currentRadial = nil
        table.wipe(menuHistory)
    end

    local onSelect = item.onSelect
    if onSelect then
        if type(onSelect) == 'string' then
            pcall(function()
                exports[menuResource][onSelect](0, currentMenu, itemIndex)
            end)
        else
            pcall(onSelect, currentMenu, itemIndex)
        end
    end
end)

exports('radialBackPressed', function()
    local numHistory = #menuHistory
    local lastMenu = numHistory > 0 and menuHistory[numHistory]

    if not lastMenu then
        currentRadial = nil
        TriggerEvent('lustt-radial:open', nuiItems(menuItems), false, nil)
        return
    end

    menuHistory[numHistory] = nil

    if lastMenu.id then
        local radial = menus[lastMenu.id]
        if radial then
            currentRadial = radial
            TriggerEvent('lustt-radial:open', nuiItems(radial.items), true, lastMenu.option)
        end
        return
    end

    currentRadial = nil
    TriggerEvent('lustt-radial:open', nuiItems(menuItems), false, lastMenu.option)
end)

exports('setRadialOpen', function(state)
    isOpen = state
    if not state then
        currentRadial = nil
        table.wipe(menuHistory)
    end
end)



AddEventHandler('onClientResourceStop', function(resource)
    for i = #menuItems, 1, -1 do
        local item = menuItems[i]

        if item.resource == resource then
            table.remove(menuItems, i)
        end
    end
end)
