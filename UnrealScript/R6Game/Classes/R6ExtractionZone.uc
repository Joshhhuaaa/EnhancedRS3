//=============================================================================
//  R6ExtractionZone.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Chaouky Garram
//=============================================================================
class R6ExtractionZone extends R6AbstractExtractionZone
    placeable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

function Touch(actor Other)
{
    // if pawn entered zone and level.game exists in this game type
    if ( (R6Pawn(Other) != none) && (Level.Game != none))
    {
        R6Pawn(Other).EnteredExtractionZone(self); // called before
        R6AbstractGameInfo(Level.Game).EnteredExtractionZone(other);
    }
}

function UnTouch(actor Other)
{
    // if pawn left zone and level.game exists in this game type
    if ( (R6Pawn(Other) != none) && (Level.Game != none))
    {
        R6AbstractGameInfo(Level.Game).LeftExtractionZone(other);
        R6Pawn(Other).LeftExtractionZone(self);
    }
}

defaultproperties
{
     bHidden=False
     m_bUseR6Availability=True
     m_bSkipHitDetection=True
     bCollideActors=True
     bCollideWorld=True
     DrawScale=12.000000
     CollisionRadius=128.000000
     CollisionHeight=20.000000
     Texture=Texture'R6Planning.Icons.PlanIcon_ZoneDefault'
     m_PlanningColor=(B=181,G=134,R=24)
}
