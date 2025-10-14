class ID_RPG_Base_Weapon_DamageType extends WeaponDamageType;

var float	HeadShotDamageMult;

var bool IsShotgun;
var bool IsPistol;
var bool IsSubMachineGun;
var bool IsMachineGun;
var bool IsSniper;
var bool IsFlamer;
var bool IsExplosive;
var bool IsMelee;
var bool CheckForHeadShots;

defaultproperties
{
     HeadShotDamageMult=1.300000
     CheckForHeadShots=True
     bKUseOwnDeathVel=True
     bBulletHit=True
     GibPerterbation=0.250000
     KDamageImpulse=15000.000000
     KDeathVel=200.000000
     KDeathUpKick=100.000000
     HumanObliterationThreshhold=25000
}
