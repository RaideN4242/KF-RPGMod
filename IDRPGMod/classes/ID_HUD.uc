class ID_HUD extends HUDKillingFloor;

#exec obj load file="KFMapEndTextures.utx"
#exec obj load file="RPGFonts.utx"

var ID_RPG_Stats_ReplicationLink ClientRep;
var transient float OldDilation,CurrentBW,DesiredBW;
var bool bUseBloom,bUseMotionBlur;
var int InfoRadius;

var Font RPGFontArrayFonts[31];

simulated function PostBeginPlay()
{
	local Font MyFont;

	Super(HudBase).PostBeginPlay();
	SetHUDAlpha();

	foreach DynamicActors(class'KFSPLevelInfo', KFLevelRule)
		Break;

	Hint_45_Time=9999999;

	MyFont=LoadWaitingFont(0);
	MyFont=LoadWaitingFont(1);

	bUseBloom=bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
	bUseMotionBlur=Class'ID_RPG_Base_HumanPawn'.Default.bUseBlurEffect;
}

function GetLocalizedMessages(out HudLocalizedMessage  Messages[8])
{
	local int i;

	for(i=0; i<ArrayCount(LocalMessages); i++)
		Messages[i]=LocalMessages[i];
}

function SetLocalizedMessage(HudLocalizedMessage  Message, int index)
{
	LocalMessages[index]=Message;
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY);

simulated function UpdateHud()
{
	local ID_RPG_Misc_Syringe S;

	Super.UpdateHud();

	if(bDisplayQuickSyringe)
	{
		S=ID_RPG_Misc_Syringe(PawnOwner.FindInventoryType(class'ID_RPG_Misc_Syringe'));
		if(S!=none)
		{
			QuickSyringeDigits.Value=S.ChargeBar()*100;

			if(QuickSyringeDigits.Value<50)
			{
				QuickSyringeDigits.Tints[0].R=128;
				QuickSyringeDigits.Tints[0].G=128;
				QuickSyringeDigits.Tints[0].B=128;

				QuickSyringeDigits.Tints[1]=QuickSyringeDigits.Tints[0];
			}
			else if(QuickSyringeDigits.Value<100)
			{
				QuickSyringeDigits.Tints[0].R=192;
				QuickSyringeDigits.Tints[0].G=96;
				QuickSyringeDigits.Tints[0].B=96;

				QuickSyringeDigits.Tints[1]=QuickSyringeDigits.Tints[0];
			}
			else
			{
				QuickSyringeDigits.Tints[0].R=255;
				QuickSyringeDigits.Tints[0].G=64;
				QuickSyringeDigits.Tints[0].B=64;

				QuickSyringeDigits.Tints[1]=QuickSyringeDigits.Tints[0];
			}
		}
	}
}

simulated function DrawHud(Canvas C)
{
	local KFGameReplicationInfo CurrentGame;
	local rotator CamRot;
	local vector CamPos, ViewDir, ScreenPos;
	local KFPawn KFBuddy;

	CurrentGame=KFGameReplicationInfo(Level.GRI);

	if(FontsPrecached<2)
		PrecacheFonts(C);

	UpdateHud();

	PassStyle=STY_Modulated;
	DrawModOverlay(C);

	if(bUseBloom)
		PlayerOwner.PostFX_SetActive(0, true);

	if(bHideHud)
	{
		C.Style=ERenderStyle.STY_Alpha;
		DrawFadeEffect(C);
		return;
	}

	if(!KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic)
	{
		if(bShowTargeting)
			DrawTargeting(C);

		C.GetCameraLocation(CamPos,CamRot);
		ViewDir=vector(CamRot);

		foreach VisibleCollidingActors(Class'KFPawn',KFBuddy,1000.f,CamPos)
		{
			KFBuddy.bNoTeamBeacon=true;
			if(KFBuddy!=PawnOwner && KFBuddy.PlayerReplicationInfo!=None && KFBuddy.Health>0 && ((KFBuddy.Location - CamPos) Dot ViewDir)>0.8)
			{
				ScreenPos=C.WorldToScreen(KFBuddy.Location+vect(0,0,1)*KFBuddy.CollisionHeight);
				if(ScreenPos.X>=0 && ScreenPos.Y>=0 && ScreenPos.X<=C.ClipX && ScreenPos.Y<=C.ClipY)
					DrawPlayerInfo(C, KFBuddy, ScreenPos.X, ScreenPos.Y);
			}
		}

		PassStyle=STY_Alpha;
		DrawDamageIndicators(C);
		DrawHudPassA(C);
		DrawHudPassC(C);

		if(KFPlayerController(PlayerOwner)!=None && KFPlayerController(PlayerOwner).ActiveNote!=None)
		{
			if(PlayerOwner.Pawn==none)
				KFPlayerController(PlayerOwner).ActiveNote=None;
			else KFPlayerController(PlayerOwner).ActiveNote.RenderNote(C);
		}

		PassStyle=STY_None;
		DisplayLocalMessages(C);
		DrawWeaponName(C);
		DrawVehicleName(C);

		PassStyle=STY_Alpha;

		if(CurrentGame!=None && CurrentGame.EndGameType>0)
		{
			DrawEndGameHUD(C, (CurrentGame.EndGameType==2));
			return;
		}

		RenderFlash(C);
		C.Style=PassStyle;
		DrawKFHUDTextElements(C);
	}
	if(KFPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo).bViewingMatineeCinematic)
	{
		PassStyle=STY_Alpha;
		DrawCinematicHUD(C);
	}
	if(bShowNotification)
		DrawPopupNotification(C);
}

