//=============================================================================
//  R6ReferenceIcons.uc : icons in the maps for planning only.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Joel Tremblay
//=============================================================================

class R6ReferenceIcons extends actor
    abstract;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

defaultproperties
{
     RemoteRole=ROLE_None
     m_eDisplayFlag=DF_ShowOnlyInPlanning
     m_bUseR6Availability=True
     m_bSkipHitDetection=True
     bAlwaysRelevant=True
     m_bSpriteShowFlatInPlanning=True
}
