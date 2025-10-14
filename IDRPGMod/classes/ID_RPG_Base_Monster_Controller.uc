class ID_RPG_Base_Monster_Controller extends KFMonsterController;

event SeePlayer(Pawn SeenPlayer)
{
	if((ChooseAttackCounter<2 || ChooseAttackTime!=Level.TimeSeconds) && SetEnemy(SeenPlayer))
		WhatToDoNext(3);
	if(Enemy==SeenPlayer)
	{
		VisibleEnemy=Enemy;
		EnemyVisibilityTime=Level.TimeSeconds;
		bEnemyIsVisible=true;
	}
}

function bool FindNewEnemy()
{
	local Pawn BestEnemy;
	local bool bSeeNew, bSeeBest;
	local float BestDist, NewDist;
	local Controller PC;
	local KFHumanPawn C;
	local Pawn NewEnemy;

	if(KFM.bNoAutoHuntEnemies || Pawn==none || Pawn.Health<0)
		Return False;
	if(KFM.bCannibal && pawn.Health<(1.0-KFM.FeedThreshold)*pawn.HealthMax || Level.Game.bGameEnded)
	{
		for(PC=Level.ControllerList; PC!=None; PC=PC.NextController)
		{
			if(ID_Weapon_Base_Turret_Sentry_AI(PC)!=none && PC.Pawn!=none && ID_Weapon_Base_Turret_Sentry(PC.Pawn).Health>0)
			{
				NewEnemy=PC.Pawn;
			}
			else
			{
				if(PC.Pawn==none || ID_RPG_Base_HumanPawn(PC.Pawn)==none)
					continue;
				C=KFHumanPawn(PC.Pawn);
				if(C==None || C.Health<=0 || !ID_RPG_Base_HumanPawn(C).CanBeAttacked())
					Continue;
				NewEnemy=PC.Pawn;
			}   
			if(NewEnemy==none)
				continue;
			if(BestEnemy==None)
			{
				BestEnemy=NewEnemy;
				BestDist=VSize(BestEnemy.Location - Pawn.Location);
				bSeeBest=CanSee(NewEnemy);
			}
			else
			{
				if(NewEnemy==none)
					continue;
				NewDist=VSize(NewEnemy.Location - Pawn.Location);
				if(!bSeeBest || (NewDist<BestDist))
				{
					bSeeNew=CanSee(NewEnemy);
					if(NewDist<BestDist)
					{
						BestEnemy=NewEnemy;
						BestDist=NewDist;
						bSeeBest=bSeeNew;
					}
				}
			}
		}
	}
	else
	{
		for(PC=Level.ControllerList; PC!=None; PC=PC.NextController)
		{
			if((ID_Weapon_Base_Turret_Sentry_AI(PC)!=none && PC.Pawn!=none && ID_Weapon_Base_Turret_Sentry(PC.Pawn).Health>0) || 
				(PC.bIsPlayer && (PC.Pawn!=None) && PC.Pawn.Health>0 && ID_RPG_Base_HumanPawn(PC.Pawn)!=none && ID_RPG_Base_HumanPawn(PC.Pawn).CanBeAttacked()))
			{
				NewEnemy=PC.Pawn;
			}
			if(BestEnemy==None)
			{
				BestEnemy=NewEnemy;
				if(BestEnemy!=none)
				{
					BestDist=VSize(BestEnemy.Location - Pawn.Location);
					bSeeBest=CanSee(BestEnemy);
				}
			}
			else
			{
				NewDist=VSize(NewEnemy.Location - Pawn.Location);
				if(!bSeeBest || (NewDist<BestDist))
				{
					bSeeNew=CanSee(NewEnemy);
					if(NewDist<BestDist)
					{
						BestEnemy=NewEnemy;
						BestDist=NewDist;
						bSeeBest=bSeeNew;
					}
				}
			}
		}
	}

	if(BestEnemy==Enemy)
		return false;

	if(BestEnemy!=None)
	{
		ChangeEnemy(BestEnemy,CanSee(BestEnemy));
		return true;
	}
	return false;
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	if(NoiseMaker!=none && FastTrace(NoiseMaker.Location,Pawn.Location))
	{
		if((ChooseAttackCounter<2 || ChooseAttackTime!=Level.TimeSeconds) && SetEnemy(NoiseMaker.instigator))
			WhatToDoNext(2);
	}
}

function bool SetEnemy(Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride)
{
	if(Enemy!=none && ClassIsChildOf(Enemy.class, class'ID_RPG_Base_Monster'))
		Enemy=none;
	if(NewEnemy==none || ClassIsChildOf(NewEnemy.class, class'ID_RPG_Base_Monster') || (ID_RPG_Base_HumanPawn(NewEnemy)!=none && !ID_RPG_Base_HumanPawn(NewEnemy).CanBeAttacked()))
		return false;
		
	if(!bHateMonster && KFHumanPawnEnemy(NewEnemy)!=None && KFHumanPawnEnemy(NewEnemy).AttitudeToSpecimen<=ATTITUDE_Ignore)
		Return False; // In other words, dont attack human pawns as long as they dont damage me or hates me.
	if(KFM.Intelligence>=BRAINS_Mammal && Enemy!=None && NewEnemy!=None && NewEnemy!=Enemy && NewEnemy.Controller!=None && NewEnemy.Controller.bIsPlayer)
	{
		if(LineOfSightTo(Enemy) && VSize(Enemy.Location-Pawn.Location)<VSize(NewEnemy.Location-Pawn.Location))
			Return False;
		Enemy=None;
	}
	if(bHateMonster && KFMonster(NewEnemy)!=None && NewEnemy.Controller!=None && (NewEnemy.Controller.Target==Self || FRand()<0.15)
	&& NewEnemy.Health>0 && VSize(NewEnemy.Location-Pawn.Location)<1500 && LineOfSightTo(NewEnemy)) // Get pissed at this fucker..
	{
		ChangeEnemy(NewEnemy,CanSee(NewEnemy));
		return true;
	}
	if(Super.SetEnemy(NewEnemy,bHateMonster))
	{
		if(!bTriggeredFirstEvent)
		{
			bTriggeredFirstEvent=True;
			if(KFM.FirstSeePlayerEvent!='')
				TriggerEvent(KFM.FirstSeePlayerEvent,Pawn,Pawn);
		}
		Return True;
	}
	Return False;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
	if(NewEnemy==none || ClassIsChildOf(NewEnemy.class, class'ID_RPG_Base_Monster'))
		return;
	if(ID_RPG_Base_HumanPawn(NewEnemy)!=none && !ID_RPG_Base_HumanPawn(NewEnemy).CanBeAttacked())
	{
		Enemy=none;
		EnemyChanged(false);
		return;
	}
	OldEnemy=Enemy;
	Enemy=NewEnemy;
	EnemyChanged(bCanSeeNewEnemy);
}

defaultproperties
{
}
