local isAttached = false
local stretcherObject = nil
local isLayingOnBed = false
local detachKeys = { 157, 158, 160, 164, 165 }

local STRETCHER_MODEL = `prop_ld_binbag_01`
local ROT_ORDER = 2

local BED_DICT   = 'anim@gangops@morgue@table@'
local BED_ANIM   = 'ko_front'
local CARRY_DICT = 'anim@heists@box_carry@'
local CARRY_ANIM = 'idle'

local function notify(msg, type)
    lib.notify({ description = msg, type = type or 'inform' })
end

local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = #text / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

local function GetClosestPlayer()
    local coords = GetEntityCoords(PlayerPedId())
    local localPlayer = PlayerId()
    local closestPlayer, closestDistance = -1, -1
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= localPlayer then
            local dist = #(GetEntityCoords(GetPlayerPed(pid)) - coords)
            if closestDistance == -1 or dist < closestDistance then
                closestPlayer, closestDistance = pid, dist
            end
        end
    end
    return closestPlayer, closestDistance
end

local function alignStretcherUpright(obj, yaw)
    if not obj or obj == 0 or not DoesEntityExist(obj) then return end
    SetEntityRotation(obj, 0.0, 0.0, yaw, ROT_ORDER, true)
end

local function GetClosestStretcher()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, STRETCHER_MODEL, false, false, false)
    if obj ~= 0 then return obj end
    return nil
end

local function settleStretcherOnGround(obj, yaw)
    if not obj or obj == 0 or not DoesEntityExist(obj) then return end
    FreezeEntityPosition(obj, false)
    PlaceObjectOnGroundProperly(obj)
    alignStretcherUpright(obj, yaw)
end

local function doLayOnStretcher(obj, offsetZ)
    local ped = PlayerPedId()
    loadAnim(BED_DICT)
    if obj and DoesEntityExist(obj) and #(GetEntityCoords(ped) - GetEntityCoords(obj)) <= 3.0 then
        TaskPlayAnim(ped, BED_DICT, BED_ANIM, 8.0, 8.0, -1, 69, 1, false, false, false)
        AttachEntityToEntity(ped, obj, 0, 0.0, 0.0, offsetZ, 0.0, 0.0, 180.0, false, false, false, false, 2, true)
        isLayingOnBed = true
    end
end

local function LayOnStretcher()
    local obj = stretcherObject or GetClosestStretcher()
    if not obj then return end
    local player, distance = GetClosestPlayer()
    local netId = NetworkGetNetworkIdFromEntity(obj)
    if player == -1 then
        doLayOnStretcher(obj, 1.15)
    elseif distance < 2.0 then
        TriggerServerEvent('lustt-radial:Stretcher:BusyCheck', GetPlayerServerId(player), 'lay', netId)
    else
        doLayOnStretcher(obj, 1.15)
    end
end

local function getOffStretcher()
    local ped = PlayerPedId()
    local obj = stretcherObject or GetClosestStretcher()
    if obj then
        local coords = GetOffsetFromEntityInWorldCoords(obj, 0.85, 0.0, 0.0)
        DetachEntity(ped, false, true)
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
    else
        DetachEntity(ped, false, true)
    end
    ClearPedTasks(ped)
    isLayingOnBed = false
end

local function doAttachStretcher(offsetZ)
    local ped = PlayerPedId()
    NetworkRequestControlOfEntity(stretcherObject)
    loadAnim(CARRY_DICT)
    TaskPlayAnim(ped, CARRY_DICT, CARRY_ANIM, 8.0, 8.0, -1, 50, 0, false, false, false)
    SetTimeout(150, function()
        AttachEntityToEntity(stretcherObject, ped, GetPedBoneIndex(ped, 28422), 0.0, -1.35, -0.22, 0.0, 0.0, 0.0, true, true, false, true, 2, true)
    end)
    FreezeEntityPosition(stretcherObject, false)
end

local function attachToStretcher()
    if not stretcherObject then return end
    doAttachStretcher(-1.0)
end

local function detachStretcher()
    local obj = stretcherObject
    if not obj then return end
    DetachEntity(obj, false, true)
    ClearPedTasksImmediately(PlayerPedId())
    isAttached = false
    if obj and obj ~= 0 and DoesEntityExist(obj) then
        local heading = GetEntityHeading(PlayerPedId())
        settleStretcherOnGround(obj, heading)
        FreezeEntityPosition(obj, true)
    end
end

RegisterNetEvent('lustt-radial:client:TakeStretcher', function()
    local model = STRETCHER_MODEL
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, 0.0)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    if obj == 0 then notify(Lang:t('error.obj_not_found'), 'error') return end
    local heading = GetEntityHeading(ped)
    SetEntityHeading(obj, heading)
    settleStretcherOnGround(obj, heading)
    FreezeEntityPosition(obj, true)
    stretcherObject = obj
    SetTimeout(200, function()
        attachToStretcher()
        isAttached = true
    end)
end)

RegisterNetEvent('lustt-radial:client:RemoveStretcher', function()
    if not stretcherObject then return end
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, 0.0)
    local bCoords = GetEntityCoords(stretcherObject)
    if #(coords - bCoords) >= 3.0 then notify(Lang:t('error.far_away'), 'error') return end
    if DoesEntityExist(stretcherObject) then
        DeleteEntity(stretcherObject)
        ClearPedTasks(ped)
        DetachEntity(ped, false, true)
        TriggerServerEvent('lustt-radial:server:RemoveStretcher', coords, stretcherObject)
        isAttached = false
        stretcherObject = nil
        isLayingOnBed = false
    end
