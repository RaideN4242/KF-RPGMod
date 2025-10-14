//=============================================================================
// PTurretPickup.
//=============================================================================
class AKFTurretPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     AmmoCost=3000
     BuyClipSize=1
     PowerValue=100
     SpeedValue=10
     RangeValue=25
     Description="Static point defence used by USCM Marines to secure an area."
     ItemName="UA 571-D Sentry Gun"
     ItemShortName="USCM Sentry Gun"
     AmmoItemName="USCM Sentry Turret"
     CorrespondingPerkIndex=2
     EquipmentCategoryID=3
     InventoryType=Class'IDRPGMod.AKFTurret'
     PickupMessage="You got a Sentry Gun."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.akfturret_pickup'
     Skins(0)=Combiner'DZResPack.skin0_cmb'
     Skins(1)=Combiner'DZResPack.skin1_cmb'
     CollisionRadius=22.000000
     CollisionHeight=10.000000
}
