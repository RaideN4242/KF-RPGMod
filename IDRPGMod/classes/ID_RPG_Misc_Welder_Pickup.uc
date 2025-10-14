class ID_RPG_Misc_Welder_Pickup extends KFWeaponPickup;

#exec obj load file="..\StaticMeshes\NewPatchSM.usx"

defaultproperties
{
     Weight=0.000000
     InventoryType=Class'IDRPGMod.ID_RPG_Misc_Welder'
     PickupMessage="You got the Welder."
     PickupSound=Sound'Inf_Weapons_Foley.Misc.AmmoPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.equipment.welder_pickup'
     CollisionHeight=5.000000
}
