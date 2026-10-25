//=============================================================================
// R6C4Effect
//=============================================================================
class R6C4Effect extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterC4
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=12
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         FadeInEndTime=4.000000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=None
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=2.000000)
         StartLocationOffset=(Z=25.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=40.000000,Max=60.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-3000.000000,Max=3000.000000))
         VelocityLossRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=12.000000,Max=12.000000),Z=(Max=1.000000))
         Name="SpriteEmitterC4"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterC4'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterC4B
         MaxParticles=1
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Flare.Glare'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         LifetimeRange=(Min=0.100000,Max=0.100000)
         Name="SpriteEmitterC4B"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterC4B'
}
