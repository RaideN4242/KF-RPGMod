class ID_Skill_InfraVision extends ID_RPG_Base_Skill_Property;

static function float GetVisionDistance(ID_RPG_Stats_ReplicationLink Link)
{
	return GetMulti(GetSkillLevel(Link));
}

static function float GetMulti(int level)
{
	return level * 0.03;
}

defaultproperties
{
     ToWhatProperty="to vision radius"
     Title="Infra Vision"
     Description="Allows to see invisible monsters"
     SkillIndex=36
     MaxLevel=5000
     Icon=Texture'KillingFloorHUD.Perks.Perk_Commando'
     InitialCost="5000"
     PerLevelCost="5000"
     AdditionalCost="0"
}
