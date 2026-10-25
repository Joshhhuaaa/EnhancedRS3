//=============================================================================
//  R6MenuMPInGameRecMessages.uc : Multi player menu to choose the pre-recorded messages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameRecMessages extends R6MenuWidget;

var R6WindowTextLabel			 m_TextPreRecMessages[5]; 
var R6WindowPopUpBox             m_pInGameRecMessagesPopUp; 
var Region                       m_RRecMsg;
var BOOL                         m_bFirstTimePaint;
var FLOAT                        m_fOffsetTxtPos;

function Created()
{
    local R6WindowTextLabel pR6TextLabelTemp;
	local color LabelTextColor;

	//Init
	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;

    // Create PopUp frame
    m_pInGameRecMessagesPopUp = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pInGameRecMessagesPopUp.CreatePopUpFrameWindow(Localize("RecMessages","ID_HEADER","R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RRecMsg.X, m_RRecMsg.Y, m_RRecMsg.W, m_RRecMsg.H); //this fct is use for initialisation
    m_pInGameRecMessagesPopUp.bAlwaysBehind   = true;
	m_pInGameRecMessagesPopUp.m_bBGFullScreen = false;

    m_TextPreRecMessages[0] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RRecMsg.X + 5, m_RRecMsg.Y + 30, WinWidth-5, 25, self));
    m_TextPreRecMessages[0].Text = Localize("Number","ID_NUM1","R6RecMessages") $ " " $ Localize("RecMessages","ID_MSG1","R6RecMessages");
    m_TextPreRecMessages[0].Align = TA_LEFT;
    m_TextPreRecMessages[0].m_Font = Root.Fonts[F_SmallTitle];
    m_TextPreRecMessages[0].TextColor = LabelTextColor;
    m_TextPreRecMessages[0].m_BGTexture         = None;
    m_TextPreRecMessages[0].m_bDrawBorders      =False;

	m_TextPreRecMessages[1] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RRecMsg.X + 5, m_RRecMsg.Y + 50, WinWidth-5, 25, self));
	m_TextPreRecMessages[1].Text = Localize("Number","ID_NUM2","R6RecMessages") $ " " $ Localize("RecMessages","ID_MSG2","R6RecMessages");
	m_TextPreRecMessages[1].Align = TA_LEFT;
	m_TextPreRecMessages[1].m_Font = Root.Fonts[F_SmallTitle];
	m_TextPreRecMessages[1].TextColor = LabelTextColor;
	m_TextPreRecMessages[1].m_BGTexture         = None;
    m_TextPreRecMessages[1].m_bDrawBorders      =False;

    m_TextPreRecMessages[2] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RRecMsg.X + 5, m_RRecMsg.Y + 70, WinWidth-5, 25, self));
	m_TextPreRecMessages[2].Text = Localize("Number","ID_NUM3","R6RecMessages") $ " " $ Localize("RecMessages","ID_MSG3","R6RecMessages");
	m_TextPreRecMessages[2].Align = TA_LEFT;
	m_TextPreRecMessages[2].m_Font = Root.Fonts[F_SmallTitle];
	m_TextPreRecMessages[2].TextColor = LabelTextColor;
	m_TextPreRecMessages[2].m_BGTexture         = None;
    m_TextPreRecMessages[2].m_bDrawBorders      =False;

    m_TextPreRecMessages[3] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RRecMsg.X + 5, m_RRecMsg.Y + 90, WinWidth-5, 25, self));
	m_TextPreRecMessages[3].Text = Localize("Number","ID_NUM4","R6RecMessages") $ " " $ Localize("RecMessages","ID_MSG4","R6RecMessages");
	m_TextPreRecMessages[3].Align = TA_LEFT;
	m_TextPreRecMessages[3].m_Font = Root.Fonts[F_SmallTitle];
	m_TextPreRecMessages[3].TextColor = LabelTextColor;
	m_TextPreRecMessages[3].m_BGTexture         = None;
    m_TextPreRecMessages[3].m_bDrawBorders      =False;

    m_TextPreRecMessages[4] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_RRecMsg.X + 5, m_RRecMsg.Y + 110, WinWidth-5, 25, self));
	m_TextPreRecMessages[4].Text = Localize("Number","ID_NUM0","R6RecMessages") $ " " $ Localize("ExitMenu","ID_MSG0","R6RecMessages");
	m_TextPreRecMessages[4].Align = TA_LEFT;
	m_TextPreRecMessages[4].m_Font = Root.Fonts[F_SmallTitle];
	m_TextPreRecMessages[4].TextColor = LabelTextColor;
	m_TextPreRecMessages[4].m_BGTexture         = None;
    m_TextPreRecMessages[4].m_bDrawBorders      =False;

	SetAcceptsFocus();
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Super.Paint(C, X, Y);

    if (!GetPlayerOwner().Pawn.IsAlive())
    {   
        Root.ChangeCurrentWidget(WidgetID_None);
    }
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    local FLOAT fHeight;
    local FLOAT fWidth;
    local INT i;

    if (!m_bFirstTimePaint)
    {
        m_bFirstTimePaint = true;

        // Check the width of the title.
        TextSize(C, Localize("RecMessages","ID_HEADER","R6RecMessages"), fWidth, fHeight);
        if (fWidth > (m_RRecMsg.W - m_fOffsetTxtPos)) 
            m_RRecMsg.W = fWidth + m_fOffsetTxtPos;
    
        for (i=0;i<5;i++)
        {
            C.Font = m_TextPreRecMessages[i].m_Font;
            TextSize(C, m_TextPreRecMessages[i].Text, fWidth,fHeight);
            if (fWidth > (m_RRecMsg.W - m_fOffsetTxtPos))
                m_RRecMsg.W = fWidth + m_fOffsetTxtPos;
        }

        m_pInGameRecMessagesPopUp.ModifyPopUpFrameWindow(Localize("RecMessages","ID_HEADER","R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RRecMsg.X, m_RRecMsg.Y, m_RRecMsg.W, m_RRecMsg.H);
    }
}

function KeyDown(int Key, float X, float Y)
{
    
    //log("Current Key Press =" @ Key);
    local R6MenuInGameMultiPlayerRootWindow RootWindow;

    RootWindow = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);
    
    switch(Key)
    {
        case RootWindow.Console.EInputKey.IK_1:
            RootWindow.ChangeCurrentWidget(InGameMpWID_MsgOffensive);
            break;
        case RootWindow.Console.EInputKey.IK_2:
            RootWindow.ChangeCurrentWidget(InGameMpWID_MsgDefensive);
            break;
        case RootWindow.Console.EInputKey.IK_3:
            RootWindow.ChangeCurrentWidget(InGameMpWID_MsgReply);
            break;
        case RootWindow.Console.EInputKey.IK_4:
            RootWindow.ChangeCurrentWidget(InGameMpWID_MsgStatus);
            break;
        case RootWindow.Console.EInputKey.IK_0:
            RootWindow.ChangeCurrentWidget( WidgetID_None);
            break;
    }
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
     m_RRecMsg=(Y=170,H=120)
}
