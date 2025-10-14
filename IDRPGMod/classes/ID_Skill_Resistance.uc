  class ID_Skill_Resistance extends ID_RPG_Base_Skill_Property;

static function float GetReduceDamageMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Monster Monster, class<DamageType> DmgType)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	if ( level > 10000) // ***
		{
		return 1.00;
		}	
	return level * 0.0003;
}

defaultproperties
{
     ToWhatProperty="to resistance"
     Title="Resistance"
     Description="Increased resistance from all damage."
     SkillIndex=1
     MaxLevel=2500
     Icon=Texture'ModIconsRPG.ID_Skill_Resistance'
}
