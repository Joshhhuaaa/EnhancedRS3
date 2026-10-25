//=============================================================================
// R6ColorPicker - Color picker for the writable map
//=============================================================================
class R6OperativeSelectorItem extends UWindowDialogControl;

var R6Rainbow m_Operative;
var R6TeamMemberReplicationInfo m_MemberRepInfo;
var INT       m_iOperativeIndex;
var INT       m_iTeam;
var byte      m_eHealth;
var String    m_szSpeciality;
var String    m_WeaponsName[4];
var BOOL      m_bMouseOver;
var string    m_szName;
var BOOL      m_bIsDead;
var BOOL      m_bIsSinglePlayer;

var const INT NameX;
var const INT NameY;
var const INT SpecX;
var const INT SpecY;
var const INT WeaponX;
var const INT WeaponY;
var const INT WeaponHeight;
var const INT LifeX;
var const INT LifeY;
var Sound m_OperativeSelectSnd;
var Color m_DarkColor;
var Color m_NormalColor;
var Material HealthIconTexture;
var Material DefaultFaceTexture;
var Plane    DefaultFaceCoords;

function LMouseDown(float X, float Y)
{
    local R6PlayerController PlayerOwner;
    local R6RainbowTeam TeamManager;

    if (m_bIsDead)
        return;
    
    PlayerOwner = R6PlayerController(GetPlayerOwner());

    PlayerOwner.PlaySound(m_OperativeSelectSnd, SLOT_Menu);

    if (!m_bIsSinglePlayer)
    {
        // TeamId is useless in MP since we know in whcih team we are from the controller.
        PlayerOwner.ChangeOperative(0, m_MemberRepInfo.m_iTeamPosition);
    }
    else
    {
        if(!m_Operative.m_bIsPlayer)
            TeamManager = R6RainbowAI(m_Operative.controller).m_TeamManager;
        else
            TeamManager = R6PlayerController(m_Operative.controller).m_TeamManager;

        PlayerOwner.ChangeOperative(TeamManager.m_iRainbowTeamName, m_Operative.m_iID);
    }

    Root.ChangeCurrentWidget( WidgetID_None );
}

function SetCharacterInfo(R6Rainbow Character)
{
    local INT iWeapon;

    m_Operative = Character;
    m_MemberRepInfo = None;
    m_bIsSinglePlayer = true;

    for (iWeapon = 0; iWeapon < 4; iWeapon++)
    {
        if (m_Operative.m_WeaponsCarried[iWeapon] != None)
        {
            m_WeaponsName[iWeapon] = m_Operative.m_WeaponsCarried[iWeapon].m_WeaponShortName;
        }
        else
        {
            if((iWeapon == 2) &&
                (m_Operative.m_szPrimaryItem != ""))
            {
                m_WeaponsName[iWeapon] = Localize(m_Operative.m_szPrimaryItem, "ID_NAME", "R6Gadgets");
            }
            else if ((iWeapon == 3) &&
                     (m_Operative.m_szSecondaryItem != ""))
            {
                m_WeaponsName[iWeapon] = Localize(m_Operative.m_szSecondaryItem, "ID_NAME", "R6Gadgets");
            }
        }
    }
}

function SetCharacterInfoMP(R6TeamMemberReplicationInfo RepInfo)
{
    m_MemberRepInfo = RepInfo;
    m_Operative = None;
    m_bIsSinglePlayer = false;

    if (m_MemberRepInfo.m_PrimaryWeapon != "")
        m_WeaponsName[0] = Localize(m_MemberRepInfo.m_PrimaryWeapon, "ID_NAME", "R6Weapons");
    else
        m_WeaponsName[0] = Localize("MISC","ID_EMPTY","R6Common");

    if (m_MemberRepInfo.m_SecondaryWeapon != "")
        m_WeaponsName[1] = Localize(m_MemberRepInfo.m_SecondaryWeapon, "ID_NAME", "R6Weapons");
    else
        m_WeaponsName[1] = Localize("MISC","ID_EMPTY","R6Common");

    if (m_MemberRepInfo.m_PrimaryGadget != "")
        m_WeaponsName[2] = Localize(m_MemberRepInfo.m_PrimaryGadget, "ID_NAME", "R6Gadgets");

    if (m_MemberRepInfo.m_SecondaryGadget != "")
        m_WeaponsName[3] = Localize(m_MemberRepInfo.m_SecondaryGadget, "ID_NAME", "R6Gadgets");
}

