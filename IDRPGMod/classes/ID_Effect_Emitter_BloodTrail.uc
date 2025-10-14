class ID_Effect_Emitter_BloodTrail extends emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=2.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.350000
         MaxParticles=4
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=2.000000)
         SpinsPerSecondRange=(X=(Max=0.300000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.450000)
         StartSizeRange=(X=(Min=22.000000,Max=35.000000),Y=(Min=22.000000,Max=35.000000),Z=(Min=22.000000,Max=35.000000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff'
         TextureUSubdivisions=8
         TextureVSubdivisions=4
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.350000,Max=0.700000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=20.000000,Max=100.000000))
     End Object
     Emitters(0)=SpriteEmitter'IDRPGMod.ID_Effect_Emitter_BloodTrail.SpriteEmitter'

}