function DrawPlayerInfo(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL;
	local string PlayerName, Health, Armor, pClanName;
	local float Dist;
	local byte BeaconAlpha;
	local float OldZ;

	if(KFPlayerReplicationInfo(P.PlayerReplicationInfo)==none || KFPRI==none || KFPRI.bViewingMatineeCinematic)
	{
		return;
	}

	Dist=vsize(P.Location-PlayerOwner.CalcViewLocation);
	Dist-=HealthBarFullVisDist;
	Dist=FClamp(Dist, 0, HealthBarCutoffDist-HealthBarFullVisDist);
	Dist=Dist/(HealthBarCutoffDist-HealthBarFullVisDist);
	BeaconAlpha=byte((1.f-Dist)*255.f);

	if(BeaconAlpha==0)
	{
		return;
	}

	OldZ=C.Z;
	C.Z=1.0;
	C.Style=ERenderStyle.STY_Alpha;
	C.SetDrawColor(255, 255, 255, BeaconAlpha);
	C.Font=LoadRPGInfoFontStatic(15);
	PlayerName=Left(P.PlayerReplicationInfo.PlayerName, 16);
	//log("Hud lvl:" @ ID_RPG_Base_HumanPawn(P).GetCurrentLvl());
	PlayerName@="("$ID_RPG_Base_HumanPawn(P).Lvl$")";
	C.StrLen(PlayerName, XL, YL);
	C.SetPos(ScreenLocX-(XL*0.5), ScreenLocY-(YL*0.75));
	C.DrawTextClipped(PlayerName);

	if(SRPlayerReplicationInfo(P.PlayerReplicationInfo).ClanName!="")
	{
		C.DrawColor=SRPlayerReplicationInfo(P.PlayerReplicationInfo).ClanColor;
		pClanName=Left(SRPlayerReplicationInfo(P.PlayerReplicationInfo).ClanName, 12);
		//pClanName="Bot Clan";
		C.StrLen(pClanName, XL, YL);
		C.SetPos(ScreenLocX-(XL*0.5), ScreenLocY-69-(YL*0.5));
		C.DrawTextClipped(pClanName);
	}

	C.SetDrawColor(0, 0, 255, BeaconAlpha);
	Armor=P.ShieldStrength@"/"@ID_RPG_Base_HumanPawn(P).MaxShieldStrength;
	C.StrLen(Armor, XL, YL);
	C.SetPos(ScreenLocX-(XL*0.5), ScreenLocY-25-(YL*0.5));
	C.DrawTextClipped(Armor);

	C.SetDrawColor(255, 0, 0, BeaconAlpha);
	Health=P.Health@"/"@ID_RPG_Base_HumanPawn(P).ClientHealthMax;
	C.StrLen(Health, XL, YL);
	C.SetPos(ScreenLocX -(XL*0.5), ScreenLocY-47-(YL*0.5));
	C.DrawTextClipped(Health);
/*
	OffsetX=(36.f * VeterancyMatScaleFactor * 0.6) - (HealthIconSize + 2.0);
	// Health
	if(P.Health > 0)
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 0.4 * BarHeight, FClamp(P.Health / P.HealthMax, 0, 1), BeaconAlpha);

	// Armor
	if(P.ShieldStrength > 0)
		DrawKFBar(C, ScreenLocX - OffsetX, (ScreenLocY - YL) - 1.5 * BarHeight, FClamp(P.ShieldStrength / 100.f, 0, 1), BeaconAlpha, true);
	*/
	C.Z=OldZ;
}

