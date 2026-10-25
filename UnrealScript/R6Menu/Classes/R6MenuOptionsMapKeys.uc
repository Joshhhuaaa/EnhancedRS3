class R6MenuOptionsMapKeys extends UWindowDialogControl;

var INT								  m_iLastKeyPressed;

var R6WindowButton					  m_pCancelButton;

function Created()
{
	Super.Created();

    // define Cancel Button
	// the value is according the pop-up defines in R6MenuOptionsTab
    m_pCancelButton = R6WindowButton(CreateWindow( class'R6WindowButton', 180, 225, 280, 25, self)); 
    m_pCancelButton.ToolTipString      = "";//Localize("Tip","ButtonMainMenu","R6Menu");
	m_pCancelButton.Text               = Localize("MultiPlayer","PopUp_Cancel","R6Menu");	
	m_pCancelButton.Align              = TA_Center;
	m_pCancelButton.m_fFontSpacing     = 0;
	m_pCancelButton.m_buttonFont       = Root.Fonts[F_SmallTitle];
	m_pCancelButton.ResizeToText();
}

function Register(UWindowDialogClientWindow W)
{
	Super.Register(W);
	m_pCancelButton.Register(W);

	SetAcceptsFocus();
	m_pCancelButton.CancelAcceptsFocus(); // the keys not go to the button, they are intercept in this class
}

function ShowWindow()
{
	SetAcceptsFocus();
	m_pCancelButton.CancelAcceptsFocus(); // the keys not go to the button, they are intercept in this class

	Super.ShowWindow();
}

function HideWindow()
{
	CancelAcceptsFocus();

	Super.HideWindow();
}

function KeyDown(int Key, float X, float Y)
{
	m_iLastKeyPressed = Key;

	NotifyWindow.Notify(Self, DE_Click);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	m_iLastKeyPressed = GetPlayerOwner().Player.Console.EInputKey.IK_LeftMouse; 

	NotifyWindow.Notify(Self, DE_Click);
}

function MMouseDown(float X, float Y) 
{
	Super.MMouseDown( X, Y);

	m_iLastKeyPressed = GetPlayerOwner().Player.Console.EInputKey.IK_MiddleMouse; 

	NotifyWindow.Notify(Self, DE_Click);
}

function RMouseDown(float X, float Y) 
{
	Super.RMouseDown( X, Y);

	m_iLastKeyPressed = GetPlayerOwner().Player.Console.EInputKey.IK_RightMouse; 

	NotifyWindow.Notify(Self, DE_Click);
}

function MouseWheelDown(FLOAT X, FLOAT Y)
{
	m_iLastKeyPressed = GetPlayerOwner().Player.Console.EInputKey.IK_MouseWheelDown; 

	NotifyWindow.Notify(Self, DE_Click);
}

function MouseWheelUp(FLOAT X, FLOAT Y)
{
	m_iLastKeyPressed = GetPlayerOwner().Player.Console.EInputKey.IK_MouseWheelUp; 

	NotifyWindow.Notify(Self, DE_Click);
}
