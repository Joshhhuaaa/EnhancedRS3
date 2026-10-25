//============================================================================//
//R6SmokeEmitter_02
//============================================================================//
class R6SmokeEmitter_02 extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6SmokeEmitter_02_01
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         FadeOutStartTime=5.000000
         FadeInEndTime=1.000000
         ParticlesPerSecond=2.000000
         Texture=Texture'R6SFX_T.Winter.Breath'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-40.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=100.000000,Max=150.000000))
         VelocityLossRange=(Z=(Max=0.600000))
         Name="SpriteEmitterR6SmokeEmitter_02_01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterR6SmokeEmitter_02_01'
}
