Config = {}

Config.gopostalobje = {  

  vector4(1060.4889, -378.1317, 68.2313, 48.3326),
  vector4(1028.8602, -408.2969, 66.3425, 38.1079),
  vector4(1010.4637, -423.5045, 65.3494, 117.6839),
  vector4(987.5757, -432.9303, 64.0412, 51.4224),
  vector4(967.1385, -451.5782, 62.7978, 39.5373),
  vector4(944.3016, -462.8917, 61.5542, 154.4395),
  vector4(979.3597, -716.3156, 58.2207, 309.9942),
  vector4(996.8094, -729.5106, 57.8157, 333.2104),
  vector4(1221.5823, -669.2777, 63.5389, 35.1073),
  vector4(1265.4871, -648.7433, 68.1332, 61.8990),

  vector4(970.7747, -701.5103, 58.4820, 345.9739),
  vector4(960.0242, -669.7945, 58.4498, 267.2583),
  vector4(943.5176, -653.5245, 58.4287, 198.6815),
  vector4(928.7411, -639.7695, 58.2425, 306.7582),

}

Config.maxSpawnAttempts = 5  -- 最大地面检测尝试次数
Config.spawnHeightOffset = 0.5 -- 初始检测高度偏移
 
Config.oxrmbox = {
  'prop_hat_box_06',  
  'bzzz_prop_custom_box_3a',  
  'bzzz_prop_custom_box_1a',
  'bzzz_prop_custom_box_2a',
} 

Config.spawnpack = {
  center = vector3(-531.2314, 5290.2490, 74.2039),  -- 区域中心坐标
  radius = 5.0,                                      -- 生成半径（单位：米）
  minCount = 1,                                      -- 最小生成数量
  maxCount = 6                                        -- 最大生成数量
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