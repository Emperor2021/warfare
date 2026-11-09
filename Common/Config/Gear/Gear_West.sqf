private ["_faction", "_i", "_p", "_side", "_u", "_addGear"];

_side = _this;
_faction = "West";

_i = [];
_u = [];
_p = [];

// ==============================================================================
// ЛОКАЛЬНАЯ ХЕЛПЕР-ФУНКЦИЯ (ОПТИМИЗАЦИЯ ПАМЯТИ)
// ==============================================================================
_addGear = {
    params ["_class", "_upgrade", "_price"];
    _i pushBack _class;
    _u pushBack _upgrade;
    _p pushBack _price;
};

// ==========================================
// 1. МИНЫ И ВЗРЫВЧАТКА (EXPLOSIVES)
// ==========================================
["APERSMineDispenser_Mag", 1, 500] call _addGear;
["ATMine_Range_Mag", 1, 100] call _addGear;
["APERSMine_Range_Mag", 1, 10] call _addGear;
["APERSBoundingMine_Range_Mag", 1, 10] call _addGear;
["SLAMDirectionalMine_Wire_Mag", 1, 10] call _addGear; // Был апгрейд 1, у East был 2
["APERSTripMine_Wire_Mag", 1, 5] call _addGear;
["SatchelCharge_Remote_Mag", 2, 20] call _addGear;
["DemoCharge_Remote_Mag", 1, 15] call _addGear;
["ClaymoreDirectionalMine_Remote_Mag", 1, 10] call _addGear; // У East был 2
["Laserbatteries", 2, 20] call _addGear;

// ==========================================
// 2. ПАТРОНЫ — ПИСТОЛЕТЫ И ПП (PISTOL & SMG AMMO)
// ==========================================
["16Rnd_9x21_Mag", 0, 10] call _addGear;
["9Rnd_45ACP_Mag", 0, 10] call _addGear;
["11Rnd_45ACP_Mag", 1, 20] call _addGear;
["6Rnd_GreenSignal_F", 0, 20] call _addGear;
["6Rnd_RedSignal_F", 0, 20] call _addGear;
["30Rnd_9x21_Mag", 0, 10] call _addGear;
["30Rnd_9x21_Red_Mag", 0, 10] call _addGear;
["30Rnd_45ACP_Mag_SMG_01", 0, 10] call _addGear;
["30Rnd_45ACP_Mag_SMG_01_tracer_green", 0, 10] call _addGear;

// ==========================================
// 3. ПАТРОНЫ — ШТУРМОВЫЕ ВИНТОВКИ (RIFLE AMMO)
// ==========================================
// 5.56 (SPAR-01 / SDAR / Mk20)
["30Rnd_556x45_Stanag", 0, 10] call _addGear;
["30Rnd_556x45_Stanag_Tracer_Red", 0, 5] call _addGear;
["20Rnd_556x45_UW_mag", 2, 100] call _addGear;
// 6.5 (MX / Mk200)
["30Rnd_65x39_caseless_mag", 1, 20] call _addGear;
["30Rnd_65x39_caseless_green_mag_Tracer", 1, 10] call _addGear; //tracer

// ==========================================
// 4. ПАТРОНЫ — ПУЛЕМЕТЫ (MG AMMO)
// ==========================================
["100Rnd_65x39_caseless_mag", 1, 30] call _addGear;
["100Rnd_65x39_caseless_mag_Tracer", 1, 20] call _addGear;
["200Rnd_65x39_cased_Box", 2, 40] call _addGear;
["200Rnd_65x39_cased_Box_Tracer", 2, 30] call _addGear;
["200Rnd_556x45_Box_F", 1, 40] call _addGear;
["200Rnd_556x45_Box_Tracer_Red_F", 1, 30] call _addGear;
["150Rnd_556x45_Drum_Mag_F", 1, 30] call _addGear;
["150Rnd_556x45_Drum_Mag_Tracer_F", 1, 20] call _addGear;
["130Rnd_338_Mag", 2, 100] call _addGear; // SPMG

