class AKFTurretAttachment extends PipeBombAttachment;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TweenAnim('Idle',0.01f);
}

defaultproperties
{
     Mesh=SkeletalMesh'DZResPack.turret_mesh_v'
}
