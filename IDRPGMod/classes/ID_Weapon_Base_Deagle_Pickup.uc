//=============================================================================
// Deagle Pickup.
//=============================================================================
class ID_Weapon_Base_Deagle_Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=5000
     AmmoCost=5000
     BuyClipSize=7
     Description="50 Cal AE handgun. A powerful personal choice for personal defense."
     AmmoItemName=".300 JHP Ammo"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=1
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_Deagle'
     PickupMessage="You got the Handcannon"
     PickupSound=Sound'KF_HandcannonSnd.50AE_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.pistol.deagle_pickup'
     CollisionHeight=5.000000
}
