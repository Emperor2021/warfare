// ============================================================
// SVB Town Buyout — выкуп городов сопротивления через переговорщика
// Спавн на 900м рядом с игроком, бот убиваемый, параметр вкл/выкл, EN/RU
// Сервер: спавн/удаление бота, выкуп (авторитет по деньгам и городу)
// Клиент: локальные addAction на боте (JIP-safe по построению)
// Сеть: только штатный CTI_CO_FNC_NetSend (publicVariable CTI_NetCom)
// ============================================================

// --- Параметр миссии (лобби): SVB_TOWN_BUYOUT. В SP Init_Parameters не выполняется — дефолт 1 ---
svb_town_buyout_enabled = ((missionNamespace getVariable ["SVB_TOWN_BUYOUT", 1]) isEqualTo 1);

// --- Настройки (крути тут) ---
if (isNil "svb_town_buyout_multiplier") then { svb_town_buyout_multiplier = 30; };    // базовая цена = cti_town_value * множитель
if (isNil "svb_town_buyout_minPrice")   then { svb_town_buyout_minPrice = 50000; };   // минимальная цена выкупа
if (isNil "svb_town_dealer_spawnRange") then { svb_town_dealer_spawnRange = 900; };   // зона переговоров (> 800м детекции сопротивления)
if (isNil "svb_town_dealer_talkRange")  then { svb_town_dealer_talkRange = 8; };      // радиус диалога
if (isNil "svb_town_dealer_cooldown")   then { svb_town_dealer_cooldown = 600; };     // кулдаун после отказа/выкупа, сек
if (isNil "svb_town_dealers") then { svb_town_dealers = []; };                        // живые боты (синхронизируется сервером)

// --- Цена выкупа города (прогрессивная, растёт со временем как ремонт КШМ) ---
svb_fnc_townBuyoutPrice = {
    params [["_town", objNull, [objNull]]];
    if (isNull _town) exitWith {0};
    private _baseValue = _town getVariable ["cti_town_value", 0];
    if !(_baseValue isEqualType 0) exitWith {0};
    private _basePrice = _baseValue * svb_town_buyout_multiplier;
    private _timeHours = time / 3600;
    private _price = _basePrice * (1 + _timeHours);
    round (svb_town_buyout_minPrice max _price)
};

