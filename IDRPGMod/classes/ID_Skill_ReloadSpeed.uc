class ID_Skill_ReloadSpeed extends ID_RPG_Base_Skill_Property;

static function float GetReloadSpeedMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Weapon Weapon)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.005;
}

defaultproperties
{
     ToWhatProperty="to reload speed"
     Title="Reload speed"
     Description="Increased reload speed for all weapons."
     SkillIndex=6
     MaxLevel=5000
     Icon=Texture'ModIconsRPG.ID_Skill_ReloadSpeed'
}
