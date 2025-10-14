class SCARPROFAssaultRifle extends ID_Weapon_Base_SCAR;

//#EXEC OBJ LOAD FILE=LS_A.ukx package=LaserScar

// Don't use alt fire to toggle
simulated function AltFire(float F);
// Don't switch fire mode
exec function SwitchModes();

defaultproperties
{
     MagCapacity=55
     ReloadRate=2.966000
     bHasSecondaryAmmo=True
     bReduceMagAmmoOnSecondaryFire=False
     Weight=20.000000
     TraderInfoTexture=Texture'DZResPack.Trader_ProfScar'
     FireModeClass(0)=Class'IDRPGMod.SCARPROFBFire'
     FireModeClass(1)=Class'IDRPGMod.SCARPROFLFire'
     Description="A laser rifle. Fires in semi or full auto with great power and accuracy."
     PickupClass=Class'IDRPGMod.SCARPROFPickup'
     AttachmentClass=Class'IDRPGMod.SCARPROFAttachment'
     ItemName="Laser SCAR"
     Skins(0)=Texture'DZResPack.ProfScar2'
}
