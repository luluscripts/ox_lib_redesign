local inTrunk = false
local isKidnapped = false
local isKidnapping = false
local cam

local disabledTrunk = {
    [`penetrator`] = true, [`vacca`] = true, [`monroe`] = true, [`turismor`] = true,
    [`osiris`] = true, [`comet`] = true, [`ardent`] = true, [`jester`] = true,
    [`nero`] = true, [`nero2`] = true, [`vagner`] = true, [`infernus`] = true,
    [`zentorno`] = true, [`comet2`] = true, [`comet3`] = true, [`comet4`] = true,
    [`bullet`] = true,
}

local function notify(msg, type, duration)
    lib.notify({ description = msg, type = type or 'inform', duration = duration or 2500 })
end

local function GetPlate(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return '' end
    local plate = GetVehicleNumberPlateText(vehicle)
    return plate and string.gsub(plate, '%s+', '') or ''
end

local function GetClosestPlayer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestPlayer, closestDist = -1, -1
    for _, pid in ipairs(GetActivePlayers()) do
        if pid ~= PlayerId() then
            local dist = #(GetEntityCoords(GetPlayerPed(pid)) - coords)
            if closestDist == -1 or dist < closestDist then
                closestPlayer, closestDist = pid, dist
            end
        end
    end
    return closestPlayer, closestDist
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

local function getNearestVeh()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local target = GetOffsetFromEntityInWorldCoords(ped, 0.0, 20.0, 0.0)
    local ray = CastRayPointToPoint(pos.x, pos.y, pos.z, target.x, target.y, target.z, 10, ped, 0)
    local _, _, _, _, vehicle = GetRaycastResult(ray)
    return vehicle
end

local function TrunkCam(enable)
    if cam then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(cam, false)
        cam = nil
    end
    if not enable then return end
    local vehicle = GetEntityAttachedTo(PlayerPedId())
    if not vehicle or vehicle == 0 then return end
    local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.5, 0.0)
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(cam, true)
    SetCamCoord(cam, drawPos.x, drawPos.y, drawPos.z + 2.0)
    SetCamRot(cam, -2.5, 0.0, GetEntityHeading(vehicle), 0.0)
    RenderScriptCams(true, false, 0, true, true)
end

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

local function enterTrunk(vehicle, offset)
    local ped = PlayerPedId()
    loadAnim('fin_ext_p1-7')
    TaskPlayAnim(ped, 'fin_ext_p1-7', 'cs_devin_dual-7', 8.0, 8.0, -1, 1, 999.0, false, false, false)
    AttachEntityToEntity(ped, vehicle, 0, offset.x, offset.y, offset.z, 0.0, 0.0, 40.0, true, true, true, true, 1, true)
    inTrunk = true
    Wait(500)
    SetVehicleDoorShut(vehicle, 5, false)
    notify(Lang:t('success.entered_trunk'), 'success', 4000)
    TrunkCam(true)
end

local function canUseTrunk(vehicle)
    if not vehicle or vehicle == 0 then return false, 'no_vehicle' end
    if disabledTrunk[GetEntityModel(vehicle)] then return false, 'cant_enter' end
    local vehClass = GetVehicleClass(vehicle)
    if not Config.TrunkClasses[vehClass] or not Config.TrunkClasses[vehClass].allowed then return false, 'cant_enter' end
    return true
end

local function handleGetIn(vehicle, onKidnap)
    local ok, reason = canUseTrunk(vehicle)
    if not ok then
        notify(reason == 'no_vehicle' and Lang:t('error.no_vehicle_found') or Lang:t('error.cant_enter_trunk'), 'error')
        return
    end
    local plate = GetPlate(vehicle)
    local vehClass = GetVehicleClass(vehicle)

    lib.callback('qb-trunk:server:getTrunkBusy', false, function(isBusy)
        if inTrunk then notify(Lang:t('error.already_in_trunk'), 'error') return end
        if isBusy then notify(Lang:t('error.someone_in_trunk'), 'error') return end

        if onKidnap and isKidnapped then
            local attachedVeh = GetEntityAttachedTo(PlayerPedId())
            if GetVehicleDoorAngleRatio(attachedVeh, 5) <= 0 then
                notify(Lang:t('error.trunk_closed'), 'error') return
            end
            local ped = PlayerPedId()
            local coords = GetOffsetFromEntityInWorldCoords(attachedVeh, 0.0, -5.0, 0.0)
            DetachEntity(ped, true, true)
            ClearPedTasks(ped)
            inTrunk = false
            TriggerServerEvent('lustt-base:trunk:server:setTrunkBusy', GetPlate(attachedVeh), nil)
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
            SetEntityCollision(ped, true, true)
            TrunkCam(false)
            return
        end

        if GetVehicleDoorAngleRatio(vehicle, 5) <= 0 then
            notify(Lang:t('error.trunk_closed'), 'error') return
        end

        local classCfg = Config.TrunkClasses[vehClass]
        enterTrunk(vehicle, { x = classCfg.x, y = classCfg.y, z = classCfg.z })
        TriggerServerEvent('qb-trunk:server:setTrunkBusy', plate, true)
        if onKidnap then isKidnapped = true end
    end, plate)
end

RegisterNetEvent('qb-kidnapping:client:SetKidnapping', function(bool)
    isKidnapping = bool
end)

