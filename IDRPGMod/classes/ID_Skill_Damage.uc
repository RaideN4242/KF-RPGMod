class ID_Skill_Damage extends ID_RPG_Base_Skill_Property;

static function float GetDamageMulti(ID_RPG_Base_Monster Injured, ID_RPG_Base_HumanPawn Player, class<DamageType> DmgType)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.013;
}

defaultproperties
{
     Title="Damage skill"
	 MaxLevel=85000000
     Description="Damage to monsters."
     Icon=Texture'ModIconsRPG.ID_Skill_Damage'
}
