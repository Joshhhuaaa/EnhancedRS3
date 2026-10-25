//=============================================================================
// R6Shell10mmAuto.
//=============================================================================
class R6Shell10mmAuto extends R6Shell;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=SpriteEmitter10mmAuto
         StaticMesh=StaticMesh'R63rdWeapons_SM.Ammo.R63rd10mmAuto'
         UseRotationFrom=PTRS_Actor
         MaxParticles=30
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         Acceleration=(Z=-1500.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartVelocityRange=(X=(Min=450.000000,Max=500.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Max=-200.000000))
         VelocityLossRange=(X=(Max=1.000000))
         Name="SpriteEmitter10mmAuto"
     End Object
     Emitters(0)=MeshEmitter'R6SFX.SpriteEmitter10mmAuto'
     bDynamicLight=True
}
