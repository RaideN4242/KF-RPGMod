class PatGunPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=15.000000
     cost=8000
     AmmoCost=100
     BuyClipSize=300
     PowerValue=100
     SpeedValue=100
     RangeValue=100
     Description="The Patriarch's gun."
     ItemName="Patriarch Chaingun"
     ItemShortName="Patty Gun"
     AmmoItemName="Pat Gun Bullets"
     AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'IDRPGMod.PatGun'
     PickupMessage="You got the Patriarch's chaingun."
     PickupSound=Sound'KF_HuskGunSnd.foley.Husk_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'kf_gore_trip_sm.limbs.Patriarch_Gun_Arm_Resource'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
