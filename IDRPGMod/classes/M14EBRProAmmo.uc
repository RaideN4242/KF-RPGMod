//=============================================================================
// M14EBR Ammo.
//=============================================================================
class M14EBRProAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     MaxAmmo=9999
     InitialAmount=9999
     PickupClass=Class'KFMod.M14EBRAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="M14EBR bullets"
}
