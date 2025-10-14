Class RadarOverlay extends HudOverlay;
	
var config float ScreenX,ScreenY,RadarSize;
var() TexRotator MainScreen;
var() Texture DotTex,RingTex;
var float RadarPulse,MinEnemyDist;
var PlayerController PlayerOwner;
var int MetersDist;

var bool bInvisible;

simulated function PostBeginPlay()
{
	PlayerOwner = Level.GetLocalPlayerController();
}
simulated function Render(Canvas C)
{
	local int X,Y;
	local float Scale,ScreenScale,PulseWidth,Dist,Angle,DotScale,XL,YL;
	local vector CamPos,Dir;
	local rotator CamRot,XDir;
	local Pawn P,PP;

	if( bInvisible )
		return;
	Scale = C.ClipY/800.f*RadarSize;
	ScreenScale = Scale*256.f;
	X = Clamp(C.ClipX*ScreenX,0,C.ClipX-ScreenScale);
	Y = Clamp(C.ClipY*ScreenY,0,C.ClipY-ScreenScale);

	C.GetCameraLocation(CamPos,CamRot);
	MainScreen.Rotation.Yaw = CamRot.Yaw;

	C.SetDrawColor(255,255,255,255);
	C.SetPos(X,Y);
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawTile(MainScreen,ScreenScale,ScreenScale, 0, 0, 256, 256 );

	ScreenScale*=0.5f;
	PulseWidth = ScreenScale*RadarPulse;
	C.DrawColor.A = 255-(RadarPulse*255.f);
	C.SetPos(X+ScreenScale-PulseWidth,Y+ScreenScale-PulseWidth);
	C.DrawTile(RingTex,PulseWidth*2.f,PulseWidth*2.f, 0, 0, RingTex.USize, RingTex.VSize);
	DotScale = Scale*16.f;

	MinEnemyDist = 5000.f; //5000
	PP = C.Viewport.Actor.Pawn;
	ForEach DynamicActors(class'Pawn',P)
		if ( P.Health>0 )
		{
			Dir = P.Location-CamPos;
			Dir.Z = 0;
			Dist = VSize(Dir);
			if ( Dist < 3000 ) //3000
			{
				C.DrawColor.A = 255 - 255*Abs(Dist*0.00033 - RadarPulse);
				if ( ID_Monster_Zombie_Patty_Base(P) != None )
				{
					MinEnemyDist = FMin(MinEnemyDist, Dist);
					C.DrawColor.R = 255;
					C.DrawColor.G = 255;
					C.DrawColor.B = 0;
				}
				else if ( Monster(P) != None )
				{
					MinEnemyDist = FMin(MinEnemyDist, Dist);
					C.DrawColor.R = 255;
					C.DrawColor.G = 0;
					C.DrawColor.B = 0;
				}
				else
				{
					C.DrawColor.R = 0;
					C.DrawColor.G = 255;
					C.DrawColor.B = 0;
				}
				Dist = ScreenScale*(Dist/3200.f); //3200
				XDir = rotator(Dir);
				Angle = ((XDir.Yaw - CamRot.Yaw) & 65535) * 6.2832/65536;
				C.SetPos(X + ScreenScale + Dist * sin(Angle) - 0.5*DotScale,
						Y + ScreenScale - Dist * cos(Angle) - 0.5*DotScale);
				C.DrawTile(DotTex,DotScale,DotScale,0,0,DotTex.USize,DotTex.VSize);
			}
		}

	if( MetersDist>=0 )
	{
		C.Font = HUD(Owner).GetFontSizeIndex(C,-2);
		C.SetDrawColor(255,0,0,Min(800-RadarPulse*800,200));
		C.TextSize(MetersDist@"m",XL,YL);
		C.SetPos(X+ScreenScale-XL*0.5f,Y-YL);
		C.DrawText(MetersDist@"m",false);
	}
}

simulated function Tick(float DeltaTime)
{
	if( bInvisible )
		return;
	RadarPulse += 1.25 * DeltaTime;
	if ( RadarPulse >= 1 )
	{
		if( MinEnemyDist<5000 ) //5000
		{
			MetersDist = MinEnemyDist/50.f; //50 100
			PlayerOwner.ViewTarget.PlaySound(Sound'DZResPack.RadarWarn',,FMin(2.0,5000/MinEnemyDist),,,FClamp(2000.f/MinEnemyDist,0.8f,2.f));
		}
		else
		{
			MetersDist = -1;
			PlayerOwner.ViewTarget.PlaySound(Sound'DZResPack.RadarScan',,1.f);
		}
		RadarPulse = RadarPulse - 1;
	}
}

defaultproperties
{
     ScreenX=1.000000
     ScreenY=0.400000
     RadarSize=1.000000
     MainScreen=TexRotator'DZResPack.Radar_r'
     DotTex=Texture'DZResPack.RadarDot'
     RingTex=Texture'DZResPack.RadarRing'
     MetersDist=-1
}
