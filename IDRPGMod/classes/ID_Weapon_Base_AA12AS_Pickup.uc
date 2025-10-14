//=============================================================================
// AA12 Shotgun Pickup.
//=============================================================================
class ID_Weapon_Base_AA12AS_Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=5000
     AmmoCost=5000
     BuyClipSize=20
     Description="An advanced fully automatic shotgun."
     AmmoItemName="12-gauge drum"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_AA12AS'
     PickupMessage="You got the AA12 auto shotgun."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Shotguns.AA12_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
