class ID_Skill_BattleMedic extends ID_RPG_Base_Skill_Property;

static function float GetSyringeRechrgeRateMulti(ID_RPG_Base_HumanPawn Player)
{
	return GetMulti(GetSkillLevel(Player));
}

static function float GetMulti(int level)
{
	return level * 0.1;
}

defaultproperties
{
     ToWhatProperty="to syringe recharge rate"
     Title="Battle Medic"
     Description="Faster syringe recharge."
     SkillIndex=29
     MaxLevel=9999
     Icon=Texture'ModIconsRPG.ID_Skill_BattleMedic'
}
