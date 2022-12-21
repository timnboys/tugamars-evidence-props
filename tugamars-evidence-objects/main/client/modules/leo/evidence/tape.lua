TAPE = {
    objectName = "",
    object = nil,
    size = 1,
    editMode = false,
    coords = vector3(0,0,0),
    rotation = vector3(0,0,0),
    heading = nil,
    type = nil,
}

local function getObjectName(size,type)
    if(size > 14) then size=14; end
    if(size < 1) then size=1; end
    if(size <= 9) then size = "0"..size; end;

    if(type == nil) then type = TAPE.type; end

    return GetHashKey("prop_" .. type .. "_tape_"..size);
end

local function spawnObject(size,net)
    local modelHash = getObjectName(size)

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
    end

    local obj = CreateObject(modelHash, TAPE.coords, net)
    if(net == false) then TAPE.object=obj; end;
    SetEntityRotation(obj,TAPE.rotation)
    SetEntityHeading(obj,TAPE.heading)
    FreezeEntityPosition(obj,true)
    SetEntityCollision(obj,false,false);
    return obj;
end

local function changeRange(newSize)
    TAPE.size=newSize;
    if(TAPE.object ~= nil) then DeleteObject(TAPE.object); end
    spawnObject(newSize,false);
end

local function leaveEditMode()
    TAPE.editMode=false;
    if(TAPE.object ~= nil) then
        DeleteObject(TAPE.object);
        TAPE.object=nil;
    end
end

local function moveObject(x,y,z)
    TAPE.coords=vector3(TAPE.coords.x+x,TAPE.coords.y+y,TAPE.coords.z+z)
    SetEntityCoords(TAPE.object,TAPE.coords.x,TAPE.coords.y,TAPE.coords.z,false, false, false);
end

local function rotateObject(rotate)
    local rotat = GetEntityRotation(TAPE.object);

    TAPE.rotation = vector3(rotat.x+rotate,rotat.y+rotate,TAPE.heading);
    SetEntityRotation(TAPE.object, TAPE.rotation);

end

local function headObject(rotate)
    TAPE.heading = GetEntityHeading(TAPE.object) + rotate;
    SetEntityHeading(TAPE.object,TAPE.heading)
end

local function placeObject()
    object = nil;
    leaveEditMode();
    local obj=spawnObject(TAPE.size,true);
end

TAPEMenu = MenuV:CreateMenu(false, 'Object Placer', 'topright', 30, 164, 74, 'size-125', 'pv', 'menuv', 'tape_editor_namespace', 'native')

TAPErange = TAPEMenu:AddRange({ icon = '🧻', label = 'Range Item', min = 1, max = 14, value = 1, saveOnUpdate = true })

local closeBtn=TAPEMenu:AddButton({ icon = '✖️', label = "Edit Mode", disabled = false });

closeBtn:On('select', function(item)
    TAPE.editMode=true;
    MenuV:CloseMenu(TAPEMenu);
end)

local confirmBtn=TAPEMenu:AddButton({ icon = '✔️', label = "Place tape", disabled = false });

confirmBtn:On('select', function(item)
    placeObject();
    MenuV:CloseMenu(TAPEMenu);
end)

local cancelBtn=TAPEMenu:AddButton({ icon = '❌', label = "Delete & Stop", disabled = false });

TAPEMenu:On('close', function()
    if(TAPE.editMode == false) then
        leaveEditMode();
    end
end)

cancelBtn:On('select', function(item)
    leaveEditMode()
    MenuV:CloseMenu(TAPEMenu);
end)

TAPErange:On('select', function(item, value)
    changeRange(value);
end)

RegisterNetEvent('pv-cad:client:evidence:tape:use', function(item,type)
    TAPE.type=type;
    MenuV:OpenMenu(TAPEMenu);
    local spawnCoords = GetEntityCoords(PlayerPedId());

    TAPE.coords = vector3((spawnCoords.x + 0.5),(spawnCoords.y + 0.5), (spawnCoords.z + 0.5));
    local obj = spawnObject(TAPE.size,false);
    SetEntityAlpha(obj, 50, true);
end)

RegisterCommand("tape", function(source, args, rawCommand)
    if(TAPE.editMode) then
        TAPE.editMode=false;
        MenuV:OpenMenu(TAPEMenu);
    end
end, false)

RegisterCommand("tapemenu", function(source, args, rawCommand)
    if(TAPE.editMode) then
        TAPE.editMode=false;
        MenuV:OpenMenu(TAPEMenu);
    end
end, false)

