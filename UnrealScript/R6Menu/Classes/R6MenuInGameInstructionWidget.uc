//=============================================================================
//  R6MenuInGameInstructionWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MenuInGameInstructionWidget extends R6MenuWidget;

var R6WindowSimpleFramedWindow  m_InstructionText;

var Region                      m_RMsgSize;
var FLOAT						m_fYInstructionTextPos;
var string                      m_szText;
var BOOL                        bIsChangingText;
var INT                         m_iArrayHudStep[3];
var R6InstructionSoundVolume    m_pLastIntructionVolume;

function Created()
{
    local R6WindowWrappedTextArea TextArea;

    m_InstructionText = R6WindowSimpleFramedWindow(CreateWindow(class'R6WindowSimpleFramedWindow', 100, m_fYInstructionTextPos, 440, 100, self));
    m_InstructionText.CreateClientWindow(class'R6WindowWrappedTextArea');
    TextArea  = R6WindowWrappedTextArea(m_InstructionText.m_ClientArea);
    TextArea.m_HBorderTexture = none;
    TextArea.m_VBorderTexture = none;
    TextArea.SetAbsoluteFont(Root.Fonts[F_PrincipalButton]);
    TextArea.m_bUseBGTexture = true;
    TextArea.m_bUseBGColor = true;
    m_InstructionText.m_eCornerType = All_Corners;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    local FLOAT fHeight;
    local FLOAT fWidth;
    local INT iNbLines;
    local R6WindowWrappedTextArea TextArea;

//    Super.BeforePaint(C,X,Y);

    if (bIsChangingText)
    {
        bIsChangingText = false;

        TextArea = R6WindowWrappedTextArea(m_InstructionText.m_ClientArea);
        TextArea.BeforePaint(C, X, Y);
        // Check the Heiht of the text.
        C.Font = Root.Fonts[F_PrincipalButton];
        TextSize(C, "TEST", fWidth, fHeight);
        iNbLines = TextArea.m_fYOffSet/fHeight;
        iNbLines += 1;     // give a one line of security to avoid cut line at the end
        iNbLines += TextArea.Lines; // add original total lines -- real total lines now
        m_RMsgSize.H = fHeight * iNbLines;

        m_InstructionText.WinHeight = m_RMsgSize.H + (2* m_InstructionText.m_fHBorderHeight) + ( 2* m_InstructionText.m_fHBorderOffset); 
        TextArea.WinHeight = m_RMsgSize.H;
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	// DrawBackGround
	C.Style = ERenderStyle.STY_Alpha;

	C.SetDrawColor( Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B, 128);        

	DrawStretchedTextureSegment( C, m_InstructionText.WinLeft, m_InstructionText.WinTop, m_InstructionText.WinWidth, m_InstructionText.WinHeight, 0, 0, 10, 10, Texture'UWindow.WhiteTexture' );
	//
}

function ChangeText(R6InstructionSoundVolume pISV, INT iBox, INT iParagraph)
{
    local string szParagraphID;
    local string szSectionID;
    local R6WindowWrappedTextArea TextArea;

    if(m_pLastIntructionVolume!=none && m_pLastIntructionVolume!=pISV)
        m_pLastIntructionVolume.StopInstruction();

    m_pLastIntructionVolume = pISV;

    switch(iParagraph)
    {
        case 0:
            szParagraphID = "TextA";
            break;
        case 1:
            szParagraphID = "TextB";
            break;
        case 2:
            szParagraphID = "TextC";
            break;
        case 3:
            szParagraphID = "TextD";
            break;
    }


    switch(iBox)
    {
        case 1:
            szSectionID = "BasicAreaBox1";
            break;
        case 2:
            szSectionID = "BasicAreaBox2";
            break;
        case 3:
            szSectionID = "BasicAreaBox3";
            break;
        case 4:
            szSectionID = "BasicAreaBox4";
            break;
        case 5:
            szSectionID = "BasicAreaBox5";
            break;
        case 6:
            szSectionID = "BasicAreaBox6";
            break;
        case 7:
            szSectionID = "BasicAreaBox7";
            break;
        
        case 8:
            szSectionID = "ShootingAreaBox1";
            break;
        case 9:
            szSectionID = "ShootingAreaBox2";
            break;
        case 10:
            szSectionID = "ShootingAreaBox3";
            break;
        case 11:
            szSectionID = "ShootingAreaBox4";
            break;
        case 12:
            szSectionID = "ShootingAreaBox5";
            break;
        case 13:
            szSectionID = "ShootingAreaBox6";
            break;
        case 14:
            szSectionID = "ShootingAreaBox7";
            break;
        case 15:
            szSectionID = "ShootingAreaBox8";
            break;
        
        case 16:
            szSectionID = "ExplodingAreaBox1";
            break;
        case 17:
            szSectionID = "ExplodingAreaBox2";
            break;
        case 18:
            szSectionID = "ExplodingAreaBox3";
            break;
        case 19:
            szSectionID = "ExplodingAreaBox4";
            break;
        case 20:
            szSectionID = "ExplodingAreaBox5";
            break;

        case 21:
            szSectionID = "RoomClearing1Box1";
            break;
        case 22:
            szSectionID = "RoomClearing1Box2";
            break;
        case 23:
            szSectionID = "RoomClearing1Box3";
            break;

        case 24:
            szSectionID = "RoomClearing2Box1";
            break;
        case 25:
            szSectionID = "RoomClearing3Box1";
            break;
        
        case 26:
            szSectionID = "HostageRescue1";
            break;
        case 27:
            szSectionID = "HostageRescue2";
            break;
        case 28:
            szSectionID = "HostageRescue3";
            break;
    }

    m_szText = R6PlayerController(GetPlayerOwner()).LocalizeTraining(szSectionID, szParagraphID, "R6Training",  iBox, iParagraph);
    TextArea = R6WindowWrappedTextArea(m_InstructionText.m_ClientArea);
    TextArea.Clear();
    TextArea.m_fYOffSet = 10;
    TextArea.m_fXOffSet = 15;
    TextArea.AddText(m_szText, Root.Colors.White, Root.Fonts[F_PrincipalButton]);
    TextArea.SetScrollable(false);
    bIsChangingText = true;
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	local FLOAT fBkpOrgY;

    if(Msg==WM_KeyUp && Key==GetPlayerOwner().GetKey("Action"))
        m_pLastIntructionVolume.SkipToNextInstruction();

	if (Msg == WM_Paint)
	{
		fBkpOrgY = C.OrgY;

		C.OrgY = 0;

		m_InstructionText.WinTop = (((C.SizeY) / 480) * m_fYInstructionTextPos);

	    Super.WindowEvent(Msg, C, X, Y, Key);

		C.OrgY = fBkpOrgY;
	}
	else
	    Super.WindowEvent(Msg, C, X, Y, Key);
}

function ResolutionChanged(float W, float H)
{
	WinWidth = W;
	WinHeight = H;

	Super.ResolutionChanged(W, H);
}

defaultproperties
{
     m_fYInstructionTextPos=35.000000
     m_RMsgSize=(X=10,Y=60,W=400)
}
