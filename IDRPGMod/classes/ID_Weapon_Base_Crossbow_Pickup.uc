class ID_Weapon_Base_Crossbow_Pickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=KillingFloorWeapons.utx

defaultproperties
{
     cost=5000
     BuyClipSize=6
     Description="Recreational hunting weapon, equipped with powerful scope and firing trigger. Exceptional headshot damage."
     AmmoItemName="Crossbow Bolts"
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_Crossbow'
     PickupMessage="You got the Xbow."
     PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.Rifle.crossbow_pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
