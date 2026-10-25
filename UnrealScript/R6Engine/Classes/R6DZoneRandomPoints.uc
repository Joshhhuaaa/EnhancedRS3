//=============================================================================
//  R6DZoneRandomPoint.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/25 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPoints extends R6DeploymentZone
	placeable
    native;

var(R6DZone) autoconstruct Array<R6DZoneRandomPointNode> m_aNode;
var(R6DZone) BOOL m_bSelectNodeInEditor;
var(R6DZone) BOOL m_bUseAllowLeave;
var          BOOL m_bInInit;
var const    Array<R6DZoneRandomPointNode> m_aTempHighPriorityNode;
var const    Array<R6DZoneRandomPointNode> m_aTempNode;

defaultproperties
{
}
