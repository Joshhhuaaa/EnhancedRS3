class UWindowBitmap extends UWindowDialogControl;

var Texture T;
var Region	R;
var bool	bStretch;
var bool	bCenter;
var INT     m_iDrawStyle;

var bool    m_bHorizontalFlip, m_bVerticalFlip; //This is ton invert a texture horizontaly on verticaly
var FLOAT   m_ImageX, m_ImageY;

function Paint(Canvas C, float X, float Y)
{
    local int XAdjust, YAdjust, RegW, RegH;
    
    if( T == None)
        return;
    
    C.Style=m_iDrawStyle;

    RegW = R.W;
    RegH = R.H;

    if(m_bHorizontalFlip)
    {
        XAdjust = R.W;
        RegW    = -R.W;
    }
        
    if(m_bVerticalFlip)
    {
        YAdjust = R.H;
        RegH    = -R.H;
    }
        

	if(bStretch)
	{
		DrawStretchedTextureSegment(C, m_ImageX, m_ImageY, WinWidth, WinHeight, R.X + XAdjust, R.Y + YAdjust, RegW, RegH, T);
	}
	else
	{
		if(bCenter)
		{
			DrawStretchedTextureSegment(C, (WinWidth - R.W)/2, (WinHeight - R.H)/2, R.W, R.H, R.X + XAdjust, R.Y + YAdjust, RegW, RegH, T);
		}
		else
		{
			DrawStretchedTextureSegment(C, m_ImageX, m_ImageY, R.W, R.H, R.X + XAdjust, R.Y + YAdjust, RegW, RegH, T);
		}
	}    
}

defaultproperties
{
     m_iDrawStyle=1
}
