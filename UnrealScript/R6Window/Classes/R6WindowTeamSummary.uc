//=============================================================================
//  R6WindowTeamSummary.uc : Team summary in execute screen there is one for each team
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================


class R6WindowTeamSummary extends UWindowWindow;

var R6Operative                       m_teamOperatives[4];
var R6WindowOperativePlanningSummary  m_OperativeSummary[4];

var R6WindowTeamPlanningSummary       m_TeamPlanningSummary;
var FLOAT                             m_fSummaryHeight, m_fOperativeSummaryHeight, m_fYPaddingBetweenElements;

var BOOL                              m_bIsSelected;

function Created()
{
    m_TeamPlanningSummary = R6WindowTeamPlanningSummary(CreateWindow(class'R6WindowTeamPlanningSummary',0,0,WinWidth,m_fSummaryHeight,self));
    
 
    m_OperativeSummary[0] = R6WindowOperativePlanningSummary(CreateWindow(class'R6WindowOperativePlanningSummary',
                                        0,
                                        m_TeamPlanningSummary.WinTop + m_TeamPlanningSummary.WinHeight + m_fYPaddingBetweenElements,
                                        WinWidth,
                                        m_fOperativeSummaryHeight,
                                        self));


    m_OperativeSummary[1] = R6WindowOperativePlanningSummary(CreateWindow(class'R6WindowOperativePlanningSummary',
                                        0,
                                        m_OperativeSummary[0].WinTop + m_OperativeSummary[0].WinHeight + m_fYPaddingBetweenElements,
                                        WinWidth,
                                        m_fOperativeSummaryHeight,
                                        self));

    m_OperativeSummary[2] = R6WindowOperativePlanningSummary(CreateWindow(class'R6WindowOperativePlanningSummary',
                                        0,
                                        m_OperativeSummary[1].WinTop + m_OperativeSummary[1].WinHeight + m_fYPaddingBetweenElements,
                                        WinWidth,
                                        m_fOperativeSummaryHeight,
                                        self));

    m_OperativeSummary[3] = R6WindowOperativePlanningSummary(CreateWindow(class'R6WindowOperativePlanningSummary',
                                        0,
                                        m_OperativeSummary[2].WinTop + m_OperativeSummary[2].WinHeight + m_fYPaddingBetweenElements,
                                        WinWidth,
                                        m_fOperativeSummaryHeight,
                                        self));
 
}

function Init()
{    
    m_teamOperatives[0] = None;
    m_teamOperatives[1] = None;
    m_teamOperatives[2] = None;
    m_teamOperatives[3] = None;

    m_OperativeSummary[0].HideWindow();
    m_OperativeSummary[1].HideWindow();
    m_OperativeSummary[2].HideWindow();
    m_OperativeSummary[3].HideWindow();

}

function AddOperative( R6Operative _Operative)
{    
    local   int                                 addedOperative; 
    local   string                              szPrimaryWeapon, szArmor;
    local   class<R6PrimaryWeaponDescription>   PrimaryWeaponClass;
    local   class<R6ArmorDescription>           ArmorDescriptionClass;
    local   Region                              R;
	

    
    addedOperative = OperativeCount();   

    if( addedOperative == 4)
        return; //Array Full!!!!


    m_teamOperatives[addedOperative] = _Operative;
    m_OperativeSummary[addedOperative].ShowWindow();    

    PrimaryWeaponClass         =  class<R6PrimaryWeaponDescription>( DynamicLoadObject( _Operative.m_szPrimaryWeapon, class'Class' ) );   
    szPrimaryWeapon            =  Localize(PrimaryWeaponClass.Default.m_NameID,"ID_SHORTNAME","R6Weapons",true);

    ArmorDescriptionClass      =  class<R6ArmorDescription>( DynamicLoadObject( _Operative.m_szArmor, class'Class' ) );   
    szArmor                    = Localize(ArmorDescriptionClass.Default.m_NameID,"ID_NAME","R6Armor", true, true);

    R.X= _Operative.m_RMenuFaceSmallX;
    R.Y= _Operative.m_RMenuFaceSmallY;
    R.W= _Operative.m_RMenuFaceSmallW;
    R.H= _Operative.m_RMenuFaceSmallH;

    m_OperativeSummary[addedOperative].setLabels( szPrimaryWeapon, szArmor, _Operative.GetName());
    m_OperativeSummary[addedOperative].setFace( _Operative.m_TMenuFaceSmall, R);

    m_OperativeSummary[addedOperative].setHealth( GetOpHealth(_Operative) );
    m_OperativeSummary[addedOperative].setSpeciality( GetSpeciality(_Operative));


}


