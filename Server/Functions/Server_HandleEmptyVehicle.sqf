private [
	"_delay", "_timeout", "_vehicle", "_detached", "_existing", "_handle",
	"_scanPeriod", "_handlerMode", "_emptyCount", "_isDefense",
	"_jipOwner", "_jipLocked"
];

_vehicle = _this select 0;
_delay = if (count _this > 1) then {_this select 1} else {missionNamespace getVariable "CTI_VEHICLES_EMPTY_TIMEOUT"};
_detached = if (count _this > 2) then {_this select 2} else {false};

if (isNull _vehicle) exitWith {};

// === Сервисная техника и контейнеры не отслеживаются вообще ===
if (!isNil {_vehicle getVariable "cti_spec"} || !isNil {_vehicle getVariable "svb_service_nocleanup"}) exitWith {
	diag_log format ["HANDLE :: service object protected: %1", typeOf _vehicle];
};

if (isNil "_delay" || {typeName _delay != "SCALAR"}) then {_delay = 600};

// Отделяем цикл в самостоятельный поток, чтобы вызывающий код не блокировался
if (!_detached) exitWith {
	_existing = _vehicle getVariable "cti_empty_monitor";
	if (isNil "_existing" || {typeName _existing != "SCRIPT"} || {scriptDone _existing}) then {
		_handle = [_vehicle, _delay, true] spawn CTI_SE_FNC_HandleEmptyVehicle;
		_vehicle setVariable ["cti_empty_monitor", _handle];
	};
};

diag_log format ["HANDLE :: Starting empty vehicle loop for %1 (delay %2)", _vehicle, _delay];

_timeout = time;

_scanPeriod = if (isNil "CTI_VEHICLES_EMPTY_SCAN_PERIOD") then {30} else {CTI_VEHICLES_EMPTY_SCAN_PERIOD};
if (isNil "_scanPeriod" || {typeName _scanPeriod != "SCALAR"}) then {_scanPeriod = 30};

_handlerMode = if (isNil "CTI_VEHICLES_HANDLER_EMPTY") then {0} else {CTI_VEHICLES_HANDLER_EMPTY};
if (isNil "_handlerMode" || {typeName _handlerMode != "SCALAR"}) then {_handlerMode = 0};

// === ВАРИАНТ А: оборона базы живёт по своему таймауту ===
// Маркер cti_save ставится в Server_BuildDefense.sqf на все построенные дефенсы
_isDefense = !isNil {_vehicle getVariable "cti_save"};

if (_vehicle iskindof "UGV_01_base_F") then {_delay = _delay / 6};

while {alive _vehicle && time - _timeout <= _delay} do {
	switch (_handlerMode) do { //--- Before
		case 0: {
			if (
				{alive _x} count crew _vehicle > 0
				&& !(
					(
						_vehicle iskindof "UGV_01_base_F"
						|| _vehicle iskindof "UAV_02_base_F"
						|| _vehicle iskindof "UAV_03_base_F"
						|| _vehicle iskindof "Static_Designator_01_base_F"
						|| typeOf _vehicle == "Land_Device_slingloadable_F"
					)
					&& !(isUAVConnected _vehicle)
				)
			) then {_timeout = time};
		};
		case 1: {
			if (
				(
					{alive _x} count crew _vehicle > 0
					|| canMove _vehicle
					|| canFire _vehicle
				)
				&& !(
					(
						_vehicle iskindof "UGV_01_base_F"
						|| _vehicle iskindof "UAV_02_base_F"
						|| _vehicle iskindof "UAV_03_base_F"
						|| _vehicle iskindof "Static_Designator_01_base_F"
						|| typeOf _vehicle == "Land_Device_slingloadable_F"
					)
					&& !(isUAVConnected _vehicle)
				)
			) then {_timeout = time};
		};
	};

	sleep _scanPeriod;

	// === ЛИМИТ 200: только обычная техника. Оборону НЕ трогаем ===
	if (!_isDefense) then {
		if (count vehicles <= 200) then {
			_timeout = time;
		} else {
			_emptyCount = {
				private _veh = _x;
				private _include = false;

				if (!isNull _veh && {alive _veh}) then {
					private _hasAliveCrew = ({alive _x} count crew _veh) > 0;

					// Техника отключённого игрока в лимит не входит
					private _own = _veh getVariable ["svb_jip_owner", grpNull];
					private _jip = !isNull _own && {_own getVariable ["cti_player_disconnected", false]};

					_include = !_hasAliveCrew && !_jip
						&& isNil {_veh getVariable "cti_gc_noremove"}
						&& isNil {_veh getVariable "cti_spec"}
						&& isNil {_veh getVariable "svb_service_nocleanup"}
						&& isNil {_veh getVariable "cti_save"};
				};

				_include
			} count vehicles;

			if (_emptyCount <= 200) then {_timeout = time};
		};
	};

	switch (_handlerMode) do { //--- After
		case 0: {
			if (
				{alive _x} count crew _vehicle > 0
				&& !(
					(
						_vehicle iskindof "UGV_01_base_F"
						|| _vehicle iskindof "UAV_02_base_F"
						|| _vehicle iskindof "UAV_03_base_F"
						|| _vehicle iskindof "Static_Designator_01_base_F"
						|| typeOf _vehicle == "Land_Device_slingloadable_F"
					)
					&& !(isUAVConnected _vehicle)
				)
			) then {_timeout = time};
		};
		case 1: {
			if (
				(
					{alive _x} count crew _vehicle > 0
					|| canMove _vehicle
					|| canFire _vehicle
				)
				&& !(
					(
						_vehicle iskindof "UGV_01_base_F"
						|| _vehicle iskindof "UAV_02_base_F"
						|| _vehicle iskindof "UAV_03_base_F"
						|| _vehicle iskindof "Static_Designator_01_base_F"
						|| typeOf _vehicle == "Land_Device_slingloadable_F"
					)
					&& !(isUAVConnected _vehicle)
				)
			) then {_timeout = time};
		};
	};
};

// === Финальная проверка: сервис и техника отключённого игрока не удаляются ===
_jipOwner = _vehicle getVariable ["svb_jip_owner", grpNull];
_jipLocked = !isNull _jipOwner && {_jipOwner getVariable ["cti_player_disconnected", false]};

if (
	alive _vehicle
	&& !_jipLocked
	&& isNil {_vehicle getVariable "cti_spec"}
	&& isNil {_vehicle getVariable "svb_service_nocleanup"}
) then {
	_vehicle setPosASL [0,0,0];
	sleep 2;
	deleteVehicle _vehicle;
} else {
	if (alive _vehicle) then {
		diag_log format ["HANDLE :: deletion blocked (jip/service): %1", typeOf _vehicle];
		// Перезапускаем отслеживание, чтобы после возврата игрока техника снова обслуживалась
		_vehicle setVariable [
			"cti_empty_monitor",
			([_vehicle, _delay, true] spawn CTI_SE_FNC_HandleEmptyVehicle)
		];
	};
};