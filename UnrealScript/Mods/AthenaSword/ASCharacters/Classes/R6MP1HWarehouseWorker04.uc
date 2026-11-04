class R6MP1HWarehouseWorker04 extends R6HWorkerShip01;

#exec OBJ LOAD FILE=..\Mods\AthenaSword\Textures\R6CharactersMP1_t.utx PACKAGE=R6CharactersMP1_t

defaultproperties
{
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel364
        KConvulseSpacing=(Min=0.5,Max=2.2)
        KSkeleton="terroskel"
        KStartEnabled=true
        bHighDetailOnly=false
        KLinearDamping=0.5
        KAngularDamping=0.5
        KBuoyancy=1.0
        KVelDropBelowThreshold=50.0
        KFriction=0.6
        KRestitution=0.3
        KImpactThreshold=150.0
        Name="KarmaParamsSkel364"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel364'
    Skins[0]=Texture'R6CharactersMP1_t.hostage.MP1_R6HWorkerShip1_warehouse_4'
}
