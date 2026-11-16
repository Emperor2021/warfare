private ["_vehicle","_ownerOK"];
_vehicle = _this;
if (typeName _vehicle != "OBJECT") exitWith {false};
if (isNull _vehicle) exitWith {false};

// То же разделение authority, что в AN_Update_Connection
_ownerOK = if (CTI_isServer) then {
	!(_vehicle isKindOf "Man" && {!isPlayer _vehicle} && {!local _vehicle})
} else {
	(_vehicle isKindOf "Man") && {!isPlayer _vehicle} && {local _vehicle}
};
if (!_ownerOK) exitWith {false};

while {!CTI_GameOver && alive _vehicle} do {
	_vehicle call AN_Reconfigure;
	sleep 10 + random(15);
};