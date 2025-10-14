class NinjaCrossbowProPickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
//#exec OBJ LOAD FILE=WeaponStaticMesh.usx

defaultproperties
{
     Weight=20.000000
     cost=350000000
     AmmoCost=80
     BuyClipSize=1
     PowerValue=80
     SpeedValue=30
     RangeValue=40
     Description="Ninja Crossbow Pro"
     ItemName="Ninja Crossbow Pro"
     ItemShortName="Ninja Crossbow Pro"
     AmmoItemName="Stars"
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CorrespondingPerkIndex=4
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'IDRPGMod.NinjaCrossbowPro'
     PickupMessage="You got the Ninja Crossbow Pro."
     PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.NinjaCrossbow'
     Skins(0)=Texture'DZResPack.cheetah_dout2'
     Skins(1)=Texture'DZResPack.tex-41476'
     Skins(2)=Texture'DZResPack.Tex_0013_1'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
