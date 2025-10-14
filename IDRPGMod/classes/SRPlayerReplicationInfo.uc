class SRPlayerReplicationInfo extends KFPlayerReplicationInfo;

var string ClanName;
var color ClanColor;
var string CurExp;
var int BLeft, MonsterLVL;
var bool bVoted,bHasSeenMessage,bHasSeenMessage30Secs;

replication
{
	reliable if(bNetDirty && Role==Role_Authority)
		ClanName,
		ClanColor,
		CurExp,BLeft,MonsterLVL,
		bVoted,bHasSeenMessage,bHasSeenMessage30Secs;
}

defaultproperties
{
     ClanColor=(B=255,G=255,R=255,A=255)
}
