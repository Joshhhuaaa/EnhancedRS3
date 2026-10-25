//=============================================================================
//  R6MenuMPInGameMsgOffensive.uc : Multi player menu to choose the pre-recorded messages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameMsgOffensive extends R6MenuWidget;


var R6WindowTextLabel			 m_TextOffensive[7]; 
var R6WindowPopUpBox             m_pInGameOffensivePopUp; 
var Region                       m_RMsgSize;
var BOOL                         m_bFirstTimePaint;
var FLOAT                        m_fOffsetTxtPos;

function Created()
{
	local color LabelTextColor;

    //Init
	LabelTextColor.R = 129;
	LabelTextColor.G = 209;
	LabelTextColor.B = 238;

    m_pInGameOffensivePopUp = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pInGameOffensivePopUp.CreatePopUpFrameWindow( Localize("Offensive","ID_HEADER","R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RMsgSize.X, m_RMsgSize.Y, m_RMsgSize.W, m_RMsgSize.H); //this fct is use for initialisation
    m_pInGameOffensivePopUp.bAlwaysBehind   = true;
	m_pInGameOffensivePopUp.m_bBGFullScreen = false;

    m_TextOffensive[0] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 30, WinWidth-5, 25, self));
    m_TextOffensive[0].Text = Localize("Number","ID_NUM1","R6RecMessages") $ " " $ Localize("Offensive","ID_MSG11","R6RecMessages");
    m_TextOffensive[0].Align = TA_LEFT;
    m_TextOffensive[0].m_Font = Root.Fonts[F_SmallTitle];
    m_TextOffensive[0].TextColor = LabelTextColor;
    m_TextOffensive[0].m_BGTexture         = None;
    m_TextOffensive[0].m_bDrawBorders      =False;

	m_TextOffensive[1] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 50, WinWidth-5, 25, self));
	m_TextOffensive[1].Text = Localize("Number","ID_NUM2","R6RecMessages") $ " " $ Localize("Offensive","ID_MSG12","R6RecMessages");
	m_TextOffensive[1].Align = TA_LEFT;
	m_TextOffensive[1].m_Font = Root.Fonts[F_SmallTitle];
	m_TextOffensive[1].TextColor = LabelTextColor;
	m_TextOffensive[1].m_BGTexture         = None;
    m_TextOffensive[1].m_bDrawBorders      =False;

    m_TextOffensive[2] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 70, WinWidth-5, 25, self));
	m_TextOffensive[2].Text = Localize("Number","ID_NUM3","R6RecMessages") $ " " $ Localize("Offensive","ID_MSG13","R6RecMessages");
	m_TextOffensive[2].Align = TA_LEFT;
	m_TextOffensive[2].m_Font = Root.Fonts[F_SmallTitle];
	m_TextOffensive[2].TextColor = LabelTextColor;
	m_TextOffensive[2].m_BGTexture         = None;
    m_TextOffensive[2].m_bDrawBorders      =False;

    m_TextOffensive[3] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 90, WinWidth-5, 25, self));
	m_TextOffensive[3].Text = Localize("Number","ID_NUM4","R6RecMessages") $ " " $ Localize("Offensive","ID_MSG14","R6RecMessages");
	m_TextOffensive[3].Align = TA_LEFT;
	m_TextOffensive[3].m_Font = Root.Fonts[F_SmallTitle];
	m_TextOffensive[3].TextColor = LabelTextColor;
	m_TextOffensive[3].m_BGTexture         = None;
    m_TextOffensive[3].m_bDrawBorders      =False;

    m_TextOffensive[4] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 110, WinWidth-5, 25, self));
	m_TextOffensive[4].Text = Localize("Number","ID_NUM5","R6RecMessages") $ " " $ Localize("Offensive","ID_MSG15","R6RecMessages");
	m_TextOffensive[4].Align = TA_LEFT;
	m_TextOffensive[4].m_Font = Root.Fonts[F_SmallTitle];
	m_TextOffensive[4].TextColor = LabelTextColor;
	m_TextOffensive[4].m_BGTexture         = None;
    m_TextOffensive[4].m_bDrawBorders      =False;

    m_TextOffensive[5] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 130, WinWidth-5, 25, self));
	m_TextOffensive[5].Text = Localize("Number","ID_NUM6","R6RecMessages") $ " " $ Localize("Offensive","ID_MSG16","R6RecMessages");
	m_TextOffensive[5].Align = TA_LEFT;
	m_TextOffensive[5].m_Font = Root.Fonts[F_SmallTitle];
	m_TextOffensive[5].TextColor = LabelTextColor;
	m_TextOffensive[5].m_BGTexture         = None;
    m_TextOffensive[5].m_bDrawBorders      =False;

    m_TextOffensive[6] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 150, WinWidth-5, 25, self));
	m_TextOffensive[6].Text = Localize("Number","ID_NUM0","R6RecMessages") $ " " $ Localize("ExitMenu","ID_MSG0","R6RecMessages");
	m_TextOffensive[6].Align = TA_LEFT;
	m_TextOffensive[6].m_Font = Root.Fonts[F_SmallTitle];
	m_TextOffensive[6].TextColor = LabelTextColor;
	m_TextOffensive[6].m_BGTexture         = None;
    m_TextOffensive[6].m_bDrawBorders      =False;

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
        if (fWidth > m_RMsgSize.W) 
            m_RMsgSize.W = fWidth;
    
        for (i=0;i<7;i++)
        {
            C.Font = m_TextOffensive[i].m_Font;
            TextSize(C, m_TextOffensive[i].Text, fWidth,fHeight);
            if (fWidth > (m_RMsgSize.W - m_fOffsetTxtPos))
                m_RMsgSize.W = fWidth + m_fOffsetTxtPos;
        }
        m_pInGameOffensivePopUp.ModifyPopUpFrameWindow(Localize("Offensive","ID_HEADER","R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RMsgSize.X, m_RMsgSize.Y, m_RMsgSize.W, m_RMsgSize.H);
    }
}

