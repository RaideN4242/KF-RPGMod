class ID_RPG_Base_Achievement extends Actor abstract;

var ID_RPG_Base_HumanPawn Ownera;
var ID_RPG_Base_PlayerController OwnerController;

var int AchievementId;
var string ExpReward;
var int CashReward;

static function string GetTitle();

static function string GetReward()
{
	return default.ExpReward @ "Exp," @ default.CashReward @ "$";
}

function SetAchievementOwner(ID_RPG_Base_PlayerController Controller)
{
	OwnerController = Controller;
	Ownera = ID_RPG_Base_HumanPawn(OwnerController.Pawn);
}

static function byte GreaterNumericValueOfStrings(string S, string SS)
{
	return class'USB_Commands'.static.GreaterNumericValueOfStrings(S,SS);
}

function Reached()
{
	// NIKE заметка - Выключены уведомления о НАГРАДАХ! BroadcastLocalizedMessage(class'ID_Message_Achievement',,OwnerController.PlayerReplicationInfo,, class);

	if(GreaterNumericValueOfStrings(ExpReward,"0")==1)
		OwnerController.GetStats().AddExperience(ExpReward);
	if(CashReward>0)
		OwnerController.PlayerReplicationInfo.Score += CashReward;
}

function Tick(float deltaTime);
function OnKill(class<ID_RPG_Base_Monster> Monster, class<DamageType> DamageType, bool IsHeadShot);
function OnTakeDamage(int BaseDamage, int Damage, class<ID_RPG_Base_Monster> Monster, class<DamageType> DamageType);
function OnDealDamage(int Damage, class<ID_RPG_Base_Monster> Monster, class<DamageType> DamageType);

defaultproperties
{
     AchievementID=-1
     DrawType=DT_None
}
