class M14EBRProFire extends ID_RPG_Base_Weapon_Fire;

// Calculate modifications to spread
simulated function float GetSpread()
{
	local float NewSpread;
	local float AccuracyMod;

	AccuracyMod = 1.0;

	// Spread bonus for firing aiming
	if( KFWeap.bAimingRifle )
		AccuracyMod *= 0.5;

	// Small spread bonus for firing crouched
	if( Instigator != none && Instigator.bIsCrouched )
		AccuracyMod *= 0.85;

	// Small spread bonus for firing in semi auto mode
	if( bWaitForRelease )
		AccuracyMod *= 0.85;

	NumShotsInBurst += 1;

	if ( Level.TimeSeconds - LastFireTime > 0.5 )
	{
		NewSpread = Default.Spread;
		NumShotsInBurst=0;
	}
	else
	{
		// Decrease accuracy up to MaxSpread by the number of recent shots up to a max of six
		NewSpread = FMin(Default.Spread + (NumShotsInBurst * (MaxSpread/6.0)),MaxSpread);
	}

	NewSpread *= AccuracyMod;

	return NewSpread;
}

defaultproperties
{
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.085000
     maxVerticalRecoilAngle=600
     maxHorizontalRecoilAngle=150
     ShellEjectClass=Class'ROEffects.KFShellEjectEBR'
     ShellEjectBoneName="Shell_eject"
     StereoFireSound=SoundGroup'KF_M14EBRSnd.M14EBR_FireST'
     DamageType=Class'IDRPGMod.ID_Weapon_Base_M14EBR_DamageType'
     DamageMin=4966
     DamageMax=4966
     Momentum=9500.000000
     bPawnRapidFireAnim=True
     TransientSoundVolume=1.800000
     FireLoopAnim="Fire"
     TweenTime=0.025000
     FireSound=SoundGroup'KF_M14EBRSnd.M14EBR_Fire'
     NoAmmoSound=Sound'KF_M14EBRSnd.M14EBR_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=0.230000
     AmmoClass=Class'IDRPGMod.M14EBRProAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=300.000000)
     ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
     ShakeRotTime=0.650000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.150000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=0.000000
     SpreadStyle=SS_Random
}
