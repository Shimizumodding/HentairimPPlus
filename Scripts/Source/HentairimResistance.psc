Scriptname HentairimResistance extends ActiveMagicEffect  

import b612

IVDTControllerScript Property MasterScript Auto
SexLabFramework Property SexLab Auto 
SexLabThread CurrentThread = None
actor Actorref
actor playerref
actor[] actorlist
int position
string ActorRaceName = ""

bool IsPlayer
int gender
string RaceNameFuckingPC 
int resistance
Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actorref = akTarget
	PrintDebug("Effect Start for " + Actorref.getdisplayname() )	
		
	PerformInitialization()
	
EndEvent

Function PerformInitialization()
PrintDebug("Perform Initialization")	
	
	CurrentThread = Sexlab.GetThreadByActor(Actorref)
	actorlist = CurrentThread.GetPositions()
	
	int X = 0
	;establish positions
	while x < actorlist.length
		if Actorref == actorlist[x]
			position = X
		Endif
		x += 1
	endwhile
	
	RegisterForTheEventsWeNeed()
	
	if sexlab == none
		PrintDebug("oh noes sexlab is none!")	
	endif
	
	if CurrentThread == none
		PrintDebug("oh noes Sexlab Thread is none!")	
	endif
	
	if MasterScript == none
		PrintDebug("oh noes Director is none!")	
	endif
	
	PrintDebug("actor list" + actorlist)

	;Base Hentairim Preparation
	InitializeConfigandForms()
	HentairimPrepare()	
	
	printdebug("initialized complete")
	;startup calculations
	CalculateStartupResistance()
EndFunction

Function RegisterForTheEventsWeNeed()
	printdebug("Registering Event")
	RegisterForModEvent("AnimationEnd", "ResistanceSceneEnd")
	
	RegisterForModEvent("StageStart", "ResistanceOnStageStart")

	RegisterForSingleUpdate(0.1)
EndFunction

Event ResistanceSceneEnd(string eventName, string argString, float argNum, form sender);
		
	PrintDebug("Scene end")
	
EndEvent


Event ResistanceOnStageStart(string eventName, string argString, float argNum, form sender)
	PrintDebug("Perform stage start")	
	
	
EndEvent

int lastenjoyment
Event OnUpdate()

	;Ends if actor is no longer in scene but magic stuck for some reason	
	if Sexlab.GetThreadByActor(actorref) == none
		RemoveResistanceSpell()
	endif
	UpdateActorResistanceDebttoCurrent()	
	if GetResistance() > 0 && IsGettingFucked()
		
		int damagetodo = 0
		damagetodo =  CurrentThread.GetEnjoyment(actorref) - LastEnjoyment
		printdebug("damage to do :" + damagetodo)
		if damagetodo > 0
			LastEnjoyment = CurrentThread.GetEnjoyment(actorref)
		
			AddResistanceDamage(damagetodo as float)
		
			HentairimUpdateStageData()
		endif

		RegisterForSingleUpdate(3.0)
	else
		RegisterForSingleUpdate(5.0)
	endif
EndEvent


;-------------------------------Hentairim Resistance Functions START---------------------------------
;sexLabThreadController.ActorAlias(actorInQuestion).GetFullEnjoyment()
string AggressorResistanceFile = "HentairimResistance/Config.json"
int enableaggressionresistance
int enablepcresistancedamage
int pcnonvictimresistancedamagemultiplier
int npcnonvictimresistancedamagemultiplier
int pcvictimresistancedamagemultiplier  = 100
int npcvictimresistancedamagemultiplier  = 100
int pcmaxresistance
int pcrecoverresistancepercentageperhour
int npcrecoverresistancepercentageperhour
int pcbrokenpointsfromresistancebreak
int npcbrokenpointsfromresistancebreak
int pcorgasmresistancedamage
int hugeppresistancedamagemultiplier
int enablemalenpcresistancedamage
int enablefemalenpcresistancedamage
int enablecreaturenpcresistancedamage
int npcorgasmresistancedamage
int victimresistancedamagemultiplier
int MaxResistance
Faction HentairimResistanceFaction
int enableprintdebug
Function InitializeConfigandForms()
	printdebug("Initializing forms and config")
	playerref = game.getplayer()
	IsPlayer = actorref == playerref
	Gender = sexlab.GetGender(ActorRef)
	ActorRaceName = actorref.GetRace().getName()
	RaceNameFuckingPC = actorlist[1].GetRace().getName() ;find time to make it more accurate
	
