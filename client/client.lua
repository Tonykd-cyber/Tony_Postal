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
            label = locale('A12'),
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
    local spawnCount = math.random(Config.spawnpack.minCount, Config.spawnpack.maxCount)

    for i = 1, spawnCount do
        -- 生成随机偏移坐标
        local randomAngle = math.random() * math.pi * 2  -- 0-360度弧度
        local randomDist = math.random() * Config.spawnpack.radius
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
        SetVehicleDoorsLocked(vehicle, 0)
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
local SSSlblip = nil
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


    ox_target:addBoxZone({
        coords = spawnCoords,  
        name = "Tonyadd_money",
        -- 必须为 vector3 坐标（例如 vec3(x, y, z)）
        size = vec3(2, 2, 2),           -- 区域尺寸（长、宽、高）
        rotation = heading,             -- 旋转角度（单位：度）
        debug = false,                   -- 显示调试绿框
        drawSprite = true,              -- 显示中心点图标
        options = {
          {
            name = 'Tonyaddmoney',     -- 选项唯一标识
            event = "Tony:addmoney",    -- 触发的事件名
            icon = "fa-solid fa-cube",  -- 图标
            label = locale('A15'),       -- 本地化文本
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
local hasbox = false
-- 创建箱子的独立函数
function createBox()
    hasbox = true
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
    if DoesEntityExist(box) and hasbox then
        DetachEntity(box, false, false)
        DeleteEntity(box)
        box = nil

                -- 停止动画
        ClearPedTasks(playerPed)
        RemoveAnimDict("anim@heists@box_carry@")
        -- 车辆存在时处理车牌
        TriggerServerEvent('Tony:addtrunkit')
    end
 
  
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
    local gopostal_package = ox_inventory:Search('count', 'gopostal_package')
     if gopostal_package >= 1 then
        if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true, move = true, combat = true },
            anim = { dict = 'timetable@jimmy@doorknock@', clip = 'knockdoor_idle' },
        })then
            ox_target:removeZone("Tonyadd_money")   -- 通过 name 移除
            
            if lib.progressCircle({
                duration = 5000,
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = { dict = 'anim@heists@box_carry@', clip = 'idle' },
                prop = { model = 'hei_prop_heist_box', bone = 60309, pos = vec3(0.025, 0.08, 0.255), rot = vec3(-145.0, 290.0, 0.0) }
            }) then
                 RemoveBlip(Lockerblip)
                spawnAnimatedNPC()
            else 
            end
        else 
        end
        TriggerServerEvent('Tony:slotss')

        Wait(1000)
        deleteEntities()
    else
        RemoveBlip(Lockerblip)
        lib.notify({
            id = 'goobjer',
            description = locale('A11'),
            description = locale('A14'),
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

    local gopostal_package = ox_inventory:Search('count', 'gopostal_package')
        if gopostal_package >= 1 then
            Spawnlocker()
        else
            RemoveBlip(Lockerblip)
            lib.notify({
                id = 'goobjer',
                title = locale('A11'),
                description = locale('A14'),
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

 
 






--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function spawnAnimatedNPC()
    -- 清理现有实体
    deleteEntities()

    -- 玩家实体信息
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    -- 模型配置
    local npcModel = 'a_m_m_business_01'
    local propModel = 'hei_prop_heist_box'
    local animDict = 'anim@heists@box_carry@'
    
    -- 加载模型
    if not lib.requestModel(npcModel, 5000) then
        print("^1错误：NPC模型加载失败")
        return
    end
    
    if not lib.requestModel(propModel, 5000) then
        print("^1错误：道具模型加载失败")
        return
    end

    -- 生成位置计算（玩家正前方2米）
    local forwardVector = GetEntityForwardVector(playerPed)
    local spawnPos = playerCoords + (forwardVector * 0.65)
    spawnPos = vector3(spawnPos.x, spawnPos.y, playerCoords.z) -- 保持相同高度

    -- 创建NPC
    currentNPC = CreatePed(4, npcModel, spawnPos.x, spawnPos.y, spawnPos.z-1.0, 0.0, true, true)
    SetEntityAsMissionEntity(currentNPC, true, true)
    FreezeEntityPosition(currentNPC, false)
    SetBlockingOfNonTemporaryEvents(currentNPC, true)

    -- 初始面向玩家
    TaskTurnPedToFaceEntity(currentNPC, playerPed, -1)
     Wait(1000)
    -- 加载动画
    if not lib.requestAnimDict(animDict, 5000) then
        print("^1错误：动画字典加载失败")
        return
    end

    -- 创建并附加道具
    currentProp = CreateObject(propModel, 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(
        currentProp,
        currentNPC,
        GetPedBoneIndex(currentNPC, 60309), -- 右手骨骼
        0.025, 0.08, 0.255,    -- 位置偏移
        -145.0, 290.0, 0.0,     -- 旋转角度
        true, true, false, true, 1, true
    )

    -- 播放动画
    TaskPlayAnim(
        currentNPC,
        animDict,
        'idle',
        8.0,
        -8.0,
        -1,
        1, -- 循环播放
        0,
        false,
        false,
        false
    )
    -- 启动持续面向系统
   -- startFacingSystem()
    -- 启动状态监控
    startEntityMonitor()
    
    print("^2成功生成携带箱子的NPC")
end
 

function deleteEntities()
    -- 停止面向线程
    if faceThread then
        Citizen.Trash(faceThread)
        faceThread = nil
    end
    
    -- 删除道具
    if currentProp and DoesEntityExist(currentProp) then
        DeleteEntity(currentProp)
        currentProp = nil
        print("^3已删除道具")
    end
    
    -- 删除NPC
    if currentNPC and DoesEntityExist(currentNPC) then
        DeleteEntity(currentNPC)
        currentNPC = nil
        print("^3已删除NPC")
    end
end


function startEntityMonitor()
    Citizen.CreateThread(function()
        while currentNPC and DoesEntityExist(currentNPC) do
            Citizen.Wait(5000) -- 每5秒检查一次
            
            -- 玩家坐标
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            -- NPC状态检查
            if IsEntityDead(currentNPC) then
                print("^3检测到NPC死亡，自动清理...")
                deleteEntities()
                break
            end
            
            -- 距离检查（超过50米自动清理）
            local npcCoords = GetEntityCoords(currentNPC)
            if #(playerCoords - npcCoords) > 50.0 then
                print("^3玩家距离过远，自动清理NPC")
                deleteEntities()
                break
            end
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteEntities()
        print("^3资源停止，已清理所有实体")
    end
end)


function startFacingSystem()
    if faceThread then return end
    
    faceThread = Citizen.CreateThread(function()
        while currentNPC and DoesEntityExist(currentNPC) do
            local playerPed = PlayerPedId()
            
            -- 平滑转向（每100ms更新）
            TaskTurnPedToFaceEntity(currentNPC, playerPed, -1)
            
            -- 保持身体正对玩家
            SetPedDesiredHeading(currentNPC, GetEntityHeading(playerPed))
            
            Citizen.Wait(100)
        end
        faceThread = nil
    end)
end