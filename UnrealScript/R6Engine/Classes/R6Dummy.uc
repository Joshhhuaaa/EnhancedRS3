//===============================================================================
//  [R6Dummy] 
//===============================================================================

class R6Dummy extends actor;

#exec NEW StaticMesh File="models\R6LHDummy.Ase" Name="R6DummyMesh"

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'R6Engine.R6DummyMesh'
}
