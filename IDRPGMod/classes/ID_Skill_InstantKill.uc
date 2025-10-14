class ID_Skill_InstantKill extends ID_RPG_Base_Skill_Property;

var array< class<ID_RPG_Base_Weapon_DamageType> > NotSkillDamageTypes;

static function float GetInstantKillChance(ID_RPG_Base_HumanPawn Player, class<DamageType> DamageType)
{
	local int i;
	for (i = 0; i < default.NotSkillDamageTypes.Length; i++)
		if (default.NotSkillDamageTypes[i] == DamageType)
			return 0;
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.00011;
}

defaultproperties
{
     NotSkillDamageTypes(0)=Class'IDRPGMod.ID_Util_Base_RadialShotSystem_DamageType'
     NotSkillDamageTypes(1)=Class'IDRPGMod.ID_Weapon_Base_Turret_DamageType'
     ToWhatProperty="to instant kill chance"
     Title="Instant kill"
     Description="Chance to kill monster from 1 bullet. Does not work with turret and radial system"
     SkillIndex=11
     MaxLevel=2000
	 Icon=Texture'ModIconsRPG.ID_Skill_InstantKill'
}
