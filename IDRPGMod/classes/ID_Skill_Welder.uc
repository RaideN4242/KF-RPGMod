class ID_Skill_Welder extends ID_RPG_Base_Skill_Property;

static function float GetWeldDamageMulti(ID_RPG_Base_HumanPawn Player)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 5;
}

defaultproperties
{
     ToWhatProperty="to welding speed"
     Title="Welder"
     Description="Faster welding."
     SkillIndex=28
     MaxLevel=9999
     Icon=Texture'ModIconsRPG.ID_Skill_Welder'
}
