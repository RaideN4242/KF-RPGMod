class ID_Message_RestartPlayer extends LocalMessage;

var string Message;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	return Default.Message @ Switch @ "seconds";
}

defaultproperties
{
     Message="You will be respawned in"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=0,R=0)
     StackMode=SM_Down
     PosY=0.200000
}