simulated function DrawModOverlay(Canvas C)
{
	local float MaxRBrighten, MaxGBrighten, MaxBBrighten;

	if(PawnOwner==None)
	{
		if(CurrentZone!=None || CurrentVolume!=None) // Reset everything.
		{
			LastR=0;
			LastG=0;
			LastB=0;
			CurrentZone=None;
			LastZone=None;
			CurrentVolume=None;
			LastVolume=None;
			bZoneChanged=false;
			SetTimer(0.f, false);
		}
		VisionOverlay=default.VisionOverlay;

		// Dead Players see Red
		if(!PlayerOwner.IsSpectating())
		{
			C.SetDrawColor(255, 255, 255, GrainAlpha);
			C.DrawTile(SpectatorOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
		}
		return;
	}

	C.SetPos(0, 0);

	if((PlayerOwner.Pawn==PawnOwner || !PlayerOwner.bBehindView) && Vehicle(PawnOwner)==None && PawnOwner.Health>0 && PawnOwner.Health<(PawnOwner.HealthMax*0.25))
		VisionOverlay=NearDeathOverlay;
	else VisionOverlay=default.VisionOverlay;

	if(KFLevelRule !=none && !KFLevelRule.bUseVisionOverlay)
		return;

	MaxRBrighten=Round(LastR*(1.0-(LastR/255))-2);
	MaxGBrighten=Round(LastG*(1.0-(LastG/255))-2);
	MaxBBrighten=Round(LastB*(1.0-(LastB/255))-2);

	C.SetDrawColor(LastR+MaxRBrighten, LastG+MaxGBrighten, LastB+MaxBBrighten, GrainAlpha);
	C.DrawTileScaled(VisionOverlay, C.SizeX, C.SizeY);

	if(!PawnOwner.Region.Zone.bDistanceFog &&
		DefaultPhysicsVolume(PawnOwner.PhysicsVolume)==None && !PawnOwner.PhysicsVolume.bDistanceFog)
		return;

	if(!bZoneChanged)
	{
		if(CurrentZone!=PawnOwner.Region.Zone || (DefaultPhysicsVolume(PawnOwner.PhysicsVolume)==None &&
			CurrentVolume !=PawnOwner.PhysicsVolume))
		{
			if(CurrentZone !=none)
				LastZone=CurrentZone;
			else if(CurrentVolume !=none)
				LastVolume=CurrentVolume;

			if(PawnOwner.Region.Zone.bDistanceFog && DefaultPhysicsVolume(PawnOwner.PhysicsVolume)!=none && !PawnOwner.Region.Zone.bNoKFColorCorrection)
			{
				CurrentVolume=none;
				CurrentZone=PawnOwner.Region.Zone;
			}
			else if(DefaultPhysicsVolume(PawnOwner.PhysicsVolume)==None && PawnOwner.PhysicsVolume.bDistanceFog && !PawnOwner.PhysicsVolume.bNoKFColorCorrection)
			{
				CurrentZone=none;
				CurrentVolume=PawnOwner.PhysicsVolume;
			}

			if(CurrentVolume!=none)
				LastZone=none;
			else if(CurrentZone!=none)
				LastVolume=none;

			if(LastZone !=none)
			{
				if(LastZone.bNewKFColorCorrection)
				{
					LastR=LastZone.KFOverlayColor.R;
					LastG=LastZone.KFOverlayColor.G;
					LastB=LastZone.KFOverlayColor.B;
				}
				else
				{
					LastR=LastZone.DistanceFogColor.R;
					LastG=LastZone.DistanceFogColor.G;
					LastB=LastZone.DistanceFogColor.B;
				}
			}
			else if(LastVolume!=none)
			{
				if(LastVolume.bNewKFColorCorrection)
				{
					LastR=LastVolume.KFOverlayColor.R;
					LastG=LastVolume.KFOverlayColor.G;
					LastB=LastVolume.KFOverlayColor.B;
				}
				else
				{
					LastR=LastVolume.DistanceFogColor.R;
					LastG=LastVolume.DistanceFogColor.G;
					LastB=LastVolume.DistanceFogColor.B;
				}
			}
			else if(LastZone!=none && LastVolume!=none)
				return;

			if(LastZone!=CurrentZone || LastVolume!=CurrentVolume)
			{
				bZoneChanged=true;
				SetTimer(OverlayFadeSpeed, false);
			}
		}
	}
	if(!bTicksTurn && bZoneChanged)
	{
		ValueCheckOut=0;
		bTicksTurn=true;
		SetTimer(OverlayFadeSpeed, false);
	}
}

simulated function DrawEndGameHUD(Canvas C, bool bVictory)
{
	local float Scalar;
	local Shader M;

	C.DrawColor.A=255;
	C.DrawColor.R=255;
	C.DrawColor.G=255;
	C.DrawColor.B=255;
	Scalar=FClamp(C.ClipY, 320, 1024);
	C.CurX=C.ClipX/2-Scalar/2;
	C.CurY=C.ClipY/2-Scalar/2;
	C.Style=ERenderStyle.STY_Alpha;

	if(bVictory)
		M=Shader'KFMapEndTextures.VictoryShader';
	else M=Shader'KFMapEndTextures.DefeatShader';

	C.DrawTile(M, Scalar, Scalar, 0, 0, 1024, 1024);

	if(bShowScoreBoard && ScoreBoard!=None)
		ScoreBoard.DrawScoreboard(C);
}

simulated function DrawHudPassA(Canvas C)
{
	local KFHumanPawn KFHPawn;
	local float TempSize;
	local class<ID_RPG_Stats_Veterancy> SV;	

	KFHPawn=KFHumanPawn(PawnOwner);

	DrawDoorHealthBars(C);

	if(!bLightHud)
	{
		DrawSpriteWidget(C, HealthBG);
	}

	DrawSpriteWidget(C, HealthIcon);
	DrawNumericWidget(C, HealthDigits, DigitsSmall);

	if(!bLightHud)
	{
		DrawSpriteWidget(C, ArmorBG);
	}

	DrawSpriteWidget(C, ArmorIcon);
	DrawNumericWidget(C, ArmorDigits, DigitsSmall);

	if(KFHPawn !=none)
	{
		C.SetPos(C.ClipX*WeightBG.PosX, C.ClipY*WeightBG.PosY);

		if(!bLightHud)
		{
			C.DrawTile(WeightBG.WidgetTexture, WeightBG.WidgetTexture.MaterialUSize()*WeightBG.TextureScale*1.5*HudCanvasScale*ResScaleX*HudScale, WeightBG.WidgetTexture.MaterialVSize()*WeightBG.TextureScale*HudCanvasScale*ResScaleY*HudScale, 0, 0, WeightBG.WidgetTexture.MaterialUSize(), WeightBG.WidgetTexture.MaterialVSize());
		}

		DrawSpriteWidget(C, WeightIcon);

		C.Font=LoadSmallFontStatic(5);
		C.FontScaleX=C.ClipX/1024.0;
		C.FontScaleY=C.FontScaleX;
		C.SetPos(C.ClipX*WeightDigits.PosX, C.ClipY*WeightDigits.PosY);
		C.DrawColor=WeightDigits.Tints[0];
		C.DrawText(int(KFHPawn.CurrentWeight)$"/"$int(KFHPawn.MaxCarryWeight));
		C.FontScaleX=1;
		C.FontScaleY=1;
	}

	if(!bLightHud)
	{
		//DrawSpriteWidget(C, GrenadeBG);
	}

	//DrawSpriteWidget(C, GrenadeIcon);
	//DrawNumericWidget(C, GrenadeDigits, DigitsSmall);

	if(PawnOwner!=none && PawnOwner.Weapon!=none)
	{
		if(ID_RPG_Misc_Syringe(PawnOwner.Weapon)!=none)
		{
			if(!bLightHud)
			{
				DrawSpriteWidget(C, SyringeBG);
			}

			DrawSpriteWidget(C, SyringeIcon);
			DrawNumericWidget(C, SyringeDigits, DigitsSmall);
		}
		else
		{
			if(bDisplayQuickSyringe)
			{
				TempSize=Level.TimeSeconds - QuickSyringeStartTime;
				if(TempSize < QuickSyringeDisplayTime)
				{
					if(TempSize < QuickSyringeFadeInTime)
					{
						QuickSyringeBG.Tints[0].A=int((TempSize / QuickSyringeFadeInTime) * 255.0);
						QuickSyringeBG.Tints[1].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A=QuickSyringeBG.Tints[0].A;
					}
					else if(TempSize > QuickSyringeDisplayTime - QuickSyringeFadeOutTime)
					{
						QuickSyringeBG.Tints[0].A=int((1.0 - ((TempSize - (QuickSyringeDisplayTime - QuickSyringeFadeOutTime)) / QuickSyringeFadeOutTime)) * 255.0);
						QuickSyringeBG.Tints[1].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[0].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeIcon.Tints[1].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[0].A=QuickSyringeBG.Tints[0].A;
						QuickSyringeDigits.Tints[1].A=QuickSyringeBG.Tints[0].A;
					}
					else
					{
						QuickSyringeBG.Tints[0].A=255;
						QuickSyringeBG.Tints[1].A=255;
						QuickSyringeIcon.Tints[0].A=255;
						QuickSyringeIcon.Tints[1].A=255;
						QuickSyringeDigits.Tints[0].A=255;
						QuickSyringeDigits.Tints[1].A=255;
					}

					if(!bLightHud)
					{
						DrawSpriteWidget(C, QuickSyringeBG);
					}

					DrawSpriteWidget(C, QuickSyringeIcon);
					DrawNumericWidget(C, QuickSyringeDigits, DigitsSmall);
				}
				else
				{
					bDisplayQuickSyringe=false;
				}
			}

			if(ID_Weapon_Base_MP7M(PawnOwner.Weapon) !=none)
			{

				MedicGunDigits.Value=ID_Weapon_Base_MP7M(PawnOwner.Weapon).ChargeBar() * 100;

				if(MedicGunDigits.Value < 50)
				{
					MedicGunDigits.Tints[0].R=128;
					MedicGunDigits.Tints[0].G=128;
					MedicGunDigits.Tints[0].B=128;

					MedicGunDigits.Tints[1]=SyringeDigits.Tints[0];
				}
				else if(MedicGunDigits.Value < 100)
				{
					MedicGunDigits.Tints[0].R=192;
					MedicGunDigits.Tints[0].G=96;
					MedicGunDigits.Tints[0].B=96;

					MedicGunDigits.Tints[1]=SyringeDigits.Tints[0];
				}
				else
				{
					MedicGunDigits.Tints[0].R=255;
					MedicGunDigits.Tints[0].G=64;
					MedicGunDigits.Tints[0].B=64;

					MedicGunDigits.Tints[1]=MedicGunDigits.Tints[0];
				}

				if(!bLightHud)
				{
					DrawSpriteWidget(C, MedicGunBG);
				}

				DrawSpriteWidget(C, MedicGunIcon);
				DrawNumericWidget(C, MedicGunDigits, DigitsSmall);
			}

			if(SPAS12(PawnOwner.Weapon) !=none)
			{

				MedicGunDigits.Value=SPAS12(PawnOwner.Weapon).ChargeBar() * 100;

				if(MedicGunDigits.Value < 50)
				{
					MedicGunDigits.Tints[0].R=128;
					MedicGunDigits.Tints[0].G=128;
					MedicGunDigits.Tints[0].B=128;

					MedicGunDigits.Tints[1]=SyringeDigits.Tints[0];
				}
				else if(MedicGunDigits.Value < 100)
				{
					MedicGunDigits.Tints[0].R=192;
					MedicGunDigits.Tints[0].G=96;
					MedicGunDigits.Tints[0].B=96;

					MedicGunDigits.Tints[1]=SyringeDigits.Tints[0];
				}
				else
				{
					MedicGunDigits.Tints[0].R=255;
					MedicGunDigits.Tints[0].G=64;
					MedicGunDigits.Tints[0].B=64;

					MedicGunDigits.Tints[1]=MedicGunDigits.Tints[0];
				}

				if(!bLightHud)
				{
					DrawSpriteWidget(C, MedicGunBG);
				}

				DrawSpriteWidget(C, MedicGunIcon);
				DrawNumericWidget(C, MedicGunDigits, DigitsSmall);
			}

			if(ID_RPG_Misc_Welder(PawnOwner.Weapon) !=none)
			{
				if(!bLightHud)
				{
					DrawSpriteWidget(C, WelderBG);
				}

				DrawSpriteWidget(C, WelderIcon);
				DrawNumericWidget(C, WelderDigits, DigitsSmall);
			}
			else if(PawnOwner.Weapon.GetAmmoClass(0) !=none)
			{
				if(!bLightHud)
				{
					//DrawSpriteWidget(C, ClipsBG);
				}

				//DrawNumericWidget(C, ClipsDigits, DigitsSmall);

				if(LAW(PawnOwner.Weapon) !=none)
				{
					DrawSpriteWidget(C, LawRocketIcon);
				}
				else if(Crossbow(PawnOwner.Weapon) !=none)
				{
					DrawSpriteWidget(C, ArrowheadIcon);
				}
				else if(PipeBombExplosive(PawnOwner.Weapon) !=none)
				{
					DrawSpriteWidget(C, PipeBombIcon);
				}
				else if(M79GrenadeLauncher(PawnOwner.Weapon) !=none)
				{
					DrawSpriteWidget(C, M79Icon);
				}
				else
				{
					if(!bLightHud && CivNade(PawnOwner.Weapon)==none)
					{
						DrawSpriteWidget(C, BulletsInClipBG);						
					}

					if(PatGun(PawnOwner.Weapon) !=none || M32Pro(PawnOwner.Weapon) !=none || MP7Dual(PawnOwner.Weapon) !=none || 
						CivNade(PawnOwner.Weapon) !=none || SCARPROFAssaultRifle(PawnOwner.Weapon) !=none || M14EBRPro(PawnOwner.Weapon) !=none ||
						Petrolboomer(PawnOwner.Weapon) !=none
					)
					{
						DrawSpriteWidget(C, ClipsBG);
						ClipsDigits.Value++;
						if(CivNade(PawnOwner.Weapon) !=none)
						{
							ClipsDigits.Value=(ClipsDigits.Value-1)/5;
						}
						if(PatGun(PawnOwner.Weapon) !=none || SCARPROFAssaultRifle(PawnOwner.Weapon) !=none || MP7Dual(PawnOwner.Weapon) !=none || M32Pro(PawnOwner.Weapon) !=none || M14EBRPro(PawnOwner.Weapon) !=none
							|| Petrolboomer(PawnOwner.Weapon) !=none)
							ClipsDigits.Value=CurClipsSecondary;
						DrawNumericWidget(C, ClipsDigits, DigitsSmall);
					}
					
					if(CivNade(PawnOwner.Weapon)==none)
						DrawNumericWidget(C, BulletsInClipDigits, DigitsSmall);

					if(Flamethrower(PawnOwner.Weapon) !=none)
					{
						//DrawSpriteWidget(C, FlameIcon);
						DrawSpriteWidget(C, FlameTankIcon);
					}
					else if(Shotgun(PawnOwner.Weapon) !=none || BoomStick(PawnOwner.Weapon) !=none || Winchester(PawnOwner.Weapon) !=none)
					{
						//DrawSpriteWidget(C, SingleBulletIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
					}
					else if(CivNade(PawnOwner.Weapon) !=none)
					{
						DrawSpriteWidget(C, ClipsIcon);
						//DrawSpriteWidget(C, BulletsInClipIcon);
					}
					else
					{
						if(PatGun(PawnOwner.Weapon) !=none || SCARPROFAssaultRifle(PawnOwner.Weapon) !=none || MP7Dual(PawnOwner.Weapon) !=none || M32Pro(PawnOwner.Weapon) !=none || M14EBRPro(PawnOwner.Weapon) !=none
							|| Petrolboomer(PawnOwner.Weapon) !=none)
						{
							DrawSpriteWidget(C, ClipsIcon);
						}
						
						//DrawSpriteWidget(C, ClipsIcon);
						DrawSpriteWidget(C, BulletsInClipIcon);
					}
				}
			}
		}
	}

	if(KFPlayerReplicationInfo(PawnOwnerPRI)!=None)
		SV=Class'ID_RPG_Stats_Veterancy';

	if(SV!=none)
		SV.Static.SpecialHUDInfo(KFPlayerReplicationInfo(PawnOwnerPRI), C);

	if(KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo)==none || KFSGameReplicationInfo(PlayerOwner.GameReplicationInfo).bHUDShowCash)
	{
		DrawSpriteWidget(C, CashIcon);
		DrawNumericWidget(C, CashDigits, DigitsSmall);
	}
	
	if(Level.TimeSeconds-LastVoiceGainTime<0.333)
	{
		if(!bUsingVOIP && PlayerOwner!=None && PlayerOwner.ActiveRoom!=None &&
			PlayerOwner.ActiveRoom.GetTitle()=="Team")
		{
			bUsingVOIP=true;
			PlayerOwner.NotifySpeakingInTeamChannel();
		}

		DisplayVoiceGain(C);
	}
	else
	{
		bUsingVOIP=false;
	}

	if(bDisplayInventory || bInventoryFadingOut)
	{
		DrawInventory(C);
	}
}

