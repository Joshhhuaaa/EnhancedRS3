//============================================================================//
// Class            R6Fire_C
// Created By       Carl Lavoie
//============================================================================//
class R6Fire_C extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteFire_C01
         DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         FadeOutStartTime=5.000000
         FadeInEndTime=5.000000
         InitialParticlesPerSecond=1.000000
         Texture=Texture'R6SFX_T.Grenade.SmokeExplosiveDrum'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartLocationOffset=(Z=75.000000)
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-40.000000))
         SpinsPerSecondRange=(X=(Min=-0.010000,Max=0.010000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=30.000000,Max=50.000000))
         LifetimeRange=(Min=10.000000,Max=12.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=50.000000,Max=50.000000))
         Name="SpriteFire_C01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteFire_C01'
     Begin Object Class=SpriteEmitter Name=SpriteFire_C02
         MaxParticles=3
         FadeOut=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Texture=Texture'R6SFX_T.Flame.Flame01'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         Acceleration=(Z=10.000000)
         StartLocationOffset=(Z=10.000000)
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=0.200000,Max=0.500000)
         StartVelocityRange=(Z=(Min=130.000000,Max=150.000000))
         Name="SpriteFire_C02"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteFire_C02'
     Begin Object Class=SpriteEmitter Name=SpriteFire_C03
         MaxParticles=3
         FadeOut=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Texture=Texture'R6SFX_T.Flame.Flame03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         Acceleration=(Z=10.000000)
         StartLocationOffset=(Z=10.000000)
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=0.200000,Max=0.500000)
         StartVelocityRange=(Z=(Min=130.000000,Max=150.000000))
         Name="SpriteFire_C03"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteFire_C03'
     Begin Object Class=SpriteEmitter Name=SpriteFire_C05
         MaxParticles=3
         FadeOut=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Texture=Texture'R6SFX_T.Flame.FlameBase'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         Acceleration=(Z=200.000000)
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=40.000000,Max=40.000000))
         LifetimeRange=(Min=0.500000,Max=0.500000)
         Name="SpriteFire_C05"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteFire_C05'
}
