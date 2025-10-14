class ID_RPG_Base_PlayerController extends KFPlayerController;

var array<GUIBuyable> AllocatedObjects;//To prevent memory leaks in trader.
var array<ID_RPG_Base_Achievement> Achievements;
var array< class<ID_RPG_Base_Achievement> > AchievementClasses;
var float LastMessage_Turret;

replication
{
	reliable if(Role<ROLE_Authority)
		BuySkill, VoteZLVL, AddVoteZLVL, LastMessage_Turret;
}

static function byte GreaterNumericValueOfStrings(string S, string SS)
{
	return class'USB_Commands'.static.GreaterNumericValueOfStrings(S,SS);
}

exec function Admin(string CommandLine)
{
	if(Left(CommandLine,4)~="set ")
	{
		return;
	}

	Super.Admin(CommandLine);
}

function ServerUse()
{
	local array<ID_Weapon_Base_Turret_Sentry_Base> USTDGTTurrets;
	local ID_Weapon_Base_Turret_Sentry_Base USTDGTTurret,CorrectUSTDGTTurret;
	local float CurrentDot, MaxDot;
	local int i;

	Super.ServerUse();

	if(Pawn==none)
	{
		return;
	}

	foreach Pawn.VisibleCollidingActors(class'ID_Weapon_Base_Turret_Sentry_Base', USTDGTTurret, 128, Pawn.Location)
	{
		if(((USTDGTTurret.Location-Pawn.Location) Dot vector(Pawn.Rotation))>0)
		{
			USTDGTTurrets[USTDGTTurrets.Length]=USTDGTTurret;
		}
	}

	for(i=0; i<USTDGTTurrets.Length; i++)
	{
		USTDGTTurret=USTDGTTurrets[i];

		if(USTDGTTurret==none)
		{
			continue;
		}

		CurrentDot=((USTDGTTurret.Location-Pawn.Location) Dot vector(Pawn.Rotation))/VSize(USTDGTTurret.Location-Pawn.Location);

		if(CurrentDot>MaxDot)
		{
			CorrectUSTDGTTurret=USTDGTTurret;
			MaxDot=CurrentDot;
		}
	}

	if(CorrectUSTDGTTurret!=none)
	{
		CorrectUSTDGTTurret.UsedBy(Pawn);
	}
}

event PlayerTick(float DeltaTime)
{
	local ID_Weapon_Base_Turret_Sentry_Base USTDGTTurret;

	Super.PlayerTick(DeltaTime);

	if(Pawn!=none && Level.TimeSeconds>=LastMessage_Turret+0.5)
	{
		foreach Pawn.VisibleCollidingActors(class'ID_Weapon_Base_Turret_Sentry_Base', USTDGTTurret, 128, Pawn.Location)
		{
			if(((USTDGTTurret.Location-Pawn.Location) Dot vector(Pawn.Rotation))>0)
			{
				if(USTDGTTurret.ShowSpecialMessage(Self,3))
				{
					LastMessage_Turret=Level.TimeSeconds;
					break;
				}
			}
		}
	}
}

function VoteZLVL(int vlvl)
{
	if(Role==ROLE_Authority)
		ID_RPG_Base_GameType(Level.Game).StartZLVote(Self, vlvl);
}

function AddVoteZLVL(bool b)
{
	if(Role==ROLE_Authority && !SRPlayerReplicationInfo(PlayerReplicationInfo).bVoted)
	{
		ID_RPG_Base_GameType(Level.Game).AddZLVote(Self, b);
	}
}

event TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type)
{
	local array<string>AS;

	super.TeamMessage(PRI, S, Type);

	if(Level.NetMode==NM_DedicatedServer || GameReplicationInfo==None || Len(S)==0)
		return;

	if(PRI!=None && PRI.PlayerName~=Level.GetLocalPlayerController().PlayerReplicationInfo.PlayerName && ((string(Type)~="say") || (string(Type)~="sayteam") || (string(Type)~="teamsay")))
	{
		AS=MySplit(S," ",false);
		if(S~="!rtv50")
			VoteZLVL(50);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
		
		AS=MySplit(S," ",false);
		if(S~="!rtv100")
			VoteZLVL(100);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
	
		AS=MySplit(S," ",false);
		if(S~="!rtv500")
			VoteZLVL(500);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);		
		
		AS=MySplit(S," ",false);
		if(S~="!rtv1000")
			VoteZLVL(1000);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
					
		AS=MySplit(S," ",false);
		if(S~="!rtv2000")
			VoteZLVL(2000);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
						
		AS=MySplit(S," ",false);
		if(S~="!rtv3000")
			VoteZLVL(3000);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
							
		AS=MySplit(S," ",false);
		if(S~="!rtv8000")
			VoteZLVL(8000);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
							
		AS=MySplit(S," ",false);
		if(S~="!rtv19995559991")
			VoteZLVL(1000000);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
							
		AS=MySplit(S," ",false);
		if(S~="!rtv19996669991")
			VoteZLVL(100000000);
		else if(S=="!y")
			AddVoteZLVL(true);
		else if(S=="!n")
			AddVoteZLVL(false);
			
	}
}

function array<string>MySplit(string str, string div, bool bDiv)
{
	local array<string>temp;
	local bool bEOL;
	local string tempChar;
	local int precount, curcount, wordcount, strLength;
	strLength=len(str);
	bEOL=false;
	precount=0;
	curcount=0;
	wordcount=0;
 
	while(!bEOL)
	{
		tempChar=Mid(str, curcount, 1);//go up by 1 count
		if(tempChar!=div)
			curcount++;
		else if(tempChar==div)
		{
			temp[wordcount]=Mid(str, precount, curcount-precount);
			wordcount++;
			if(bDiv)
				precount=curcount;//leaves the divider
			else
				precount=curcount+1;//removes the divider.
			curcount++;
		}
		if(curcount==strLength)//end of string, flush out the final word.
		{
			temp[wordcount]=Mid(str, precount, curcount);
			bEOL=true;
		}
	}
	return temp;
}

simulated function PostBeginPlay()
{
	local ID_RPG_Base_Achievement Achievement;
	local int i;

	super.PostBeginPlay();

	if(Role==ROLE_Authority)
	{
		if(Achievements.length==0)
		{
			for(i=0; i<AchievementClasses.length; i++)
			{
				Achievement=Spawn(AchievementClasses[i]);
				Achievement.SetAchievementOwner(self);
				Achievements[Achievements.length]=Achievement;
				log("Created:" @ Achievement);
			}
		}
	}
}

function ID_RPG_Stats_ServerSteamStats GetStats()
{
	return ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements);
}

function ID_RPG_Stats_ReplicationLink getRepLink()
{
	if(SteamStatsAndAchievements!=none && ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements).Rep!=none)
		return ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements).Rep;
	else
		return class'ID_RPG_Stats_ReplicationLink'.static.FindStats(self);
}

function SetPawnClass(string inClass, string inCharacter)
{
	PawnClass=Class'ID_RPG_Base_HumanPawn';
	inCharacter=Class'KFGameType'.Static.GetValidCharacter(inCharacter);
	PawnSetupRecord=class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

function SendSelectedVeterancyToServer(optional bool bForceChange)
{
	//log("SendSelectedVeterancyToServer");
	if(Level.NetMode!=NM_Client && ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements)!=none)
		ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements).WaveEnded();
}

function SelectVeterancy(class<KFVeterancyTypes>VetSkill, optional bool bForceChange)
{
	//log("SelectVeterancy");
	if(ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements)!=none)
		ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements).ServerSelectPerk(Class<ID_RPG_Stats_Veterancy>(VetSkill));
}

//Allow clients fix the behindview bug themself
exec function BehindView(Bool B)
{
	if(Vehicle(Pawn)==None || Vehicle(Pawn).bAllowViewChange)//Allow vehicles to limit view changes
	{
		ClientSetBehindView(B);
		bBehindView=B;
	}
}

