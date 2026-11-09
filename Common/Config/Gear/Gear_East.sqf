private ["_faction", "_i", "_p", "_side", "_u", "_addGear"];

_side = _this;
_faction = "East";

_i = [];
_u = [];
_p = [];

// ==============================================================================
// ЛОКАЛЬНАЯ ХЕЛПЕР-ФУНКЦИЯ (ОПТИМИЗАЦИЯ ПАМЯТИ И ЧИТОКОД)
// Избегаем O(N^2) при конкатенации массивов через '+'
// ==============================================================================
_addGear = {
    params ["_class", "_upgrade", "_price"];
    _i pushBack _class;
    _u pushBack _upgrade;
    _p pushBack _price;
};

// ==========================================
// 1. ВЗРЫВЧАТКА И МИНЫ (EXPLOSIVES)
// ==========================================
["APERSMineDispenser_Mag", 1, 500] call _addGear;
["ATMine_Range_Mag", 1, 100] call _addGear;
["APERSMine_Range_Mag", 1, 10] call _addGear;
["APERSBoundingMine_Range_Mag", 1, 10] call _addGear;
["SLAMDirectionalMine_Wire_Mag", 2, 10] call _addGear;
["APERSTripMine_Wire_Mag", 1, 5] call _addGear;
["SatchelCharge_Remote_Mag", 2, 20] call _addGear;
["DemoCharge_Remote_Mag", 1, 15] call _addGear;
["ClaymoreDirectionalMine_Remote_Mag", 2, 10] call _addGear;
["Laserbatteries", 2, 20] call _addGear;

// ==========================================
// 2. ПАТРОНЫ ДЛЯ ПИСТОЛЕТОВ И ПП (PISTOL & SMG AMMO)
// ==========================================
["10Rnd_9x21_Mag", 0, 10] call _addGear;
["16Rnd_9x21_Mag", 0, 20] call _addGear;
["6Rnd_45ACP_Cylinder", 1, 20] call _addGear;
["6Rnd_GreenSignal_F", 0, 20] call _addGear;
["6Rnd_RedSignal_F", 0, 20] call _addGear;
["30Rnd_9x21_Mag_SMG_02_Tracer_Green", 0, 10] call _addGear;
["30Rnd_9x21_Mag", 0, 10] call _addGear;
["30Rnd_9x21_Red_Mag", 0, 10] call _addGear;
["30Rnd_545x39_Mag_Green_F", 0, 20] call _addGear;
["30Rnd_545x39_Mag_Tracer_Green_F", 0, 20] call _addGear;
["75rnd_762x39_AK12_Mag_F", 1, 200] call _addGear;

// ==========================================
// 3. ПАТРОНЫ ДЛЯ ШТУРМОВЫХ ВИНТОВОК (RIFLE AMMO)
// ==========================================
["30Rnd_556x45_Stanag_green", 0, 10] call _addGear;
["30Rnd_556x45_Stanag_Tracer_Green", 0, 5] call _addGear;
["30Rnd_762x39_Mag_Green_F", 1, 20] call _addGear;
["30Rnd_762x39_AK12_Mag_F", 1, 20] call _addGear;
["30Rnd_762x39_Mag_Tracer_Green_F", 1, 15] call _addGear;
["30Rnd_65x39_caseless_green", 1, 30] call _addGear;
["30Rnd_65x39_caseless_green_mag_Tracer", 1, 25] call _addGear;
["30Rnd_580x42_Mag_F", 1, 15] call _addGear;
["30Rnd_580x42_Mag_Tracer_F", 1, 10] call _addGear;
["10Rnd_50BW_Mag_F", 3, 100] call _addGear;
["20Rnd_556x45_UW_mag", 2, 100] call _addGear;

// ==========================================
// 4. ПАТРОНЫ ДЛЯ ПУЛЕМЕТОВ (MG AMMO)
// ==========================================
["150Rnd_762x54_Box", 2, 100] call _addGear;
["150Rnd_762x54_Box_Tracer", 2, 90] call _addGear;
["150Rnd_93x64_Mag", 3, 200] call _addGear;
["100Rnd_580x42_Mag_F", 1, 30] call _addGear;
["100Rnd_580x42_Mag_Tracer_F", 1, 25] call _addGear;

