class ID_Skill_BetterArmor extends ID_RPG_Base_Skill_Property;

static function float GetArmoreDamageReduceMulti(ID_RPG_Stats_ReplicationLink Link)
{
	return GetMulti(GetSkillLevel(Link));
}

static function float GetMulti(int level)
{
	return level * 0.00034; // ***
}

defaultproperties
{
     ToWhatProperty="to armor damage reduction"
     Title="Better armor"
     Description="Your armor is better."
     SkillIndex=10
     MaxLevel=2500
     Icon=Texture'ModIconsRPG.ID_Skill_BetterArmor'
}
