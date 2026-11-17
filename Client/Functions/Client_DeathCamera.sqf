/*
	svb_fnc_deathCam — камера смерти (только клиент).
	Камера живёт до респауна, но не меньше 10 секунд:
	сначала труп (статика), затем убийца — камера следует за ним
	и СМОТРИТ НА НЕГО (camSetTarget), плавно (camSetRelPos+camCommit).
	БЕЗ attachTo (он наследует курс юнита и ломает взгляд на цель).
	Суицид/краш/objNull — только труп.
	Труп виден всё время работы камеры (hideObject в самом конце).
	Вызов: [_killed, _killer, _instigator] spawn svb_fnc_deathCam;
	Использует существующую CTI_DeathCamera — её cleanup уже встроен
	в CTI_UI_Respawn_OnRespawnReady (уничтожает камеру при телепорте).
*/

if (!hasInterface) exitWith {};

params [
	["_killed", objNull, [objNull]],
	["_killer", objNull, [objNull]],
	["_instigator", objNull, [objNull]]
];

if (isNull _killed) exitWith {};

// Гасим камеру с прошлой смерти, если ещё крутится (защита от дублей)
if (!isNil "CTI_DeathCamera" && {!isNull CTI_DeathCamera}) then {
	CTI_DeathCamera cameraEffect ["TERMINATE", "BACK"];
	camDestroy CTI_DeathCamera;
	CTI_DeathCamera = nil;
};

private _minDuration = 10;   // минимум секунд камеры и видимости трупа
private _corpsePhase = 5;    // сколько смотрим на труп до перехода на убийцу
private _followDist = 10;    // насколько камера сзади убийцы, м
private _followHeight = 15;  // высота камеры над убийцей, м
private _tick = 0.1;         // шаг цикла следования (10 Гц, camCommit интерполирует)

// Кто виноват: instigator важнее killer (водитель/стрелок техники)
private _culprit = if (!isNull _instigator) then { _instigator } else { _killer };
// Сам себя / objNull / не человек (краш верта/машины) — показываем только труп
private _showKiller = (!isNull _culprit) && {_culprit isNotEqualTo _killed} && {_culprit isKindOf "CAManBase"};

diag_log format ["[SVB] DeathCam: killed=%1 killer=%2 instigator=%3 showKiller=%4", _killed, _killer, _instigator, _showKiller];

// Фокус: если труп/убийца в технике — целимся в технику, иначе камера утонет в обломках
private _fnc_focus = {
	params ["_obj"];
	if (!isNull objectParent _obj) then { objectParent _obj } else { _obj };
};

private _corpseFocus = [_killed] call _fnc_focus;

// Локальная ссылка на камеру (глобал мог уже уничтожить OnRespawnReady)
private _cam = "camera" camCreate (_corpseFocus modelToWorldVisual [0, -3, 1.6]);
CTI_DeathCamera = _cam;
// Фаза трупа: статично смотрим на труп явным вектором
private _toCorpse = (getPosASL _corpseFocus) vectorDiff (getPosASL _cam);
_cam setVectorDirAndUp [_toCorpse, [0,0,1]];
_cam camSetFov 0.7;
_cam cameraEffect ["INTERNAL", "BACK"];
showCinemaBorder false;

// Проявляем картинку поверх камеры (BLACK OUT был в OnPlayerKilled)
titleCut ["", "BLACK IN", 1];

private _start = time;
private _switched = false;

// Держим камеру: минимум _minDuration И до истечения таймера респавна.
// CTI_DeathTimer читается вживую — сменил локацию в меню, камера сама удлинилась.
// OnRespawnReady уничтожит CTI_DeathCamera при респауне — выходим по isNull.
while {(time - _start < _minDuration) || {time < (missionNamespace getVariable ["CTI_DeathTimer", time])}} do {
	if (isNull _cam) exitWith {};

	if (!_switched && {time - _start >= _corpsePhase}) then { _switched = true; };

	// После перехода: следуем за убийцей и СМОТРИМ НА НЕГО, плавно
	if (_switched && _showKiller && {!isNull _culprit}) then {
		private _killerFocus = [_culprit] call _fnc_focus;
		_cam camSetTarget _killerFocus;                      // взгляд НА цель (постоянный трекинг)
		_cam camSetRelPos [0, -_followDist, _followHeight];  // позиция сзади-сверху относительно цели
		_cam camCommit _tick;                               // интерполяция = плавно, без снапов
	};

	uiSleep _tick;
};

// Cleanup: камеру мог уже уничтожить CTI_UI_Respawn_OnRespawnReady (авто-респаун)
if (!isNull _cam) then {
	_cam cameraEffect ["TERMINATE", "BACK"];
	camDestroy _cam;
};
// Не затираем глобал, если там уже камера от НОВОЙ смерти
if (!isNil "CTI_DeathCamera" && {CTI_DeathCamera isEqualTo _cam}) then {
	CTI_DeathCamera = nil;
};

// Прячем труп только теперь — он лежал всё время работы камеры (>=10 сек)
if (!isNull _killed) then { hideObject _killed };