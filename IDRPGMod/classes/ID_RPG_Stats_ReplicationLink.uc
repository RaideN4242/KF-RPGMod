Class ID_RPG_Stats_ReplicationLink extends LinkedReplicationInfo;

var string Experience;
var int Skills[51];

var float NextRepTime;
var int ClientAccknowledged[2],SendIndex;
var ID_RPG_Stats_ServerSteamStats StatObject;
var ID_RPG_Mutator Mut;

var class<ID_RPG_Base_Skill> MySkills[51];

struct FShopItemIndex
{
	var class<Pickup> PC;
	var byte CatNum;
};
var array< FShopItemIndex > ShopInventory;
var array<Material> ShopPerkIcons;
var array<string> ShopCategories;

replication
{
	// Functions server can call.
	reliable if( Role == ROLE_Authority )
		Experience, Skills, ClientPerkLevel,ClientReceiveWeapon,ClientSendAcknowledge,ClientReceiveCategory;

	reliable if( Role < ROLE_Authority )
		ServerSelectPerk,ServerRequestPerks,ServerAcnowledge;
}

//cheating protection
function Timer()
{
	local int i;
	
	super.Timer();
	
	if( Role != ROLE_Authority/* || StatObject.GetID()!=*/ )
		return;
	
	/*for (i = 0; i < ArrayCount(Skills); i++)
	{
		log(i@"= Skill index ="@MySkills[i].default.SkillIndex);
	}*/
	
	for (i = 0; i < ArrayCount(Skills); i++)
	{		
		if(MySkills[i]!=None && Skills[i]>MySkills[i].default.MaxLevel)
		{
			log("Wrong level for skill"@MySkills[i]@"-"@Skills[i]@">"@MySkills[i].default.MaxLevel);
			Skills[i]=MySkills[i].default.MaxLevel;
		}
	}
}

