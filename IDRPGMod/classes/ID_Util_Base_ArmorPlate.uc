class ID_Util_Base_ArmorPlate extends ID_RPG_Base_Util;

var int ArmorPlateStrength;

function AddUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	Pawn.MaxShieldStrength += ArmorPlateStrength;
	Pawn.ShieldStrength += ArmorPlateStrength;
}

static function  string GetItemInfo()
{
	return "Adds additional" @ default.ArmorPlateStrength @ "armor points";
}

function RemoveUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	Pawn.MaxShieldStrength -= ArmorPlateStrength;
	if (Pawn.ShieldStrength > Pawn.MaxShieldStrength)
		Pawn.ShieldStrength = Pawn.MaxShieldStrength;
}

defaultproperties
{
     ArmorPlateStrength=25
     PickupClass=Class'IDRPGMod.ID_Util_Base_ArmorPlate_Pickup'
     ItemName="Addtional Armor plate"
}