simulated final function RenderFlash(canvas Canvas)
{
	if(PlayerOwner==None || PlayerOwner.FlashScale.X==0 || PlayerOwner.FlashFog==vect(0,0,0))
		Return;
	Canvas.DrawColor.R=Min(Abs(PlayerOwner.FlashFog.X*PlayerOwner.FlashScale.X)*255,255);
	Canvas.DrawColor.G=Min(Abs(PlayerOwner.FlashFog.Y*PlayerOwner.FlashScale.X)*255,255);
	Canvas.DrawColor.B=Min(Abs(PlayerOwner.FlashFog.Z*PlayerOwner.FlashScale.X)*255,255);
	Canvas.DrawColor.A=255;
	Canvas.Style=ERenderStyle.STY_Translucent;
	Canvas.SetPos(0,0);
	Canvas.DrawTile(Texture'engine.WhiteSquareTexture', Canvas.ClipX, Canvas.ClipY, 0, 0, 1, 1);
	Canvas.DrawColor=Canvas.Default.DrawColor;
}

function DrawDoorHealthBars(Canvas C)
{
	local KFDoorMover DamageDoor;
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local rotator CameraRotation;
	local name DoorTag;
	local int i;

	if(PawnOwner==None)
		return;

	if((Level.TimeSeconds>LastDoorBarHealthUpdate) || (ID_RPG_Misc_Welder(PawnOwner.Weapon)!=none && PlayerOwner.bFire==1))
	{
		DoorCache.Length=0;

		foreach CollidingActors(class'KFDoorMover', DamageDoor, 300.00, PlayerOwner.CalcViewLocation)
		{
			if(DamageDoor.WeldStrength<=0)
				continue;

			DoorCache[DoorCache.Length]=DamageDoor;

			C.GetCameraLocation(CameraLocation, CameraRotation);
			TargetLocation=DamageDoor.WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
			TargetLocation.Z=CameraLocation.Z;
			CamDir=vector(CameraRotation);

			if(Normal(TargetLocation-CameraLocation) dot Normal(CamDir)>=0.1 && DamageDoor.Tag!=DoorTag && FastTrace(DamageDoor.WeldIconLocation-((DoorCache[i].WeldIconLocation-CameraLocation)*0.25), CameraLocation))
			{
				HBScreenPos=C.WorldToScreen(TargetLocation);
				DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DamageDoor.WeldStrength/DamageDoor.MaxWeld, 255);
				DoorTag=DamageDoor.Tag;
			}
		}
		LastDoorBarHealthUpdate=Level.TimeSeconds+0.2;
	}
	else
	{
		for(i=0; i<DoorCache.Length; i++)
		{
			if(DoorCache[i].WeldStrength<=0)
				continue;
			C.GetCameraLocation(CameraLocation, CameraRotation);
			TargetLocation=DoorCache[i].WeldIconLocation /*+ vect(0, 0, 1) * Height*/;
			TargetLocation.Z=CameraLocation.Z;
			CamDir=vector(CameraRotation);

			if(Normal(TargetLocation-CameraLocation) dot Normal(CamDir)>=0.1 && DoorCache[i].Tag!=DoorTag && FastTrace(DoorCache[i].WeldIconLocation-((DoorCache[i].WeldIconLocation-CameraLocation)*0.25), CameraLocation))
			{
				HBScreenPos=C.WorldToScreen(TargetLocation);
				DrawDoorBar(C, HBScreenPos.X, HBScreenPos.Y, DoorCache[i].WeldStrength/DoorCache[i].MaxWeld, 255);
				DoorTag=DoorCache[i].Tag;
			}
		}
	}
}

