//=============================================================================
// R6SmokeFrigo
//=============================================================================
class R6SmokeFrigo extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSmokeFrigo01
         DrawStyle=PTDS_Modulated
         MaxParticles=20
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         FadeOutStartTime=1.000000
         FadeInEndTime=0.200000
         ParticlesPerSecond=2.000000
         Texture=Texture'R6SFX_T.Grenade.Tear_Gaz'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=100.000000,Max=150.000000),Z=(Min=-25.000000,Max=-50.000000))
         VelocityLossRange=(Y=(Max=0.600000),Z=(Max=0.600000))
         Name="SpriteEmitterSmokeFrigo01"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterSmokeFrigo01'
     m_bDeleteOnReset=False
}
