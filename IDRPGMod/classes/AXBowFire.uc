class AXBowFire extends ID_RPG_Base_Weapon_Shotgun_Fire;

function float GetFireSpeed()
{
/*	if (ID_RPG_Base_HumanPawn(Instigator) != none)
	{
		return  1 + class'ID_Skill_FireSpeed'.static.GetFireSpeedMulti(ID_RPG_Base_HumanPawn(Instigator), ID_RPG_Base_Weapon(Weapon));
	}*/

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
	return 2500;
}

defaultproperties
{
     EffectiveRange=2500.000000
     RecoilRate=0.085000
     maxVerticalRecoilAngle=2000
     maxHorizontalRecoilAngle=500
     FireAimedAnim="Fire"
     bRandomPitchFireSound=False
     FireSoundRef="DZResPack.AXBowShoot"
     NoAmmoSoundRef="DZResPack.AXBowDraw"
     ProjPerFire=1
     ProjSpawnOffset=(Y=0.000000,Z=0.000000)
     TransientSoundVolume=1.800000
     FireLoopAnim="Fire"
     FireSound=Sound'DZResPack.AXBowShoot'
     NoAmmoSound=Sound'DZResPack.AXBowDraw'
     FireForce="AssaultRifleFire"
     FireRate=0.250000
     AmmoClass=Class'IDRPGMod.AXBowAmmo'
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     ProjectileClass=Class'IDRPGMod.AXBowArrow'
     BotRefireRate=1.800000
     aimerror=1.000000
     Spread=0.750000
     SpreadStyle=SS_None
}
