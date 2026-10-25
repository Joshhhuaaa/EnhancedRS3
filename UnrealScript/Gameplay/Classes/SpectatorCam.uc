//=============================================================================
// SpectatorCam.
//=============================================================================
class SpectatorCam extends KeyPoint;

var() bool bSkipView; // spectators skip this camera when flipping through cams
var() float FadeOutTime;	// fade out time if used as EndCam

defaultproperties
{
     FadeOutTime=5.000000
     DrawType=DT_Mesh
     bClientAnim=True
     bDirectional=True
     CollisionRadius=20.000000
     CollisionHeight=40.000000
     Texture=Texture'Engine.S_Camera'
}
