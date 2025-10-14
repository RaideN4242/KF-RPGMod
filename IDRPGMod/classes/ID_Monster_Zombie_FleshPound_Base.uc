class ID_Monster_Zombie_FleshPound_Base extends ID_RPG_Base_Monster;

#exec OBJ LOAD FILE=KFPlayerSound.uax

var () float BlockDamageReduction;
var bool bChargingPlayer,bClientCharge;
var int TwoSecondDamageTotal;
var float LastDamagedTime,RageEndTime;

var() vector RotMag;
var() vector RotRate;
var() float RotTime;
var() vector OffsetMag;
var() vector OffsetRate;
var() float OffsetTime;

var name ChargingAnim;

var() int RageDamageThreshold;

var FleshPoundAvoidArea AvoidArea;

var bool bFrustrated;

replication
{
	reliable if(Role == ROLE_Authority)
		bChargingPlayer, bFrustrated;
}

defaultproperties
{
     BlockDamageReduction=0.400000
     RotMag=(X=500.000000,Y=500.000000,Z=600.000000)
     RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     RotTime=6.000000
     OffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     OffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     OffsetTime=3.500000
     ChargingAnim="PoundRun"
     RageDamageThreshold=360
     ExperiencePoints="1700"
     TruePMHeadHeight=2.500000
     MeleeAnims(0)="PoundAttack1"
     MeleeAnims(1)="PoundAttack2"
     MeleeAnims(2)="PoundAttack3"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Talk'
     StunsRemaining=1
     BleedOutDuration=7.000000
     ZombieFlag=3
     MeleeDamage=35
     damageForce=15000
     bFatAss=True
     KFRagdollName="FleshPound_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Jump'
     SpinDamConst=20.000000
     SpinDamRand=20.000000
     bMeleeStunImmune=True
     Intelligence=BRAINS_Mammal
     bUseExtendedCollision=True
     ColOffset=(Z=52.000000)
     ColRadius=36.000000
     ColHeight=35.000000
     SeveredArmAttachScale=1.300000
     SeveredLegAttachScale=1.200000
     SeveredHeadAttachScale=1.500000
     PlayerCountHealthScale=0.250000
     OnlineHeadshotOffset=(X=22.000000,Z=68.000000)
     OnlineHeadshotScale=1.300000
     HeadHealth=1200.000000
     PlayerNumHeadHealthScale=0.300000
     MotionDetectorThreat=5.000000
     bBoss=True
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ScoringValue=160
     IdleHeavyAnim="PoundIdle"
     IdleRifleAnim="PoundIdle"
     RagDeathUpKick=100.000000
     MeleeRange=45.000000
     GroundSpeed=130.000000
     WaterSpeed=120.000000
     HealthMax=2000.000000
     Health=2000
     HeadScale=1.300000
     MenuName="Flesh Pound"
     MovementAnims(0)="PoundWalk"
     MovementAnims(1)="WalkB"
     WalkAnims(0)="PoundWalk"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="RunL"
     WalkAnims(3)="RunR"
     IdleCrouchAnim="PoundIdle"
     IdleWeaponAnim="PoundIdle"
     IdleRestAnim="PoundIdle"
     AmbientSound=Sound'KF_BaseFleshpound.FP_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip.FleshPound_Freak'
     PrePivot=(Z=0.000000)
     Skins(0)=Combiner'KF_Specimens_Trip_T.fleshpound_cmb'
     Skins(1)=Shader'KFCharacters.FPAmberBloomShader'
     Mass=600.000000
     RotationRate=(Yaw=45000,Roll=0)
}
