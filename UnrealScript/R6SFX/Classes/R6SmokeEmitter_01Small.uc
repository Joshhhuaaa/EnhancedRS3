//=============================================================================
// R6SmokeEmitter_01Small.
//=============================================================================
class R6SmokeEmitter_01Small extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSmoke_01Small_01
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=50
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=4.000000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=2.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         Acceleration=(Z=100.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.100000,Y=0.100000,Z=0.100000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=5.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=150.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Max=20.000000),Y=(Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitterSmoke_01Small_01"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterSmoke_01Small_01'
}
