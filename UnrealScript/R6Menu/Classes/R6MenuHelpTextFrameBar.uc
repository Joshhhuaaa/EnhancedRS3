class R6MenuHelpTextFrameBar extends UWindowWindow;

var R6MenuHelpTextBar      m_HelpTextBar;

function Created()
{
    // the value 51 and 102 are in concordance with the value in paint()
    //m_HelpTextBar = R6MenuHelpTextBar(CreateWindow(class'R6MenuHelpTextBar', 38, 1, WinWidth - 76, WinHeight - 2, self));
    m_HelpTextBar = R6MenuHelpTextBar(CreateWindow(class'R6MenuHelpTextBar', 0, 1, WinWidth, WinHeight - 2, self));
    m_BorderColor = Root.Colors.BlueLight;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    // Draw frame box
    DrawSimpleBorder(C);
}

defaultproperties
{
}
