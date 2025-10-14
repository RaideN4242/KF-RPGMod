class ID_RPG_Base_Skill_Weapon extends ID_RPG_Base_Skill;

var float DamageMulti;
var float ReloadMulti;
var float FireMulti;
var float ClipMulti;
var class<ID_RPG_Base_Weapon> Weapon;

static function float GetDamageMulti(ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	if(ClassIsChildOf(Player.Weapon.class, default.Weapon))
		return GetDamageMultiInternal(GetSkillLevel(Player));
	return 0;
}

static function float GetDamageMultiInternal(int level)
{
	return level*default.DamageMulti;
}

static function string GetCurrentSkillInfoInternal(int level)
{
	local float damage;
	damage=GetDamageMultiInternal(level);
	return "+"$ToPercent(damage)@"damage with"@default.Weapon.default.ItemName;
}

static function string GetNextSkillInfoInternal(int level)
{
	return GetCurrentSkillInfoInternal(level);
}

static function string GetSkillTitle(ID_RPG_Stats_ReplicationLink Link)
{
	return default.Weapon.default.ItemName@"Mastery";
}

defaultproperties
{
     DamageMulti=0.050000
     Weapon=Class'IDRPGMod.ID_Weapon_Base_AA12AS'
     Title="Weapon Mastery"
}