// ==========================================
// 5. ПАТРОНЫ — СНАЙПЕРКИ (SNIPER AMMO)
// ==========================================
["20Rnd_762x51_Mag", 1, 50] call _addGear;
["10Rnd_338_Mag", 2, 100] call _addGear;
["7Rnd_408_Mag", 3, 150] call _addGear;

// ==========================================
// 6. ВЫСТРЕЛЫ — ПУСКОВЫЕ УСТАНОВКИ (LAUNCHER AMMO)
// ==========================================
["NLAW_F", 1, 50] call _addGear;
["Titan_AA", 2, 250] call _addGear;
["Titan_AP", 2, 100] call _addGear;
["Titan_AT", 3, 400] call _addGear;
["MRAWS_HEAT_F", 2, 300] call _addGear;
["MRAWS_HE_F", 1, 150] call _addGear;
["MRAWS_HEAT55_F", 1, 200] call _addGear;
["Vorona_HEAT", 3, 500] call _addGear; // OPFOR, см. косяки
["Vorona_HE", 2, 150] call _addGear;

// ==========================================
// 7. ГРАНАТЫ / ДЫМЫ / ХИС (THROWABLES)
// ==========================================
["HandGrenade", 1, 100] call _addGear;
["MiniGrenade", 0, 50] call _addGear;
["B_IR_Grenade", 2, 40] call _addGear;
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
// 8. ПОДСТВОЛКА (GL AMMO)
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
["3Rnd_HE_Grenade_shell", 1, 150] call _addGear;
["3Rnd_Smoke_Grenade_shell", 1, 30] call _addGear;
["3Rnd_SmokeRed_Grenade_shell", 1, 30] call _addGear;
["3Rnd_SmokeGreen_Grenade_shell", 1, 30] call _addGear;
["3Rnd_SmokeYellow_Grenade_shell", 1, 30] call _addGear;
["3Rnd_SmokePurple_Grenade_shell", 1, 30] call _addGear;
["3Rnd_SmokeBlue_Grenade_shell", 1, 30] call _addGear;
["3Rnd_SmokeOrange_Grenade_shell", 1, 30] call _addGear;
["3Rnd_UGL_FlareWhite_F", 1, 30] call _addGear;
["3Rnd_UGL_FlareGreen_F", 1, 30] call _addGear;
["3Rnd_UGL_FlareRed_F", 1, 30] call _addGear;
["3Rnd_UGL_FlareYellow_F", 1, 30] call _addGear;
["3Rnd_UGL_FlareCIR_F", 1, 100] call _addGear;

// ==========================================
// 9. ОРУЖИЕ: ПИСТОЛЕТЫ И ПП
// ==========================================
["hgun_P07_F", 0, 10] call _addGear;
["hgun_P07_khk_F", 0, 10] call _addGear;
["hgun_ACPC2_F", 1, 10] call _addGear;
["hgun_Pistol_heavy_01_F", 2, 20] call _addGear;
["hgun_Pistol_Signal_F", 0, 15] call _addGear;
["SMG_01_F", 0, 15] call _addGear;
["SMG_05_F", 0, 15] call _addGear;

// ==========================================
// 10. ОРУЖИЕ: ШТУРМОВЫЕ ВИНТОВКИ
// ==========================================
["arifle_Mk20_plain_F", 0, 30] call _addGear;
["arifle_Mk20_GL_plain_F", 0, 50] call _addGear;
["arifle_MXC_F", 1, 50] call _addGear;
["arifle_MXC_Black_F", 1, 50] call _addGear;
["arifle_MXC_khk_F", 1, 50] call _addGear;
["arifle_MX_F", 1, 100] call _addGear;
["arifle_MX_Black_F", 1, 100] call _addGear;
["arifle_MX_khk_F", 1, 100] call _addGear;
["arifle_MX_GL_F", 1, 125] call _addGear;
["arifle_MX_GL_Black_F", 1, 125] call _addGear;
["arifle_MX_GL_khk_F", 1, 125] call _addGear;
["arifle_MX_SW_F", 1, 150] call _addGear;
["arifle_MX_SW_Black_F", 1, 150] call _addGear;
["arifle_MX_SW_khk_F", 1, 150] call _addGear;
["arifle_SPAR_01_blk_F", 1, 50] call _addGear;
["arifle_SPAR_01_khk_F", 1, 50] call _addGear;
["arifle_SPAR_01_snd_F", 1, 50] call _addGear;
["arifle_SPAR_01_GL_blk_F", 1, 75] call _addGear;
["arifle_SPAR_01_GL_khk_F", 1, 75] call _addGear;
["arifle_SPAR_01_GL_snd_F", 1, 75] call _addGear;
["arifle_SDAR_F", 2, 100] call _addGear;

