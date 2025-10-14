class WTFEquipAFS12Fire extends ID_RPG_Base_Weapon_Shotgun_Fire;

var()		  class<Emitter>  ShellEjectClass;			// class of the shell eject emitter
var()		  Emitter		ShellEjectEmitter;		 // The shell eject emitter
var()		  name			ShellEjectBoneName;		// name of the shell eject bone

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

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

	return super(WeaponFire).AllowFire();
}

simulated function InitEffects()
{
	super.InitEffects();

	// don't even spawn on server
	if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if ( (ShellEjectClass != None) && ((ShellEjectEmitter == None) || ShellEjectEmitter.bDeleteMe) )
	{
		ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
		Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
	}
}

function DrawMuzzleFlash(Canvas Canvas)
{
	super.DrawMuzzleFlash(Canvas);
	// Draw shell ejects
	if (ShellEjectEmitter != None )
	{
		Canvas.DrawActor( ShellEjectEmitter, false, false, Weapon.DisplayFOV );
	}
}

function FlashMuzzleFlash()
{
	super.FlashMuzzleFlash();

	if (ShellEjectEmitter != None)
	{
		ShellEjectEmitter.Trigger(Weapon, Instigator);
	}
}

simulated function DestroyEffects()
{
	super.DestroyEffects();

	if (ShellEjectEmitter != None)
		ShellEjectEmitter.Destroy();
}

defaultproperties
{
     ShellEjectClass=Class'ROEffects.KFShellEjectShotty'
     ShellEjectBoneName="Shell_eject"
     maxVerticalRecoilAngle=1000
     maxHorizontalRecoilAngle=500
     FireAimedAnim="Fire_Iron"
     StereoFireSound=SoundGroup'KF_AA12Snd.AA12_FireST'
     bRandomPitchFireSound=False
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireSound=SoundGroup'KF_AA12Snd.AA12_Fire'
     NoAmmoSound=Sound'KF_AA12Snd.AA12_DryFire'
     FireRate=0.200000
     AmmoClass=Class'IDRPGMod.WTFEquipAFS12Ammo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=250.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=6.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     ProjectileClass=Class'IDRPGMod.WTFEquipAFS12ForceBullet'
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=1.000000
     Spread=1125.000000
     ProjPerFire=12

}
