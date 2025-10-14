class ID_Monster_Zombie_GoreFast extends ID_Monster_Zombie_GoreFast_Base;

#exec OBJ LOAD FILE=KFPlayerSound.uax

simulated function PostNetReceive()
{
	if (bRunning)
		MovementAnims[0]='ZombieRun';
	else MovementAnims[0]=default.MovementAnims[0];
}

function SetMindControlled(bool bNewMindControlled)
{
	if( bNewMindControlled )
	{
		NumZCDHits++;

		if( NumZCDHits > 1 )
		{
			if( !IsInState('RunningToMarker') )
			{
				GotoState('RunningToMarker');
			}
			else
			{
				NumZCDHits = 1;
				if( IsInState('RunningToMarker') )
				{
					GotoState('');
				}
			}
		}
		else
		{
			if( IsInState('RunningToMarker') )
			{
				GotoState('');
			}
		}

		if( bNewMindControlled != bZedUnderControl )
		{
			GroundSpeed = OriginalGroundSpeed * 1.25;
			Health *= 1.25;
			HealthMax *= 1.25;
		}
	}
	else
	{
		NumZCDHits=0;
	}

	bZedUnderControl = bNewMindControlled;
}

function GivenNewMarker()
{
	if( bRunning && NumZCDHits > 1 )
	{
		GotoState('RunningToMarker');
	}
	else
	{
		GotoState('');
	}
}

function RangedAttack(Actor A)
{
	Super.RangedAttack(A);
	if( !bShotAnim && !bDecapitated && VSize(A.Location-Location)<=700 )
		GoToState('RunningState');
}

