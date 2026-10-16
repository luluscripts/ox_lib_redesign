RegisterNetEvent('lustt-radial:server:RemoveStretcher', function(pos, stretcherObject)
    TriggerClientEvent('lustt-radial:client:RemoveStretcherFromArea', -1, pos, stretcherObject)
end)

RegisterNetEvent('lustt-radial:Stretcher:BusyCheck', function(target, type, netId)
    local source = source
    TriggerClientEvent('lustt-radial:Stretcher:client:BusyCheck', target, source, type, netId)
end)

RegisterNetEvent('lustt-radial:server:BusyResult', function(isBusy, target, type, netId)
    local source = source
    TriggerClientEvent('lustt-radial:client:Result', target, isBusy, type, netId)
end)
