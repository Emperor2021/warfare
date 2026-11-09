while {! CTI_GameOver && alive  _this } do {
	// На сервере все объекты local
	if (!CTI_isServer && ! local _this && _this isKindOf "Man") exitWith {false};
	_this call AN_Reconfigure;
	sleep 10+random(15);
};