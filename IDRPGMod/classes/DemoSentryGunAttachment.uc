class DemoSentryGunAttachment extends PipeBombAttachment;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TweenAnim('Folded',0.01f);
}

defaultproperties
{
     Mesh=SkeletalMesh'DZResPack.SentryMesh'
     Skins(0)=Texture'DZResPack.Sentry.SentrySpistonDiffuse'
     Skins(1)=Texture'DZResPack.Sentry.SentryFlapDiffuse'
     Skins(2)=Texture'DZResPack.SDemoSkin'
     Skins(3)=Shader'DZResPack.Sentry.InvisibleWeaponsFlash'
     Skins(4)=Shader'DZResPack.Sentry.InvisibleWeaponsFlash'
     Skins(5)=Shader'DZResPack.Sentry.InvisibleWeaponsFlash'
     Skins(6)=Shader'DZResPack.Sentry.InvisibleWeaponsFlash'
     Skins(7)=Shader'DZResPack.Sentry.InvisibleWeaponsFlash'
     Skins(8)=Shader'DZResPack.Sentry.InvisibleWeaponsFlash'
}
