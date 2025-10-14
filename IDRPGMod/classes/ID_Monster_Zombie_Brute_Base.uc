class ID_Monster_Zombie_Brute_Base extends ID_RPG_Base_Monster;

#exec OBJ LOAD FILE=WPC_BRUTE_T.utx
#exec OBJ LOAD FILE=KFWeaponSound.uax

var bool bChargingPlayer;
var bool bClientCharge;
var bool bFrustrated;
var int MaxRageCounter;
var int RageCounter;
var float RageSpeedTween;
var int TwoSecondDamageTotal;
var float LastDamagedTime;
var int RageDamageThreshold;
var int BlockHitsLanded;

var name ChargingAnim;
var Sound RageSound;

var() vector ShakeViewRotMag;
var() vector ShakeViewRotRate;
var() float ShakeViewRotTime;
var() vector ShakeViewOffsetMag;
var() vector ShakeViewOffsetRate;
var() float ShakeViewOffsetTime;

var float PushForce;
var vector PushAdd;
var float RageDamageMul;
var float RageBumpDamage;
var float BlockAddScale;
var bool bBlockedHS;
var bool bBlocking;
var bool bServerBlock;
var bool bClientBlock;
var float BlockDmgMul;
var float BlockFireDmgMul;
var float BurnGroundSpeedMul;

replication
{
	reliable if(Role == ROLE_Authority)
		bChargingPlayer, bServerBlock;
}

defaultproperties
{
     RageDamageThreshold=50
     ChargingAnim="BruteRun"
     RageSound=SoundGroup'WPC_Brute_S.Brute.Brute_Rage'
     ShakeViewRotMag=(X=500.000000,Y=500.000000,Z=600.000000)
     ShakeViewRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeViewRotTime=6.000000
     ShakeViewOffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     ShakeViewOffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeViewOffsetTime=3.500000
     PushForce=460.000000
     PushAdd=(Z=150.000000)
     RageDamageMul=1.100000
     RageBumpDamage=4.000000
     BlockAddScale=2.500000
     BlockDmgMul=0.100000
     BlockFireDmgMul=0.700000
     BurnGroundSpeedMul=0.850000
     TruePMHeadHeight=2.500000
     MeleeAnims(0)="BruteAttack1"
     MeleeAnims(1)="BruteAttack2"
     MeleeAnims(2)="BruteBlockSlam"
     MoanVoice=SoundGroup'WPC_Brute_S.Brute.Brute_Talk'
     BleedOutDuration=7.000000
     ZombieFlag=3
     MeleeDamage=20
     damageForce=6500
     bFatAss=True
     KFRagdollName="FleshPound_Trip"
     MeleeAttackHitSound=SoundGroup'WPC_Brute_S.Brute.Brute_HitPlayer'
     JumpSound=SoundGroup'WPC_Brute_S.Brute.Brute_Jump'
     SpinDamConst=20.000000
     SpinDamRand=20.000000
     bMeleeStunImmune=True
     bUseExtendedCollision=True
     ColOffset=(Z=52.000000)
     ColRadius=35.000000
     ColHeight=25.000000
     SeveredArmAttachScale=1.300000
     SeveredLegAttachScale=1.200000
     SeveredHeadAttachScale=1.500000
     PlayerCountHealthScale=0.250000
     OnlineHeadshotOffset=(X=22.000000,Z=68.000000)
     OnlineHeadshotScale=1.300000
     HeadHealth=450.000000
     PlayerNumHeadHealthScale=0.250000
     MotionDetectorThreat=5.000000
     HitSound(0)=SoundGroup'WPC_Brute_S.Brute.Brute_Pain'
     DeathSound(0)=SoundGroup'WPC_Brute_S.Brute.Brute_Death'
     ChallengeSound(0)=SoundGroup'WPC_Brute_S.Brute.Brute_Challenge'
     ChallengeSound(1)=SoundGroup'WPC_Brute_S.Brute.Brute_Challenge'
     ChallengeSound(2)=SoundGroup'WPC_Brute_S.Brute.Brute_Challenge'
     ChallengeSound(3)=SoundGroup'WPC_Brute_S.Brute.Brute_Challenge'
     ScoringValue=60
     IdleHeavyAnim="BruteIdle"
     IdleRifleAnim="BruteIdle"
     RagDeathUpKick=100.000000
     MeleeRange=85.000000
     GroundSpeed=140.000000
     WaterSpeed=120.000000
     HealthMax=900.000000
     Health=900
     HeadScale=1.300000
     MenuName="Brute"
     MovementAnims(0)="BruteWalkC"
     MovementAnims(1)="BruteWalkC"
     WalkAnims(0)="BruteWalkC"
     WalkAnims(1)="BruteWalkC"
     WalkAnims(2)="RunL"
     WalkAnims(3)="RunR"
     IdleCrouchAnim="BruteIdle"
     IdleWeaponAnim="BruteIdle"
     IdleRestAnim="BruteIdle"
     AmbientSound=Sound'WPC_Brute_S.Idle.FP_IdleLoop'
     Mesh=SkeletalMesh'WPC_BRUTE.Brute_Freak'
     PrePivot=(Z=0.000000)
     Skins(0)=Combiner'WPC_BRUTE_T.WPC.Brute_Final'
     Mass=600.000000
     RotationRate=(Yaw=45000,Roll=0)
}
