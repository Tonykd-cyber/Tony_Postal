ESX = exports["es_extended"]:getSharedObject()

local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target
local hasjob = false
local hascar = false
lib.locale()

CreateThread(function()   

	local Postalblip = AddBlipForCoord(67.9947, 120.9220, 79.1221)
	SetBlipSprite(Postalblip, 444)
	SetBlipDisplay(Postalblip, 4)
	SetBlipScale(Postalblip, 0.7)
	SetBlipColour(Postalblip, 26)
	SetBlipAsShortRange(Postalblip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(locale('A11'))
	EndTextCommandSetBlipName(Postalblip)
   
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k, v in pairs(Config.Pedlocation) do
			local pos = GetEntityCoords(PlayerPedId())	
			local dist = #(v.Cords - pos)
			
			
			if dist < 40 and pedspawned == false then
				TriggerEvent('Tony:pedspawn',v.Cords,v.h)
				pedspawned = true
			end
			if dist >= 35 then
				pedspawned = false
				DeletePed(npc)
			end
		end
	end
end)

RegisterNetEvent('Tony:pedspawn')
AddEventHandler('Tony:pedspawn',function(coords,heading)

    local hash = Config.Postalped[math.random(#Config.Postalped)]

	if not HasModelLoaded(hash) then
		RequestModel(hash)
		Wait(10)
	end
	while not HasModelLoaded(hash) do 
		Wait(10)
	end

    pedspawned = true
	npc = CreatePed(5, hash, coords, heading, false, false)
	FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityInvincible(npc, true)

end)

ox_target:addBoxZone({

    coords = vec3(78.9427, 112.5193, 81.1681),
    size = vec3(2, 2, 2),
    rotation = 158.1205,
    debug = false,
    drawSprite = true,
    options = {
        {
            name = 'Tony_goobj',
			event = "Tony:goobj",
			icon = "fa-solid fa-cube",
			label = locale('A1'),
            distance = 2.0
        },

        {
            name = 'Tony_goobjb',
			icon = "fa-solid fa-cube",
			label = locale('A2'),
            onSelect = function()
                DeleteVehicle()
            end,
            distance = 2.0
        }
    }
})

 
RegisterNetEvent('Tony:goobj')
AddEventHandler('Tony:goobj', function()
    if not hasjob and not hascar then
        hasjob = true
        hascar = true
        lib.notify({
            id = 'goobj',
            title = locale('A6'),
            description = locale('A7'),
            showDuration = 3000,
            position = 'top',
            style = {
                backgroundColor = '#27272B',
                color = '#00AADA',
                ['.description'] = {
                  color = '#00AADA'
                }
            },
            icon = 'fa-solid fa-cube',
            iconColor = '#00AADA'
        })

    ox_target:addModel(Config.oxrmbox, {
        {
            name = 'lockeropen',   -- 唯一标识符
            event = "Tony:additem",
            icon = "fa-solid fa-cube",
            label = locale('A3'),
            distance = 1.5
        }
    }) 
    ox_target:addGlobalVehicle({
        {
            name = 'trunkadditem',
            event = 'Tony:addtrunk',
            icon = 'fa-solid fa-car',
            description = locale('A12'),
            bones = {'exhaust'},
            distance = 3,
        }
    })
        SpawnLocalObject()
        SpawnVehicle()
        Spawnlocker()
    else       
        lib.notify({
            id = 'goobjer',
            title = locale('A6'),
            description = locale('A8'),
            showDuration = 2000,
            position = 'top',
            style = {
                backgroundColor = '#27272B',
                color = '#00AADA',
                ['.description'] = {
                  color = '#00AADA'
                }
            },
            icon = 'fa-solid fa-cube',
            iconColor = '#00AADA'
        })
    end    
end)

function SpawnLocalObject()
    -- 清空旧物体（可选）
    -- ClearExistingObjects()
    -- 生成随机数量
    local spawnCount = math.random(Config.spawnArea.minCount, Config.spawnArea.maxCount)

    for i = 1, spawnCount do
        -- 生成随机偏移坐标
        local randomAngle = math.random() * math.pi * 2  -- 0-360度弧度
        local randomDist = math.random() * Config.spawnArea.radius
        local xOffset = math.cos(randomAngle) * randomDist
        local yOffset = math.sin(randomAngle) * randomDist
        
        -- 计算最终坐标
        local spawnPos = vector3(
            70.0 + xOffset,
            120.0 + yOffset,
            79.0
        )
        -- 随机选择模型
        local randomModel = Config.oxrmbox[math.random(1, #Config.oxrmbox)]
        
        -- 生成物体
        ESX.Game.SpawnLocalObject(randomModel, spawnPos, function(object)
            PlaceObjectOnGroundProperly(object)
            
            -- 设置随机朝向（0-360度）
            SetEntityHeading(object, math.random(0.0, 360.0))
            
            -- 可选：添加轻微高度偏移模拟自然分布
            local finalPos = GetEntityCoords(object)
            SetEntityCoords(object, finalPos.x, finalPos.y, finalPos.z + math.random() * 0.2)
            PlaceObjectOnGroundProperly(object)
        end)
    end
end

function SpawnVehicle()
    hascar = true
    ESX.Game.SpawnVehicle('boxville2', Config.vehicle[1], Config.vehicle.heading, function(vehicle)
        spawnedVehicle = vehicle
        Citizen.Wait(100) -- 确保车辆初始化
        
        -- 解锁车门并允许所有玩家进入
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        
        -- 可选：直接设置车门为完全可操作状态
        SetVehicleNeedsToBeHotwired(vehicle, false)
        
        -- 其他操作...
        --SetVehicleNumberPlateText(vehicle, "MYPLATE")
        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
        
        -- 调试输出
        print("Door lock status:", GetVehicleDoorLockStatus(vehicle))
    end)
end

function DeleteVehicle()
    hascar = false
    hasjob = false
    ox_target:removeModel(Config.oxrmbox, 'lockeropen')
    ox_target:removeGlobalVehicle('trunkadditem')
    if DoesEntityExist(spawnedVehicle) then  -- 确保车辆存在
        ESX.Game.DeleteVehicle(spawnedVehicle)
        spawnedVehicle = nil  -- 清除引用
        print("车辆已删除")
    else
        print("有可删除的车辆")
    end
end

 

function Spawnlocker()

    local selectedPos = Config.gopostalobje[math.random(#Config.gopostalobje)]
    -- 分解坐标和朝向
    local spawnCoords = vector3(selectedPos.x, selectedPos.y, selectedPos.z)
    local heading = selectedPos.w 


      exports.ox_target:addBoxZone({
        coords = spawnCoords,  
        name = "Tonyadd_money",
        -- 必须为 vector3 坐标（例如 vec3(x, y, z)）
        size = vec3(2, 2, 2),           -- 区域尺寸（长、宽、高）
        rotation = heading,             -- 旋转角度（单位：度）
        debug = true,                   -- 显示调试绿框
        drawSprite = true,              -- 显示中心点图标
        options = {
          {
            name = 'Tonyaddmoney',     -- 选项唯一标识
            event = "Tony:addmoney",    -- 触发的事件名
            icon = "fa-solid fa-cube",  -- 图标
            label = locale('A1'),       -- 本地化文本
            distance = 4.0              -- 最大交互距离
          }
        }
      })

    Lockerblip = AddBlipForCoord(selectedPos.x, selectedPos.y, selectedPos.z)
    SetBlipSprite(Lockerblip, 478)
    SetBlipColour(Lockerblip, 26)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(locale('A9'))
    EndTextCommandSetBlipName(Lockerblip)
    SetBlipRoute(Lockerblip, true)
 end


 

RegisterNetEvent('Tony:additem')
AddEventHandler('Tony:additem', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local foundObject = nil

    -- 遍历所有配置模型，寻找最近的有效对象
    for _, modelName in ipairs(Config.oxrmbox) do
        local modelHash = GetHashKey(modelName)  -- 关键修正：逐个获取模型哈希
        local object = GetClosestObjectOfType(playerCoords, 1.5, modelHash, false, false, false)

        if object ~= 0 and DoesEntityExist(object) then
            foundObject = object
            break  -- 找到第一个有效对象后退出循环
        end
    end
    if foundObject then
        -- 安全删除对象（处理网络实体）
        if NetworkGetEntityIsNetworked(foundObject) then
            DeleteEntity(foundObject)  -- 网络实体需用 DeleteEntity
        else
            SetEntityAsMissionEntity(foundObject, true, true)
            DeleteObject(foundObject)
        end
        print("✅ 目标物体已删除")
        createBox()
     
    else
        print("❌ 未找到附近的可交互箱子")
    end
end)



--[[RegisterNetEvent('Tony:Deletejobd')
AddEventHandler('Tony:Deletejobd', function()

    hasjob = false
 
    local modelHash = GetHashKey('bzzz_prop_shop_locker')  -- 获取道具哈希值
    local playerCoords = GetEntityCoords(PlayerPedId())    -- 获取玩家坐标

    -- 获取玩家附近最近的匹配对象
    local closestObject = GetClosestObjectOfType(
        playerCoords.x, 
        playerCoords.y, 
        playerCoords.z, 
        5.0,           -- 最大搜索半径（单位：米）
        modelHash, 
        false, false, false
    )

    -- 验证对象是否存在
    if DoesEntityExist(closestObject) then
        -- 设置为任务对象以便安全删除
        SetEntityAsMissionEntity(closestObject, true, true)
        -- 删除对象
        DeleteObject(closestObject)
        print("YES")
    else
        print("no")
    end
    RemoveBlip(Lockerblip)
    lib.notify({
        id = 'goobjer',
        title = locale('A6'),
        description = locale('A10'),
        showDuration = 2000,
        position = 'top',
        style = {
            backgroundColor = '#27272B',
            color = '#00AADA',
            ['.description'] = {
              color = '#00AADA'
            }
        },
        icon = 'fa-solid fa-cube',
        iconColor = '#00AADA'
    })
 
end)    ]]

-- 初始化box变量为nil（用于存储物体句柄）
local box = nil

-- 创建箱子的独立函数
function createBox()
    local hash = GetHashKey('hei_prop_heist_box')
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.5))
    
    -- 清理已存在的物体
    if DoesEntityExist(box) then
        DetachEntity(box, false, false)
        DeleteEntity(box)
        box = nil
    end

    -- 加载模型
    RequestModel(hash)
    while not HasModelLoaded(hash) do 
        Citizen.Wait(0) 
    end
    
    -- 创建并附加箱子
    box = CreateObjectNoOffset(hash, x, y, z, true, false)
    SetModelAsNoLongerNeeded(hash)
    
    -- 加载并播放动画
    LoadAnimDict("anim@heists@box_carry@")
    AttachEntityToEntity(box, ped, GetPedBoneIndex(PlayerPedId(),  60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, 0.0, false, false, true, false, 2, true)

    if not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3) then
        TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 
            8.0, 8.0, -1, 50, 0, false, false, false)
    end
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

 

-- 事件处理：添加后备箱
RegisterNetEvent('Tony:addtrunk')
AddEventHandler('Tony:addtrunk', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    --local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 6.0, 0, 70)
    --local plate = GetVehicleNumberPlateText(vehicle)
    -- 清理箱子逻辑
    if DoesEntityExist(box) then
        DetachEntity(box, false, false)
        DeleteEntity(box)
        box = nil
    end
    -- 停止动画
    ClearPedTasks(playerPed)
    RemoveAnimDict("anim@heists@box_carry@")
    -- 车辆存在时处理车牌
    TriggerServerEvent('Tony:addtrunkit')
  
end)
 

-- 资源停止时的清理
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if DoesEntityExist(box) then
            DeleteEntity(box)
        end
        RemoveAnimDict("anim@heists@box_carry@")
    end
end)


RegisterNetEvent('Tony:addmoney')
AddEventHandler('Tony:addmoney', function()
    local gopostal_package = exports.ox_inventory:Search('count', 'gopostal_package')
     if gopostal_package >= 1 then
        if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true, move = true, combat = true },
            anim = { dict = 'timetable@jimmy@doorknock@', clip = 'knockdoor_idle' },
        })then
            exports.ox_target:removeZone("Tonyadd_money")   -- 通过 name 移除
            if lib.progressCircle({
                duration = 5000,
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = { dict = 'anim@heists@box_carry@', clip = 'idle' },
                prop = { model = 'hei_prop_heist_box', bone = 60309, pos = vec3(0.025, 0.08, 0.255), rot = vec3(-145.0, 290.0, 0.0) }
            }) then
                TriggerServerEvent('Tony:slotss')
                RemoveBlip(Lockerblip)
            else 
            end
        else 
        end
    else
        RemoveBlip(Lockerblip)
        lib.notify({
            id = 'goobjer',
            description = locale('A11'),
            description = locale('A13'),
            showDuration = 2000,
            position = 'top',
            style = {
                backgroundColor = '#27272B',
                color = '#00AADA',
                ['.description'] = {
                  color = '#00AADA'
                }
            },
            icon = 'fa-solid fa-cube',
            iconColor = '#00AADA'
        })
    end  
end)    


RegisterNetEvent('Tony:rejob')
AddEventHandler('Tony:rejob', function()

    local gopostal_package = exports.ox_inventory:Search('count', 'gopostal_package')
        if gopostal_package >= 1 then
            Spawnlocker()
        else
            RemoveBlip(Lockerblip)
            lib.notify({
                id = 'goobjer',
                description = locale('A11'),
                description = locale('A12'),
                showDuration = 2000,
                position = 'top',
                style = {
                    backgroundColor = '#27272B',
                    color = '#00AADA',
                    ['.description'] = {
                      color = '#00AADA'
                    }
                },
                icon = 'fa-solid fa-cube',
                iconColor = '#00AADA'
            })
        end      
end)    