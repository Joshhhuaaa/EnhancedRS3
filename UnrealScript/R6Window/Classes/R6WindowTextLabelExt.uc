//=============================================================================
//  R6WindowTextLabelExt.uc : An array of textlabel with each individual parameters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Yannick Joly
//=============================================================================

class R6WindowTextLabelExt extends R6WindowSimpleFramedWindowExt;

const iNumberOfLabelMax = 20;
const C_iMAX_SIZE_OF_TEXT_LABEL = 596;

struct TextLabel
{
    var Font      TextFont;
    var Color     TextColorFont;
    var string    m_szTextLabel;
    var FLOAT     X;
    var FLOAT     XTextPos;
    var FLOAT     Y;
    var FLOAT     fWidth;
	var FLOAT     fHeight;
    var FLOAT     fXLine;
    var TextAlign Align;
    var bool      bDrawLineAtEnd;
    var bool      bUpDownBG;
	var BOOL	  bResizeToText;
};

var string      Text;
var font        m_Font;
var TextAlign   Align;

var FLOAT       m_fTextX, 
                m_fTextY;		        // changed by BeforePaint functions
var FLOAT       m_fFontSpacing;		    // Space between characters
var FLOAT       m_fLMarge;			    // Left Text Margin
var FLOAT       m_fYLineOffset;         // OffSet for the draw line after text

var Texture     m_BGTexture;		    // Put = None when no background is needed

var color       m_vTextColor;
var color       m_vLineColor;

var INT         m_TextDrawstyle;
var INT         m_Drawstyle;
var INT         m_iNumberOfLabel;

var bool        m_bRefresh;
var bool        m_bCheckToDrawLine;
var bool        m_bTextCenterToWindow;    // center the text to the center of the window
var bool		m_bUpDownBG;			  // set to true if you want a background of editbox type behind your text

var TextLabel   m_sTextLabelArray[iNumberOfLabelMax];


function Created()
{
    Super.Created();
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H;
    local FLOAT fWinWidth, 
                fRelativeX,
                fXTemp;

    local INT i;
#ifdefDEBUG
	local BOOL bShowLog;
#endif

    if (m_bRefresh)
    {
        m_bRefresh = false;

        fXTemp = 0;
        m_bCheckToDrawLine = false;
        
        for( i =0; i < m_iNumberOfLabel; i++)
        {
            C.Font = m_sTextLabelArray[i].TextFont;

            fWinWidth = m_sTextLabelArray[i].fWidth;

			if (m_sTextLabelArray[i].bResizeToText)
			{
				TextSize(C, m_sTextLabelArray[i].m_szTextLabel, W, H);

				if (W > WinWidth)
				{
					// if textwidth is greater than max, cut the word
					if (W > C_iMAX_SIZE_OF_TEXT_LABEL)
					{
						m_sTextLabelArray[i].m_szTextLabel = TextSize(C, m_sTextLabelArray[i].m_szTextLabel, W, H, C_iMAX_SIZE_OF_TEXT_LABEL);
					}

					m_sTextLabelArray[i].XTextPos = 4; // 2 pixels for the border + 2 pixels left
					WinWidth = W + (2 * 4); // 4 pixels of space each side

					m_sTextLabelArray[i].fWidth = WinWidth;
					fWinWidth = m_sTextLabelArray[i].fWidth;

					if ((OwnerWindow != none) && OwnerWindow.IsA('R6WindowPopUpBox'))
					{
						R6WindowPopUpBox(OwnerWindow).ResizePopUp( WinWidth);
					}
				}
			}
			else
			{
			    m_sTextLabelArray[i].m_szTextLabel = TextSize(C, m_sTextLabelArray[i].m_szTextLabel, W, H, fWinWidth);
			}
    
		    switch(m_sTextLabelArray[i].Align)
		    {
		        case TA_Left:
			        fXTemp = m_fLMarge;
			        break;
		        case TA_Right:
			        fXTemp = fWinWidth - W - (Len(m_sTextLabelArray[i].m_szTextLabel) * m_fFontSpacing) -m_fVBorderWidth;
			        break;
		        case TA_Center:
			        fXTemp = (fWinWidth - W) / 2;
			        break;            
            }

            if (m_sTextLabelArray[i].bDrawLineAtEnd)
            {
                m_sTextLabelArray[i].fXLine = m_sTextLabelArray[i].X + fWinWidth;
                m_bCheckToDrawLine = true;
            }

            m_sTextLabelArray[i].XTextPos = m_sTextLabelArray[i].X + fXTemp;

#ifdefDEBUG
			if (bShowLog)
			{
				log("WinTop :"$WinTop);
				log("m_sTextLabelArray[i].m_szTextLabel: "$m_sTextLabelArray[i].m_szTextLabel);
				log("m_sTextLabelArray[i].XTextPos: "$m_sTextLabelArray[i].XTextPos);
				log("m_sTextLabelArray[i].Y: "$m_sTextLabelArray[i].Y);
			}
#endif

            if(m_bTextCenterToWindow)
            {
		        m_sTextLabelArray[i].Y = (WinHeight - H) / 2;
		        m_sTextLabelArray[i].Y = FLOAT(INT(m_sTextLabelArray[i].Y+0.5));
            }
        }
    }
}


