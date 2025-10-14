class ID_Skill_FireSpeed extends ID_RPG_Base_Skill_Property;

static function float GetFireSpeedMulti(ID_RPG_Base_HumanPawn Player, ID_RPG_Base_Weapon Weapon)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.004;
}

defaultproperties
{
     ToWhatProperty="to firing speed"
     Title="Firing speed"
     Description="Increased firing speed from all weapons."
     SkillIndex=4
     Icon=Texture'ModIconsRPG.ID_Skill_FireSpeed'
}
