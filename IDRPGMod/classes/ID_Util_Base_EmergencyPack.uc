class ID_Util_Base_EmergencyPack extends ID_RPG_Base_Util_WithTimer;

var int AmoutOfUses;
var float MinimumHPPercent;

simulated function Timer()
{
	if (Player.Health < Player.HealthMax * default.MinimumHPPercent)
	{
		Player.Health = Player.HealthMax;
		AmoutOfUses--;
		if (AmoutOfUses == 0)
			Destroy();
	}
}

static function  string GetItemInfo()
{
	return "Restores max hp when hp is lower than" @  default.MinimumHPPercent * 100 $ "%.| Can be used" @ default.AmoutOfUses @ "times" ;
}

defaultproperties
{
     AmoutOfUses=1
     MinimumHPPercent=0.250000
     Interval=0.300000
     PickupClass=Class'IDRPGMod.ID_Util_Base_EmergencyPack_Pickup'
     ItemName="Emergency Pack"
}