exec function ToggleBehindView()
{
	ServerToggleBehindview();
}

function ServerToggleBehindview()
{
	local bool B;

	if(Vehicle(Pawn)==None || Vehicle(Pawn).bAllowViewChange)
	{
		B=!bBehindView;
		ClientSetBehindView(B);
		bBehindView=B;
	}
}

function ShowBuyMenu(string wlTag,float maxweight)
{
	StopForceFeedback();
	ClientOpenMenu(string(Class'ID_GUI_Menu_Buy'),,wlTag,string(maxweight));
	log("Opened menu");
}

simulated function ServerBuySkill(class<ID_RPG_Base_Skill>Skill)
{
	BuySkill(Skill);
}

function BuySkill(class<ID_RPG_Base_Skill>Skill)
{
	//log("Buying:" @ Skill);
	if(ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements)!=none)
	{
		ID_RPG_Stats_ServerSteamStats(SteamStatsAndAchievements).BuySkill(Skill);

		if(ID_RPG_Base_HumanPawn(Pawn)!=none)
		{
			ID_RPG_Base_HumanPawn(Pawn).SkillBought();
		}
	}
}

//////////////////////////////////////// 
/*
заменяем содержание TeamSay на содержание Say
Теперь и T и Y идентичны по свойствам своим и все зрители могут читать текст. Не важно T или Y нажата
*/
exec function TeamSay(string Msg)
{
Msg = Left(Msg,128);

if ( AllowTextMessage(Msg) )
ServerSay(Msg);
}
////////////////////////////////////////


simulated final function ResetItem(GUIBuyable Item)
{
	Item.ItemName="";
	Item.ItemDescription="";
	Item.ItemCategorie="";
	Item.ItemImage=None;
	Item.ItemWeaponClass=None;
	Item.ItemAmmoClass=None;
	Item.ItemPickupClass=None;
	Item.ItemCost=0;
	Item.ItemAmmoCost=0;
	Item.ItemFillAmmoCost=0;
	Item.ItemWeight=0;
	Item.ItemPower=0;
	Item.ItemRange=0;
	Item.ItemSpeed=0;
	Item.ItemAmmoCurrent=0;
	Item.ItemAmmoMax=0;
	Item.bSaleList=false;
	Item.bSellable=false;
	Item.bMelee=false;
	Item.bIsVest=false;
	Item.bIsFirstAidKit=false;
	Item.ItemPerkIndex=0;
	Item.ItemSellValue=0;
}

function ServerReStartPlayer()
{
	//log("Controller-ServerReStartPlayer");
	ClientCloseMenu(true, true);

	if(Level.Game.bWaitingToStartMatch)
		PlayerReplicationInfo.bReadyToPlay=true;
	else Level.Game.RestartPlayer(self);
	
	//log("PlayerReplicationInfo.bReadyToPlay:" @ PlayerReplicationInfo.bReadyToPlay);
}

function AddExperienceGainedMessage(string Experience, Vector Location)
{
	local ID_HUD_DrawableActor_Experience ExpActor;
	Location.Y+=-40+Rand(80);
	Location.X+=-40+Rand(80);
	if(GreaterNumericValueOfStrings(Experience,"0")==2)
		return;
	ExpActor=Spawn(class'ID_HUD_DrawableActor_Experience',,, Location);
	ExpActor.Experience=Experience;
	ExpActor.Controller=self;
}

function AddCashGainedMessage(int Cash, Vector Location)
{
	local ID_HUD_DrawableActor_Cash CashActor;
	Location.Y+=-40+Rand(80);
	Location.X+=-40+Rand(80);
	if(Cash==0)
		return;
	CashActor=Spawn(class'ID_HUD_DrawableActor_Cash',,, Location);
	CashActor.Cash=Cash;
	CashActor.Controller=self;
}

