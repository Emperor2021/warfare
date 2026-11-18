/*
    Автор: Emperor (модификация warfare2026)
    Дата: 2026-06-22
    Время: 17:15
    Описание: Скрипт безопасной инициализации стартового отряда игрока.
    Автоматически спавнит пехотных специалистов поддержки, а также отправляет сетевой запрос
    на сервер для создания техники с экипажами (водители и стрелки) через оригинальные функции BECTI.
    
    Дата: 2026-08-05
    Время: 21:32
    Техника мгновенно и корректно регистрируется в глобальной сети CTI (Advanced Network / ANET).
    БОТЫ И ТЕХНИКА СТОЯТ НА МЕСТЕ ПРИ СТАРТЕ, ДВИГАЮТСЯ ПО ПРИКАЗУ ИГРОКА
    ПРИ ПОСТРОЙКЕ ЦЕНТРА УПРАВЛЕНИЯ ТЕХНИКА ПОДКЛЮЧАЕТСЯ К СЕТИ
*/

if (isDedicated) exitWith {};

// Ожидание полной инициализации клиента и Strat Mode для исключения критических багов спавна
waitUntil { !isNil "CTI_Init_Client" && {CTI_Init_Client} };
waitUntil { !isNil "CTI_Init_Strat" && {CTI_Init_Strat} };
sleep 3;
// ==========================================
// БЛОКИРОВКА СПАВНА ВО ВРЕМЯ ДЕБРИФИНГА (JIP)
// ==========================================
// Ждём до 10 секунд, пока сервер не пришлёт статус конца игры.
// Это страховка от рассинхрона, когда клиент прогрузился быстрее, чем сервер кинул PVF.
private _timeout = time + 4;
waitUntil {
    sleep 1;
    (missionNamespace getVariable ["CTI_GameOver", false]) || (time > _timeout)
};

if (missionNamespace getVariable ["CTI_GameOver", false]) exitWith {
    diag_log "[BECTI] Client_InitPlayerBots: Игра завершена. Спавн стартовых ботов и техники отменён для JIP.";
};
// ==========================================
private _side = CTI_P_SideJoined;
private _sideID = CTI_P_SideID;

// Выполнение скрипта допускается только для игровых сторон (Запад и Восток)
if !(_side in [west, east]) exitWith {};

// --- СЕКЦИЯ КОНФИГУРАЦИИ ТЕХНИКИ И КЛАССОВ ---
private _crewClass = "B_soldier_F";          // Класс экипажа по умолчанию
private _classes = [];                       // Список классов пехотинцев
private _vehiclesToSpawn = [];               // Список всей спавнящейся техники

switch (_side) do {
    case west: {
        _crewClass = "B_crew_F";             // Экипаж синих
        
        // --- НАСТРОЙКА ТЕХНИКИ ДЛЯ ЗАПАДА (WEST) ---
        _vehiclesToSpawn = [
            "B_MBT_01_TUSK_F",
            "B_APC_Tracked_01_AA_F",
            "B_MRAP_01_hmg_F",
            "B_MBT_01_arty_F"
        ];
        
        _classes = [
            "B_soldier_UAV_F",
            "B_engineer_F"
        ];
    };
    case east: {
        _crewClass = "O_crew_F";             // Экипаж красных
        
        // --- НАСТРОЙКА ТЕХНИКИ ДЛЯ ВОСТОКА (EAST) ---
        _vehiclesToSpawn = [
            "O_MBT_02_cannon_F",
            "O_APC_Tracked_02_AA_F",
            "O_MRAP_02_hmg_F",
            "O_MBT_02_arty_F"
        ];
        
        _classes = [
            "O_soldier_UAV_F",
            "O_engineer_F"
        ];
    };
};

// --- ИНИЦИАЛИЗАЦИЯ ГЛОБАЛЬНЫХ МАССИВОВ BECTI (ЕСЛИ ОТСУТСТВУЮТ) ---
if (isNil "CTI_AI_Units") then { CTI_AI_Units = []; };
if (isNil "CTI_Player_Vehicles") then { CTI_Player_Vehicles = []; };

// --- СПАВН ПЕХОТНЫХ БОТОВ С ПОЛНОЙ РЕГИСТРАЦИЕЙ В СТРУКТУРЕ BECTI ---
private _currentAI = (units group player) - [player];
private _neededBots = 2 - (count _currentAI);

