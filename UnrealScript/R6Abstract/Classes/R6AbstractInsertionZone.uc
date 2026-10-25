//=============================================================================
//  R6AbstractInsertionZone.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/06 * Created by Aristomenis Kolokathis
//=============================================================================

class R6AbstractInsertionZone extends PlayerStart
    native
    notplaceable;

var(Rainbow) INT m_iInsertionNumber;

defaultproperties
{
     m_eDisplayFlag=DF_ShowOnlyInPlanning
     m_b3DSound=False
     DrawScale=3.000000
}
