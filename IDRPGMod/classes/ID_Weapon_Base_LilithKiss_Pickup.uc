//=============================================================================
// Lilith's Kisses Pickup:
// Happy Valentine's Day!
//=============================================================================
class ID_Weapon_Base_LilithKiss_Pickup extends KFWeaponPickup;

function ShowDualiesInfo(Canvas C)
{
	C.SetPos((C.SizeX - C.SizeY) / 2,0);
	C.DrawTile( Texture'KillingfloorHUD.ClassMenu.Dualies', C.SizeY, C.SizeY, 0.0, 0.0, 256, 256);
}

defaultproperties
{
     Weight=13.000000
     cost=4500
     BuyClipSize=60
     PowerValue=75
     SpeedValue=80
     RangeValue=45
     Description="Specially modified automatic shotguns, given as a gift for Valentine's Day."
     ItemName="Lilith's Kisses"
     ItemShortName="Lilith's Kisses"
     AmmoItemName="12-Gauge Shells"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     CorrespondingPerkIndex=1
     EquipmentCategoryID=1
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_LilithKiss'
     PickupMessage="You found Lilith's Kisses."
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.lilith_pickup'
     CollisionHeight=5.000000
}
