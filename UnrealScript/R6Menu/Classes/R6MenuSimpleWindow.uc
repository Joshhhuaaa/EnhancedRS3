//=============================================================================
//  R6WindowSimpleWindow.uc : Draw a simple window (opportunity to create a empty box)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/20 * Created by Yannick Joly
//=============================================================================

class R6MenuSimpleWindow extends UWindowWindow;

var UWindowWindow pAdviceParent;

var BOOL m_bDrawSimpleBorder;

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	if (m_bDrawSimpleBorder)
		DrawSimpleBorder(C);
}

function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if ( pAdviceParent != None)
	{
		pAdviceParent.MouseWheelDown( X, Y);
	}
}

function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if ( pAdviceParent != None)
	{
		pAdviceParent.MouseWheelUp( X, Y);
	}
}

defaultproperties
{
     m_bDrawSimpleBorder=True
}
