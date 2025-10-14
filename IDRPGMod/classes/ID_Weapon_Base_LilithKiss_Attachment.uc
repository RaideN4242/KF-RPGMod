class ID_Weapon_Base_LilithKiss_Attachment extends DualiesAttachment;

simulated function UpdateTacBeam( float Dist );
simulated function TacBeamGone();

defaultproperties
{
     BrotherMesh=SkeletalMesh'DZResPack.lilith_3rd'
     mTracerClass=None
     mShellCaseEmitterClass=None
     bHeavy=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
     Mesh=SkeletalMesh'DZResPack.lilith_3rd'
}
