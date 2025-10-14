class ID_RPG_Base_Util extends Inventory;

var bool DestroyAfterAddingEffect;
var int SellValue;
var ID_RPG_Base_HumanPawn Player;

replication
{
	reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		DestroyAfterAddingEffect, SellValue;
}

function GiveTo( pawn Other, optional Pickup Pickup )
{
	Instigator = Other;
	Player = ID_RPG_Base_HumanPawn(Other);
	if ( Other.AddInventory( Self ) )
	{
		AddUtilEffects(ID_RPG_Base_HumanPawn(Other));
	}
	if (DestroyAfterAddingEffect)
		Destroy();
}

function AddUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	
}

function RemoveUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	
}

event Destroyed(){
	super.Destroyed();
	RemoveUtilEffects(Player);
}

simulated function DrawHud(Canvas C, int index, int X, int Y)
{
	C.DrawText(index $ ":" @ ItemName);
}

static function  string GetItemInfo()
{
	return "CHANGE ME!";
}

defaultproperties
{
     PickupClass=Class'IDRPGMod.ID_RPG_Base_Util_Pickup'
     ItemName="Change me!"
}
