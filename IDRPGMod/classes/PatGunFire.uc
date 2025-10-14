class PatGunFire extends ID_RPG_Base_Weapon_Fire;

var 	sound   				FireEndSound;				// The sound to play at the end of the ambient fire sound
var 	sound   				FireEndStereoSound;			// The sound to play at the end of the ambient fire sound in first person stereo
var 	float   				AmbientFireSoundRadius;		// The sound radius for the ambient fire sound
var		sound					AmbientFireSound;		  // How loud to play the looping ambient fire sound
var		byte					AmbientFireVolume;		 // The ambient fire sound

function StartFiring()
{
	if( !bWaitForRelease )
	{
		GotoState('FireLoop');
	}
	else
	{
		Super.StartFiring();
	}
}

function PlayAmbientSound(Sound aSound)
{
	local WeaponAttachment WA;

	WA = WeaponAttachment(Weapon.ThirdPersonActor);

	if ( Weapon == none || (WA == none))
		return;

	if(aSound == None)
	{
		WA.SoundVolume = WA.default.SoundVolume;
		WA.SoundRadius = WA.default.SoundRadius;
	}
	else
	{
		WA.SoundVolume = AmbientFireVolume;
		WA.SoundRadius = AmbientFireSoundRadius;
	}

	WA.AmbientSound = aSound;
}

event ModeDoFire()
{
	if( !bWaitForRelease )
	{
		if( AllowFire() && IsInState('FireLoop'))
		{
			Super.ModeDoFire();
		}
	}
	else
	{
	  Super.ModeDoFire();
	}
}

state FireLoop
{
	function BeginState()
	{
		NextFireTime = Level.TimeSeconds - 0.1; //fire now!

		if( KFWeap.bAimingRifle )
		{
			Weapon.LoopAnim(FireLoopAimedAnim, FireLoopAnimRate, TweenTime);
		}
		else
		{
			Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
		}

		PlayAmbientSound(AmbientFireSound);
	}

	// Overriden because we play an anbient fire sound
	function PlayFiring() {}
	function ServerPlayFiring() {}

	function EndState()
	{
		Weapon.AnimStopLooping();
		PlayAmbientSound(none);
		if( Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
		  Weapon.Instigator.IsFirstPerson() && StereoFireSound != none )
		{
			Weapon.PlayOwnedSound(FireEndStereoSound,SLOT_None,AmbientFireVolume/127,,AmbientFireSoundRadius,,false);
		}
		else
		{
			Weapon.PlayOwnedSound(FireEndSound,SLOT_None,AmbientFireVolume/127,,AmbientFireSoundRadius);
		}
		Weapon.StopFire(ThisModeNum);
	}

	function StopFiring()
	{
		GotoState('');
	}

	function ModeTick(float dt)
	{
		Super.ModeTick(dt);

		if ( !bIsFiring ||  !AllowFire()  )  // stopped firing, magazine empty
		{
			GotoState('');
			return;
		}
	}
}

function PlayFireEnd()
{
	if( !bWaitForRelease )
	{
		Super.PlayFireEnd();
	}
}

defaultproperties
{
     FireEndSound=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineWindDown'
     AmbientFireSoundRadius=500.000000
     AmbientFireSound=Sound'KF_BasePatriarch.Attack.Kev_MG_GunfireLoop'
     AmbientFireVolume=255
     RecoilRate=0.005000
     maxVerticalRecoilAngle=20
     maxHorizontalRecoilAngle=15
     RecoilVelocityScale=0.000000
     ShellEjectClass=Class'IDRPGMod.PattyShellEject'
     ShellEjectBoneName="Barrel"
     bAccuracyBonusForSemiAuto=True
     DamageType=Class'IDRPGMod.DamTypePG'
     DamageMin=100
     DamageMax=120
     Momentum=5500.000000
     bPawnRapidFireAnim=True
     TransientSoundVolume=1.800000
     FireEndAnim="FireLoopEnd"
     TweenTime=0.025000
     FireRate=0.100000
     AmmoClass=Class'IDRPGMod.PatGunAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=25.000000,Y=25.000000,Z=125.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=4.000000,Y=2.500000,Z=5.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMG'
     Spread=1.800000
     SpreadStyle=SS_Random
}
