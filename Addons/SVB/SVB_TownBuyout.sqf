// ============================================================
// SVB Town Buyout — выкуп городов сопротивления через переговорщика
// Спавн на 900м рядом с игроком, бот убиваемый, параметр вкл/выкл, EN/RU
// Цена: прогрессивная; после первого захвата города НЕ на линии связи = x2
// Сервер: спавн/удаление бота, выкуп (авторитет по деньгам и городу)
// Клиент: локальные addAction на боте (JIP-safe по построению)
// Сеть: только штатный CTI_CO_FNC_NetSend (publicVariable CTI_NetCom)
// ============================================================

// --- Параметр миссии (лобби): SVB_TOWN_BUYOUT. В SP Init_Parameters не выполняется — дефолт 1 ---
svb_town_buyout_enabled = ((missionNamespace getVariable ["SVB_TOWN_BUYOUT", 1]) isEqualTo 1);

// --- Настройки (крути тут) ---
if (isNil "svb_town_buyout_multiplier") then { svb_town_buyout_multiplier = 200; };    // базовая цена = cti_town_value * множитель
if (isNil "svb_town_buyout_minPrice")   then { svb_town_buyout_minPrice = 50000; };   // минимальная цена выкупа
if (isNil "svb_town_buyout_hourStep")   then { svb_town_buyout_hourStep = 100; };     // на сколько растёт множитель каждый час
if (isNil "svb_town_buyout_transferTime") then { svb_town_buyout_transferTime = 20; };  // фаза передачи денег = окно перехвата, сек
if (isNil "svb_town_dealer_notifyRange") then { svb_town_dealer_notifyRange = 2000; };   // радиус оповещения игроков о сделке
if (isNil "svb_town_buyout_offlink_mult") then { svb_town_buyout_offlink_mult = 2; }; // множитель за город НЕ на линии связи
<<<<<<< HEAD
if (isNil "svb_town_dealer_spawnRange") then { svb_town_dealer_spawnRange = 900; };   // зона переговоров (> 800м детекции сопротивления)
=======
if (isNil "svb_town_dealer_spawnRange") then { svb_town_dealer_spawnRange = 1000; };   // зона переговоров (> 800м детекции сопротивления)
>>>>>>> 172fc410eb02e2eeb8f136e9dfa9dc15aa923a8a
if (isNil "svb_town_dealer_talkRange")  then { svb_town_dealer_talkRange = 10; };      // радиус диалога
if (isNil "svb_town_dealer_cooldown")   then { svb_town_dealer_cooldown = 600; };     // кулдаун после отказа/выкупа, сек
if (isNil "svb_town_dealers") then { svb_town_dealers = []; };                        // живые боты (синхронизируется сервером)

// --- Есть ли у города прямая линия связи с городом данной стороны ---
svb_fnc_townLinkedToSide = {
    params [["_town", objNull, [objNull]], ["_side", sideUnknown, [sideUnknown]]];
    if (isNull _town) exitWith {false};
    private _own = _side call CTI_CO_FNC_GetSideTowns;
    if (count _own isEqualTo 0) exitWith {false};
    private _neigh = _town getVariable ["CTI_Neigh", []];
    private _linked = false;
    { if (_x in _own) exitWith {_linked = true}; } forEach _neigh;
    _linked
};