simulated function Tick(float Delta)
{
	if(ClientRep==None)
		ClientRep=Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(PlayerOwner);
	Super.Tick(Delta);
}

function string GetNewEXPString(string S)
{
	local int i;
	local string SS;

	for(i=0;i<Len(S);i++)
	{
		if(i!=0 && i%3==0)
		{
			SS=" "$SS;
		}

		SS=Mid(S,Len(S)-i-1,1)$SS;
	}

	return SS;
}

simulated function DrawKFHUDTextElements(Canvas C)
{
	local float	XL, YL,CurrentHeight;
	//local int	 NumZombies, Min;
	local string S;

	if(PlayerOwner==none || KFGRI==none || !KFGRI.bMatchHasBegun || KFPlayerController(PlayerOwner).bShopping)
	{
		return;
	}

	// Countdown Text
	if(KFGRI.TimeToNextWave>0)
//	if(!KFGRI.bWaveInProgress)
	{
		//Min=KFGRI.TimeToNextWave / 60;
		//NumZombies=KFGRI.TimeToNextWave - (Min * 60);

		S=string(KFGRI.TimeToNextWave); //Eval((Min >=10), string(Min), "0" $ Min) $ ":" $ Eval((NumZombies >=10), string(NumZombies), "0" $ NumZombies);
		C.Font=LoadFont(2);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(255, 50, 50, KFHUDAlpha);
		C.SetPos(C.ClipX-66-(XL/2), 66-YL/2);
		C.DrawText(S, False);
	}

	if(ID_RPG_Base_HumanPawn(PlayerOwner.Pawn)!=none && ID_RPG_Base_HumanPawn(PlayerOwner.Pawn).Health>0)
	{
		// NIKE: Тут менял индикатор Experience на CurrentMonsterLVL но пока это не готово, даже в local не вносил ничего. Позже пофиксю 
		// NIKE: UPDATE. p.s. Игрокам не понравилась идея, и я вернул обратно индюк.
		S="Experience:"@GetNewEXPString(ClientRep.Experience);
		C.Font=LoadRPGInfoFontStatic(25);
		C.Strlen(S, XL, YL);
		C.SetDrawColor(0, 255, 0, KFHUDAlpha);
		C.SetPos(C.ClipX/2-(XL/2), CurrentHeight);
		CurrentHeight+=YL;
		C.DrawText(S);		
		
		if(ID_RPG_Base_HumanPawn(PlayerOwner.Pawn).CanBuyNow())
		{
			S="Shopping time! Time left:"@ID_RPG_Base_HumanPawn(PlayerOwner.Pawn).ShoppingTimeLeft @ "seconds";
			C.Font=LoadRPGInfoFontStatic(23);
			C.Strlen(S, XL, YL);
			if(ID_RPG_Base_HumanPawn(PlayerOwner.Pawn).ShoppingTimeLeft>15)
				C.SetDrawColor(175,176,158, KFHUDAlpha);
			else
				C.SetDrawColor(255,0,0, KFHUDAlpha);
			C.SetPos(C.ClipX/2-(XL/2), CurrentHeight);
			CurrentHeight+=YL;
			C.DrawText(S);
		}
		else
		{
			S="Shopping time in"@ID_RPG_Base_HumanPawn(PlayerOwner.Pawn).TimeToStartShopping@"seconds";
			C.Font=LoadRPGInfoFontStatic(16);
			C.Strlen(S, XL, YL);
			C.SetDrawColor(255,194,168, KFHUDAlpha);
			C.SetPos(C.ClipX/2-(XL/2), CurrentHeight);
			CurrentHeight+=YL;
			C.DrawText(S);
		}
		
		if(SRPlayerREplicationInfo(KFPRI).BLeft!=0)
		{
			S="Kills till boss:"@SRPlayerREplicationInfo(KFPRI).BLeft;
			C.Font=LoadRPGInfoFontStatic(23);
			C.Strlen(S, XL, YL);
			C.SetDrawColor(0, 255, 255, KFHUDAlpha);
			C.SetPos(C.ClipX/2-(XL/2), CurrentHeight);
			CurrentHeight+=YL;
			C.DrawText(S);
		}
		
		if(SRPlayerREplicationInfo(KFPRI).MonsterLVL!=0)
		{
			S="Current Monster LVL:"@SRPlayerREplicationInfo(KFPRI).MonsterLVL;
			C.Font=LoadRPGInfoFontStatic(15);
			C.Strlen(S, XL, YL);
			C.SetDrawColor(255, 0, 255, KFHUDAlpha);
			C.SetPos(C.ClipX / 2 - (XL / 2), CurrentHeight);
			CurrentHeight+=YL;
			C.DrawText(S);
		}
		
		bIsSecondDowntime=true;
	}

	C.DrawActor(None, False, True); // Clear Z.
	C.DrawActor(ShopDirPointer, False, false);
	DrawTraderDistance(C);
	
	InfoRadius=1500;
	DrawMonstersInfo(C, ID_RPG_Base_PlayerController(PlayerOwner));
	DrawDamageActors(C, ID_RPG_Base_PlayerController(PlayerOwner));
	DrawActiveUtilEffects(C, ID_RPG_Base_HumanPawn(PlayerOwner.Pawn));
}

