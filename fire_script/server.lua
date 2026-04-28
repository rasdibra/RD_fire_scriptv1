local VorpCore = exports.vorp_core:GetCore()
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()

-- 1. Regjistrimi i itemit "campfire"
VorpInv.RegisterUsableItem("campfire", function(data)
    local src = data.source
    TriggerClientEvent("campfire:openUI", src)
end)

-- 2. Marrja e te dhenave te inventory-t
RegisterNetEvent("campfire:getData", function()
    local src = source
    
    -- RREGULLIMI KETU: Perdorim VorpInv direkt me 'src'
    local woodCount = VorpInv.getItemCount(src, "wood") or 0
    local rockCount = VorpInv.getItemCount(src, "rock") or 0

    local items = {
        wood = {
            count = woodCount,
            image = "nui://vorp_inventory/html/img/items/wood.png"
        },
        rock = {
            count = rockCount,
            image = "nui://vorp_inventory/html/img/items/rock.png"
        }
    }

    TriggerClientEvent("campfire:sendData", src, items)
end)

-- 3. Proçesi i Crafting
RegisterNetEvent("campfire:craft", function(data)
    local src = source
    local user = VorpCore.getUser(src)
    if not user then return end

    local char = user.getUsedCharacter
    local woodNeeded = tonumber(data.wood or 0)
    local rockNeeded = tonumber(data.rock or 0)

    if woodNeeded < 7 or rockNeeded < 4 then
        TriggerClientEvent("vorp:TipRight", src, "Duhen te pakten 7 dru dhe 4 gure", 3000)
        return
    end

    -- RREGULLIMI KETU: Kontrollojme sasine duke perdorur VorpInv
    local playerWood = VorpInv.getItemCount(src, "wood")
    local playerRock = VorpInv.getItemCount(src, "rock")

    if playerWood >= woodNeeded and playerRock >= rockNeeded then
        -- Perdorim VorpInv per te hequr itemat
        VorpInv.subItem(src, "wood", woodNeeded)
        VorpInv.subItem(src, "rock", rockNeeded)
        
        TriggerClientEvent("campfire:spawn", src)
        TriggerClientEvent("vorp:TipRight", src, "Zjarri u ndez me sukses!", 3000)
    else
        TriggerClientEvent("vorp:TipRight", src, "Nuk ke materiale mjaftueshem", 3000)
    end
end)