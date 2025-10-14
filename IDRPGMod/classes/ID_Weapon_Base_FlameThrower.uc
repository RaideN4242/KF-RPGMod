class ID_Weapon_Base_FlameThrower extends ID_RPG_Base_Weapon
	abstract;

simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	  return false;

	if( AmmoAmount(0) <= 0 )
		return false;

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
		return false;

	return true;
}

simulated function AnimEnd(int channel)
{
	if(!FireMode[0].IsInState('FireLoop'))
	{
	 	Super.AnimEnd(channel);
	}
}

simulated function WeaponTick(float dt)
{
  Super.WeaponTick(dt);
}

function bool RecommendRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

defaultproperties
{
     MagCapacity=30
     ReloadRate=5.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Flamethrower"
     MinimumFireRange=300
     HudImage=Texture'KillingFloorHUD.WeaponSelect.flamethrower_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.FlameThrower'
     bSteadyAim=True
     bHasAimingMode=True
     IdleAimAnim="Idle"
     QuickPutDownTime=0.500000
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Flame_Thrower'
     ZoomInRotation=(Pitch=-1000,Roll=1500)
     ZoomedDisplayFOV=70.000000
     FireModeClass(0)=Class'IDRPGMod.ID_Weapon_Base_FlameThrower_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     PutDownAnimRate=1.000000
     PutDownTime=1.000000
     AIRating=0.700000
     CurrentRating=0.700000
     Description="A deadly experimental weapon designed by Horzine industries. It can fire streams of burning liquid which ignite on contact."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=4
     InventoryGroup=4
     GroupOffset=2
     PickupClass=Class'IDRPGMod.ID_Weapon_Base_FlameThrower_Pickup'
     PlayerViewOffset=(X=5.000000,Y=7.000000,Z=-8.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.FlameThrowerAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="Flame Thrower"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Flamethrower_Trip'
     DrawScale=0.900000
     Skins(0)=Combiner'KF_Weapons_Trip_T.Supers.flamethrower_cmb'
     Skins(2)=FinalBlend'KillingFloorWeapons.Welder.FBFlameOrange'
     TransientSoundVolume=1.250000
}
