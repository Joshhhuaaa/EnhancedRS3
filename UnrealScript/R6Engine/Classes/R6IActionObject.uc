//=============================================================================
//  R6IActionObject : This class should be subclassed in order to create object
//					  that can be manipulated with the action mode
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/10 * Created by Alexandre Dionne
//    2001/11/26 * Merged with interactive objects - Jean-Francois Dube
//=============================================================================

class R6IActionObject extends R6InteractiveObject
    native
    abstract; 

var FLOAT	m_fMinMouseMove;		//Min mouse value we take from the input
var FLOAT	m_fMaxMouseMove;		//Max mouse value we take from the input
var Actor   m_ActionInstigator;     //The pawn doing the action

function bool startAction(FLOAT deltaMouse, Actor actionInstigator);
function bool updateAction(FLOAT deltaMouse, Actor actionInstigator);
function endAction();

defaultproperties
{
     m_fMinMouseMove=1.000000
     m_fMaxMouseMove=250.000000
     m_bBlockCoronas=True
     Physics=PHYS_Rotating
     m_bHandleRelativeProjectors=True
     bSkipActorPropertyReplication=False
}