HentairimResistanceFaction = Game.GetFormFromFile(0x803, "HentairimResistance.esp") as Faction	

enableaggressionresistance = JsonUtil.GetIntValue(AggressorResistanceFile, "enableaggressionresistance", 0)
enablepcresistancedamage = JsonUtil.GetIntValue(AggressorResistanceFile, "enablepcresistancedamage", 0)
pcnonvictimresistancedamagemultiplier = JsonUtil.GetIntValue(AggressorResistanceFile, "pcnonvictimresistancedamagemultiplier", 100)
npcnonvictimresistancedamagemultiplier = JsonUtil.GetIntValue(AggressorResistanceFile, "npcnonvictimresistancedamagemultiplier", 100)
pcvictimresistancedamagemultiplier = JsonUtil.GetIntValue(AggressorResistanceFile, "pcvictimresistancedamagemultiplier", 100)
npcvictimresistancedamagemultiplier = JsonUtil.GetIntValue(AggressorResistanceFile, "npcvictimresistancedamagemultiplier", 100)
pcmaxresistance = JsonUtil.GetIntValue(AggressorResistanceFile, "pcmaxresistance", 300)
pcrecoverresistancepercentageperhour = JsonUtil.GetIntValue(AggressorResistanceFile, "pcrecoverresistancepercentageperhour", 20)
npcrecoverresistancepercentageperhour = JsonUtil.GetIntValue(AggressorResistanceFile, "npcrecoverresistancepercentageperhour", 20)
pcbrokenpointsfromresistancebreak = JsonUtil.GetIntValue(AggressorResistanceFile, "pcbrokenpointsfromresistancebreak", 0)
npcbrokenpointsfromresistancebreak = JsonUtil.GetIntValue(AggressorResistanceFile, "npcbrokenpointsfromresistancebreak", 0)
hugeppresistancedamagemultiplier = JsonUtil.GetIntValue(AggressorResistanceFile, "hugeppresistancedamagemultiplier", 100)
enablemalenpcresistancedamage = JsonUtil.GetIntValue(AggressorResistanceFile, "enablemalenpcresistancedamage", 0)
enablefemalenpcresistancedamage = JsonUtil.GetIntValue(AggressorResistanceFile, "enablefemalenpcresistancedamage", 0)
enablecreaturenpcresistancedamage = JsonUtil.GetIntValue(AggressorResistanceFile, "enablecreaturenpcresistancedamage", 0)
;enablewidget = JsonUtil.GetIntValue(AggressorResistanceFile, "enablewidget", 0)
enableprintdebug = JsonUtil.GetIntValue(AggressorResistanceFile, "enableprintdebug", 0)


;initialize faction
if !Actorref.IsInFaction(HentairimResistanceFaction)
	SetResistance(100)
endif
if !Actorref.IsInFaction(HentairimBroken)
	SetBrokenPoints(0)
endif

endfunction

Function RemoveResistanceSpell()
	Spell ResistanceSpell = Game.GetFormFromFile(0x800, "HentairimResistance.esp") as Spell	
	actorref.removespell(ResistanceSpell)
endfunction


Function CalculateStartupResistance()
int ResistancetoRecover = 0

printdebug("hours since last sex : " + sexlab.HoursSinceLastSex(actorref))
if IsBroken()
	 SetBrokenpoints(GetBrokenpoints() - math.floor(sexlab.HoursSinceLastSex(actorref)))
	
	if IsBroken() ;still broken. 0 resistance
		resistance = 0
	else 
		;recover resistance
		SetResistance(100)
		if isplayer
			announce("You Recovered from being broken!")
		endif
		return
	endif
	
endif

if isplayer
		;start pc recover resistance 
	SetResistance(GetResistance() + math.floor((sexlab.HoursSinceLastSex(actorref) * pcrecoverresistancepercentageperhour ) as int))