// ==========================================
// 5. ПАТРОНЫ ДЛЯ СНАЙПЕРОК (SNIPER AMMO)
// ==========================================
["10Rnd_762x54_Mag", 2, 100] call _addGear;
["20Rnd_650x39_Cased_Mag_F", 2, 100] call _addGear;
["10Rnd_93x64_DMR_05_Mag", 3, 150] call _addGear;
["10Rnd_127x54_Mag", 3, 150] call _addGear;
["5Rnd_127x108_Mag", 3, 250] call _addGear;
["5Rnd_127x108_APDS_Mag", 3, 250] call _addGear;

// ==========================================
// 6. ВЫСТРЕЛЫ ДЛЯ ГРАНАТОМЕТОВ (LAUNCHER AMMO)
// ==========================================
["RPG7_F", 0, 25] call _addGear;
["RPG32_F", 1, 100] call _addGear;
["RPG32_HE_F", 1, 50] call _addGear;
["Titan_AA", 2, 250] call _addGear;
["Titan_AP", 2, 100] call _addGear;
["Titan_AT", 3, 400] call _addGear;
["Vorona_HEAT", 3, 500] call _addGear;
["Vorona_HE", 2, 100] call _addGear;


// ==========================================
// 7. ГРАНАТЫ, ДЫМЫ И ХИС (THROWABLES)
// ==========================================
["HandGrenade", 1, 100] call _addGear;
["MiniGrenade", 0, 50] call _addGear;
["O_IR_Grenade", 2, 40] call _addGear;
["SmokeShellBlue", 0, 50] call _addGear;
["SmokeShellGreen", 0, 50] call _addGear;
["SmokeShellOrange", 0, 50] call _addGear;
["SmokeShellPurple", 0, 50] call _addGear;
["SmokeShellRed", 0, 50] call _addGear;
["SmokeShell", 0, 50] call _addGear;
["SmokeShellYellow", 0, 50] call _addGear;
["Chemlight_green", 0, 10] call _addGear;
["Chemlight_red", 0, 10] call _addGear;
["Chemlight_yellow", 0, 10] call _addGear;
["Chemlight_blue", 0, 10] call _addGear;

// ==========================================
// 8. ПОДСТВОЛЬНЫЕ ГРАНАТОМЕТЫ (GL AMMO)
// ==========================================
["1Rnd_HE_Grenade_shell", 1, 50] call _addGear;
["1Rnd_Smoke_Grenade_shell", 1, 10] call _addGear;
["1Rnd_SmokeRed_Grenade_shell", 1, 10] call _addGear;
["1Rnd_SmokeGreen_Grenade_shell", 1, 10] call _addGear;
["1Rnd_SmokeYellow_Grenade_shell", 1, 10] call _addGear;
["1Rnd_SmokePurple_Grenade_shell", 1, 10] call _addGear;
["1Rnd_SmokeBlue_Grenade_shell", 1, 10] call _addGear;
["1Rnd_SmokeOrange_Grenade_shell", 1, 10] call _addGear;
["UGL_FlareWhite_F", 0, 10] call _addGear;
["UGL_FlareGreen_F", 0, 10] call _addGear;
["UGL_FlareRed_F", 0, 10] call _addGear;
["UGL_FlareYellow_F", 0, 10] call _addGear;
["UGL_FlareCIR_F", 1, 10] call _addGear;

// ==========================================
// 9. ОРУЖИЕ (WEAPONS)
// ==========================================

// --- Пистолеты ---
["hgun_Pistol_01_F", 0, 5] call _addGear;
["hgun_Rook40_F", 1, 10] call _addGear;
["hgun_Pistol_heavy_02_F", 2, 20] call _addGear;
["hgun_Pistol_Signal_F", 0, 15] call _addGear;

// --- Пистолеты-пулеметы (ПП) ---
["hgun_PDW2000_F", 0, 10] call _addGear;
["SMG_02_F", 0, 10] call _addGear;

// --- Пулеметы ---
["LMG_Zafir_F", 2, 150] call _addGear;
["arifle_RPK12_F", 2, 1000] call _addGear; // Ручной пулемет
["MMG_01_hex_F", 3, 400] call _addGear;
["MMG_01_tan_F", 3, 400] call _addGear;

