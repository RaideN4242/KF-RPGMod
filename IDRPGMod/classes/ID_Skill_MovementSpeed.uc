class ID_Skill_MovementSpeed extends ID_RPG_Base_Skill_Property;

static function float GetMovementSpeedMulti(ID_RPG_Stats_ReplicationLink Link)
{
	return GetMulti(GetSkillLevel(Link));
}

static function float GetMulti(int level)
{
	return level * 0.0006;
}

defaultproperties
{
     ToWhatProperty="to movement speed"
     Title="Movement speed"
     Description="Allows you to move faster."
     SkillIndex=9
     MaxLevel=9000
     Icon=Texture'ModIconsRPG.ID_Skill_MovementSpeed'
}
