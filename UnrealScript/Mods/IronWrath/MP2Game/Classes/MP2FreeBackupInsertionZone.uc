class MP2FreeBackupInsertionZone extends PlayerStart;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2Planning.utx PACKAGE=MP2Planning

var(FreeBackup) int m_iSkinIndex;
var(FreeBackup) bool m_bHighPriority;

defaultproperties
{
    m_iSkinIndex=-1
    m_eDisplayFlag=DF_ShowOnlyInPlanning
    bHidden=false
    m_bUseR6Availability=true
    bUnlit=true
    m_b3DSound=false
    DrawScale=3.0
    Texture=Texture'MP2Planning.Icons.NF'
    m_PlanningColor=(R=24,G=134,B=181,A=255)
}
