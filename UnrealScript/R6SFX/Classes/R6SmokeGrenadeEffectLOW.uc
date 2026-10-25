//=============================================================================
// R6SmokeGrenadeEffectLOW
//=============================================================================
class R6SmokeGrenadeEffectLOW extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSmokeLOW1
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=12
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=1.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_04'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=80.000000)
         DampingFactorRange=(X=(Min=-1.000000),Y=(Min=-1.000000),Z=(Min=-1.000000))
         StartLocationOffset=(X=20.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.030000),Y=(Min=-0.030000,Max=0.030000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         LifetimeRange=(Min=40.000000,Max=40.000000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=25.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.200000,Max=0.200000))
         Name="SpriteEmitterSmokeLOW1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterSmokeLOW1'
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=60.000000
}