// --- Штурмовые винтовки ---
["arifle_AKS_F", 0, 30] call _addGear;
["arifle_TRG21_F", 0, 40] call _addGear;
["arifle_TRG21_GL_F", 0, 50] call _addGear;
["arifle_AKM_F", 1, 30] call _addGear;
["arifle_Katiba_C_F", 1, 50] call _addGear;
["arifle_Katiba_F", 1, 100] call _addGear;
["arifle_Katiba_GL_F", 1, 125] call _addGear;
["arifle_CTAR_blk_F", 1, 20] call _addGear;
["arifle_CTAR_ghex_F", 1, 20] call _addGear;
["arifle_CTAR_hex_F", 1, 20] call _addGear;
["arifle_CTAR_GL_blk_F", 1, 30] call _addGear;
["arifle_CTAR_GL_ghex_F", 1, 30] call _addGear;
["arifle_CTAR_GL_hex_F", 1, 30] call _addGear;
["arifle_CTARS_blk_F", 1, 50] call _addGear;
["arifle_CTARS_ghex_F", 1, 50] call _addGear;
["arifle_CTARS_hex_F", 1, 50] call _addGear;
["arifle_AK12_F", 2, 100] call _addGear;
["arifle_AK12_GL_F", 2, 100] call _addGear;
["arifle_SDAR_F", 2, 100] call _addGear;
["arifle_ARX_blk_F", 3, 250] call _addGear;
["arifle_ARX_ghex_F", 3, 250] call _addGear;
["arifle_ARX_hex_F", 3, 250] call _addGear;

// --- Снайперские винтовки и Марксманки ---
["srifle_DMR_01_F", 2, 200] call _addGear;
["srifle_DMR_07_blk_F", 2, 200] call _addGear;
["srifle_DMR_07_ghex_F", 2, 200] call _addGear;
["srifle_DMR_07_hex_F", 2, 200] call _addGear;
["srifle_DMR_04_F", 3, 250] call _addGear;
["srifle_DMR_04_Tan_F", 3, 250] call _addGear;
["srifle_DMR_05_blk_F", 3, 300] call _addGear;
["srifle_DMR_05_hex_F", 3, 300] call _addGear;
["srifle_DMR_05_tan_f", 3, 300] call _addGear;
["srifle_GM6_F", 3, 500] call _addGear;
["srifle_GM6_camo_F", 3, 500] call _addGear;
["srifle_GM6_ghex_F", 3, 500] call _addGear;

// --- Пусковые установки ---
["launch_RPG7_F", 0, 100] call _addGear;
["launch_RPG32_F", 1, 200] call _addGear;
["launch_RPG32_ghex_F", 1, 200] call _addGear;
["launch_O_Vorona_brown_F", 2, 400] call _addGear;
["launch_O_Vorona_green_F", 2, 400] call _addGear;
["launch_O_Titan_short_F", 3, 500] call _addGear;
["launch_O_Titan_short_ghex_F", 3, 500] call _addGear;
["launch_O_Titan_F", 3, 500] call _addGear;
["launch_O_Titan_ghex_F", 3, 500] call _addGear;

// ==========================================
// 10. ОДЕЖДА (UNIFORMS)
// ==========================================
["U_O_V_Soldier_Viper_F", 3, 500] call _addGear;
["U_O_V_Soldier_Viper_hex_F", 3, 500] call _addGear;
["U_O_FullGhillie_ard", 3, 350] call _addGear;
["U_O_T_FullGhillie_tna_F", 3, 350] call _addGear;
["U_O_FullGhillie_lsh", 3, 350] call _addGear;
["U_O_FullGhillie_sard", 3, 350] call _addGear;
["U_O_GhillieSuit", 2, 200] call _addGear;
["U_O_T_Sniper_F", 2, 200] call _addGear;
["U_O_PilotCoveralls", 2, 150] call _addGear;
["U_O_CombatUniform_ocamo", 2, 100] call _addGear;
["U_O_SpecopsUniform_ocamo", 2, 100] call _addGear;
["U_O_CombatUniform_oucamo", 2, 100] call _addGear;
["U_O_T_Soldier_F", 2, 100] call _addGear;
["U_O_T_Officer_F", 1, 20] call _addGear;
["U_O_OfficerUniform_ocamo", 0, 20] call _addGear;
["U_O_Wetsuit", 2, 50] call _addGear;

