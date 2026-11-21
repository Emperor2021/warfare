private ["_bounty", "_created_units", "_created_vehicles", "_crew", "_crews", "_group", "_locked", "_net", "_position", "_side", "_sideID", "_unit", "_units", "_vehicle", "_vehicle_crew"];

_units = _this select 0;
_position = _this select 1;
_side = _this select 2;
_group = _this select 3;
_locked = if (count _this > 4) then {_this select 4} else {true};
_net = if (count _this > 5) then {_this select 5} else {false};
_bounty = if (count _this > 6) then {_this select 6} else {false};

if (_side == resistance) then {_net=false};

_sideID = (_side) call CTI_CO_FNC_GetSideID;
//if (isNull _group) then {_group = createGroup _side};


_created_units = [];
_created_vehicles = [];
_crews = [];
_v_groups=[];

// Базовая точка отряда. РАНЬШЕ _position перезаписывалась внутри цикла на объект дороги,
// из-за чего пехота и каждая следующая машина спавнились уже от случайной дороги (дрейф позиции).
private _base_pos = if (typeName _position == "OBJECT") then {getPos _position} else {+_position};
if (count _base_pos < 3) then {_base_pos set [2, 0]};

{
	private _class = _x;

	if (_class isKindOf "Man") then {
		// === ПЕХОТА ===
		// CTI_CO_FNC_GetRandomPosition проверяет ТОЛЬКО воду (см. шапку функции),
		// а CTI_CO_FNC_CreateUnit ставит юнита с placement 0 точно в точку.
		// В плотной застройке точка могла оказаться внутри здания -> бот в текстурах.
		// findEmptyPosition учитывает здания, технику и габариты класса.
		private _u_pos = [];
		for "_try" from 1 to 12 do {
			private _rnd = [_base_pos, 2, 15] call CTI_CO_FNC_GetRandomPosition;
			private _p = _rnd findEmptyPosition [0, 8, _class];
			if !(_p isEqualTo []) exitWith {_u_pos = _p};
		};

		if (_u_pos isEqualTo []) then {
			// Свободного места нет — юнита НЕ создаём, чтобы он не застрял в текстурах
			diag_log format ["[SVB] CreateTeam: нет свободного места для пехоты %1 (сторона %2), спавн пропущен", _class, _side];
		} else {
			_unit = [_class, _group, _u_pos, _sideID] call CTI_CO_FNC_CreateUnit;
			_created_units pushBack _unit;
		};
	} else {
		_crew = switch (true) do {
			case (_class isKindOf "Tank"): { missionNamespace getVariable format["%1_SOLDIER_CREW", _side] };
			case (_class isKindOf "Air"): { missionNamespace getVariable format["%1_SOLDIER_PILOT", _side] };
			default { missionNamespace getVariable format["%1_SOLDIER", _side] };
		};
		if (typeName _crew == "ARRAY") then {_crew = _crew select 0};

		// === ТЕХНИКА ===
		// Раньше: случайный сегмент из nearRoads 100 БЕЗ проверки занятости и габаритов,
		// поэтому при большой обороне машины вставали друг в друга и в фасады.
		private _v_pos = [];
		private _v_dir = random 360;

		for "_radius" from 100 to 300 step 100 do {
			if !(_v_pos isEqualTo []) exitWith {};

			private _roads = _base_pos nearRoads _radius;
			if (count _roads == 0) then {continue};

			// Перемешиваем существующей функцией миссии; лимит перебора — защита от нагрузки
			_roads = _roads call CTI_CO_FNC_ArrayShuffle;
			if (count _roads > 60) then {_roads resize 60};

			{
				private _road = _x;
				if (isNull _road) then {continue};
				private _rp = getPos _road;
				if !(isOnRoad _rp) then {continue};
				if (surfaceIsWater _rp) then {continue};

				// Габариты класса + здания; малый радиус, чтобы остаться на полотне
				private _p = _rp findEmptyPosition [0, 3, _class];
				if (_p isEqualTo []) then {continue};
				if !(isOnRoad _p) then {continue};

				// Не ставим машину прямо на пехоту
				if ({alive _x} count (_p nearEntities ["Man", 3]) > 0) then {continue};

				// Главное: не ставим машину в уже стоящую технику/статику/ящики
				private _blockers = (_p nearEntities ["All", 12]) select {
					alive _x && {
						_x isKindOf "LandVehicle" || {_x isKindOf "Air"} || {_x isKindOf "Ship"} ||
						{_x isKindOf "StaticWeapon"} || {_x isKindOf "AmmoBox"}
					}
				};
				if (count _blockers > 0) then {continue};

				_v_pos = _p;
				// Направление вдоль дороги — иначе танк встанет поперёк улицы и заденет фасады
				private _connected = roadsConnectedTo _road;
				if (count _connected > 0) then {_v_dir = _road getDir (_connected select 0)};
				if (true) exitWith {};
			} forEach _roads;
		};

		// === FALLBACK: дорог нет (пустыня, поля) ===
		// БЫЛО: одна попытка findEmptyPosition [5,150] от фиксированной _base_pos.
		// Для всех машин группы возвращалась одна и та же ближайшая точка, а setPosATL
		// ниже телепортировал их туда, убивая placement-разброс -> техника сама в себе.
		// СТАЛО: разносим seed-точки вокруг базы и проверяем занятость тем же фильтром,
		// что и в дорожной ветке выше. nearEntities видит машины, созданные в этом же
		// цикле, в отличие от findEmptyPosition — это и закрывает стакание.
		if (_v_pos isEqualTo []) then {
			for "_try" from 1 to 40 do {
				if !(_v_pos isEqualTo []) exitWith {};

				private _dir = random 360;
				private _dist = 8 + random 90;
				private _seed = [
					(_base_pos select 0) + (sin _dir) * _dist,
					(_base_pos select 1) + (cos _dir) * _dist,
					0
				];

				if (surfaceIsWater _seed) then {continue};

				private _p = _seed findEmptyPosition [0, 60, _class];
				if (_p isEqualTo []) then {continue};
				if (surfaceIsWater _p) then {continue};

				// Не ставим машину прямо на пехоту
				if ({alive _x} count (_p nearEntities ["Man", 4]) > 0) then {continue};

				// Не ставим машину в уже стоящую технику/статику/ящики
				private _blockers = (_p nearEntities ["All", 12]) select {
					alive _x && {
						_x isKindOf "LandVehicle" || {_x isKindOf "Air"} || {_x isKindOf "Ship"} ||
						{_x isKindOf "StaticWeapon"} || {_x isKindOf "AmmoBox"}
					}
				};
				if (count _blockers > 0) then {continue};

				_v_pos = _p;
			};
		};

		if (_v_pos isEqualTo []) then {
			diag_log format ["[SVB] CreateTeam: нет свободного места для техники %1 (сторона %2), спавн пропущен", _class, _side];
		} else {
			if (count _v_pos < 3) then {_v_pos set [2, 0]};
			_vehicle = [_class, _v_pos, _v_dir, _sideID, _locked, _net, _bounty] call CTI_CO_FNC_CreateVehicle;
			_created_vehicles pushBack _vehicle;

			// CTI_CO_FNC_CreateVehicle создаёт с placement radius 7 и FORM (setPos z=1):
			// движок сдвигает машину до 7м и роняет с метра. Без фиксации она уедет с дороги в застройку.
			if (!isNull _vehicle) then {
				_vehicle setPosATL _v_pos;
				_vehicle setDir _v_dir;
				_vehicle setVelocity [0,0,0];
			};

			_n_group= createGroup _side;
			waitUntil {!isNil "_n_group"};
			waitUntil {!isNull _n_group};
			_v_groups set [count _v_groups,_n_group];
			_vehicle_crew = [_vehicle, _crew, _n_group, _sideID] call CTI_CO_FNC_ManVehicle;
			_crews = _crews + _vehicle_crew;
		};
	};
} forEach _units;

//{_group addVehicle _x} forEach _created_vehicles;

[_created_units, _created_vehicles, _crews, _group,_v_groups]