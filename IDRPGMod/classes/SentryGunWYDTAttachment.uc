class SentryGunWYDTAttachment extends PipeBombAttachment;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TweenAnim('Fold',0.01f);
}

defaultproperties
{
     Mesh=SkeletalMesh'DZResPack.SentryGunWYDT_Mesh'
     PrePivot=(Z=7.000000)
}
