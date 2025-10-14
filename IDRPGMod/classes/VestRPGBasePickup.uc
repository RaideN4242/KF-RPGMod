class VestRPGBasePickup extends KFWeaponPickup;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Destroy();
}

defaultproperties
{
     Weight=0.000000
     Description="Kevlar Vest."
     CorrespondingPerkIndex=7
     PickupMessage="You got the Vest."
     PickupSound=None
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'DZResPack.Vest_sm'
     CollisionHeight=5.000000
}