if (_neededBots > 0) then {
    player groupChat format [localize "STR_BECTI_SpawningBots", _neededBots];
    
    for "_i" from 1 to _neededBots do {
        private _unitClass = _classes select (_i - 1);
        private _spawnPos = [getPos player, 5, 15, 3, 0, 0.3, 0] call BIS_fnc_findSafePos;
        if (count _spawnPos == 2) then { _spawnPos pushBack 0; };
        
        // Создаем юнита с NONE чтобы он не бежал за игроком
        private _bot = (group player) createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
        [_bot] joinSilent (group player);
        _bot enableFatigue false;
        
        // Остановка бота на месте
        doStop _bot;
        _bot setBehaviour "SAFE";
        _bot setCombatMode "YELLOW";
        
        // === ПОЛНАЯ РЕГИСТРАЦИЯ В СТРУКТУРЕ BECTI ===
        _bot setVariable ["cti_net", _sideID, true];
        // AN_iNet и AN_Conn НЕ устанавливаем здесь - это сделает AN_Launch
        _bot setVariable ["cti_ai_order", CTI_ORDER_CLIENT_NONE, true];
        _bot setVariable ["cti_ai_order_pos", [0,0], true];
        _bot setVariable ["cti_ai_side", _side, true];
        _bot setVariable ["cti_ai_group", group player, true];
        _bot setVariable ["cti_ai_leader", player, true];
        _bot setVariable ["cti_ai_player", true, true];
        
        // === МЕТКА ДЛЯ ПЕРЕПОДКЛЮЧЕНИЯ К СЕТИ ===
        _bot setVariable ["cti_start_unit", true, true];
        
        CTI_AI_Units pushBack _bot;
        _bot setVariable ["cti_fsm", true, true];
        _bot setSkill 0.5;
        _bot setUnitAbility 0.5;
        
        // === ИНИЦИАЛИЗАЦИЯ МАРКЕРОВ ДЛЯ 3D МИРА ===
        [_bot, _sideID] call CTI_CO_FNC_InitializeNetVehicle;
        
        // === ЗАПУСК СЕТИ ДЛЯ БОТА ЛОКАЛЬНО НА КЛИЕНТЕ ===
        // Бот создан на клиенте и локален здесь. Запускаем сеть локально.
        [_bot, _sideID] spawn AN_Launch;
        
        sleep 0.25;
    };

    // ИСПРАВЛЕНИЕ БАГА #1: publicVariable заменён на запрос к серверу (работает на Dedicated Server)
    ["SERVER", "Request_Update_AIUnits", [CTI_AI_Units]] call CTI_CO_FNC_NetSend;
    player groupChat format [localize "STR_CTI_InfantryArrived_Custom", _neededBots];
};

