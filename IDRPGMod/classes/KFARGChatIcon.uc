class KFARGChatIcon extends Actor;

function PostBeginPlay()
{
	if(Level.Game.bTeamGame)
	{
		if(Pawn(Owner)!=None && Pawn(Owner).PlayerReplicationInfo.Team.TeamIndex==0)
		{
			Texture = Texture'Chat';
		}
	}
}

defaultproperties
{
     Texture=Texture'DZResPack.Chat'
     DrawScale=0.500000
     Style=STY_Masked
}
