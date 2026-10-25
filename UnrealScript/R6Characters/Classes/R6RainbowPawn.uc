//=============================================================================
//  R6RainbowPawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Created by Rima Brek
//=============================================================================
class R6RainbowPawn extends R6Rainbow
	abstract; 
 
#exec OBJ LOAD FILE=..\Animations\R6Rainbow_UKX.ukx PACKAGE=R6Rainbow_UKX
#exec OBJ LOAD FILE="..\textures\R61stWeapons_T.utx" Package="R61stWeapons_T"

simulated event PostBeginPlay() 
{
    if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer)
        m_iTeam = m_iDefaultTeam;

    if(m_bUseSpecialSkin == false)
    {
        if(m_iDefaultTeam == c_iTeamNumBravo && Level.NetMode != NM_Standalone)
        {
            Skins[0] = Level.RedTeamSkin;
            Skins[1] = Level.RedHeadSkin;
            Skins[2] = Level.RedGogglesSkin;
            Skins[5] = Level.RedHandSkin;
            LinkMesh(Level.RedMesh);
        }
        else
        {
            Skins[0] = Level.GreenTeamSkin;
            Skins[1] = Level.GreenHeadSkin;
            Skins[2] = Level.GreenGogglesSkin;
            Skins[5] = Level.GreenHandSkin;
            LinkMesh(Level.GreenMesh);
        }
    }

   LinkSkelAnim(MeshAnimation'R6Rainbow_UKX.RainbowAnim');
    Super.PostBeginPlay();
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
}

simulated function SetFemaleParameters()
{		
	// scale pawn's mesh
	SetPawnScale(0.95);
    //If the pawn scale changes, don't forget to change the Attach factor.
	m_fAttachFactor=0.95;
	m_fPrePivotPawnInitialOffset = -4.0;
	if(Level.NetMode != NM_Client)
		PrePivot.Z += m_fPrePivotPawnInitialOffset;
}

simulated function SetRainbowFaceTexture()
{
	local	INT			iFaceIndex;
    local	string		aFaceTexture;
    local	Texture		aTexture;

	if(bShowLog) log(self$" SetRainbowFaceTexture() : bIsFemale ="$bIsFemale$" m_iOperativeID="$m_iOperativeID);
	iFaceIndex = 3;

	if(bIsFemale)
	{
		SetFemaleParameters();

		// scale helmet for female operatives
		if(m_Helmet != none)
			m_Helmet.DrawScale=1.0;

		// scale nightvision for female operatives
		if(m_NightVision != none)
			m_NightVision.DrawScale=1.0;
	}

	switch(m_iOperativeID)
	{
		// presence of this : Skins[iFaceIndex]=Texture'R6Characters_t.RainbowFaces.R6RFaceBurke';	
		// causes the texture to be loaded automatically...
		case 0:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceArnavisca";		break;
		case 1:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBeckenbauer";	break;
		case 2:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBogart";			break;
		case 3:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceBurke";			break;
		case 4:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceChaves";			break;
		case 5:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceDuBarry";		break;	
		case 6:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceFilatov";		break;
		case 7:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceGalanos";		break;
		case 8:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHaider";			break;
		case 9:		aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHanley";			break;
		case 10:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceHomer";			break;
		case 11:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceLofquist";		break;
		case 12:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceLoiselle";		break;
		case 13:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMaldini";		break;
		case 14:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMcAllen";		break;
		case 15:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMorris";			break;
		case 16:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceMurad";			break;
		case 17:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNarino";			break;
		case 18:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNoronha";		break;
		case 19:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceNovikov";		break;
		case 20:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceSuo_Won";		break;
		case 21:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFacePetersen";		break;
		case 22:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFacePrice";			break;
		case 23:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceRakuzanka";		break;
		case 24:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceRaymond";		break;
		case 25:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWalter";			break;
		case 26:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWeber";			break;
		case 27:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceWoo";			break;
		case 28:	aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceYakoby";			break;	
		default:
			aFaceTexture = "R6Characters_t.RainbowFaces.R6RFaceReserve";					
	}

	if(aFaceTexture != "")
		Skins[iFaceIndex] = Texture(DynamicLoadObject(aFaceTexture, class'Texture'));
}

defaultproperties
{
     m_FOVClass=Class'R6Characters.R6FieldOfView'
     Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel213
         KConvulseSpacing=(Max=2.200000)
         KSkeleton="terroskel"
         KStartEnabled=True
         bHighDetailOnly=False
         KLinearDamping=0.500000
         KAngularDamping=0.500000
         KBuoyancy=1.000000
         KVelDropBelowThreshold=50.000000
         KFriction=0.600000
         KRestitution=0.300000
         KImpactThreshold=150.000000
         Name="KarmaParamsSkel213"
     End Object
     KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel213'
     Skins(5)=Texture'R61stWeapons_T.Hands.R61stHands'
}
