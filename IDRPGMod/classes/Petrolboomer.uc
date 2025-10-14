class Petrolboomer extends ID_RPG_Base_Weapon;

simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	  return false;

	if( AmmoAmount(0) <= 0 )
	{
		return false;
	}

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
	if(!FireMode[0].IsInState('FireLoop'))
	{
	 	Super.AnimEnd(channel);
	}
}

function bool RecommendRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}
//
simulated function AltFire(float F){}
exec function SwitchModes(){}

/*
simulated function bool CanZoomNow()
{
	return ( !FireMode[1].bIsFiring &&
		  ((FireMode[1].NextFireTime - FireMode[1].FireRate * 0.2) < Level.TimeSeconds + FireMode[1].PreFireTime));
}

function bool AllowReload()
{
	if( (FireMode[1].NextFireTime - FireMode[1].FireRate * 0.1) > Level.TimeSeconds + FireMode[1].PreFireTime )
	{
		return false;
	}

	return super.AllowReload();
}

simulated function bool ReadyToFire(int Mode)
{
	// Don't allow firing while reloading the shell
	if( (FireMode[1].NextFireTime - FireMode[1].FireRate * 0.06) > Level.TimeSeconds + FireMode[1].PreFireTime )
	{
		return false;
	}

	return super.ReadyToFire(Mode);
}*/

defaultproperties
{
     ForceZoomOutOnAltFireTime=0.400000
     MagCapacity=100
     ReloadRate=3.750000
     bHasSecondaryAmmo=True
     bReduceMagAmmoOnSecondaryFire=False
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     FlashBoneName="Bone25"
     WeaponReloadAnim="Reload_SCAR"
     MinimumFireRange=300
     HudImage=Texture'DZResPack.txr.Petrolboomer_unselect'
     SelectedHudImage=Texture'DZResPack.txr.Petrolboomer_select'
     bSteadyAim=True
     Weight=20.000000
     bHasAimingMode=True
     IdleAimAnim="Idle"
     QuickPutDownTime=0.500000
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     SleeveNum=0
     TraderInfoTexture=Texture'DZResPack.txr.Petrolboomer_trader'
     bIsTier3Weapon=True
     ZoomInRotation=(Pitch=-1000,Roll=1500)
     ZoomedDisplayFOV=70.000000
     FireModeClass(0)=Class'IDRPGMod.PetrolboomerBurstFire'
     FireModeClass(1)=Class'IDRPGMod.PetrolboomerFireGL'
     PutDownAnim="PutDown"
     PutDownAnimRate=1.000000
     PutDownTime=1.000000
     AIRating=0.700000
     CurrentRating=0.700000
     Description="A deadly experimental weapon designed by Horzine industries. It can fire streams of burning liquid which ignite on contact."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=250
     InventoryGroup=4
     GroupOffset=8
     PickupClass=Class'IDRPGMod.PetrolboomerPickup'
     PlayerViewOffset=(X=7.000000,Y=3.000000,Z=-4.000000)
     BobDamping=4.500000
     AttachmentClass=Class'IDRPGMod.PetrolboomerAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="Petrolboomer"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
     Mesh=SkeletalMesh'DZResPack.v_petrolbomber'
     Skins(0)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
     Skins(1)=Combiner'DZResPack.txr.petrolboomer_cmb'
     Skins(2)=Texture'DZResPack.txr.petrol_v'
     TransientSoundVolume=1.250000
}
