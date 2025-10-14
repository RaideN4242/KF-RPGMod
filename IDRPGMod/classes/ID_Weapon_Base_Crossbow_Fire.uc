class ID_Weapon_Base_Crossbow_Fire extends ID_RPG_Base_Weapon_Shotgun_Fire;

simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

function DoFireEffect()
{
   Super(ID_RPG_Base_Weapon_Shotgun_Fire).DoFireEffect();
}

defaultproperties
{
     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=250
     maxHorizontalRecoilAngle=75
     FireAimedAnim="Fire_Iron"
     bRandomPitchFireSound=False
     ProjPerFire=1
     ProjSpawnOffset=(Y=0.000000,Z=0.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireSound=SoundGroup'KF_XbowSnd.Xbow_Fire'
     NoAmmoSound=Sound'KF_XbowSnd.Xbow_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=2.500000
     AmmoClass=Class'KFMod.CrossbowAmmo'
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     ProjectileClass=Class'IDRPGMod.ID_Weapon_Base_Crossbow_Arrow'
     BotRefireRate=2.500000
     aimerror=1.000000
     Spread=0.750000
     SpreadStyle=SS_None
}
