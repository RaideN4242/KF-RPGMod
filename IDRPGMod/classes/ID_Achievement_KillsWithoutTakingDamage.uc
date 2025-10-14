class ID_Achievement_KillsWithoutTakingDamage extends ID_RPG_Base_Achievement;

var int Kills;
var int KillsCount;

static function string GetTitle()
{
	return "'Kill" @ default.KillsCount @ "Monsters without taking a damage'";
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

function OnTakeDamage(int BaseDamage, int Damage, class<ID_RPG_Base_Monster> Monster, class<DamageType> damageType)
{
	Kills = 0;
}

defaultproperties
{
     KillsCount=150
     AchievementID=1
     ExpReward="500"
     CashReward=100
}
