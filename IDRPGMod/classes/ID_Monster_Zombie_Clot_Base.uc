class ID_Monster_Zombie_Clot_Base extends ID_RPG_Base_Monster;

#exec OBJ LOAD FILE=KFPlayerSound.uax
#exec OBJ LOAD FILE=KF_Freaks_Trip.ukx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T.utx

var KFPawn  DisabledPawn;
var bool bGrappling;
var float GrappleEndTime;
var() float GrappleDuration;

var float ClotGrabMessageDelay;

replication
{
	reliable if(bNetDirty && Role == ROLE_Authority)
		bGrappling;
}

defaultproperties
{
     GrappleDuration=1.500000
     ClotGrabMessageDelay=12.000000
     MeleeAnims(0)="ClotGrapple"
     MeleeAnims(1)="ClotGrappleTwo"
     MeleeAnims(2)="ClotGrappleThree"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Talk'
     bCannibal=True
     MeleeDamage=6
     damageForce=5000
     KFRagdollName="Clot_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Jump'
     CrispUpThreshhold=9
     PuntAnim="ClotPunt"
     AdditionalWalkAnims(0)="ClotWalk2"
     Intelligence=BRAINS_Mammal
     bUseExtendedCollision=True
     ColOffset=(Z=48.000000)
     ColRadius=25.000000
     ColHeight=5.000000
     ExtCollAttachBoneName="Collision_Attach"
     SeveredArmAttachScale=0.800000
     SeveredLegAttachScale=0.800000
     SeveredHeadAttachScale=0.800000
     OnlineHeadshotOffset=(X=20.000000,Z=37.000000)
     OnlineHeadshotScale=1.300000
     MotionDetectorThreat=0.340000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.clot.Clot_Challenge'
     ScoringValue=10
     MeleeRange=20.000000
     GroundSpeed=105.000000
     WaterSpeed=105.000000
     JumpZ=340.000000
     HealthMax=130.000000
     Health=130
     MenuName="Clot"
     MovementAnims(0)="ClotWalk"
     WalkAnims(0)="ClotWalk"
     WalkAnims(1)="ClotWalk"
     WalkAnims(2)="ClotWalk"
     WalkAnims(3)="ClotWalk"
     AmbientSound=Sound'KF_BaseClot.Clot_Idle1Loop'
     Mesh=SkeletalMesh'KF_Freaks_Trip.CLOT_Freak'
     DrawScale=1.100000
     PrePivot=(Z=5.000000)
     Skins(0)=Combiner'KF_Specimens_Trip_T.clot_cmb'
     RotationRate=(Yaw=45000,Roll=0)
}
