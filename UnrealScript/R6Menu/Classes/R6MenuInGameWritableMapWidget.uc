//=============================================================================
//  R6MenuInGameWritableMapWidget.uc : Game Main Menu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/04/05 * Created by Hugo Allaire
//=============================================================================
class R6MenuInGameWritableMapWidget extends R6MenuWidget;

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE="..\textures\Color.utx" Package="Color.Color"
#exec OBJ LOAD FILE="..\textures\Color.utx" Package="Color"
#exec OBJ LOAD FILE="..\textures\R6WritableMapIcons.utx" Package="R6WritableMapIcons"

var const INT c_iNbOfIcons;

var		bool					m_bIsDrawing;
var		R6ColorPicker			m_cColorPicker;
var     R6WindowRadioButton     m_Icons[16];
var     R6WindowRadioButton     m_CurrentSelectedIcon;

function Created()
{
    local INT iIconsCount;
    local INT iPosX;
    local Region ButtonRegion;

    // keep size in sync with PICKWIDTH,PICKHEIGHT*NUM_COLOR in R6ColorPicker.uc
	m_cColorPicker = R6ColorPicker(CreateWindow(class'R6ColorPicker', 10, 190, 40, 100, self));

    for (iIconsCount = 0; iIconsCount < c_iNbOfIcons; iIconsCount++)
    {
        if (iIconsCount < 8)
        {
            ButtonRegion.X = iIconsCount * 64;
            ButtonRegion.Y = 0;
        }
        else
        {
            ButtonRegion.X = (iIconsCount-8) * 64;
            ButtonRegion.Y = 192;
        }

        ButtonRegion.W = 64;
        ButtonRegion.H = 64;

        iPosX = 34 + (iIconsCount * (32 + 4));
        m_Icons[iIconsCount] = R6WindowRadioButton(CreateControl(class'R6WindowRadioButton', iPosX, WinHeight - 48, 32, 32, self));
        m_Icons[iIconsCount].RegionScale = 0.5;
        m_Icons[iIconsCount].bUseRegion = True;
        m_Icons[iIconsCount].UpRegion = ButtonRegion;
        m_Icons[iIconsCount].UpTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';
        m_Icons[iIconsCount].bCenter = false;
        m_Icons[iIconsCount].m_iDrawStyle = ERenderStyle.STY_Alpha;
        m_Icons[iIconsCount].m_bDrawBorders = false;

        if (iIconsCount < 8)
        {
            ButtonRegion.Y = 64;
        }
        else
        {
            ButtonRegion.Y = 256;
        }

        m_Icons[iIconsCount].OverRegion = ButtonRegion;
        m_Icons[iIconsCount].OverTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';

        if (iIconsCount < 8)
        {
            ButtonRegion.Y = 128;
        }
        else
        {
            ButtonRegion.Y = 320;
        }


        m_Icons[iIconsCount].DownRegion = ButtonRegion;
        m_Icons[iIconsCount].DownTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';

        m_Icons[iIconsCount].m_iButtonID = iIconsCount; 
    }

    m_CurrentSelectedIcon = m_Icons[0];
    m_CurrentSelectedIcon.m_bSelected= true;

    class'Actor'.static.GetCanvas().m_pWritableMapIconsTexture = Texture'R6WritableMapIcons.R6WritableMapIcons';
}

function SendLineToTeam()
{
	local string msg;
	local int i;
	local float x, y;
	local Color c;
	local LevelInfo pLevel;

	c=m_cColorPicker.GetSelectedColor();
	i=0;
	if (C.R==255) i+=2;
	if (C.G==255) i+=4;
	if (C.B==255) i+=8;
	msg=Chr(i);

	pLevel = GetLevel();

	if (pLevel.m_aCurrentStrip.length > 2)
	{				
		for(i=0; i<pLevel.m_aCurrentStrip.length; i++)
		{
			msg=msg $
				Chr(pLevel.m_aCurrentStrip[i].position.X) $
				Chr(pLevel.m_aCurrentStrip[i].position.Y);
		}
		
		pLevel.AddEncodedWritableMapStrip(msg);
		R6PlayerController(GetPlayerOwner()).ServerBroadcast(GetPlayerOwner(), msg, 'Line');
	}

	pLevel.m_aCurrentStrip.Remove(0, pLevel.m_aCurrentStrip.length);
}

function MouseLeave()
{
	super.MouseLeave();
	m_bIsDrawing=false;
	SendLineToTeam();
}

function RMouseDown(float X, float Y)
{
    local String szMsg;
    local Color c;
    local INT iColorIndex;

    if(X < 60 || X > 640 || Y < 0 || Y > 416)
        return;
        
    
    c = m_cColorPicker.GetSelectedColor();
    iColorIndex = 0;
    if (C.R==255) iColorIndex+=2;
    if (C.G==255) iColorIndex+=4;
    if (C.B==255) iColorIndex+=8;

    super.RMouseDown(X, Y);
    szMsg = X $" "$ Y $ " " $ m_CurrentSelectedIcon.m_iButtonID $ " " $ iColorIndex;
    log(szMsg);
    R6PlayerController(GetPlayerOwner()).ServerBroadcast(GetPlayerOwner(), szMsg, 'Icon');
}

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);

    if(X>=60 && X<640 && Y>=0 && Y<480)
	    m_bIsDrawing = true;
}

function LMouseUp(float X, float Y)
{
	super.LMouseUp(X, Y);

    if(m_bIsDrawing)
    {
    	m_bIsDrawing = false;
	    SendLineToTeam();
    }
}

function MouseMove(float X, float Y)
{	
	local float tx, ty;
	local vector v;

	super.MouseMove(X, Y);

	if (m_bIsDrawing)
	{		
		ParentWindow.GetMouseXY(tx, ty);
		v.X=(tx-60.0f)/(640.0f-60.0f);
		v.Y=ty/480.0f;
		v.Z=0;
		GetLevel().AddWritableMapPoint(v, m_cColorPicker.GetSelectedColor());
	}
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local INT		uSize, vSize;
	local Texture	mapTexture;
	Super.Paint(C, X, Y);

	C.SetPos(0, 0);
	C.DrawRect(Texture'Color.Color.Black', 640, 480);

	mapTexture=GetLevel().m_tWritableMapTexture;
	if(mapTexture != none)
	{
		C.SetPos(60, 0);
		C.DrawRect(mapTexture, 640-60, 480);
	}

	C.DrawWritableMap(GetLevel());
}

function Notify(UWindowDialogControl Button, byte Msg)
{
	switch(Msg)
    {
        case DE_Click:
            if (R6WindowRadioButton(Button) != None)
            {
                m_CurrentSelectedIcon.m_bSelected= false;
                m_CurrentSelectedIcon = R6WindowRadioButton(Button);
                m_CurrentSelectedIcon.m_bSelected= true;
            }
            break;
    }
}

function ShowWindow()
{
	Super.ShowWindow();

	Root.m_bScaleWindowToRoot = true; // this is scale the window to the size of the root
}

function HideWindow()
{
	Super.HideWindow();

	Root.m_bScaleWindowToRoot = false;
}

defaultproperties
{
     c_iNbOfIcons=16
}