function TexRegion GetOpHealth( R6Operative _Operative )
{
    local TexRegion Result;
    
    switch( _Operative.m_iHealth)
	{
        
        case 0: //Alive
    		Result.X = 31;
		    Result.Y = 29;
		    Result.W = 10;
		    Result.H = 10;
			break;
		case 1: //Wounded
			Result.X = 42;
			Result.Y = 29;
			Result.W = 10;
			Result.H = 10;
			break;
		case 2: //Incapacitated or Dead
        case 3:
			Result.X = 53;
			Result.Y = 29;
			Result.W = 10;
			Result.H = 10;
            break;
            
    }

    Result.T = Texture'R6MenuTextures.TeamBarIcon';

    return Result;
}

function TexRegion GetSpeciality( R6Operative _Operative )
{
    local TexRegion Result;

    if(_Operative.m_szSpecialityID == "ID_ASSAULT")
    {     
        Result.X = 229;
		Result.Y = 10;
		Result.W = 9;
		Result.H = 9;
    }
    else if(_Operative.m_szSpecialityID == "ID_SNIPER")
    {
        Result.X = 229;
		Result.Y = 50;
		Result.W = 9;
		Result.H = 9;
        
    }
    else if(_Operative.m_szSpecialityID == "ID_DEMOLITIONS")
    {
        Result.X = 239;
		Result.Y = 10;
		Result.W = 9;
		Result.H = 9;
    }
    else if(_Operative.m_szSpecialityID == "ID_ELECTRONICS")
    {
        Result.X = 229;
		Result.Y = 30;
		Result.W = 9;
		Result.H = 9;        
    }
    else
    {
        //Operative.m_szSpecialityID == "ID_RECON"
        Result.X = 239;
		Result.Y = 30;
		Result.W = 9;
		Result.H = 9;        
    } 

    Result.T = Texture'R6MenuTextures.Tab_Icon00';

    return Result;   
}


function SetSelected(bool _IsSelected)
{

    m_bIsSelected  = _IsSelected;

    m_OperativeSummary[0].SetSelected(_IsSelected);
    m_OperativeSummary[1].SetSelected(_IsSelected);
    m_OperativeSummary[2].SetSelected(_IsSelected);
    m_OperativeSummary[3].SetSelected(_IsSelected);
}

function SetTeam(int _Team)
{        

    switch(_Team)
    {
    case 0: //Red        
        m_TeamPlanningSummary.SetTeamName(Localize("GearRoom","team1","R6Menu"));  
        break;
    case 1: //Green        
        m_TeamPlanningSummary.SetTeamName(Localize("GearRoom","team2","R6Menu"));  
        break;
    case 2: //Gold
        m_TeamPlanningSummary.SetTeamName(Localize("GearRoom","team3","R6Menu"));
        break;

    }
        m_TeamPlanningSummary.SetTeamColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);        

        m_OperativeSummary[0].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
        m_OperativeSummary[1].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
        m_OperativeSummary[2].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
        m_OperativeSummary[3].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
}

function int OperativeCount()
{
    local INT   addedOperative;

    addedOperative = 0;

    while( (addedOperative < 4) && (m_teamOperatives[addedOperative] != None) )
    {
        addedOperative++;
    } 
    
    return addedOperative;
}

function SetPlanningDetails(string szWayPoint, string szGoCode)
{    
    m_TeamPlanningSummary.SetPlanningValues(szWayPoint, szGoCode);
}

defaultproperties
{
     m_fSummaryHeight=53.000000
     m_fOperativeSummaryHeight=44.000000
     m_fYPaddingBetweenElements=2.000000
}
