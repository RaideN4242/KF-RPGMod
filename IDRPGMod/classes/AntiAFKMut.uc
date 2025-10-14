//
// Written by metalmedved.com
// Custom-made weapons, skins and mutators
//
class AntiAFKMut extends Mutator
	config(IDRPGMod);

var() globalconfig int AFKLimit, LevelLimit, MinLevel; //* , MaxLevel *//
var() globalconfig localized string AFKKickMsg, LevelKickMsgTemp;
var() localized string LevelKickMsg;

var array<Controller> aPCs;

function PostNetBeginPlay()
{
	LevelKickMsg = LevelKickMsgTemp;
	ReplaceText(LevelKickMsg,"%a",string(MinLevel));
//	ReplaceText(LevelKickMsg,"%b",string(MaxLevel));

	SetTimer(5.0, True);
}

function ClearaPC(Controller C)
{
	local int i;

	m:
	for(i=0;i<aPCs.Length;i++)
	{
		if(aPCs[i]==None || aPCs[i]==C)
		{
			aPCs.Remove(i,1);
			goto m;
		}
	}
}

function bool IsInaPC(Controller C)
{
	local int i;

	for(i=0;i<aPCs.Length;i++)
	{
		if(C==aPCs[i])
			return true;
	}
	return false;
}

function InsertaPC(Controller C)
{
	aPCs[aPCs.Length]=C;
}

function checkAFK()
{
	local Controller C;
	local ID_RPG_Base_HumanPawn pawn;

	if (Level.Game.bGameEnded)
		return;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if( KFPlayerController(C)!=None && KFPlayerController(C).Pawn!=None && ID_RPG_Base_HumanPawn(KFPlayerController(C).Pawn) != none
			&& !KFPlayerController(C).PlayerReplicationInfo.bAdmin)
		{
			pawn = ID_RPG_Base_HumanPawn(KFPlayerController(C).Pawn);

			if( pawn.Lvl<MinLevel ) //* || pawn.Lvl>MaxLevel *// 
			{
				//log("Lvl"@pawn.Lvl);
				pawn.LevelTimer+=5;
			}
			else
				pawn.LevelTimer=0;

			if (pawn.LevelTimer>0)
				KFPlayerController(C).ClientMessage(LevelKickMsg, 'CriticalEvent');

			if(pawn.LevelTimer>LevelLimit)
			{
				Level.Game.Broadcast(Self,pawn.PlayerReplicationInfo.PlayerName@"is kicked for level restrictions.");
				Level.Game.AccessControl.DefaultKickReason=LevelKickMsg;
				Level.Game.AccessControl.KickPlayer(KFPlayerController(C));
				Level.Game.AccessControl.DefaultKickReason=Level.Game.AccessControl.default.DefaultKickReason;
				continue;
			}

			if(pawn.AFKLocation != pawn.Location || pawn.AFKKills!=KFPlayerReplicationInfo(pawn.PlayerReplicationInfo).Kills || pawn.HasTurret>0)
			{
				pawn.AFKLocation = pawn.Location;
				pawn.AFKTimer=0;
				pawn.AFKKills=KFPlayerReplicationInfo(pawn.PlayerReplicationInfo).Kills;
				ClearaPC(C);
			}
			else
			{
				pawn.AFKTimer+=5;
			}

			if (pawn.AFKTimer+10 >= AFKLimit && !IsInaPC(C))
			{
				InsertaPC(C);
				Level.Game.Broadcast(Self,pawn.PlayerReplicationInfo.PlayerName@"is AFK.");
				KFPlayerController(C).ClientMessage("You are AFK and will be kicked in 10 seconds", 'CriticalEvent');
			}

			if (pawn.AFKTimer >= AFKLimit)
			{
				Level.Game.Broadcast(Self,pawn.PlayerReplicationInfo.PlayerName@"is kicked for AFK.");
				Level.Game.AccessControl.DefaultKickReason=AFKKickMsg;
				Level.Game.AccessControl.KickPlayer(KFPlayerController(C));
				Level.Game.AccessControl.DefaultKickReason=Level.Game.AccessControl.default.DefaultKickReason;
				ClearaPC(C);
			}
		}
	}
}

function Timer()
{
	CheckAFK();
}

defaultproperties
{
     AFKLimit=500
     LevelLimit=0
     MinLevel=0
///     MaxLevel=99999999999
     AFKKickMsg="AFK"
     LevelKickMsgTemp="To play on this server your perk level should be between %a and %b"
     bAddToServerPackages=True
     GroupName="KF-AntiAFK"
     FriendlyName="Anti AFK RPG mutator"
     Description="Punish players for AFK in RPG Mod."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
