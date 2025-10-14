class ID_Util_Base_Banana extends ID_RPG_Base_Util_WithTimer;

var int HP;

simulated function Timer()
{
	Player.Health += HP;
	if (Player.Health > Player.HealthMax)
		Player.Health = Player.HealthMax;
}

static function  string GetItemInfo()
{
	return "Regenerates" @ default.HP @ "HP every" @ default.Interval @ "seconds";
}

defaultproperties
{
     HP=1
     PickupClass=Class'IDRPGMod.ID_Util_Base_Banana_Pickup'
     ItemName="Banana"
}
