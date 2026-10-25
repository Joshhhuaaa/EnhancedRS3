//=============================================================================
//  R6ActionPointAbstract.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Jean-Francois Dube
//=============================================================================

class R6ActionPointAbstract extends Actor
    native
	abstract;

var R6ActionPointAbstract   prevActionPoint;      // previous point in the current planning
var Array<Actor>            m_PathToNextPoint;    // list of navigation point to reach the next Action Point

function ResetPathNode();   //Set path node Icon to none
function ResetActionIcon(); //set action icon to none

defaultproperties
{
}