// --- ПОСЛЕДОВАТЕЛЬНЫЙ СПАВН ТЕХНИКИ С ПОЛНОЙ РЕГИСТРАЦИЕЙ ---
if (count _vehiclesToSpawn > 0) then {
    {
        private _currentVehClass = _x;
        
        private _vehicleName = getText (configFile >> "CfgVehicles" >> _currentVehClass >> "displayName");
        if (_vehicleName == "") then { _vehicleName = _currentVehClass; };

                player groupChat format [localize "STR_CTI_RequestingVehicle_Custom", _vehicleName];
        sleep 1;

        // === ПОИСК СВОБОДНОЙ ПОЗИЦИИ ИСКЛЮЧИТЕЛЬНО НА ДОРОГЕ ===
        // Причина: база в городе, плотная застройка. findSafePos меряет зазор до ЦЕНТРА объекта,
        // из-за чего техника встаёт в здания/вплотную к соседям -> пенетрация геометрии -> взрыв.
        // Радиус 200м, при отсутствии свободного места +200м (до 1000м).
        private _spawnPos = [];
        private _spawnDir = getDir player;
        private _center = getPos player;

        for "_radius" from 200 to 1000 step 200 do {
            if !(_spawnPos isEqualTo []) exitWith {};

            private _roads = _center nearRoads _radius;
            if (count _roads == 0) then { continue };

            // Перемешиваем, чтобы 4 машины не встали в одну точку.
            // Лимит 60 сегментов на радиус — защита от тяжёлого перебора в городе.
            _roads = _roads call BIS_fnc_arrayShuffle;
            if (count _roads > 60) then { _roads resize 60 };

            {
                private _road = _x;
                if (isNull _road) then { continue };
                private _rPos = getPos _road;

                // Только дорожное полотно и только суша
                if !(isOnRoad _rPos) then { continue };
                if (surfaceIsWater _rPos) then { continue };

                // findEmptyPosition учитывает габариты класса техники и здания.
                // Радиус 3м — чтобы не уехать с полотна; результат перепроверяем isOnRoad.
                private _p = _rPos findEmptyPosition [0, 3, _currentVehClass];
                if (_p isEqualTo []) then { continue };
                if !(isOnRoad _p) then { continue };

                // "На дороге никого нет" — паттерн проверок из svb_fnc_isSpawnPointFree
                if ({alive _x} count (_p nearEntities ["Man", 6]) > 0) then { continue };
                private _blockers = (_p nearEntities ["All", 12]) select {
                    alive _x && {
                        _x isKindOf "LandVehicle" || {_x isKindOf "Air"} || {_x isKindOf "Ship"} ||
                        {_x isKindOf "StaticWeapon"} || {_x isKindOf "AmmoBox"}
                    }
                };
                if (count _blockers > 0) then { continue };

                // Точка свободна. Направление — ВДОЛЬ дороги, иначе танк встанет поперёк улицы.
                _spawnPos = _p;
                private _connected = roadsConnectedTo _road;
                if (count _connected > 0) then {
                    _spawnDir = _road getDir (_connected select 0);
                };
                if (true) exitWith {};
            } forEach _roads;
        };

        if (_spawnPos isEqualTo []) then {
            diag_log format ["[BECTI] InitPlayerBots: свободной дороги в радиусе 1000м не найдено для %1, спавн отменён", _currentVehClass];
            player groupChat format [localize "STR_CTI_ERROR", _vehicleName];
            continue;
        };
        if (count _spawnPos == 2) then { _spawnPos pushBack 0 };

        // === СОЗДАНИЕ ТЕХНИКИ ЧЕРЕЗ ОФИЦИАЛЬНУЮ ФУНКЦИЮ BECTI ===
        // Параметры: CLASSNAME, POSITION, DIRECTION, SIDE, LOCKED, PUBLIC, HANDLED, SPECIAL
        // PUBLIC = true означает что техника будет инициализирована через Server_Run_Net
        private _veh = [_currentVehClass, _spawnPos, _spawnDir, _sideID, false, true, true] call CTI_CO_FNC_CreateVehicle;

        if (isNil "_veh" || {isNull _veh}) then {
            diag_log format ["[BECTI] ОШИБКА: Не удалось создать технику %1", _currentVehClass];
            player groupChat format [localize "STR_CTI_ERROR", _vehicleName];
            sleep 1;
            continue;
        };

        // === ФИКСАЦИЯ ТЕХНИКИ НА НАЙДЕННОЙ ТОЧКЕ ДОРОГИ ===
        // CTI_CO_FNC_CreateVehicle создаёт через createVehicle [..., 7, "FORM"]:
        // placement radius 7 сдвигает машину до 7м, FORM роняет её с 1м.
        // Без фиксации техника уедет с дороги обратно в застройку — весь поиск насмарку.
        _veh setPosATL _spawnPos;
        _veh setDir _spawnDir;
        _veh setVelocity [0,0,0];

        // === v_keys ДЛЯ ОТОБРАЖЕНИЯ ИКОНОК В 3D ===
       _veh setVariable ["v_keys", [getPlayerUID player, group player], true];
        
        // === РЕГИСТРАЦИЯ ТЕХНИКИ ===
        _veh setVariable ["cti_owner", player, true];
        _veh setVariable ["cti_owner_uid", getPlayerUID player, true];
        _veh setVariable ["cti_side", _sideID, true];
        // ct_net уже установлен через CTI_CO_FNC_CreateVehicle с параметром PUBLIC=true
        // AN_iNet и AN_Conn НЕ устанавливаем здесь - это сделает AN_Launch через Server_Run_Net
        
        // === МЕТКА ДЛЯ ПЕРЕПОДКЛЮЧЕНИЯ К СЕТИ ===
        _veh setVariable ["cti_start_vehicle", true, true];
        
        CTI_Player_Vehicles pushBack _veh;
        
        _veh setVariable ["cti_ai_vehicle", true, true];
        _veh setVariable ["cti_ai_player", true, true];
        _veh setVariable ["cti_handled", true, true];
        
        // === ИНИЦИАЛИЗАЦИЯ МАРКЕРОВ ДЛЯ 3D МИРА ===
        [_veh, _sideID] call CTI_CO_FNC_InitializeNetVehicle;
        
        if (count (configFile >> "CfgVehicles" >> _currentVehClass >> "Turrets") > 0) then {
            _veh setVariable ["cti_ai_gunner", true, true];
        };

        // Остановка техники
        _veh engineOn false;

        clearWeaponCargoGlobal _veh;
        clearMagazineCargoGlobal _veh;
        clearItemCargoGlobal _veh;
        clearBackpackCargoGlobal _veh;

        _veh addMagazineCargoGlobal ["30Rnd_556x45_Stanag", 15];
        _veh addMagazineCargoGlobal ["30Rnd_6539_caseless_green", 15];
        _veh addItemCargoGlobal ["FirstAidKit", 5];
        _veh addItemCargoGlobal ["ToolKit", 1];

        // === ВОДИТЕЛЬ ===
        private _driverPos = [_spawnPos, 3, _spawnDir - 180] call BIS_fnc_relPos;
        private _driver = (group player) createUnit [_crewClass, _driverPos, [], 0, "NONE"];
        [_driver] joinSilent (group player);
        _driver moveInDriver _veh;
        _driver enableFatigue false;
        
        doStop _driver;
        _driver setBehaviour "SAFE";
        _driver setCombatMode "YELLOW";
        
        _driver setVariable ["cti_net", _sideID, true];
        // AN_iNet НЕ устанавливаем - это сделает AN_Launch
        _driver setVariable ["cti_ai_order", CTI_ORDER_CLIENT_NONE, true];
        _driver setVariable ["cti_ai_order_pos", [0,0], true];
        _driver setVariable ["cti_ai_side", _side, true];
        _driver setVariable ["cti_ai_group", group player, true];
        _driver setVariable ["cti_ai_leader", player, true];
        _driver setVariable ["cti_ai_player", true, true];
        _driver setVariable ["cti_ai_vehicle_driver", _veh, true];
        _driver setSkill 0.5;
        _driver setUnitAbility 0.5;
        CTI_AI_Units pushBack _driver;
        
        // Запуск сети для водителя локально
        [_driver, _sideID] spawn AN_Launch;

        // === СТРЕЛОК ===
        if (_veh emptyPositions "gunner" > 0) then {
            private _gunnerPos = [_spawnPos, 3, _spawnDir - 90] call BIS_fnc_relPos;
            private _gunner = (group player) createUnit [_crewClass, _gunnerPos, [], 0, "NONE"];
            [_gunner] joinSilent (group player);
            _gunner moveInGunner _veh;
            _gunner enableFatigue false;
            
            doStop _gunner;
            _gunner setBehaviour "SAFE";
            _gunner setCombatMode "YELLOW";
            
            _gunner setVariable ["cti_net", _sideID, true];
            // AN_iNet НЕ устанавливаем
            _gunner setVariable ["cti_ai_order", CTI_ORDER_CLIENT_NONE, true];
            _gunner setVariable ["cti_ai_order_pos", [0,0], true];
            _gunner setVariable ["cti_ai_side", _side, true];
            _gunner setVariable ["cti_ai_group", group player, true];
            _gunner setVariable ["cti_ai_leader", player, true];
            _gunner setVariable ["cti_ai_player", true, true];
            _gunner setVariable ["cti_ai_vehicle_gunner", _veh, true];
            _gunner setSkill 0.5;
            _gunner setUnitAbility 0.5;
            CTI_AI_Units pushBack _gunner;
            
            // Запуск сети для стрелка локально
            [_gunner, _sideID] spawn AN_Launch;
        };

        // === КОМАНДИР ===
        if (_veh emptyPositions "commander" > 0) then {
            private _commanderPos = [_spawnPos, 3, _spawnDir] call BIS_fnc_relPos;
            private _commander = (group player) createUnit [_crewClass, _commanderPos, [], 0, "NONE"];
            [_commander] joinSilent (group player);
            _commander moveInCommander _veh;
            _commander enableFatigue false;
            
            doStop _commander;
            _commander setBehaviour "SAFE";
            _commander setCombatMode "YELLOW";
            
            _commander setVariable ["cti_net", _sideID, true];
            // AN_iNet НЕ устанавливаем
            _commander setVariable ["cti_ai_order", CTI_ORDER_CLIENT_NONE, true];
            _commander setVariable ["cti_ai_order_pos", [0,0], true];
            _commander setVariable ["cti_ai_side", _side, true];
            _commander setVariable ["cti_ai_group", group player, true];
            _commander setVariable ["cti_ai_leader", player, true];
            _commander setVariable ["cti_ai_player", true, true];
            _commander setVariable ["cti_ai_vehicle_commander", _veh, true];
            _commander setSkill 0.5;
            _commander setUnitAbility 0.5;
            CTI_AI_Units pushBack _commander;
            
            // Запуск сети для командира локально
            [_commander, _sideID] spawn AN_Launch;
        };

        // ИСПРАВЛЕНИЕ БАГА #1: publicVariable заменён на запрос к серверу
        ["SERVER", "Request_Update_AIUnits", [CTI_AI_Units, CTI_Player_Vehicles]] call CTI_CO_FNC_NetSend;

        // Запуск скрипта слежения за пустой техникой
         ["SERVER", "Request_HandleAction", ["empty", [_veh]]] call CTI_CO_FNC_NetSend;

        // ИСПРАВЛЕНИЕ БАГА #2: UI-функции только на клиенте, без remoteExec target 0
        if (!CTI_IsServer) then {
            [] call CTI_CL_FNC_UpdateTeamUI;
            [] call CTI_UI_Map_Update;
        };

        player groupChat format [localize "STR_CTI_VehicleArrived_Custom", _vehicleName];
        sleep 0.5;
    } forEach _vehiclesToSpawn;
};

