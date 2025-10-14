class SPAS12SwitchMessage extends CriticalEventPlus;

var() localized string SwitchMessage[10];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if(Switch >= 0 && Switch <= 9)
		return Default.SwitchMessage[Switch];
}

defaultproperties
{
     SwitchMessage(0)="Loading bullets..."
     SwitchMessage(1)="Loading buckshot..."
     DrawColor=(B=105,G=105,R=105)
     FontSize=-1
}
