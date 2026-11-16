#define	AN_Range_V	1000
#define	AN_Range_I	100

/*
	Переменные узла сети:
	CTI_Net    — принадлежность стороне (0/1), -1 = осознанно вне сети, nil = не инициализирован
	AN_iNet    — вычисленная связность (-1 или сторона)
	AN_Conn    — родитель в графе
	AN_Parrents— список детей узла
*/

private ["_vehicle","_global","_side_id","_side","_forced","_candidates","_max_distance","_up_r","_up","_structures","_ccs","_town","_hq","_final","_parent_list","_already_parent","_my_conn","_log","_dbg","_cand"];

_vehicle = _this;
if (typeName _vehicle != "OBJECT") exitWith {false};
if (isNull _vehicle) exitWith {false};

if (CTI_isServer) then {waitUntil {CTI_Init_Server};};

_log = missionNamespace getVariable ["NET_LOG", false];

// networked для всех узлов
_global = true;

_side_id = _vehicle getVariable ["CTI_Net", -11];
if (_side_id < 0) exitWith {false};

_side = (_side_id) call CTI_CO_FNC_GetSideFromID;

// Принудительный узел — корень сам себе
_forced = _vehicle getVariable ["AN_Forced", false];
if (_forced) exitWith {
	if !((_vehicle getVariable ["AN_Conn", objNull]) isEqualTo _vehicle) then {_vehicle setVariable ["AN_Conn", _vehicle, _global]};
	_vehicle setVariable ["AN_Parrents", [], false];
	false
};

// HQ — корень сети: ссылается на сам себя, AN_iNet всегда равен стороне
if (_vehicle isEqualTo ((_side) call CTI_CO_FNC_GetSideHQ)) exitWith {
	if !((_vehicle getVariable ["AN_Conn", objNull]) isEqualTo _vehicle) then {_vehicle setVariable ["AN_Conn", _vehicle, true]};
	if !((_vehicle getVariable ["AN_iNet", -1]) isEqualTo _side_id) then {_vehicle setVariable ["AN_iNet", _side_id, true]};
	if !(_vehicle in (_vehicle getVariable ["AN_Parrents", []])) then {_vehicle setVariable ["AN_Parrents", [_vehicle], false]};
	false
};

// ЦУ — второй корень сети, по тому же паттерну что HQ.
// Без этой ветки ЦУ обрабатывался как обычный узел: искал родителя, не находил
// (HQ мёртв, техника offline) и сбрасывал себе AN_iNet = -1 в else-ветке.
// После этого техника не могла к нему подключиться, т.к. фильтр кандидатов
// требует AN_iNet == sideID -> взаимная блокировка, сеть стороны мертва целиком.
// Два ЦУ = два независимых корня, резервирование.
if ((_vehicle getVariable ["cti_structure_type", ""]) isEqualTo CTI_CONTROLCENTER) exitWith {
	if !((_vehicle getVariable ["AN_Conn", objNull]) isEqualTo _vehicle) then {_vehicle setVariable ["AN_Conn", _vehicle, true]};
	if !((_vehicle getVariable ["AN_iNet", -1]) isEqualTo _side_id) then {_vehicle setVariable ["AN_iNet", _side_id, true]};
	if !(_vehicle in (_vehicle getVariable ["AN_Parrents", []])) then {_vehicle setVariable ["AN_Parrents", [_vehicle], false]};
	false
};

// Пехота внутри техники — родитель это её транспорт
// getVariable с default: nil в сравнении даёт type error и обрывает функцию
if (_vehicle isKindOf "Man" && {!(vehicle _vehicle isEqualTo _vehicle)} && {(vehicle _vehicle) getVariable ["AN_iNet", -1] isEqualTo _side_id}) exitWith {
	if !((_vehicle getVariable ["AN_Conn", objNull]) isEqualTo (vehicle _vehicle)) then {_vehicle setVariable ["AN_Conn", vehicle _vehicle, true]};
	false
};

