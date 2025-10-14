class SPAS12Fire extends ID_RPG_Base_Weapon_Shotgun_Fire;

#exec OBJ LOAD FILE="SPAS12_Snd.uax"

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	if( Instigator==None || Instigator.Controller==none )
		return;

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;
	Super.ModeDoFire();
}

simulated function bool AllowFire()
{

	if( KFWeapon(Weapon).bIsReloading && KFWeapon(Weapon).MagAmmoRemaining < 1)
		return false;

	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if( KFPawn(Instigator).bThrowingNade )
		return false;

	if( Level.TimeSeconds - LastClickTime>FireRate )
	{
		LastClickTime = Level.TimeSeconds;
	}

	if( KFWeapon(Weapon).MagAmmoRemaining<1 )
	{
		return false;
	}

	FireSound=Sound'SPAS12_Snd.Spas12_shot_mono';
	StereoFireSound=Sound'SPAS12_Snd.Spas12_shot_stereo';
	ProjPerFire=7;
	ProjectileClass=Class'IDRPGMod.SPAS12Bullet';
//	Weapon.ItemName=Weapon.default.ItemName $ "(Buckshot)";
	Spread=1125.000000;

	return super(WeaponFire).AllowFire();
}

function DrawMuzzleFlash(Canvas Canvas)
{
	super.DrawMuzzleFlash(Canvas);
}

function FlashMuzzleFlash()
{
	super.FlashMuzzleFlash();
}

simulated function DestroyEffects()
{
	super.DestroyEffects();
}

defaultproperties
{
     KickMomentum=(X=-45.000000,Z=10.000000)
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire"
     StereoFireSound=Sound'SPAS12_Snd.Spas12_shot_stereo'
     bRandomPitchFireSound=False
     ProjPerFire=20
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnimRate=0.900000
     FireSound=Sound'SPAS12_Snd.Spas12_shot_mono'
     NoAmmoSound=Sound'SPAS12_Snd.Spas12_empty'
     FireRate=0.400000
     AmmoClass=Class'IDRPGMod.SPAS12Ammo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'IDRPGMod.SPAS12Bullet'
     BotRefireRate=0.600000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=1.000000
     Spread=1125.000000
}
