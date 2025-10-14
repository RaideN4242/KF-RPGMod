class ID_Monster_Zombie_FleshPound_AvoidArea extends FleshPoundAvoidArea;

state BigMeanAndScary
{
Begin:
	StartleBots();
	Sleep(1.0);
	GoTo('Begin');
}

function InitFor(KFMonster V)
{
	if (V != None)
	{
		KFMonst = V;
		SetCollisionSize(KFMonst.CollisionRadius *3, KFMonst.CollisionHeight + CollisionHeight);
		SetBase(KFMonst);
		GoToState('BigMeanAndScary');
	}
}

function Touch( actor Other )
{
	if ( (Pawn(Other) != None) && RelevantTo(Pawn(Other)) && ID_RPG_Base_Monster_Controller(Pawn(Other).Controller) != none )
	{
		ID_RPG_Base_Monster_Controller(Pawn(Other).Controller).AvoidThisMonster(KFMonst);
	}
}

function bool RelevantTo(Pawn P)
{
	return ( KFMonst != none && VSizeSquared(KFMonst.Velocity) >= 75 && Super.RelevantTo(P)
	&& KFMonst.Velocity dot (P.Location - KFMonst.Location) > 0  );
}

function StartleBots()
{
	local ID_RPG_Base_Monster P;

	if (KFMonst != None)
		ForEach CollidingActors(class'ID_RPG_Base_Monster', P, CollisionRadius)
			if ( RelevantTo(P) )
			{
				if (ID_RPG_Base_Monster_Controller(P.Controller) != none)
					ID_RPG_Base_Monster_Controller(P.Controller).AvoidThisMonster(KFMonst);
			}
}

defaultproperties
{
}
