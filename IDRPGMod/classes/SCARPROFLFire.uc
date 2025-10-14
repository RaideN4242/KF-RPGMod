//=============================================================================
 //SCARMK17 Fire
//=============================================================================
class SCARPROFLFire extends ID_RPG_Base_Weapon_Shotgun_Fire;

#EXEC OBJ LOAD FILE=KF_SCARSnd.uax
#EXEC OBJ LOAD FILE=KF_ZEDGunSnd.uax

var()		  class<Emitter>  ShellEjectClass;			// class of the shell eject emitter
var()		  Emitter		ShellEjectEmitter;		 // The shell eject emitter
var()		  name			ShellEjectBoneName;		// name of the shell eject bone

function float GetFireSpeed()
{
	if (ID_RPG_Base_HumanPawn(Instigator) != none)
	{
		return  1 + class'ID_Skill_FireSpeed'.static.GetFireSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), ID_RPG_Base_Weapon(Weapon));
	}

	return 1;
}

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	Spread = Default.Spread;
	Rec = 1;

	if ( ID_RPG_Base_HumanPawn(Instigator) != none )
	{
		Rec -= class'ID_Skill_DecreasedRecoil'.static.GetRecoilDecreaseMulti(ID_RPG_Base_HumanPawn(Instigator), ID_RPG_Base_Weapon(Weapon));
		
		if (Rec <= 0.3)
			Rec = 0.3;
		Spread = Spread * Rec;		
	}

	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}

	Super(BaseProjectileFire).ModeDoFire();

	// client
	if (Instigator.IsLocallyControlled())
	{
		HandleRecoil(Rec);
	}
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

function float MaxRange()
{
	return 25000;
}

defaultproperties
{
     ShellEjectClass=Class'ROEffects.KFShellEjectSCAR'
     ShellEjectBoneName="Shell_eject"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=500
     maxHorizontalRecoilAngle=250
     FireAimedAnim="Fire_Iron"
     StereoFireSound=Sound'KF_ZEDGunSnd.Fire.KF_WEP_ZED_Primary_S'
     ProjPerFire=1
     bPawnRapidFireAnim=True
     TransientSoundVolume=1.800000
     FireLoopAnim="Fire"
     TweenTime=0.025000
     FireSound=Sound'KF_ZEDGunSnd.Fire.KF_WEP_ZED_Primary_M'
     NoAmmoSound=Sound'KF_SCARSnd.SCAR_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=0.096000
     AmmoClass=Class'IDRPGMod.SCARPROFLAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=300.000000)
     ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
     ShakeRotTime=0.650000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.150000
     ProjectileClass=Class'IDRPGMod.SCARPROFLBullet'
     BotRefireRate=0.990000
     aimerror=42.000000
     Spread=0.007500
}
