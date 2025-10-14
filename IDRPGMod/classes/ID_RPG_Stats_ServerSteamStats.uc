Class ID_RPG_Stats_ServerSteamStats extends KFSteamStatsAndAchievements;

var ID_RPG_Stats_ReplicationLink Rep;
var ID_RPG_Stats_Object MyID_RPG_Stats_Object;
var KFPlayerController PlayerOwner;
var ID_RPG_Mutator MutatorOwner;
var bool bHasChanged,bStatsChecking,bStHasInit,bHadSwitchedVet,bSwitchIsOKNow,bStatsReadyNow;

var class<ID_RPG_Stats_Veterancy> SelectingPerk;

final function int GetID()
{
	if(MyID_RPG_Stats_Object==none)
	{
		return 0;
	}

	return MyID_RPG_Stats_Object.ID;
}
final function SetID(int ID)
{
	if(MyID_RPG_Stats_Object!=none)
	{
		MyID_RPG_Stats_Object.ID=ID;
	}
}

function PreBeginPlay()
{
	if( Rep==None )
	{
		Rep = Spawn(Class'ID_RPG_Stats_ReplicationLink',Owner);
		Rep.StatObject = Self;
	}
	Super.PreBeginPlay();
}
function PostBeginPlay()
{
	local Class<ID_RPG_Stats_Veterancy> Vet;

	bStatsReadyNow = !MutatorOwner.bUseRemoteDatabase;
	PlayerOwner = KFPlayerController(Owner);
	MyID_RPG_Stats_Object = MutatorOwner.GetStatsForPlayer(PlayerOwner);
	KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).ClientVeteranSkill = class'ID_RPG_Stats_Veterancy';;
	if( !bStatsReadyNow )
	{
		Timer();
		SetTimer(1+FRand(),true);
		return;
	}
	bSwitchIsOKNow = true;
	if( MyID_RPG_Stats_Object!=None )
	{
		RepCopyStats();
		bHasChanged = true;
		CheckPerks(true);
		Vet = Class'ID_RPG_Stats_Veterancy';
		if( Vet!=None )
			ServerSelectPerk(Vet);
	}
	else CheckPerks(true);
	if( MutatorOwner.bForceGivePerk && KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).ClientVeteranSkill==None )
		ServerSelectPerk(Rep.PickRandomPerk());
	bSwitchIsOKNow = false;
	SetTimer(0.1,false);
}
final function GetData( string D )
{
	local Class<ID_RPG_Stats_Veterancy> Vet;

	bStatsReadyNow = true;
	MyID_RPG_Stats_Object.SetSaveData(D);
	RepCopyStats();
	bHasChanged = true;
	bSwitchIsOKNow = true;

	CheckPerks(true);
	Vet = Class'ID_RPG_Stats_Veterancy';
	if( Vet!=None )
		ServerSelectPerk(Vet);
	Rep.SendClientPerks();
	if( MutatorOwner.bForceGivePerk && KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).ClientVeteranSkill==None )
		ServerSelectPerk(Rep.PickRandomPerk());
	bSwitchIsOKNow = false;
	SetTimer(0.1,false);
}
function Timer()
{
	if( !bStatsReadyNow )
	{
		MutatorOwner.GetRemoteStatsForPlayer(Self);
		return;
	}
	if( !bStHasInit )
	{
		if( PlayerOwner.SteamStatsAndAchievements!=None && PlayerOwner.SteamStatsAndAchievements!=Self )
			PlayerOwner.SteamStatsAndAchievements.Destroy();
		PlayerOwner.SteamStatsAndAchievements = Self;
		PlayerOwner.PlayerReplicationInfo.SteamStatsAndAchievements = Self;
		bStHasInit = true;
		Rep.SendClientPerks();
	}
	if( bStatsChecking )
	{
		bStatsChecking = false;
		CheckPerks(false);
	}
}
final function RepCopyStats()
{
	local int i;
	Rep.Experience=GetNumericStringValueFromString(MyID_RPG_Stats_Object.Experience);
	for(i=0;i<ArrayCount(MyID_RPG_Stats_Object.Skills);i++)
		Rep.Skills[i]=MyID_RPG_Stats_Object.Skills[i];
}
final function ServerSelectPerk( Class<ID_RPG_Stats_Veterancy> VetType )
{
	if( KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).ClientVeteranSkill==VetType )
	{
		if( SelectingPerk!=None )
		{
			SelectingPerk = None;
			PlayerOwner.ClientMessage("You will remain the same perk now.");
		}
		return;
	}
}

final function CheckPerks( bool bInit )
{
	if( !bStatsReadyNow )
		return;
}
final function DelayedStatCheck()
{
	if( MyID_RPG_Stats_Object!=None )
		MyID_RPG_Stats_Object.bStatsChanged = true;
	if( bStatsChecking || !bStatsReadyNow )
		return;
	bStatsChecking = true;
	SetTimer(1,false);
}

static function byte GreaterNumericValueOfStrings(string S, string SS)
{
	return class'USB_Commands'.static.GreaterNumericValueOfStrings(S,SS);
}

static function string AddNumericValuesFromStrings(string S, string SS)
{
	return class'USB_Commands'.static.AddNumericValuesFromStrings(S,SS);
}

static function string SubtractNumericValuesFromStrings(string S, string SS)
{
	return class'USB_Commands'.static.SubtractNumericValuesFromStrings(S,SS);
}

static function int GetNumericValueFromString(string S)
{
	return class'USB_Commands'.static.GetNumericValueFromString(S);
}

static function string GetNumericStringValueFromString(string S)
{
	return class'USB_Commands'.static.GetNumericStringValueFromString(S);
}

