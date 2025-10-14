class ID_Message_BossTime extends ID_Message_SpecialSquadTime;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return Default.Message;
}

defaultproperties
{
     Message="BOSS TIME|Prepare your ass!"
     DrawColor=(B=0,G=0)
}
