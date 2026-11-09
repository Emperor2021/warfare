_side = _this;
_faction = "West";

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
// Если нужен скрипт, добавляем его в конец строки.
_sections = [

    // --- Казармы ---
    [CTI_FACTORY_BARRACKS, [
        ["B_Soldier_SL_F", "", "", 1000, 2, 4], // Юнит для награды за ПВП
        ["B_soldier_LAT2_F", "", "", 300, 2, 1],
        ["B_officer_F", "", "", 1000, 2, 1],
        ["B_Soldier_lite_F", "", "", 50, 2, 0],
        ["B_crew_F", "", "", 70, 2, 0],
        ["B_Soldier_F", "", "", 70, 2, 1],
        ["B_Helipilot_F", "", "", 70, 2, 1],
        ["B_diver_F", "", "", 100, 2, 2],
        ["B_soldier_UAV_F", "", "", 2100, 2, 2],
        ["B_recon_F", "", "", 100, 2, 3],
        ["B_soldier_AR_F", "", "", 100, 2, 2],
        ["B_HeavyGunner_F", "", "", 200, 2, 3],
        ["B_Soldier_GL_F", "", "", 100, 2, 1],
        ["B_soldier_LAT_F", "", "", 150, 2, 1],
        ["B_recon_LAT_F", "", "", 200, 2, 3],
        ["B_soldier_M_F", "", "", 125, 2, 2],
        ["B_Sharpshooter_F", "", "", 150, 2, 3],
        ["B_recon_M_F", "", "", 150, 2, 3],
        ["B_Recon_Sharpshooter_F", "", "", 180, 2, 3],
        ["B_medic_F", "", "", 100, 2, 1],
        ["B_recon_medic_F", "", "", 120, 2, 3],
        ["B_soldier_repair_F", "", "", 100, 2, 1],
        ["B_engineer_F", "", "", 120, 2, 2],
        ["B_soldier_exp_F", "", "", 150, 2, 2],
        ["B_recon_exp_F", "", "", 150, 2, 3],
        ["B_soldier_PG_F", "", "", 100, 2, 2],
        ["B_soldier_AA_F", "", "", 300, 2, 3],
        ["B_soldier_AT_F", "", "", 450, 2, 2],
        ["B_spotter_F", "", "", 120, 2, 3],
        ["B_recon_JTAC_F", "", "", 140, 2, 3],
        ["B_sniper_F", "", "", 200, 2, 3],
        ["B_ghillie_lsh_F", "", "", 250, 2, 3],
        ["B_ghillie_sard_F", "", "", 250, 2, 3],
        ["B_ghillie_ard_F", "", "", 250, 2, 3],
        ["B_supplyCrate_F", "", localize "STR_Mobile_Gear_Access_Crate", 100, 5, 1, "service-gear"]
    ]],

    // --- Легкий завод ---
    [CTI_FACTORY_LIGHT, [
        ["B_Quadbike_01_F", "", "", 70, 5, 0],
        ["C_Kart_01_black_F", "", "", 100, 5, 0],
        ["I_C_Offroad_02_unarmed_F", "", "", 200, 5, 0],
        ["C_Offroad_02_unarmed_F", "", "", 250, 5, 0],
        ["SUV_01_base_black_F", "", "", 500, 5, 0],
        ["B_G_Van_02_transport_F", "", "", 300, 5, 0],
        ["B_G_Van_02_vehicle_F", "", "", 300, 5, 0],
        ["B_G_Offroad_01_F", "", "Offroad (can load statics)", 250, 5, 0],
        ["B_G_Offroad_01_armed_F", "", "", 500, 5, 1],
        ["B_Truck_01_transport_F", "", "", 400, 5, 0],
        ["B_MRAP_01_F", "", "", 325, 5, 0],
        ["B_MRAP_01_hmg_F", "", "", 750, 5, 1],
        ["B_MRAP_01_gmg_F", "", "", 900, 5, 1],
        ["B_CTRG_LSV_01_light_F", "", "", 300, 5, 1],
        ["B_LSV_01_unarmed_F", "", "", 400, 5, 1],
        ["B_LSV_01_armed_F", "", "", 650, 5, 1],
        ["B_T_LSV_01_AT_F", "", "", 1500, 5, 1],
        ["B_Truck_01_medical_F", "", "Mobile respawn HEMTT", 2500, 5, 1, "service-medic"],
        ["C_Van_02_medevac_F", "", "Mobile respawn minibus", 2500, 5, 1, "service-medic"],
        ["B_UGV_01_F", "", "", 500, 5, 1],
        ["B_UGV_01_rcws_F", "", "", 1000, 5, 1],
        ["B_UGV_02_Demining_F", "", "", 1000, 5, 0],
        ["B_UGV_02_Science_F", "", "", 1000, 5, 0]
    ]],

    // --- Тяжелый завод ---
    [CTI_FACTORY_HEAVY, [
        ["B_APC_Wheeled_01_cannon_F", "", "", 2000, 10, 0],
        ["B_APC_Tracked_01_CRV_F", "", "", 3000, 10, 0, "service-repairtruck"],
        ["B_APC_Tracked_01_rcws_F", "", "", 3500, 10, 1],
        ["B_AFV_Wheeled_01_cannon_F", "", "", 6000, 10, 1],
        ["B_AFV_Wheeled_01_up_cannon_F", "", "", 7000, 10, 1],
        ["B_MBT_01_cannon_F", "", "", 8000, 10, 1],
        ["B_MBT_01_TUSK_F", "", "", 8500, 10, 1],
        ["B_APC_Tracked_01_AA_F", "", "", 6500, 10, 1],
        ["B_MBT_01_arty_F", "", "", 200000, 10, 2],
        ["B_MBT_01_mlrs_F", "", "", 250000, 10, 2]
    ]],

    // --- Ремонтный завод ---
    [CTI_FACTORY_REPAIR, [
        ["B_Truck_01_Repair_F", "", "", 1000, 5, 0, "service-repairtruck"],
        ["CTI_Salvager_West", "", "Salvage Truck", CTI_VEHICLES_SALVAGER_PRICE, 5, 0, ["B_Truck_01_box_F", "salvager"]],
        ["CTI_Salvager_Independent_West", "", "Salvager", CTI_VEHICLES_SALVAGER_PRICE, 5, 0, ["B_Truck_01_box_F", "salvager-independent"]],
        ["B_G_Van_01_fuel_F", "", "", 700, 5, 0, "service-fueltruck"],
        ["B_Truck_01_fuel_F", "", "", 500, 5, 0, "service-fueltruck"],
        ["B_Slingload_01_Repair_F", "", "", 750, 5, 0, "service-repairtruck"],
        ["B_Slingload_01_Fuel_F", "", "", 550, 5, 0, "service-fueltruck"],
        ["B_Truck_01_mover_F", "", "", 300, 5, 0]
    ]],

    // --- Склад боеприпасов ---
    [CTI_FACTORY_AMMO, [
        ["B_Truck_01_ammo_F", "", "", 550, 5, 0, "service-ammotruck"],
        ["B_Slingload_01_Ammo_F", "", "", 550, 5, 0, "service-ammotruck"]
    ]],

    // --- Авиабаза ---
    [CTI_FACTORY_AIR, [
        ["B_UAV_01_F", "", "", 1000, 5, 0],
        ["C_IDAP_UAV_06_antimine_F", "", "", 1250, 5, 0],
        ["B_UAV_05_F", "", "", 6000, 6, 0],
        ["B_UAV_02_dynamicLoadout_F", "", "", 8500, 6, 1],
        ["B_T_UAV_03_dynamicLoadout_F", "", "", 5000, 7, 1],
        ["B_Heli_Light_01_F", "", "", 1500, 4, 0],
        ["B_Heli_Light_01_dynamicLoadout_F", "", "", 3000, 4, 0],
        ["B_Heli_Attack_01_dynamicLoadout_F", "", "", 9000, 7, 0],
        ["B_Heli_Attack_01_pylons_dynamicLoadout_F", "", "", 11000, 8, 0],
        ["B_Heli_Transport_01_F", "", "", 4000, 5, 0],
        ["B_Heli_Transport_01_pylons_F", "", "", 5000, 5, 0],
        ["B_Heli_Transport_03_F", "", "", 7000, 6, 0],
        ["B_Heli_Transport_03_unarmed_F", "", "", 6000, 10, 0],
        ["B_CTRG_Heli_Transport_01_Assault_F", "", "", 4000, 6, 0],
        ["B_CTRG_Heli_Transport_01_DAP_F", "", "", 6000, 6, 0],
        ["B_Plane_CAS_01_dynamicLoadout_F", "", "", 12500, 8, 1],
        ["B_Plane_Fighter_01_F", "", "", 17500, 8, 1],
        ["B_Plane_Fighter_01_Stealth_F", "", "", 22500, 8, 1],
        ["B_Plane_Fighter_01_Cluster_F", "", "", 20000, 8, 1],
        ["B_T_VTOL_01_armed_F", "", "", 15000, 8, 1],
        ["C_Heli_Light_01_civil_F", "", "", 1500, 5, 1],
        ["B_Slingload_01_Medevac_F", "", "", 6000, 10, 0, "service-medic"]
    ]],

    // --- Флот ---
    [CTI_FACTORY_NAVAL, [
        ["C_Scooter_Transport_01_F", "", "", 50, 5, 0],
        ["B_Boat_Transport_01_F", "", "", 275, 5, 0],
        ["B_Boat_Armed_01_minigun_F", "", "", 750, 5, 0],
        ["B_SDV_01_F", "", "", 400, 5, 0,"service-repairtruck"]
    ]],

    // --- Спецзавод 20, устройство ---
    [20, [
        ["Land_Device_slingloadable_F", "", localize "STR_CTI_NUKE_DEVICE_NAME", CTI_NUKE_COST_DEVICE, 10, 1]
    ]],

    // --- AAF / Independent, завод 4 ---
    [4, [
        ["I_MRAP_03_F", "", "", 250, 10, 1],
        ["I_MRAP_03_hmg_F", "", "", 750, 10, 1],
        ["I_MRAP_03_gmg_F", "", "", 900, 10, 1],
        ["I_APC_Wheeled_03_cannon_F", "", "", 2000, 10, 2],
        ["I_APC_tracked_03_cannon_F", "", "", 3000, 10, 3],
        ["I_LT_01_scout_F", "", "", 3000, 10, 2],
        ["I_LT_01_cannon_F", "", "", 5000, 10, 3],
        ["I_LT_01_AA_F", "", "", 6000, 10, 3],
        ["I_LT_01_AT_F", "", "", 6000, 10, 3],
        ["I_MBT_03_cannon_F", "", "", 10000, 10, 3],
        ["I_Heli_Transport_02_F", "", "", 3000, 10, 4],
        ["I_Heli_light_03_unarmed_F", "", "", 2500, 10, 4],
        ["I_Heli_light_03_F", "", "", 10000, 10, 4],
        ["I_UAV_02_F", "", "", 15000, 10, 5],
        ["I_Plane_Fighter_03_dynamicLoadout_F", "", "", 10000, 10, 5],
        ["I_Plane_Fighter_03_AA_F", "", "", 15000, 10, 5],
        ["I_Plane_Fighter_04_Cluster_F", "", "", 15000, 10, 5]
    ]],

    // --- Городской завод ---
    [CTI_FACTORY_TOWN, [
        ["SUV_01_base_blue_F", "", "", 1000, 5, 0],
        ["C_Hatchback_01_sport_F", "", "", 2000, 5, 0],
        ["SUV_01_base_black_F", "", "", 1000, 5, 0],
        ["Box_NATO_Wps_F", "", "", 125, 5, 0],
        ["Box_NATO_Ammo_F", "", "", 100, 5, 0],
        ["Box_NATO_Support_F", "", "", 100, 5, 0],
        ["Box_NATO_Grenades_F", "", "", 100, 5, 0],
        ["Box_NATO_AmmoOrd_F", "", "", 500, 5, 0],
        ["Box_NATO_WpsLaunch_F", "", "", 250, 5, 0],
        ["Box_NATO_WpsSpecial_F", "", "", 300, 5, 0],
        ["B_Mortar_01_F", "", "", 15000, 10, 0],
        ["B_UAV_01_F", "", "", 2500, 10, 0],
        ["B_Slingload_01_Cargo_F", "", "", 0, 0, 0]
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