function KeyDown(int Key, float X, float Y)
{
    local R6Rainbow aRainbow;
    local R6PlayerController aPC;
	local R6MenuInGameMultiPlayerRootWindow R6Root;

	R6Root = R6MenuInGameMultiPlayerRootWindow(OwnerWindow);

    aPC = R6PlayerController(R6Root.m_R6GameMenuCom.m_PlayerController);
    aRainbow = R6Rainbow(aPC.Pawn);

    switch(Key)
    {
        case R6Root.Console.EInputKey.IK_1:
            aRainbow.SetCommunicationAnimation(COM_Go);
			aPC.ServerPlayRecordedMsg("Offensive ID_MSG11", PRMV_Move);
            break;
        case R6Root.Console.EInputKey.IK_2:
			aRainbow.SetCommunicationAnimation(COM_FollowMe);	
            aPC.ServerPlayRecordedMsg("Offensive ID_MSG12", PRMV_FollowMe);
            break;
        case R6Root.Console.EInputKey.IK_3:
			aRainbow.SetCommunicationAnimation(COM_Go);
            aPC.ServerPlayRecordedMsg("Offensive ID_MSG13", PRMV_Charge);
            break;
        case R6Root.Console.EInputKey.IK_4:
            aRainbow.SetCommunicationAnimation(COM_Go);	 
            aPC.ServerPlayRecordedMsg("Offensive ID_MSG14", PRMV_MoveOut);
            break;
        case R6Root.Console.EInputKey.IK_5:
            aPC.ServerPlayRecordedMsg("Offensive ID_MSG15", PRMV_TangoSpotted);
            break;
        case R6Root.Console.EInputKey.IK_6:
            aPC.ServerPlayRecordedMsg("Offensive ID_MSG16", PRMV_StatusReport);
            break;
    }

    if ((Key >= R6Root.Console.EInputKey.IK_0) && (Key <= R6Root.Console.EInputKey.IK_9))
            R6Root.ChangeCurrentWidget( WidgetID_None);

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
     m_RMsgSize=(Y=170,H=160)
}
