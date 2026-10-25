class R6WindowConfirmationButton extends R6WindowButton;


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	if(m_buttonFont != NONE)
		C.Font = m_buttonFont;
	else
		C.Font = Root.Fonts[Font];
	
	//C.Style = 3;

	Super.Paint(C,X,Y);
	C.Style = 1;
	R6WindowLookAndFeel(LookAndFeel).DrawButtonBorder(Self, C);

	
}

defaultproperties
{
}