function MouseEnter()
{
    Super.MouseEnter();
    m_bMouseOver = true;
}

function MouseLeave()
{
    Super.MouseLeave();
    m_bMouseOver = false;
}

function UpdateGadgets()
{
    local BOOL bIsPrimaryGadgetEmpty;
    local BOOL bIsPrimaryGadgetSet;
    local BOOL bIsSecondaryGadgetEmpty;
    local BOOL bIsSecondaryGadgetSet;

    if (m_Operative.m_WeaponsCarried[2] != None)
    {
        if (m_Operative.m_WeaponsCarried[2].HasAmmo())
        {
            m_WeaponsName[2] = Localize(m_Operative.m_WeaponsCarried[2].m_NameID, "ID_NAME", "R6Gadgets");
        }
        else
        {
            m_WeaponsName[2] = Localize("MISC","ID_EMPTY","R6Common");
        }
        bIsPrimaryGadgetSet = true;
    }
    
    if (m_Operative.m_WeaponsCarried[3] != None)
    {
        if (m_Operative.m_WeaponsCarried[3].HasAmmo())
        {
            m_WeaponsName[3] = Localize(m_Operative.m_WeaponsCarried[3].m_NameID, "ID_NAME", "R6Gadgets");
        }
        else
        {   
            m_WeaponsName[3] = Localize("MISC","ID_EMPTY","R6Common");
        }
        
        bIsSecondaryGadgetSet = true;
    }
    
    // Check for passive gadgets
    if (m_Operative.m_bHasLockPickKit)
    {
        if (!bIsPrimaryGadgetSet)
        {
            m_WeaponsName[2] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
            bIsPrimaryGadgetSet = true;
        }
        else if (!bIsSecondaryGadgetSet)
        {
            m_WeaponsName[3] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
            bIsSecondaryGadgetSet = true;
        }
    }
    
    if (m_Operative.m_bHasDiffuseKit)
    {
        if (!bIsPrimaryGadgetSet)
        {
            m_WeaponsName[2] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
            bIsPrimaryGadgetSet = true;
        }
        else if (!bIsSecondaryGadgetSet)
        {
            m_WeaponsName[3] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
            bIsSecondaryGadgetSet = true;
        }
    }
    
    if (m_Operative.m_bHasElectronicsKit)
    {
        if (!bIsPrimaryGadgetSet)
        {
            m_WeaponsName[2] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
            bIsPrimaryGadgetSet = true;
        }
        else if (!bIsSecondaryGadgetSet)
        {
            m_WeaponsName[3] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
            bIsSecondaryGadgetSet = true;
        }
    }
    
    if (m_Operative.m_bHaveGasMask)
    {
        if (!bIsPrimaryGadgetSet)
        {
            m_WeaponsName[2] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
            bIsPrimaryGadgetSet = true;
        }
        else if (!bIsSecondaryGadgetSet)
        {
            m_WeaponsName[3] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
            bIsSecondaryGadgetSet = true;
        }
    }
    
    if (!bIsPrimaryGadgetSet)
    {
        m_WeaponsName[2] = Localize("MISC","ID_EMPTY","R6Common");
    }
    
    if (!bIsSecondaryGadgetSet)
    {
        m_WeaponsName[3] = Localize("MISC","ID_EMPTY","R6Common");
    }
}

