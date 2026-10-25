//=============================================================================
//  R6MenuMPInGameVote.uc : Multi player menu vote screen
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/7 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameVote extends R6MenuWidget;

const C_iNUMBER_OF_CHOICES		= 3;

var R6WindowTextLabel				m_AVoteText[4]; 
var R6WindowPopUpBox				m_pPopUpBG; 
var Region							m_RVote;

var string							m_szPlayerNameToKick;

var FLOAT							m_fOffsetTxtPos;

var BOOL							m_bFirstTimePaint;

function Created()
{
    local R6WindowTextLabel pR6TextLabelTemp;
	local color LabelTextColor;

	//Init
	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;

    // Create PopUp frame
    m_pPopUpBG = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPopUpBG.CreatePopUpFrameWindow(Localize("MPInGame","Vote_Title","R6Menu"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RVote.X, m_RVote.Y, m_RVote.W, m_RVote.H); //this fct is use for initialisation
    m_pPopUpBG.bAlwaysBehind = true;

    m_AVoteText[0] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RVote.X + 5, m_RVote.Y + 30, WinWidth-5, 25, self));
    m_AVoteText[0].Text = Localize("Number","ID_NUM1","R6RecMessages") $ " " $ Localize("MPInGame","Vote_Yes","R6Menu");
    m_AVoteText[0].Align			= TA_LEFT;
    m_AVoteText[0].m_Font			= Root.Fonts[F_SmallTitle];
    m_AVoteText[0].TextColor		= LabelTextColor;
    m_AVoteText[0].m_BGTexture      = None;
    m_AVoteText[0].m_bDrawBorders   = False;

	m_AVoteText[1] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RVote.X + 5, m_RVote.Y + 50, WinWidth-5, 25, self));
	m_AVoteText[1].Text = Localize("Number","ID_NUM2","R6RecMessages") $ " " $ Localize("MPInGame","Vote_No","R6Menu");
	m_AVoteText[1].Align			= TA_LEFT;
	m_AVoteText[1].m_Font			= Root.Fonts[F_SmallTitle];
	m_AVoteText[1].TextColor		= LabelTextColor;
	m_AVoteText[1].m_BGTexture      = None;
    m_AVoteText[1].m_bDrawBorders   = False;
 
    m_AVoteText[2] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RVote.X + 5, m_RVote.Y + 70, WinWidth-5, 25, self));
	m_AVoteText[2].Text = Localize("Number","ID_NUM0","R6RecMessages") $ " " $ Localize("ExitMenu","ID_MSG0","R6RecMessages");
	m_AVoteText[2].Align			= TA_LEFT;
	m_AVoteText[2].m_Font			= Root.Fonts[F_SmallTitle];
	m_AVoteText[2].TextColor		= LabelTextColor;
	m_AVoteText[2].m_BGTexture      = None;
    m_AVoteText[2].m_bDrawBorders   = False;

	SetAcceptsFocus();
}


function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local string szTitle;
    local FLOAT fHeight;
    local FLOAT fWidth;
    local INT i;
    Super.BeforePaint(C,X,Y);

    if (!m_bFirstTimePaint)
    {
        m_bFirstTimePaint = true;

        // Check the width of the title.
		if(m_szPlayerNameToKick != "")
		szTitle = Localize("MPInGame","Vote_Title","R6Menu") $ " " $ m_szPlayerNameToKick;
		else
		{
			szTitle = Localize("MPInGame", "Vote_NextMap_Title", "R6Menu");
		}
        TextSize(C, szTitle, fWidth, fHeight);
        if (fWidth > (m_RVote.W - m_fOffsetTxtPos)) 
            m_RVote.W = fWidth + m_fOffsetTxtPos;
    
        for ( i= 0; i < C_iNUMBER_OF_CHOICES; i++)
        {
            C.Font = m_AVoteText[i].m_Font;
            TextSize(C, m_AVoteText[i].Text, fWidth,fHeight);
            if (fWidth > (m_RVote.W - m_fOffsetTxtPos))
                m_RVote.W = fWidth + m_fOffsetTxtPos;
        }

        m_pPopUpBG.ModifyPopUpFrameWindow( szTitle, R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RVote.X, m_RVote.Y, m_RVote.W, m_RVote.H);
    }
}

function KeyDown(int Key, float X, float Y)
{
	local R6MenuInGameMultiPlayerRootWindow R6CurrentRoot;
	local BOOL bCloseVoteMenu;


	R6CurrentRoot = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);
	bCloseVoteMenu = true;

    switch(Key)
    {
        case R6CurrentRoot.Console.EInputKey.IK_1:
			R6CurrentRoot.m_R6GameMenuCom.SetVoteResult( true);
            break;
        case R6CurrentRoot.Console.EInputKey.IK_2:
			R6CurrentRoot.m_R6GameMenuCom.SetVoteResult( false);
            break;
        case R6CurrentRoot.Console.EInputKey.IK_0:
            break;
		default:
			bCloseVoteMenu = false;
			break;
    }

	if (bCloseVoteMenu)
		R6CurrentRoot.ChangeWidget( WidgetID_None, true, false);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	local FLOAT fBkpOrgX, fBkpOrgY;

	if (Msg == WM_Paint)
	{
		fBkpOrgX = C.OrgX;
		fBkpOrgY = C.OrgY;

		// move the origin to place the menu in the center of the screen
		C.OrgX = 0;
		C.OrgY = (C.SizeY - 480) * 0.5;

	    Super.WindowEvent(Msg, C, X, Y, Key);

		C.OrgX = fBkpOrgX;
		C.OrgY = fBkpOrgY;
	}
	else
	    Super.WindowEvent(Msg, C, X, Y, Key);
}

defaultproperties
{
     m_fOffsetTxtPos=15.000000
     m_RVote=(Y=170,H=80)
}
