ESX = exports["es_extended"]:getSharedObject()

local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

RegisterServerEvent('Tony:package')
AddEventHandler('Tony:package', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem('gopostal_package', 1)
end)    


RegisterServerEvent('Tony:slotss')
AddEventHandler('Tony:slotss', function()

    local src = source
	ox_inventory:RemoveItem(src, 'gopostal_package', 1)
	ox_inventory:AddItem(src, 'money', 1000)
    TriggerClientEvent('Tony:rejob',src)

end)

 
RegisterServerEvent('Tony:ClearInventory')
AddEventHandler('Tony:ClearInventory', function()

	ox_inventory:ClearInventory('GoPostal', true)

end)

RegisterServerEvent('Tony:addtrunkit')
AddEventHandler('Tony:addtrunkit', function()
  
	local src = source
	ox_inventory:AddItem(src, 'gopostal_package', 1)
--[[print(plate)
    local success, response = exports.ox_inventory:AddItem('trunk'..plate, 'gopostal_package', 1)]]
end)
 

 
 
