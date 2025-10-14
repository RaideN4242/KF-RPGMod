class M32ProFire extends ID_RPG_Base_Weapon_Shotgun_Fire;

function float MaxRange()
{
	return 2500;
}

defaultproperties
{
     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=50
     FireAimedAnim="Iron_Fire"
     StereoFireSound=SoundGroup'KF_M32Snd.M32_FireST'
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=10.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireSound=SoundGroup'KF_M32Snd.M32_Fire'
     NoAmmoSound=Sound'KF_M79Snd.M79_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=0.330000
     AmmoClass=Class'IDRPGMod.M32Pro1Ammo'
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     ProjectileClass=Class'IDRPGMod.M32Pro1Proj'
     BotRefireRate=1.800000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stNadeL'
     aimerror=0.000000
     Spread=0.000000
}
