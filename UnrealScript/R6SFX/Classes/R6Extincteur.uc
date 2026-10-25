//=============================================================================
// R6Extincteur.
//=============================================================================
class R6Extincteur extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterExtincteur2
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=50
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=10.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Extincteur'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-300.000000)
         StartLocationOffset=(Z=-150.000000)
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000))
         StartSpinRange=(X=(Min=-0.050000,Max=0.050000))
         StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=2500.000000,Max=5000.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=12.000000,Max=12.000000))
         Name="SpriteEmitterExtincteur2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterExtincteur2'
     bAlwaysRelevant=True
     LifeSpan=30.000000
}