// ==========================================
// 11. БРОНИКИ (VESTS)
// ==========================================
["V_TacVest_blk", 3, 300] call _addGear;
["V_TacVest_brn", 3, 300] call _addGear;
["V_TacVest_camo", 3, 300] call _addGear;
["V_TacVest_khk", 3, 300] call _addGear;
["V_TacVest_oli", 3, 300] call _addGear;
["V_HarnessOGL_brn", 2, 100] call _addGear;
["V_HarnessOGL_ghex_F", 2, 100] call _addGear;
["V_HarnessOGL_gry", 2, 100] call _addGear;
["V_HarnessO_brn", 2, 150] call _addGear;
["V_HarnessO_ghex_F", 2, 150] call _addGear;
["V_HarnessO_gry", 2, 150] call _addGear;
["V_BandollierB_cbr", 1, 50] call _addGear;
["V_BandollierB_ghex_F", 1, 50] call _addGear;
["V_RebreatherIR", 2, 100] call _addGear;

// ==========================================
// 12. РЮКЗАКИ (BACKPACKS)
// ==========================================
["B_Bergen_dgtl_F", 3, 500] call _addGear;
["B_Bergen_hex_F", 3, 500] call _addGear;
["B_Carryall_cbr", 3, 200] call _addGear;
["B_Carryall_ghex_F", 3, 200] call _addGear;
["B_Carryall_ocamo", 3, 200] call _addGear;
["B_Carryall_khk", 3, 200] call _addGear;
["B_Carryall_oli", 3, 200] call _addGear;
["B_Carryall_oucamo", 3, 200] call _addGear;
["O_UAV_01_backpack_F", 3, 2000] call _addGear;
["B_ViperHarness_blk_F", 2, 200] call _addGear;
["B_ViperHarness_ghex_F", 2, 200] call _addGear;
["B_ViperHarness_hex_F", 2, 200] call _addGear;
["B_ViperHarness_khk_F", 2, 200] call _addGear;
["B_ViperHarness_oli_F", 2, 200] call _addGear;
["B_Kitbag_cbr", 2, 150] call _addGear;
["B_Kitbag_rgr", 2, 150] call _addGear;
["B_Kitbag_sgg", 2, 150] call _addGear;
["B_ViperLightHarness_blk_F", 2, 100] call _addGear;
["B_ViperLightHarness_ghex_F", 2, 100] call _addGear;
["B_ViperLightHarness_hex_F", 2, 100] call _addGear;
["B_ViperLightHarness_khk_F", 2, 100] call _addGear;
["B_ViperLightHarness_oli_F", 2, 100] call _addGear;

if !(MADE_FOR_STRATIS) then {
	["O_Mortar_01_support_F", 3, 5] call _addGear;
	["O_Mortar_01_weapon_F", 3, 9995] call _addGear;
};

["B_FieldPack_blk", 1, 50] call _addGear;
["B_FieldPack_cbr", 1, 50] call _addGear;
["B_FieldPack_ghex_F", 1, 50] call _addGear;
["B_FieldPack_ocamo", 1, 50] call _addGear;
["B_FieldPack_khk", 1, 50] call _addGear;
["B_FieldPack_oli", 1, 50] call _addGear;
["B_FieldPack_oucamo", 1, 50] call _addGear;
["B_Parachute", 1, 100] call _addGear;
["O_Static_Designator_02_weapon_F", 2, 500] call _addGear;