// ==========================================
// 11. ОРУЖИЕ: ПУЛЕМЕТЫ
// ==========================================
["LMG_03_F", 0, 150] call _addGear;
["LMG_Mk200_F", 2, 200] call _addGear;
["MMG_02_black_F", 3, 300] call _addGear;
["MMG_02_camo_F", 3, 300] call _addGear;
["MMG_02_sand_F", 3, 300] call _addGear;

// ==========================================
// 12. ОРУЖИЕ: СНАЙПЕРКИ И МАРКСМАНКИ
// ==========================================
["arifle_MXM_F", 1, 150] call _addGear;
["arifle_MXM_Black_F", 1, 150] call _addGear;
["arifle_MXM_khk_F", 1, 150] call _addGear;
["srifle_EBR_F", 1, 200] call _addGear;
["arifle_SPAR_02_blk_F", 2, 150] call _addGear;
["arifle_SPAR_02_khk_F", 2, 150] call _addGear;
["arifle_SPAR_02_snd_F", 2, 150] call _addGear;
["arifle_SPAR_03_blk_F", 2, 200] call _addGear;
["arifle_SPAR_03_khk_F", 2, 200] call _addGear;
["arifle_SPAR_03_snd_F", 2, 200] call _addGear;
["srifle_DMR_03_F", 2, 200] call _addGear;
["srifle_DMR_03_multicam_F", 2, 200] call _addGear;
["srifle_DMR_03_khaki_F", 2, 200] call _addGear;
["srifle_DMR_03_tan_F", 2, 200] call _addGear;
["srifle_DMR_03_woodland_F", 2, 200] call _addGear;
["srifle_DMR_06_camo_F", 2, 175] call _addGear;
["srifle_DMR_06_olive_F", 2, 175] call _addGear;
["srifle_DMR_02_F", 3, 300] call _addGear;
["srifle_DMR_02_camo_F", 3, 300] call _addGear;
["srifle_DMR_02_sniper_F", 3, 300] call _addGear;
["srifle_LRR_F", 3, 500] call _addGear;
["srifle_LRR_camo_F", 3, 500] call _addGear;
["srifle_LRR_tna_F", 3, 500] call _addGear;

// ==========================================
// 13. ОРУЖИЕ: ПУСКОВЫЕ УСТАНОВКИ
// ==========================================
["launch_NLAW_F", 1, 100] call _addGear;
["launch_MRAWS_green_F", 2, 400] call _addGear;
["launch_MRAWS_olive_F", 2, 400] call _addGear;
["launch_MRAWS_sand_F", 2, 400] call _addGear;
["launch_O_Vorona_brown_F", 2, 400] call _addGear; // OPFOR, см. косяки
["launch_O_Vorona_green_F", 2, 400] call _addGear; // OPFOR
["launch_B_Titan_short_F", 3, 500] call _addGear;
["launch_B_Titan_short_tna_F", 3, 500] call _addGear;
["launch_B_Titan_F", 3, 500] call _addGear;
["launch_B_Titan_tna_F", 3, 500] call _addGear;

