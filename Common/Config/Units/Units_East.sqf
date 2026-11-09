_side = _this;
_faction = "East";

_c = [];
_p = [];
_n = [];
_o = [];
_t = [];
_u = [];
_f = [];
_s = [];

// Формат строки юнита:
// [класс, картинка, имя, цена, время, апгрейд]
// Если нужен скрипт или массив параметров, добавляем в конец.
_sections = [

    // --- Казармы ---
    [CTI_FACTORY_BARRACKS, [
        ["O_Soldier_SL_F", "", "", 1000, 5, 4], // Юнит для награды за ПВП
        ["O_SoldierU_SL_F", "", "", 200, 5, 4], // Для защиты городов
        ["O_soldierU_LAT_F", "", "", 300, 5, 4], // Для защиты городов
        ["O_soldierU_TL_F", "", "", 150, 2, 4], // Для защиты городов
        ["O_officer_F", "", "", 10000, 2, 1],
        ["O_Soldier_lite_F", "", "", 50, 2, 0],
        ["O_crew_F", "", "", 70, 2, 0],
        ["O_Soldier_F", "", "", 70, 2, 1],
        ["O_soldierU_F", "", "", 70, 2, 1],
        ["O_helipilot_F", "", "", 70, 2, 1],
        ["O_diver_F", "", "", 100, 2, 2],
        ["O_soldier_UAV_F", "", "", 2100, 2, 2],
        ["O_recon_F", "", "", 100, 2, 3],
        ["O_Soldier_AR_F", "", "", 100, 2, 2],
        ["O_soldierU_AR_F", "", "", 100, 2, 2],
        ["O_HeavyGunner_F", "", "", 200, 2, 3],
        ["O_Urban_HeavyGunner_F", "", "", 200, 2, 3],
        ["O_R_Patrol_Soldier_AR_F", "", "", 500, 2, 3],
        ["O_R_Soldier_LAT_F", "", "", 750, 2, 3],
        ["O_R_soldier_M_F", "", "", 500, 2, 3],
        ["O_R_JTAC_F", "", "", 500, 2, 3],
        ["O_Soldier_GL_F", "", "", 100, 2, 1],
        ["O_SoldierU_GL_F", "", "", 100, 2, 1],
        ["O_Soldier_LAT_F", "", "", 150, 2, 1],
        ["O_soldierU_LAT_F", "", "", 150, 2, 1], // Дубль с другим апгрейдом/ценой
        ["O_recon_LAT_F", "", "", 200, 2, 3],
        ["O_soldier_M_F", "", "", 125, 2, 2],
        ["O_soldierU_M_F", "", "", 125, 2, 2],
        ["O_Sharpshooter_F", "", "", 150, 2, 3],
        ["O_Urban_Sharpshooter_F", "", "", 150, 2, 3],
        ["O_recon_M_F", "", "", 150, 2, 3],
        ["O_Pathfinder_F", "", "", 180, 2, 3],
        ["O_medic_F", "", "", 100, 2, 1],
        ["O_soldierU_medic_F", "", "", 100, 2, 1],
        ["O_recon_medic_F", "", "", 120, 2, 3],
        ["O_soldier_repair_F", "", "", 100, 2, 1],
        ["O_soldierU_repair_F", "", "", 100, 2, 1],
        ["O_engineer_F", "", "", 120, 2, 2],
        ["O_engineer_U_F", "", "", 120, 2, 2],
        ["O_soldier_exp_F", "", "", 150, 2, 2],
        ["O_soldierU_exp_F", "", "", 150, 2, 2],
        ["O_recon_exp_F", "", "", 150, 2, 3],
        ["O_soldier_PG_F", "", "", 100, 2, 2],
        ["O_Soldier_AA_F", "", "", 300, 2, 3],
        ["O_soldierU_AA_F", "", "", 300, 2, 3],
        ["O_Soldier_AT_F", "", "", 450, 2, 2],
        ["O_soldierU_AT_F", "", "", 450, 2, 2],
        ["O_spotter_F", "", "", 120, 2, 3],
        ["O_recon_JTAC_F", "", "", 140, 2, 3],
        ["O_sniper_F", "", "", 200, 2, 3],
        ["O_ghillie_lsh_F", "", "", 250, 2, 3],
        ["O_ghillie_sard_F", "", "", 250, 2, 3],
        ["O_ghillie_ard_F", "", "", 250, 2, 3],
        ["O_supplyCrate_F", "", localize "STR_Mobile_Gear_Access_Crate", 100, 5, 1, "service-gear"]
    ]],

    // --- Легкий завод ---
    [CTI_FACTORY_LIGHT, [
        ["O_Quadbike_01_F", "", "", 70, 5, 0],
        ["C_Kart_01_black_F", "", "", 100, 5, 0],
        ["O_G_Offroad_01_F", "", "", 150, 5, 0],
        ["I_C_Offroad_02_unarmed_F", "", "", 200, 5, 0],
        ["O_G_Van_02_transport_F", "", "", 300, 5, 0],
        ["O_G_Van_02_vehicle_F", "", "", 300, 5, 0],
        ["C_Offroad_02_unarmed_F", "", "", 250, 5, 0],
        ["O_Truck_02_transport_F", "", "", 300, 5, 0],
        ["O_Truck_03_transport_F", "", "", 300, 5, 1],
        ["O_G_Offroad_01_armed_F", "", "", 500, 5, 1],
        ["O_MRAP_02_F", "", "", 325, 5, 0],
        ["O_MRAP_02_hmg_F", "", "", 750, 5, 1],
        ["O_MRAP_02_gmg_F", "", "", 900, 5, 1],
        ["O_LSV_02_unarmed_F", "", "", 400, 5, 1],
        ["O_LSV_02_armed_F", "", "", 600, 5, 1],
        ["O_T_LSV_02_AT_F", "", "", 1500, 5, 1],
        ["O_UGV_01_F", "", "", 500, 5, 1],
        ["O_UGV_02_Demining_F", "", "", 1000, 5, 0],
        ["O_UGV_02_Science_F", "", "", 1000, 5, 0],
        ["O_UGV_01_rcws_F", "", "", 1000, 5, 1],
        ["O_Truck_03_medical_F", "", "Mobile respawn Tempest", 2500, 5, 1, "service-medic"],
        ["O_Truck_02_medical_F", "", "Mobile respawn Kamaz", 2500, 5, 1, "service-medic"],
        ["C_IDAP_Van_02_medevac_F", "", "Mobile respawn minibus", 2500, 5, 1, "service-medic"]
    ]],

    // --- Тяжелый завод ---
    [CTI_FACTORY_HEAVY, [
        ["O_APC_Wheeled_02_rcws_F", "", "", 2000, 10, 0],
        ["O_APC_Tracked_02_cannon_F", "", "", 3500, 10, 0],
        ["O_MBT_02_cannon_F", "", "", 13000, 10, 1],
        ["O_APC_Tracked_02_AA_F", "", "", 8000, 10, 1],
        ["O_MBT_04_cannon_F", "", "", 24000, 10, 1], // Tank DLC
        ["O_MBT_04_command_F", "", "", 25000, 10, 1], // Tank DLC
        ["I_Truck_02_MRL_F", "", "", 250000, 10, 2],
        ["O_MBT_02_arty_F", "", "", 200000, 10, 2]
    ]],

    // --- Ремонтный завод ---
    [CTI_FACTORY_REPAIR, [
        ["O_Truck_02_box_F", "", "", 1000, 5, 0, "service-repairtruck"],
        ["O_Truck_03_repair_F", "", "", 1000, 5, 0, "service-repairtruck"],
        ["CTI_Salvager_East", "", "Salvage Truck", CTI_VEHICLES_SALVAGER_PRICE, 5, 0, ["O_Truck_02_covered_F", "salvager"]],
        ["CTI_Salvager_Independent_East", "", "Salvage Truck", CTI_VEHICLES_SALVAGER_PRICE, 5, 0, ["O_Truck_02_covered_F", "salvager-independent"]],
        ["O_Truck_02_fuel_F", "", "", 450, 5, 0, "service-fueltruck"],
        ["O_Truck_03_fuel_F", "", "", 500, 5, 0, "service-fueltruck"],
        ["Land_Pod_Heli_Transport_04_repair_F", "", "", 750, 5, 0, "service-repairtruck"],
        ["Land_Pod_Heli_Transport_04_fuel_F", "", "", 550, 5, 0, "service-fueltruck"]
    ]],

    // --- Склад боеприпасов ---
    [CTI_FACTORY_AMMO, [
        ["O_Truck_02_Ammo_F", "", "", 500, 5, 0, "service-ammotruck"],
        ["O_Truck_03_Ammo_F", "", "", 550, 5, 0, "service-ammotruck"],
        ["Land_Pod_Heli_Transport_04_ammo_F", "", "", 550, 5, 0, "service-ammotruck"]
    ]],

    // --- Авиабаза ---
    [CTI_FACTORY_AIR, [
        ["O_UAV_01_F", "", "", 1000, 5, 0],
        ["C_IDAP_UAV_06_antimine_F", "", "", 1250, 5, 0],
        ["O_UAV_02_dynamicLoadout_F", "", "", 7000, 6, 1],
        ["O_T_UAV_04_CAS_F", "", "", 10000, 7, 1],
        ["O_Heli_Light_02_dynamicLoadout_F", "", "", 4000, 4, 0],
        ["O_Heli_Transport_04_F", "", "", 6000, 6, 0],
        ["O_Heli_Attack_02_dynamicLoadout_F", "", "", 10000, 7, 0],
        ["O_Plane_CAS_02_dynamicLoadout_F", "", "", 12500, 8, 1],
        ["O_Plane_Fighter_02_F", "", "", 17500, 8, 1],
        ["O_Plane_Fighter_02_Stealth_F", "", "", 22500, 8, 1],
        ["O_T_VTOL_02_vehicle_dynamicLoadout_F", "", "", 15000, 8, 1],
        ["C_Heli_Light_01_civil_F", "", "", 1500, 5, 1],
        ["Land_Pod_Heli_Transport_04_medevac_F", "", "", 6000, 25, 0, "service-medic"]
    ]],

    // --- Флот ---
    [CTI_FACTORY_NAVAL, [
        ["C_Scooter_Transport_01_F", "", "", 50, 5, 0],
        ["O_Boat_Transport_01_F", "", "", 275, 5, 0],
        ["O_Boat_Armed_01_hmg_F", "", "", 750, 5, 0],
        ["O_SDV_01_F", "", "", 400, 5, 0,"service-repairtruck"] 
    ]],

    // --- Спецзавод 20, ядерное устройство ---
    [20, [
        ["Land_Device_slingloadable_F", "", localize "STR_CTI_NUKE_DEVICE_NAME", CTI_NUKE_COST_DEVICE, 10, 1]
    ]],

    // --- AAF / Independent, завод 4 ---
    [4, [
        ["I_MRAP_03_F", "", "", 300, 10, 1],
        ["I_MRAP_03_hmg_F", "", "", 750, 10, 1],
        ["I_MRAP_03_gmg_F", "", "", 900, 10, 1],
        ["I_APC_Wheeled_03_cannon_F", "", "", 2000, 10, 2],
        ["I_APC_tracked_03_cannon_F", "", "", 3000, 10, 3],
        ["I_LT_01_scout_F", "", "", 3000, 10, 2], // Tank DLC
        ["I_LT_01_cannon_F", "", "", 6000, 10, 3], // Tank DLC
        ["I_LT_01_AA_F", "", "", 6000, 10, 3], // Tank DLC
        ["I_LT_01_AT_F", "", "", 8000, 10, 3], // Tank DLC
        ["I_MBT_03_cannon_F", "", "", 10000, 10, 3],
        ["I_Heli_Transport_02_F", "", "", 3000, 10, 4],
        ["I_Heli_light_03_unarmed_F", "", "", 2500, 10, 4],
        ["I_Heli_light_03_F", "", "", 10000, 10, 4],
        ["I_UAV_02_F", "", "", 25000, 10, 5],
        ["I_Plane_Fighter_03_dynamicLoadout_F", "", "", 10000, 10, 5],
        ["I_Plane_Fighter_03_AA_F", "", "", 15000, 10, 5],
        ["I_Plane_Fighter_04_Cluster_F", "", "", 15000, 10, 5]
    ]],

    // --- Городской завод ---
    [CTI_FACTORY_TOWN, [
        ["SUV_01_base_red_F", "", "", 1000, 5, 0],
        ["C_Hatchback_01_sport_F", "", "", 2000, 5, 0],
        ["Box_East_Wps_F", "", "", 125, 5, 0],
        ["Box_East_Ammo_F", "", "", 100, 5, 0],
        ["Box_East_Support_F", "", "", 100, 5, 0],
        ["Box_East_Grenades_F", "", "", 100, 5, 0],
        ["Box_East_AmmoOrd_F", "", "", 500, 5, 0],
        ["Box_East_WpsLaunch_F", "", "", 250, 5, 0],
        ["Box_East_WpsSpecial_F", "", "", 300, 5, 0],
        ["O_Mortar_01_F", "", "", 15000, 10, 0],
        ["O_UAV_01_F", "", "", 2500, 10, 0],
        ["Land_Pod_Heli_Transport_04_box_F", "", "", 0, 0, 0]
    ]]
];

// Разбираем секции по заводам и заполняем старые массивы, которые жрет Set_Units.sqf
{
    _x params ["_factory", "_rows"];

    {
        _x params ["_class", "_pic", "_name", "_price", "_time", "_upgrade", ["_script", ""]];

        _c pushBack _class;
        _p pushBack _pic;
        _n pushBack _name;
        _o pushBack _price;
        _t pushBack _time;
        _u pushBack _upgrade;
        _f pushBack _factory;
        _s pushBack _script;
    } forEach _rows;
} forEach _sections;

[_side, _faction, _c, _p, _n, _o, _t, _u, _f, _s] call compile preprocessFileLineNumbers "Common\Config\Units\Set_Units.sqf";