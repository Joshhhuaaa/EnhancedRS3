//=============================================================================
// R6ClaymoreMineEffect
//=============================================================================
class R6ClaymoreMineEffect extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterClaymoreMine1
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=15
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
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=2.000000)
         StartLocationOffset=(Z=25.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=3000.000000,Max=-3000.000000))
         VelocityLossRange=(X=(Min=18.000000,Max=18.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=18.000000,Max=18.000000))
         Name="SpriteEmitterClaymoreMine1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterClaymoreMine1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterClaymoreMine2
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=15
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeInEndTime=4.000000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=4.000000)
         Acceleration=(Z=2.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=40.000000,Max=60.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=8.000000,Max=8.000000)
         StartVelocityRange=(X=(Min=-5000.000000,Max=-1000.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Max=250.000000))
         VelocityLossRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=5.000000,Max=5.000000),Z=(Min=1.000000,Max=5.000000))
         Name="SpriteEmitterClaymoreMine2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterClaymoreMine2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterClaymoreMine4
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Modulated
         MaxParticles=300
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=6000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Muzzleflash.12GaugeSparks'
         Acceleration=(Z=-250.000000)
         StartSizeRange=(X=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-2500.000000,Max=-10.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=500.000000))
         VelocityLossRange=(Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         Name="SpriteEmitterClaymoreMine4"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterClaymoreMine4'
     bDynamicLight=True
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=8.000000
}