// ==========================================
// 13. ШЛЕМЫ И ШАПКИ (HEADGEAR)
// ==========================================
["H_HelmetO_ViperSP_hex_F", 3, 1500] call _addGear;
["H_HelmetO_ViperSP_ghex_F", 3, 1500] call _addGear;
["H_HelmetLeaderO_ghex_F", 3, 100] call _addGear;
["H_HelmetLeaderO_ocamo", 3, 100] call _addGear;
["H_HelmetLeaderO_oucamo", 3, 100] call _addGear;
["H_PilotHelmetFighter_O", 3, 300] call _addGear;
["H_HelmetSpecO_blk", 2, 50] call _addGear;
["H_HelmetSpecO_ghex_F", 2, 50] call _addGear;
["H_HelmetSpecO_ocamo", 2, 50] call _addGear;
["H_HelmetCrew_O_ghex_F", 1, 30] call _addGear;
["H_HelmetCrew_O", 1, 30] call _addGear;
["H_HelmetO_ghex_F", 1, 30] call _addGear;
["H_HelmetO_ocamo", 1, 30] call _addGear;
["H_HelmetO_oucamo", 1, 30] call _addGear;
["H_PilotHelmetHeli_O", 1, 40] call _addGear;
["H_CrewHelmetHeli_O", 1, 50] call _addGear;
["H_Bandanna_gry", 0, 5] call _addGear;
["H_Bandanna_cbr", 0, 5] call _addGear;
["H_Bandanna_sgg", 0, 5] call _addGear;
["H_Bandanna_camo", 0, 5] call _addGear;
["H_Watchcap_blk", 0, 10] call _addGear;
["H_Watchcap_cbr", 0, 10] call _addGear;
["H_Watchcap_camo", 0, 10] call _addGear;
["H_Watchcap_khk", 0, 10] call _addGear;
["H_Beret_ocamo", 0, 15] call _addGear;
["H_Cap_grn_BI", 0, 20] call _addGear;
["H_Cap_blk", 0, 20] call _addGear;
["H_Cap_grn", 0, 20] call _addGear;
["H_Cap_tan", 0, 20] call _addGear;
["H_Cap_brn_SPECOPS", 0, 5] call _addGear;
["H_MilCap_ghex_F", 0, 30] call _addGear;
["H_MilCap_ocamo", 0, 30] call _addGear;
["H_ShemagOpen_tan", 0, 20] call _addGear;

// ==========================================
// 14. ОЧКИ И МАСКИ (GLASSES)
// ==========================================
["G_Tactical_Black", 1, 100] call _addGear;
["G_Balaclava_blk", 0, 5] call _addGear;
["G_Balaclava_combat", 0, 5] call _addGear;
["G_Balaclava_lowprofile", 0, 5] call _addGear;
["G_Balaclava_oli", 0, 5] call _addGear;
["G_Bandanna_aviator", 0, 5] call _addGear;
["G_Bandanna_beast", 0, 5] call _addGear;
["G_Bandanna_blk", 0, 5] call _addGear;
["G_Bandanna_khk", 0, 5] call _addGear;
["G_Bandanna_oli", 0, 5] call _addGear;
["G_Bandanna_shades", 0, 5] call _addGear;
["G_Bandanna_sport", 0, 5] call _addGear;
["G_Bandanna_tan", 0, 5] call _addGear;
["G_O_Diving", 2, 50] call _addGear;

// ==========================================
// 15. ОПТИКА (OPTICS)
// ==========================================
["optic_ACO_grn_smg", 0, 10] call _addGear;
["optic_ACO_grn", 1, 10] call _addGear;
["optic_MRCO", 1, 10] call _addGear;
["optic_DMS", 1, 20] call _addGear;
["optic_DMS_ghex_F", 1, 20] call _addGear;
["optic_Arco", 2, 20] call _addGear;
["optic_Arco_blk_F", 2, 20] call _addGear;
["optic_Arco_ghex_F", 2, 20] call _addGear;
["optic_KHS_blk", 2, 100] call _addGear;
["optic_KHS_hex", 2, 100] call _addGear;
["optic_KHS_tan", 2, 100] call _addGear;
["optic_KHS_old", 2, 100] call _addGear;
["optic_LRPS", 3, 50] call _addGear;
["optic_LRPS_ghex_F", 3, 50] call _addGear;
["optic_Nightstalker", 3, 100] call _addGear;
["optic_tws", 3, 100] call _addGear;
["optic_Yorris", 1, 5] call _addGear;

