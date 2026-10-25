//=============================================================================
//  R6MenuObjectiveLabel.uc : A check box plus the objective description
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/05 * Created by Alexandre Dionne
//=============================================================================


class R6MenuObjectiveLabel extends UWindowWindow;

var R6WindowTextLabel			m_Objective;
var R6WindowTextLabel			m_ObjectiveFailed;
var bool						m_bObjectiveCompleted;
var Texture						m_TCheckBoxBorder, m_TCheckBoxMark;
var Region						m_RCheckBoxBorder, m_RCheckBoxMark;
var FLOAT                       m_fYPaddingBetweenElements;

function Created()
{
    m_Objective = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_RCheckBoxBorder.W + m_fYPaddingBetweenElements, 
                                                0, 
                                        		WinWidth - m_RCheckBoxBorder.W - m_fYPaddingBetweenElements, 
                                                WinHeight, 
                                                self));

    m_Objective.SetProperties( "", TA_LEFT, Root.Fonts[F_Normal], Root.Colors.White, false);
	m_Objective.m_bResizeToText = true;

	m_ObjectiveFailed = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, 10, WinHeight, self));
	m_ObjectiveFailed.SetProperties( "", TA_LEFT, Root.Fonts[F_Normal], Root.Colors.Red, false);
}

function SetProperties(string _Objective, bool _completed, optional string _szFailed)
{
	m_Objective.m_bResizeToText = true;
    m_Objective.SetNewText( _Objective, true);
    m_bObjectiveCompleted = _completed;

	m_ObjectiveFailed.WinLeft  = m_Objective.WinLeft + m_Objective.WinWidth;
	m_ObjectiveFailed.m_bResizeToText = true;
	m_ObjectiveFailed.SetNewText( _szFailed, true);
}

function SetNewLabelWindowSizes( FLOAT _X, FLOAT _Y, FLOAT _W, FLOAT _H)
{
	m_Objective.WinWidth = _W;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    C.Style = ERenderStyle.STY_Alpha;

    if(m_bObjectiveCompleted)
	{
		DrawStretchedTextureSegment( C, 2, 2, 
                                     m_RCheckBoxMark.W, m_RCheckBoxMark.H, 
									 m_RCheckBoxMark.X, m_RCheckBoxMark.Y, m_RCheckBoxMark.W, m_RCheckBoxMark.H, m_TCheckBoxMark );
    }

    DrawStretchedTextureSegment( C, 0, 0, 
                                    m_RCheckBoxBorder.W, m_RCheckBoxBorder.H, 
									m_RCheckBoxBorder.X, m_RCheckBoxBorder.Y, m_RCheckBoxBorder.W, m_RCheckBoxBorder.H, m_TCheckBoxBorder );


}

defaultproperties
{
     m_fYPaddingBetweenElements=2.000000
     m_TCheckBoxBorder=Texture'R6MenuTextures.Gui_BoxScroll'
     m_TCheckBoxMark=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RCheckBoxBorder=(X=12,Y=40,W=14,H=14)
     m_RCheckBoxMark=(Y=52,W=10,H=10)
}
