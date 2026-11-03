class MP2Hud extends R6HUD
    native;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2HUD.utx PACKAGE=MP2Hud
#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2ActionIcons.utx PACKAGE=MP2ActionIcons
#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx PACKAGE=Inventory_t

var int m_iClignoteJauge;
var bool m_bDisplayJauge;
var bool m_bHidePrisonerIcons;
var float m_fClignoteTexte;
var float m_fClignoteTexteFrequece;
var Material m_MP2TexHUDElements;
var Texture m_HeartBeat[3];
var Texture m_texDisqueDetect;
var Texture m_texDisqueTroune;
var Texture m_texIconeFloppy;
var Texture m_texHBS;

native(1616) final function DrawNativeHUDOxygene(Canvas C);

native(1618) final function DrawNativeHUDMP2(Canvas C);

function DrawHUD(Canvas C)
{
    local Vector viewLocation;
    local Rotator ViewRotation;
    local int flashBangCoefficient;
    local R6Pawn aPlayerPawn;

    if(Level.m_bInGamePlanningActive == true)
    {
        if(!m_bHidePrisonerIcons)
        {
            m_bHidePrisonerIcons = true;
            MP2PlayerController(m_PlayerOwner).HideLimitSeatsIcons();
        }
        return;
    }
    m_bHidePrisonerIcons = false;
    if(m_PlayerOwner != none)
    {
        aPlayerPawn = R6Pawn(m_PlayerOwner.Pawn);
    }
    if((m_PlayerOwner != none) && m_PlayerOwner.m_TeamManager != none)
    {
        if(R6PlanningInfo(m_PlayerOwner.m_TeamManager.m_TeamPlanning) != none)
        {
            m_pNextWayPoint = R6PlanningInfo(m_PlayerOwner.m_TeamManager.m_TeamPlanning).GetNextActionPoint();
        }
    }
    if(m_PlayerOwner != none)
    {
        if(!(Level.NetMode == NM_Standalone))
        {
            if(MP2PlayerController(m_PlayerOwner).m_fOxygeneLevel != float(-1))
            {
                DrawNativeHUDOxygene(C);
            }
        }
    }
    DrawNativeHUDMP2(C);
    if(m_PlayerOwner != none)
    {
        if(MP2Rainbow(m_PlayerOwner.m_pawn) != none)
        {
            if((MP2Rainbow(m_PlayerOwner.m_pawn).m_bHasDataObject == true) && int(m_PlayerOwner.m_CurrentCircumstantialAction.iHasAction) == 0)
            {
                C.SetDrawColor(byte(255), byte(255), byte(255), 70);
                C.SetPos(C.HalfClipX - float(16), C.ClipY - float(74));
                C.DrawTile(m_texIconeFloppy, 32.0, 32.0, 0.0, 0.0, 32.0, 32.0);
            }
        }
    }
    if(m_PlayerOwner != none)
    {
        if(m_PlayerOwner.m_InteractionCA != none)
        {
            m_PlayerOwner.m_InteractionCA.m_color = m_iCurrentTeamColor;
        }
        if(m_PlayerOwner.m_InteractionInventory != none)
        {
            m_PlayerOwner.m_InteractionInventory.m_color = m_iCurrentTeamColor;
        }
    }
    if(m_bDisplayTimeBomb)
    {
        DisplayBombTimer(C);
    }
}

function MP2AddTextServerMessage(string M, Class<LocalMessage> MessageClass, optional float fLifeTime, optional byte bMessageUseBigFont)
{
    local int i;

    TextServerMessages[0] = M;
    MessageUseBigFont[0] = bMessageUseBigFont;
    MessageServerLife[0] = fLifeTime;
}

defaultproperties
{
    m_MP2TexHUDElements=Texture'MP2Hud.MP2HUDElements'
    m_HeartBeat[0]=Texture'MP2Hud.heartbeat_greenA'
    m_HeartBeat[1]=Texture'MP2Hud.heartbeat_greenB'
    m_HeartBeat[2]=Texture'MP2Hud.heartbeat_greenC'
    m_texDisqueDetect=Texture'MP2Hud.radardetectdisque'
    m_texDisqueTroune=Texture'MP2Hud.radardetect_tourne'
    m_texIconeFloppy=Texture'MP2ActionIcons.icones_disquette'
    m_texHBS=Texture'Inventory_t.HeartBeat.SphereBeat'
}
