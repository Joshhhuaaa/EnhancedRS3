//=============================================================================
//  R6WindowOperativePlanningSummary.uc : Small window summerizing an operative
//                                        planning result for the execute screen
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================


class R6WindowOperativePlanningSummary extends UWindowWindow;

var R6WindowBitMap      m_OperativeFace;

var R6WindowBitMap      m_BMPSpeciality;
var R6WindowBitMap      m_BMPHealth;

var R6WindowTextLabel   m_PrimaryWeapon, m_Armor, m_OperativeName;

var FLOAT               m_fFaceWidth, m_FaceHeight, m_fNameLabelHeight;
var INT                 m_IXSpecialityOffset, m_IXHealthOffset, m_IYIconPos, m_IHealthWidth, m_IHealthHeight, m_ISpecialityWidth, m_ISpecialityHeight;

var Texture             m_TBottomLabelBG;
var Region              m_RBottomLabelBG;

var Color               m_LabelColor;

var BYTE                m_BAlphaOpNameBg;
var BYTE                m_BSelectedAlphaOpNameBg;
var BYTE                m_BCurrentAlpha;

var Color               m_CDarkColor;

var BYTE                m_BAlphaBg;


var BOOL                m_bIsSelected;

function Created()
{
 
    local FLOAT fLabelHeight;

    m_OperativeFace = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',m_BorderTextureRegion.H,m_BorderTextureRegion.W,m_fFaceWidth,m_FaceHeight,self));
    m_BMPSpeciality = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',m_FaceHeight + m_IXSpecialityOffset,m_IYIconPos,m_ISpecialityWidth,m_ISpecialityHeight,self));
    m_BMPSpeciality.m_iDrawStyle = ERenderStyle.STY_Alpha;
    m_BMPHealth     = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',m_BMPSpeciality.WinLeft + m_BMPSpeciality.WinWidth + m_IXHealthOffset, m_IYIconPos,m_IHealthWidth,m_IHealthHeight,self));
    m_BMPHealth.m_iDrawStyle = ERenderStyle.STY_Alpha;

    m_OperativeName                = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_BMPHealth.WinLeft + m_BMPHealth.WinWidth, 0, WinWidth - m_BMPHealth.WinLeft - m_BMPHealth.WinWidth, m_fNameLabelHeight, self));
    m_OperativeName.m_bDrawBorders = false;
    m_OperativeName.Align          = TA_CENTER;    
    m_OperativeName.TextColor      = Root.Colors.White;
    m_OperativeName.m_Font         = Root.Fonts[F_SmallTitle];
    m_OperativeName.m_BGTexture    = None;    

    fLabelHeight = (WinHeight - m_OperativeName.WinHeight) / 2;

    m_PrimaryWeapon                = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_OperativeFace.WinLeft + m_fFaceWidth, m_OperativeName.WinTop + m_OperativeName.WinHeight,  m_OperativeName.WinWidth, fLabelHeight, self));
    m_PrimaryWeapon.m_bDrawBorders = false;
    m_PrimaryWeapon.Align          = TA_LEFT;    
    m_PrimaryWeapon.TextColor      = Root.Colors.White;
    m_PrimaryWeapon.m_Font         = Root.Fonts[F_VerySmallTitle];
    m_PrimaryWeapon.m_BGTexture    = None;
    m_PrimaryWeapon.m_fLMarge      = 4;
    m_PrimaryWeapon.m_bFixedYPos   = true;
    m_PrimaryWeapon.TextY          = 1;

    m_Armor                        = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_PrimaryWeapon.WinLeft, m_PrimaryWeapon.WinTop + m_PrimaryWeapon.WinHeight, m_OperativeName.WinWidth, fLabelHeight, self));
    m_Armor.m_bDrawBorders         = false;
    m_Armor.Align                  = TA_LEFT;    
    m_Armor.TextColor              = Root.Colors.White;
    m_Armor.m_Font                 = Root.Fonts[F_VerySmallTitle];
    m_Armor.m_BGTexture            = None; 
    m_Armor.m_fLMarge              = m_PrimaryWeapon.m_fLMarge;
    m_Armor.m_bFixedYPos           = true; 

    m_BCurrentAlpha                = m_BAlphaOpNameBg;
    
}

function setHealth(TexRegion _T)
{
    m_BMPHealth.T = _T.T;
    m_BMPHealth.R.X = _T.X;
    m_BMPHealth.R.Y = _T.Y;
    m_BMPHealth.R.W = _T.H;
    m_BMPHealth.R.H = _T.W;
}