// === ФИНАЛЬНАЯ ОСТАНОВКА ВСЕХ ЮНИТОВ ===
{
    if (alive _x && !isPlayer _x) then {
        doStop _x;
        _x setBehaviour "SAFE";
        _x setCombatMode "YELLOW";
    };
} forEach (units group player);

// --- ФИНАЛЬНАЯ СИНХРОНИЗАЦИЯ ---
{
    if (alive _x) then {
        if (isNil {_x getVariable "cti_net"}) then {
            _x setVariable ["cti_net", _sideID, true];
            // AN_iNet НЕ устанавливаем здесь - это должно быть установлено через AN_Launch
        };
        
        _x setVariable ["cti_ai_order", CTI_ORDER_CLIENT_NONE, true];
        _x setVariable ["cti_ai_order_pos", [0,0], true];
        _x setVariable ["cti_ai_side", _side, true];
        _x setVariable ["cti_ai_group", group player, true];
        _x setVariable ["cti_ai_player", true, true];
        
        _x setSkill 0.5;
        _x setUnitAbility 0.5;
        
        if (!(_x in CTI_AI_Units)) then {
            CTI_AI_Units pushBack _x;
        };
    };
} forEach ((units player - [player]) call CTI_CO_FNC_GetLiveUnits);

// ИСПРАВЛЕНИЕ БАГА #1: publicVariable заменён на запрос к серверу
["SERVER", "Request_Update_AIUnits", [CTI_AI_Units, CTI_Player_Vehicles]] call CTI_CO_FNC_NetSend;

// ИСПРАВЛЕНИЕ БАГА #2: UI-функции только на клиенте, без remoteExec target 0
if (!CTI_IsServer) then {
    [] call CTI_CL_FNC_UpdateTeamUI;
    [] call CTI_UI_Map_Update;
    [] call CTI_UI_Team_Update;
};

player groupChat (localize "STR_CTI_SquadReady_Custom");
diag_log format ["[BECTI] Стартовый отряд игрока %1 успешно инициализирован. AI: %2, Техника: %3", 
    name player, count CTI_AI_Units, count CTI_Player_Vehicles];