function OnKill(class<ID_RPG_Base_Monster>Monster, class<DamageType>DamageType, bool IsHeadshot)
{
	local int i;
	for(i=0; i<Achievements.length; i++)
		Achievements[i].OnKill(Monster, DamageType, IsHeadshot);
}

function OnTakeDamage(int BaseDamage, int Damage, class<ID_RPG_Base_Monster>Monster, class<DamageType>DamageType)
{
	local int i;
	for(i=0; i<Achievements.length; i++)
		Achievements[i].OnTakeDamage(BaseDamage, Damage, Monster, DamageType);
}

function OnDealDamage(int Damage, class<ID_RPG_Base_Monster>Monster, class<DamageType>DamageType)
{
	local int i;
	for(i=0; i<Achievements.length; i++)
		Achievements[i].OnDealDamage(Damage, Monster, DamageType);
}

defaultproperties
{
     AchievementClasses(0)=Class'IDRPGMod.ID_Achievement_KillsInTime'
     AchievementClasses(1)=Class'IDRPGMod.ID_Achievement_KillsWithoutTakingDamage'
     AchievementClasses(2)=Class'IDRPGMod.ID_Achievement_KillsWithoutDying'
     AchievementClasses(3)=Class'IDRPGMod.ID_Achievement_PattyKiller'
     AchievementClasses(4)=Class'IDRPGMod.ID_Achievement_Sniper'
     AchievementClasses(5)=Class'IDRPGMod.ID_Achievement_BloatKiller'
     AchievementClasses(6)=Class'IDRPGMod.ID_Achievement_BloatKiller_Only'
     AchievementClasses(7)=Class'IDRPGMod.ID_Achievement_BruteKiller'
     AchievementClasses(8)=Class'IDRPGMod.ID_Achievement_BruteKiller_Only'
     AchievementClasses(9)=Class'IDRPGMod.ID_Achievement_ClotKiller'
     AchievementClasses(10)=Class'IDRPGMod.ID_Achievement_ClotKiller_Only'
     AchievementClasses(11)=Class'IDRPGMod.ID_Achievement_CrawlerKiller'
     AchievementClasses(12)=Class'IDRPGMod.ID_Achievement_CrawlerKiller_Only'
     AchievementClasses(13)=Class'IDRPGMod.ID_Achievement_FleshPoundKiller'
     AchievementClasses(14)=Class'IDRPGMod.ID_Achievement_FleshPoundKiller_Only'
     AchievementClasses(15)=Class'IDRPGMod.ID_Achievement_GorefastKiller'
     AchievementClasses(16)=Class'IDRPGMod.ID_Achievement_GorefastKiller_Only'
     AchievementClasses(17)=Class'IDRPGMod.ID_Achievement_HuskKiller'
     AchievementClasses(18)=Class'IDRPGMod.ID_Achievement_HuskKiller_Only'
     AchievementClasses(19)=Class'IDRPGMod.ID_Achievement_ScrakeKiller'
     AchievementClasses(20)=Class'IDRPGMod.ID_Achievement_ScrakeKiller_Only'
     AchievementClasses(21)=Class'IDRPGMod.ID_Achievement_ShiverKiller'
     AchievementClasses(22)=Class'IDRPGMod.ID_Achievement_ShiverKiller_Only'
     AchievementClasses(23)=Class'IDRPGMod.ID_Achievement_SirenKiller'
     AchievementClasses(24)=Class'IDRPGMod.ID_Achievement_SirenKiller_Only'
     AchievementClasses(25)=Class'IDRPGMod.ID_Achievement_StalkerKiller'
     AchievementClasses(26)=Class'IDRPGMod.ID_Achievement_StalkerKiller_Only'
     AchievementClasses(27)=Class'IDRPGMod.ID_Achievement_JasonKiller'
     AchievementClasses(28)=Class'IDRPGMod.ID_Achievement_JasonKiller_Only'
     LobbyMenuClassString="IDRPGMod.ID_GUI_Lobby_Menu"
}
