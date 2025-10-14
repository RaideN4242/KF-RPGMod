class ActorVestRPG extends Actor;

var xPawn OwnerPawn;
var bool bDying;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if(xPawn(Owner) != none)
		OwnerPawn = xPawn(Owner);
	SetTimer(1,True);
}

simulated function Timer()
{
	if(OwnerPawn == none)
		Destroy();

	if(OwnerPawn != none && OwnerPawn.IsInState('Dying') && !bDying)
	{
		bTearOff = true;
		bDying = true;
		LifeSpan = 10;
		bUnlit = true;
		DetachFromBone(Owner);
	}
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DZResPack.Vest_sm'
     bReplicateInstigator=True
     DrawScale=1.300000
     bGameRelevant=True
     bNetNotify=True
}
