Config = {}

Config.gopostalobje = {  

  vector4(970.4670, -502.4955, 62.1409, 254.9342),
  vector4(976.6498, -580.6735, 59.8502, 218.3763),
  vector4(964.3303, -596.0832, 59.9027, 256.2140),
 

}

Config.maxSpawnAttempts = 5  -- 最大地面检测尝试次数
Config.spawnHeightOffset = 0.5 -- 初始检测高度偏移
 
Config.oxrmbox = {
  'prop_hat_box_06',  
  'bzzz_prop_custom_box_3a',  
  'bzzz_prop_custom_box_1a',
  'bzzz_prop_custom_box_2a',
} 

Config.spawnArea = {
  center = vector3(70.0, 120.0, 79.0),  -- 区域中心坐标
  radius = 5.0,                         -- 生成半径（单位：米）
  minCount = 1,                         -- 最小生成数量
  maxCount = 4                          -- 最大生成数量
}

Config.Pedlocation = {  
    {Cords = vector3(78.9427, 112.5193, 80.2), h = 158.1205},   
}

Config.Postalped = {
    `S_M_M_Postal_01`,
}

Config.vehicle = {
  vector3(60.9892, 124.7706, 79.2272),
  heading = 158.2907
}