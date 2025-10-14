class ID_RPG_Base_Util_WithTimer extends ID_RPG_Base_Util;

var float Interval;
var bool Repeatable;

function AddUtilEffects(ID_RPG_Base_HumanPawn Pawn)
{
	SetTimer(Interval, Repeatable);
}

defaultproperties
{
     Interval=5.000000
     Repeatable=True
}
