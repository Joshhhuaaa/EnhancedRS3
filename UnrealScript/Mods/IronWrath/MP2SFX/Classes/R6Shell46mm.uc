class R6Shell46mm extends R6Shell;

#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP23rdWeapons_SM.usx PACKAGE=MP23rdWeapons_SM

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter46mm
        StaticMesh=StaticMesh'MP23rdWeapons_SM.Ammo.R63rd46mmGerman'
        UseRotationFrom=PTRS_Actor
        MaxParticles=30
        UseCollision=true
        RespawnDeadParticles=false
        SpinParticles=true
        DampRotation=true
        UseRegularSizeScale=false
        AutomaticInitialSpawning=false
        SecondsBeforeInactive=0.0
        Acceleration=(X=0.0,Y=0.0,Z=-1500.0)
        ExtentMultiplier=(X=0.0,Y=0.0,Z=0.0)
        DampingFactorRange=(X=(Min=-0.5,Max=0.5),Y=(Min=-0.5,Max=0.5),Z=(Min=0.1,Max=0.5))
        SpinsPerSecondRange=(X=(Min=1.0,Max=1.0),Y=(Min=1.0,Max=1.0),Z=(Min=1.0,Max=1.0))
        RotationDampingFactorRange=(X=(Max=1.0),Y=(Max=1.0),Z=(Max=1.0))
        StartVelocityRange=(X=(Min=450.0,Max=500.0),Y=(Min=-20.0,Max=20.0),Z=(Max=-200.0))
        VelocityLossRange=(X=(Max=1.0))
        Name="MeshEmitter46mm"
    End Object
    Emitters[0]=MeshEmitter'MP2SFX.MeshEmitter46mm'
    bDynamicLight=true
}
