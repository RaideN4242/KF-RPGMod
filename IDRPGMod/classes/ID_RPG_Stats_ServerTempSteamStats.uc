// Because this is most likely going to fail on init, spawn the real stats actor here...
Class ID_RPG_Stats_ServerTempSteamStats extends KFSteamStatsAndAchievements;

function PostBeginPlay()
{
	local KFPlayerController PlayerOwner;

	PlayerOwner = KFPlayerController(Owner);
	if( PlayerOwner.Player==None )
		return; // very bad...
	Spawn(Class'ID_RPG_Stats_ServerSteamStats',PlayerOwner);
}

defaultproperties
{
     bUsedCheats=True
     RemoteRole=ROLE_None
     LifeSpan=0.100000
     bNetNotify=False
}
