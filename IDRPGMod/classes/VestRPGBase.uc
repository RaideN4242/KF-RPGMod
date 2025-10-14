class VestRPGBase extends ID_RPG_Base_Weapon;

var int ArmorPlateStrength;
var ActorVestRPG AV;
var ID_RPG_Base_HumanPawn Player;
var bool bRemoved;

simulated function Weapon WeaponChange(byte F, bool bSilent)
{
	if(Inventory == None)
		return None;
	else return Inventory.WeaponChange(F,bSilent);
}

function GiveTo(pawn Other, optional Pickup Pickup)
{
	if(Role==ROLE_Authority)
	{
		ModifyPlayer(Other);
	}
	Super.GiveTo(Other, Pickup);
	Player = ID_RPG_Base_HumanPawn(Other);
	AddUtilEffects(ID_RPG_Base_HumanPawn(Other));
}

function ModifyPlayer(Pawn Other)
{
	local xPawn ThePawn;
//	local string SkelName, MeshName;

	if(xPawn(Other) != None)
	{
		ThePawn = xPawn(Other);
//		SkelName = ThePawn.Species.static.GetRagSkelName(ThePawn.GetMeshName());
//		MeshName = string(ThePawn.Mesh);

		AV = Other.Spawn(class'ActorVestRPG',Other,,Other.Location,rot(0,0,0));
		//ThePawn.AttachToBone(AV,'Spine');
		ThePawn.AttachToBone(AV,'CHR_Spine2');
		AV.SetRelativeLocation(vect(7,-2,0));
		//AV.SetRelativeRotation(rot(-16384,0,0));
	}
}

function AddUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	Pawn.MaxShieldStrength += ArmorPlateStrength;
	Pawn.ShieldStrength += ArmorPlateStrength;
	Pawn.HealthMax += ArmorPlateStrength;
	Pawn.Health += ArmorPlateStrength;
}

function RemoveUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
//	log("REMOVE VEST");

	if(bRemoved || Role!=ROLE_Authority)
		return;

		Pawn.MaxShieldStrength -= ArmorPlateStrength;
		if (Pawn.ShieldStrength > Pawn.MaxShieldStrength)
			Pawn.ShieldStrength = Pawn.MaxShieldStrength;
		if(Pawn.HealthMax<=ArmorPlateStrength)
		{
			Pawn.HealthMax=1;
		}
		else
		{
			Pawn.HealthMax -= ArmorPlateStrength;
		}
		if (Pawn.Health > Pawn.HealthMax)
			Pawn.Health = Pawn.HealthMax;

	bRemoved=true;
}

simulated function Destroyed()
{
	super.Destroyed();

	if(AV!=none)
		AV.Destroy();

	if(Role==ROLE_Authority)
		RemoveUtilEffects(Player);
}

function DropFrom(vector StartLocation)
{
	local int m;

	if(!bCanThrow)
		return;

	if(AV!=None)
		AV.Destroy();

	ClientWeaponThrown();

	for(m=0; m<NUM_FIRE_MODES; m++)
	{
		if (FireMode[m].bIsFiring)
			StopFire(m);
	}

	if(Instigator != None)
	{
		DetachFromPawn(Instigator);
	}

	Destroyed();
	Destroy();
}

defaultproperties
{
     MagCapacity=1
     HudImage=Texture'DZResPack.VestRPG_Trader'
     SelectedHudImage=Texture'DZResPack.VestRPG_Trader'
     Weight=0.000000
     bKFNeverThrow=True
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'DZResPack.VestRPG_Trader'
     HudImageRef="DZResPack.VestRPG_Trader"
     SelectedHudImageRef="DZResPack.VestRPG_Trader"
     FireModeClass(0)=Class'KFMod.NoFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     AIRating=0.200000
     CurrentRating=0.200000
     Description="Kevlar Vest"
     DisplayFOV=75.000000
     Priority=45
     InventoryGroup=5
     GroupOffset=2
     BobDamping=8.000000
     AttachmentClass=Class'IDRPGMod.VestRPGAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
}
