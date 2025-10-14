class ID_Skill_HeadshotDamage extends ID_RPG_Base_Skill_Property;

static function float GetHeadshotDamageMulti(ID_RPG_Base_Monster Injured, ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.1;
}

defaultproperties
{
     ToWhatProperty="to headshot damage"
     Title="Headshot Damage"
     Description="Increased headshot damage from all weapons. Works with Damage skill."
     SkillIndex=2
	 MaxLevel=2000
     Icon=Texture'ModIconsRPG.ID_Skill_HeadshotDamage'
}
