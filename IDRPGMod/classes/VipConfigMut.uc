class VipConfigMut extends Mutator config(WeaponSkinConfig);

struct VipStruct
{
	var config string PlayerID;
	var config string PerkIndex;
	var config string PlayerName;
	var config string SpecialWeapon;
};
struct VipSkinStruct
{
	var config string Skin;
	var config string PlayerID;
	var config string PlayerName;
};

var config array<VipStruct> VipList;
var config array<VipSkinStruct> SkinList;
var array<PlayerController> PendingPlayers;
var array<KFHumanPawn> PendingBodies;

function PostBeginPlay()
{
	if(KFGameType(Level.Game)==None) Destroyed();
	AddAvailableVipSkins();
	Super.PostBeginPlay();
	SaveConfig();
	SetTimer(0.1,true);
}

function ModifyPlayer(Pawn P)
{
	Super.ModifyPlayer(P);
	TryGiveSpecialWeapon(P);
}

function AddAvailableVipSkins()
{
	local int i,N;
	for(i=0;i<SkinList.Length;i++)
	{
		N=Class'KFGameType'.Default.AvailableChars.Length;
		Class'KFGameType'.Default.AvailableChars[N]=SkinList[i].Skin;
	}
}

function Timer()
{
	local int i;
	local Controller C;
	for(C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if(PlayerController(C)!=none && PlayerController(C).PlayerReplicationInfo.PlayerID>0)
			TryToPutSkinOn(PlayerController(C));
	}
}

function TryToPutSkinOn(PlayerController PC)
{
	local int i;
	local string Hash;
	Hash=PC.GetPlayerIDHash();
	for(i=0;i<SkinList.Length;i++)
	{
		if(SkinList[i].PlayerID~=Hash)
			PC.PlayerReplicationInfo.SetCharacterName(SkinList[i].Skin);
	}
}

function TryGiveSpecialWeapon(Pawn P)
{
	local KFPlayerReplicationInfo KFPRI;
	local string Hash, PerkIndex;
	local PlayerController PC;
	local int i;
	if(P==None) return;
	KFPRI=KFPlayerReplicationInfo(P.PlayerReplicationInfo);
	PC=PlayerController(P.Controller);
	if(PC==None) return;
	Hash=PC.GetPlayerIDHash();
	if(KFPRI!=None)
	{
		PerkIndex=string(KFPRI.ClientVeteranSkill.default.PerkIndex);
	}
	for(i=0;i<VipList.Length;i++)
	{
		if(VipList[i].PlayerID~=Hash && VipList[i].PerkIndex~=PerkIndex)
			P.GiveWeapon(VipList[i].SpecialWeapon);
	}
}

defaultproperties
{
	VipList(0)=(PlayerID="76561198051378",PlayerName="Flame",PerkIndex="4",SpecialWeapon="KFMod.Katana")
	SkinList(0)=(PlayerID="76561198051378",PlayerName="Flame",Skin="VipSkinsMut.SPMRFoster")
	bAddToServerPackages=True
	GroupName="KF-VipConfig"
	FriendlyName="VipConfigMut"
	Description="Vip Settings"
	bAlwaysRelevant=True	
}