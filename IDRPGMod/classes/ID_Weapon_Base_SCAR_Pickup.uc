//=============================================================================
// AK47 Pickup.
//=============================================================================
class ID_Weapon_Base_SCAR_Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=5000
     AmmoCost=5000
     BuyClipSize=20
     Description="Advanced tactical assault rifle. Equipped with an aimpoint sight."
     AmmoItemName="7.62x51mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_SCAR'
     PickupMessage="You got the SCARMK17"
     PickupSound=Sound'KF_SCARSnd.SCAR_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Rifles.SCAR_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
