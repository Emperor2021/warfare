private ["_vehicle","_side_id","_net_global","_upd","_rec","_log"];

// Защита параметров (§  25)
if (typeName _this != "ARRAY") exitWith {false};
if (count _this < 2) exitWith {false};
_vehicle = _this select 0;
_side_id = _this select 1;
if (typeName _vehicle != "OBJECT") exitWith {false};
if (isNull _vehicle) exitWith {false};
if (typeName _side_id != "SCALAR") exitWith {false};

_log = missionNamespace getVariable ["NET_LOG", false];

// При разрушении техники экипаж кратковременно становится civilian
// (см. TODO в Common_OnUnitKilled.sqf), и GetSideID возвращает -1.
// Такой запуск отбрасываем: записанный -1 больше не перезаписывается
// (isNil = false) и насовсем убивает сеть узла — AN_Reconfigure и
// AN_CheckConn выходят по _side_id < 0. Для городов -1 легитимен,
// поэтому гейт только для игрока. Скан повторит запуск с валидной стороной.
if (_side_id < 0 && {isPlayer _vehicle}) exitWith {false};

if (_log) then {diag_log format [":: NET :: Trying to launch for %1 with sideid %2", _vehicle, _side_id]};

// Guard по живости ОБОИХ циклов: мёртвый или отсутствующий цикл
// не должен блокировать перезапуск
_upd = _vehicle getVariable ["AN_updHandle", scriptNull];
_rec = _vehicle getVariable ["AN_recHandle", scriptNull];
if (!isNull _upd && {!scriptDone _upd} && !isNull _rec && {!scriptDone _rec}) exitWith {false};

// Принадлежность игрока восстанавливается ПРИНУДИТЕЛЬНО на новом объекте.
// Метка AN_memberInit живёт на объекте: переживает перезапуск циклов,
// но НЕ переживает респавн (объект новый). Итог: кнопка выключения сети
// работает в течение жизни, а после смерти сеть возвращается сама.
if (isPlayer _vehicle) then {
	if (isNil {_vehicle getVariable "AN_memberInit"}) then {
		_vehicle setVariable ["CTI_Net", _side_id, true];
		_vehicle setVariable ["AN_memberInit", true, false];
		if (_log) then {diag_log format [":: NET :: membership restored for %1 -> %2", _vehicle, _side_id]};
	} else {
		if (isNil {_vehicle getVariable "CTI_Net"}) then {_vehicle setVariable ["CTI_Net", _side_id, true];};
	};
} else {
	if (isNil {_vehicle getVariable "CTI_Net"}) then {_vehicle setVariable ["CTI_Net", _side_id, true];};
};

// AN_Conn networked для игроков и техники, локально для ботов
_net_global = if (_vehicle isKindOf "Man" && !isPlayer _vehicle) then {false} else {true};
if (isNil {_vehicle getVariable "AN_Conn"}) then {_vehicle setVariable ["AN_Conn", objNull, _net_global];};
if (isNil {_vehicle getVariable "AN_iNet"}) then {_vehicle setVariable ["AN_iNet", -1, true];};
if (isNil {_vehicle getVariable "AN_Parrents"}) then {_vehicle setVariable ["AN_Parrents", [], false];};

// spawn от nil обрывает скрипт молча и второй handle не записывается
if (isNil "AN_Update_Connection" || {isNil "AN_Reconfigure_loop"}) exitWith {
	diag_log format [":: NET :: ERROR functions missing for %1: upd=%2 rec=%3",
		_vehicle, isNil "AN_Update_Connection", isNil "AN_Reconfigure_loop"];
	false
};

if (_log) then {diag_log format [":: NET :: Launching for %1 with sideid %2", _vehicle, _side_id]};

// Handle храним локально (false): script handle валиден только на своей машине
if (isNull _upd || {scriptDone _upd}) then {
	_vehicle setVariable ["AN_updHandle", _vehicle spawn AN_Update_Connection, false];
};
if (isNull _rec || {scriptDone _rec}) then {
	_vehicle setVariable ["AN_recHandle", _vehicle spawn AN_Reconfigure_loop, false];
};

true