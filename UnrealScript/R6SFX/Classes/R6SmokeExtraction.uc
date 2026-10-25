//=============================================================================
// R6SmokeExtraction
//=============================================================================
class R6SmokeExtraction extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSmokeExtraction1
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=15.000000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=1.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Extraction'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         Acceleration=(X=-5.000000,Z=5.000000)
         DampingFactorRange=(X=(Min=-1.000000),Y=(Min=-1.000000),Z=(Min=-1.000000))
         StartLocationOffset=(X=20.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000),Y=(Min=-0.050000,Max=0.050000))
         StartSizeRange=(X=(Min=5.000000,Max=20.000000))
         LifetimeRange=(Min=20.000000,Max=25.000000)
         StartVelocityRange=(X=(Min=20.000000,Max=50.000000),Y=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Max=1.500000),Y=(Max=1.000000),Z=(Min=0.200000,Max=0.200000))
         Name="SpriteEmitterSmokeExtraction1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterSmokeExtraction1'
     bNetDirty=True
     bAlwaysRelevant=True
     m_bDeleteOnReset=False
}
