class ID_Skill_Doctor extends ID_RPG_Base_Skill_Property;

static function float GetHealPotencyMulti(ID_RPG_Base_HumanPawn Player)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.1;
}

defaultproperties
{
     ToWhatProperty="to healing power"
     Title="Doctor"
     Description="Better healing."
     SkillIndex=30
     MaxLevel=9999
     Icon=Texture'ModIconsRPG.ID_Skill_Doctor'
}
