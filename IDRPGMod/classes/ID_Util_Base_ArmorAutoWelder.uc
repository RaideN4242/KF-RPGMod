class ID_Util_Base_ArmorAutoWelder extends ID_RPG_Base_Util_WithTimer;

var int Armor;

simulated function Timer()
{
	Player.ShieldStrength += Armor;
	if (Player.ShieldStrength > Player.MaxShieldStrength)
		Player.ShieldStrength = Player.MaxShieldStrength;
}

static function  string GetItemInfo()
{
	return "Regenerates" @ default.Armor @ "Armor Points every" @ default.Interval @ "seconds";
}

defaultproperties
{
     Armor=1
     PickupClass=Class'IDRPGMod.ID_Util_Base_ArmorAutoWelder_Pickup'
     ItemName="Automatic Armor Welder"
}
