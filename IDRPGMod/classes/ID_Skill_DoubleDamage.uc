class ID_Skill_DoubleDamage extends ID_RPG_Base_Skill_Property;

static function float GetDoubleDamageChance(ID_RPG_Base_HumanPawn Player)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.001;
}

defaultproperties
{
     ToWhatProperty="to double damage chance"
     Title="Double damage"
     Description="Chance to deal 2x damage."
     SkillIndex=12
     MaxLevel=1000
     Icon=Texture'ModIconsRPG.ID_Skill_DoubleDamage'
}
