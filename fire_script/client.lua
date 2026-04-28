local campfireProp = nil
local fireFX = nil
local smokeFX = nil

-- 1. Hapja e UI kur perdoret itemi (Thirret nga Serveri)
RegisterNetEvent("campfire:openUI", function()
    SetNuiFocus(true, true)
    TriggerServerEvent("campfire:getData") -- Kerkon listen e itemave nga serveri
end)

-- 2. Marrja e te dhenave dhe dhenia ne HTML
RegisterNetEvent("campfire:sendData", function(items)
    SendNUIMessage({
        action = "open",
        items = items
    })
end)

-- 3. Kur klikon "Ndiz Zjarrin" ne UI
RegisterNUICallback("startFire", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("campfire:craft", data) -- Dergon sasine te serveri per t'i fshire
    cb('ok')
end)

-- 4. Eventi qe ben Spawn kampin (Thirret nga serveri nese craft eshte OK)
RegisterNetEvent("campfire:spawn", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Pozicionimi para lojtarit
    local distance = 1.5
    local forwardVector = GetEntityForwardVector(playerPed)
    local forwardX = playerCoords.x + forwardVector.x * distance
    local forwardY = playerCoords.y + forwardVector.y * distance
    local forwardZ = playerCoords.z

    -- Pastro nese ka nje ekzistues
    if campfireProp ~= nil then DeleteEntity(campfireProp) end
    if fireFX ~= nil then StopParticleFxLooped(fireFX, false) end
    if smokeFX ~= nil then StopParticleFxLooped(smokeFX, false) end

    -- Animacioni i ndezjes
    local animDict = "mini_games@story@beechers@build_floor@john"
    local animName = "hammer_loop_good"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, 3000, 1, 0, false, false, false)
    
    TriggerEvent('vorp:showProgressBar', {
        duration = 3000,
        label = 'Duke ndezur zjarrin...',
        color = { r = 255, g = 100, b = 0 }
    })

    Wait(3000)
    ClearPedTasks(playerPed)

    -- Krijo Objektin
    local campfireHash = GetHashKey("p_campfire01x")
    RequestModel(campfireHash)
    while not HasModelLoaded(campfireHash) do Wait(10) end

    campfireProp = CreateObject(campfireHash, forwardX, forwardY, forwardZ, true, true, true)
    PlaceObjectOnGroundProperly(campfireProp)
    SetEntityAsMissionEntity(campfireProp, true, true)

    -- Partikujt (Zjarri dhe Tymi)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do Wait(10) end
    end
    
    -- FIX për RedM
    UseParticleFxAsset("core")
    fireFX = StartParticleFxLoopedAtCoord("core_fire", forwardX, forwardY, forwardZ - 0.4, 0.0, 0.0, 0.0, 0.8, false, false, false, false)
    
    UseParticleFxAsset("core")
    smokeFX = StartParticleFxLoopedAtCoord("core_smoke", forwardX, forwardY, forwardZ - 0.4, 0.0, 0.0, 0.0, 0.5, false, false, false, false)

    -- Fshirja automatike pas 1 ore (3600000 ms)
    SetTimeout(3600000, function()
        if campfireProp ~= nil then DeleteEntity(campfireProp) campfireProp = nil end
        if fireFX ~= nil then StopParticleFxLooped(fireFX, false) fireFX = nil end
        if smokeFX ~= nil then StopParticleFxLooped(smokeFX, false) smokeFX = nil end
    end)
end)

-- Mbyllja e UI
RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)