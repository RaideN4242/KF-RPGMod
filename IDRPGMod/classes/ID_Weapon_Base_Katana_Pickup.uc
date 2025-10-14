class ID_Weapon_Base_Katana_Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=5000
     Description="An incredibly sharp katana sword."
     //showMesh=SkeletalMesh'KF_Weapons3rd_Trip.Katana_3rd'
     CorrespondingPerkIndex=4
     InventoryType=Class'IDRPGMod.ID_Weapon_Base_Katana'
     PickupMessage="You got the Katana."
     PickupSound=Sound'KF_AxeSnd.Axe_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.melee.Katana_pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
