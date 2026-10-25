//=============================================================================
//  R6WindowButtonGear.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/15 * Created by Alexandre Dionne
//=============================================================================

class R6WindowButtonGear extends R6WindowButton;

var FLOAT				m_fAlpha;

var Texture				m_HighLightTexture;
var BOOL				m_HighLight;

var BOOL				m_bForceMouseOver;					// force a mouse over 


function RMouseDown(float X, float Y) 
{
	bRMouseDown = True;
}

function MMouseDown(float X, float Y) 
{	
	bMMouseDown = True;
}

function LMouseDown(float X, float Y)
{
	bMouseDown = True;
}


function Paint(Canvas C, float X, float Y)
{
	C.Style = ERenderStyle.STY_Alpha;

//	Super.Paint(C,X,Y);

	if(bDisabled)
	{
		if(DisabledTexture != None)
		{
			if(!m_HighLight)
			    C.SetDrawColor(m_vButtonColor.R,m_vButtonColor.G,m_vButtonColor.B, m_fAlpha);
			DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(DisabledRegion.W*RegionScale), Abs(DisabledRegion.H*RegionScale), 
											DisabledRegion.X, DisabledRegion.Y, DisabledRegion.W, DisabledRegion.H, DisabledTexture );
		}
	}
	else
	{
		if(m_HighLight)
		{
            DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 
												0, 0, m_HighLightTexture.USize, m_HighLightTexture.VSize, m_HighLightTexture );
		}

		if(bMouseDown)
		{
			if(DownTexture != None)
			{
				C.SetDrawColor(m_vButtonColor.R,m_vButtonColor.G,m_vButtonColor.B);
				DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(DownRegion.W*RegionScale), Abs(DownRegion.H*RegionScale), 
												DownRegion.X, DownRegion.Y, DownRegion.W, DownRegion.H, DownTexture );
			}
		}
		else if ((MouseIsOver()) || (m_bForceMouseOver))
		{
			if(OverTexture != None)
			{
				C.SetDrawColor(m_vButtonColor.R,m_vButtonColor.G,m_vButtonColor.B);
				DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(OverRegion.W*RegionScale), Abs(OverRegion.H*RegionScale), 
												OverRegion.X, OverRegion.Y, OverRegion.W, OverRegion.H, OverTexture );
			}
		}
		else if(UpTexture != None)
		{
			if (!m_HighLight)
				C.SetDrawColor(m_vButtonColor.R,m_vButtonColor.G,m_vButtonColor.B, m_fAlpha);
			DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(UpRegion.W*RegionScale), Abs(UpRegion.H*RegionScale), 
											UpRegion.X, UpRegion.Y, UpRegion.W, UpRegion.H, UpTexture );
		}
	}


    if(m_bDrawSimpleBorder)
    {
        DrawSimpleBorder(C);
    }
}

function ForceMouseOver( BOOL _bForceMouseOver)
{
	m_bForceMouseOver = _bForceMouseOver;
}

defaultproperties
{
     m_fAlpha=128.000000
     m_HighLightTexture=Texture'R6TextureMenuEquipment.Highlight_gearroom'
     ImageX=1.000000
     ImageY=1.000000
}
