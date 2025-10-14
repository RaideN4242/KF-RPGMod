class ID_Skill_IncreasedMagazine extends ID_RPG_Base_Skill_Property;

static function float GetMagIncreaseMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Weapon Weapon)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.013;
}

defaultproperties
{
     ToWhatProperty="to magazine size"
     Title="Magazine size"
     Description="Increased magazine size for all weapons."
     SkillIndex=7
     MaxLevel=99999
     Icon=Texture'ModIconsRPG.ID_Skill_IncreasedMagazine'
}
