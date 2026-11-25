/*
	Script: Addons\SVB\SVB_TownTaskMarkers.sqf
	Описание: Клиентские задачи (штатный task system Arma 3) по городам линии фронта.
	Правила показа:
	- На старте (своих городов 0) — задачи на ВСЕХ городах, кроме наших.
	- Появились свои города — задачи только на "разрешённых":
	  разрешённый = сосед нашего города по линии CTI_Neigh (сами наши города без задач).
	- Задача на городе, который стал нашим или выпал из разрешённых — завершается.
	- Состояние после создания НЕ трогается: игрок сам назначает/снимает.
	Ожидание имён: waitUntil {CTI_Towns findIf {isNil {...}} == -1} — защита от
	заголовков-координат ("207071") на старте (гонка с Init_Location).
	Удаление: setTaskState "Succeeded" + player removeSimpleTask, только в spawn.
	Проверка дубликатов: по объекту города через isEqualTo.

	Locality: ТОЛЬКО КЛИЕНТ, таски локальные.
	Запуск: 0 execVM из клиентского блока Addons\Strat_mode\init.sqf.
	JIP: безопасно — при входе скрипт строит задачи с нуля по актуальному состоянию.
	Формат записи: [_town, _task, _id]
*/

if (!hasInterface) exitWith {};
waitUntil {!isNil "CTI_InitTowns"};
waitUntil {CTI_InitTowns};
waitUntil {!isNil "CTI_P_SideJoined"};
if (CTI_P_SideJoined == resistance) exitWith {};
waitUntil {!isNil "CTI_P_SideID"};
waitUntil {!isNil "CTI_P_SideLogic"};

// Ждём имена всех городов (findIf == -1 значит "ни одного без имени").
// allSatisfy в SQF НЕ существует — не использовать.
diag_log "[SVB] Жду инициализации имён городов...";
waitUntil {CTI_Towns findIf {isNil {_x getVariable "cti_town_name"}} == -1};
diag_log format ["[SVB] Имена инициализированы, городов: %1", count CTI_Towns];

svb_townTasks = [];

// Имя города: cti_town_name, фолбэк — ближайшая локация, затем сетка (крайний случай)
svb_fnc_townDisplayName = {
	params [["_town", objNull, [objNull]]];
	if (isNull _town) exitWith {""};
	private _name = _town getVariable ["cti_town_name", ""];
	if (_name isEqualTo "") then {
		private _best = "";
		{
			private _loc = nearestLocation [getPos _town, _x];
			if (!isNull _loc && {(getPos _town) distance (locationPosition _loc) < 1000}) exitWith { _best = name _loc };
		} forEach ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"];
		_name = if (_best isEqualTo "") then { mapGridPosition _town } else { _best };
		_town setVariable ["cti_town_name", _name];
	};
	_name
};

svb_fnc_createTownTask = {
	params [["_town", objNull, [objNull]]];
	if (isNull _town) exitWith {taskNull};
	private _townName = [_town] call svb_fnc_townDisplayName;
	private _id = format ["svb_task_%1", _town];
	private _task = player createSimpleTask [_id];
	_task setSimpleTaskType "attack";
	_task setSimpleTaskDescription ["Статус: НЕ НАЗНАЧЕНО", _townName, _townName];
	_task setSimpleTaskTarget [_town, true];
	_task setTaskState "Created";
	_task
};

// Удаление задачи — только в spawn (unscheduled не даёт removeSimpleTask отработать)
svb_fnc_completeTownTask = {
	params [["_task", taskNull, [taskNull]], ["_id", "", [""]]];
	if (isNull _task) exitWith {};
	[_task, _id] spawn {
		params [["_task", taskNull, [taskNull]], ["_id", "", [""]]];
		if (isNull _task) exitWith {};
		_task setTaskState "Succeeded";
		sleep 0.3;
		player removeSimpleTask _task;
		diag_log format ["SVB COMPLETE: %1 завершена и удалена", _id];
	};
};

// Обновляем ТОЛЬКО строку статуса в описании, состояние не трогаем
svb_fnc_updateTownTask = {
	params [["_task", taskNull, [taskNull]], ["_status", "", [""]]];
	if (isNull _task) exitWith {};
	private _desc = format ["Статус: %1", _status];
	if ((taskDescription _task select 0) != _desc) then {
		private _title = taskDescription _task select 1;
		_task setSimpleTaskDescription [_desc, _title, _title];
	};
};

while {!CTI_GameOver} do {
	// 1. Разрешённые города: соседи наших по линиям CTI_Neigh
	private _allowed = [];
	private _ownedCount = 0;
	{
		private _town = _x;
		if ((_town getVariable ["cti_town_sideID", -1]) == CTI_P_SideID) then {
			_ownedCount = _ownedCount + 1;
			{
				if (!isNull _x && {!(_x in _allowed)}) then { _allowed pushBack _x };
			} forEach (_town getVariable ["CTI_Neigh", []]);
		};
	} forEach CTI_Towns;

	// 2. Создаём/удаляем задачи (итерируем по CTI_Towns, не по svb_townTasks)
	{
		private _town = _x;
		private _sideID = _town getVariable ["cti_town_sideID", -1];
		private _isOurs = (_sideID == CTI_P_SideID);
		private _isAllowed = (_town in _allowed) || ((_ownedCount == 0) && !_isOurs);

		private _existingIdx = -1;
		{
			if ((_x select 0) isEqualTo _town) exitWith { _existingIdx = _forEachIndex };
		} forEach svb_townTasks;

		if (_isAllowed && !_isOurs) then {
			if (_existingIdx < 0) then {
				private _newTask = [_town] call svb_fnc_createTownTask;
				if (!isNull _newTask) then {
					svb_townTasks pushBack [_town, _newTask, format ["svb_task_%1", _town]];
				};
			};
		} else {
			if (_existingIdx >= 0) then {
				private _rec = svb_townTasks select _existingIdx;
				[(_rec select 1), (_rec select 2)] call svb_fnc_completeTownTask;
				svb_townTasks deleteAt _existingIdx;
			};
		};
	} forEach CTI_Towns;

	// 3. Строка статуса (бой/приоритет) для живых задач
	private _active = CTI_P_SideLogic getVariable ["CTI_ACTIVE", []];
	private _prio   = CTI_P_SideLogic getVariable ["CTI_PRIORITY", objNull];
	{
		private _town = _x select 0;
		private _task = _x select 1;
		if (!isNull _task) then {
			private _status = switch (true) do {
				case (_town == _prio):   {"ПРИОРИТЕТ"};
				case (_town in _active): {"АТАКА"};
				default                  {"НЕ НАЗНАЧЕНО"};
			};
			[_task, _status] call svb_fnc_updateTownTask;
		};
	} forEach svb_townTasks;

	sleep 5;
};

// Cleanup при завершении игры
{
	[(_x select 1), (_x select 2)] call svb_fnc_completeTownTask;
} forEach svb_townTasks;
svb_townTasks = [];