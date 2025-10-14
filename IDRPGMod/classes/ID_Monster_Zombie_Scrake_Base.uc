class ID_Monster_Zombie_Scrake_Base extends ID_RPG_Base_Monster;

#exec OBJ LOAD FILE=KFPlayerSound.uax

var(Sounds) sound SawAttackLoopSound;
var(Sounds) sound ChainSawOffSound;

var bool bCharging;
var() float AttackChargeRate;

// Exhaust effects
var() class<VehicleExhaustEffect> ExhaustEffectClass;
var() VehicleExhaustEffect ExhaustEffect;
var bool bNoExhaustRespawn;

replication
{
	reliable if(Role == ROLE_Authority)
		bCharging;
}

defaultproperties
{
     SawAttackLoopSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Impale'
     ChainSawOffSound=SoundGroup'KF_ChainsawSnd.Chainsaw_Deselect'
     AttackChargeRate=2.500000
     ExhaustEffectClass=Class'KFMod.ChainsawExhaust'
     ExperiencePoints="1000"
     TruePMHeadHeight=2.200000
     MeleeAnims(0)="SawZombieAttack1"
     MeleeAnims(1)="SawZombieAttack2"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Talk'
     StunsRemaining=1
     BleedOutDuration=6.000000
     ZombieFlag=3
     MeleeDamage=20
     damageForce=-75000
     bFatAss=True
     KFRagdollName="Scrake_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Jump'
     bMeleeStunImmune=True
     Intelligence=BRAINS_Mammal
     bUseExtendedCollision=True
     ColOffset=(Z=55.000000)
     ColRadius=29.000000
     ColHeight=18.000000
     SeveredArmAttachScale=1.100000
     SeveredLegAttachScale=1.100000
     PlayerCountHealthScale=0.500000
     PoundRageBumpDamScale=0.010000
     OnlineHeadshotOffset=(X=22.000000,Y=5.000000,Z=58.000000)
     OnlineHeadshotScale=1.500000
     HeadHealth=650.000000
     PlayerNumHeadHealthScale=0.300000
     MotionDetectorThreat=3.000000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ScoringValue=100
     IdleHeavyAnim="SawZombieIdle"
     IdleRifleAnim="SawZombieIdle"
     MeleeRange=40.000000
     GroundSpeed=85.000000
     WaterSpeed=75.000000
     HealthMax=1200.000000
     Health=1200
     MenuName="Scrake"
     MovementAnims(0)="SawZombieWalk"
     MovementAnims(1)="SawZombieWalk"
     MovementAnims(2)="SawZombieWalk"
     MovementAnims(3)="SawZombieWalk"
     WalkAnims(0)="SawZombieWalk"
     WalkAnims(1)="SawZombieWalk"
     WalkAnims(2)="SawZombieWalk"
     WalkAnims(3)="SawZombieWalk"
     IdleCrouchAnim="SawZombieIdle"
     IdleWeaponAnim="SawZombieIdle"
     IdleRestAnim="SawZombieIdle"
     AmbientSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip.Scrake_Freak'
     DrawScale=1.050000
     PrePivot=(Z=3.000000)
     Skins(0)=Shader'KF_Specimens_Trip_T.scrake_FB'
     Skins(1)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
     SoundVolume=175
     SoundRadius=100.000000
     Mass=500.000000
     RotationRate=(Yaw=45000,Roll=0)
}
