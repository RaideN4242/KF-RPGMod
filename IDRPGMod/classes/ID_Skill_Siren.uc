class ID_Skill_Siren extends ID_RPG_Base_Skill_Property;

#exec Texture Import File=Siren_icon_64.dds

static function float GetReduceDamageSiren(ID_RPG_Base_HumanPawn Player)
{
	return GetMulti(GetSkillLevel(Player));	
}

static function float GetMulti(int level)
{
	return level * 0.00094;
}

defaultproperties
{
     ToWhatProperty="to siren resistance"
     Title="Siren Resistance"
     Description="Increased resistance to siren."
     SkillIndex=42
     MaxLevel=1000
     Icon=Texture'IDRPGMod.Siren_icon_64'
}
