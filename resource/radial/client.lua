local jobRadialId = nil

local QBCore = nil
CreateThread(function()
    local state = GetResourceState('qb-core')
    if state == 'missing' then return end
    while GetResourceState('qb-core') ~= 'started' do Wait(0) end
    QBCore = exports['qb-core']:GetCoreObject()
end)

local function getPlayerJob()
    if not QBCore then return LocalPlayer.state.job end
    local ok, data = pcall(function() return QBCore.Functions.GetPlayerData() end)
    if ok and data and data.job then return data.job end
    return LocalPlayer.state.job
end

local function resolveJobInteractions(jobName)
    local data = Config.JobInteractions[jobName]
    if type(data) == 'string' then
        return Config.JobInteractions[data]
    end
    return data
end

local function buildOnSelect(item)
    local t, e = item.type, item.event
    if t == 'client'    then return function() TriggerEvent(e, item) end end
    if t == 'server'    then return function() TriggerServerEvent(e, item) end end
    if t == 'command'   then return function() ExecuteCommand(e) end end
    if t == 'qbcommand' then return function() TriggerServerEvent('QBCore:CallCommand', e, item) end end
end

local function registerSubItems(id, items)
    local converted = {}
    for _, item in ipairs(items) do
        local entry = { icon = item.icon, label = item.title }
        if item.items and #item.items > 0 then
            local subId = 'oxradial_' .. item.id
            registerSubItems(subId, item.items)
            entry.menu = subId
        else
            entry.keepOpen = (item.shouldClose == false)
            entry.onSelect = buildOnSelect(item)
        end
        converted[#converted + 1] = entry
    end
    lib.registerRadial({ id = id, items = converted })
end

local function addTopLevelItem(menuItem)
    if menuItem.items and #menuItem.items > 0 then
        local subId = 'oxradial_' .. menuItem.id .. '_sub'
        registerSubItems(subId, menuItem.items)
        lib.addRadialItem({
            id    = menuItem.id,
            icon  = menuItem.icon,
            label = menuItem.title,
            menu  = subId,
        })
    else
        lib.addRadialItem({
            id       = menuItem.id,
            icon     = menuItem.icon,
            label    = menuItem.title,
            keepOpen = (menuItem.shouldClose == false),
            onSelect = buildOnSelect(menuItem),
        })
    end
end

local function setupStaticItems()
    for _, item in ipairs(Config.MenuItems) do
        addTopLevelItem(item)
    end
end

local function removeJobItem()
    if jobRadialId then
        lib.removeRadialItem(jobRadialId)
        jobRadialId = nil
    end
end

local function setupJobItem()
    removeJobItem()
end

RegisterNetEvent('sairon-police:lusttbabapro', function()
    lib.registerContext({
        id = 'sairon_police_objects',
        title = 'Polis Obje Menüsü',
        options = {
            { title = 'Bariyer',        description = 'Bir Bariyer Spawnla',        icon = 'shield-halved',        event = 'police:client:spawnBarrier'  },
            { title = 'Trafik Levhası', description = 'Bir Trafik Levhası Spawnla', icon = 'road-barrier',         event = 'police:client:spawnRoadSign' },
            { title = 'Işık',           description = 'Bir Işık Spawnla',           icon = 'lightbulb',            event = 'police:client:spawnLight'    },
            { title = 'Koni',           description = 'Bir Koni Spawnla',           icon = 'triangle-exclamation', event = 'police:client:spawnCone'     },
            { title = 'Objeyi Sil',     description = 'En Yakındaki Objeyi Yok Et', icon = 'trash',                event = 'police:client:deleteObject'  },
        },
    })
    lib.showContext('sairon_police_objects')
end)

RegisterNetEvent('lustt:sairon',  function() exports['lustt-dispatch']:OfficerDown()   end)
RegisterNetEvent('lustt:sairon2', function() exports['lustt-dispatch']:OfficerBackup() end)


CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(500) end

    setupStaticItems()
    setupJobItem()

    local serverId = GetPlayerServerId(PlayerId())

    AddStateBagChangeHandler('job', ('player:%s'):format(serverId), function()
        Wait(150)
        setupJobItem()
    end)

    AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(serverId), function(_, _, value)
        if not value then removeJobItem() end
    end)
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(1000) end

    local lastJobName, lastOnDuty

    while true do
        Wait(2000)

        if not LocalPlayer.state.isLoggedIn then
            lastJobName, lastOnDuty = nil, nil
            removeJobItem()
        else
            local job = getPlayerJob()
            local jobName  = job and job.name
            local onDuty   = job and job.onduty

            if jobName ~= lastJobName or onDuty ~= lastOnDuty then
                lastJobName = jobName
                lastOnDuty  = onDuty
                setupJobItem()
            end
        end
    end
end)