simulated static final function ID_RPG_Stats_ReplicationLink FindStats( PlayerController Other )
{
	local LinkedReplicationInfo L;
	local ID_RPG_Stats_ReplicationLink C;

	if( Other.PlayerReplicationInfo==None )
		return None; // Not yet init.
	for( L=Other.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
		if( ID_RPG_Stats_ReplicationLink(L)!=None )
			return ID_RPG_Stats_ReplicationLink(L);
	if( Other.Level.NetMode!=NM_Client )
		return None; // Not yet init.
	foreach Other.DynamicActors(Class'ID_RPG_Stats_ReplicationLink',C)
		if( C.Owner==Other )
		{
			C.RepLinkBroken();
			return C;
		}
	return None;
}

simulated function int getLevel()
{
	local int i;
	local int result;
	
	for (i = 0; i < ArrayCount(Skills); i++)
	{
		//log("Skill:" @ i @ "=" @ Skills[i]);
		result += Skills[i];
	}
		
	//log("Result:" @ result);
	return result;
}

simulated function Tick( float DeltaTime )
{
	local PlayerController PC;
	local LinkedReplicationInfo L;

	if( Level.NetMode==NM_DedicatedServer )
	{
		Disable('Tick');
		return;
	}
	PC = Level.GetLocalPlayerController();
	if( Level.NetMode!=NM_Client && PC!=Owner )
	{
		Disable('Tick');
		return;
	}
	if( PC.PlayerReplicationInfo==None )
		return;
	Disable('Tick');
	Class'ID_RPG_Helpers_LevelCleanup'.Static.AddSafeCleanup(PC);

	if( PC.PlayerReplicationInfo.CustomReplicationInfo!=None )
	{
		for( L=PC.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
			if( L==Self )
				return; // Make sure not already added.

		NextReplicationInfo = None;
		for( L=PC.PlayerReplicationInfo.CustomReplicationInfo; L!=None; L=L.NextReplicationInfo )
			if( L.NextReplicationInfo==None )
			{
				L.NextReplicationInfo = Self; // Add to the end of the chain.
				return;
			}
	}
	PC.PlayerReplicationInfo.CustomReplicationInfo = Self;
}
simulated final function RepLinkBroken() // Called by GUI when this is noticed.
{
	Enable('Tick');
	Tick(0);
}

final function Class<ID_RPG_Stats_Veterancy> PickRandomPerk()
{
	return class'ID_RPG_Stats_Veterancy';
}
final function ServerSelectPerk( Class<ID_RPG_Stats_Veterancy> VetType )
{
	StatObject.ServerSelectPerk(VetType);
}
final function ServerRequestPerks()
{
	if( NextRepTime<Level.TimeSeconds )
		SendClientPerks();
}
final function SendClientPerks()
{
	if( !StatObject.bStatsReadyNow )
		return;
	NextRepTime = Level.TimeSeconds+2.f;
}

simulated function ClientPerkLevel( int Index, byte CurLevel )
{
	return;
}

simulated function ClientReceiveWeapon( int Index, string P, byte Categ )
{
	ShopInventory.Length = Max(ShopInventory.Length,Index+1);
	//log("CR"@P);
	if( ShopInventory[Index].PC==None )
	{
		ShopInventory[Index].PC = class<Pickup>(DynamicLoadObject(P,Class'Class'));
		ShopInventory[Index].CatNum = Categ;
		++ClientAccknowledged[0];
	}
}
simulated function ClientReceiveCategory( byte Index, string S )
{
	ShopCategories.Length = Max(ShopCategories.Length,Index+1);
	if( ShopCategories[Index]=="" )
	{
		ShopCategories[Index] = S;
		++ClientAccknowledged[1];
	}
}
simulated function ClientSendAcknowledge()
{
	ServerAcnowledge(ClientAccknowledged[0],ClientAccknowledged[1]);
}
function ServerAcnowledge( int A, int B )
{
	ClientAccknowledged[0] = A;
	ClientAccknowledged[1] = B;
}

Auto state RepSetup
{
Begin:
	if( Level.NetMode==NM_Client )
		Stop;
	SetTimer(1,true);
	Sleep(1.f);
	NetUpdateFrequency = 0.2f;

	if( Viewport(StatObject.PlayerOwner.Player)!=None ) // Is host, just copy over values.
	{
		ShopInventory.Length = Mut.LoadInventory.Length;
		for( SendIndex=0; SendIndex<Mut.LoadInventory.Length; ++SendIndex )
		{
			ShopInventory[SendIndex].PC = Mut.LoadInventory[SendIndex];
			ShopInventory[SendIndex].CatNum = Mut.LoadInvCategory[SendIndex];
		}
		ShopCategories = Mut.WeaponCategories;
	}
	else
	{
		// Now MAKE SURE client receives the full inventory list.
		while( ClientAccknowledged[0]<Mut.LoadInventory.Length || ClientAccknowledged[1]<Mut.WeaponCategories.Length )
		{
			for( SendIndex=0; SendIndex<Mut.LoadInventory.Length; ++SendIndex )
			{
				ClientReceiveWeapon(SendIndex,string(Mut.LoadInventory[SendIndex]),Mut.LoadInvCategory[SendIndex]);
				Sleep(0.1f);
			}
			for( SendIndex=0; SendIndex<Mut.WeaponCategories.Length; ++SendIndex )
			{
				ClientReceiveCategory(SendIndex,Mut.WeaponCategories[SendIndex]);
				Sleep(0.1f);
			}
			ClientSendAcknowledge();
			Sleep(1.f);
		}
	}
	GoToState('');
}

defaultproperties
{
     MySkills(0)=Class'IDRPGMod.ID_Skill_Damage'
     MySkills(1)=Class'IDRPGMod.ID_Skill_Resistance'
     MySkills(2)=Class'IDRPGMod.ID_Skill_HeadshotDamage'
     MySkills(3)=Class'IDRPGMod.ID_Skill_Discount'
     MySkills(4)=Class'IDRPGMod.ID_Skill_FireSpeed'
     MySkills(5)=Class'IDRPGMod.ID_Skill_DecreasedRecoil'
     MySkills(6)=Class'IDRPGMod.ID_Skill_ReloadSpeed'
     MySkills(7)=Class'IDRPGMod.ID_Skill_IncreasedMagazine'
     MySkills(8)=Class'IDRPGMod.ID_Skill_CarryWeight'
     MySkills(9)=Class'IDRPGMod.ID_Skill_MovementSpeed'
     MySkills(10)=Class'IDRPGMod.ID_Skill_BetterArmor'
     MySkills(11)=Class'IDRPGMod.ID_Skill_InstantKill'
     MySkills(12)=Class'IDRPGMod.ID_Skill_DoubleDamage'
     MySkills(13)=Class'IDRPGMod.ID_Skill_MaxHP'
     MySkills(14)=Class'IDRPGMod.ID_Skill_MaxArmor'
     MySkills(15)=Class'IDRPGMod.ID_Skill_AdditionalExperience'
     MySkills(16)=Class'IDRPGMod.ID_Skill_AdditionalCash'
     MySkills(17)=Class'IDRPGMod.ID_Skill_FireResistance'
     MySkills(18)=Class'IDRPGMod.ID_Skill_ExplosiveResistance'
     MySkills(19)=Class'IDRPGMod.ID_Skill_Weapon_AA12AS'
     MySkills(20)=Class'IDRPGMod.ID_Skill_Weapon_Crossbow'
     MySkills(21)=Class'IDRPGMod.ID_Skill_Weapon_Deagle'
     MySkills(22)=Class'IDRPGMod.ID_Skill_Weapon_FlameThrower'
     MySkills(23)=Class'IDRPGMod.ID_Skill_Weapon_AK12LLI'
     MySkills(24)=Class'IDRPGMod.ID_Skill_Weapon_M14EBR'
     MySkills(25)=Class'IDRPGMod.ID_Skill_Weapon_M32GL'
     MySkills(26)=Class'IDRPGMod.ID_Skill_Weapon_SCAR'
     MySkills(27)=Class'IDRPGMod.ID_Skill_Weapon_Turret'
     MySkills(28)=Class'IDRPGMod.ID_Skill_Welder'
     MySkills(29)=Class'IDRPGMod.ID_Skill_BattleMedic'
     MySkills(30)=Class'IDRPGMod.ID_Skill_Doctor'
//     MySkills(31)=Class'IDRPGMod.ID_Skill_Weapon_THR40DT'
     MySkills(33)=Class'IDRPGMod.ID_Skill_Weapon_MP7M'
     MySkills(34)=Class'IDRPGMod.ID_Skill_Weapon_Moss12S'
     MySkills(35)=Class'IDRPGMod.ID_Skill_Weapon_M4A4HowlDT'
     MySkills(36)=Class'IDRPGMod.ID_Skill_InfraVision'
     MySkills(37)=Class'IDRPGMod.ID_Skill_Weapon_XMV850'
     MySkills(38)=Class'IDRPGMod.ID_Skill_Weapon_AXBow'
     MySkills(40)=Class'IDRPGMod.ID_Skill_Weapon_V94LLI'
     MySkills(42)=Class'IDRPGMod.ID_Skill_Siren'
     MySkills(43)=Class'IDRPGMod.ID_Skill_Weapon_PatGun'
     MySkills(44)=Class'IDRPGMod.ID_Skill_TurretHP'
     MySkills(45)=Class'IDRPGMod.ID_Skill_Weapon_Katana'
     MySkills(46)=Class'IDRPGMod.ID_Skill_Weapon_AUG'
     MySkills(47)=Class'IDRPGMod.ID_Skill_Weapon_VALDT'
     MySkills(48)=Class'IDRPGMod.ID_Skill_Weapon_LilithKiss'
     MySkills(49)=Class'IDRPGMod.ID_Skill_Weapon_P416'
     MySkills(50)=Class'IDRPGMod.ID_Skill_Weapon_UMP45'
     ShopPerkIcons(0)=Texture'KillingFloorHUD.Perks.Perk_Medic'
     bOnlyRelevantToOwner=True
     bAlwaysRelevant=False
     NetPriority=15.000000
}
