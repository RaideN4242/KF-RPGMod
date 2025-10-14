class MP7DAttachment extends DualiesAttachment;

var() editinline Emitter mTracer2;

simulated function UpdateTacBeam(float Dist);
simulated function TacBeamGone();

simulated event ThirdPersonEffects()
{
	local PlayerController PC;

	//Prevents tracers from spawning if player is using the flashlight function of the 9mm
	if(FiringMode==1)
		return;

	if(Level.NetMode==NM_DedicatedServer || Instigator==None)
		return;

	//new Trace FX-Ramm
	if(FiringMode==0)
	{
		if(OldSpawnHitCount!=SpawnHitCount)
		{
			OldSpawnHitCount=SpawnHitCount;
			GetHitInfo();
			PC=Level.GetLocalPlayerController();
			if((Instigator!=None && Instigator.Controller==PC) || (VSize(PC.ViewTarget.Location-mHitLocation)<4000))
			{
				Spawn(class'ROBulletHitEffect',,, mHitLocation, Rotator(-mHitNormal));
				CheckForSplash();
			}
		}
	}

  	if(FlashCount>0)
	{
		if(KFPawn(Instigator)!=None)
		{
			//We don't really have alt fire, but use the alt fire anims as the left hand firing anims
			if(bMyFlashTurn)
			{
				KFPawn(Instigator).StartFiringX(false,bRapidFire);
			}
			else
			{
				KFPawn(Instigator).StartFiringX(true,bRapidFire);
			}
		}

		if(bDoFiringEffects)
		{
			PC=Level.GetLocalPlayerController();

			if((Level.TimeSeconds-LastRenderTime>0.2) && (Instigator.Controller!=PC))
				return;

			WeaponLight();
			DoFlashEmitter();
			SpawnTracer();			

			if(!bIsOffHand)
			{
				if(!bMyFlashTurn)
				{
					ThirdPersonShellEject();
				}
				else if(brother!=None)
				{
					brother.ThirdPersonShellEject();
				}
			}
		}
	}
	else
	{
		GotoState('');
		if(KFPawn(Instigator)!=None)
			KFPawn(Instigator).StopFiring();
	}
}

simulated function SpawnTracer()
{
	local vector SpawnLoc, SpawnDir, SpawnVel;
	local float hitDist;

	if(!bDoFiringEffects)
	{
		return;
	}

	if(mTracer==None)
		mTracer=Spawn(mTracerClass);
	
	if(mTracer2==None)
		mTracer2=Spawn(mTracerClass);

	if(mTracer!=None)
	{
		SpawnLoc=GetTracerStart();
		mTracer.SetLocation(SpawnLoc);

		hitDist=VSize(mHitLocation-SpawnLoc)-mTracerPullback;

		SpawnDir=Normal(mHitLocation-SpawnLoc);

		if(hitDist>mTracerMinDistance)
		{
			SpawnVel=SpawnDir * mTracerSpeed;
			mTracer.Emitters[0].StartVelocityRange.X.Min=SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.X.Max=SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.Y.Min=SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Y.Max=SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Z.Min=SpawnVel.Z;
			mTracer.Emitters[0].StartVelocityRange.Z.Max=SpawnVel.Z;

			mTracer.Emitters[0].LifetimeRange.Min=hitDist/mTracerSpeed;
			mTracer.Emitters[0].LifetimeRange.Max=mTracer.Emitters[0].LifetimeRange.Min;

			mTracer.SpawnParticle(1);
		}
	}
	
	if(mTracer2!=None)
	{
		SpawnLoc=GetTracerStart();
		mTracer2.SetLocation(SpawnLoc);
		hitDist=VSize(mHitLocation-SpawnLoc)-mTracerPullback;
		SpawnDir=Normal(mHitLocation-SpawnLoc);

		if(hitDist>mTracerMinDistance)
		{
			SpawnVel=SpawnDir * mTracerSpeed;
			mTracer2.Emitters[0].StartVelocityRange.X.Min=SpawnVel.X;
			mTracer2.Emitters[0].StartVelocityRange.X.Max=SpawnVel.X;
			mTracer2.Emitters[0].StartVelocityRange.Y.Min=SpawnVel.Y;
			mTracer2.Emitters[0].StartVelocityRange.Y.Max=SpawnVel.Y;
			mTracer2.Emitters[0].StartVelocityRange.Z.Min=SpawnVel.Z;
			mTracer2.Emitters[0].StartVelocityRange.Z.Max=SpawnVel.Z;

			mTracer2.Emitters[0].LifetimeRange.Min=hitDist/mTracerSpeed;
			mTracer2.Emitters[0].LifetimeRange.Max=mTracer2.Emitters[0].LifetimeRange.Min;

			mTracer2.SpawnParticle(1);
		}
	}
}

simulated function Destroyed()
{
	if(mTracer2!=None)
		mTracer2.Destroy();

	Super.Destroyed();
}

defaultproperties
{
     BrotherMesh=SkeletalMesh'DZResPack.mp7_3rd'
     bRapidFire=True
     bAltRapidFire=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
     Mesh=SkeletalMesh'DZResPack.mp7_3rd'
}
