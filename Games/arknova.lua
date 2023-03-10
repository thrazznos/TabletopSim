--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

--[[ The onLoad event is called after the game save finishes loading. --]]
require("vscode/console")
require("utilities/chatTools")

DEBUG = false
fastSetupAnimation = false
fastGameAnimations = false

--------CONSTANTS-----------------------
PLAYER_DATA = {
    ['White'] = {
        ['pos'] = Vector({-45.00, 0.98, -22.58}),
        ['pawns'] = {
            'ba176b','98cf83','c17872','73a012',
        },
        ['cubeBag'] = '045dcd',
        ['conservationPointPawn'] = '23f41a',
        ['appealPointPawn'] = '15f2f4',
        ['reputationPointPawn'] = '8f2664',
        ['selection_row_zone'] = 'befcfe',
        ['selected_card_zone'] = 'e363bd',
        ['actionCardLocations'] = {        
            Vector({-48.63, 1.00, -29.81}),
            Vector({-44.96, 1.00, -29.81}),
            Vector({-41.30, 1.00, -29.81}),
            Vector({-37.64, 1.00, -29.81}),
            Vector({-52.29, 1.00, -29.81})
        }
    },
    ['Yellow'] = {
        ['pos'] = Vector({-15.00, 0.98, -22.58}),
        ['pawns'] = {
            'd2bd1b','49852f','a33af6','368676',
        },
        ['cubeBag'] = '18b382',
        ['conservationPointPawn'] = 'c0d4aa',
        ['appealPointPawn'] = 'fc8a15',
        ['reputationPointPawn'] = '64f3fb',
        ['selection_row_zone'] = 'ef4d6c',
        ['selected_card_zone'] = '294ad1',
        ['actionCardLocations'] = {        
            Vector({-18.63, 1.00, -29.81}),
            Vector({-14.96, 1.00, -29.81}),
            Vector({-11.30, 1.00, -29.81}),
            Vector({-7.64, 1.00, -29.81}),
            Vector({-22.29, 1.00, -29.81})
        }
    },
    ['Red'] = {
        ['pos'] = Vector({15.00, 0.98, -22.58}),
        ['pawns'] = {
            'd4c066','de78d5','3154c0','7a6110',
        },
        ['cubeBag'] = '7780c2',
        ['conservationPointPawn'] = '6880dc',
        ['appealPointPawn'] = '8156c7',
        ['reputationPointPawn'] = 'e8ee40',
        ['selection_row_zone'] = '4bbbaa',
        ['selected_card_zone'] = 'c4aca7',
        ['actionCardLocations'] = {        
            Vector({11.37, 1.00, -29.81}),
            Vector({15.04, 1.00, -29.81}),
            Vector({18.70, 1.00, -29.81}),
            Vector({22.36, 1.00, -29.81}),
            Vector({7.71, 1.00, -29.81})
        }
    },
    ['Blue'] = {
        ['pos'] = Vector({45.00, 0.98, -22.58}),
        ['pawns'] = {
            '91902e','321c47','28e95f','018903',
        },
        ['cubeBag'] = 'c4f4bc',
        ['conservationPointPawn'] = 'd21fc0',
        ['appealPointPawn'] = 'f67354',
        ['reputationPointPawn'] = 'c0f361',
        ['selection_row_zone'] = '012ca4',
        ['selected_card_zone'] = '5882a8',
        ['actionCardLocations'] = {        
            Vector({41.37, 1.00, -29.81}),
            Vector({45.04, 1.00, -29.81}),
            Vector({48.70, 1.00, -29.81}),
            Vector({52.36, 1.00, -29.81}),
            Vector({37.71, 1.00, -29.81})
        }
    }
}
seatedPlayers = {}
unseatedPlayers = {}
sortedSeatedPlayers = {}
dynamic_assets = {}
coffeeMarkerStartingLocations = {
    Vector({3.45, 1.43, 0.80}),
    Vector({3.45, 1.43, 0.80}),
    Vector({6.24, 1.43, 0.80}),
    Vector({9.03, 1.43, 0.80}),
}

