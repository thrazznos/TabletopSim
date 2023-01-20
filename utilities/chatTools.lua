
print("Importing tools")

function onChat(message, sender)

    --get the command name
    local _, _, commandName, _ = string.find(message, "^(%a+)")

    chatCommands = {
        ["init"] = setup,
        ["ls"] = printDynamicObjects,
        ["players"] = printSeatedPlayers,
        ["find"] = spawnCubeAtLocation,
        ["flip"] = flipObjectByGuid
    }

    if(chatCommands[commandName]) then
        chatCommands[commandName](message, sender)
    end
end

function spawnCubeAtLocation(message, sender)
    local subStr = string.gsub(message, "find ", "")

    --TODO: check the pattern here for vector somehow
    _, _, x, y, z = string.find(subStr, "{(-?%d+.?%d*), (-?%d+.?%d*), (-?%d+.?%d*)}")
    if( (x == nil) or (y == nil) or (z == nil)) then
        print("Vector cannot be parsed, aborting")
        return 1
    end
    
    print("Marking " .. x .. " " .. y .. " " .. z) 

    local object = spawnObject({
        type = "BlockSquare",
        position = {0, 20, 0},
        scale = {0.5, 0.5, 0.5},
        sound = true,
        snap_to_grid = true,
        callback_function = function(spawned_object)
            spawned_object.use_gravity = false
            spawned_object.mass = 0
            Wait.frames(function() 
                local vec = spawned_object.getPosition()
                spawned_object.setPositionSmooth({x, y, z})
                spawned_object.use_gravity = true
            end, 60)
        end
    })
end

function printSeatedPlayers()
    print("Printing seated players")
    for _, player in ipairs(seatedPlayers) do
        print(player .. " is seated")
    end
end

function printUnseatedPlayers()
    print("Printing unseated players")
    for _, player in ipairs(unseatedPlayers) do
        print(player .. " is unseated")
    end
end

--Utility Functions
function printDynamicObjects()
    if(dynamic_assets == nil) then
        print("no dynamic objects")
    else
        print(getTableSize(dynamic_assets) .. " dynamic objects created")
        for key,value in pairs(dynamic_assets) do
            print(key .. ": " .. value)
        end
    end
end

function flipObjectByGuid(message, sender)
    _, _, _, guid = string.find(message, "^(%a+) (%w+)")
    print("flipping " .. guid)
    obj = getObjectFromGUID(guid)
    obj.flip()
end
