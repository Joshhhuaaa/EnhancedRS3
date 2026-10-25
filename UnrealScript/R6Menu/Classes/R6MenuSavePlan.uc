//=============================================================================
//  R6MenuSavePlan.uc : This is the class where you manage the save plan. You have an edit box to edit
//						the name of the save file and a text list box where we displaying the other save files
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/02 * Created by Yannick Joly
//=============================================================================
class R6MenuSavePlan extends UWindowDialogClientWindow;

const C_iEDITBOX_HEIGHT		 = 24;

var R6WindowEditBox          m_pEditSaveNameBox;                // the edit box to edit the save name
var R6WindowTextListBox		 m_pListOfSavedPlan;				// the save plan was displayed in this window

var R6WindowButton           m_BDeletePlan;
var INT                      m_IBXPos, m_IBYPos;                          // Button Position


function Created()
{
	m_pEditSaveNameBox = R6WindowEditBox(CreateWindow(class'R6WindowEditBox', 0, 0, WinWidth, C_iEDITBOX_HEIGHT));
    m_pEditSaveNameBox.TextColor = Root.Colors.White;
    m_pEditSaveNameBox.SetFont(F_VerySmallTitle);
    m_pEditSaveNameBox.bCaps = false;
    m_pEditSaveNameBox.SetValue( "");
    m_pEditSaveNameBox.MoveEnd();
	m_pEditSaveNameBox.MaxLength = 20; // limited nb of letter
	m_pEditSaveNameBox.Offset = 5;
    
    m_BDeletePlan   = R6WindowButton(CreateControl(class'R6WindowButton', m_IBXPos, WinHeight - R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H - m_IBYPos, WinWidth - m_IBXPos, R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H));
    //m_BDeletePlan.SpecialPaint = R6MenuRSLookAndFeel(LookAndFeel).DrawSquareBorder;
    m_BDeletePlan.m_buttonFont = Root.Fonts[F_VerySmallTitle];
    m_BDeletePlan.m_fLMarge = 4;
    m_BDeletePlan.m_fRMarge = 4;
    m_BDeletePlan.m_bDrawSpecialBorder = true;
    m_BDeletePlan.m_bDrawBorders = true;
    m_BDeletePlan.Align = TA_LEFT;
    m_BDeletePlan.Text = Localize("POPUP","DELETEPLANBUTTON","R6Menu");    
    m_BDeletePlan.ResizeToText();
    
    m_pListOfSavedPlan = R6WindowTextListBox(CreateWindow(class'R6WindowTextListBox', 0, C_iEDITBOX_HEIGHT, WinWidth, m_BDeletePlan.WinTop - C_iEDITBOX_HEIGHT));
    m_pListOfSavedPlan.ListClass=class'R6WindowListBoxItem';
    m_pListOfSavedPlan.m_font = Root.Fonts[F_VerySmallTitle];    
	m_pListOfSavedPlan.Register(  self );
	m_pListOfSavedPlan.m_fXItemOffset = 5;
	m_pListOfSavedPlan.m_DoubleClickClient = OwnerWindow;
    m_pListOfSavedPlan.m_bSkipDrawBorders = true;
    m_pListOfSavedPlan.m_fItemHeight = 10;

}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    C.Style = ERenderStyle.STY_Normal;
        
	C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);       

    DrawStretchedTexture( C, 0, m_pListOfSavedPlan.WinTop, WinWidth, 1, Texture'UWindow.WhiteTexture');
}


function Notify(UWindowDialogControl C, byte E)
{
    local String DelPlanMsg;
    
    if( E == DE_Click )
    {
        if (C == m_pListOfSavedPlan)
        {
            
            // if you have a selection, change the name of the edit box to the name of the selection
            if (m_pListOfSavedPlan.m_SelectedItem != None)
            {
                m_pEditSaveNameBox.SetValue( m_pListOfSavedPlan.m_SelectedItem.HelpText);
            }
            
        }
        else if(C == m_BDeletePlan)
        {
            if (m_pListOfSavedPlan.m_SelectedItem != None)
		    {
                DelPlanMsg = Localize("POPUP","DelPlanMsg","R6Menu") @ ":" @ m_pListOfSavedPlan.m_SelectedItem.HelpText @ "\\n" @ Localize("POPUP","DelPlanQuestion","R6Menu");
			    R6MenuRootWindow(Root).SimplePopUp(Localize("POPUP","DelPlan","R6Menu"), DelPlanMsg, EPopUpID_SaveDelPlan);
		    }
        }
    }
}

defaultproperties
{
     m_IBXPos=6
     m_IBYPos=4
}
