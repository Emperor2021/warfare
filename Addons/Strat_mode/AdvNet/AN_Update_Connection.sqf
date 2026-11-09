private ["_vehicle"];
_vehicle=_this;
while {! CTI_GameOver && alive  _vehicle} do {
	// На сервере все объекты local, проверка не нужна
	if (CTI_isServer) then {
		// Сервер обновляет AN_iNet для всех
	} else {
		if (! local _vehicle && _vehicle isKindOf "Man") exitWith {false};
	};
	if ((_vehicle) call AN_Check_Connection) then {
		if !((_vehicle getVariable "AN_iNet") == (_vehicle getVariable "AN_Conn") getVariable "AN_iNet") then {
			_vehicle setVariable ["AN_iNet",(_vehicle getVariable "AN_Conn") getVariable "AN_iNet" ,true];
		};
	} else {
		if !((_vehicle getVariable "AN_iNet") == -1) then {
			_vehicle setVariable ["AN_iNet",-1,true];
		};
	};
	sleep 3;
};
_vehicle setVariable ["AN_iNet",nil,true];