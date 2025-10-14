Class SentryGunWYDTLazor extends Emitter
	Transient;

var SentryGunWYDT TurretOwner;
var BeamEmitter BM;
var vector TipBoneLocation;

simulated function BeginPlay()
{
	TurretOwner = SentryGunWYDT(Owner);
	BM = BeamEmitter(Emitters[0]);
	LastRenderTime = Level.TimeSeconds;
	Tick(0);
}

simulated function Tick( float Delta )
{
	local vector X,HL,HN;
	TipBoneLocation = TurretOwner.GetBoneCoords('tip2').Origin;
	if( TurretOwner==None )
		Destroy();
	else if( (Level.TimeSeconds-FMax(LastRenderTime,TurretOwner.LastRenderTime))<6.f )
	{
		SetLocation(TipBoneLocation+(TurretOwner.LaserOffset>>TurretOwner.Rotation));
		if( Abs(TurretOwner.CurrentRot.Yaw)<30 && Abs(TurretOwner.CurrentRot.Pitch)<30 )
			SetRotation(TurretOwner.Rotation);
		else SetRotation(TurretOwner.GetActualDirection());

		X = vector(Rotation);
		if( TurretOwner.Trace(HL,HN,TipBoneLocation+X*3000,TipBoneLocation,true)==None )
			HL = TipBoneLocation+X*3000;

		X.X = VSize(HL-TipBoneLocation);
		BM.BeamEndPoints[0].Offset.X.Min = X.X;
		BM.BeamEndPoints[0].Offset.X.Max = X.X;
	}
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamEndPoints(0)=(offset=(X=(Min=800.000000,Max=800.000000)))
         DetermineEndPointBy=PTEP_Offset
         BeamTextureVScale=0.500000
         RotatingSheets=1
         FadeOut=True
         FadeIn=True
         ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.200000,Max=0.300000),Z=(Min=0.010000,Max=0.100000))
         FadeOutStartTime=0.050000
         FadeInEndTime=0.050000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSizeRange=(X=(Min=2.000000,Max=2.000000))
         Texture=Texture'KFX.TransTrailT'
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=BeamEmitter'IDRPGMod.SentryGunWYDTLazor.BeamEmitter0'

     bNoDelete=False
}