function AddExperience(string Amount)
{   
	local string MaxExp;
	MaxExp="9950000000000";
	bHasChanged=true;

	if(/*Rep.Experience+Amount<0 || */GreaterNumericValueOfStrings(Rep.Experience,MaxExp)<=1) 
		Rep.Experience=MaxExp;
	else
		Rep.Experience=AddNumericValuesFromStrings(Rep.Experience,Amount);
	if(MyID_RPG_Stats_Object!=None)
		MyID_RPG_Stats_Object.Experience=Rep.Experience;

	SRPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).CurExp=Rep.Experience;
	DelayedStatCheck();
}

function BuySkill( class<ID_RPG_Base_Skill> Skill)
{
	local string price;

	price = Skill.static.GetNextLevelPrice(Rep);

	if(GreaterNumericValueOfStrings(price,Rep.Experience)==1)
		return;

	//if(Rep.Skills[Skill.default.SkillIndex]>=Skill.default.MaxLevel)
	//	return;

	bHasChanged=true;
	Rep.Experience=SubtractNumericValuesFromStrings(Rep.Experience,price);
	Rep.Skills[Skill.default.SkillIndex]++;
	if(MyID_RPG_Stats_Object!=None)
	{
		MyID_RPG_Stats_Object.Experience=SubtractNumericValuesFromStrings(MyID_RPG_Stats_Object.Experience,price);
		MyID_RPG_Stats_Object.Skills[Skill.default.SkillIndex]++;
	}

	SRPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).CurExp=Rep.Experience;
	DelayedStatCheck();
	//log("Bought:" @ Skill);
}


function MatchEnded();
function AddDamageHealed(int Amount, optional bool bMP7MHeal, optional bool bMP5MHeal);
function AddWeldingPoints(int Amount);
function AddShotgunDamage(int Amount);
function AddHeadshotKill(bool bLaserSightedEBRHeadshot);
function AddStalkerKill();
function AddBullpupDamage(int Amount);
function AddMeleeDamage(int Amount);
function AddFlameThrowerDamage(int Amount);
function WaveEnded()
{
	if( SelectingPerk!=None )
	{
		bHadSwitchedVet = false;
		bSwitchIsOKNow = true;
		ServerSelectPerk(SelectingPerk);
		bSwitchIsOKNow = false;
	}
}
function AddKill(bool bLaserSightedEBRM14Headshotted, bool bMeleeKill, bool bZEDTimeActive, bool bM4Kill, bool bBenelliKill, bool bRevolverKill, bool bMK23Kill, bool bFNFalKill, bool bBullpupKill, string MapName);
function AddBloatKill(bool bWithBullpup);
function AddSirenKill(bool bLawRocketImpact);
function AddStalkerKillWithExplosives();
function AddFireAxeKill();
function AddChainsawScrakeKill();
function AddBurningCrossbowKill();
function AddFeedingKill();
function OnGrenadeExploded();
function AddGrenadeKill();
function OnShotHuntingShotgun();
function AddHuntingShotgunKill();
function KilledEnemyWithBloatAcid();
function KilledFleshpound(bool bWithMeleeAttack, bool bWithAA12, bool bWithKnife, bool bWithClaymore);
function AddMedicKnifeKill();
function AddGibKill(bool bWithM79);
function AddFleshpoundGibKill();
function AddSelfHeal();
function AddOnlySurvivorOfWave();

function AddDonatedCash(int Amount);
function AddZedTime(float Amount);
function AddExplosivesDamage(int Amount);
function WonLostGame( bool bDidWin )
{
	bHasChanged = true;
	DelayedStatCheck();
	GoToState('');
}
function KilledPatriarch(bool bPatriarchHealed, bool bKilledWithLAW, bool bSuicidalDifficulty, bool bOnlyUsedCrossbows, bool bClaymore, string MapName);
// Allow no default functionality with the stats.
function OnStatsAndAchievementsReady();
function PostNetBeginPlay();
function InitializeSteamStatInt(int Index, int Value);
function SetSteamAchievementCompleted(int Index);
event SetLocalAchievementCompleted(int Index);
function ServerSteamStatsAndAchievementsInitialized();
function UpdateAchievementProgress();
function int GetAchievementCompletedCount();
event OnPerkAvailable();
function WonLongGame(string MapName, float Difficulty);
function AddDemolitionsPipebombKill();
function AddSCARKill();
function AddCrawlerKilledInMidair();
function Killed8ZedsWithGrenade();
function Killed10ZedsWithPipebomb();
function KilledHusk(bool bDamagedFriendly);
function AddMac10BurnDamage(int Amount);
function AddGorefastBackstab();
function ScrakeKilledByFire();
function KilledCrawlerWithCrossbow();
function OnLARReloaded();
function AddStalkerKillWithLAR();
function KilledHuskWithPistol();
function AddDroppedTier3Weapon();
function Survived10SecondsAfterVomit();
function CheckChristmasAchievementsCompleted();

function Destroyed()
{
	if( Rep!=None )
	{
		Rep.Destroy();
		Rep = None;
	}
	if( PlayerOwner!=None && !PlayerOwner.bDeleteMe )
	{
		// Was destroyed mid-game for random reason, respawn.
		MutatorOwner.PendingPlayers[MutatorOwner.PendingPlayers.Length] = PlayerOwner;
		MutatorOwner.SetTimer(0.1,false);
	}
	Super.Destroyed();
}

defaultproperties
{
     bInitialized=True
     bUsedCheats=True
     RemoteRole=ROLE_None
     bNetNotify=False
}
