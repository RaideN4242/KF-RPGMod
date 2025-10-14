class ID_Weapon_Base_Katana extends ID_RPG_Base_Weapon_Melee
    abstract;

defaultproperties
{
     weaponRange=99.000000
     BloodyMaterial=Combiner'KF_Weapons2_Trip_T.melee.Katana_Bloody_cmb'
     BloodSkinSwitchArray=0
     bSpeedMeUp=True
     HudImage=Texture'KillingFloor2HUD.WeaponSelect.Katana_unselected'
     SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.Katana'
     Weight=3.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Katana'
     FireModeClass(0)=Class'IDRPGMod.ID_Weapon_Base_Katana_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     SelectSound=SoundGroup'KF_KatanaSnd.Katana_Select'
     AIRating=0.400000
     CurrentRating=0.600000
     Description="An incredibly sharp katana sword."
     DisplayFOV=75.000000
     Priority=5
     GroupOffset=1
     PickupClass=Class'IDRPGMod.ID_Weapon_Base_Katana_Pickup'
     BobDamping=8.000000
     AttachmentClass=Class'KFMod.KatanaAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Katana"
     Mesh=SkeletalMesh'KF_Weapons2_Trip.katana_Trip'
     Skins(0)=Combiner'KF_Weapons2_Trip_T.melee.Katana_cmb'
}