else
	;start npc recover resistance 
	SetResistance(GetResistance() + math.floor(sexlab.HoursSinceLastSex(actorref) * npcrecoverresistancepercentageperhour))
endif


endfunction

float AccumulatedResistanceDamage = 0.0


bool function IsGettingFucked()
string penetrationlbl1

penetrationlbl1  = HentaiRimTags.PenetrationLabel(CurrentSceneID , currentstage , 0)

if isvictim
	;always getting fucked if victim
	return true
elseif iscowgirl()
	return false
elseif IsgettingPenetrated()
	return true
elseif IsGettingSuckedoff()
	return true
elseif position > 0 && (penetrationlbl1 == "SCG" ||  penetrationlbl1 == "FCG" ||  penetrationlbl1 == "SAC" ||  penetrationlbl1 == "FAC"	)
	;Getting femdommed
	return true
else 
	return false
endif
endfunction

function AddResistanceDamage(float value)
printdebug("GetPercentageofMaxResistance(value) : " + GetPercentageofMaxResistance(value))
float Damage = GetPercentageofMaxResistance(value) * GetResistanceDamageMultiplier()

printdebug("add resistance damege :" + value)
printdebug("damage percentage of max resistance :" + Damage)

if GetResistance() < 0
	Damage = 0
	return
endif

AccumulatedResistanceDamage += Damage
printdebug("AccumulatedResistanceDamage :" + AccumulatedResistanceDamage)
if AccumulatedResistanceDamage >= 0.01
	printdebug("do damage :" + AccumulatedResistanceDamage * 100)
	SetResistance(GetResistance() - math.floor((AccumulatedResistanceDamage * 100)))
	AccumulatedResistanceDamage = 0
	
	if GetResistance() < 0
		SetResistance(0)
	endif
endif

if GetResistance() <= 0 && !isbroken()
	if isplayer
		SetBrokenPoints(pcbrokenpointsfromresistancebreak)
	else
		SetBrokenPoints(npcbrokenpointsfromresistancebreak)
	endif
endif

endfunction


function UpdateActorResistanceDebttoCurrent()
	float resistancedebt = StorageUtil.GetfloatValue(Actorref, "ActorResistanceDebt" ,0)
	if resistancedebt > 0
		AddResistanceDamage(resistancedebt)
		StorageUtil.SetfloatValue(Actorref, "ActorResistanceDebt" ,0)
	endif
EndFunction


int function GetResistance()

	return actorref.GetFactionRank(HentairimResistanceFaction)

endFunction

int function GetBrokenPoints()

	return actorref.GetFactionRank(HentairimBroken)

endFunction

function SetBrokenPoints(int value)
if !actorref.isinfaction(HentairimBroken)
	actorref.addtofaction(HentairimBroken)
endif

int NewBrokenValue  = Value
if NewBrokenValue <= 0
	NewBrokenValue = 0
elseif NewBrokenValue > 127
	NewBrokenValue = 127
endif
;announce broken
if actorref.GetFactionRank(HentairimBroken) == 0 && NewBrokenValue > 0 && isplayer
	Announce(Actorref.getdisplayname() + " Is Broken!")
Endif

actorref.SetFactionRank(HentairimBroken , NewBrokenValue)

endFunction

function SetResistance(int value)
printdebug("setting resistance : " + value)
if enableaggressionresistance != 1 || IsBroken() ; dont need to add resistance damage after broken
	return
endif

int NewResistance = value

if !actorref.isinfaction(HentairimResistanceFaction)
	actorref.addtofaction(HentairimResistanceFaction)
	actorref.SetFactionRank(HentairimResistanceFaction,100)
endif

if NewResistance > 100
	printdebug("Resistance reached cap")
NewResistance =  100
endif

Actorref.SetFactionRank(HentairimResistanceFaction,NewResistance)

endfunction


int function GetResistancePercentage()
if enableaggressionresistance == 0	
	return 100
else
	int res = GetResistance()

	if res < 0
		res = 0
	endif
	
	return res
endif
endFunction


