//=============================================================================
// R6TearsGazGrenadeEffect
//=============================================================================
class R6TearsGazGrenadeEffect extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterGasGrenade
         DrawStyle=PTDS_Modulated
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=45.000000
         FadeInEndTime=4.000000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Tear_Gaz'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=1.000000)
         StartLocationOffset=(Z=25.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
         StartSizeRange=(X=(Min=80.000000,Max=150.000000))
         LifetimeRange=(Min=60.000000,Max=60.000000)
         StartVelocityRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-3000.000000,Max=3000.000000))
         VelocityLossRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=12.000000,Max=12.000000),Z=(Max=1.000000))
         Name="SpriteEmitterGasGrenade"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterGasGrenade'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterGasGrenade01
         DrawStyle=PTDS_Modulated
         MaxParticles=5
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=45.000000
         FadeInEndTime=4.000000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Tear_Gaz'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
         StartSizeRange=(X=(Min=60.000000,Max=150.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=60.000000,Max=60.000000)
         StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Min=1000.000000,Max=2000.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=12.000000,Max=12.000000))
         Name="SpriteEmitterGasGrenade01"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterGasGrenade01'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterGasGrenade02
         DrawStyle=PTDS_Modulated
         MaxParticles=5
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=45.000000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=3000.000000
         Texture=Texture'R6SFX_T.Grenade.Tear_Gaz'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=1.000000)
         StartLocationOffset=(Z=50.000000)
         SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
         StartSizeRange=(X=(Min=60.000000,Max=150.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=60.000000,Max=60.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000))
         Name="SpriteEmitterGasGrenade02"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterGasGrenade02'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterGasGrenade03
         MaxParticles=1
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=3000.000000
         Texture=Texture'R6SFX_T.Flare.Glare'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         LifetimeRange=(Min=0.100000,Max=0.100000)
         Name="SpriteEmitterGasGrenade03"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteEmitterGasGrenade03'
     bDynamicLight=True
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=60.000000
}
