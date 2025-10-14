class AXBowPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=9.000000
     cost=800
     BuyClipSize=10
     PowerValue=64
     SpeedValue=50
     RangeValue=100
     Description="AutoXBow."
     ItemName="AutoXBow"
     ItemShortName="AutoXBow"
     AmmoItemName="AutoXBow Bolts"
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'IDRPGMod.AXBow'
     PickupMessage="You got the AutoXbow."
     PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.AXBowSMesh'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
