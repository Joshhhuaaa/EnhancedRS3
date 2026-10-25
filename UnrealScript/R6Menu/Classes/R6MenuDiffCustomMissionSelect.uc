//=============================================================================
//  R6MenuDiffCustomMissionSelect.uc : Little Area where you select
//										the custom mission difficulty level
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/29 * Created by Alexandre Dionne
//=============================================================================


class R6MenuDiffCustomMissionSelect extends UWindowDialogClientWindow
                config(USER);

var R6WindowButtonBox				m_pButLevel1;
var R6WindowButtonBox				m_pButLevel2;
var R6WindowButtonBox				m_pButLevel3;
var R6WindowButtonBox				m_pButLastSel;

var config  INT CustomMissionDifficultyLevel;

var BOOL                            m_bAutoSave; //this can be used to skip auto save 

function Created()
{
	local R6MenuButtonsDefines		  pButtonsDef;
	local FLOAT fXOffset, fYOffset, fWidth, fHeight, fYStep;

	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));

	fXOffset = 5;
	fYOffset = 5;
	fWidth	 = WinWidth - 20;
	fHeight	 = 15;
	fYStep	 = fHeight + 16;

    // Button Level 1 -- RECRUIT
    m_pButLevel1 = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pButLevel1.SetButtonBox( false);
    m_pButLevel1.CreateTextAndBox( pButtonsDef.GetButtonLoc( EButtonName.EBN_Recruit), 
                                   pButtonsDef.GetButtonLoc( EButtonName.EBN_Recruit, true), 0, EButtonName.EBN_Recruit);

	fYOffset += fYStep;

    // Button Level 2 -- VETERAN
    m_pButLevel2 = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pButLevel2.SetButtonBox( false);
    m_pButLevel2.CreateTextAndBox( pButtonsDef.GetButtonLoc( EButtonName.EBN_Veteran), 
                                   pButtonsDef.GetButtonLoc( EButtonName.EBN_Veteran, true), 0, EButtonName.EBN_Veteran);

	fYOffset += fYStep;

    // Button Level 3 -- ELITE
    m_pButLevel3 = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pButLevel3.SetButtonBox( false);
    m_pButLevel3.CreateTextAndBox( pButtonsDef.GetButtonLoc( EButtonName.EBN_Elite), 
                                   pButtonsDef.GetButtonLoc( EButtonName.EBN_Elite, true), 0, EButtonName.EBN_Elite);

    switch( EButtonName.EBN_Recruit - 1 + CustomMissionDifficultyLevel)
    {
    case m_pButLevel1.m_iButtonID:
        m_pButLastSel = m_pButLevel1;
        break;
    case m_pButLevel2.m_iButtonID:
        m_pButLastSel = m_pButLevel2;
        break;
    case m_pButLevel3.m_iButtonID:
        m_pButLastSel = m_pButLevel3;
        break;
    default:
        m_pButLastSel = m_pButLevel2;
        break;
    }

    m_pButLastSel.SetButtonBox( true );
    
}

//We should receive 1, 2 or 3
function SetDifficulty(INT iDifficulty_)
{

    switch( EButtonName.EBN_Recruit - 1 + iDifficulty_)
    {
    case m_pButLevel1.m_iButtonID:        
        m_pButLastSel.SetButtonBox(false);
	    m_pButLevel1.SetButtonBox(true); // change the boolean state
	    m_pButLastSel = m_pButLevel1;
        break;
    case m_pButLevel2.m_iButtonID:
        m_pButLastSel.SetButtonBox(false);
	    m_pButLevel2.SetButtonBox(true); // change the boolean state
	    m_pButLastSel = m_pButLevel2;
        break;
    case m_pButLevel3.m_iButtonID:
        m_pButLastSel.SetButtonBox(false);
	    m_pButLevel3.SetButtonBox(true); // change the boolean state
	    m_pButLastSel = m_pButLevel3;
        break;    
    }

}


function int GetDifficulty()
{       
    CustomMissionDifficultyLevel = m_pButLastSel.m_iButtonID - EButtonName.EBN_Recruit + 1;

    if(m_bAutoSave)
    {        
        SaveConfig();
    }
    
	return CustomMissionDifficultyLevel;
}

function Notify(UWindowDialogControl C, byte E)
{
	if (E == DE_Click)
	{
		if ( R6WindowButtonBox(C).GetSelectStatus())
		{
			m_pButLastSel.SetButtonBox(false);
			R6WindowButtonBox(C).SetButtonBox(true); // change the boolean state
			m_pButLastSel = R6WindowButtonBox(C);	
		}
	}
}

defaultproperties
{
     CustomMissionDifficultyLevel=1
     m_bAutoSave=True
}
