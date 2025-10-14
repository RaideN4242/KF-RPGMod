class KFARGBuchonOPQGR extends GameRules;

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
	local Inventory I;
	local KFWeaponPickup weaponPickup;
	local string txtToSay;

	weaponPickup=KFWeaponPickup(item);

	if(weaponPickup!=None)
	{
		I=Other.FindInventoryType(weaponPickup.InventoryType);

		if(I==None)
		{
			//txtToSay  = "@?@";// believe or not, this is a colour.
			txtToSay$=Repl(class'ID_RPG_Mutator'.default.StringReplace,"%KFARGWeapon%"," "$weaponPickup.ItemName$" ");
			txtToSay=Repl(txtToSay,"%KFARGPlayerName%"," "$Other.GetHumanReadableName()$" ");
			Level.Game.Broadcast(None,txtToSay);
		}
	}

	return Super.OverridePickupQuery(Other,item,bAllowPickup);
}

defaultproperties
{
}