simulated function DrawActiveUtilEffects(Canvas C, ID_RPG_Base_HumanPawn Pawn)
{
	local Inventory Inv;
	local int i;

	if(Pawn==none || Pawn.Inventory==None) 
		return;

	C.Font=LoadRPGInfoFontStatic(13);

	for(Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory)
	{
		if(ID_RPG_Base_Util(Inv)!=None)
		{
			//log("Drawing:" @ ID_RPG_Base_Util(Inv));
			if(i==0)
			{
				C.SetPos(10, C.ClipY  / 2);
				C.SetDrawColor(147, 206, 255, 255);
				C.DrawText("Your active utils:");
				C.SetDrawColor(96, 181, 255, 255);
			}
			i++;
			C.SetPos(20, C.ClipY/2+15*i);
			ID_RPG_Base_Util(Inv).DrawHud(C, i, 20, C.ClipX/2+15*i);
		}
	}
}

simulated function DrawMonstersInfo(Canvas C, ID_RPG_Base_PlayerController Controller)
{
	local rotator CameraRotation;
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local float Dist;
	local ID_RPG_Base_Monster currentActor;
	local vector FromLocation;
	local Pawn Pawn;
	local string LvlString, HealthString;
	local float StringHeight, StringWidth;

	Pawn=Controller.Pawn;
	if(Pawn==none)
		return;
	C.GetCameraLocation(CameraLocation, CameraRotation);
	CamDir=vector(CameraRotation);
	
	FromLocation=vect(0, 0, 0);
	FromLocation.X=Pawn.Location.X-20;
	FromLocation.Y=Pawn.Location.Y;
	FromLocation.Z=Pawn.Location.Z;

	foreach Pawn.RadiusActors(class'ID_RPG_Base_Monster', currentActor, InfoRadius, FromLocation)
	{
		if(currentActor.Health<=0 || currentActor.Cloaked() || currentActor.bCloaked || currentActor.Visibility==1)//|| ID_Monster_Zombie_Stalker(currentActor)!=none)
			continue;
		TargetLocation=currentActor.Location+vect(0, 0, 1)*(currentActor.CollisionHeight*1.9);
		Dist=VSize(TargetLocation-CameraLocation);
		//log("Location:" @ currentActor.Location);
		if((Normal(TargetLocation-CameraLocation) dot CamDir)<0)
			continue;

		HBScreenPos=C.WorldToScreen(TargetLocation);
		//log("Time:" @ currentActor.LivingTime);

		if(FastTrace(TargetLocation, CameraLocation))
		{
			C.Font=LoadRPGInfoFontStatic(20-10*(Dist/InfoRadius));

			if(currentActor.HealthMax*0.8<currentActor.Health)
				C.SetDrawColor(0, 255, 0, 255);
			else if(currentActor.HealthMax*0.5<currentActor.Health)
				C.SetDrawColor(255, 120, 20, 255);
			else
				C.SetDrawColor(255-255*currentActor.Health/currentActor.HealthMax, 0, 0, 255);

			HealthString="HP:"@currentActor.Health;
			C.StrLen(HealthString, StringWidth, StringHeight);
			C.SetPos(HBScreenPos.X-StringWidth*0.5, HBScreenPos.Y+23);
			C.DrawText(HealthString);

			LvlString="Lvl:"@currentActor.Lvl;
			C.SetDrawColor(0, 255, 0, 255);
			if(currentActor.IsBoss)
			{
				C.Font=LoadRPGInfoFontStatic(25-13*(Dist / InfoRadius)); //LoadFont(3 + 3 * (Dist / InfoRadius));
				LvlString="BOSS" @ LvlString; 
				C.SetDrawColor(255, 0, 0, 255);
			}
			C.StrLen(LvlString, StringWidth, StringHeight);
			C.SetPos(HBScreenPos.X-StringWidth*0.5, HBScreenPos.Y);
			C.DrawText(LvlString);
		}
	}
}

