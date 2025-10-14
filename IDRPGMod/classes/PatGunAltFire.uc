class PatGunAltFire extends ID_RPG_Base_Weapon_Shotgun_Fire;

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
		if( Level.TimeSeconds - LastClickTime>FireRate )
		{
			LastClickTime = Level.TimeSeconds;
		}

		//if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

	return super(WeaponFire).AllowFire();
}

function float MaxRange()
{
	return 5000;
}

defaultproperties
{
     CrouchedAccuracyBonus=0.100000
     KickMomentum=(X=-45.000000,Z=25.000000)
     maxVerticalRecoilAngle=1000
     maxHorizontalRecoilAngle=250
     StereoFireSound=SoundGroup'KF_LAWSnd.LAW_FireST'
     bRandomPitchFireSound=False
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Z=0.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     TransientSoundVolume=1.800000
     FireSound=SoundGroup'KF_LAWSnd.LAW_Fire'
     NoAmmoSound=Sound'KF_LAWSnd.LAW_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=0.9
     AmmoClass=Class'IDRPGMod.PatRocketAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'IDRPGMod.MyLAWProj'
     BotRefireRate=2.250000
     Spread=0.100000
}
