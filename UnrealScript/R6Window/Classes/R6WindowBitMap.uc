class R6WindowBitMap extends UWindowBitmap;

var Color           m_TextureColor;
var bool            m_bUseColor;
var bool            m_bDrawBorder;


function Paint(Canvas C, FLOAT X, FLOAT Y)
{

    if(m_bUseColor)
    {
        C.SetDrawColor(m_TextureColor.R,m_TextureColor.G,m_TextureColor.B);
    }

    Super.Paint(C, X, Y);

    if(m_bDrawBorder)
    {
        DrawSimpleBorder(C);   
    }
    
}

defaultproperties
{
}
