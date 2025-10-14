class ID_Skill_ExplosiveResistance extends ID_RPG_Base_Skill_Property;

static function float GetReduceDamageMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Monster Monster, class<DamageType> DmgType)
{
	if (DmgType == class'ID_Monster_Zombie_Patty_LAWProjectile_DamageType')
		return GetMulti(GetSkillLevel(Player)) / 2;
	if (DmgType == class'ID_Weapon_Base_M32GL_DamageType')
		return GetMulti(GetSkillLevel(Player));
	return 0;
}

static function float GetMulti(int level)
{
	if ( level > 1000)
		{
		return 1.0;
		}
	return level * 0.001;
}

defaultproperties
{
     ToWhatProperty="to explosives resistance"
     Title="Explosives Resistance"
     Description="Increased resistance to explosives.|Resistance to patty rocket - 1/2 of skill resitance"
     SkillIndex=18
     MaxLevel=950
     Icon=Texture'ModIconsRPG.ID_Skill_ExplosiveResistance'
}
