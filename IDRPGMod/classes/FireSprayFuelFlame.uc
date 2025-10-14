class FireSprayFuelFlame extends Emitter;

var() float BurnInterval;
var Actor Parent;
var() int FlameDamage;

simulated function PostBeginPlay()
{
	SetTimer(BurnInterval, true);
}

simulated function Timer()
{
	local Material SurfaceMat;
	local int HitSurface;
	local Vector HitLocation, HitNormal;
	local Rotator EffectDir;
	local Actor Other;

	Other = Trace(HitLocation, HitNormal, Location + (vector(Rotation) * float(32)), Location - (vector(Rotation) * float(16)), true,, SurfaceMat);
	EffectDir = rotator(MirrorVectorByNormal(vector(Rotation), HitNormal));
	
	if((Vehicle(Other) != none) && Other.SurfaceType == 0)
	{
		HitSurface = 3;
	}
	else
	{
		if(((Other != none) && !Other.IsA('LevelInfo')) && Other.SurfaceType != 0)
		{
			HitSurface = Other.SurfaceType;
		}
		else
		{
			if(SurfaceMat != none)
			{
				HitSurface = SurfaceMat.SurfaceType;
			}
		}
	}  
}

defaultproperties
{
     BurnInterval=1.000000
     FlameDamage=1000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         Acceleration=(Z=100.000000)
         ColorScale(0)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Z=(Min=0.670000,Max=2.000000))
         MaxParticles=7
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=3.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=2.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=56.000000,Max=45.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.750000,Max=1.250000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=5.000000,Max=15.000000))
     End Object
     Emitters(0)=SpriteEmitter'IDRPGMod.FireSprayFuelFlame.SpriteEmitter10'

     LightType=LT_Pulse
     LightHue=30
     LightSaturation=100
     LightBrightness=100.000000
     LightRadius=4.000000
     bNoDelete=False
     AmbientSound=Sound'Amb_Destruction.Fire.Kessel_Fire_Small_Vehicle'
     LifeSpan=0.500000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=500.000000
}
