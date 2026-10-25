class R6WindowPopUpBoxCW extends UWindowDialogClientWindow;

const C_fBUT_HEIGHT			= 17;

var MessageBoxButtons       Buttons;

var MessageBoxResult        EnterResult;
var MessageBoxResult        ESCResult;
var R6WindowPopUpButton     m_pOKButton,
                            m_pCancelButton;

var R6WindowButtonBox		m_pDisablePopUpButton;

function KeyDown(int Key, float X, float Y)
{
	local R6WindowPopUpBox P;

	P = R6WindowPopUpBox(ParentWindow);

	if (Key == GetPlayerOwner().Player.Console.EInputKey.IK_Enter && EnterResult != MR_None)
	{
		P.Result = EnterResult;
		P.Close();
	}
	else if (Key == GetPlayerOwner().Player.Console.EInputKey.IK_Escape)
	{
		P.Result = ESCResult;
		P.Close();		
	}
}

function Resized()
{
    /*
	Super.Resized();
	MessageArea.SetSize(WinWidth-20, WinHeight-44);
    */
}


function SetupPopUpBoxClient( MessageBoxButtons InButtons, MessageBoxResult InESCResult, optional MessageBoxResult InEnterResult)
{
    local FLOAT fXBut, fYBut, fWidthBut, fHeightBut;
	local BOOL bButtonsValid;

    // default
    fWidthBut = 23;
    fHeightBut = C_fBUT_HEIGHT;

	Buttons = InButtons;
	EnterResult = InEnterResult;
	ESCResult = InESCResult;

    if (m_pOKButton != None)
        m_pOKButton.HideWindow();

    if (m_pCancelButton != None)
        m_pCancelButton.HideWindow();
    
	bButtonsValid = true;

	// Create buttons
	switch(Buttons)
	{
		case MB_OKCancel:
			// create OK and CANCEL Buttons
			fXBut = WinWidth - fWidthBut - 20; 

            if (m_pCancelButton != None)
            {
                m_pCancelButton.WinLeft = fXBut;
                m_pCancelButton.ShowWindow();
            }
            else
            {
			    fYBut = (WinHeight - fHeightBut)*0.5; 
			    fYBut = FLOAT(INT(fYBut+0.5));
			    m_pCancelButton = R6WindowPopUpButton(CreateControl(class'R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
			    m_pCancelButton.ImageX = 2;
			    m_pCancelButton.ImageY = 2;
				m_pCancelButton.m_bDrawRedBG = true;
			    R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pCancelButton, 1);
            }

			fXBut = fXBut - fWidthBut - 20;
            if (m_pOKButton != None)
            {
                m_pOKButton.WinLeft = fXBut;
                m_pOKButton.ShowWindow();
            }
            else
            {
                m_pOKButton = R6WindowPopUpButton(CreateControl(class'R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
			    m_pOKButton.ImageX = 2;
			    m_pOKButton.ImageY = 2;
				m_pOKButton.m_bDrawGreenBG = true;
			    R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pOKButton, 0);
            }
            
			break;
		case MB_OK:
			// create OK Button
			fXBut = WinWidth - fWidthBut - 20; 
			fYBut = (WinHeight - fHeightBut)*0.5; 
			fYBut = FLOAT(INT(fYBut+0.5));

			m_pOKButton = R6WindowPopUpButton(CreateControl(class'R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
			m_pOKButton.ImageX = 2;
			m_pOKButton.ImageY = 2;
			m_pOKButton.m_bDrawGreenBG = true;
			R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pOKButton, 0);
			break;
		case MB_Cancel:
			// create CANCEL Button

			fXBut = WinWidth - fWidthBut - 20; 

            if (m_pCancelButton != None)
            {
                m_pCancelButton.WinLeft = fXBut;
                m_pCancelButton.ShowWindow();
            }
            else
            {
                fYBut = (WinHeight - fHeightBut)*0.5; 
			    fYBut = FLOAT(INT(fYBut+0.5));

				m_pCancelButton = R6WindowPopUpButton(CreateControl(class'R6WindowPopUpButton', fXBut, fYBut, fWidthBut, fHeightBut));
				m_pCancelButton.ImageX = 2;
				m_pCancelButton.ImageY = 2;
				m_pCancelButton.m_bDrawRedBG = true;
				R6WindowLookAndFeel(LookAndFeel).Button_SetupEnumSignChoice(m_pCancelButton, 1);
            }			

			break;
		default:
			bButtonsValid = false;
			break;
	}

	if (bButtonsValid)
		SetAcceptsFocus();
}

function AddDisablePopUpButton()
{
	local FLOAT fXBut, fYBut;

	if (m_pDisablePopUpButton == None)
	{
		fXBut = 5; // small offset 
		fYBut = 0; 
		fYBut = FLOAT(INT(fYBut+0.5));			
	//			fWidthBut = WinWidth - fWidthBut
		// create DisablePopUpButton text button
		m_pDisablePopUpButton = R6WindowButtonBox(CreateControl( class'R6WindowButtonBox', fXBut, fYBut, WinWidth, WinHeight, self));
		m_pDisablePopUpButton.SetButtonBox( false);
		m_pDisablePopUpButton.CreateTextAndBox( Localize("POPUP","DISABLEPOPUP","R6Menu"), 
												"", 0, R6WindowPopUpBox(ParentWindow).m_ePopUpID, true);
		m_pDisablePopUpButton.bAlwaysOnTop = true;
		m_pDisablePopUpButton.m_bResizeToText = true;
	}
	else
	{
		m_pDisablePopUpButton.ShowWindow();
	}
}

function RemoveDisablePopUpButton()
{
	if (m_pDisablePopUpButton != None)
	{
		m_pDisablePopUpButton.HideWindow();
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6WindowPopUpBox P;

	P = R6WindowPopUpBox(ParentWindow);

	switch(E)
	{
		case DE_Click:
			if (C.IsA('R6WindowButtonBox'))
			{
				R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
			}
			else
			{
				switch(C)
				{
					case m_pOKButton:
						P.Result = MR_OK;
						P.Close();
						break;
					case m_pCancelButton:
	//					log("This button is click");
						P.Result = MR_Cancel;
						P.Close();
						break;
				}
			}
			break;
		default:
			break;
	}
}

defaultproperties
{
}
