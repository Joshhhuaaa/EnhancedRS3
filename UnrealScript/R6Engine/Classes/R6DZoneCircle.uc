//=============================================================================
//  R6DZoneCircle.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================

class R6DZoneCircle extends R6DeploymentZone
	placeable
    native;

var(R6DZone)    FLOAT   m_fRadius;

defaultproperties
{
     m_fRadius=250.000000
}
