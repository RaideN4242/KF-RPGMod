class ID_Achievement_PattyKiller extends ID_Achievement_MonsterKiller_Base;

var int GodModePeriod;

static function string GetReward()
{
	return "God Mode for" @ default.GodModePeriod @ "and" @ class'ID_Achievement_MonsterKiller_Base'.static.GetReward();
}

function Timer()
{
	OwnerController.bGodMode = false;
}

function Tick(float deltaTime)
{
	if (Kills >= KillsCount)
	{
		Reached();
		Kills = 0;
		OwnerController.bGodMode = true;
		setTimer(GodModePeriod, false);
	}
}

defaultproperties
{
     GodModePeriod=50
     MonsterClass=Class'IDRPGMod.ID_Monster_Zombie_Patty'
     ExpReward="6000"
     CashReward=1200
}
