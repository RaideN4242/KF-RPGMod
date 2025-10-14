class ID_Achievement_MonsterKiller_Base extends ID_RPG_Base_Achievement abstract;

var int Kills;
var int KillsCount;
var class<ID_RPG_Base_Monster> MonsterClass;
var bool OnlyThisMonster;

static function string GetTitle()
{
	return "'Kill" @ default.KillsCount @ default.MonsterClass.default.MenuName $ "'";
}

function Tick(float deltaTime)
{
	if (Kills >= KillsCount)
	{
		Reached();
		Kills = 0;
	}
}

function OnKill(class<ID_RPG_Base_Monster> Monster, class<DamageType> DamageType, bool IsHeadshot)
{
	if (ClassIsChildOf(Monster, MonsterClass))
		Kills++;
	else if (OnlyThisMonster)
		Kills=0;
}

defaultproperties
{
     KillsCount=5
     MonsterClass=Class'IDRPGMod.ID_Monster_Zombie_Clot'
     AchievementID=3
}
