class ID_Achievement_KillsInTime extends ID_RPG_Base_Achievement;

var int Period;
var int KillsCount;

var array<float> Kills;


static function string GetTitle()
{
	return "'Kill" @ default.KillsCount @ "Monsters in" @ default.Period @ "seconds'";
}

function Tick(float deltaTime)
{
	local int i;
	//remove old Kills
	for (i = Kills.length - 1; i >= 0; i--)
	{
		if (Kills[i] < Level.TimeSeconds - Period)
		{
			Kills.Remove(i, 1);
			//log("removed exprired kill");
		}
	}
	//check achievement
	if (Kills.length >= KillsCount)
	{
		Reached();
		Kills.Remove(0, Kills.length);
	}
}

function OnKill(class<ID_RPG_Base_Monster> Monster, class<DamageType> DamageType, bool IsHeadshot)
{
	Kills[Kills.length] = Level.TimeSeconds;
}

defaultproperties
{
     Period=5
     KillsCount=20
     AchievementID=0
     ExpReward="1000"
     CashReward=200
}