float function GetPercentageofMaxResistance(float value)

return value /  GetMaxResistanceAbsolute()
endfunction

String RaceBaseResistance = "HentairimResistance/RaceBaseResistance.json"
Float function GetMaxResistanceAbsolute()

if IsPlayer
	return pcmaxresistance as float
else
	return jsonUtil.GetIntValue(RaceBaseResistance, ActorRaceName  , 100) as float
endif
endFunction

Float Function GetResistanceDamageMultiplier()
float ResistanceDamageMultiplier = 1
 
if IsPlayer
	;PCRacebasedResistanceLossModifier
	ResistanceDamageMultiplier = ResistanceDamageMultiplier * PCRacebasedResistanceLossModifier()
	
	;set victim / non victim resistance Multiplier
	if IsVictim
		ResistanceDamageMultiplier = ResistanceDamageMultiplier * pcvictimresistancedamagemultiplier /100 as float
		else
		ResistanceDamageMultiplier = ResistanceDamageMultiplier * pcnonvictimresistancedamagemultiplier /100 as float
	endif
	;huge pp multiplier for PC
	if ishugepp
		ResistanceDamageMultiplier = ResistanceDamageMultiplier * hugeppresistancedamagemultiplier /100 as float
	endif
	
	

else
	if IsVictim
		ResistanceDamageMultiplier = ResistanceDamageMultiplier * npcvictimresistancedamagemultiplier /100 as float
	else
		ResistanceDamageMultiplier = ResistanceDamageMultiplier * npcnonvictimresistancedamagemultiplier /100 as float
	endif
endif
printdebug("ResistanceDamageMultiplier :" + ResistanceDamageMultiplier)
return ResistanceDamageMultiplier
endfunction

String RaceFuckingPCFile  = "HentairimResistance/RaceFuckingPCResistanceModifier.json"

float Function PCRacebasedResistanceLossModifier()
float RaceFuckingPCModifier = jsonUtil.GetFloatValue(RaceFuckingPCFile, RaceNameFuckingPC  , 1.0)
return RaceFuckingPCModifier
endFunction
;/
Function UpdateWidget()
string root = PUT SOME SWF
asDirection = "Right"

int MeterID = iwant_widgets_native.LoadMeter(root,Int 20, 20, true)
iwant_widgets_native.SetSize(root,MeterID,20,50)

