local progress
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local playerState = LocalPlayer.state

local pendingLuluStop
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= 'lulu_hud' then return end
    if pendingLuluStop then
        local resolve = pendingLuluStop
        pendingLuluStop = nil
        resolve()
    end
end)

local function luluProgressCall(exportName, data)
    while progress ~= nil do Wait(0) end
    progress = true
    playerState.invBusy = true

    local resolved = false
    local function resolveFalse()
        if resolved then return end
        resolved = true
        progress = nil
        playerState.invBusy = false
        if data._callback then data._callback(false) end
    end
    pendingLuluStop = resolveFalse

    local ok, result = pcall(function()
        return exports.lulu_hud:Progress(data)
    end)

    if pendingLuluStop == resolveFalse then pendingLuluStop = nil end

    if resolved then
        return false
    end

    if ok then
        resolved = true
        progress = nil
        playerState.invBusy = false
        if data._callback then data._callback(result) end
        return result
    end

    resolveFalse()
    return false
end

local function interruptProgress(data)
    if not data.useWhileDead and IsEntityDead(cache.ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(cache.ped) then return true end
    if not data.allowCuffed and IsPedCuffed(cache.ped) then return true end
    if not data.allowFalling and IsPedFalling(cache.ped) then return true end
    if not data.allowSwimming and IsPedSwimming(cache.ped) then return true end
end

local function buildProgressbarAction(data)
    local action = {
        name        = data.label or '',
        duration    = data.duration or 5000,
        label       = data.label or '',
        useWhileDead = data.useWhileDead or false,
        canCancel   = data.canCancel or false,
        disarm      = true,
        controlDisables = {
            disableMovement    = false,
            disableCarMovement = false,
            disableMouse       = false,
            disableCombat      = false,
        },
        animation = {
            animDict = nil,
            anim     = nil,
            flags    = 49,
            task     = nil,
        },
        prop    = { model = nil },
        propTwo = { model = nil },
    }

    local disable = data.disable
    if disable then
        action.controlDisables.disableMovement    = disable.move    or false
        action.controlDisables.disableCarMovement = disable.car     or false
        action.controlDisables.disableMouse       = disable.mouse   or false
        action.controlDisables.disableCombat      = disable.combat  or false
    end

    local anim = data.anim
    if anim then
        if anim.dict then
            action.animation.animDict = anim.dict
            action.animation.anim    = anim.clip
            action.animation.flags   = anim.flag or 49
        elseif anim.scenario then
            action.animation.task = anim.scenario
        end
    end

    local prop = data.prop
    if prop then
        if prop.model then
            action.prop = {
                model    = prop.model,
                bone     = prop.bone or 60309,
                coords   = prop.pos   or vec3(0, 0, 0),
                rotation = prop.rot   or vec3(0, 0, 0),
            }
        elseif type(prop) == 'table' and prop[1] then
            local p = prop[1]
            action.prop = {
                model    = p.model,
                bone     = p.bone or 60309,
                coords   = p.pos  or vec3(0, 0, 0),
                rotation = p.rot  or vec3(0, 0, 0),
            }
            if prop[2] then
                local p2 = prop[2]
                action.propTwo = {
                    model    = p2.model,
                    bone     = p2.bone or 60309,
                    coords   = p2.pos  or vec3(0, 0, 0),
                    rotation = p2.rot  or vec3(0, 0, 0),
                }
            end
        end
    end

    return action
end

function lib.progressBar(data)
    if GetResourceState('lulu_hud') == 'started' then
        return luluProgressCall('progressBar', data)
    end

    while progress ~= nil do Wait(0) end
    if interruptProgress(data) then return false end

    progress = true
    playerState.invBusy = true

    local finished = false
    local action = buildProgressbarAction(data)

    exports['progressbar']:Progress(action, function(cancelled)
        finished = true
        progress = nil
        playerState.invBusy = false
        if data._callback then
            data._callback(not cancelled)
        end
    end)

    local startTime = GetGameTimer()
    while not finished do Wait(0) end

    local elapsed = GetGameTimer() - startTime
    return elapsed >= data.duration
end

function lib.progressCircle(data)
    if GetResourceState('lulu_hud') == 'started' then
        return luluProgressCall('progressCircle', data)
    end
    return lib.progressBar(data)
end

function lib.cancelProgress()
    if GetResourceState('lulu_hud') == 'started' then
        local ok, result = pcall(function()
            exports.lulu_hud:CancelProgress()
            return true
        end)
        if ok then return result end
    end
    if not progress then
        error('No progress bar is active')
    end
    TriggerEvent('progressbar:client:cancel')
    progress = nil
end

function lib.progressActive()
    return progress ~= nil
end

RegisterNUICallback('progressComplete', function(data, cb)
    cb(1)
    progress = nil
end)