// Радиус поиска кандидатов
_candidates = [];
_max_distance = 5000;
_up_r = 0;
if (_side in [east, west]) then {
	_up = (_side) call CTI_CO_FNC_GetSideUpgrades;
	// Проверка длины: select за границей массива обрывает функцию
	if (typeName _up == "ARRAY" && {count _up > CTI_UPGRADE_NETR}) then {
		_up_r = _up select CTI_UPGRADE_NETR;
	};
};
if (_vehicle isKindOf "Man") then {_max_distance = AN_Range_I + 200 * _up_r} else {_max_distance = AN_Range_V + 1000 * _up_r};
if (_vehicle isKindOf "FlagPole_F") then {_max_distance = 5000};

// HQ берём один раз — раньше вызывался для каждого объекта в vehicles (§12)
_hq = (_side) call CTI_CO_FNC_GetSideHQ;

// Кандидаты: ЦУ (исключая сам объект и разрушенные)
if (_side in [east, west]) then {
	_structures = (_side) call CTI_CO_FNC_GetSideStructures;
	_ccs = [CTI_CONTROLCENTER, _structures] call CTI_CO_FNC_GetSideStructuresByType;
	{
		if ((_vehicle distance _x <= _max_distance) && {!(_x isEqualTo _vehicle)} && {alive _x} && {(_x getVariable ["AN_iNet", -1]) isEqualTo _side_id}) then {_candidates pushBack _x};
		true
	} count _ccs;
};

// Кандидаты: города
if (count _candidates == 0 || {_vehicle isKindOf "FlagPole_F" && {_side in [east, west]}}) then {
	{
		_town = _x;
		if (!(isNull _town) && {!(_town isEqualTo _vehicle)} && {_vehicle distance _town <= _max_distance} && {(_town getVariable ["AN_iNet", -1]) isEqualTo _side_id} && {!((_town getVariable ["AN_Conn", objNull]) isEqualTo _vehicle)} && {!(_vehicle in (_town getVariable ["AN_Parrents", []]))}) then {_candidates pushBack _town};
		true
	} count ((_side_id) call CTI_CO_FNC_GetSideTowns);
};

// Кандидат: HQ
if (count _candidates == 0 && {_side in [east, west]}) then {
	if (!isNull _hq && {alive _hq} && {_vehicle distance _hq <= _max_distance}) then {_candidates pushBack _hq};
};

// Кандидаты: техника-ретранслятор
// Ретранслятор обязан быть в радиусе сети этого узла, в сети стороны,
// не ссылаться на нас и не содержать нас в списке детей (защита от петель).
// in вместо вложенного {_x == _vehicle} count: вложенный code-block внутри
// многострочного условия ломал парсер SQF ("Потеряна }")
if (!(_vehicle isKindOf "FlagPole_F")) then {
	{
		_cand = _x;
		if ((_vehicle distance _cand <= _max_distance) && {!(_cand isEqualTo _vehicle)} && {!(_cand isEqualTo _hq)} && {alive _cand} && {(_cand getVariable ["AN_iNet", -1]) isEqualTo _side_id} && {!((_cand getVariable ["AN_Conn", objNull]) isEqualTo _vehicle)} && {!(_vehicle in (_cand getVariable ["AN_Parrents", []]))}) then {_candidates pushBack _cand};
		true
	} count vehicles;
};

// Ближайший кандидат становится родителем
_final = [_vehicle, _candidates] call CTI_CO_FNC_GetClosestEntity;

if !(isNull _final) then {
	if !(_final isEqualTo _vehicle) then {
		if !(_final isEqualTo (_vehicle getVariable ["AN_Conn", objNull])) then {
			_vehicle setVariable ["AN_Conn", _final, _global];
		};
		_parent_list = (_final getVariable ["AN_Parrents", []]);
		_already_parent = (_vehicle in _parent_list);
		if !(_already_parent) then {
			_vehicle setVariable ["AN_Parrents", _parent_list + [_vehicle], false];
		};
	};
	if (_log) then {
		_my_conn = _vehicle getVariable ["AN_Conn", objNull];
		_dbg = [];
		if !(isNull _my_conn) then {_dbg = _my_conn getVariable ["AN_Parrents", []]};
		diag_log format [":: NET :: Sucess in reconf %1 to %2 through %3", _vehicle, _final, _dbg];
	};
} else {
	_vehicle setVariable ["AN_Conn", objNull, _global];
	_vehicle setVariable ["AN_iNet", -1, true];
	_vehicle setVariable ["AN_Parrents", [], false];
	if (_log) then {diag_log format [":: NET :: Failure in reconf %1", _vehicle]};
};