bonusTileLocations = {
    Vector({-25.15, 1.13, 0.94}),
    Vector({-23.26, 1.13, 0.94}),
    Vector({-19.98, 1.13, 0.94}),
    Vector({-18.13, 1.13, 0.94}),
}

conservationProjectLocations = {
    Vector({17.77, 1.00, -8.16}),
    Vector({21.40, 1.00, -8.16}),
    Vector({25.05, 1.00, -8.16}),
    Vector({28.65, 1.00, -8.15}),
}

twoPlayerConservationBlockCubeLocations = {
    Vector({16.72, 1.23, -9.64}),
    Vector({21.44, 1.23, -9.64}),
    Vector({26.15, 1.23, -9.64}),

    Vector({16.00, 1.31, -2.26}),
    Vector({16.00, 1.31, -3.01}),
    Vector({16.00, 1.31, -3.75}),
}

soloActionMarkerLocations = {
    Vector({-0.56, 1.31, -20.68}),
    Vector({-0.56, 1.31, -21.33}),
    Vector({-0.56, 1.31, -21.98}),
    Vector({-0.56, 1.31, -22.63}),
    Vector({-0.56, 1.31, -23.28}),
    Vector({-0.56, 1.31, -23.94}),
    Vector({-0.56, 1.31, -24.61}),
}

appealStartingLocations = {
    Vector({-30.60, 1.33, -7.67}),
    Vector({-29.74, 1.33, -7.67}),
    Vector({-28.89, 1.33, -7.67}),
    Vector({-28.03, 1.33, -7.67}),
    Vector({-13.52, 1.33, -7.67})
}

singlePlayerBoardGuid = "1e5455"

mapGuids = {
    ["0"] = "",
    ['A'] = "",
    ['1'] = "5c094e",
    ['2'] = "4c89da",
    ['3'] = "a6c7a5",
    ['4'] = "7af8d5",
    ['5'] = "73540d",
    ['6'] = "38cff8",
    ['7'] = "5be757",
    ['8'] = "ef5c14",
    ['9'] = "ddbbd5",
    ['10'] = "e88324",
}

------------------------------------------------------------

--Collect Player list, seatedPlayers
function setSeatedPlayers()
    for key, _ in pairs(PLAYER_DATA) do
        if(Player[key].seated or DEBUG) then
            table.insert(seatedPlayers, key)
        else
            table.insert(unseatedPlayers, key)
        end
    end
end

