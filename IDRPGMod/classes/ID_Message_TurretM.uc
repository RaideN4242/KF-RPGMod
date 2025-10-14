class ID_Message_TurretM extends LocalMessage;

var localized string Message[4];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	
	return Default.Message[Switch];
}

defaultproperties
{
     Message(0)="Can't deploy Medic RPG turret here"
     Message(1)="Medic RPG turret deployed"
     Message(2)="Medic RPG turret destroyed"
     Message(3)="Press '%Use%' to pick up the turret."
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=4
     DrawColor=(B=0,G=170,R=0)
     StackMode=SM_Down
     PosY=0.800000
}
