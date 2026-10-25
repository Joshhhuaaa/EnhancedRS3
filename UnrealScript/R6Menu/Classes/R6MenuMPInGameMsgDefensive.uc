//=============================================================================
//  R6MenuMPInGameMsgDefensive.uc : Multi player menu to choose the order to be play
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameMsgDefensive extends R6MenuWidget;

var R6WindowTextLabel			 m_TextDefensive[7]; 
var R6WindowPopUpBox             m_pInGameGiveOrderPopUp; 
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

    m_pInGameGiveOrderPopUp = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pInGameGiveOrderPopUp.CreatePopUpFrameWindow( Localize("Defensive","ID_HEADER","R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RMsgSize.X, m_RMsgSize.Y, m_RMsgSize.W, m_RMsgSize.H); //this fct is use for initialisation
    m_pInGameGiveOrderPopUp.bAlwaysBehind   = true;
	m_pInGameGiveOrderPopUp.m_bBGFullScreen = false;

    m_TextDefensive[0] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 30, WinWidth-5, 25, self));
    m_TextDefensive[0].Text = Localize("Number","ID_NUM1","R6RecMessages") $ " " $ Localize("Defensive","ID_MSG21","R6RecMessages");
    m_TextDefensive[0].Align = TA_LEFT;
    m_TextDefensive[0].m_Font = Root.Fonts[F_SmallTitle];
    m_TextDefensive[0].TextColor = LabelTextColor;
    m_TextDefensive[0].m_BGTexture         = None;
    m_TextDefensive[0].m_bDrawBorders      =False;

	m_TextDefensive[1] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 50, WinWidth-5, 25, self));
	m_TextDefensive[1].Text = Localize("Number","ID_NUM2","R6RecMessages") $ " " $ Localize("Defensive","ID_MSG22","R6RecMessages");
	m_TextDefensive[1].Align = TA_LEFT;
	m_TextDefensive[1].m_Font = Root.Fonts[F_SmallTitle];
	m_TextDefensive[1].TextColor = LabelTextColor;
	m_TextDefensive[1].m_BGTexture         = None;
    m_TextDefensive[1].m_bDrawBorders      =False;

    m_TextDefensive[2] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 70, WinWidth-5, 25, self));
	m_TextDefensive[2].Text = Localize("Number","ID_NUM3","R6RecMessages") $ " " $ Localize("Defensive","ID_MSG23","R6RecMessages");
	m_TextDefensive[2].Align = TA_LEFT;
	m_TextDefensive[2].m_Font = Root.Fonts[F_SmallTitle];
	m_TextDefensive[2].TextColor = LabelTextColor;
	m_TextDefensive[2].m_BGTexture         = None;
    m_TextDefensive[2].m_bDrawBorders      =False;

    m_TextDefensive[3] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 90, WinWidth-5, 25, self));
	m_TextDefensive[3].Text = Localize("Number","ID_NUM4","R6RecMessages") $ " " $ Localize("Defensive","ID_MSG24","R6RecMessages");
	m_TextDefensive[3].Align = TA_LEFT;
	m_TextDefensive[3].m_Font = Root.Fonts[F_SmallTitle];
	m_TextDefensive[3].TextColor = LabelTextColor;
	m_TextDefensive[3].m_BGTexture         = None;
    m_TextDefensive[3].m_bDrawBorders      =False;

    m_TextDefensive[4] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 110, WinWidth-5, 25, self));
	m_TextDefensive[4].Text = Localize("Number","ID_NUM5","R6RecMessages") $ " " $ Localize("Defensive","ID_MSG25","R6RecMessages");
	m_TextDefensive[4].Align = TA_LEFT;
	m_TextDefensive[4].m_Font = Root.Fonts[F_SmallTitle];
	m_TextDefensive[4].TextColor = LabelTextColor;
	m_TextDefensive[4].m_BGTexture         = None;
    m_TextDefensive[4].m_bDrawBorders      =False;

    m_TextDefensive[5] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 130, WinWidth-5, 25, self));
	m_TextDefensive[5].Text = Localize("Number","ID_NUM6","R6RecMessages") $ " " $ Localize("Defensive","ID_MSG26","R6RecMessages");
	m_TextDefensive[5].Align = TA_LEFT;
	m_TextDefensive[5].m_Font = Root.Fonts[F_SmallTitle];
	m_TextDefensive[5].TextColor = LabelTextColor;
	m_TextDefensive[5].m_BGTexture         = None;
    m_TextDefensive[5].m_bDrawBorders      =False;

    m_TextDefensive[6] = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, m_RMsgSize.Y + 150, WinWidth-5, 25, self));
	m_TextDefensive[6].Text = Localize("Number","ID_NUM0","R6RecMessages") $ " " $ Localize("ExitMenu","ID_MSG0","R6RecMessages");
	m_TextDefensive[6].Align = TA_LEFT;
	m_TextDefensive[6].m_Font = Root.Fonts[F_SmallTitle];
	m_TextDefensive[6].TextColor = LabelTextColor;
	m_TextDefensive[6].m_BGTexture         = None;
    m_TextDefensive[6].m_bDrawBorders      =False;

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
        TextSize(C, Localize("Defensive","ID_HEADER","R6RecMessages"), fWidth, fHeight);
        if (fWidth > m_RMsgSize.W) 
            m_RMsgSize.W = fWidth;
    
        for (i=0;i<7;i++)
        {
            C.Font = m_TextDefensive[i].m_Font;
            TextSize(C, m_TextDefensive[i].Text, fWidth,fHeight);
            if (fWidth > (m_RMsgSize.W - m_fOffsetTxtPos))
                m_RMsgSize.W = fWidth + m_fOffsetTxtPos;
        }
        m_pInGameGiveOrderPopUp.ModifyPopUpFrameWindow(Localize("Defensive","ID_HEADER","R6RecMessages"), R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), m_RMsgSize.X, m_RMsgSize.Y, m_RMsgSize.W, m_RMsgSize.H);
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
			aRainbow.SetCommunicationAnimation(COM_Hold);	
            aPC.ServerPlayRecordedMsg("Defensive ID_MSG21", PRMV_HoldPosition);
            break;
        case R6Root.Console.EInputKey.IK_2:
            aPC.ServerPlayRecordedMsg("Defensive ID_MSG22", PRMV_NeedBackup);
            break;
        case R6Root.Console.EInputKey.IK_3:
			aRainbow.SetCommunicationAnimation(COM_Cover);  
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG23", PRMV_Retreat);
            break;
        case R6Root.Console.EInputKey.IK_4:
            aRainbow.SetCommunicationAnimation(COM_Regroup);
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG24", PRMV_SecureArea);
            break;
        case R6Root.Console.EInputKey.IK_5:
			aRainbow.SetCommunicationAnimation(COM_Regroup);	
            aPC.ServerPlayRecordedMsg("Defensive ID_MSG25", PRMV_ReformOnMe);
            break;
        case R6Root.Console.EInputKey.IK_6:
            aRainbow.SetCommunicationAnimation(COM_Cover); 
			aPC.ServerPlayRecordedMsg("Defensive ID_MSG26", PRMV_CoverMe);
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
