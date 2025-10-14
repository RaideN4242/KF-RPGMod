 class ID_Weapon_Base_Single extends ID_RPG_Base_Weapon;


function byte BestMode()
{
	return 0;
}

defaultproperties
{
     FirstPersonFlashlightOffset=(X=-20.000000,Y=-22.000000,Z=8.000000)
     MagCapacity=13
     ReloadRate=2.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Single9mm"
     ModeSwitchAnim="LightOn"
     HudImage=Texture'KillingFloorHUD.WeaponSelect.single_9mm_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.single_9mm'
     Weight=0.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_9mm'
     ZoomedDisplayFOV=65.000000
     FireModeClass(0)=Class'IDRPGMod.ID_Weapon_Base_Single_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_9MMSnd.9mm_Select'
     AIRating=0.250000
     CurrentRating=0.250000
     Description="A 9mm Pistol"
     DisplayFOV=70.000000
     Priority=3
     InventoryGroup=2
     GroupOffset=1
     PickupClass=Class'IDRPGMod.ID_Weapon_Base_Single_Pickup'
     PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-10.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.SingleAttachment'
     IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
     ItemName="9mm Tactical"
     Mesh=SkeletalMesh'KF_Weapons_Trip.9mm_Trip'
     Skins(0)=Combiner'KF_Weapons_Trip_T.Pistols.Ninemm_cmb'
}
