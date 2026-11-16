AN_Check_Connection = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_CheckConn.sqf";
AN_Reconfigure = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_Reconfigure.sqf";
AN_Launch = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_Launch.sqf";
AN_Update_Connection = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_Update_Connection.sqf";
AN_Handle_Team = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_Handle_Team.sqf";

AN_Switchable = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_Switchable.sqf";
AN_Reconfigure_loop = compile preprocessFileLineNumbers "Addons\Strat_mode\AdvNet\AN_Reconfigure_Loop.sqf";

with missionNamespace do {
	CTI_PVF_Server_Run_Net = {
		_this spawn AN_Launch;
	};
};

0 execVM "Addons\Strat_mode\AdvNet\AN_Ex_Intrusion.sqf";

waitUntil {
	sleep 0.1;
	CTI_Init_Strat && CTI_InitTowns
};

// === КЛИЕНТ: только чтение реплики, сеть не поднимает ===
if (CTI_IsClient && hasInterface) then {
	0 spawn {
		while {!CTI_GameOver} do {

			waitUntil {
				sleep 0.5;
				!isNull player && alive player
			};

			// Сеть поднимает сервер. Клиент ждёт реплику переменных и ничего не пишет.
			waitUntil {
				sleep 0.2;
				!isNull player &&
				!isNil {player getVariable "CTI_Net"} &&
				!isNil {player getVariable "AN_iNet"} &&
				!isNil {player getVariable "AN_Conn"}
			};

			while {alive player && !CTI_GameOver} do {
				private _net = player getVariable ["CTI_Net", -1];
				private _inet = player getVariable ["AN_iNet", -1];
				private _conn = player getVariable ["AN_Conn", objNull];

				private _isConnected =
					(_net > -1) &&
					{_net isEqualTo _inet} &&
					{!isNull _conn} &&
					{alive _conn};

				// Client_AN_Connected — производное состояние для UI
				if (isNil "Client_AN_Connected" || {Client_AN_Connected != _isConnected}) then {
					Client_AN_Connected = _isConnected;
				};

				sleep 0.2;
			};
		};
	};
};

// === СЕРВЕР: подъём сети + покрытие респавна + инвариант принадлежности ===
if (CTI_IsServer) then {

	waitUntil {
		sleep 0.1;
		CTI_Init_Server
	};

	{
		[_x, -1] spawn AN_Launch;
		true
	} count CTI_Towns;

	// Подъём сети игрокам. После респавна объект игрока НОВЫЙ,
	// поэтому сканируем периодически, а не один раз при ините.
	// Проверяем ОБА handle: живой upd при мёртвом/отсутствующем rec
	// означает что AN_Conn никогда не найдётся (родителя ищет только AN_Reconfigure).
	0 spawn {
		while {!CTI_GameOver} do {
			{
				private _p = _x;
				if (isNull _p) then {continue};

				// --- Подъём циклов ---
				// Сторона берётся от ГРУППЫ: при разрушении техники side юнита
				// кратковременно становится CIV, группа сторону сохраняет.
				// Без фильтра в AN_Launch уходил -1 и убивал сеть узла навсегда.
				if (alive _p) then {
					private _hu = _p getVariable ["AN_updHandle", scriptNull];
					private _hr = _p getVariable ["AN_recHandle", scriptNull];
					if (
						isNil {_p getVariable "CTI_Net"} ||
						{isNil {_p getVariable "AN_iNet"}} ||
						{isNull _hu} || {scriptDone _hu} ||
						{isNull _hr} || {scriptDone _hr}
					) then {
						private _pside = side group _p;
						if (_pside in [west, east]) then {
							[_p, _pside call CTI_CO_FNC_GetSideID] spawn AN_Launch;
						};
					};
				};

				// --- Инвариант принадлежности ---
				// CTI_Net игрока держим равным его стороне из CTI_SERVER_CLIENT_<uid>
				// (index 3, пишет Server_OnPlayerConnected). Этот источник от side юнита
				// не зависит, крушение его не портит.
				// Пропускаем игрока, который сам выключил сеть кнопкой (AN_NetOff).
				// Метка живёт на объекте -> после респавна её нет -> сеть встанет сама.
				if !(_p getVariable ["AN_NetOff", false]) then {
					private _rec = missionNamespace getVariable [format ["CTI_SERVER_CLIENT_%1", getPlayerUID _p], []];
					if (count _rec > 3) then {
						private _s = _rec select 3;
						if (typeName _s == "SIDE" && {_s in [west, east]}) then {
							private _want = _s call CTI_CO_FNC_GetSideID;
							if ((_p getVariable ["CTI_Net", -1]) != _want) then {
								_p setVariable ["CTI_Net", _want, true];
								diag_log format [":: NET :: membership held for %1 -> %2", name _p, _s];
							};
						};
					};
				};
			} forEach allPlayers;
			sleep 1;
		};
	};
};