QBCore.Functions.CreateUseableItem("evidence_marker", function(source,item)
    TriggerClientEvent('pv-cad:cient:use:evidence_marker',source,item);
end);

QBCore.Functions.CreateUseableItem("ptape_roll", function(source,item)
    local Player = QBCore.Functions.GetPlayer(source)
    if (Player.PlayerData.job.type == "leo" or Player.PlayerData.job.name == "ambulance") then
        TriggerClientEvent('pv-cad:client:evidence:tape:use',source,item,"police");
    else
        TriggerClientEvent('QBCore:Notify', source, "You are not an emergency agent.", "error")
    end

end);

QBCore.Functions.CreateUseableItem("ftape_roll", function(source,item)
    local Player = QBCore.Functions.GetPlayer(source)
    if (Player.PlayerData.job.type == "leo" or Player.PlayerData.job.name == "ambulance") then
        TriggerClientEvent('pv-cad:client:evidence:tape:use',source,item,"fire");
    else
        TriggerClientEvent('QBCore:Notify', source, "You are not an emergency agent.", "error")
    end

end);

RegisterNetEvent('pv-cad:server:evidence:marker:delete', function(obj)
    TriggerClientEvent('pv-cad:client:evidence:marker:delete', -1, obj);
end)
