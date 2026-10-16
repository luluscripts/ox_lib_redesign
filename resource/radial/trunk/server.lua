local trunkBusy = {}

function IsCloseToTarget(source, target)
    if not DoesPlayerExist(target) then return false end
    return #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(target))) < 2.0
end

RegisterNetEvent('lustt-radial:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('lustt-radial:trunk:client:Door', -1, plate, door, open)
end)

RegisterNetEvent('qb-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

RegisterNetEvent('lustt-base:trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

RegisterNetEvent('qb-trunk:server:KidnapTrunk', function(target, closestVehicle)
    local source = source
    if not IsCloseToTarget(source, target) then return end
    TriggerClientEvent('qb-trunk:client:KidnapGetIn', target, closestVehicle)
end)

lib.callback.register('qb-trunk:server:getTrunkBusy', function(source, plate)
    return trunkBusy[plate] == true
end)

lib.addCommand('bagajagir', { help = Lang:t('general.getintrunk_command_desc') }, function(source)
    TriggerClientEvent('qb-trunk:client:GetIn', source)
end)

lib.addCommand('putintrunk', { help = Lang:t('general.putintrunk_command_desc') }, function(source)
    TriggerClientEvent('qb-trunk:server:KidnapTrunk', source)
end)
