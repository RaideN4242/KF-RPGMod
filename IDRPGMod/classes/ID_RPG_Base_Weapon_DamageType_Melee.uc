class ID_RPG_Base_Weapon_DamageType_Melee extends ID_RPG_Base_Weapon_DamageType
	abstract;

defaultproperties
{
     HeadShotDamageMult=1.250000
     IsMelee=True
     WeaponClass=Class'IDRPGMod.ID_RPG_Base_Weapon_Melee'
     DeathString="%o was beat down by %k."
     FemaleSuicide="%o beat herself down."
     MaleSuicide="%o beat himself down."
     PawnDamageEmitter=Class'ROEffects.ROBloodPuff'
     LowGoreDamageEmitter=Class'ROEffects.ROBloodPuffNoGore'
     LowDetailEmitter=Class'ROEffects.ROBloodPuffSmall'
     FlashFog=(X=600.000000)
     VehicleDamageScaling=0.600000
}
