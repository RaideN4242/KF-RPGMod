class ID_Monster_Zombie_Jason_Base extends ID_RPG_Base_Monster;

#exec OBJ LOAD FILE=..\sounds\JasonVor_S.uax
#exec OBJ LOAD File=..\Sounds\KF_BaseGorefast.uax

var(Sounds) sound SawAttackLoopSound;
var(Sounds) sound ChainSawOffSound;

var bool bCharging;
var() float AttackChargeRate;

// Exhaust effects
var() class<VehicleExhaustEffect> ExhaustEffectClass;
var() VehicleExhaustEffect ExhaustEffect;
var bool bNoExhaustRespawn;

var() float BurnDamageScale;

replication
{
	reliable if(Role == ROLE_Authority)
		bCharging;
}

defaultproperties
{
     SawAttackLoopSound=Sound'KF_BaseGorefast.Attack.Gorefast_AttackSwish3'
     AttackChargeRate=2.500000
     BurnDamageScale=0.250000
     TruePMHeadHeight=2.200000
     MeleeAnims(0)="SawZombieAttack1"
     MeleeAnims(1)="SawZombieAttack2"
     bStunImmune=True
     StunsRemaining=0
     BleedOutDuration=6.000000
     ZombieFlag=3
     MeleeDamage=25
     damageForce=-75000
     bFatAss=True
     KFRagdollName="Scrake_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_HitPlayer'
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
     HeadHealth=800.000000
     PlayerNumHeadHealthScale=0.300000
     MotionDetectorThreat=3.000000
     ScoringValue=300
     IdleHeavyAnim="SawZombieIdle"
     IdleRifleAnim="SawZombieIdle"
     MeleeRange=40.000000
     GroundSpeed=85.000000
     WaterSpeed=75.000000
     HealthMax=1500.000000
     Health=1500
     MenuName="Jason"
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
     AmbientSound=Sound'JasonVor_S.Jason_Sound'
     Mesh=SkeletalMesh'JasonVor_A.Jason'
     DrawScale=1.050000
     PrePivot=(Z=3.000000)
     Skins(0)=Shader'JasonVor_T.Jason__FB'
     Skins(1)=Texture'JasonVor_T.JVMaskB'
     Skins(2)=Combiner'JasonVor_T.Machete_cmb'
     SoundVolume=175
     SoundRadius=100.000000
     Mass=500.000000
     RotationRate=(Yaw=45000,Roll=0)
}