// ==========================================
// 14. ОДЕЖДА: УНИФОРМА (UNIFORMS)
// ==========================================
["U_B_FullGhillie_ard", 3, 360] call _addGear; 
["U_B_T_FullGhillie_tna_F", 3, 360] call _addGear;
["U_B_FullGhillie_lsh", 3, 360] call _addGear;
["U_B_FullGhillie_sard", 3, 360] call _addGear;
["U_B_T_Sniper_F", 3, 45] call _addGear;
["U_B_GhillieSuit", 3, 45] call _addGear;
["U_B_CTRG_Soldier_F", 3, 50] call _addGear;
["U_B_CTRG_Soldier_3_F", 3, 50] call _addGear;
["U_B_CTRG_Soldier_2_F", 2, 40] call _addGear;
["U_B_CTRG_Soldier_urb_1_F", 2, 40] call _addGear;
["U_B_CTRG_Soldier_urb_3_F", 2, 40] call _addGear;
["U_B_CTRG_1", 2, 30] call _addGear;
["U_B_CTRG_3", 2, 30] call _addGear;
["U_B_PilotCoveralls", 2, 30] call _addGear;
["U_B_Wetsuit", 2, 50] call _addGear;
["U_B_CTRG_2", 1, 10] call _addGear;
["U_B_HeliPilotCoveralls", 1, 15] call _addGear;
["U_B_CombatUniform_mcam", 1, 20] call _addGear;
["U_B_CombatUniform_mcam_vest", 1, 20] call _addGear;
["U_B_T_Soldier_SL_F", 1, 20] call _addGear;
["U_B_T_Soldier_F", 1, 20] call _addGear;
["U_B_T_Soldier_AR_F", 0, 10] call _addGear;
["U_B_CombatUniform_mcam_tshirt", 0, 10] call _addGear;
["U_B_CTRG_Soldier_urb_2_F", 1, 30] call _addGear;
["U_I_G_Story_Protagonist_F", 0, 20] call _addGear;
["U_I_G_resistanceLeader_F", 0, 20] call _addGear;

// ==========================================
// 15. ОДЕЖДА: БРОНЕЖИЛЕТЫ (VESTS)
// ==========================================
["V_PlateCarrierSpec_blk", 3, 200] call _addGear;
["V_PlateCarrierSpec_rgr", 3, 200] call _addGear;
["V_PlateCarrierSpec_mtp", 3, 200] call _addGear;
["V_PlateCarrierSpec_tna_F", 3, 200] call _addGear;
["V_PlateCarrierGL_blk", 3, 200] call _addGear;
["V_PlateCarrierGL_rgr", 3, 200] call _addGear;
["V_PlateCarrierGL_mtp", 3, 200] call _addGear;
["V_PlateCarrierGL_tna_F", 3, 200] call _addGear;
["V_PlateCarrier1_blk", 2, 100] call _addGear;
["V_PlateCarrier1_rgr", 2, 100] call _addGear;
["V_PlateCarrier1_rgr_noflag_F", 2, 100] call _addGear;
["V_PlateCarrier1_tna_F", 2, 100] call _addGear;
["V_PlateCarrierL_CTRG", 2, 100] call _addGear;
["V_PlateCarrier_Kerry", 2, 100] call _addGear;
["V_PlateCarrier2_blk", 2, 150] call _addGear;
["V_PlateCarrier2_rgr", 2, 150] call _addGear;
["V_PlateCarrier2_rgr_noflag_F", 2, 150] call _addGear;
["V_PlateCarrier2_tna_F", 2, 150] call _addGear;
["V_PlateCarrierH_CTRG", 2, 150] call _addGear;
["V_RebreatherB", 2, 100] call _addGear;
["V_I_G_resistanceLeader_F", 1, 100] call _addGear;
["V_TacVestIR_blk", 1, 150] call _addGear;
["V_BandollierB_rgr", 0, 50] call _addGear;
["V_BandollierB_khk", 0, 50] call _addGear;
["V_BandollierB_oli", 0, 50] call _addGear;
["V_Chestrig_blk", 0, 100] call _addGear;
["V_Chestrig_rgr", 0, 100] call _addGear;
["V_Chestrig_khk", 0, 100] call _addGear;
["V_Chestrig_oli", 0, 100] call _addGear;
["V_TacChestrig_cbr_F", 0, 100] call _addGear;
["V_TacChestrig_grn_F", 0, 100] call _addGear;
["V_TacChestrig_oli_F", 0, 100] call _addGear;