state RunningState
{
	function bool CanSpeedAdjust()
	{
		return false;
	}

	function BeginState()
	{
		GroundSpeed = OriginalGroundSpeed * 1.875;
		bRunning = true;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function EndState()
	{
		GroundSpeed = GetOriginalGroundSpeed();
		bRunning = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		RunAttackTimeout=0;

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function RemoveHead()
	{
		GoToState('');
		Global.RemoveHead();
	}

	function RangedAttack(Actor A)
	{
		local float ChargeChance;

		if( Level.Game.GameDifficulty < 2.0 )
		{
			ChargeChance = 0.1;
		}
		else if( Level.Game.GameDifficulty < 4.0 )
		{
			ChargeChance = 0.2;
		}
		else if( Level.Game.GameDifficulty < 7.0 )
		{
			ChargeChance = 0.3;
		}
		else
		{
			ChargeChance = 0.4;
		}

		if ( bShotAnim || Physics == PHYS_Swimming)
			return;
		else if ( CanAttack(A) )
		{
			bShotAnim = true;

			if( FRand() < ChargeChance )
			{
				SetAnimAction('ClawAndMove');
				RunAttackTimeout = GetAnimDuration('GoreAttack1', 1.0);
			}
			else
			{
				SetAnimAction('Claw');
				Controller.bPreparingMove = true;
				Acceleration = vect(0,0,0);
				// Once we attack stop running
				GoToState('');
			}
			return;
		}
	}

	simulated function Tick(float DeltaTime)
	{
		if( RunAttackTimeout > 0 )
		{
			RunAttackTimeout -= DeltaTime;

			if( RunAttackTimeout <= 0 && !bZedUnderControl )
			{
				RunAttackTimeout = 0;
				GoToState('');
			}
		}

		if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
		{
			if( LookTarget!=None )
			{
				Acceleration = AccelRate * Normal(LookTarget.Location - Location);
			}
		}

		global.Tick(DeltaTime);
	}


Begin:
	GoTo('CheckCharge');
CheckCharge:
	if( Controller!=None && Controller.Target!=None && VSize(Controller.Target.Location-Location)<700 )
	{
		Sleep(0.5+ FRand() * 0.5);
		GoTo('CheckCharge');
	}
	else
	{
		GoToState('');
	}
}

state RunningToMarker extends RunningState
{
	simulated function Tick(float DeltaTime)
	{
		if( RunAttackTimeout > 0 )
		{
			RunAttackTimeout -= DeltaTime;

			if( RunAttackTimeout <= 0 && !bZedUnderControl )
			{
				RunAttackTimeout = 0;
				GoToState('');
			}
		}

		if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
		{
			if( LookTarget!=None )
			{
				Acceleration = AccelRate * Normal(LookTarget.Location - Location);
			}
		}

		global.Tick(DeltaTime);
	}


Begin:
	GoTo('CheckCharge');
CheckCharge:
	if( bZedUnderControl || (Controller!=None && Controller.Target!=None && VSize(Controller.Target.Location-Location)<700) )
	{
		Sleep(0.5+ FRand() * 0.5);
		GoTo('CheckCharge');
	}
	else
	{
		GoToState('');
	}
}

simulated event SetAnimAction(name NewAction)
{
	local int meleeAnimIndex;
	local bool bWantsToAttackAndMove;

	if( NewAction=='' )
		Return;

	bWantsToAttackAndMove = NewAction == 'ClawAndMove';

	if( NewAction == 'Claw' )
	{
		meleeAnimIndex = Rand(3);
		NewAction = meleeAnims[meleeAnimIndex];
		CurrentDamtype = ZombieDamType[meleeAnimIndex];
	}

	if( bWantsToAttackAndMove )
	{
	  ExpectingChannel = AttackAndMoveDoAnimAction(NewAction);
	}
	else
	{
	  ExpectingChannel = DoAnimAction(NewAction);
	}

	if( !bWantsToAttackAndMove && AnimNeedsWait(NewAction) )
	{
		bWaitForAnim = true;
	}
	else
	{
		bWaitForAnim = false;
	}

	if( Level.NetMode!=NM_Client )
	{
		AnimAction = NewAction;
		bResetAnimAct = True;
		ResetAnimActTime = Level.TimeSeconds+0.3;
	}
}

simulated function int AttackAndMoveDoAnimAction( name AnimName )
{
	local int meleeAnimIndex;

	if( AnimName == 'ClawAndMove' )
	{
		meleeAnimIndex = Rand(3);
		AnimName = meleeAnims[meleeAnimIndex];
		CurrentDamtype = ZombieDamType[meleeAnimIndex];
	}

	if( AnimName=='GoreAttack1' || AnimName=='GoreAttack2' )
	{
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		PlayAnim(AnimName,, 0.1, 1);

		return 1;
	}

	return super.DoAnimAction( AnimName );
}

simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;
	local coords boneCoords;
	local bool bValidBoneToHide;

	if( boneName == LeftThighBone )
	{
		boneScaleSlot = 0;
		bValidBoneToHide = true;
		if( SeveredLeftLeg == none )
		{
			SeveredLeftLeg = Spawn(SeveredLegAttachClass,self);
			SeveredLeftLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords( 'lleg' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'lleg', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredLeftLeg, 'lleg');
		}
	}
	else if ( boneName == RightThighBone )
	{
		boneScaleSlot = 1;
		bValidBoneToHide = true;
		if( SeveredRightLeg == none )
		{
			SeveredRightLeg = Spawn(SeveredLegAttachClass,self);
			SeveredRightLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords( 'rleg' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rleg', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightLeg, 'rleg');
		}
	}
	else if( boneName == RightFArmBone )
	{
		boneScaleSlot = 2;
		bValidBoneToHide = true;
		if( SeveredRightArm == none )
		{
			SeveredRightArm = Spawn(SeveredArmAttachClass,self);
			SeveredRightArm.SetDrawScale(SeveredArmAttachScale);
			boneCoords = GetBoneCoords( 'rarm' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rarm', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightArm, 'rarm');
		}
	}
	else if ( boneName == LeftFArmBone )
	{
		return;
	}
	else if ( boneName == HeadBone )
	{
		if( SeveredHead == none )
		{
			bValidBoneToHide = true;
			boneScaleSlot = 4;
			SeveredHead = Spawn(SeveredHeadAttachClass,self);
			SeveredHead.SetDrawScale(SeveredHeadAttachScale);
			boneCoords = GetBoneCoords( 'neck' );
			AttachEmitterEffect( NeckSpurtEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredHead, 'neck');
		}
		else
		{
			return;
		}
	}
	else if ( boneName == 'spine' )
	{
		bValidBoneToHide = true;
		boneScaleSlot = 5;
	}

	if( bValidBoneToHide )
	{
		SetBoneScale(BoneScaleSlot, 0.0, BoneName);
	}
}

defaultproperties
{
     DetachedArmClass=Class'KFChar.SeveredArmGorefast'
     DetachedLegClass=Class'KFChar.SeveredLegGorefast'
     DetachedHeadClass=Class'KFChar.SeveredHeadGorefast'
     ControllerClass=Class'IDRPGMod.ID_Monster_Zombie_Gorefast_Controller'
}
