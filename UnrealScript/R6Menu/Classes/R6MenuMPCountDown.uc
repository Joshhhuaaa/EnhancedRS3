//=============================================================================
//  R6MenuMPCountDown.uc : this menu show the count down before the game start in multi 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/09 * Created by Yannick Joly
//=============================================================================
class R6MenuMPCountDown extends UWindowWindow;

const C_iWAIT_XFRAMES						= 10;					// wait 10 frames

var R6WindowTextLabel						m_pCountDownLabel;		// the countdown text window
var R6WindowTextLabel						m_pCountDown;			// the countdown text window

var INT										m_iLastValue;
var INT										m_iFrameRefresh;

function Created()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	m_pCountDownLabel = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 185, 180, 270, 20, self));
	m_pCountDownLabel.SetProperties( Localize("POPUP","PopUpTitle_CountDown","R6Menu"), TA_Center, Root.Fonts[F_MainButton], Root.Colors.White, false);
	m_pCountDownLabel.m_bResizeToText = true;

	m_pCountDown = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 185, 200, 270, 20, self));
	m_pCountDown.SetProperties( "", TA_Center, Root.Fonts[F_MainButton], Root.Colors.White, false);
	m_pCountDown.m_bResizeToText = true;
}

function Paint(Canvas C, float X, float Y)
{
	local INT iServerCountDownTime;
	local R6MenuInGameMultiPlayerRootWindow R6Root;

	if (m_iFrameRefresh > C_iWAIT_XFRAMES) // wait X frames before a refresh
	{
		m_iFrameRefresh = 0;
		R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

		iServerCountDownTime =	Max( 1, INT(R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo).GetRoundTime()));
		if (iServerCountDownTime != m_iLastValue)
		{
			m_pCountDown.SetNewText( string(iServerCountDownTime), true);
			m_iLastValue = iServerCountDownTime;
		}
	}

	m_iFrameRefresh++;
}

defaultproperties
{
     m_iLastValue=-1
     m_iFrameRefresh=11
}