// ==========================================
// 16. ОДЕЖДА: РЮКЗАКИ (BACKPACKS)
// ==========================================
["B_Carryall_cbr", 3, 150] call _addGear;
["B_Carryall_khk", 3, 150] call _addGear;
["B_Carryall_mcamo", 3, 150] call _addGear;
["B_Carryall_oli", 3, 150] call _addGear;
["B_Bergen_mcamo_F", 3, 1000] call _addGear;
["B_Bergen_tna_F", 3, 1000] call _addGear;
["B_UAV_01_backpack_F", 3, 2000] call _addGear;
["B_Static_Designator_01_weapon_F", 2, 500] call _addGear;

if !(MADE_FOR_STRATIS) then {
    ["B_Mortar_01_support_F", 3, 5] call _addGear;
    ["B_Mortar_01_weapon_F", 3, 9995] call _addGear;
};

["B_Kitbag_cbr", 2, 100] call _addGear;
["B_Kitbag_rgr", 2, 100] call _addGear;
["B_Kitbag_mcamo", 2, 100] call _addGear;
["B_Kitbag_sgg", 2, 100] call _addGear;
["B_TacticalPack_blk", 1, 100] call _addGear;
["B_TacticalPack_rgr", 1, 100] call _addGear;
["B_TacticalPack_mcamo", 1, 100] call _addGear;
["B_TacticalPack_oli", 1, 100] call _addGear;
["B_AssaultPack_blk", 1, 50] call _addGear;
["B_AssaultPack_cbr", 1, 50] call _addGear;
["B_AssaultPack_rgr", 1, 50] call _addGear;
["B_AssaultPack_khk", 1, 50] call _addGear;
["B_AssaultPack_mcamo", 1, 50] call _addGear;
["B_AssaultPack_sgg", 1, 50] call _addGear;
["B_AssaultPack_tna_F", 1, 50] call _addGear;
["B_AssaultPack_Kerry", 1, 50] call _addGear;
["B_Parachute", 1, 100] call _addGear;