function getSortedSeatedPlayers()
    math.randomseed( os.time() )
    offset = math.random(#seatedPlayers)

    for i, _ in ipairs(seatedPlayers) do
        --print(seatedPlayers[(i + offset) % #seatedPlayers + 1])
        --Crazy modulus math cause not zero index
        table.insert(sortedSeatedPlayers, seatedPlayers[(i + offset) % #seatedPlayers + 1]) 
    end
end

function onLoad()
    initMoneyCounters()
    setSeatedPlayers()
    --getSortedSeatedPlayers()
    printSeatedPlayers()


    if getObjectFromGUID('157aa7') then
        createSetupButtons()
    else
        createRefillButton()
    end
end

function setup(x)
    startGame()
    return
end

function spawnSinglePlayerBoard(spawn_position)
    singlePlayerBoard = getObjectFromGUID(singlePlayerBoardGuid)
    singlePlayerBoard.setPositionSmooth(spawn_position, false, fastSetupAnimations)

    zone = spawnObject({
        type = "ScriptingTrigger",
        position = {spawn_position.x, spawn_position.y + 1, spawn_position.z},
        scale = {3, 1, 5},
        callback_function = function(spawned_zone)
            print("Spawning Single Player Board Zone: " .. spawned_zone.getGUID())
            dynamic_assets["singlePlayerBoardZone"] = spawned_zone.getGUID()
        end
    })
end

function createRefillButton()
    local b = getObjectFromGUID('14efab')
    local s = 0.6
    b.createButton({
        label="Refill\nDisplay",
        width = 3000,
        height = 2000,
        position = {0,0,0},
        scale = {s,s,s},
        font_size = 1000,
        click_function = "refill",
        color = {106.7/255,200.3/255,232.5/255}
    })
    b.createButton({
        label="Return\nAssistants",
        width = 3500,
        height = 2000,
        position = {53.5, 0, 12.5},
        scale = {s,s,s},
        font_size = 1000,
        click_function = "return_assistants",
        color = {106.7/255,200.3/255,232.5/255}
    })
end

function createSetupButtons()
    playerCount = math.max(#seatedPlayers,1)
    local board = getObjectFromGUID('157aa7')
    local bScale = board.getScale()

    board.createButton({
        label="Start Game",
        width = 3300,
        height = 699,
        position = {0/bScale.x,0.5,0/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "startGame",
        color = {106.7/255,200.3/255,232.5/255}
    })
    board.createButton({
        label="<",
        width = 500,
        height = 699,
        position = {-4/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "pCountDec",
        color = {106.7/255,200.3/255,232.5/255}
    })
    board.createButton({
        label=">",
        width = 500,
        height = 699,
        position = {4/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "pCountInc",
        color = {106.7/255,200.3/255,232.5/255}
    })
    board.createButton({
        label="Players: " .. tostring(playerCount),
        width = 3300,
        height = 699,
        position = {0/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "empty",
        color = {106.7/255,200.3/255,232.5/255}
    })

    board.createButton({
        label="Map Type",
        width = 3300,
        height = 699,
        position = {9/bScale.x,0.5,-1.5/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "empty",
        color = {106.7/255,200.3/255,232.5/255}
    })
    board.createButton({
        label="<",
        width = 500,
        height = 699,
        position = {5/bScale.x,0.5,0/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "decMapType",
        color = {106.7/255,200.3/255,232.5/255}
    })
    board.createButton({
        label=">",
        width = 500,
        height = 699,
        position = {13/bScale.x,0.5,0/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "incMapType",
        color = {106.7/255,200.3/255,232.5/255}
    })

    MAP_TYPE = 1
    board.createButton({
        label="Map A",
        tooltip = "Recommended for first time players.",
        width = 3300,
        height = 699,
        position = {9/bScale.x,0.5,0/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "empty",
        color = {106.7/255,200.3/255,232.5/255}
    })

    --[[
    LONG_GAME = true
    board.createButton({
        label="Long Game",
        width = 3300,
        height = 699,
        position = {0/bScale.x,0.5,-3/bScale.z},
        scale = {1/bScale.x,1,1/bScale.z},
        font_size = 549,
        click_function = "toggleLength",
        color = {106.7/255,200.3/255,232.5/255}
    })]]

    board.createButton({
        label="Manual Setup",
        width = 4000,
        height = 699,
        position = {0/bScale.x,0.5,1.5/bScale.z},
        scale = {0.5/bScale.x,0.5,0.5/bScale.z},
        font_size = 549,
        click_function = "manual"
    })


end

--[[
function toggleLength()
    LONG_GAME = not LONG_GAME
    local b = getObjectFromGUID('157aa7')
    if LONG_GAME then
        b.editButton({index=4,label = "Long Game"})
    else
        b.editButton({index=4,label = "Short Game"})
    end
end]]

function pCountInc()
    playerCount = playerCount + 1
    if playerCount > 4 then playerCount = 1 end
    updateBoard()
end
function pCountDec()
    playerCount = playerCount - 1
    if playerCount < 1 then playerCount = 4 end
    updateBoard()
end

function updateBoard()
    local board = getObjectFromGUID('157aa7')
    board.editButton({index=3, label="Players: " .. playerCount})
end

function onPlayerChangeColor(color)
    if getObjectFromGUID('157aa7') then
        playerCount = math.max(#seatedPlayers, 1)
        updateBoard()
    end

    setSeatedPlayers()
end

function manual()
    getObjectFromGUID('157aa7').destruct()
    Notes.setNotes("")
end

function incMapType()
    MAP_TYPE = MAP_TYPE + 1
    if MAP_TYPE > 3 then MAP_TYPE = 1 end
    updateMapBoard()
end

function decMapType()
    MAP_TYPE = MAP_TYPE - 1
    if MAP_TYPE < 1 then MAP_TYPE = 3 end
    updateMapBoard()
end

function updateMapBoard()
    local infoTable = {
        {
            ['label'] = "Map A",
            ['tooltip'] = "Recommended for first time players.",
            ['fontSize'] = 549,
        },
        {
            ['label'] = "Map 0",
            ['tooltip'] = "Recommended for intermediate players.",
            ['fontSize'] = 549,
        },
        {
            ['label'] = "Maps 1-10\n[i](Manual Setup)[/i]",
            ['tooltip'] = "10 maps with unique abilities. See rulebook page 3 for setup suggestions.\n\n[i]Note: Maps must be set up manually before or after pressing \"Start Game\". Maps are located in bags to the left of the board. Hover over the map's text for an english translation.",
            ['fontSize'] = 309,
        },
    }

    local board = getObjectFromGUID('157aa7')
    local t = infoTable[MAP_TYPE]
    board.editButton({index=7, label=t.label, tooltip=t.tooltip, font_size=t.fontSize})
end

function startGame()
    getSortedSeatedPlayers()
    getObjectFromGUID('157aa7').destruct()
    Notes.setNotes("")

    --maps
    setupMaps(MAP_TYPE)

    --place coffee marker, skip for 1p
    if (playerCount > 1) then
        local coffeeMarker = getObjectFromGUID('bbf4bd')
        coffeeMarker.setPositionSmooth(coffeeMarkerStartingLocations[playerCount], false, fastSetupAnimation)
    end

    --bonus tiles
    local bag = getObjectFromGUID('1c73d4')
    bag.shuffle()
    for _,pos in ipairs(bonusTileLocations) do
        bag.takeObject({position=pos})
    end
    bag.destruct()

    --fill display
    local zDeck = getObjectFromGUID('27f70f')
    zDeck.shuffle()
    FACEDOWN = true
    createRefillButton()
    refill()
    broadcastToAll('Discard 4 cards from your hand [i](not Final Scoring cards)[/i], then flip display cards face up.')

    --basic conservation projects
    local bag = getObjectFromGUID('853c1f')
    bag.shuffle()
    if playerCount<4 then
        table.remove(conservationProjectLocations, 4) --Only use 3 projects for less than 4 players
    end
    for _,pos in ipairs(conservationProjectLocations) do
        local o = bag.takeObject({position=pos})
        o.setLock(true)
        o.setRotation({0,180,0})
    end

    --place conservation and funding blocking markers
    if playerCount < 3 then
    local bag = getObjectFromGUID('669758')
        if playerCount == 1 then
            --solo markers
            singlePlayerBoardOffset = Vector({-11.64, 0, 0})
            tokenStartingLocation = Vector({-0.56, 1.31, 1.90})
            tokenOffset = Vector({0, 0, -0.65})

            singlePlayerBoardLocation = PLAYER_DATA[sortedSeatedPlayers[1]].pos + singlePlayerBoardOffset
            spawnSinglePlayerBoard(singlePlayerBoardLocation)

            for i=1, 7 do
                bag.takeObject(
                    {position=singlePlayerBoardLocation + 
                    tokenStartingLocation +
                    tokenOffset * (i -1)
                })
            end
        end
        if playerCount == 2 then
            for _,pos in ipairs(twoPlayerConservationBlockCubeLocations) do
                local o = bag.takeObject({position=pos})
                o.setLock(true)
                o.setRotation({0,180,0})
            end
        end
    else
        getObjectFromGUID('669758').destruct()
    end
    if playerCount~=1 then
        getObjectFromGUID('1e5455').destruct()
    end

    if(sortedSeatedPlayers) then
        broadcastToAll(sortedSeatedPlayers[1] .. " is the starting player.", sortedSeatedPlayers[1])
    end

    --appealStartingLocations

    if(#sortedSeatedPlayers == 1) then
        local appealPawn = getObjectFromGUID(PLAYER_DATA[sortedSeatedPlayers[1]].appealPointPawn)
        appealPawn.setPositionSmooth(appealStartingLocations[5], false, fastSetupAnimation)
    else
        for i, color in pairs(sortedSeatedPlayers) do
            appealPawn = getObjectFromGUID(PLAYER_DATA[color].appealPointPawn)
            appealPawn.setPositionSmooth(appealStartingLocations[i], false, fastSetupAnimation)
        end
    end
    
    --remove unseated appeal tokens
    for i, value in ipairs(unseatedPlayers) do
        getObjectFromGUID(PLAYER_DATA[value].appealPointPawn).destruct()
    end

    --remove unseated reputation and conservation tokens
    for i, value in ipairs(unseatedPlayers) do
        getObjectFromGUID(PLAYER_DATA[value].conservationPointPawn).destruct()
        getObjectFromGUID(PLAYER_DATA[value].reputationPointPawn).destruct()
    end

    --WIP

    --shuffle action cards
    local deckList = {
        getObjectFromGUID('0c9750'),
        getObjectFromGUID('8c5762'),
        getObjectFromGUID('280aba'),
        getObjectFromGUID('1d9c26'),
    }
    local offset = {
        Vector({-18.63, 1.00, -29.81})-Vector({-7.64, 1.00, -29.81}),
        Vector({-14.96, 1.00, -29.81})-Vector({-7.64, 1.00, -29.81}),
        Vector({-11.30, 1.00, -29.81})-Vector({-7.64, 1.00, -29.81}),
    }

    for _,deck in ipairs(deckList) do
        deck.shuffle()
        local basePos = deck.getPosition()
        for i=1,3 do
            deck.takeObject({position=basePos+offset[i]})
        end
    end

    --starting cards
    local obDeck = getObjectFromGUID('bd92ce')
    obDeck.shuffle()

    for _,color in ipairs(Player.getAvailableColors()) do
        if Player[color].seated then
            obDeck.deal(2, color, 2)
            zDeck.deal(8,color)
        end
    end
end

function setupMaps(type)
    if type == 3 then return end
    local bag = nil
    if type == 1 then
        bag = getObjectFromGUID('9e3768')
    else
        bag = getObjectFromGUID('d71bb5')
    end

    for i, color in ipairs(sortedSeatedPlayers) do
        --draw board
        local o = bag.takeObject({position = PLAYER_DATA[color].pos})
        o.setLock(true)
        o.setRotation({0,180,0})

        Wait.time(function() setupPlayer(o, PLAYER_DATA[color]) end, 2)
    end



    --destroy map bags
    getObjectFromGUID('9e3768').destruct()
    getObjectFromGUID('d71bb5').destruct()
    getObjectFromGUID('7f96e0').destruct()
    getObjectFromGUID('1b6f23').destruct()
    getObjectFromGUID('018f75').destruct()
end

function setupPlayer(board, sub)
    local basePos = board.getPosition()
    local s = board.getScale().x
    local bag = getObjectFromGUID(sub.cubeBag)

    --pawns & cubes
    local pawnCount = 1
    local snaps = board.getSnapPoints()
    for _,snap in ipairs(snaps) do
        if snap.tags[1]=='assist' then
            local currPawn = getObjectFromGUID(sub.pawns[pawnCount])
            local pos = basePos + s*snap.position:inverse()+Vector(0,1,0)
            currPawn.setPositionSmooth(pos,false,false)
            pawnCount = pawnCount+1
            if pawnCount==4 then
                currPawn = getObjectFromGUID(sub.pawns[pawnCount])
                currPawn.setPositionSmooth(basePos+Vector(8.29,0.11,1.32),false,false)
            end
        elseif snap.tags[1]=='cube' then
            local pos = basePos + s*snap.position:inverse()+Vector(0,1,0)
            bag.takeObject({position=pos})
        end
    end

    --3-space enclosure
    if MAP_TYPE == 1 then
        local threeBag = getObjectFromGUID('460173')
        threeBag.takeObject({position=basePos + Vector(-5.6,0.16,-1.6), rotation={0.00, 330.00, 0.00}})
    end
end

function refill()
    if WAIT then return end
    WAIT = true
    Wait.time(function() WAIT = false end, 0.5)

    --find deck
    local dZone = getObjectFromGUID('9d30f9')
    local d = dZone.getObjects()[1]

    if d==nil then
        broadcastToAll("Deck is empty, perform refill manually.")
        return
    end

    local rowZone = getObjectFromGUID('da2561')

    local posTable = {
        Vector({-24.93, 1.10, -3.51}),
        Vector({-18.86, 1.10, -3.51}),
        Vector({-12.78, 1.10, -3.51}),
        Vector({-6.71, 1.10, -3.51}),
        Vector({-0.65, 1.10, -3.51}),
        Vector({5.42, 1.10, -3.51}),
    }

    --get and sort existing cards
    local cards = rowZone.getObjects()
    table.sort(cards, function(a,b) return a.getPosition().x < b.getPosition().x end)

    --slide existing cards
    for i,card in ipairs(cards) do
        card.setPositionSmooth(posTable[i], false, false)
    end

    local ndx = #cards+1 --first empty index
    slotsToFill = (6-ndx)+1

    if #d.getObjects() < slotsToFill then
        slotsToFill = #d.getObjects()
    end

    for i=1,slotsToFill do
        n = ndx+i-1
        if FACEDOWN then
            d.takeObject({position=posTable[n], rotation={0.00, 180.00, 180.00}})
        else
            d.takeObject({position=posTable[n], rotation={0.00, 180.00, 0}})
        end
    end
    FACEDOWN = false
end

function initMoneyCounters()
    local guids = {'79ecc1','d70ec2','165706','de8228',}

    for _,g in ipairs(guids) do
        local obj = getObjectFromGUID(g)
        if obj then
            local value = tonumber(obj.getGMNotes())
            if not value then
                value = 0
                obj.setGMNotes(value)
            end

            local s = 1
            obj.createButton({
                click_function = "empty",
                font_size = 1000,
                label = value,
                width = 0,
                height = 0,
                font_color = {1,1,1},
                position = {1.075,0,1.2},
                scale = {s,s,s*1.1},
            })

            local w = 1000
            local h = 750
            local ss = 0.4
            local zOff = 1.8
            local xStart = -1.5
            local xEnd = 2.8
            local xOffset = (xEnd-xStart)/3

            obj.createButton({
                click_function = "minusThree",
                font_size = 1000,
                label = "-5",
                width = w,
                height = h,
                position = {1.075-1.4, 0, 1.5},
                scale = {ss,ss,ss},
                color = {222/255,73/255,63/255}
            })

            obj.createButton({
                click_function = "minusOne",
                font_size = 1000,
                label = "-1",
                width = w,
                height = h,
                position = {1.075-1.4, 0, 0.75},
                scale = {ss,ss,ss},
                color = {222/255,73/255,63/255}
            })

            obj.createButton({
                click_function = "plusOne",
                font_size = 1000,
                label = "+1",
                width = w,
                height = h,
                position = {1.075+1.4, 0, 0.75},
                scale = {ss,ss,ss},
                color = {130/255,186/255,63/255}
            })

            obj.createButton({
                click_function = "plusThree",
                font_size = 1000,
                label = "+5",
                width = w,
                height = h,
                position = {1.075+1.4, 0, 1.5},
                scale = {ss,ss,ss},
                color = {130/255,186/255,63/255}
            })
        end
    end
end

function updateLabel(obj, value)
    obj.setGMNotes(value)
    obj.editButton({
        index = 0,
        label = value
    })
end

function minusOne(obj)
    local value = tonumber(obj.getGMNotes())
    value = value - 1
    updateLabel(obj, value)
end

function minusThree(obj)
    local value = tonumber(obj.getGMNotes())
    value = value - 5
    updateLabel(obj, value)
end

function plusOne(obj)
    local value = tonumber(obj.getGMNotes())
    value = value +1
    updateLabel(obj, value)
end

function plusThree(obj)
    local value = tonumber(obj.getGMNotes())
    value = value +5
    updateLabel(obj, value)
end

function empty()
end

--[[
function onLoad(save_state)
    getObjectFromGUID('36f20a').createButton({
        width=1000,
        height=1000,
        click_function = "asdf",
        position = {0,1,0},
    })
end

function asdf()
    local a = getObjectFromGUID('4e3ebd')
    local b = getObjectFromGUID('ca5ebd')

    local num = 14
    local div = 15
    local startpos = a.getPosition()

    local offset = (b.getPosition()-a.getPosition())*(1/div)
    for i=1,num do
        a.clone({position = startpos+i*offset})
    end
end
]]

card_location_history = {}

function onObjectEnterScriptingZone(zone, enter_object)
    for key, player in pairs(PLAYER_DATA) do
        if(zone.guid == player.selected_card_zone) then
            slideCards(player)
            placeCard1(player)
            if(playerCount == 1) then
                incrementSinglePlayerActionTracker()
            end
        end
    end

end

function slideCards(player)
    local rowZone = getObjectFromGUID(player.selection_row_zone)
    print(rowZone.guid)
    local cards = getSortedCardsInZone(rowZone)

    --slide existing cards
    for i,card in ipairs(cards) do
        card.setPositionSmooth(player.actionCardLocations[i], false, false)
    end
end

function placeCard1(player)

    local selectionZone = getObjectFromGUID(player.selected_card_zone)
    local selected_card = selectionZone.getObjects()
    print(selected_card[1].getName())
    local position1 = player.actionCardLocations[5]
    selected_card[1].setPositionSmooth(position1, false, false)
end

function saveCardPositions()
    local rowZone = getObjectFromGUID(selection_row_zone_guid)
    local cards = getSortedCardsInZone(rowZone)

    local temp_table = {}
    for i,card in ipairs(cards) do
        table.insert(temp_table, {card, card.getPosition()})
    end

    --table of tables that contains card and location pairings for each turn
    table.insert(card_location_history, temp_table)
    print(#card_location_history)
    --TODO: How can I see whats in here
    print(card_location_history[1][1][1].guid)
    --BUGBUG: function triggers before the 5th card gets added back in
end

function getSortedCardsInZone(rowZone)
    local cards = rowZone.getObjects()
    table.sort(cards, function(a,b) return a.getPosition().x < b.getPosition().x end)
    --sorted list of cards by location
    return cards
end

university_zone_guid = "b6e969"

function return_assistants()
    local assistant_notepad_locations = {
        Vector({21.41, 1.08, -19.18}),
        Vector({21.41, 1.08, -19.98}),
        Vector({21.41, 1.08, -20.78}),
        Vector({21.41, 1.08, -21.58})
    }

    local universityZone = getObjectFromGUID(university_zone_guid)
    local assistants = universityZone.getObjects()
    print("Returning " .. #assistants .. " assistants")

    for i,assistant in ipairs(assistants) do
        assistant.setPositionSmooth(assistant_notepad_locations[i], false, false)
    end

end


function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

function incrementSinglePlayerActionTracker()
    action_zone = getObjectFromGUID(dynamic_assets["singlePlayerBoardZone"])
    if(action_zone) then
        local tokens = action_zone.getObjects()
        table.sort(tokens, sortSinglePlayerTokens)
        currPos = tokens[1].getPosition()
        tokens[1].setPositionSmooth(currPos + Vector({0.63, 0, 0}), false, fastGameAnimations)
    else    
        print "SinglePlayerBoard zone not found"
    end
end

function sortSinglePlayerTokens(a, b)
    loc_a = a.getPosition()
    loc_b = b.getPosition()

    if(loc_a.x == loc_b.x) then
        return loc_a.z > loc_b.z
    else
        return loc_a.x < loc_b.x
    end
end