RegisterNetEvent('qb-trunk:client:KidnapTrunk', function()
    local closestPlayer, distance = GetClosestPlayer()
    if distance == -1 or distance >= 2 then return end
    if not isKidnapping then notify(Lang:t('error.not_kidnapped'), 'error') return end
    local vehicle = getNearestVeh()
    if vehicle == 0 then return end
    TriggerEvent('police:client:KidnapPlayer')
    TriggerServerEvent('police:server:CuffPlayer', GetPlayerServerId(closestPlayer), false)
    Wait(50)
    TriggerServerEvent('qb-trunk:server:KidnapTrunk', GetPlayerServerId(closestPlayer), vehicle)
end)

RegisterNetEvent('qb-trunk:client:KidnapGetIn', function(veh)
    handleGetIn(veh, true)
end)

RegisterNetEvent('qb-trunk:client:GetIn', function()
    handleGetIn(getNearestVeh(), false)
end)

RegisterNetEvent('lustt-radial:trunk:client:Door', function(plate, door, open)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh == 0 then return end
    if GetPlate(veh) ~= plate then return end
    if open then SetVehicleDoorOpen(veh, door, false, false)
    else SetVehicleDoorShut(veh, door, false) end
end)

RegisterNetEvent('lustt-radial:client:openDoor', function(data)
    local door = tonumber((data.id:gsub('door', '')))
    if not door then return end
    local ped = PlayerPedId()
    local currentVeh = GetVehiclePedIsIn(ped)
    local closestVehicle = currentVeh ~= 0 and currentVeh or getNearestVeh()
    if closestVehicle == 0 then notify(Lang:t('error.no_vehicle_found'), 'error') return end
    local plate = GetPlate(closestVehicle)
    local isDriverSeatOccupied = not IsVehicleSeatFree(closestVehicle, -1)
    local isDoorOpen = GetVehicleDoorAngleRatio(closestVehicle, door) > 0.0
    local remote = closestVehicle ~= currentVeh and isDriverSeatOccupied
    if remote then TriggerServerEvent('lustt-radial:trunk:server:Door', not isDoorOpen, plate, door)
    elseif isDoorOpen then SetVehicleDoorShut(closestVehicle, door, false)
    else SetVehicleDoorOpen(closestVehicle, door, false, false) end
end)

RegisterNetEvent('lustt-radial:client:ChangeSeat', function(data)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if veh == 0 then return end
    if not IsVehicleSeatFree(veh, data.id) then notify(Lang:t('error.seat_occupied'), 'error') return end
    if GetEntitySpeed(veh) * 3.6 > 100.0 then notify(Lang:t('error.vehicle_driving_fast'), 'error') return end
    SetPedIntoVehicle(ped, veh, data.id)
    notify(Lang:t('info.switched_seats', { seat = data.title }))
end)

RegisterNetEvent('lustt-radial:flipVehicle', function()
    if lib.progressBar({
        duration = Config.Fliptime,
        label = Lang:t('progress.flipping_car'),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
    }) then
        SetVehicleOnGroundProperly(getNearestVeh())
        StopAnimTask(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 1.0)
    else
        notify(Lang:t('task.cancel_task'), 'error')
        StopAnimTask(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 1.0)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if cam then
            sleep = 0
            local vehicle = GetEntityAttachedTo(PlayerPedId())
            if vehicle and vehicle ~= 0 then
                local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.5, 0.0)
                SetCamRot(cam, -2.5, 0.0, GetEntityHeading(vehicle), 0.0)
                SetCamCoord(cam, drawPos.x, drawPos.y, drawPos.z + 2.0)
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if inTrunk and not isKidnapped then
            local ped = PlayerPedId()
            local vehicle = GetEntityAttachedTo(ped)
            if DoesEntityExist(vehicle) then
                sleep = 0
                local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
                local plate = GetPlate(vehicle)
                local doorOpen = GetVehicleDoorAngleRatio(vehicle, 5) > 0
                local driverIn = not IsVehicleSeatFree(vehicle, -1)
                DrawText3Ds(drawPos.x, drawPos.y, drawPos.z + 0.75, Lang:t('general.get_out_trunk_button'))
                DrawText3Ds(drawPos.x, drawPos.y, drawPos.z + 0.5, doorOpen and Lang:t('general.close_trunk_button') or Lang:t('general.open_trunk_button'))
                if IsControlJustPressed(0, 38) then
                    if not doorOpen then notify(Lang:t('error.trunk_closed'), 'error')
                    else
                        local coords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.0, 0.0)
                        DetachEntity(ped, true, true)
                        ClearPedTasks(ped)
                        inTrunk = false
                        TriggerServerEvent('qb-trunk:server:setTrunkBusy', plate, false)
                        SetEntityCoords(ped, coords.x, coords.y, coords.z)
                        SetEntityCollision(ped, true, true)
                        TrunkCam(false)
                    end
                    Wait(100)
                end
                if IsControlJustPressed(0, 47) then
                    if driverIn then TriggerServerEvent('lustt-radial:trunk:server:Door', not doorOpen, plate, 5)
                    elseif doorOpen then SetVehicleDoorShut(vehicle, 5, false)
                    else SetVehicleDoorOpen(vehicle, 5, false, false) end
                    Wait(100)
                end
            end
        end
        Wait(sleep)
    end
end)
