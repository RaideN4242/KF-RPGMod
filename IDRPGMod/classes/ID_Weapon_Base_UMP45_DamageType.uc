class ID_Weapon_Base_UMP45_DamageType extends ID_RPG_Base_Weapon_DamageType_Projectile
	abstract;

defaultproperties
{
     WeaponClass=Class'IDRPGMod.ID_Weapon_Base_UMP45'
     DeathString="%k killed %o («HK UMP-45»)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=2500.000000
     KDeathVel=250.000000
     KDeathUpKick=80.000000
}
