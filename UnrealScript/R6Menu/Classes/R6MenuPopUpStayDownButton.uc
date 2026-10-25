class R6MenuPopUpStayDownButton extends R6WindowButton;

var bool    m_bSubMenu;

function Created()
{
	bNoKeyboard = True;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    if(LookAndFeel.IsA('R6MenuRSLookAndFeel'))
    {
        C.Font = m_buttonFont;
        if(bDisabled)
        {
            R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonDisable(self,C);
        }
        else if(bMouseDown || m_bSelected)
	    {
            R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonDown(self,C);
        }
        else if(MouseIsOver())
        {
            R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonOver(self,C);
        }
        else
        {
            R6MenuRSLookAndFeel(LookAndFeel).DrawPopupButtonUp(self,C);
        }
    }

}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local FLOAT fGlobalX;
    local FLOAT fGlobalY;
    
	if(!bDisabled)
    {
        // Informe the list controller about that item is selected
        GetMouseXY(fGlobalX, fGlobalY);
        WindowToGlobal(fGlobalX,fGlobalY,fGlobalX,fGlobalY);
        OwnerWindow.GlobalToWindow(fGlobalX,fGlobalY,fGlobalX,fGlobalY);
        R6WindowListRadio(OwnerWindow).SetSelected(fGlobalX,fGlobalY);
    }
    
	Super.LMouseDown(X, Y);
}

function Tick(FLOAT fDelta)
{
}

defaultproperties
{
}
