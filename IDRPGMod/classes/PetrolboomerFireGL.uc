class PetrolboomerFireGL extends ID_RPG_Base_Weapon_Shotgun_Fire;

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

simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

function float MaxRange()
{
	return 5000;
}

function DoFireEffect()
{
   Super(KFShotgunFire).DoFireEffect();
}
function InitEffects()
{
	Super.InitEffects();
	if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'Bone25');
}

defaultproperties
{
     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=50
     FireAimedAnim="Fire_GL"
     StereoFireSound=SoundGroup'KF_M79Snd.M79_FireST'
     FireSoundRef="KF_M79Snd.M79_Fire"
     StereoFireSoundRef="KF_M79Snd.M79_FireST"
     NoAmmoSoundRef="KF_M79Snd.M79_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=10.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireAnim="Fire_GL"
     FireSound=SoundGroup'KF_M79Snd.M79_Fire'
     NoAmmoSound=Sound'KF_M79Snd.M79_DryFire'
     FireForce="AssaultRifleFire"
     FireRate=4.500000
     AmmoClass=Class'IDRPGMod.PetrolboomerAmmoGL'
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     ProjectileClass=Class'IDRPGMod.MolotovProj'
     BotRefireRate=1.800000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stNadeL'
     aimerror=42.000000
     Spread=0.015000
}