RegisterCommand("pickuptape", function(source, args, rawCommand)
    local playerPos=GetEntityCoords(PlayerPedId());

    local dist=5.0;
    local obj=nil;

    for i=1,14 do
        local hash=getObjectName(i,"police")
        local o=GetClosestObjectOfType(playerPos.x,playerPos.y,playerPos.z, 2.5,hash,false,false,false);
        local opos=GetEntityCoords(o);

        if( #(opos - playerPos) < dist ) then
            dist = #(opos - playerPos);
            obj = o;
        end

        hash=getObjectName(i,"fire")
        local of=GetClosestObjectOfType(playerPos.x,playerPos.y,playerPos.z, 2.5,hash,false,false,false);
        opos=GetEntityCoords(of);

        if( #(opos - playerPos) < dist ) then
            dist = #(opos - playerPos);
            obj = of;
        end

    end

    if(obj ~= nil) then
        startPickAnimation();
        TriggerServerEvent("pv-cad:server:evidence:marker:delete", obj);
    end

end)

Citizen.CreateThread(function()
    while true do

        if(TAPE.editMode) then
            local instructionScaleform = RequestScaleformMovie("instructional_buttons")

            while not HasScaleformMovieLoaded(instructionScaleform) do
                Wait(0)
            end

            PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL")

            PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS")
            PushScaleformMovieFunctionParameterBool(0)
            PopScaleformMovieFunctionVoid()

            local buttonsToDraw = {
                {
                    ["label"] = "",
                    ["button"] = "~INPUT_CELLPHONE_UP~"
                },
                {
                    ["label"] = "",
                    ["button"] = "~INPUT_CELLPHONE_DOWN~"
                },
                {
                    ["label"] = "",
                    ["button"] = "~INPUT_CELLPHONE_LEFT~"
                },
                {
                    ["label"] = "Move",
                    ["button"] = "~INPUT_CELLPHONE_RIGHT~"
                },
                {
                    ["label"] = "",
                    ["button"] = "~INPUT_PICKUP~"
                },
                {
                    ["label"] = "Move Z (up/down)",
                    ["button"] = "~INPUT_PARACHUTE_BRAKE_LEFT~"
                },
                {
                    ["label"] = "",
                    ["button"] = "~INPUT_HUD_SPECIAL~"
                },
                {
                    ["label"] = "Rotate (up/down)",
                    ["button"] = "~INPUT_VEH_DUCK~"
                },
                {
                    ["label"] = "Rotate Z (left/right)",
                    ["button"] = "~INPUT_MP_TEXT_CHAT_TEAM~"
                },
                {
                    ["label"] = "Stop edit",
                    ["button"] = "~INPUT_CELLPHONE_CANCEL~"
                },
                {
                    ["label"] = "Place object",
                    ["button"] = "~INPUT_FRONTEND_RDOWN~"
                },
            }

            for buttonIndex, buttonValues in ipairs(buttonsToDraw) do
                PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT")
                PushScaleformMovieFunctionParameterInt(buttonIndex - 1)

                PushScaleformMovieMethodParameterButtonName(buttonValues["button"])
                if(buttonValues["label"] ~= nil) then
                    PushScaleformMovieFunctionParameterString(buttonValues["label"])
                end
                PopScaleformMovieFunctionVoid()
            end

            PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
            PushScaleformMovieFunctionParameterInt(-1)
            PopScaleformMovieFunctionVoid()
            DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255)

            --Move front (Arrow up)
            if IsControlPressed(0,172) then
                moveObject(0.05,0,0);
            end

            --Move Back (Arrow down)
            if IsControlPressed(0,173) then
                moveObject(-0.05,0,0);
            end

            --Move Left (Arrow left)
            if IsControlPressed(0,174) then
                moveObject(0,0.05,0);
            end

            --Move Right (Arrow right)
            if IsControlPressed(0,175) then
                moveObject(0,-0.05,0);
            end

            --Move down (E)
            if IsControlPressed(0,38) then
                moveObject(0,0,0.01);
            end

            --Move up (Q)
            if IsControlPressed(0,152) then
                moveObject(0,0,-0.01);
            end

            --Rotate (X)
            if IsControlPressed(0,73) then
                rotateObject(0.05);
            end

            --Rotate (Z)
            if IsControlPressed(0,48) then
                rotateObject(-0.05);
            end

            -- Rotate (Y)
            if(IsControlPressed(0,246)) then
                headObject(0.5);
            end

            -- ESC (Exit)
            if(IsControlPressed(0,177)) then
                leaveEditMode();
            end

            -- Enter (Place)
            if(IsControlPressed(0,191)) then
                placeObject();
            end


            Citizen.Wait(1)
        else
            Citizen.Wait(1000);
        end

    end
end)