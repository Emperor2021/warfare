/*
  # HEADER #
	Script: 		Client\Functions\Client_OnPlayerKilled.sqf
	Alias:			CTI_CL_FNC_OnPlayerKilled
	Description:	Triggered from the "Killed" EH whenever the player dies
					Note this function shall be called by an Event Handler (EH) but can be called manually
	Author: 		Benny
	Creation Date:	19-09-2013
	Revision Date:	19-09-2013

  # PARAMETERS #
    0	[Object]: The killed unit
    1	[Object]: The killer

  # RETURNED VALUE #
	None

  # SYNTAX #
	[KILLED, KILLER] spawn CTI_CL_FNC_OnPlayerKilled

  # DEPENDENCIES #
	Client Function: CTI_CL_FNC_AddMissionActions
	Common Function: CTI_CO_FNC_OnUnitKilled

  # EXAMPLE #
	player addEventHandler ["killed", {_this spawn CTI_CL_FNC_OnPlayerKilled}];
	  -> This function be triggered everytime the player dies
*/

private ["_killed", "_killer", "_instigator"];

_killed = _this select 0;
_killer = _this select 1;
// instigator пришёл из Killed EH (водитель/стрелок), может отсутствовать
_instigator = if (count _this > 2) then { _this select 2 } else { objNull };

_killed connectTerminalToUAV objNull;

CTI_DeathPosition = getPos _killed;
CTI_P_LastDeathTime=time;

//--- Close dialogs if needed (check 2 times).
if (dialog) then {closeDialog 0};
if (dialog) then {closeDialog 0};

CTI_P_Respawning = true;

//--- Clear the previous
for '_i' from 0 to 10 do { player removeAction _i };

titleCut["","BLACK OUT",1];

if !(CTI_P_Jailed && _killed ==_killer ) then {[_killed, _killer, CTI_P_SideID] spawn CTI_CO_FNC_OnUnitKilled};

waitUntil {alive player};
// hideobject _killed перенесён в svb_fnc_deathCam — труп должен быть виден все 5 секунд камеры

// === ОЧИСТКА СЕТЕВЫХ ПЕРЕМЕННЫХ ПОСЛЕ РЕСПАВНА ===
// Сбрасываем сетевое состояние в валидные значения.
// ВАЖНО: нельзя ставить nil, иначе AN_Reconfigure выходит по isNil {AN_iNet}
// и сеть не восстанавливается. Ставим -1 / objNull / [] — это "нет сети",
// но валидное состояние, которое AN_Reconfigure обработает и найдёт ретранслятор.
player setVariable ["AN_iNet", -1, true];
player setVariable ["AN_Conn", objNull, true];
player setVariable ["AN_Parrents", [], true];
player setVariable ["CTI_Net", (side player) call CTI_CO_FNC_GetSideID, true];
player setVariable ["AN_updHandle", nil, false];  // локально, handle не networked
player setVariable ["AN_recHandle", nil, false];  // локально, handle не networked

CTI_DeathTimer = time + (missionNamespace getVariable "CTI_RESPAWN_TIMER");

call CTI_CL_FNC_AddMissionActions;

//--- Make sure that player is always the leader (of his group).
if (! (isPlayer (leader(group player))) && !(CTI_P_SideJoined == resistance)) then {(group player) selectLeader player};

if !( missionNamespace getVariable ["TUTO_COMPLETE",false]) then {
	hideObject _killed; // в туториале камеры нет — прячем труп сразу, как раньше
	titleCut["","BLACK IN",1];
	12452 cutText [localize "STR_Begin_Tutorial", "BLACK IN", 5];
	0 call TUTORIAL_RUN;
} else {
	createDialog "CTI_RscRespawnMenu";
	//--- Камера смерти: 5 сек (труп -> убийца), поверх неё меню респавна
	[_killed, _killer, _instigator] spawn svb_fnc_deathCam;
};