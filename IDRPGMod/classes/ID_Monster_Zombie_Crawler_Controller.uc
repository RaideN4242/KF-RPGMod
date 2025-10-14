class ID_Monster_Zombie_Crawler_Controller extends ID_RPG_Base_Monster_Controller;


var	float	LastPounceTime;
var	bool	bDoneSpottedCheck;



function bool IsInPounceDist(actor PTarget)
{
  local vector DistVec;
  local float time;

  local float HeightMoved;
  local float EndHeight;

  //work out time needed to reach target

  DistVec = pawn.location - PTarget.location;
  DistVec.Z=0;

  time = vsize(DistVec)/ID_Monster_Zombie_Crawler(Pawn).PounceSpeed;

  // vertical change in that time

  //assumes downward grav only
  HeightMoved = Pawn.JumpZ*time + 0.5*pawn.PhysicsVolume.Gravity.z*time*time;

  EndHeight = pawn.Location.z +HeightMoved;

  //log(Vsize(Pawn.Location - PTarget.Location));


  if((abs(EndHeight - PTarget.Location.Z) < Pawn.CollisionHeight + PTarget.CollisionHeight) &&
  VSize(pawn.Location - PTarget.Location) < KFMonster(Pawn).MeleeRange * 5)
	return true;
  else
	return false;
}

function bool FireWeaponAt(Actor A)
{
	local vector aFacing,aToB;
	local float RelativeDir;

	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;

	if(CanAttack(A))
	{
	 Target = A;
	 Monster(Pawn).RangedAttack(Target);
	}
	else
	{
		//TODO - base off land time rather than launch time?
		if((LastPounceTime + (4.5 - (FRand() * 3.0))) < Level.TimeSeconds )
		{
			aFacing=Normal(Vector(Pawn.Rotation));
			// Get the vector from A to B
			aToB=A.Location-Pawn.Location;

			RelativeDir = aFacing dot aToB;
			if ( RelativeDir > 0.85 )
			{
				//Facing enemy
				if(IsInPounceDist(A) )
				{
					if(ID_Monster_Zombie_Crawler(Pawn) != none && ID_Monster_Zombie_Crawler(Pawn).DoPounce()==true )
						LastPounceTime = Level.TimeSeconds;
				}
			}
		}
	}
	return false;
}

function bool NotifyLanded(vector HitNormal)
{
  if( ID_Monster_Zombie_Crawler(Pawn) != none && ID_Monster_Zombie_Crawler(Pawn).bPouncing )
  {
	// restart pathfinding from landing location
	GotoState('hunting');
	return false;
  }
  else
	return super(KFMonsterController).NotifyLanded(HitNormal);
}

defaultproperties
{
}
