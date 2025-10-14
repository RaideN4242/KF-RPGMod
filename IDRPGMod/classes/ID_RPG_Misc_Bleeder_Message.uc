class ID_RPG_Misc_Bleeder_Message extends CriticalEventPlus
	abstract;
	
var string YouAreBleedingText, YourTeamMateIsBleeding;

static function string GetString(optional int SwitchX, optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local string S;

	if (RelatedPRI_1 == none)
		return "";
	
	if( SwitchX==1 )
		Return Default.YouAreBleedingText;
	S = Default.YourTeamMateIsBleeding;
	ReplaceText(S,"%o", RelatedPRI_1.PlayerName);
	return S;
}

static function ClientReceive(PlayerController P, optional int SwitchX, optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if( P.PlayerReplicationInfo==RelatedPRI_1 )
		SwitchX = 1;
	Super.ClientReceive(P,SwitchX,RelatedPRI_1);
}

defaultproperties
{
     YouAreBleedingText="You are bleeding."
     YourTeamMateIsBleeding="%o is bleeding, heal him before he dies."
     DrawColor=(B=73,G=76,R=200)
     StackMode=SM_Up
     PosY=0.700000
     FontSize=6
}