end)

RegisterNetEvent('lustt-radial:client:RemoveStretcherFromArea', function(playerPos, bObject)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local obj = stretcherObject or GetClosestStretcher()
    if pos == playerPos or not obj or obj ~= bObject then return end
    if #(pos - playerPos) >= 10 then return end
    if IsEntityPlayingAnim(ped, CARRY_DICT, CARRY_ANIM, false) then detachStretcher() end
    if IsEntityPlayingAnim(ped, BED_DICT, BED_ANIM, false) then
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0.85, 0.0, 0.0)
        ClearPedTasks(ped)
        DetachEntity(ped, false, true)
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
        isLayingOnBed = false
    end
end)

RegisterNetEvent('lustt-radial:Stretcher:client:BusyCheck', function(otherId, type, netId)
    local ped = PlayerPedId()
    local busy
    loadAnim(BED_DICT)
    busy = IsEntityPlayingAnim(ped, BED_DICT, BED_ANIM, 3)
    TriggerServerEvent('lustt-radial:server:BusyResult', busy, otherId, type, netId)
end)

RegisterNetEvent('lustt-radial:client:Result', function(isBusy, type, netId)
    if isBusy then
        notify(Lang:t('error.stretcher_in_use'), 'error')
        if type == 'lay' or type == 'sit' then isLayingOnBed = false else isAttached = false end
        return
    end
    local ped = PlayerPedId()
    local obj = stretcherObject
    if netId then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and DoesEntityExist(entity) then obj = entity end
    end
    if not obj then return end
    NetworkRequestControlOfEntity(obj)
    if type == 'lay' then
        doLayOnStretcher(obj, 1.15)
    else
        loadAnim(CARRY_DICT)
        TaskPlayAnim(ped, CARRY_DICT, CARRY_ANIM, 8.0, 8.0, -1, 50, 0, false, false, false)
        SetTimeout(150, function()
            AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), 0.0, -1.35, -0.22, 0.0, 0.0, 0.0, true, true, false, true, 2, true)
        end)
        FreezeEntityPosition(obj, false)
        isAttached = true
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if stretcherObject then
        detachStretcher()
        DeleteObject(stretcherObject)
        ClearPedTasksImmediately(PlayerPedId())
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        
        if isLayingOnBed then
            sleep = 0
            DrawText3Ds(pos.x, pos.y, pos.z + 0.2, "[G] - Ayağa Kalk")
            if IsControlJustPressed(0, 47) or IsDisabledControlJustPressed(0, 47) then
                getOffStretcher()
                sleep = 100
            end
        end

        local obj = stretcherObject or GetClosestStretcher()
        if obj and DoesEntityExist(obj) then
            local offsetCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.85, 0.0)
            local distance = #(pos - offsetCoords)
            if distance <= 1.0 then
                sleep = 0
                if isAttached then
                    DrawText3Ds(offsetCoords.x, offsetCoords.y, offsetCoords.z, Lang:t('general.stop_pushing_stretcher_button'))
                    if IsControlJustPressed(0, 51) then detachStretcher() isAttached = false sleep = 100 end
                elseif obj == stretcherObject then -- Only the creator can push and see push prompt
                    DrawText3Ds(offsetCoords.x, offsetCoords.y, offsetCoords.z, Lang:t('general.push_stretcher_button'))
                    if IsControlJustPressed(0, 51) then attachToStretcher() isAttached = true sleep = 100
                    elseif IsControlJustPressed(0, 74) then FreezeEntityPosition(obj, true) sleep = 100 end
                end
                
                -- Lay prompt is visible to everyone
                if not isLayingOnBed and not isAttached then
                    DrawText3Ds(offsetCoords.x, offsetCoords.y, offsetCoords.z + 0.2, "[G] - Sedyeye Yatır/Yat")
                    if IsControlJustPressed(0, 47) or IsDisabledControlJustPressed(0, 47) then LayOnStretcher() sleep = 100 end
                end
            elseif distance <= 2.0 then
                sleep = 0
                if not isLayingOnBed then
                    if obj == stretcherObject then -- Only show push position to creator
                        DrawText3Ds(offsetCoords.x, offsetCoords.y, offsetCoords.z, Lang:t('general.push_position_drawtext'))
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isAttached then
            sleep = 0
            local ped = PlayerPedId()
            if IsControlJustPressed(0, 73) or IsDisabledControlJustPressed(0, 73) then
                if stretcherObject and DoesEntityExist(stretcherObject) then
                    local coords = GetEntityCoords(stretcherObject)
                    DeleteEntity(stretcherObject)
                    ClearPedTasks(ped)
                    DetachEntity(ped, false, true)
                    TriggerServerEvent('lustt-radial:server:RemoveStretcher', coords, stretcherObject)
                    isAttached = false
                    stretcherObject = nil
                    isLayingOnBed = false
                end
                sleep = 100
            end
            for i = 1, #detachKeys do
                if IsControlJustPressed(0, detachKeys[i]) or IsDisabledControlJustPressed(0, detachKeys[i]) then
                    detachStretcher()
                    sleep = 100
                    break
                end
            end
            if IsPedShooting(ped) or IsPlayerFreeAiming(PlayerId()) or IsPedInMeleeCombat(ped) or IsEntityDead(ped) or IsPedRagdoll(ped) then
                detachStretcher()
            end
        end
        Wait(sleep)
    end
end)
