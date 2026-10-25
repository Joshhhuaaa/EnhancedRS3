//=============================================================================
// R6FFSteamImpact.
//=============================================================================
class R6FFSteamImpact extends R6LimitedSFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterFFSteam1
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=75
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=15.000000
         Texture=Texture'R6SFX_T.Impact.Water_Smoke'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=75.000000)
         Acceleration=(Z=-20.000000)
         StartMassRange=(Max=10.000000)
         SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.080000,Max=0.080000))
         StartSizeRange=(X=(Min=1.000000,Max=0.500000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=100.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Min=1.200000,Max=1.200000),Y=(Min=1.200000,Max=1.200000),Z=(Min=1.200000,Max=1.200000))
         Name="SpriteEmitterFFSteam1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterFFSteam1'
     bAlwaysRelevant=True
     LifeSpan=60.000000
}