function UpdatePosition()
{
    WinTop = class'R6MenuInGameOperativeSelectorWidget'.Default.c_OutsideMarginY + 
        class'R6MenuInGameOperativeSelectorWidget'.Default.c_InsideMarginY + 
        (m_Operative.m_iID * (class'R6MenuInGameOperativeSelectorWidget'.Default.c_InsideMarginY + class'R6MenuInGameOperativeSelectorWidget'.default.c_RowHeight));

}

function UpdatePositionMP()
{
    if (m_MemberRepInfo != None)
    {
        WinTop = class'R6MenuInGameOperativeSelectorWidget'.Default.c_OutsideMarginY + 
            class'R6MenuInGameOperativeSelectorWidget'.Default.c_InsideMarginY + 
            (m_MemberRepInfo.m_iTeamPosition * (class'R6MenuInGameOperativeSelectorWidget'.Default.c_InsideMarginY + class'R6MenuInGameOperativeSelectorWidget'.default.c_RowHeight));
    }
}

    // +---------------------------------+ (1)
    // |       |                         |
    // |       |        (9)              |
    // |  (8)  |-------------------------| (4)
    // |       |                         | 
    // |       |        (10)             |
    // +-------+-------------------------+ (2)
    // |      (7)                        |
    // |                                 |
    // |              (11)               |
    // |                                 |
    // |                                 |
    // +---------------------------------+ (3)
    //(5)                               (6) 

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    local INT       iLifeU;
    local INT       iWeapon;
    local BOOL      bIsDead;
    local BOOL      bCurrentSelection;
    local BYTE      NameAlpha;
    local Color     NameColor;
    local Color     NameBackgroundColor;
    local BYTE      NameBackgroundAlpha;
    local BYTE      SpecAlpha;
    local Color     SpecColor;
    local Color     SpecAndWeaponBackgroundColor;
    local BYTE      SpecAndWeaponBackgroundAlpha;
    local Color     WeaponColor;
    local BYTE      WeaponAlpha;
    local BYTE      FaceAlpha;
    local Color     LineColor;
    local BYTE      LineAlpha;
    local string    Name;
    local BOOL      bIsPrimaryGadgetEmpty;
    local BOOL      bIsSecondaryGadgetEmpty;

    local FLOAT     fPosX;
    local FLOAT     fPosY;
    local PlayerController PlayerOwner;

    PlayerOwner = GetPlayerOwner();

    if (m_bIsSinglePlayer)
    {
        if (PlayerOwner.ViewTarget == m_Operative)
        {
            bCurrentSelection = true;
        }
        else
        {
            bCurrentSelection = false;
        }

        m_eHealth = m_Operative.m_eHealth;
        m_bIsDead = m_eHealth >= m_Operative.eHealth.HEALTH_Incapacitated;

        // Update Gadget Information
        UpdateGadgets();
        bIsPrimaryGadgetEmpty = false;
        bIsSecondaryGadgetEmpty = false;
    }
    else
    {
        if (m_MemberRepInfo == R6Pawn(PlayerOwner.Pawn).m_TeamMemberRepInfo)
        {
            bCurrentSelection = true;
        }
        else
        {
            bCurrentSelection = false;
        }

        m_eHealth = m_MemberRepInfo.m_eHealth;
        m_bIsDead = m_eHealth >= PlayerOwner.Pawn.eHealth.HEALTH_Incapacitated;
        bIsPrimaryGadgetEmpty = m_MemberRepInfo.m_bIsPrimaryGadgetEmpty;
        bIsSecondaryGadgetEmpty = m_MemberRepInfo.m_bIsSecondaryGadgetEmpty;
    }

    iLifeU = Min(INT(m_eHealth), 2);

    C.Style = ERenderStyle.STY_Alpha;

    LineColor = m_NormalColor;

    if (m_bIsDead == true)
    {
        NameColor = m_NormalColor;
        NameAlpha = 128;

        NameBackgroundColor = m_DarkColor;
        NameBackgroundAlpha = 255;

        SpecColor = m_NormalColor;
        SpecAlpha = 128;

        WeaponColor = m_NormalColor;
        WeaponAlpha = 128;

        SpecAndWeaponBackgroundColor = m_DarkColor;
        SpecAndWeaponBackgroundAlpha = 128;

        FaceAlpha = 128;

        LineAlpha = 128;
    }
    else if(m_bMouseOver)
    {
        NameColor = m_DarkColor;
        NameAlpha = 255;

        NameBackgroundColor = m_NormalColor;
        NameBackgroundAlpha = 255;

        SpecColor = Root.Colors.White;
        SpecAlpha = 255;

        WeaponColor = Root.Colors.White;
        WeaponAlpha = 255;

        SpecAndWeaponBackgroundColor = m_DarkColor;
        SpecAndWeaponBackgroundAlpha = 255;

        FaceAlpha = 255;

        LineAlpha = 255;
    }
    else if (bCurrentSelection)
    {
        NameColor = Root.Colors.White;
        NameAlpha = 255;

        NameBackgroundColor = m_NormalColor;
        NameBackgroundAlpha = 128;

        SpecColor = Root.Colors.White;
        SpecAlpha = 255;

        WeaponColor = Root.Colors.White;
        WeaponAlpha = 255;

        SpecAndWeaponBackgroundColor = m_NormalColor;
        SpecAndWeaponBackgroundAlpha = 128;

        FaceAlpha = 255;

        LineAlpha = 255;
    }
    else // Normal
    {
        NameColor = m_NormalColor;
        NameAlpha = 255;

        NameBackgroundColor = m_DarkColor;
        NameBackgroundAlpha = 255;

        SpecColor = m_NormalColor;
        SpecAlpha = 255;

        WeaponColor = m_NormalColor;
        WeaponAlpha = 255;

        SpecAndWeaponBackgroundColor = m_DarkColor;
        SpecAndWeaponBackgroundAlpha = 128;

        FaceAlpha = 255;

        LineAlpha = 255;
    }

    // (9) Operative Name's Background
    C.DrawColor = NameBackgroundColor;
    C.DrawColor.A = NameBackgroundAlpha;
    DrawStretchedTextureSegment(C, 40, 1, WinWidth - 41, 21, 0, 0, 1, 1, Texture'Color.Color.White');

    // (9) Operative Name
    Name = GetCharacterName();
    C.TextSize(Name, fPosX, fPosY);
    C.SetPos(NameX - (fPosX / 2.0), NameY);
    C.Font = Root.Fonts[F_PopUpTitle];
    C.DrawColor = NameColor;
    C.DrawColor.A = NameAlpha;
    C.DrawText(Name);

    // (9) Operative Health Status
    C.SetPos(LifeX, LifeY);
    C.DrawTile(HealthIconTexture, 10, 10, 31 + 11 * iLifeU , 29, 10, 10);

    // (10) & (11) Speciality & Weapon Backgrounds
    C.DrawColor = SpecAndWeaponBackgroundColor;
    C.DrawColor.A = SpecAndWeaponBackgroundAlpha;
    DrawStretchedTextureSegment(C, 40, 23, WinWidth - 40, 20, 0, 0, 1, 1, Texture'Color.Color.White');
    DrawStretchedTextureSegment(C, 1, 44, WinWidth - 2, 44, 0, 0, 1, 1, Texture'Color.Color.White');

    // Draw Lines
    C.DrawColor = LineColor;
    C.DrawColor.A = LineAlpha;
    DrawStretchedTextureSegment(C, 1, 0, WinWidth - 2, 1, 0, 0, 1, 1, Texture'Color.Color.White'); // (1)
    DrawStretchedTextureSegment(C, 1, 43, WinWidth - 2, 1, 0, 0, 1, 1, Texture'Color.Color.White'); // (2)
    DrawStretchedTextureSegment(C, 1, WinHeight - 1, WinWidth - 2, 1, 0, 0, 1, 1, Texture'Color.Color.White'); // (3)
    DrawStretchedTextureSegment(C, 40, 22, WinWidth - 38, 1, 0, 0, 1, 1, Texture'Color.Color.White'); // (4)
    DrawStretchedTextureSegment(C, 0, 0, 1, WinHeight, 0, 0, 1, 1, Texture'Color.Color.White'); // (5)
    DrawStretchedTextureSegment(C, WinWidth - 1, 0, 1, WinHeight, 0, 0, 1, 1, Texture'Color.Color.White'); // (6)
    DrawStretchedTextureSegment(C, 39, 0, 1, 43, 0, 0, 1, 1, Texture'Color.Color.White'); // (7)


    // (8) Operative Face
    C.SetPos(1, 1);
    C.DrawColor = Root.Colors.White;
    C.DrawColor.A = FaceAlpha;

    if (m_bIsSinglePlayer)
    {
        // Face in Single Player
        C.DrawTile(m_Operative.m_FaceTexture, 38, 42, m_Operative.m_FaceCoords.X, m_Operative.m_FaceCoords.Y, m_Operative.m_FaceCoords.Z, m_Operative.m_FaceCoords.W);

        // (10) Speciality.
        // Speciality doesn't make sense in Multiplayer
        C.DrawColor = SpecColor;
        C.DrawColor.A = SpecAlpha;
        C.TextSize(m_szSpeciality, fPosX, fPosY);
        C.SetPos(SpecX - fPosX / 2.0f, SpecY);
        C.DrawText(m_szSpeciality);
    }
    else
    {
        // Face in multiplayer 
        C.DrawTile(DefaultFaceTexture, 38, 42, DefaultFaceCoords.X, DefaultFaceCoords.Y, DefaultFaceCoords.Z, DefaultFaceCoords.W);
    }
    
    // (11) Weapon
    C.DrawColor = WeaponColor;
    C.DrawColor.A = WeaponAlpha;
    C.Font = Root.Fonts[F_VerySmallTitle];
    for (iWeapon = 0; iWeapon < 2; iWeapon++)
    {
        C.SetPos(WeaponX, WeaponY + WeaponHeight * iWeapon);
        C.DrawText(m_WeaponsName[iWeapon]);
    }

    C.SetPos(WeaponX, WeaponY + WeaponHeight * 2);

    if (bIsPrimaryGadgetEmpty)
    {
        C.DrawText(Localize("MISC","ID_EMPTY","R6Common"));
    }
    else
        C.DrawText(m_WeaponsName[iWeapon]);

    C.SetPos(WeaponX, WeaponY + WeaponHeight * 3);

    if (bIsSecondaryGadgetEmpty)
    {
        C.DrawText(Localize("MISC","ID_EMPTY","R6Common"));
    }
    else
        C.DrawText(m_WeaponsName[3]);
}

function string GetCharacterName()
{
    if (m_bIsSinglePlayer)
    {
        if (m_Operative != None)
        {
            return m_Operative.m_CharacterName;
        }
    }
    else
    {
        return m_MemberRepInfo.m_CharacterName;
    }
}

defaultproperties
{
     NameX=119
     NameY=6
     SpecX=119
     SpecY=26
     WeaponX=5
     WeaponY=44
     WeaponHeight=10
     LifeX=44
     LifeY=6
     m_OperativeSelectSnd=Sound'SFX_Menus.Play_Rose_Select'
     HealthIconTexture=Texture'R6MenuTextures.Credits.TeamBarIcon'
     DefaultFaceTexture=Texture'R6MenuOperative.RS6_Memeber_01'
     DefaultFaceCoords=(W=42.000000,X=472.000000,Y=308.000000,Z=38.000000)
}
