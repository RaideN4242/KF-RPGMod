//=============================================================================
// M14EBR Pickup.
//=============================================================================
class ID_Weapon_Base_M14EBR_Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=5000
     AmmoCost=5000
     BuyClipSize=20
     Description="Updated M14 Enhanced Battle Rifle - Semi Auto variant. Equipped with a laser sight."
     AmmoItemName="7.62x51mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=2
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_M14EBR'
     PickupMessage="You got the M14 EBR"
     PickupSound=Sound'KF_M14EBRSnd.M14EBR_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Rifles.M14_EBR_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
