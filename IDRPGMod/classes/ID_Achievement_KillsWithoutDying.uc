class ID_Achievement_KillsWithoutDying extends ID_RPG_Base_Achievement;

var int Kills;
var int KillsCount;

static function string GetTitle()
{
	return "'Kill" @ default.KillsCount @ "Monsters without dying'";
}

function Tick(float deltaTime)
{
	if (Kills >= KillsCount)
	{
		Reached();
		Kills = 0;
	}
}

function OnKill(class<ID_RPG_Base_Monster> Monster, class<DamageType> damageType, bool IsHeadshot)
{
	Kills++;
}

defaultproperties
{
     KillsCount=800
     AchievementID=2
     ExpReward="1500"
     CashReward=300
}