function setSpeciality(TexRegion _T)
{
    m_BMPSpeciality.T = _T.T;
    m_BMPSpeciality.R.X = _T.X;
    m_BMPSpeciality.R.Y = _T.Y;
    m_BMPSpeciality.R.W = _T.H;
    m_BMPSpeciality.R.H = _T.W;
}

function setFace(Texture _T, Region _R)
{
    m_OperativeFace.T   = _T;
    m_OperativeFace.R   = _R;
}

function setLabels(string szPrimaryWeapon, string szArmor, string szOperativeName)
{
    m_PrimaryWeapon.SetNewText(szPrimaryWeapon, true);
    m_Armor.SetNewText(szArmor, true);
    m_OperativeName.SetNewText(szOperativeName, true);
}

function SetColor(Color _LabelColor, Color _DarkColor)
{
    m_BorderColor = _LabelColor;
    m_LabelColor  = _LabelColor;
    m_CDarkColor  = _DarkColor;
    
    m_BMPSpeciality.m_TextureColor  = _LabelColor;
    m_BMPHealth.m_TextureColor      = _LabelColor;

    SetSelected(m_bIsSelected);
}

function SetSelected(bool _IsSelected)
{
    if(_IsSelected)
    {   
        m_OperativeName.TextColor      = Root.Colors.White;
        m_PrimaryWeapon.TextColor      = Root.Colors.White;
        m_Armor.TextColor              = Root.Colors.White;        
        m_BCurrentAlpha                = m_BSelectedAlphaOpNameBg;
    }        
    else
    {
        m_OperativeName.TextColor      = m_LabelColor;
        m_PrimaryWeapon.TextColor      = m_LabelColor;
        m_Armor.TextColor              = m_LabelColor;        
        m_BCurrentAlpha                = m_BAlphaOpNameBg;
    }
    
    m_BMPSpeciality.m_bUseColor        = !_IsSelected;
    m_BMPHealth.m_bUseColor            = !_IsSelected;
    
    m_bIsSelected = _IsSelected;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    //Draw Bottom Label background
    C.Style = ERenderStyle.STY_Alpha;
    C.SetDrawColor(m_LabelColor.R, m_LabelColor.G, m_LabelColor.B, m_BCurrentAlpha);
    DrawStretchedTexture( C, m_OperativeFace.WinLeft + m_fFaceWidth, 0, WinWidth - m_fFaceWidth - m_OperativeFace.WinLeft, m_OperativeName.WinHeight, m_TBottomLabelBG );

    C.SetDrawColor(m_CDarkColor.R, m_CDarkColor.G, m_CDarkColor.B, m_BAlphaBg);
    DrawStretchedTexture( C, m_OperativeFace.WinLeft + m_fFaceWidth, m_OperativeName.WinHeight, WinWidth - m_fFaceWidth - m_OperativeFace.WinLeft, WinHeight - m_OperativeName.WinHeight, m_TBottomLabelBG );
}

function AfterPaint(Canvas C, FLOAT X, FLOAT Y)
{
    //Draw Lines
    C.Style = ERenderStyle.STY_Normal;
    C.SetDrawColor(m_LabelColor.R, m_LabelColor.G, m_LabelColor.B, m_LabelColor.A);    
    DrawStretchedTexture( C, m_OperativeFace.WinLeft + m_fFaceWidth, 0, 1, WinHeight, m_TBottomLabelBG );
    DrawStretchedTexture( C, m_OperativeFace.WinLeft + m_fFaceWidth, m_fNameLabelHeight, WinWidth - m_fFaceWidth - m_OperativeFace.WinLeft, 1, m_TBottomLabelBG );
 
    DrawSimpleBorder(C);
}

defaultproperties
{
     m_BAlphaOpNameBg=77
     m_BSelectedAlphaOpNameBg=128
     m_BAlphaBg=128
     m_IXSpecialityOffset=1
     m_IXHealthOffset=3
     m_IYIconPos=4
     m_IHealthWidth=10
     m_IHealthHeight=10
     m_ISpecialityWidth=9
     m_ISpecialityHeight=9
     m_fFaceWidth=38.000000
     m_FaceHeight=42.000000
     m_fNameLabelHeight=17.000000
     m_TBottomLabelBG=Texture'UWindow.WhiteTexture'
     m_RBottomLabelBG=(W=10,H=10)
}
