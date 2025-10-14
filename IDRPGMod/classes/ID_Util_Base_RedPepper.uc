class ID_Util_Base_RedPepper extends ID_RPG_Base_Util;

var float AdditionalSpeed;

static function  string GetItemInfo()
{
	return "Adds additional" @ int(default.AdditionalSpeed * 100) $ "% to movement speed.|Just put it in your panties :)";
}

defaultproperties
{
     AdditionalSpeed=0.050000
     PickupClass=Class'IDRPGMod.ID_Util_Base_RedPepper_Pickup'
     ItemName="Red Pepper"
}
