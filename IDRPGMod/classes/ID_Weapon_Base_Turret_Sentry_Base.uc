class ID_Weapon_Base_Turret_Sentry_Base extends SVehicle
	Placeable
	CacheExempt;

var ID_Weapon_Base_Turret_Base TurretWeap;
var() globalconfig int HitDamages,TurretHealth;
var int EffectiveRange;
var() globalconfig float FireRateTime;
var Pawn OwnerPawn;
var ID_Weapon_Base_Turret_Base WeaponOwner;

replication
{
	reliable if(Role==ROLE_Authority)
		TurretHealth;
}

final function SetOwningPlayer(Pawn Other, ID_Weapon_Base_Turret_Base Wep)
{
	OwnerPawn=Other;
	PlayerReplicationInfo=Other.PlayerReplicationInfo;
	WeaponOwner=Wep;
	bScriptPostRender=true;
	GetExtraHP(ID_RPG_Base_HumanPawn(Other));
}

function GetExtraHP(ID_RPG_Base_HumanPawn Other)
{
/*	if(Other==none)
	{
		return;
	}

	HealthMax += class'ID_Skill_TurretHP'.static.GetAddHP(Other);
	Health = HealthMax;*/
}

simulated function SetSettings(Pawn Other, ID_Weapon_Base_Turret_Base Wep)
{
	if(Wep==none)
	{
		return;
	}

	if(Wep.TurretHealth>0)
	{
		Health=Wep.TurretHealth;
	}

	TurretWeap=Wep;
}

simulated function bool ShowSpecialMessage(ID_RPG_Base_PlayerController USTDGTPC, int i)
{
	if(Health>0 && USTDGTPC!=none && (OwnerPawn==none || USTDGTPC.Pawn==OwnerPawn))
	{
		USTDGTPC.ReceiveLocalizedMessage(class'ID_Message_Turret', i);
		return true;
	}

	return false;
}

function UsedBy(Pawn P)
{
	if(Health<=0 || P==none || (OwnerPawn!=none && P!=OwnerPawn) || TurretWeap==none)
	{
		return;
	}

	ModifyTurretWeapon(TurretWeap);
	Destroy();
}

function ModifyTurretWeapon(ID_Weapon_Base_Turret_Base CurrentTurret)
{
	if(CurrentTurret==none)
	{
		return;
	}

	CurrentTurret.TurretHealth=Health;
	CurrentTurret.bSentryDeployed=false;
}

defaultproperties
{
}
