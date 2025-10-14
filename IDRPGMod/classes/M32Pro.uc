class M32Pro extends ID_RPG_Base_Weapon_Shotgun;

var float NextIronTime;
var byte NumMinesOut;
var() byte MaximumMines;
var() localized string MinesText;
var Actor.FireProperties SavedFireProperties;

replication
{
	reliable if(Role < ROLE_Authority)
		ThreeFire;
	reliable if( Role==ROLE_Authority && bNetOwner )
		NumMinesOut;
}

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

// Yes we have alt fire!
simulated function AltFire(float F){}
exec function SwitchModes(){}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local HopMineProj P;

	Super.GiveTo(Other,Pickup);
	NumMinesOut = 0;
	foreach DynamicActors(Class'HopMineProj',P)
	{
		if( P.InstigatorController==Other.Controller && !P.bNeedsDetonate )
		{
			P.Instigator = Other;
			P.WeaponOwner = Self;
			++NumMinesOut;
		}
		else if( P.WeaponOwner==Self )
			P.WeaponOwner = None;
	}
}

final function AddMine( HopMineProj M )
{
	++NumMinesOut;
	M.WeaponOwner = Self;
	NetUpdateTime = Level.TimeSeconds-1;
}
final function RemoveMine( HopMineProj M )
{
	--NumMinesOut;
	M.WeaponOwner = None;
	NetUpdateTime = Level.TimeSeconds-1;
}
simulated function RenderOverlays( Canvas Canvas )
{
	Super.RenderOverlays(Canvas);
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.Font = Canvas.MedFont;
	Canvas.SetPos(25,Canvas.ClipY*0.5);
	Canvas.DrawText(MinesText$NumMinesOut$"/"$MaximumMines,false);
}

//3rd fire mode
simulated exec function ToggleIronSights()
{
	//less restrictive than chainsaw/axe because we aren't actually doing an attack
	if ( NextIronTime <= Level.TimeSeconds )
	{
		if (Instigator != none)
		{
			ThreeFire();				
			NextIronTime=Level.TimeSeconds+0.2;
		}
	}
}

simulated function ThreeFire()
{
	if(Role == ROLE_Authority)
	{
		MySpawnProj();
	}
}

function MySpawnProj()
{
	local HopMineProj P;
	local Vector StartProj, StartTrace, X,Y,Z;
	local Rotator Aim;
	local Vector HitLocation, HitNormal;
	local Actor Other;	
		
	GetViewAxes(X,Y,Z);
	
	StartTrace = Instigator.Location + Instigator.EyePosition();
	StartProj = StartTrace + X*50;
	if ( !WeaponCentered() )
		StartProj = StartProj + Hand * Y*10;
	
	Other = Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
	
	if (Other != None)
	{
		StartProj = HitLocation;
	}

	Aim = MyAdjustAim(StartProj, 0);

	P = Spawn(class'HopMineProj',,, StartProj, Aim);
	
	if( P!=None && !P.bNeedsDetonate )
		AddMine(P);
}

function Rotator MyAdjustAim(Vector Start, float InAimError)
{
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = class'M32Ammo';
		SavedFireProperties.ProjectileClass = class'HopMineProj';
		SavedFireProperties.WarnTargetPct = 0;
		SavedFireProperties.MaxRange = 2500;
		SavedFireProperties.bTossed = false;
		SavedFireProperties.bTrySplash = false;
		SavedFireProperties.bLeadTarget = false;
		SavedFireProperties.bInstantHit = false;
		SavedFireProperties.bInitialized = true;
	}
	return Instigator.AdjustAim(SavedFireProperties, Start, InAimError);
}

defaultproperties
{
     MaximumMines=16
     MinesText="Mines: "
     MagCapacity=12
     ReloadRate=0.400000
     bHasSecondaryAmmo=True
     bReduceMagAmmoOnSecondaryFire=False
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_M32_MGL"
     HudImage=Texture'DZResPack.Weapon.m32_unselect'
     SelectedHudImage=Texture'DZResPack.Weapon.M32_Select'
     Weight=20.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'DZResPack.Weapon.m32_trader'
     bIsTier3Weapon=True
     MeshRef="KF_Weapons2_Trip.M32_MGL_Trip"
     SkinRefs(0)="DZResPack.M32_D_cmb"
     SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
     SelectSoundRef="KF_M79Snd.M79_Select"
     HudImageRef="DZResPack.M32_unselect"
     SelectedHudImageRef="DZResPack.M32_Select"
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'IDRPGMod.M32ProFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KF_M79Snd.M79_Select'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="An advanced semi automatic grenade launcher. Launches high explosive grenades."
     DisplayFOV=65.000000
     Priority=210
     InventoryGroup=4
     GroupOffset=6
     PickupClass=Class'IDRPGMod.M32ProPickup'
     PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'IDRPGMod.M32ProAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="M32 PRO"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
     Mesh=SkeletalMesh'KF_Weapons2_Trip.M32_MGL_Trip'
     Skins(0)=Combiner'DZResPack.Weapon.m32_D_cmb'
     Skins(1)=Shader'KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr'
}
