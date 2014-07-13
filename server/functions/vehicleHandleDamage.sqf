//	@file Name: vehicleHandleDamage.sqf
//	@file Author: AgentRev

#define COLLISION_DMG_SCALE 0.2
#define WHEEL_COLLISION_DMG_SCALE 0.05
#define IFV_MISSILE_DMG_SCALE 1.5
#define TANK_MISSILE_DMG_SCALE 2.0
#define HELI_MISSILE_DMG_SCALE 5.0

_vehicle = _this select 0;
_selection = _this select 1;
_damage = _this select 2;
// _source = _this select 3;
_ammo = _this select 4;

if (_selection != "?") then
{
	_oldDamage = if (_selection == "") then {
		damage _vehicle
	} else {
		_vehicle getHitPointDamage (_vehicle getVariable ["A3W_hitPoint_" + _selection, ""]) // returns nil if hitpoint doesn't exist
	};

	if (!isNil "_oldDamage") then
	{
		if (_ammo == "") then // Reduce collision damage
		{
			_selSubstr = toArray _selection;
			_selSubstr resize 5;

			_scale = if (toString _selSubstr == "wheel") then {
				WHEEL_COLLISION_DMG_SCALE
			} else {
				COLLISION_DMG_SCALE
			};

			_damage = ((_damage - _oldDamage) * _scale) + _oldDamage;
		}
		else
		{
			// If vehicle is heli and projectile is missile then blow that shit up
			if (_vehicle isKindOf "Helicopter") then
			{
				if (_selection == "") then
				{
					if ({_ammo isKindOf _x} count ["R_PG32V_F", "M_NLAW_AT_F", "M_Titan_AT", "M_Titan_AA", "M_Air_AA", "Missile_AA_04_F"] > 0) then
					{
						_damage = ((_damage - _oldDamage) * HELI_MISSILE_DMG_SCALE) + _oldDamage;
					};
				}
				else
				{
					if (_selection == "fuel_hit") then
					{
						_damage = 0; // Block goddamn fuel leak
					};
				};
			};

			// If vehicle is tank and projectile is AT missile then multiply damage
			if (_vehicle isKindOf "Tank") then
			{
				if ({_ammo isKindOf _x} count ["R_PG32V_F", "M_NLAW_AT_F", "M_Titan_AT", "M_Scalpel_AT", "Missile_AGM_02_F"] > 0) then
				{
					_scale = if ({_vehicle isKindOf _x} count ["APC_Tracked_01_base_F", "APC_Tracked_02_base_F", "APC_Tracked_03_base_F"] > 0) then {
						IFV_MISSILE_DMG_SCALE
					} else {
						TANK_MISSILE_DMG_SCALE
					};

					_damage = ((_damage - _oldDamage) * _scale) + _oldDamage;
				};
			};
		};
	};
};

_damage
