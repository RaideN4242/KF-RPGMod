//=============================================================================
// SCARMK17 Ammo.
//=============================================================================
class ID_Weapon_Base_P416_Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     AmmoPickupAmount=30
     MaxAmmo=330
     InitialAmount=130
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="P416 bullets"
}
