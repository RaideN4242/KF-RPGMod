class ID_RPG_Base_Util_Pickup extends Pickup;

var int Cost;
var class<ID_RPG_Base_Util> UtilItemClass;
var class<Pickup> BasePickupClass;
var bool Sellable;

defaultproperties
{
     cost=5000
     UtilItemClass=Class'IDRPGMod.ID_RPG_Base_Util'
     Sellable=True
}
