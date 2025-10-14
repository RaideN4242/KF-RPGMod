class ID_Monster_Zombie_GoreFast_Base extends ID_RPG_Base_Monster;

#exec OBJ LOAD FILE=KFPlayerSound.uax

var bool bRunning;
var float RunAttackTimeout;

replication
{
	reliable if(Role == ROLE_Authority)
		bRunning;
}

defaultproperties
{
     ExperiencePoints="100"
     TruePMHeadHeight=2.500000
     MeleeAnims(0)="GoreAttack1"
     MeleeAnims(1)="GoreAttack2"
     MeleeAnims(2)="GoreAttack1"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Talk'
     bCannibal=True
     MeleeDamage=15
     damageForce=5000
     KFRagdollName="GoreFast_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Jump'
     CrispUpThreshhold=8
     bUseExtendedCollision=True
     ColOffset=(Z=52.000000)
     ColRadius=25.000000
     ColHeight=10.000000
     ExtCollAttachBoneName="Collision_Attach"
     SeveredArmAttachScale=0.900000
     SeveredLegAttachScale=0.900000
     PlayerCountHealthScale=0.150000
     OnlineHeadshotOffset=(X=5.000000,Z=53.000000)
     OnlineHeadshotScale=1.500000
     MotionDetectorThreat=0.500000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_Challenge'
     ScoringValue=15
     IdleHeavyAnim="GoreIdle"
     IdleRifleAnim="GoreIdle"
     MeleeRange=30.000000
     GroundSpeed=120.000000
     WaterSpeed=140.000000
     HealthMax=250.000000
     Health=250
     HeadScale=1.500000
     MenuName="Gorefast"
     MovementAnims(0)="GoreWalk"
     WalkAnims(0)="GoreWalk"
     WalkAnims(1)="GoreWalk"
     WalkAnims(2)="GoreWalk"
     WalkAnims(3)="GoreWalk"
     IdleCrouchAnim="GoreIdle"
     IdleWeaponAnim="GoreIdle"
     IdleRestAnim="GoreIdle"
     AmbientSound=Sound'KF_BaseGorefast.Gorefast_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip.GoreFast_Freak'
     DrawScale=1.200000
     PrePivot=(Z=10.000000)
     Skins(0)=Combiner'KF_Specimens_Trip_T.gorefast_cmb'
     Mass=350.000000
     RotationRate=(Yaw=45000,Roll=0)
}
