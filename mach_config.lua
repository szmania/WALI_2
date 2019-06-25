
module(..., package.seeall)
--WALI_attritionMinRate = 1
--WALI_attritionMaxRate = 7
--isDebugMode = true

--NEED TO SET TO FALSE BEFORE RELEASE
__MACH_DEBUG_MODE__ = true

--MACH----------------

--MACH BATTLE CHRONICLER
__MACH_MAJOR_BATTLE_MIN_SOLDIER_CASUALTIES__ = 500 --LAND
__MACH_MAJOR_BATTLE_MIN_SHIP_CASUALTIES__ = 3 --NAVAL
__MACH_MAJOR_BATTLE_MIN_SOLDIER_ON_SHIP_CASUALTIES__ = 1 --NAVAL AMPHIBIOUS
__MACH_MAJOR_BATTLE_MIN_PERCENTAGE_OF_TOTAL_SIDE_FORCES_AS_CASUALTIES__ = 0.25

--AI Attrition rates
--MACH_AI_attritionMinRate = 1
--MACH_AI_attritionMaxRate = 7

--Long Supply Lines levels and distances 
--__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_1__ = 20
--__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_2__ = 25
--__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_3__ = 30
--__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_4__ = 35
--__MACH_LONG_SUPPLY_LINES_DISTANCE_LEVEL_5__ = 40

--Enemy army must be within this region_capital_distance from supply line to cut it off (units are x,y map coordinate units of measurement)
--MACH_distance_from_supply_line = 1.5

--__MACH_MAX_DISTANCE_ALLOWED_FROM_ENEMY_SUPPLY_LINE__ = 10
