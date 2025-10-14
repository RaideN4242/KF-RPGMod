class ID_Skill_MaxHP extends ID_RPG_Base_Skill_Property;

static function float GetAdditionalHP(ID_RPG_Stats_ReplicationLink Link)
{
	return GetMulti(GetSkillLevel(Link));
}

static function float GetMulti(int level)
{
	return level * 3; // ***
}

defaultproperties
{
     ToWhatProperty="to max hp"
     Title="Max HP"
     Description="Increased max hp."
     SkillIndex=13
     MaxLevel=700000000
     Icon=Texture'ModIconsRPG.ID_Skill_MaxHP'
}