simulated function DrawDamageActors(Canvas C, ID_RPG_Base_PlayerController Controller)
{
	local rotator CameraRotation;
	local vector CameraLocation, CamDir, TargetLocation, HBScreenPos;
	local float Dist;
	local ID_HUD_DrawableActor currentActor;
	local vector FromLocation;
	local Pawn Pawn;

	Pawn=Controller.Pawn;
	if(Pawn==none)
		return;
	C.GetCameraLocation(CameraLocation, CameraRotation);
	CamDir=vector(CameraRotation);

	FromLocation=vect(0, 0, 0);
	FromLocation.X=Pawn.Location.X - 20;
	FromLocation.Y=Pawn.Location.Y;
	FromLocation.Z=Pawn.Location.Z;
	
	foreach Pawn.RadiusActors(class'ID_HUD_DrawableActor', currentActor, InfoRadius, FromLocation)
	{
		TargetLocation=currentActor.Location;
		Dist=VSize(TargetLocation-CameraLocation);
		//log("Location:" @ currentActor.Location);
		if((Normal(TargetLocation-CameraLocation) dot CamDir)<0)
			continue;

		HBScreenPos=C.WorldToScreen(TargetLocation);
		//log("Time:" @ currentActor.LivingTime);

		if(FastTrace(TargetLocation, CameraLocation))
		{
			currentActor.Draw(self, C, HBScreenPos.X, HBScreenPos.Y, Dist, Controller);
		}
	}
}

