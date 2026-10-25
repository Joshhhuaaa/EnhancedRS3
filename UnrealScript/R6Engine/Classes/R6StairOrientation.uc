/*=============================================================================
// R6StairOrientation - automatically placed in StairVolume
============================================================================= */
class R6StairOrientation extends Actor
	notplaceable
	native;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var() R6StairVolume m_pStairVolume;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( m_pStairVolume == none )
    {
        log( "WARNING: " $name$ " is not linked to a stair volume. Remove it." );
    }
}

defaultproperties
{
     m_eDisplayFlag=DF_ShowOnlyInPlanning
     bStatic=True
     bHidden=True
     m_bSkipHitDetection=True
     m_bSpriteShowFlatInPlanning=True
     Texture=Texture'R6Planning.Icons.PlanIcon_Stairs'
}
