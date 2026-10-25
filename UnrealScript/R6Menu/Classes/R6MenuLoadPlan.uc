//=============================================================================
//  R6MenuLoadPlan.uc : Window that pops up with all plans that can be loaded
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuLoadPlan extends UWindowDialogClientWindow;

var R6WindowTextListBox		 m_pListOfSavedPlan;				// the save plan was displayed in this window

var R6WindowButton           m_BDeletePlan;
var INT                      m_IBXPos, m_IBYPos;                          // Button Position

function Created()
{

    m_BDeletePlan   = R6WindowButton(CreateControl(class'R6WindowButton', m_IBXPos, WinHeight - R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H - m_IBYPos, WinWidth - m_IBXPos, R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H));
    //m_BDeletePlan.SpecialPaint = R6MenuRSLookAndFeel(LookAndFeel).DrawSquareBorder;
    m_BDeletePlan.m_buttonFont = Root.Fonts[F_VerySmallTitle];
    m_BDeletePlan.m_fLMarge = 4;
    m_BDeletePlan.m_fRMarge = 4;
    m_BDeletePlan.Align = TA_LEFT;
    m_BDeletePlan.m_bDrawSpecialBorder = true;
    m_BDeletePlan.m_bDrawBorders = true;
    m_BDeletePlan.Text = Localize("POPUP","DELETEPLANBUTTON","R6Menu");    
    m_BDeletePlan.ResizeToText();

	m_pListOfSavedPlan = R6WindowTextListBox(CreateWindow(class'R6WindowTextListBox', 0, 0, WinWidth, m_BDeletePlan.WinTop));
    m_pListOfSavedPlan.ListClass=class'R6WindowListBoxItem';
    m_pListOfSavedPlan.m_font = Root.Fonts[F_VerySmallTitle];    
	m_pListOfSavedPlan.Register(  self );
	m_pListOfSavedPlan.m_fXItemOffset = 5;
	m_pListOfSavedPlan.m_DoubleClickClient = OwnerWindow;
    m_pListOfSavedPlan.m_bSkipDrawBorders = true;
    m_pListOfSavedPlan.m_fItemHeight = 10;

    
}

function Resized()
{
    m_BDeletePlan.WinTop = WinHeight - R6MenuRSLookAndFeel(LookAndFeel).m_RSquareBgLeft.H - m_IBYPos;
    m_pListOfSavedPlan.SetSize(WinWidth, m_BDeletePlan.WinTop);
}

function Notify(UWindowDialogControl C, byte E)
{
    local String DelPlanMsg;

	if( E == DE_Click && C == m_BDeletePlan)
	{
		// if you have a selection, change the name of the edit box to the name of the selection
		if (m_pListOfSavedPlan.m_SelectedItem != None)
		{
            DelPlanMsg = Localize("POPUP","DelPlanMsg","R6Menu") @ ":" @ m_pListOfSavedPlan.m_SelectedItem.HelpText @ "\\n" @Localize("POPUP","DelPlanQuestion","R6Menu");
			R6MenuRootWindow(Root).SimplePopUp(Localize("POPUP","DelPlan","R6Menu"), DelPlanMsg, EPopUpID_LoadDelPlan);
		}
    }
}

defaultproperties
{
     m_IBXPos=6
     m_IBYPos=4
}