static function Font LoadRPGInfoFontStatic(int i)
{
	i=Clamp(i, 9, 30);
	if(default.RPGFontArrayFonts[i]==none)
	{
		default.RPGFontArrayFonts[i]=Font(DynamicLoadObject("RPGFonts.RPGFont" $ i , class'Font'));
		if(default.RPGFontArrayFonts[i]==none)
			Log("Warning: "$default.Class$" Couldn't dynamically load font "$"RPGFonts.RPGFont" $ i);
	}

	return default.RPGFontArrayFonts[i];
}


simulated event PostRender(canvas Canvas)
{
	local plane OldModulate;
	local color OldColor;
	local int i;

	BuildMOTD();

	OldModulate=Canvas.ColorModulate;
	OldColor=Canvas.DrawColor;

	Canvas.ColorModulate.X=1;
	Canvas.ColorModulate.Y=1;
	Canvas.ColorModulate.Z=1;
	Canvas.ColorModulate.W=HudOpacity/255;

	LinkActors();

	ResScaleX=Canvas.SizeX/640.0;
	ResScaleY=Canvas.SizeY / 480.0;

	CheckCountDown(PlayerOwner.GameReplicationInfo);

	if(PawnOwner!=None && PawnOwner.bSpecialHUD)
		PawnOwner.DrawHud(Canvas);

	if(PlayerOwner==None || PawnOwner==None || PawnOwnerPRI==None ||
		(PlayerOwner.IsSpectating() && PlayerOwner.bBehindView))
	{
		DrawSpectatingHud(Canvas);
	}
	else if(!PawnOwner.bHideRegularHUD)
	{
		DrawHud(Canvas);
	}

	if(!bHideHud)
	{
		for(i=0; i<Overlays.length; i++)
			Overlays[i].Render(Canvas);

		if(!DrawLevelAction(Canvas))
		{
			if(PlayerOwner !=None)
			{
				if(PlayerOwner.ProgressTimeOut > Level.TimeSeconds)
					DisplayProgressMessages(Canvas);
				else if(MOTDState==1)
					MOTDState=2;
			}
		}
		if(bShowBadConnectionAlert)
			DisplayBadConnectionAlert(Canvas);

		DisplayMessages(Canvas);

		if(bShowVoteMenu && VoteMenu!=None)
			VoteMenu.RenderOverlays(Canvas);
	}

	PlayerOwner.RenderOverlays(Canvas);

	if(PlayerConsole !=None && PlayerConsole.bTyping)
		DrawTypingPrompt(Canvas, PlayerConsole.TypedStr, PlayerConsole.TypedStrPos);

	hudLastRenderTime=Level.TimeSeconds;

	Canvas.ColorModulate=OldModulate;
	Canvas.DrawColor=OldColor;
	OnPostRender(Self, Canvas);
}

simulated function DrawHealthBar(Canvas C, Actor A, int Health, int MaxHealth, float Height);

defaultproperties
{
}
