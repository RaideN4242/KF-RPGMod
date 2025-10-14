class ID_Skill_FireResistance extends ID_RPG_Base_Skill_Property;

static function float GetReduceDamageMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Monster Monster, class<DamageType> DmgType)
{
	if (DmgType == class'ID_Weapon_Base_FlameThrower_DamageType' || DmgType == class'DamTypeBurned')
		return GetMulti(GetSkillLevel(Player));
	return 0;
}

static function float GetMulti(int level)
{
	return level * 0.001;
}

/*static function float GetMulti(int level)
{
	if ( level > 20)
		{
		return 0.7;
		}
	return level * 0.0019;
}*/

defaultproperties
{
     ToWhatProperty="to fire resistance"
     Title="Fire Resistance"
     Description="Increased resistance to fire."
     SkillIndex=17
     MaxLevel=980
     Icon=Texture'ModIconsRPG.ID_Skill_FireResistance'
}
