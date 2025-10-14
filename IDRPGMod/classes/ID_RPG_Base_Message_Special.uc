class ID_RPG_Base_Message_Special extends LocalMessage;

var string Message;

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
     Message="KILL THIS STUPID MESSAGE"
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=220,G=0)
     StackMode=SM_Down
     PosY=0.800000
}