// ==========================================
// 17. ОДЕЖДА: ШЛЕМЫ И ШАПКИ (HEADGEAR)
// ==========================================
["H_HelmetB_TI_tna_F", 3, 500] call _addGear;
["H_HelmetSpecB", 3, 100] call _addGear;
["H_HelmetSpecB_blk", 3, 100] call _addGear;
["H_HelmetSpecB_paint2", 3, 100] call _addGear;
["H_HelmetSpecB_paint1", 3, 100] call _addGear;
["H_HelmetSpecB_sand", 3, 100] call _addGear;
["H_HelmetSpecB_snakeskin", 3, 100] call _addGear;
["H_HelmetB_Enh_tna_F", 3, 100] call _addGear;
["H_PilotHelmetFighter_B", 3, 300] call _addGear;
["H_HelmetO_ViperSP_hex_F", 3, 2000] call _addGear; // OPFOR VIPER, см. косяки
["H_HelmetO_ViperSP_ghex_F", 3, 2000] call _addGear; // OPFOR VIPER
["H_HelmetB", 2, 40] call _addGear;
["H_HelmetB_black", 2, 40] call _addGear;
["H_HelmetB_camo", 2, 40] call _addGear;
["H_HelmetB_desert", 2, 40] call _addGear;
["H_HelmetB_grass", 2, 40] call _addGear;
["H_HelmetB_sand", 2, 40] call _addGear;
["H_HelmetB_snakeskin", 2, 40] call _addGear;
["H_HelmetB_tna_F", 2, 40] call _addGear;
["H_HelmetCrew_B", 2, 50] call _addGear;
["H_PilotHelmetHeli_B", 2, 50] call _addGear;
["H_CrewHelmetHeli_B", 2, 50] call _addGear;
["H_HelmetB_light", 1, 30] call _addGear;
["H_HelmetB_light_black", 1, 30] call _addGear;
["H_HelmetB_light_desert", 1, 30] call _addGear;
["H_HelmetB_light_grass", 1, 30] call _addGear;
["H_HelmetB_light_sand", 1, 30] call _addGear;
["H_HelmetB_light_snakeskin", 1, 30] call _addGear;
["H_HelmetB_Light_tna_F", 1, 30] call _addGear;
["H_Bandanna_gry", 0, 5] call _addGear;
["H_Bandanna_blu", 0, 5] call _addGear;
["H_Bandanna_cbr", 0, 5] call _addGear;
["H_Bandanna_khk_hs", 0, 5] call _addGear;
["H_Bandanna_khk", 0, 5] call _addGear;
["H_Bandanna_mcamo", 0, 5] call _addGear;
["H_Bandanna_sgg", 0, 5] call _addGear;
["H_Bandanna_sand", 0, 5] call _addGear;
["H_Bandanna_camo", 0, 5] call _addGear;
["H_Watchcap_blk", 0, 10] call _addGear;
["H_Watchcap_cbr", 0, 10] call _addGear;
["H_Watchcap_camo", 0, 10] call _addGear;
["H_Watchcap_khk", 0, 10] call _addGear;
["H_Beret_blk", 0, 15] call _addGear;
["H_Beret_02", 0, 15] call _addGear;
["H_Beret_Colonel", 0, 15] call _addGear;
["H_Booniehat_khk_hs", 0, 20] call _addGear;
["H_Booniehat_khk", 0, 20] call _addGear;
["H_Booniehat_mcamo", 0, 20] call _addGear;
["H_Booniehat_oli", 0, 20] call _addGear;
["H_Booniehat_tan", 0, 20] call _addGear;
["H_Booniehat_tna_F", 0, 20] call _addGear;
["H_Cap_grn_BI", 0, 20] call _addGear;
["H_Cap_blk", 0, 20] call _addGear;
["H_Cap_blk_CMMG", 0, 20] call _addGear;
["H_Cap_grn", 0, 20] call _addGear;
["H_Cap_blk_ION", 0, 20] call _addGear;
["H_Cap_oli", 0, 20] call _addGear;
["H_Cap_oli_hs", 0, 20] call _addGear;
["H_Cap_tan", 0, 20] call _addGear;
["H_Cap_tan_specops_US", 0, 5] call _addGear;
["H_Cap_khaki_specops_UK", 0, 20] call _addGear;
["H_Cap_usblack", 0, 20] call _addGear;
["H_MilCap_gry", 0, 30] call _addGear;
["H_MilCap_mcamo", 0, 30] call _addGear;
["H_MilCap_tna_F", 0, 30] call _addGear;
["H_Shemag_olive", 0, 20] call _addGear;
["H_Shemag_olive_hs", 0, 20] call _addGear;
["H_ShemagOpen_khk", 0, 20] call _addGear;

// ==========================================
// 18. ОДЕЖДА: ОЧКИ И МАСКИ (GLASSES)
// ==========================================
["G_Tactical_Clear", 1, 100] call _addGear;
["G_Balaclava_TI_blk_F", 2, 100] call _addGear;
["G_Balaclava_TI_G_blk_F", 2, 100] call _addGear;
["G_Balaclava_TI_tna_F", 2, 100] call _addGear;
["G_Balaclava_TI_G_tna_F", 2, 100] call _addGear;
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
["G_Combat", 0, 10] call _addGear;
["G_Combat_Goggles_tna_F", 0, 10] call _addGear;
["G_B_Diving", 2, 50] call _addGear;

