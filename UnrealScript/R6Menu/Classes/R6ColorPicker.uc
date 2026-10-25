//=============================================================================
// R6ColorPicker - Color picker for the writable map
//=============================================================================
class R6ColorPicker extends UWindowDialogControl;

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE="..\textures\Color.utx" Package="Color.Color"
#exec OBJ LOAD FILE="..\textures\Color.utx" Package="Color"

const NUM_COLOR     = 5;
const PICKWIDTH     = 40;
const PICKHEIGHT    = 20;

var int					m_iSelectedColorIndex;
var Color				m_aColorChoice[NUM_COLOR];

function Paint(Canvas C, float X, float Y)
{
    local INT i;

    for(i=0; i<NUM_COLOR; i++)
    {
        C.SetPos(0, i * PICKHEIGHT);
        C.SetDrawColor(m_aColorChoice[i].R, m_aColorChoice[i].G, m_aColorChoice[i].B);
        C.DrawRect(Texture'Color.Color.White', PICKWIDTH, PICKHEIGHT);
    }

    C.SetDrawColor(m_aColorChoice[m_iSelectedColorIndex].R, m_aColorChoice[m_iSelectedColorIndex].G, m_aColorChoice[m_iSelectedColorIndex].B);
    C.SetPos(1, m_iSelectedColorIndex * PICKHEIGHT + 1);
    C.DrawRect(Texture'Color.Color.Black', PICKWIDTH - 2, PICKHEIGHT - 2);
    C.SetPos(4, m_iSelectedColorIndex * PICKHEIGHT + 4);
    C.DrawRect(Texture'Color.Color.White', PICKWIDTH - 8, PICKHEIGHT - 8);
}

function Color GetSelectedColor()
{
	return m_aColorChoice[m_iSelectedColorIndex];
}

function LMouseDown(float X, float Y)
{
    local INT iSelectedColorIndex;

	super.LMouseDown(X, Y);
	iSelectedColorIndex = Y / PICKHEIGHT;
    if(iSelectedColorIndex >= 0 && iSelectedColorIndex < NUM_COLOR)
        m_iSelectedColorIndex = iSelectedColorIndex;
}

defaultproperties
{
     m_aColorChoice(0)=(G=255,A=255)
     m_aColorChoice(1)=(B=255,G=255,R=255,A=255)
     m_aColorChoice(2)=(R=255,A=255)
     m_aColorChoice(3)=(B=255,A=255)
     m_aColorChoice(4)=(G=255,R=255,A=255)
     bIgnoreLDoubleClick=True
     bIgnoreMDoubleClick=True
     bIgnoreRDoubleClick=True
}
