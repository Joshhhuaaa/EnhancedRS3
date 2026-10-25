class R6MenuHelpTextBar extends UWindowWindow;

var string          m_szText;
var string          m_szDefaultText;
var FLOAT           m_fTextX;
var FLOAT           m_fTextY;


function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    local FLOAT W,H;
   

    C.Font = Root.Fonts[F_SmallTitle];// TODO: see why I need to do that after click on a button
    
    m_szText = m_szDefaultText;
    
    if(Root.MouseWindow!=None)
    {
    
        if(Root.MouseWindow.ToolTipString!="")
        {     
            m_szText = Root.MouseWindow.ToolTipString;
        }        
        
    }

    if(m_szText != "")
    {
        TextSize(C, m_szText, W, H);
        m_fTextX = (WinWidth - W) / 2;
	    m_fTextY = (WinHeight - H) / 2;
        m_fTextY = FLOAT(INT(m_fTextY+0.5));
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{

    C.Font = Root.Fonts[F_SmallTitle];// TODO: see why I need to do that after click on a button
    ClipText(C, m_fTextX, m_fTextY, m_szText);
}

defaultproperties
{
}
