function startPickAnimation()
    local animDict = "pickup_object"
    local animName = "pickup_low"


    ClearPedSecondaryTask(PlayerPedId())
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end
    local playerPed = PlayerPedId()

    TaskPlayAnim(playerPed, 1.0, -1, -1, 50, 0, 0, 0, 0)
    TaskPlayAnim(playerPed, animDict, animName, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
    Citizen.Wait(1000)
    ClearPedSecondaryTask(playerPed)
end

RegisterNetEvent('pv-cad:cient:use:evidence_marker', function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Marker Number",
        inputs = {
            {
                text = "Marker number (Min: 1; Max: " .. Config.Evidence.Markers.MaxNumber .. ")", -- text you want to be displayed as a place holder
                name = "ev-marker-number", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },

        },
    })

    if dialog ~= nil then
        local markerNum=tonumber(dialog['ev-marker-number']);
        if(markerNum > Config.Evidence.Markers.MaxNumber) then markerNum=Config.Evidence.Markers.MaxNumber; end
        if(markerNum < 1) then markerNum=1; end

        local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 0.5, GetEntityHeading(PlayerPedId())


        local modelHash = GetHashKey("ril" .. markerNum)

        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)

            while not HasModelLoaded(modelHash) do
                Citizen.Wait(1)
            end
        end

        startPickAnimation();
        local obj = CreateObject(modelHash, spawnCoords, true)
        PlaceObjectOnGroundProperly(obj);
        SetEntityHeading(obj,spawnHeading)
        SetEntityCollision(obj,true,true)
        local objCoords=GetEntityCoords(obj);
        SetEntityCoords(obj,objCoords.x,objCoords.y,objCoords.z-0.05,false,false,false,false);
        SetModelAsNoLongerNeeded("ril" .. markerNum)

        TriggerServerEvent("QBCore:Server:RemoveItem", 'evidence_marker', 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["evidence_marker"], "remove")

    end
end)

RegisterCommand("pickupmarker", function(source, args, rawCommand)
   local playerPos=GetEntityCoords(PlayerPedId());

    local dist=5.0;
    local obj=nil;

    for i=1,Config.Evidence.Markers.MaxNumber do
        local hash=GetHashKey("ril"..i)
        local o=GetClosestObjectOfType(playerPos.x,playerPos.y,playerPos.z, 2.5,hash,false,false,false);
        local opos=GetEntityCoords(o);

        if( #(opos - playerPos) < dist ) then
            dist = #(opos - playerPos);
            obj = o;
        end

    end

    if(obj ~= nil) then
        startPickAnimation();
        TriggerServerEvent("pv-cad:server:evidence:marker:delete", obj);
        TriggerServerEvent("QBCore:Server:AddItem", "evidence_marker", 1)
        TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["evidence_marker"], "add")
    end

end)

RegisterNetEvent('pv-cad:client:evidence:marker:delete', function(obj)
    DeleteObject(obj)
end)


