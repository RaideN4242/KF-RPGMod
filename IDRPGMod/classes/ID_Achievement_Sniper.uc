class ID_Achievement_Sniper extends ID_RPG_Base_Achievement;

var int HeadShots;
var int HeadShotCount;

static function string GetTitle()
{
	return "'Do" @ default.HeadShotCount @ "headshots in a row'";
}

function Tick(float deltaTime)
{
	if (HeadShots >= HeadShotCount)
	{
		Reached();
		HeadShots = 0;
	}
}

function OnKill(class<ID_RPG_Base_Monster> Monster, class<DamageType> DamageType, bool IsHeadshot)
{   
	if (!IsHeadshot)
		HeadShots = 0;
	else
		HeadShots++;
}

defaultproperties
{
     HeadShotCount=25
     AchievementID=4
     ExpReward="500"
     CashReward=100
}
