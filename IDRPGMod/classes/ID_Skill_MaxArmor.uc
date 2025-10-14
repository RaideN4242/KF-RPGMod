class ID_Skill_MaxArmor extends ID_RPG_Base_Skill_Property;

static function float GetAdditionalArmor(ID_RPG_Stats_ReplicationLink Link)
{
	return GetMulti(GetSkillLevel(Link));
}

static function float GetMulti(int level)
{
	return level * 3; // ***
}

defaultproperties
{
     ToWhatProperty="to max armor"
     Title="Max Armor"
     Description="Increased max armor."
     SkillIndex=14
     MaxLevel=700000000
     Icon=Texture'ModIconsRPG.ID_Skill_MaxArmor'
}
