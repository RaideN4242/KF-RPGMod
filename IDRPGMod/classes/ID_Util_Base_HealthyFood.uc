class ID_Util_Base_HealthyFood extends ID_RPG_Base_Util;

var int AdditionalHP;

function AddUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	Pawn.HealthMax += AdditionalHP;
	Pawn.Health += AdditionalHP;
	log("ADD HP"@Pawn.Health@"/"@Pawn.HealthMax@"+"@AdditionalHP);
}

static function  string GetItemInfo()
{
	return "Adds additional" @ default.AdditionalHP @ "HP";
}

function RemoveUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	if(Pawn.HealthMax<=AdditionalHP)
	{
		Pawn.HealthMax=1;
	}
	else
	{
		Pawn.HealthMax -= AdditionalHP;
	}
	if (Pawn.Health > Pawn.HealthMax)
		Pawn.Health = Pawn.HealthMax;
		
	log("REMOVE HP"@Pawn.Health@"/"@Pawn.HealthMax@"-"@AdditionalHP);
}

defaultproperties
{
     AdditionalHP=25
     PickupClass=Class'IDRPGMod.ID_Util_Base_HealthyFood_Pickup'
     ItemName="Healthy Food"
}
