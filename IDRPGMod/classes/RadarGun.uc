class RadarGun extends KFMeleeGun;

var Pawn OldInstigator;
var RadarOverlay MyHUD;
var float NextToggleTime;

simulated exec function SetOffset( string XY )
{
	local float X,Y;
	local int i;

	if( MyHUD==None )
		return;
	i = InStr(XY," ");
	if( i==-1 )
	{
		Level.GetLocalPlayerController().ClientMessage("Bad Parameters in: SetOffset Xoffset Yoffset (example: SetOffset 0.1 0.1)");
		return;
	}
	X = float(Left(XY,i));
	Y = float(Mid(XY,i+1));
	MyHUD.ScreenX = X;
	MyHUD.ScreenY = Y;
	MyHUD.SaveConfig();
}
simulated exec function SetScale( float X )
{
	if( MyHUD==None )
		return;
	MyHUD.RadarSize = X;
	MyHUD.SaveConfig();
}
simulated function PostNetReceive()
{
	local PlayerController PC;

	if( OldInstigator!=Instigator )
	{
		OldInstigator = Instigator;
		PC = Level.GetLocalPlayerController();
		if( Instigator!=None && PC.Pawn==Instigator )
		{
			if( MyHUD==None )
			{
				MyHUD = Spawn(Class'RadarOverlay',PC.myHUD);
				PC.myHUD.Overlays[PC.myHUD.Overlays.length] = MyHUD;
			}
		}
		else if( MyHUD!=None )
			MyHUD.Destroy();
	}
}
function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local PlayerController PC;

	Super.GiveTo(Other,Pickup);
	if( Level.NetMode==NM_DedicatedServer || MyHUD!=None )
		return;
	PC = Level.GetLocalPlayerController();
	if( PC!=None && PC.Pawn==Other )
	{
		MyHUD = Spawn(Class'RadarOverlay',PC.myHUD);
		PC.myHUD.Overlays[PC.myHUD.Overlays.length] = MyHUD;
	}
}

simulated function Weapon WeaponChange( byte F, bool bSilent )
{
	if ( Inventory == None )
		return None;
	else return Inventory.WeaponChange(F,bSilent);
}

function PlayIdle();

simulated event RenderOverlays( Canvas Canvas )
{
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(25,Canvas.ClipY*0.25f);
	Canvas.Font = Canvas.Viewport.Actor.MyHUD.GetFontSizeIndex(Canvas,-1);
}

simulated function ClientReload()
{
}
exec function ReloadMeNow()
{
}

simulated function AnimEnd(int channel);

simulated function Destroyed()
{
	if( MyHUD!=None )
		MyHUD.Destroy();
	super.Destroyed();
}

// need to figure out modified rating based on enemy/tactical situation
simulated function float RateSelf()
{
	CurrentRating = -2;
	return CurrentRating;
}

simulated event ClientStartFire(int Mode)
{
	if( NextToggleTime>Level.TimeSeconds )
		return;

	if( MyHUD!=None )
		MyHUD.bInvisible = !MyHUD.bInvisible;
	NextToggleTime = Level.TimeSeconds+0.5f;
}

simulated event ClientStopFire(int Mode)
{
}

function bool BotFire(bool bFinished, optional name FiringMode)
{
	return false;
}

event ServerStartFire(byte Mode)
{
}

function ServerStopFire(byte Mode)
{
}

defaultproperties
{
     MagCapacity=13
     HudImage=Texture'DZResPack.Trader_MT'
     SelectedHudImage=Texture'DZResPack.Trader_MT'
     Weight=0.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'DZResPack.Trader_MT'
     FireModeClass(0)=Class'KFMod.NoFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     SelectForce="SwitchToAssaultRifle"
     bCanThrow=False
     Priority=10
     InventoryGroup=5
     GroupOffset=5
     PickupClass=Class'IDRPGMod.RadarPickup'
     BobDamping=6.000000
     AttachmentClass=Class'IDRPGMod.RadarAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="Zed Radar"
     Mesh=SkeletalMesh'KF_Weapons_Trip.9mm_Trip'
}
