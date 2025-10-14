class LureNadeProj extends Nade;

var bool bActive;

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	
	if( Level.NetMode!=NM_DedicatedServer )
	{
		Trail = Spawn(class'FX_FGrenTrail',self,, Location, Rotation);
		Trail.Lifespan = LifeSpan;
	}	
}

simulated function Landed(Vector HitNormal)
{
	if(!bActive)
	{
		bActive = true;
		Spawn(class'LureNadeLure',,, Location, rotator(HitNormal));
	}
	HitWall(HitNormal, none);
	SetTimer(ExplodeTimer, false);
}

simulated function HitWall(Vector HitNormal, Actor Wall)
{
	local Vector VNorm;
	local PlayerController PC;

	if((Pawn(Wall) != none) || GameObjective(Wall) != none)
	{
		Explode(Location, HitNormal);
		return;
	}
	VNorm = (Velocity Dot HitNormal) * HitNormal;
	Velocity = (-VNorm * DampenFactor) + ((Velocity - VNorm) * DampenFactorParallel);
	RandSpin(100000.0);
	DesiredRotation.Roll = 0;
	RotationRate.Roll = 0;
	Speed = VSize(Velocity);
	
	if(Speed < float(20))
	{
		bBounce = false;
		PrePivot.Z = -1.50;
		SetPhysics(Phys_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
		
		/*if(Trail != none)
		{
			Trail.mRegen = false;
		}*/
	}
	else
	{
		if((Level.NetMode != NM_DedicatedServer) && Speed > float(250))
		{
			PlaySound(ImpactSound, SLOT_INteract);
		}
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
		
		if(((!Level.bDropDetail && Level.DetailMode != 0) && (Level.TimeSeconds - LastSparkTime) > 0.50) && EffectIsRelevant(Location, false))
		{
			PC = Level.GetLocalPlayerController();
			
			if((PC.ViewTarget != none) && VSize(PC.ViewTarget.Location - Location) < float(6000))
			{
				Spawn(HitEffectClass,,, Location, rotator(HitNormal));
			}
			LastSparkTime = Level.TimeSeconds;
		}
	} 
}

final simulated function ProcessGravity(float Delta)
{
	local KFMonster A;
	local Vector D;
	local float dist;
	
	foreach VisibleCollidingActors(class'KFMonster', A, 500.0)
	{
		if((((A.Class == Class) || A.bStatic) || !A.bMovable) || A == none)
		{
			continue;			
		}
		
		if((A.Physics == PHYS_Walking) || A.Physics == PHYS_None)
		{
			A.SetPhysics(PHYS_Falling);
		}
		D = Location - A.Location;
		dist = VSize(D);
		
		if((ZombieBoss(A) != none) && dist < float(50))
		{
			BlowUp(Location);
			Destroy();
		}
		
		if((A.Physics == PHYS_Karma) || A.Physics == PHYS_KarmaRagdoll)
		{
			A.KAddImpulse(Normal(D) * (((float(360) - dist) * Delta) * 0.50), vect(0.0, 0.0, 0.0));
			continue;
		}
		
		if(dist > float(500))
		{
			A.Velocity += ((Normal(D) * (float(360) - dist)) * Delta);
			continue;
		}
		A.Velocity = Normal(D) * 150.0;		
	}	
}

simulated function Tick(float Delta)
{
	ProcessGravity(Delta);
}

simulated function Destroyed()
{
	if(Trail!=None)
	{			
		Trail.mRegen=false;
		Trail.Destroy();
	}
	
	super.Destroyed();	
}

defaultproperties
{
     ExplodeTimer=5.000000
     Speed=1000.000000
     MaxSpeed=2000.000000
     StaticMesh=StaticMesh'PatchStatics.StunProjectile'
     LifeSpan=6.000000
}
