class HeatEm extends VehicleExhaustEffect;

defaultproperties
{
     MaxSpritePPSOne=20
     MaxSpritePPSTwo=22
     IdleSpritePPSOne=5
     IdleSpritePPSTwo=7
     Begin Object Class=SpriteEmitter Name=SpriteEmitter62
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         Acceleration=(X=70.000000,Z=20.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.100000
         MaxParticles=20
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.075000,Max=0.075000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=0.500000)
         SizeScale(2)=(RelativeTime=0.370000,RelativeSize=1.100000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.500000)
         StartSizeRange=(X=(Min=3.750000,Max=7.500000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=2.500000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Vehicles.Gasoline_Smoke'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=5.625000,Max=37.500000),Y=(Min=-5.625000,Max=5.625000),Z=(Min=-5.625000,Max=5.625000))
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.300000,RelativeVelocity=(X=0.200000,Y=1.000000,Z=1.000000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(Y=0.400000,Z=0.400000))
     End Object
     Emitters(0)=SpriteEmitter'IDRPGMod.HeatEm.SpriteEmitter62'

     AutoDestroy=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=8.000000
     bHardAttach=False
     bDirectional=True
}
