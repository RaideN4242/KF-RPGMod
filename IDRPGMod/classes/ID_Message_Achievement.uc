class ID_Message_Achievement extends ID_Message_SpecialSquadTime
	abstract;

static function string GetString(optional int SwitchX, optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local string S;

	if( SwitchX==1 )
		S = "You";
	else
		S = Eval(RelatedPRI_1!=None,RelatedPRI_1.PlayerName,Class'xDeathMessage'.Default.SomeoneString);

	S @= "acvieved:" @ class<ID_RPG_Base_Achievement>(OptionalObject).static.GetTitle();

	S $= "|Reward:"  @ class<ID_RPG_Base_Achievement>(OptionalObject).static.GetReward();
	return S;
}

static function ClientReceive(PlayerController P, optional int SwitchX, optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if( P.PlayerReplicationInfo==RelatedPRI_1 )
		SwitchX = 1;
	Super.ClientReceive(P,SwitchX,RelatedPRI_1,,OptionalObject);
}

defaultproperties
{
     DrawColor=(B=184,G=255,R=79)
     StackMode=SM_Up
}