// ============================================================
// СЕРВЕРНАЯ ЧАСТЬ
// ============================================================
if (isServer) then {

    // --- Удалить переговорщика города ---
    svb_fnc_townDealerRemove = {
        params [["_town", objNull, [objNull]]];
        if (isNull _town) exitWith {};
        private _dealer = _town getVariable ["svb_town_dealer", objNull];
        if (!isNull _dealer) then {
            private _grp = group _dealer;
            missionNamespace setVariable ["svb_town_dealers", svb_town_dealers - [_dealer], true];
            deleteVehicle _dealer;
            if (!isNull _grp) then { deleteGroup _grp; };
        };
        _town setVariable ["svb_town_dealer", objNull, true];
    };

    // --- Создать переговорщика рядом с игроком (в сторону города) ---
     svb_fnc_townDealerSpawn = {
        params [["_town", objNull, [objNull]], ["_player", objNull, [objNull]]];
        if (isNull _town || isNull _player) exitWith {};

        // 30м от игрока в направлении города + сдвиг 15м влево/вправо, чтобы машина не заехала на него
        private _dirToTown = _player getDir _town;
        private _sideOffset = selectRandom [-90, 90];
        private _pos = (_player getPos [30, _dirToTown]) getPos [15, _dirToTown + _sideOffset];
        _pos set [2, 0];
        _pos = [_pos, 8] call CTI_CO_FNC_GetEmptyPosition;

        private _grp = createGroup civilian;
        _grp deleteGroupWhenEmpty true; // страховка от утечки пустых групп
        private _unit = _grp createUnit ["C_man_1", _pos, [], 0, "NONE"];
		        _unit forceAddUniform "U_I_OfficerUniform";
        

        // ИИ его не трогает, но анимации остаются рабочими
        removeAllWeapons _unit;
        _unit allowFleeing 0;
        _unit setSkill ["courage", 1];
        _grp setBehaviour "CARELESS";
        _grp setCombatMode "BLUE";
        // Держим физически на месте, но FSM/анимации работают
        doStop _unit;
        _unit forceSpeed 0;
        // Отключаем только то, что мешает (НЕ отключаем MOVE/FSM — они нужны для анимаций)
        _unit disableAI "TARGET";
        _unit disableAI "AUTOTARGET";
        _unit disableAI "AUTOCOMBAT";
        _unit disableAI "SUPPRESSION";
        _unit disableAI "COVER";
        _unit setUnitPos "UP";
        _unit setCaptive true;
        // Принудительно стойка стоя
        _unit switchMove "AmovPercMstpSnonWnonDnon";
        _unit setName localize "STR_SVB_TownBuyout_Name";
        _unit setDir (_unit getDir _player);

        // --- РЕГИСТРАЦИЯ БОТА (без этого вся механика мертва) ---
        _unit setVariable ["svb_town_dealer_town", _town, true];
        _town setVariable ["svb_town_dealer", _unit, true];
        svb_town_dealers pushBack _unit;
        publicVariable "svb_town_dealers";

        // Убийство бота = срыв переговоров. ЕХ на сервере (юнит локален серверу), без блокирующих команд
        _unit addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator"];
            private _town = _unit getVariable ["svb_town_dealer_town", objNull];
            if (isNull _town) exitWith {};
            // Выкуп заблокирован, пока город не сменит владельца — только классический захват
            _town setVariable ["svb_town_dealer_killed", true, true];
            private _townName = _town getVariable ["cti_town_name", "?"];
            // Уведомляем обе стороны: сделка сорвана для всех (локализация на клиенте)
            [["CLIENT", west], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Killed", [_townName]]]] call CTI_CO_FNC_NetSend;
            [["CLIENT", east], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Killed", [_townName]]]] call CTI_CO_FNC_NetSend;
            private _who = if (!isNull _instigator) then {_instigator} else {_killer};
            diag_log format ["[SVB_TOWN_BUYOUT] %1: переговорщик убит (%2), выкуп заблокирован до смены владельца",
                _townName, if (!isNull _who) then {name _who} else {"неизвестно"}];
        }];
    };

    // --- Обработка выкупа (СТI_PВФ_Request_TownBuyout, spawn) ---
    svb_fnc_townBuyoutServer = {
        params [["_town", objNull, [objNull]], ["_client", objNull, [objNull]]];
        if (!isServer || !svb_town_buyout_enabled) exitWith {};
        if (isNull _town || isNull _client) exitWith {};
        if !(_town in CTI_Towns) exitWith {};
        if !(alive _client && isPlayer _client) exitWith {};

        private _side = side _client;
        if !(_side in [west, east]) exitWith {};
        if ((_town getVariable ["cti_town_sideID", -1]) != CTI_RESISTANCE_ID) exitWith {};
        if (_town getVariable ["svb_town_dealer_killed", false]) exitWith {};

        private _dealer = _town getVariable ["svb_town_dealer", objNull];
        if (isNull _dealer || !alive _dealer) exitWith {};
        // Античит: покупать можно только стоя рядом с ботом
        if (_client distance _dealer > (svb_town_dealer_talkRange + 5)) exitWith {};

        // Лок от параллельных выкупов (серверный, не сетевой)
        if (_town getVariable ["svb_town_buyout_lock", false]) exitWith {};
        _town setVariable ["svb_town_buyout_lock", true];

        private _price = [_town] call svb_fnc_townBuyoutPrice;
        private _group = group _client;
        private _funds = [_group, _side] call CTI_CO_FNC_GetFunds;
        private _townName = _town getVariable ["cti_town_name", "?"];

        if (_price <= 0 || _funds < _price) exitWith {
            _town setVariable ["svb_town_buyout_lock", false];
            [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_NeedPrice", [_price]]]] call CTI_CO_FNC_NetSend;
        };

        // Списание — серверный авторитет
        [_group, _side, -_price] call CTI_CO_FNC_ChangeFunds;
        // Флаг для ФСМ town_resistance: принудительно убрать зелёных (состояние Cleanup)
        _town setVariable ["svb_town_buyout", true, true];
        [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Paid", [_price, _townName]]]] call CTI_CO_FNC_NetSend;
        diag_log format ["[SVB_TOWN_BUYOUT] %1 платит $%2 за %3", name _client, _price, _townName];

        // Ждём, пока ФСМ уберёт гарнизон (цикл ФСМ ~2с), максимум 20с.
        // Если город не активировался (переговоры на 900м) — сопротивление неактивно, проходим сразу
        private _timeout = time + 20;
        waitUntil { !(_town getVariable ["cti_town_resistance_active", false]) || time > _timeout };

        // Пока ждали — город могли захватить обычным путём. Возврат денег.
        if ((_town getVariable ["cti_town_sideID", -1]) != CTI_RESISTANCE_ID) exitWith {
            [_group, _side, _price] call CTI_CO_FNC_ChangeFunds;
            _town setVariable ["svb_town_buyout", false, true];
            _town setVariable ["svb_town_buyout_lock", false];
            [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Refund", []]]] call CTI_CO_FNC_NetSend;
        };

        // Смена владельца штатной функцией, БЕЗ награды за захват (3-й параметр)
        [_town, _side, false] call CTI_SE_FNC_OnTownCaptured;

        [_town] call svb_fnc_townDealerRemove;
        _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true];
        _town setVariable ["svb_town_buyout_lock", false];
        diag_log format ["[SVB_TOWN_BUYOUT] %1 перешёл к %2 без боя", _townName, _side];

        // Сброс флага для ФСМ: если гарнизона не было — Cleanup не запустится, снимаем сами.
        // Если зелёные успели заспавниться в окно смены стороны — флаг оставим, ФСМ их уберёт и сбросит сам.
        [_town] spawn {
            params ["_town"];
            sleep 5;
            if !(_town getVariable ["cti_town_resistance_active", false]) then {
                _town setVariable ["svb_town_buyout", false, true];
            };
        };
    };

    // --- Отказ от сделки (мягкий: кулдаун, бот вернётся) ---
    svb_fnc_townBuyoutRefuse = {
        params [["_town", objNull, [objNull]], ["_client", objNull, [objNull]]];
        if (!isServer || !svb_town_buyout_enabled) exitWith {};
        if (isNull _town || isNull _client) exitWith {};
        if ((_town getVariable ["cti_town_sideID", -1]) != CTI_RESISTANCE_ID) exitWith {};
        if (_town getVariable ["svb_town_buyout_lock", false]) exitWith {};
        private _dealer = _town getVariable ["svb_town_dealer", objNull];
        if (isNull _dealer) exitWith {};
        if (_client distance _dealer > (svb_town_dealer_talkRange + 5)) exitWith {};

        [_town] call svb_fnc_townDealerRemove;
        _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true];
        [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Refused", []]]] call CTI_CO_FNC_NetSend;
    };

    // --- Серверный цикл: спавн/уборка ботов (один цикл на миссию, шаг 5с) ---
    svb_fnc_townDealerLoop = {
        waitUntil {!isNil "CTI_Init_Server" && {CTI_Init_Server} && !isNil "CTI_InitTowns" && {CTI_InitTowns}};
        while {!CTI_GameOver} do {
            private _players = allPlayers select {alive _x && side _x in [west, east]};
            {
                private _town = _x;
                if (!isNull _town) then {
                    private _dealer = _town getVariable ["svb_town_dealer", objNull];
                    // Бота убили/удалили извне — прибираем труп и группу
                    if (!isNull _dealer && {!alive _dealer}) then {
                        [_town] call svb_fnc_townDealerRemove;
                        _dealer = objNull;
                    };
                    if ((_town getVariable ["cti_town_sideID", -1]) isEqualTo CTI_RESISTANCE_ID) then {
                        private _near = _players select {_x distance _town <= svb_town_dealer_spawnRange};
                        private _blocked = time < (_town getVariable ["svb_town_dealer_blockedUntil", 0]);
                        private _killed = _town getVariable ["svb_town_dealer_killed", false];
                        private _busy = _town getVariable ["svb_town_buyout_lock", false];
                        if (isNull _dealer && {!_blocked} && {!_killed} && {!_busy} && {count _near > 0}) then {
                            // Бот появляется рядом с ближайшим к городу игроком в зоне
                            private _sorted = [_town, _near] call CTI_CO_FNC_SortByDistance;
                            [_town, _sorted select 0] call svb_fnc_townDealerSpawn;
                        } else {
                            // Все ушли из зоны / кулдаун / идёт выкуп — бот уходит
                            if (!isNull _dealer && {count _near isEqualTo 0 || _blocked || _busy}) then {
                                [_town] call svb_fnc_townDealerRemove;
                            };
                        };
                    } else {
                        // Город сменил владельца — убираем бота и сбрасываем срыв переговоров
                        if (!isNull _dealer) then { [_town] call svb_fnc_townDealerRemove; };
                        if (_town getVariable ["svb_town_dealer_killed", false]) then {
                            _town setVariable ["svb_town_dealer_killed", false, true];
                        };
                    };
                };
            } forEach CTI_Towns;
            sleep 5;
        };
    };

    if (svb_town_buyout_enabled) then { [] spawn svb_fnc_townDealerLoop; };
};

// ============================================================
// КЛИЕНТСКАЯ ЧАСТЬ — диалог через addAction (как Piers/BigFOB)
// ============================================================
if (hasInterface && svb_town_buyout_enabled) then {
    svb_fnc_townDealerClientLoop = {
        waitUntil {!isNil "CTI_Init_Client" && {CTI_Init_Client}};

        // --- Разово на старте клиента: берём ГРАЖДАНСКИЕ анимации из конфигов этой версии игры ---
        // Названия не выдумываем — читаем что реально есть. Если гражданских нет — запасной идл без оружия
        if (isNil "svb_dealer_waveAnim") then {
            svb_dealer_waveAnim = "";
            svb_dealer_idleAnim = "";
            private _states = ("true" configClasses (configFile >> "CfgMovesMaleSdr" >> "States")) apply {configName _x};
            // 1) гражданская анимация с движениями рук (разговор/махание/приветствие)
            {
                private _n = toLower _x;
                if (_n find "civil" >= 0 && {(_n find "talk" >= 0) || (_n find "wave" >= 0) || (_n find "greet" >= 0)}) exitWith {
                    svb_dealer_waveAnim = _x;
                };
            } forEach _states;
            // 2) запасной вариант: любой идл без оружия
            if (svb_dealer_waveAnim isEqualTo "") then {
                {
                    if ((toLower _x) find "aidlpercmstpsnonwnondnon" >= 0) exitWith { svb_dealer_waveAnim = _x; };
                } forEach _states;
            };
            // 3) поза к которой возвращаемся после взмаха
            {
                if (_x isEqualTo "AmovPercMstpSnonWnonDnon") exitWith { svb_dealer_idleAnim = _x; };
            } forEach _states;
            diag_log format ["[SVB_TOWN_BUYOUT] Гражданские анимации переговорщика: взмах=%1, идл=%2", svb_dealer_waveAnim, svb_dealer_idleAnim];
        };

        private _dealer = objNull;
        private _actBuy = -1;
        private _actRefuse = -1;
		private _animatedDealer = objNull;

        while {!CTI_GameOver} do {
            sleep 2;
            // Ближайший живой бот в радиусе диалога + махание рукой
            // Анимации — локальный эффект, играем на клиенте (каждый видит сам)
            private _near = objNull;
            {
             if (!isNull _x && {alive _x}) then {
                    private _dist = _x distance player;

                    // Анимация играет ПОСТОЯННО (зациклена) — включаем один раз на бота, не дёргаем каждый тик
                    if (_dist <= 120 && {svb_dealer_waveAnim isNotEqualTo ""} && {_animatedDealer isNotEqualTo _x}) then {
                        _x switchMove svb_dealer_waveAnim;
                        _animatedDealer = _x;
                    };

                    if (_dist <= svb_town_dealer_talkRange && isNull _near) then { _near = _x; };
                };
            } forEach (missionNamespace getVariable ["svb_town_dealers", []]);

            // Ушли/бот исчез — снимаем экшены
            if (!isNull _dealer && {_dealer isNotEqualTo _near}) then {
                _dealer removeAction _actBuy;
                _dealer removeAction _actRefuse;
                _dealer = objNull; _actBuy = -1; _actRefuse = -1;
            };

            // Подошли к новому боту — вешаем диалог
            if (!isNull _near && {isNull _dealer}) then {
                _dealer = _near;
                private _town = _dealer getVariable ["svb_town_dealer_town", objNull];
                private _price = [_town] call svb_fnc_townBuyoutPrice;
                private _name = _town getVariable ["cti_town_name", "?"];

                _actBuy = _dealer addAction [
                    format [localize "STR_SVB_TownBuyout_Buy", _name, _price],
                    {
                        params ["_target", "_caller"];
                        private _town = _target getVariable ["svb_town_dealer_town", objNull];
                        if (isNull _town) exitWith {};
                        private _price = [_town] call svb_fnc_townBuyoutPrice;
                        // Локальная проверка для удобства, сервер всё равно перепроверит
                        if (call CTI_CL_FNC_GetPlayerFunds < _price) exitWith {
                            systemChat format [localize "STR_SVB_TownBuyout_NoFunds", _price];
                        };
                        ["SERVER", "Request_TownBuyout", [_town, _caller]] call CTI_CO_FNC_NetSend;
                    },
                    [], 100, false, true, "",
                    "alive _target && alive player && vehicle player == player"
                ];
                _actRefuse = _dealer addAction [
                    localize "STR_SVB_TownBuyout_Refuse",
                    {
                        params ["_target", "_caller"];
                        private _town = _target getVariable ["svb_town_dealer_town", objNull];
                        if (!isNull _town) then {
                            ["SERVER", "Request_TownBuyoutRefuse", [_town, _caller]] call CTI_CO_FNC_NetSend;
                        };
                    },
                    [], 99, false, true, "",
                    "alive _target && alive player && vehicle player == player"
                ];
                systemChat format [localize "STR_SVB_TownBuyout_Greet", _name, _price];
            };
        };
    };

    [] spawn svb_fnc_townDealerClientLoop;
};