// ==========================================
// 19. ОПТИКА (OPTICS)
// ==========================================
["optic_Aco_smg", 0, 10] call _addGear;
["optic_Holosight", 0, 10] call _addGear;
["optic_Holosight_blk_F", 0, 10] call _addGear;
["optic_Holosight_khk_F", 0, 10] call _addGear;
["optic_Holosight_smg", 0, 10] call _addGear;
["optic_Holosight_smg_blk_F", 0, 10] call _addGear;
["optic_MRD", 1, 5] call _addGear;
["optic_Aco", 1, 10] call _addGear;
["optic_MRCO", 1, 10] call _addGear;
["optic_DMS", 1, 20] call _addGear;
["optic_Hamr", 2, 20] call _addGear;
["optic_Hamr_khk_F", 2, 20] call _addGear;
["optic_ERCO_blk_F", 2, 30] call _addGear;
["optic_ERCO_khk_F", 2, 30] call _addGear;
["optic_ERCO_snd_F", 2, 30] call _addGear;

["optic_SOS", 2, 50] call _addGear;
["optic_SOS_khk_F", 2, 50] call _addGear;
["optic_LRPS", 3, 50] call _addGear;
["optic_LRPS_tna_F", 3, 50] call _addGear;
["optic_AMS_snd", 2, 70] call _addGear;
["optic_AMS_khk", 2, 70] call _addGear;
["optic_AMS", 2, 50] call _addGear;
["optic_NVS", 2, 30] call _addGear;
["optic_tws", 3, 100] call _addGear;
["optic_tws_mg", 3, 100] call _addGear;


// ==========================================
// 20. ОБВЕС (ACCESSORIES, SILENCERS, BIPODS)
// ==========================================
["acc_pointer_IR", 0, 10] call _addGear;
["acc_flashlight", 1, 20] call _addGear;
["muzzle_snds_acp", 0, 40] call _addGear;
["muzzle_snds_L", 1, 30] call _addGear;
["muzzle_snds_M", 1, 50] call _addGear;
["muzzle_snds_m_khk_F", 1, 50] call _addGear;
["muzzle_snds_m_snd_F", 1, 50] call _addGear;
["muzzle_snds_H", 1, 75] call _addGear;
["muzzle_snds_H_khk_F", 1, 75] call _addGear;
["muzzle_snds_H_snd_F", 1, 75] call _addGear;
["muzzle_snds_H_MG", 1, 100] call _addGear;
["muzzle_snds_H_MG_blk_F", 1, 100] call _addGear;
["muzzle_snds_H_MG_khk_F", 1, 100] call _addGear;
["muzzle_snds_B", 2, 150] call _addGear;
["muzzle_snds_B_snd_F", 2, 150] call _addGear;
["muzzle_snds_B_khk_F", 2, 150] call _addGear;
["muzzle_snds_338_black", 3, 100] call _addGear;
["muzzle_snds_338_green", 3, 100] call _addGear;
["muzzle_snds_338_sand", 3, 100] call _addGear;
["muzzle_snds_93mmg", 3, 100] call _addGear;
["muzzle_snds_93mmg_tan", 3, 100] call _addGear;
["bipod_01_F_blk", 2, 50] call _addGear;
["bipod_01_F_khk", 2, 50] call _addGear;
["bipod_01_F_mtp", 2, 50] call _addGear;
["bipod_01_F_snd", 2, 50] call _addGear;

// ==========================================
// 21. ПРЕДМЕТЫ И ИНСТРУМЕНТЫ (ITEMS)
// ==========================================
["NVGoggles", 0, 20] call _addGear;
["NVGoggles_tna_F", 1, 30] call _addGear;
["NVGogglesB_grn_F", 3, 500] call _addGear;
["NVGogglesB_gry_F", 3, 500] call _addGear;
["NVGogglesB_blk_F", 3, 500] call _addGear;
["Rangefinder", 1, 20] call _addGear;
["Laserdesignator", 2, 50] call _addGear;
["Laserdesignator_01_khk_F", 2, 50] call _addGear;
["ItemGPS", 1, 10] call _addGear;
["B_UavTerminal", 2, 50] call _addGear;
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

//--- Templates
_t = [];
// ... твои закомментированные шаблоны ...
[_faction, _t] call compile preprocessFileLineNumbers "Common\Config\Gear\Gear_Template_Set.sqf";