// --- Цена выкупа города: адаптивный множитель (+step за каждый час) + x2 если не на линии связи ---
svb_fnc_townBuyoutPrice = {
    params [["_town", objNull, [objNull]], ["_side", sideUnknown, [sideUnknown]]];
    if (isNull _town) exitWith {0};
    private _baseValue = _town getVariable ["cti_town_value", 0];
    if !(_baseValue isEqualType 0) exitWith {0};
    // Адаптивный множитель: базовый + 100 за каждый ПОЛНЫЙ час миссии (ступенчато)
    private _hours = floor (time / 3600);
    private _mult = svb_town_buyout_multiplier + (_hours * svb_town_buyout_hourStep);
    private _price = round (svb_town_buyout_minPrice max (_baseValue * _mult));
    // Если сторона уже владеет городами и этот НЕ на линии — x2 сверху
    if ((count (_side call CTI_CO_FNC_GetSideTowns)) > 0 && {!([_town, _side] call svb_fnc_townLinkedToSide)}) then {
        _price = _price * svb_town_buyout_offlink_mult;
    };
    _price
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
        _grp deleteGroupWhenEmpty true;
        private _unit = _grp createUnit ["C_man_1", _pos, [], 0, "NONE"];
        _unit forceAddUniform "U_I_OfficerUniform";

        // ИИ его не трогает, но анимации остаются рабочими
        removeAllWeapons _unit;
        _unit allowFleeing 0;
        _unit setSkill ["courage", 1];
        _grp setBehaviour "CARELESS";
        _grp setCombatMode "BLUE";
        doStop _unit;
        _unit forceSpeed 0;
        _unit disableAI "TARGET";
        _unit disableAI "AUTOTARGET";
        _unit disableAI "AUTOCOMBAT";
        _unit disableAI "SUPPRESSION";
        _unit disableAI "COVER";
        _unit setUnitPos "UP";
        _unit setCaptive true;
        _unit switchMove "AmovPercMstpSnonWnonDnon";
        _unit setName localize "STR_SVB_TownBuyout_Name";
        _unit setDir (_unit getDir _player);

        // --- РЕГИСТРАЦИЯ БОТА ---
        _unit setVariable ["svb_town_dealer_town", _town, true];
	    _unit setVariable ["svb_town_dealer_side", side _player, true];  // сторона, для которой заспавнился переговорщик
        _town setVariable ["svb_town_dealer", _unit, true];
        svb_town_dealers pushBack _unit;
        publicVariable "svb_town_dealers";

                        // Убийство бота = перехват сделки ИЛИ обычный срыв
        _unit addEventHandler ["Killed", {
            params ["_unit", "_killer", "_instigator"];
            private _town = _unit getVariable ["svb_town_dealer_town", objNull];
            if (isNull _town) exitWith {};
            private _townName = _town getVariable ["cti_town_name", "?"];
            private _who = if (!isNull _instigator) then {_instigator} else {_killer};
            private _deal = _town getVariable ["svb_town_buyout_deal", []];

            if (count _deal > 0) then {
                // === СДЕЛКА В ПРОЦЕССЕ ===
                _deal params ["_grp", "_side", "_price", "_client"];
                _town setVariable ["svb_town_buyout_intercepted", true];
                _town setVariable ["svb_town_buyout_deal", []];
                _town setVariable ["svb_town_deal_info", [], true];
                // КУЛДАУН: бот не появляется 10 минут после срыва сделки
                _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true];

                if (!isNull _who && {isPlayer _who} && {side _who in [west, east]} && {side _who != _side}) then {
                    // Враг убил → деньги уходят убийце, город остаётся зелёным
                    [group _who, side _who, _price] call CTI_CO_FNC_ChangeFunds;
                    [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_InterceptedBuyer", [_price]]]] call CTI_CO_FNC_NetSend;
                    [["CLIENT", _who], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_InterceptedKiller", [_price]]]] call CTI_CO_FNC_NetSend;
                    diag_log format ["[SVB_TOWN_BUYOUT] %1: сделка перехвачена %2, $%3 переведены убийце, кулдаун %4с", _townName, name _who, _price, svb_town_dealer_cooldown];
                } else {
                    // Свой/ИИ убил → деньги теряются, город остаётся зелёным
                    [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_InterceptedLost", []]]] call CTI_CO_FNC_NetSend;
                    diag_log format ["[SVB_TOWN_BUYOUT] %1: сделка сорвана своими, $%2 потеряны, кулдаун %3с", _townName, _price, svb_town_dealer_cooldown];
                };
            } else {
                // === ОБЫЧНОЕ УБИЙСТВО ВНЕ СДЕЛКИ ===
                _town setVariable ["svb_town_dealer_killed", true, true];
                // КУЛДАУН: бот не появляется 10 минут после убийства вне сделки
                _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true];
                [["CLIENT", west], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Killed", [_townName]]]] call CTI_CO_FNC_NetSend;
                [["CLIENT", east], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Killed", [_townName]]]] call CTI_CO_FNC_NetSend;
                diag_log format ["[SVB_TOWN_BUYOUT] %1: переговорщик убит (%2), выкуп заблокирован, кулдаун %3с",
                    _townName, if (!isNull _who) then {name _who} else {"неизвестно"}, svb_town_dealer_cooldown];
            };
        }];
    };

        // --- Обработка выкупа: оплата -> передача денег (окно перехвата) -> уборка -> переход ---
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
        if (_client distance _dealer > (svb_town_dealer_talkRange + 5)) exitWith {};

        if (_town getVariable ["svb_town_buyout_lock", false]) exitWith {};
        _town setVariable ["svb_town_buyout_lock", true];

        private _price = [_town, _side] call svb_fnc_townBuyoutPrice;
        private _group = group _client;
        private _funds = [_group, _side] call CTI_CO_FNC_GetFunds;
        private _townName = _town getVariable ["cti_town_name", "?"];

        if (_price <= 0 || _funds < _price) exitWith {
            _town setVariable ["svb_town_buyout_lock", false];
            [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_NeedPrice", [_price]]]] call CTI_CO_FNC_NetSend;
        };

        // Списание — серверный авторитет
        [_group, _side, -_price] call CTI_CO_FNC_ChangeFunds;
        // Сделка: серверная запись для Killed EH + публичная для клиентов
        _town setVariable ["svb_town_buyout_deal", [_group, _side, _price, _client]];
        _town setVariable ["svb_town_deal_info", [_side, _price], true];
        _town setVariable ["svb_town_buyout_intercepted", false];

        // --- Оповещение всех nearby: своим защищать, врагам перехватывать ---
        {
            if (alive _x && {isPlayer _x} && {side _x in [west, east]} && {_x distance _town <= svb_town_dealer_notifyRange}) then {
                if (side _x isEqualTo _side) then {
                    [["CLIENT", _x], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_DealFriendly", [_townName, _price, svb_town_buyout_transferTime]]]] call CTI_CO_FNC_NetSend;
                } else {
                    [["CLIENT", _x], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_DealEnemy", [_townName, _price, svb_town_buyout_transferTime]]]] call CTI_CO_FNC_NetSend;
                };
            };
        } forEach allPlayers;

        diag_log format ["[SVB_TOWN_BUYOUT] %1 платит $%2 за %3, передача %4с", name _client, _price, _townName, svb_town_buyout_transferTime];

        // === ФАЗА 1: передача денег. Гарнизон ещё на месте, окно перехвата ===
        private _transferEnd = time + svb_town_buyout_transferTime;
        waitUntil {
            (_town getVariable ["svb_town_buyout_intercepted", false])
            || ((_town getVariable ["cti_town_sideID", -1]) != CTI_RESISTANCE_ID)
            || time >= _transferEnd
        };

        if (_town getVariable ["svb_town_buyout_intercepted", false]) exitWith {
            _town setVariable ["svb_town_buyout_intercepted", false];
            _town setVariable ["svb_town_deal_info", [], true];
            _town setVariable ["svb_town_buyout_lock", false];
            _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true]; 
            [_town] call svb_fnc_townDealerRemove;
            diag_log format ["[SVB_TOWN_BUYOUT] %1: сделка провалена (перехват при передаче)", _townName];
        };

        if ((_town getVariable ["cti_town_sideID", -1]) != CTI_RESISTANCE_ID) exitWith {
            [_group, _side, _price] call CTI_CO_FNC_ChangeFunds;
            _town setVariable ["svb_town_buyout_deal", []];
            _town setVariable ["svb_town_deal_info", [], true];
            _town setVariable ["svb_town_buyout_lock", false];
            _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true];
            [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Refund", []]]] call CTI_CO_FNC_NetSend;
        };

        // === ФАЗА 2: уборка гарнизона штатной FSM ===
        _town setVariable ["svb_town_buyout", true, true];
        private _timeout = time + 20;
        waitUntil {
            !(_town getVariable ["cti_town_resistance_active", false])
            || time > _timeout
            || (_town getVariable ["svb_town_buyout_intercepted", false])
        };

        if (_town getVariable ["svb_town_buyout_intercepted", false]) exitWith {
            _town setVariable ["svb_town_buyout_intercepted", false];
            _town setVariable ["svb_town_buyout", false, true];
            _town setVariable ["svb_town_deal_info", [], true];
            _town setVariable ["svb_town_buyout_lock", false];
            [_town] call svb_fnc_townDealerRemove;
            diag_log format ["[SVB_TOWN_BUYOUT] %1: сделка провалена (перехват при уборке)", _townName];
        };

        if ((_town getVariable ["cti_town_sideID", -1]) != CTI_RESISTANCE_ID) exitWith {
            [_group, _side, _price] call CTI_CO_FNC_ChangeFunds;
            _town setVariable ["svb_town_buyout_deal", []];
            _town setVariable ["svb_town_deal_info", [], true];
            _town setVariable ["svb_town_buyout", false, true];
            _town setVariable ["svb_town_buyout_lock", false];
            [["CLIENT", _client], "Client_OnMessageReceived", ["svb-dealer", ["STR_SVB_TownBuyout_Refund", []]]] call CTI_CO_FNC_NetSend;
        };

        // === ФАЗА 3: переход города, без награды за захват ===
        [_town, _side, false] call CTI_SE_FNC_OnTownCaptured;
        _town setVariable ["svb_town_buyout_deal", []];
        _town setVariable ["svb_town_deal_info", [], true];

        [_town] call svb_fnc_townDealerRemove;
        _town setVariable ["svb_town_dealer_blockedUntil", time + svb_town_dealer_cooldown, true];
        _town setVariable ["svb_town_buyout_lock", false];
        diag_log format ["[SVB_TOWN_BUYOUT] %1 перешёл к %2 без боя", _townName, _side];

        [_town] spawn {
            params ["_town"];
            sleep 5;
            if !(_town getVariable ["cti_town_resistance_active", false]) then {
                _town setVariable ["svb_town_buyout", false, true];
            };
        };
    };

    // --- Отказ от сделки ---
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

        // --- Серверный цикл спавна/уборки ---
    svb_fnc_townDealerLoop = {
        waitUntil {!isNil "CTI_Init_Server" && {CTI_Init_Server} && !isNil "CTI_InitTowns" && {CTI_InitTowns}};
        while {!CTI_GameOver} do {
            private _players = allPlayers select {alive _x && side _x in [west, east]};
            {
                private _town = _x;
                if (!isNull _town) then {
                    private _dealer = _town getVariable ["svb_town_dealer", objNull];
                    // Труп/удалённый извне — прибираем
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
                            private _sorted = [_town, _near] call CTI_CO_FNC_SortByDistance;
                            [_town, _sorted select 0] call svb_fnc_townDealerSpawn;
                        } else {
                            // ВАЖНО: во время сделки (_busy) бота НЕ трогаем — он должен жить
                            // все 20 сек передачи денег, чтобы противник успел его убить (перехват).
                            // Удалит его сам обработчик сделки в конце или при перехвате.
                            if (!isNull _dealer && {!_busy && {count _near isEqualTo 0 || _blocked}}) then {
                                [_town] call svb_fnc_townDealerRemove;
                            };
                        };
                    } else {
                        // Город сменил владельца — убираем бота и сбрасываем срыв
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
// КЛИЕНТСКАЯ ЧАСТЬ
// ============================================================
if (hasInterface && svb_town_buyout_enabled) then {
        svb_fnc_townDealerClientLoop = {
        waitUntil {!isNil "CTI_Init_Client" && {CTI_Init_Client}};

        if (isNil "svb_dealer_waveAnim") then {
            svb_dealer_waveAnim = "";
            svb_dealer_idleAnim = "";
            private _states = ("true" configClasses (configFile >> "CfgMovesMaleSdr" >> "States")) apply {configName _x};
            {
                private _n = toLower _x;
                if (_n find "civil" >= 0 && {(_n find "talk" >= 0) || (_n find "wave" >= 0) || (_n find "greet" >= 0)}) exitWith {
                    svb_dealer_waveAnim = _x;
                };
            } forEach _states;
            if (svb_dealer_waveAnim isEqualTo "") then {
                {
                    if ((toLower _x) find "aidlpercmstpsnonwnondnon" >= 0) exitWith { svb_dealer_waveAnim = _x; };
                } forEach _states;
            };
            {
                if (_x isEqualTo "AmovPercMstpSnonWnonDnon") exitWith { svb_dealer_idleAnim = _x; };
            } forEach _states;
            diag_log format ["[SVB_TOWN_BUYOUT] Гражданские анимации переговорщика: взмах=%1, идл=%2", svb_dealer_waveAnim, svb_dealer_idleAnim];
        };

        private _dealer = objNull;
        private _actBuy = -1;
        private _actRefuse = -1;
        private _animatedDealer = objNull;
        private _nextAimMsg = 0;

        while {!CTI_GameOver} do {
            sleep 2;
            private _near = objNull;
            {
                if (!isNull _x && {alive _x}) then {
                    private _dist = _x distance player;
                    if (_dist <= 120 && {svb_dealer_waveAnim isNotEqualTo ""} && {_animatedDealer isNotEqualTo _x}) then {
                        _x switchMove svb_dealer_waveAnim;
                        _animatedDealer = _x;
                    };
                    if (_dist <= svb_town_dealer_talkRange && isNull _near) then { _near = _x; };
                };
            } forEach (missionNamespace getVariable ["svb_town_dealers", []]);

            // --- Опознание прицелом: кто такой переговорщик и идёт ли сделка ---
            private _look = cursorTarget;
            if (!isNull _look && {alive _look} && {_look in (missionNamespace getVariable ["svb_town_dealers", []])} && {time >= _nextAimMsg}) then {
                private _lt = _look getVariable ["svb_town_dealer_town", objNull];
                if (!isNull _lt) then {
                    private _ln = _lt getVariable ["cti_town_name", "?"];
                    private _info = _lt getVariable ["svb_town_deal_info", []];
                    if (count _info > 0) then {
                        _info params ["_dealSide", "_dealPrice"];
                        // Сообщение о перехвате — только врагу покупателя
                        if !(CTI_P_SideJoined isEqualTo _dealSide) then {
                            systemChat format [localize "STR_SVB_TownBuyout_AimDeal", _ln, _dealPrice];
                            _nextAimMsg = time + 10;
                        };
                         } else {
                        private _ds = _look getVariable ["svb_town_dealer_side", sideUnknown];
                        if (CTI_P_SideJoined isEqualTo _ds) then {
                            // Я — сторона инициатора: приглашение выкупить, БЕЗ "убей"
                            systemChat format [localize "STR_SVB_TownBuyout_AimIdleOwn", _ln];
                        } else {
                            // Я — противник: подсказка сорвать сделку
                            systemChat format [localize "STR_SVB_TownBuyout_AimIdle", _ln];
                        };
                        _nextAimMsg = time + 20;
                    };
                };
            };

            if (!isNull _dealer && {_dealer isNotEqualTo _near}) then {
                _dealer removeAction _actBuy;
                _dealer removeAction _actRefuse;
                _dealer = objNull; _actBuy = -1; _actRefuse = -1;
            };

            if (!isNull _near && {isNull _dealer}) then {
                _dealer = _near;
                private _town = _dealer getVariable ["svb_town_dealer_town", objNull];
                private _price = [_town, CTI_P_SideJoined] call svb_fnc_townBuyoutPrice;
                private _name = _town getVariable ["cti_town_name", "?"];

                _actBuy = _dealer addAction [
                    format [localize "STR_SVB_TownBuyout_Buy", _name, _price],
                    {
                        params ["_target", "_caller"];
                        private _town = _target getVariable ["svb_town_dealer_town", objNull];
                        if (isNull _town) exitWith {};
                        private _price = [_town, CTI_P_SideJoined] call svb_fnc_townBuyoutPrice;
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