function Paint(Canvas C, float X, float Y)
{
    local FLOAT tempSpace;
    local INT i; 
 	local Texture T;	

    if (!GetActivateBorder())
        Super.Paint(C, X, Y);

    // draw at least one line at the end of the fake text box?
    if(m_bCheckToDrawLine)
    {
	    C.Style = m_Drawstyle;
        C.SetDrawColor(m_vLineColor.R,m_vLineColor.G,m_vLineColor.B);
        for( i =0; i < m_iNumberOfLabel - 1; i++)
        {
            if (m_sTextLabelArray[i].bDrawLineAtEnd)
            {
		        DrawStretchedTextureSegment( C, m_sTextLabelArray[i].fXLine, m_fYLineOffset, 1, WinHeight - m_fYLineOffset,
										        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
										        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
            }
        }    
    }

    // draw text
    if (m_sTextLabelArray[0].m_szTextLabel != "")
	{	
        tempSpace = C.SpaceX;		
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;	
        m_vTextColor = m_sTextLabelArray[0].TextColorFont;
		C.SetDrawColor(m_vTextColor.R,m_vTextColor.G,m_vTextColor.B);		
        
        C.Style =m_TextDrawstyle;

        for( i =0; i < m_iNumberOfLabel; i++)
        {
            if ( m_sTextLabelArray[i].TextFont != m_Font)
            {
                m_Font = m_sTextLabelArray[i].TextFont;
                C.Font = m_sTextLabelArray[i].TextFont;
            }

            if ( m_sTextLabelArray[i].TextColorFont != m_vTextColor)
            {
                m_vTextColor = m_sTextLabelArray[i].TextColorFont;
		        C.SetDrawColor(m_vTextColor.R,m_vTextColor.G,m_vTextColor.B);
            }

            if ( m_sTextLabelArray[i].bUpDownBG)
            {
				// draw the text box background
				DrawUpDownBG( C, m_sTextLabelArray[i].X, m_sTextLabelArray[i].Y, m_sTextLabelArray[i].fWidth, m_sTextLabelArray[i].fHeight);

				// reset param
                C.Style = m_TextDrawstyle;
				C.SetDrawColor(m_vTextColor.R,m_vTextColor.G,m_vTextColor.B);		
            }

    		ClipText(C, m_sTextLabelArray[i].XTextPos, m_sTextLabelArray[i].Y, m_sTextLabelArray[i].m_szTextLabel, True);
        }

		C.SpaceX = tempSpace;
	}    
}

//===============================================================================
// DrawUpDownBG: Draw the editbox background effect under the text if the bUpDownBG is true
//===============================================================================
function DrawUpDownBG( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH)
{
	local Texture BGTexture;
    local Region  RTexture;

	// BG texture
	BGTexture = Texture'R6MenuTextures.Gui_BoxScroll';
	// BG Region
    RTexture.X = 114;
    RTexture.Y = 47;
    RTexture.W = 2;
    RTexture.H = 13;

	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(Root.Colors.White.R,Root.Colors.White.G,Root.Colors.White.B);

    DrawStretchedTextureSegment( C, _fX, _fY, _fW, _fH, 
                                    RTexture.X, RTexture.Y, RTexture.W, RTexture.H, BGTexture);
}

// use at create only
function INT AddTextLabel( string _szTextToAdd, FLOAT _X, FLOAT _Y, FLOAT _fWidth, TextAlign _Align, BOOL _bDrawLineAtEnd, optional FLOAT _fHeight, optional BOOL _bResizeToText)
{
    local INT iIndex;

    iIndex = 0;

    if ( m_iNumberOfLabel < iNumberOfLabelMax)
    {
        m_sTextLabelArray[m_iNumberOfLabel].m_szTextLabel   = _szTextToAdd;
        m_sTextLabelArray[m_iNumberOfLabel].X               = _X;
        m_sTextLabelArray[m_iNumberOfLabel].XTextPos        = _X;
        m_sTextLabelArray[m_iNumberOfLabel].Y               = _Y;
        m_sTextLabelArray[m_iNumberOfLabel].fWidth          = _fWidth;
		if (_fHeight == 0)
			m_sTextLabelArray[m_iNumberOfLabel].fHeight     = 15;
		else
			m_sTextLabelArray[m_iNumberOfLabel].fHeight     = _fHeight;
        m_sTextLabelArray[m_iNumberOfLabel].Align           = _Align;
        m_sTextLabelArray[m_iNumberOfLabel].bDrawLineAtEnd  = _bDrawLineAtEnd;
		m_sTextLabelArray[m_iNumberOfLabel].bResizeToText	= _bResizeToText;
        m_sTextLabelArray[m_iNumberOfLabel].TextFont        = m_Font;
        m_sTextLabelArray[m_iNumberOfLabel].TextColorFont   = m_vTextColor;

        m_sTextLabelArray[m_iNumberOfLabel].bUpDownBG = m_bUpDownBG;

        iIndex = m_iNumberOfLabel;
        m_bRefresh = true;          // refresh in before paint because maybe you add text outside created() fct
        m_iNumberOfLabel+=1;
    }

    return iIndex;
}


//===============================================================================
// According the index value, change the string. No check was done is the index is valid or not
//===============================================================================
function ChangeTextLabel( string _szNewStringLabel, INT _iIndex)
{
    m_sTextLabelArray[_iIndex].m_szTextLabel   = _szNewStringLabel;
    m_bRefresh = true;
}

//===============================================================================
// According the index value, change the color of the font. No check was done is the index is valid or not
//===============================================================================
function ChangeColorLabel( Color _vNewColorText, INT _iIndex)
{
    m_sTextLabelArray[_iIndex].TextColorFont   = _vNewColorText;
    m_bRefresh = true;
}

function string GetTextLabel(INT _iIndex)
{
	return m_sTextLabelArray[_iIndex].m_szTextLabel;
}

function Color GetTextColor( INT _iIndex)
{
	return m_sTextLabelArray[_iIndex].TextColorFont;
}

function Clear()
{
    local INT i;

    for( i =0; i < m_iNumberOfLabel; i++)
    {
        m_sTextLabelArray[i].m_szTextLabel = "";
    }

    m_iNumberOfLabel = 0;
    m_bRefresh = true;
}

defaultproperties
{
     m_TextDrawstyle=5
     m_DrawStyle=5
     m_bRefresh=True
     m_fLMarge=2.000000
     m_fYLineOffset=1.000000
}