iwant_widgets_native.SetMeterPercent(root,MeterID, GetResistance()
iwant_widgets_native.DoMeterFlash(root,MeterID)

endfunction
/;
;-------------------------------Hentairim Resistance Functions END---------------------------------

;-----------------------BASE HENTAIRIM Update Functions-----------------------------

Bool IsHugePP
string CurrentSceneID = ""
string currentStageID = ""
Int currentStage = -1
Int ThreadID = -1
Faction HentairimBroken
bool IsVictim

Function HentairimPrepare()
	printdebug("Hentairim Prepare Initial Data ")
	HentairimBroken = Game.GetFormFromFile(0x802, "HentairimResistance.esp") as Faction
	ThreadID = CurrentThread.GetThreadID()
	IsHugePP = IsHugePP()
	HentairimUpdateStageData()
	IsVictim = IsVictim(Actorref)
	
	printdebug("ThreadID : " + ThreadID)
	printdebug("Partner IsHugePP : " + IsHugePP)


endfunction
float DirectorLastLabelTime
Function HentairimUpdateStageData()
	printdebug("Hentairim Update Stage Data ")

	if DirectorLastLabelTime != MasterScript.GetDirectorLastLabelTime()	
		printdebug("Animation or Stage is Different. Updating Stage Data")
		CurrentSceneID = CurrentThread.GetActiveScene()
		currentStageID = CurrentThread.GetActiveStage()
		currentstage = GetLegacyStageNum(CurrentSceneID, currentStageID)
		
		UpdateLabels(Actorref)	

		printdebug("PC Thread Position : " + CurrentThread.GetPositionIdx(Actorref))
		printdebug("current Animation : " + CurrentSceneID)
		printdebug("current StageID : " + currentStageID)
		printdebug("current stage number: " + currentstage)
		DirectorLastLabelTime = MasterScript.GetDirectorLastLabelTime()
	endif
	
endfunction

String Stimulationlabel
String PenisActionLabel
string OralLabel
string EndingLabel
string PenetrationLabel
string Labelsconcat
;sexLabThreadController.ActorAlias(actorInQuestion).GetFullEnjoyment()

Function UpdateLabels(actor char)
 	printdebug("Hentairim Updating Labels")

 Stimulationlabel = MasterScript.GetStimulationlabel(char)
 PenisActionLabel  = MasterScript.GetPenisActionLabel(char)
 OralLabel  = MasterScript.GetOralLabel(char)
 EndingLabel  = MasterScript.GetEndingLabel(char)
 PenetrationLabel = MasterScript.GetPenetrationLabel(char)
 
 Labelsconcat = "1" +Stimulationlabel + "1" + PenisActionLabel + "1" + OralLabel + "1" + PenetrationLabel + "1" + EndingLabel
 PrintDebug("Stimulationlabel :" + Stimulationlabel + ", PenisActionLabel :" +  PenisActionLabel  + ", OralLabel :" +  OralLabel  + ", PenetrationLabel :" +  PenetrationLabel  + ", EndingLabel :" +  EndingLabel)

endfunction
;-----------------------BASE HENTAIRIM Update Functions END-----------------------------


;-----------------------Hentairim Common Utilities START--------------------------------------

Bool Function Isintense()
	return stringutil.find(Labelsconcat ,"1F") > -1 || stringutil.find(Labelsconcat ,"BST") > -1
endfunction

Bool Function IsGettingStimulated()
	return Stimulationlabel == "SST" ||  Stimulationlabel == "FST"
endfunction

Bool Function IsSuckingoffOther()
	return OralLabel == "SBJ" ||  OralLabel == "FBJ"
endfunction

Bool Function IsGettingDoublePenetrated()

return PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsgettingPenetrated()
	return IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated()
endfunction

Bool Function IsGettingVaginallyPenetrated()
	return  PenetrationLabel == "SVP" || PenetrationLabel == "FVP" || PenetrationLabel == "SCG" || PenetrationLabel == "FCG" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsGettingAnallyPenetrated() 
	return PenetrationLabel == "SAP" || PenetrationLabel == "FAP"  || PenetrationLabel == "SAC" || PenetrationLabel == "FAC" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsKissing()
	return OralLabel == "KIS" 
endfunction

Bool Function IsCunnilingus()
	return OralLabel == "CUN"
endfunction

Bool Function IsGivingAnalPenetration()
	return PenisActionLabel == "FDA" || PenisActionLabel == "SDA"
endfunction

Bool Function IsGivingVaginalPenetration()
	return PenisActionLabel =="FDV" || PenisActionLabel == "SDV"
endfunction

Bool Function IsLeadIN()
	return Stimulationlabel == "LDI" && PenisActionlabel == "LDI" && Penetrationlabel == "LDI" && OralLabel == "LDI" && EndingLabel == "LDI" 
endfunction 

Bool Function IsGettingSuckedoff()
	return PenisActionLabel == "SMF" ||  PenisActionLabel == "FMF"	 
endfunction

Bool Function IsCowgirl()
	return PenetrationLabel == "SCG" ||  PenetrationLabel == "FCG" ||  PenetrationLabel == "SAC" ||  PenetrationLabel == "FAC"			
endfunction

Bool Function IsEnding()
	return EndingLabel == "ENI" || EndingLabel == "ENO"
endfunction


Bool function IshugePP()
	;no Huge PP effects if not receiving in position 0
	if position != 0
		return false
	endif
	;SOS
	faction SchlongFaction = Game.GetFormFromFile(0xAFF8 , "Schlongs of Skyrim.esp") as Faction
	;TNG
	keyword TNG_XL
	keyword TNG_L
	keyword TNG_Gentlewoman
	 String ControlConfigFile  = "HentairimDirector/Config.json"
	 int HugePPSchlongSize = JsonUtil.GetIntValue(ControlConfigFile, "soshugeppsize" ,6)
    if !TNG_Gentlewoman && isDependencyReady("TheNewGentleman.esp")
      TNG_XL = Game.GetFormFromFile(0xFE5, "TheNewGentleman.esp") as Keyword
      TNG_L = Game.GetFormFromFile(0xFE4, "TheNewGentleman.esp") as Keyword
      TNG_Gentlewoman = Game.GetFormFromFile(0xFF8, "TheNewGentleman.esp") as Keyword
    endif

  String MaleRaceName = actorList[1].GetRace().getName()
  if stringutil.find(MaleRaceName, "Brute") > -1 || stringutil.find(MaleRaceName, "Spider") > -1 || stringutil.find(MaleRaceName, "Lurker") > -1 || stringutil.find(MaleRaceName, "Daedroth") > -1 || stringutil.find(MaleRaceName, "Horse") > -1 || stringutil.find(MaleRaceName, "Bear") > -1 || stringutil.find(MaleRaceName, "Chaurus") > -1 || stringutil.find(MaleRaceName, "Dragon") > -1 || MaleRaceName == "Frost Atronach" || stringutil.find(MaleRaceName, "Giant") > -1 || MaleRaceName == "Mammoth" || MaleRaceName == "Sabre Cat" || stringutil.find(MaleRaceName, "Troll") > -1 || MaleRaceName == "Werewolf" || stringutil.find(MaleRaceName, "Gargoyle") > -1 || MaleRaceName == "Dwarven Centurion" || stringutil.find(MaleRaceName, "Ogre") > -1 || MaleRaceName == "Ogrim" || MaleRaceName == "Nest Ant Flier" || stringutil.find(MaleRaceName, "OGrim") > -1
    return True
  else
    ;if Schlong is big
    if (SchlongFaction)
      return actorList[1].GetFactionRank(SchlongFaction) >= HugePPSchlongSize
    elseif (TNG_XL)
      ;keywords can explicitly overwrite value
      int TNG_Size = TNG_PapyrusUtil.GetActorSize(actorList[1])
      bool tngxl = actorList[1].HasKeyword(TNG_XL)
      bool tngl = actorList[1].HasKeyword(TNG_L)
      bool isBig = tngxl || TNG_Size >= HugePPSchlongSize || tngl

      return isBig
    endif
    return false
  endif
EndFunction


int Function GetLegacyStageNum(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		int stage_num = all_stages.find(asStage)+1
		return stage_num
	endif
	return 0
EndFunction

int Function GetLegacyStagesCount(String asScene)
	int stages_count = SexlabRegistry.GetAllStages(asScene).Length
	return stages_count
EndFunction

float Function GetAnimationSpeed()
return AnimSpeedHelper.GetAnimationSpeed(game.getplayer() , true)

endFunction

Function PlaySound(Sound theSound, Actor actorMakingSound, Bool waitForCompletion = True)

	If waitForCompletion
		theSound.PlayAndWait(actorMakingSound)
	Else
		theSound.Play(actorMakingSound)
	EndIf
EndFunction

Bool Function IsVictim(actor char)
  return CurrentThread.GetSubmissive(char)
endFunction

Bool Function IsBroken()
	return actorref.GetFactionRank(HentairimBroken) > 0
endfunction

bool function has_spell(actor a, int id, string filename)
	spell sp = get_form(id, filename) as spell
	if !sp
		return false
	endif
	return a.HasSpell(sp)
endfunction

form function get_form(int id, string filename)
	if Game.GetModbyName(filename) == 255 
		return None
	endif
	return Game.GetFormFromFile(id, filename)
endfunction


Function PrintDebug(string Contents = "")
if enableprintdebug == 1
	miscutil.printconsole(actorref.getdisplayname() + " HentaiRim Resistance " + Contents)
endif
endfunction 


Bool function isDependencyReady(String modname)
  int index = Game.GetModByName(modname)
  if index == 255 || index == -1
    return false
  else
    return true
  endif
endfunction
;-----------------------Hentairim Common Utilities END--------------------------------------

Function Announce(String Content)

	GetAnnouncement().Show(Content,"icon.dds", aiDelay = 2.0)

endfunction