// ==========================================
// 16. ОБВЕС (ACCESSORIES, SILENCERS, BIPODS)
// ==========================================
["acc_pointer_IR", 0, 10] call _addGear;
["acc_flashlight", 1, 20] call _addGear;
["muzzle_snds_L", 1, 30] call _addGear;
["muzzle_snds_M", 1, 50] call _addGear;
["muzzle_snds_m_khk_F", 1, 50] call _addGear;
["muzzle_snds_m_snd_F", 1, 50] call _addGear;
["muzzle_snds_58_blk_F", 1, 50] call _addGear;
["muzzle_snds_58_wdm_F", 1, 50] call _addGear;
["muzzle_snds_H", 1, 75] call _addGear;
["muzzle_snds_H_khk_F", 1, 75] call _addGear;
["muzzle_snds_H_snd_F", 1, 75] call _addGear;
["muzzle_snds_H_MG", 1, 100] call _addGear;
["muzzle_snds_H_MG_blk_F", 1, 100] call _addGear;
["muzzle_snds_H_MG_khk_F", 1, 100] call _addGear;
["muzzle_snds_B", 2, 150] call _addGear;
["muzzle_snds_B_snd_F", 2, 150] call _addGear;
["muzzle_snds_B_khk_F", 2, 150] call _addGear;
["muzzle_snds_93mmg", 3, 100] call _addGear;
["muzzle_snds_93mmg_tan", 3, 100] call _addGear;
["muzzle_snds_65_TI_hex_F", 3, 100] call _addGear;
["muzzle_snds_65_TI_ghex_F", 3, 100] call _addGear;
["muzzle_snds_65_TI_blk_F", 3, 100] call _addGear;
["bipod_02_F_blk", 2, 50] call _addGear;
["bipod_02_F_hex", 2, 50] call _addGear;
["bipod_02_F_tan", 2, 50] call _addGear;

// ==========================================
// 17. ПРЕДМЕТЫ И ИНСТРУМЕНТЫ (ITEMS)
// ==========================================
["NVGoggles_OPFOR", 0, 20] call _addGear;
["O_NVGoggles_hex_F", 1, 30] call _addGear;
["O_NVGoggles_ghex_F", 1, 30] call _addGear;
["O_NVGoggles_urb_F", 1, 30] call _addGear;
["Rangefinder", 1, 20] call _addGear;
["Laserdesignator_02", 3, 50] call _addGear;
["Laserdesignator_02_ghex_F", 3, 50] call _addGear;
["ItemGPS", 1, 10] call _addGear;
["O_UavTerminal", 2, 50] call _addGear;
["FirstAidKit", 0, 15] call _addGear;
["Medikit", 0, 15] call _addGear;
["ItemMap", 0, 5] call _addGear;
["itemradio", 0, 5] call _addGear;
["itemcompass", 0, 5] call _addGear;
["itemwatch", 0, 5] call _addGear;
["MineDetector", 0, 10] call _addGear;
["Toolkit", 0, 25] call _addGear;

// ==============================================================================
// ФИНАЛЬНАЯ КОМПИЛЯЦИЯ В BECTI
// ==============================================================================
[_faction, _i, _u, _p] call compile preprocessFileLineNumbers "Common\Config\Gear\Gear_Config_Set.sqf";

//--- Templates (Закомментировано, чтобы не ебать память при загрузке, если не используешь)
_t = [];
/*
_t = _t + [[[["arifle_trg21_f",["","acc_pointer_ir","optic_aco_grn"],["30rnd_556x45_stanag"]],["",[],[]],["hgun_rook40_f",[],["16rnd_9x21_mag"]]],[["u_o_combatuniform_ocamo",["firstaidkit","firstaidkit"]],["V_PlateCarrier2_rgr",["handgrenade","handgrenade"]],["b_assaultpack_khk",["16rnd_9x21_mag","16rnd_9x21_mag","16rnd_9x21_mag","16rnd_9x21_mag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag","30rnd_556x45_stanag"]]],["h_helmeto_ocamo",""],[["nvgoggles","binocular"],["itemmap","itemgps","itemradio","itemcompass","itemwatch"]]]];
// ... остальные шаблоны ...
*/

[_faction, _t] call compile preprocessFileLineNumbers "Common\Config\Gear\Gear_Template_Set.sqf";