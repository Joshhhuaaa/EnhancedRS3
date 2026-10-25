//=============================================================================
// Breath.
//=============================================================================
class R6BreathEmitter extends R6SFX
    placeable;

function PostBeginPlay()
{
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=BreathEmitter
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=8
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Winter.Breath'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=6.000000)
         FadeOutFactor=(W=4.000000,X=4.000000,Y=4.000000,Z=4.000000)
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSizeRange=(X=(Min=3.000000,Max=8.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         InitialDelayRange=(Max=5.000000)
         StartVelocityRange=(Y=(Min=-5.000000,Max=-15.000000))
         Name="BreathEmitter"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.BreathEmitter'
     RemoteRole=ROLE_None
}
