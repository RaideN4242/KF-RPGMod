class ID_Skill_TurretHP extends ID_RPG_Base_Skill_Property;

static function float GetAddHP(ID_RPG_Base_HumanPawn Player)
{
	return GetMulti(GetSkillLevel(Player));	
}

static function float GetMulti(int level)
{
	return level * 85;
}

defaultproperties
{
     ToWhatProperty="to turret HP"
     IsPercent=False
     Title="TurretHP"
     Description="Increased turret HP."
	 MaxLevel=75000000
     SkillIndex=44
     Icon=Texture'DZResPack.SentryGun_HP'
}
