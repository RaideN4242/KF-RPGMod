class ID_Skill_CarryWeight extends ID_RPG_Base_Skill_Property;

static function float GetCarryWeight(ID_RPG_Stats_ReplicationLink Link)
{
	return GetMulti(GetSkillLevel(Link));
}

static function float GetMulti(int level)
{
	return level * 1;
}

defaultproperties
{
     ToWhatProperty="to carry weigth"
     Title="Carry Weight"
     Description="Increased carry weight."
     SkillIndex=8
     MaxLevel=900
     Icon=Texture'ModIconsRPG.ID_Skill_CarryWeight'
}
