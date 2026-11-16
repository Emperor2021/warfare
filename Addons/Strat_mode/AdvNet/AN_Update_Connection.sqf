private ["_vehicle","_ownerOK","_conn","_connNet","_myNet"];
_vehicle = _this;
if (typeName _vehicle != "OBJECT") exitWith {false};
if (isNull _vehicle) exitWith {false};

// Разделение authority:
// сервер считает ВСЁ (техника, города, HQ, игрок), кроме чужих клиентских ботов;
// клиент считает только своих локальных ботов (сервер их не видит).
// Техника всегда на сервере — запуск AN_Launch для неё идёт через Server_Run_Net.
_ownerOK = if (CTI_isServer) then {
	!(_vehicle isKindOf "Man" && {!isPlayer _vehicle} && {!local _vehicle})
} else {
	(_vehicle isKindOf "Man") && {!isPlayer _vehicle} && {local _vehicle}
};
// exitWith строго на верхнем уровне: внутри then{} он вышел бы только из блока,
// и хвост setVariable ["AN_iNet",nil,true] удалил бы переменную локально
if (!_ownerOK) exitWith {false};

while {!CTI_GameOver && alive _vehicle} do {
	if ((_vehicle) call AN_Check_Connection) then {
		_conn = _vehicle getVariable ["AN_Conn", objNull];
		// default обязателен: у мёртвого узла AN_iNet = nil, сравнение nil убивает цикл
		_connNet = if (isNull _conn) then {-1} else {_conn getVariable ["AN_iNet", -1]};
		_myNet = _vehicle getVariable ["AN_iNet", -1];
		if (_myNet != _connNet) then {
			_vehicle setVariable ["AN_iNet", _connNet, true];
		};
	} else {
		if ((_vehicle getVariable ["AN_iNet", -1]) != -1) then {
			_vehicle setVariable ["AN_iNet", -1, true];
		};
	};
	sleep 3;
};

// Узел умер — освобождаем признак инициализации для AN_Launch
_vehicle setVariable ["AN_iNet", nil, true];