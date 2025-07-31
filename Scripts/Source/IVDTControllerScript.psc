Scriptname IVDTControllerScript extends ReferenceAlias  

import b612

SexLabFramework Property SexLab Auto
IVDTMCMConfigurationScript Property ConfigOptions Auto
IVDTSoundsScript Property Sounds Auto
Spell Property SceneTrackerSpell Auto
SoundCategory Property SexLabVoices Auto
SoundCategory Property IVDTVoices Auto
SoundCategory Property IVDTMCMAudio Auto
Race Property WerewolfRace Auto
Race Property VampireLordRace Auto
actor playerref 
Bool PlayerInScene = false
Int ivdtScenesCurrentlyRunning = 0
Int maleOnlyScenesCurrentlyRunning = 0
int enablehentairimstagecontrol
string blockorgasmstring
bool DirectorCanAdvanceStage = true
string currentSceneID
string currentStageID
Actor[] actorList
bool PCisAggressor
Bool AllFemale
bool PCisReceiving
bool PCisVictim
int PCposition
;string PCPositionHentairimTags
;labels and interaction times
String Stimulationlabel
String PenisActionLabel
string OralLabel
string EndingLabel
string PenetrationLabel
float TotalSecondsFucked
Float LastLabelUpdateTime
Bool GotFucked
;Timers
float TimertoAdvance
float LastManualAdvancetime
Bool UpdateNow = false
int ldi
int sst
int fst
int bst
int kis
int cun
int sbj
int fbj
int sap
int svp
int fap
int fvp
int sdp
int fdp
int scg
int sac
int fcg
int fac
int sdv
int sda
int fdv
int fda
int shj
int fhj
int stf
int ftf
int smf
int fmf
int sfj
int ffj
int eno
int eni
float updaterate = 0.5
;Modules Spells
Spell SFXSPELL
Spell ExpressionsSpell
Spell ResistanceSpell
;others
Faction schlongfaction
keyword TNG_Gentlewoman
faction HentairimBroken
faction HentairimResistanceFaction
Faction HentairimDoNotDisturbFaction
SexLabThread CurrentThread
float TimerMultiplier = 1.0

;Called first time ever the mod is loaded
Event OnInit()
	AddDoNotDisturbandCombatRape()
	PerformInitialization()
EndEvent

;Called on subsequent reloads of the save
Event OnPlayerLoadGame()
	PerformInitialization()
	UnmuteSexLabVoices()
	UpdateMasterVolume()
	Utility.GetCurrentGameTime()
EndEvent

Function PerformInitialization()
	; Register globally whenever the script is first initialized
	RegisterForTheEventsWeNeed()

;Modules
SFXSPELL = Game.GetFormFromFile(0x800, "HentairimSFX.esp") as Spell
ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell	
ResistanceSpell = Game.GetFormFromFile(0x800, "HentairimResistance.esp") as Spell	

;Others
if Game.GetModbyName("Schlongs of Skyrim.esp") != 255
	schlongfaction = Game.GetFormFromFile(0xAFF8 , "Schlongs of Skyrim.esp") as Faction
EndIf
if Game.GetModbyName("TheNewGentleman.esp") != 255
	TNG_Gentlewoman = Game.GetFormFromFile(0xFF8, "TheNewGentleman.esp") as Keyword
endif
if Game.GetModbyName("HentairimResistance.esp") != 255
	HentairimBroken = Game.GetFormFromFile(0x802, "HentairimResistance.esp") as Faction
endif

if !SFXSPELL
	WritetoErrorlogs("Director", "SFX Spell is Missing! Make Sure the Mod is properly installed and Plugin Enabled")
endif

if !ExpressionsSpell
	WritetoErrorlogs("Director", "Expressions Spell is Missing! Make Sure the Mod is properly installed and Plugin Enabled")
endif

if !ResistanceSpell
	WritetoErrorlogs("Director", "Resistance Spell is Missing! Make Sure the Mod is properly installed and Plugin Enabled")
endif

;workarounds male actors to show male animations for female only


EndFunction

Function RegisterForTheEventsWeNeed()
	RegisterForModEvent("AnimationStart", "DirectorSceneStart")
	;RegisterForModEvent("AnimationEnd", "DirectorSceneEnd")
EndFunction

;Director reacts when a sexlab scene start
Event DirectorSceneStart(string eventName, string argString, float argNum, form sender)
	;Hentairim is for handling player scenes only. 
	playerref = game.getplayer() ;player
	printdebug("Sexlab Scene Detected")
	if PlayerInScene || !Sexlab.GetThreadByActor(PlayerRef)
		printdebug("Sexlab Scene Does not Involve Player.Ignored")
		Return
	endIf
	CustomScenePositionTags = ""
	CustomStageNum = 0
	CustomSceneTags = new string[1]
	CustomSceneTags = papyrusutil.RemoveString(CustomSceneTags , CustomSceneTags[0])
	RunCustomScene = false
	TimertoAdvance = 0 
	UpdateNow = false
	ResetTimerMultipler()
	
	StorageUtil.SetIntValue(None, "DirectorAdvanceStage", 0) ;default no directory signal to have processes be ready
	
	;Initialize Configs
	InitializeDIrectorConfigs()
	CurrentThread = Sexlab.GetThreadByActor(PlayerRef) ;CURRENT THREAD
	CurrentSceneID = CurrentThread.GetActiveScene()
	CurrentStageID = CurrentThread.GetActiveStage()
	actorList = CurrentThread.GetPositions()
	PlayerInScene = true
	updatelabels(CurrentSceneID , GetLegacyStageNum(CurrentSceneID, CurrentStageID) , 0) ;update labels
	;initialize variables
	IVDTCanAdvance = true ;default IVDT ready to advance
	SFXCanAdvance = true ;default sfx ready to advance
	GetActorInteractiontypes(playerref)
	GetActorpartnerInteractiontypes(playerref)
	PCisAggressor = PCisAggressor()
	AllFemale = AllFemale()
	PCisReceiving = playerref == actorList[0]
	PCisVictim = PCisVictim()
	PCPosition =  CurrentThread.GetPositionIdx(Playerref)
	
	RunCustomScene = CheckifShouldRunCustomScene()
	
	AddtoTimer(GetTimer()) ;calculate starting timer to advance
	AddTrackerToSceneIfApplicable(argString)
	printdebug("Run Custom Scene : " + RunCustomScene)
	printdebug("CurrentThread :" + CurrentThread)
	printdebug("CurrentSceneID :" + CurrentSceneID)
	printdebug("CurrentStageID :" + CurrentStageID)
	printdebug("actorList :" + actorList)
	printdebug("Scene start")
	
	RegisterForSingleUpdate(0.1)
EndEvent


Function DirectorEndScene()
	if enablearmorswap == 1
		RestoreArmor(playerref)
	endif
	
	if enablehentairimscaling == 1
		ResetScaling()
	endif
	if resetsexassignment == 1
		RevertAllActorsSex()
	endif
	ResetAnimationSpeed()
	StorageUtil.SetStringValue(None, "DirectorCustomScene", "")
	;RemoveStrapon()
	CurrentThread = none
	CurrentSceneID = none
	CurrentStageID = none
	PlayerInScene = false
	PositionsToAlign = new int[1]
	PositionsToAlign = papyrusutil.RemoveInt(PositionsToAlign , PositionsToAlign[0])
	updaterate = 0.5
	printdebug("Hentairim Director Scene END")
	
endfunction 

;Event DirectorSceneEnd(string eventName, string argString, float argNum, form sender)
;	miscutil.printconsole("DirectorSceneEnd START eventName : " + eventName + " argString : " + argString + " argNum : " + argNum)
;	printdebug("eventName :" + eventName + " argString : " + argString + " argNum : " + argNum)
;EndEvent

Event OnUpdate()
	printdebug("Updating")
	;check whether to advance Stage
	printdebug("TimertoAdvance : " + TimertoAdvance)
	printdebug("Thread Total Time : " + CurrentThread.GetTimeTotal())
	if Input.IsKeyPressed(directortoolskey)
			OpenDirectorsTools()
	elseif Input.IsKeyPressed(adjustsidewayskey)
		if Input.IsKeyPressed(modifierkey)
			AdjustAlignment(0 , true)
		else
			AdjustAlignment(0 , false)
		endIf
	elseif Input.IsKeyPressed(adjustupdownkey)
		if Input.IsKeyPressed(modifierkey)
			AdjustAlignment(2 , true)
		else
			AdjustAlignment(2 , false)
		endIf
	elseif Input.IsKeyPressed(adjustforwardkey)
		if Input.IsKeyPressed(modifierkey)
			AdjustAlignment(1 , true)
		else
			AdjustAlignment(1 , false)
		endIf
	elseif Input.IsKeyPressed(adjustrotationkey)
		if Input.IsKeyPressed(modifierkey)
			AdjustAlignment(3 , true)
		else
			AdjustAlignment(3 , false)
		endIf
	elseif Input.IsKeyPressed(advancekey)
		if CurrentThread.GetTimeTotal() > LastManualAdvancetime + 3
			if RunCustomScene
				MovetoNextCustomStage()
			else
				CurrentThread.skipto(GetNextStageID(CurrentSceneID, CurrentStageID))
			endIf
			LastManualAdvancetime = CurrentThread.GetTimeTotal()
		endif
	endif

	if DirectorCanAdvanceStage && enableautoadvancestage == 1 && IVDTCanAdvance && SFXCanAdvance && TimertoAdvance < CurrentThread.GetTimeTotal()
		;timer has passed and everyone is ready! TIME TO ADVANCE!
		StorageUtil.SetIntValue(None, "DirectorAdvanceStage", 0)
		if RunCustomScene
			MovetoNextCustomStage()
		elseif ((npcchangescenewhenpcisvictim == 1 && PCisVictim) || npcchangescenewhenpcisvictim == 0) && PCisVictim && IsgettingPenetrated() && chancefornpctochangepenetrationscene >= Utility.randomint(1,100)
			TeleportToRandomStageWithSimilarPositions() 	
		else	
			CurrentThread.skipto(GetNextStageID(CurrentSceneID, CurrentStageID))
		endif
		AddtoTimer(GetTimer()) ;calculate starting timer to advance
		LoadStageSpeed()
		UpdateNow = true
	elseif DirectorCanAdvanceStage && enableautoadvancestage == 1 && TimertoAdvance < CurrentThread.GetTimeTotal()
		;timer has passed but other processes are not ready. send global signal to tell processes to be maintain readiness for advance
		if StorageUtil.GetIntValue(None, "DirectorAdvanceStage") == 0
			StorageUtil.SetIntValue(None, "DirectorAdvanceStage", 1)
		endif
	endif
	
	;update variables if not the same scene or stage id as before
	if UpdateNow || currentSceneID != CurrentThread.GetActiveScene() || CurrentStageID != CurrentThread.GetActiveStage()
		printdebug("Update Labels As Scene or Stage is different")
		
		currentSceneID = CurrentThread.GetActiveScene()
		CurrentStageID = CurrentThread.GetActiveStage()
		updatelabels(CurrentSceneID , GetLegacyStageNum(CurrentSceneID, CurrentStageID) , 0) ;update labels for position 0 only
		UpdateNow = false ;director done updating
		LastLabelUpdateTime = CurrentThread.GetTimeTotal()
		if resetsmp == 1
			consoleutil.executecommand("SMP Reset")
		endif
	endif


	if Sexlab.GetThreadByActor(playerref) ;continue to update if Player is in Scene
		RegisterForSingleUpdate(updaterate)
	else
		DirectorEndScene()
	endif
	
endEvent

bool function isUpdating()
	return updatenow
endfunction


Function AddTrackerToSceneIfApplicable(string argString)
	
	;Hentairim Director running

	;------------Start Applying Effects to Actors in Thread------------------------		
	RunThreadControl(actorList)
	
	;---------------Applying IVDT Spell to Player-------------------
	if playerref.HasSpell(SceneTrackerSpell) ;Scene with female voice actor
		playerref.RemoveSpell(SceneTrackerSpell)
	endif	
	if EnableIVDT == 1
		printdebug("playerref added Hentairim ivdt Spell")
		playerref.AddSpell(SceneTrackerSpell, abVerbose = False) ;Scene with female voice actor
	endif
	;-------------Applying SFX Spell to non position 1 actors----------------
	
	
	if enablesfx == 1
		int z = 1 ;skip position 0
		while z <= actorList.length
			if actorList[z].HasSpell(SFXSPELL) 
				actorList[z].RemoveSpell(SFXSPELL)
			endif
			
			printdebug(actorList[z].getdisplayname() + " added SFX Spell")
			actorList[z].AddSpell(SFXSPELL, abVerbose = False)
		z += 1
		EndWhile
	endif
	
	;---------------Applying Expressions Spell to Actors------------------
	if EnableExpressions == 1
			
		int z = 0
		while z <= actorList.length
			if sexlab.GetGender(actorList[z]) <= 1 ;not creature
				if actorList[z].HasSpell(ExpressionsSpell) 
					actorList[z].RemoveSpell(ExpressionsSpell)
				endif
				if actorList[z] == playerref && enablepcexpression == 1
					printdebug(actorList[z].getdisplayname() + " added Expression Spell")
					actorList[z].AddSpell(ExpressionsSpell, abVerbose = False)
				elseif sexlab.GetGender(actorList[z]) == 0 && enablemalenpcexpression == 1
					printdebug(actorList[z].getdisplayname() + " added Expression Spell")
					actorList[z].AddSpell(ExpressionsSpell, abVerbose = False)
				elseif sexlab.GetGender(actorList[z]) == 1 && enablefemalenpcexpression == 1
					printdebug(actorList[z].getdisplayname() + " added Expression Spell")
					actorList[z].AddSpell(ExpressionsSpell, abVerbose = False)
				endif
			endif
		z += 1
		EndWhile
	EndIf
	
	;---------------Applying Resistance Spell to Actors------------------

	enablepcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablepcresistancedamage" ,0)
	enablemalenpcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablemalenpcresistancedamage" ,0)
	enablefemalenpcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablefemalenpcresistancedamage" ,0)
	enablecreaturenpcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablefemalenpcresistancedamage" ,0)
	if enableResistance == 1

		int z = 0
		while z <= actorList.length
			if sexlab.GetGender(actorList[z]) <= 1 ;not creature
				if actorList[z].HasSpell(ResistanceSpell) 
					actorList[z].RemoveSpell(ResistanceSpell)
				endif
				if actorList[z] == playerref && enablepcresistancedamage == 1
					printdebug(actorList[z].getdisplayname() + " added Resistance Spell")
					actorList[z].AddSpell(ResistanceSpell, abVerbose = False)
				elseif sexlab.GetGender(actorList[z]) == 0 && enablemalenpcresistancedamage == 1
					printdebug(actorList[z].getdisplayname() + " added Resistance Spell")
					actorList[z].AddSpell(ResistanceSpell, abVerbose = False)
				elseif sexlab.GetGender(actorList[z]) == 1 && enablefemalenpcresistancedamage == 1
					printdebug(actorList[z].getdisplayname() + " added Resistance Spell")
					actorList[z].AddSpell(ResistanceSpell, abVerbose = False)
				elseif sexlab.GetGender(actorList[z]) > 1 && enablecreaturenpcresistancedamage == 1
					printdebug(actorList[z].getdisplayname() + " added Resistance Spell")
					actorList[z].AddSpell(ResistanceSpell, abVerbose = False)
				endif
			endif
		z += 1
		EndWhile
		
	endif
EndFunction

Function RegisterThatSceneIsStarting(Bool maleOnlyScene)
	;ivdtScenesCurrentlyRunning += 1
	
	;If maleOnlyScene
	;	maleOnlyScenesCurrentlyRunning += 1
	;EndIf
	
	;If ivdtScenesCurrentlyRunning > 0 && ConfigOptions.GetModSettingBool("bMuteSexLabVoices:VoiceSystemManagement")
	;	SexLabVoices.Mute()
	;EndIf
EndFunction

Function RegisterThatSceneIsEnding(Bool maleOnlyScene)
	;ivdtScenesCurrentlyRunning -= 1
	
	;If maleOnlyScene
	;	maleOnlyScenesCurrentlyRunning -= 1
	;EndIf
	
	;If ivdtScenesCurrentlyRunning <= 0
	;	SexLabVoices.UnMute()
	;EndIf
EndFunction

Function PlaySound(Sound theSound, Actor actorMakingSound, Bool waitForCompletion = True)

	If waitForCompletion
		theSound.PlayAndWait(actorMakingSound)
	Else
		theSound.Play(actorMakingSound)
	EndIf
EndFunction

bool function IsMale(actor char)
	return sexlab.GetGender((char)) == 0
endfunction

String Function GetNameOfVoiceType(Actor actorWithVoice)
	Race actorRace = actorWithVoice.GetRace()
	
	If actorRace == WerewolfRace ;Transformable creatures must have their voice type hardcoded, otherwise they would use their non-creature voice type
		If IsMale(actorWithVoice)
			Return "MaleWerewolf"
		Else
			Return "FemaleWerewolf"
		EndIf
	
	ElseIf actorRace == VampireLordRace
		If IsMale(actorWithVoice)
			Return "MaleVampireLord"
		Else
			Return "FemaleVampireLord"
		EndIf		
	Else 
		VoiceType voiceTypeToGetNameOf = actorWithVoice.GetLeveledActorBase().GetVoiceType()
		String voiceTypeAsString = voiceTypeToGetNameOf as String 
		Int startingIndex = StringUtil.Find(voiceTypeAsString, "<") + 1
		Int endingIndex = StringUtil.Find(voiceTypeAsString, " (")

		Return StringUtil.Substring(voiceTypeAsString, startingIndex, endingIndex - startingIndex) 
	EndIf
EndFunction



IVDTVoiceFemaleScript Function GetVoiceForActress(Actor actressToVoice)
	
	return GetOwningQuest().GetAliasByName("Slot" + 1) as IVDTVoiceFemaleScript
EndFunction

IVDTVoiceMaleScript Function GetVoiceForActor(Actor actorToVoice)
	IVDTVoiceMaleScript hisVoiceSlot = None
	string actorName = actorToVoice.GetLeveledActorBase().GetName()
	string actorVoiceType = GetNameOfVoiceType(actorToVoice)
	
	;Run through all voice slots and check if any have a matching actor or voice type
	Int currentSlot = 1
	Int maleVoiceSlots = ConfigOptions.MaleVoiceSlots
	String temp = ""
	int EnableReassigningMaleVoice

	EnableReassigningMaleVoice = JsonUtil.GetIntValue("IVDTHentai/Config.json","enablereassigningmalevoice",0) 
	
	;	printdebug ("Male actorVoiceType  : "+ actorVoiceType )
;Slot M1 = MaleEvenTone
;Slot M2 = MaleArgonian
;Slot M3 = MaleBrute
;Slot M4 = MaleNord
;Slot M5 = MaleCondescending
;Slot M6 = MaleDarkElf
;Slot M7 = MaleKhajitt
;Slot M8 = MaleOrc
	;reassign unused slots

;HENTAIRIM hard assign voice	

if EnableReassigningMaleVoice == 1	
	if  actorVoiceType ==  "malecommander" || actorVoiceType ==  "malesoldier" 
		actorVoiceType = "malebrute"
	elseif actorVoiceType ==  "malecommoner" || actorVoiceType ==  "malecommoneraccented" || actorVoiceType ==  "maleeventonedaccented"|| actorVoiceType ==  "maleyoungeager"
		 actorVoiceType = "maleeventoned"
	elseif actorVoiceType ==  "maleelfhaughty"
		 actorVoiceType = "malecondescending"
	elseif actorVoiceType ==  "maleguard" || actorVoiceType ==  "malenordcommander"
		 actorVoiceType = "malenord"
;	elseif actorVoiceType ==  "maleslycynical"
;		 actorVoiceType = "maledarkelf"
	endif
endif	


if actorVoiceType == "MaleEvenToned"
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 1) as IVDTVoiceMaleScript
elseif actorVoiceType == "MaleArgonian"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 2) as IVDTVoiceMaleScript
elseif actorVoiceType == "MaleBrute"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 3) as IVDTVoiceMaleScript	
elseif actorVoiceType == "MaleNord"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 4) as IVDTVoiceMaleScript
elseif actorVoiceType == "MaleCondescending"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 5) as IVDTVoiceMaleScript
elseif actorVoiceType == "MaleDarkElf"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 6) as IVDTVoiceMaleScript
elseif actorVoiceType == "MaleKhajitt"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 7) as IVDTVoiceMaleScript
elseif actorVoiceType == "MaleOrc"	
	hisVoiceSlot = GetOwningQuest().GetAliasByName("Slot" + 8) as IVDTVoiceMaleScript
else
	hisVoiceSlot = none
endif

	
	Return hisVoiceSlot
EndFunction


IVDTVoiceMaleScript Function GetDefaultMaleVoice(Actor actorToVoice)

	Return GetOwningQuest().GetAliasByName("Slot" + 1) as IVDTVoiceMaleScript
EndFunction



IVDTVoiceFemaleScript Function GetFemaleVoiceAtSlot(Int slot)
	Return GetOwningQuest().GetAliasByName("Slot" + slot) as IVDTVoiceFemaleScript
EndFunction

IVDTVoiceMaleScript Function GetMaleVoiceAtSlot(Int slot)
	Return GetOwningQuest().GetAliasByName("Slot" + slot) as IVDTVoiceMaleScript
EndFunction


;SFX Config.json
String SFXConfigFile  = "HentairimSFX/Config.json"
int EnableSFX

;Expressions Config.json
String ExpressionConfigFile  = "HentairimExpressions/Config.json"
int enableExpressions
int enablepcexpression
int enablefemalenpcexpression
int enablemalenpcexpression

;IVDT Config.json
String IVDTConfigFile  = "IVDTHentai/Config.json"
int enableIVDT


;Director Config.json
String ControlConfigFile  = "HentairimDirector/Config.json"
string StageMakerFile = "HentairimDirector/StageMaker.json"
string StageMakerJSONFolder = "HentairimDirector/StageMakerJSON/"

int directortoolskey
int modifierkey
int adjustforwardkey
int adjustsidewayskey
int adjustupdownkey
int adjustrotationkey
int advancekey
int enablehentairimscaling
int enablearmorswap
int enableautoadvancestage
int chancefornpctochangepenetrationscene
int npcchangescenewhenpcisvictim
int ResetSMP
int resetsexassignment
int enableprintdebug

int enablestagemaker
int chancetousecustomstage
int skipfirststageasap

;Hentairim combatrape.json
String CombatRapeConfigFile  = "HentairimDirector/CombatRape.json"

;ArmorSwapping config.json
string ArmorSwappingFile =  "HentairimDirector/ArmorSwapping.json"

;Stage Timers
string TimerConfigFile =  "HentairimDirector/Timers.json"

;Resistance
string ResistanceConfigFile  =  "HentairimResistance/Config.json"
int enableResistance
int enablepcresistancedamage
int enablemalenpcresistancedamage
int enablefemalenpcresistancedamage
int enablecreaturenpcresistancedamage

Function InitializeDirectorConfigs()

	;Start BY Validation files and post msg box if there are issues
	
	ValidateJsonFile("Hentairim Director config", ControlConfigFile)
	ValidateJsonFile("Hentairim Combat Rape", CombatRapeConfigFile)
	ValidateJsonFIle("Hentairim SFX config" , SFXConfigFile)
	ValidateJsonFIle("Hentairim Expressions config" , ExpressionConfigFile)
	ValidateJsonFIle("Hentairim Armor Swapping config" , ArmorSwappingFile)
	ValidateJsonFIle("Hentairim Timers config" , TimerConfigFile)
	ValidateJsonFIle("Hentairim IVDT config" , IVDTConfigFile)
	ValidateJsonFIle("Hentairim Stage Maker" , StageMakerFile)
	ValidateJsonFIle("Hentairim Resistance config" , ResistanceConfigFile)
	ValidateJsonFIle("Hentairim Resistance RaceBaseResistance" , "HentairimResistance/RaceBaseResistance.json")
	ValidateJsonFIle("Hentairim Resistance RaceFuckingPCEnjoymentModifier" , "HentairimResistance/RaceFuckingPCResistanceModifier.json")
	
	;load SFX config
	EnableSFX = JsonUtil.GetIntValue(SFXConfigFile, "enablesfx" ,0)
	
	;load Expressions config
	enableExpressions = JsonUtil.GetIntValue(ExpressionConfigFile, "enableexpressions" ,0)
	enablepcexpression = JsonUtil.GetIntValue(ExpressionConfigFile, "enablepc" ,0)
	enablefemalenpcexpression = JsonUtil.GetIntValue(ExpressionConfigFile, "enablefemalenpc" ,0)
	enablemalenpcexpression = JsonUtil.GetIntValue(ExpressionConfigFile, "enablemalenpc" ,0)
	
	;load resistance config
	enableResistance = JsonUtil.GetIntValue(ResistanceConfigFile, "enableaggressionresistance" ,0)
	enablepcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablepcresistancedamage" ,0)
	enablemalenpcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablemalenpcresistancedamage" ,0)
	enablefemalenpcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablefemalenpcresistancedamage" ,0)
	enablecreaturenpcresistancedamage = JsonUtil.GetIntValue(ResistanceConfigFile, "enablefemalenpcresistancedamage" ,0)
	
	;Load Timers config
	ldi = JsonUtil.GetIntValue(TimerConfigFile,"ldi",9999)
	sst = JsonUtil.GetIntValue(TimerConfigFile,"sst",9999)
	fst = JsonUtil.GetIntValue(TimerConfigFile,"fst",9999)
	bst = JsonUtil.GetIntValue(TimerConfigFile,"bst",9999)
	kis = JsonUtil.GetIntValue(TimerConfigFile,"kis",9999)
	cun = JsonUtil.GetIntValue(TimerConfigFile,"cun",9999)
	sbj = JsonUtil.GetIntValue(TimerConfigFile,"sbj",9999)
	fbj = JsonUtil.GetIntValue(TimerConfigFile,"fbj",9999)
	sap = JsonUtil.GetIntValue(TimerConfigFile,"sap",9999)
	svp = JsonUtil.GetIntValue(TimerConfigFile,"svp",9999)
	fap = JsonUtil.GetIntValue(TimerConfigFile,"fap",9999)
	fvp = JsonUtil.GetIntValue(TimerConfigFile,"fvp",9999)
	sdp = JsonUtil.GetIntValue(TimerConfigFile,"sdp",9999)
	fdp = JsonUtil.GetIntValue(TimerConfigFile,"fdp",9999)
	scg = JsonUtil.GetIntValue(TimerConfigFile,"scg",9999)
	sac = JsonUtil.GetIntValue(TimerConfigFile,"sac",9999)
	fcg = JsonUtil.GetIntValue(TimerConfigFile,"fcg",9999)
	fac = JsonUtil.GetIntValue(TimerConfigFile,"fac",9999)
	sdv = JsonUtil.GetIntValue(TimerConfigFile,"sdv",9999)
	sda = JsonUtil.GetIntValue(TimerConfigFile,"sda",9999)
	fdv = JsonUtil.GetIntValue(TimerConfigFile,"fdv",9999)
	fda = JsonUtil.GetIntValue(TimerConfigFile,"fda",9999)
	shj = JsonUtil.GetIntValue(TimerConfigFile,"shj",9999)
	fhj = JsonUtil.GetIntValue(TimerConfigFile,"fhj",9999)
	stf = JsonUtil.GetIntValue(TimerConfigFile,"stf",9999)
	ftf = JsonUtil.GetIntValue(TimerConfigFile,"ftf",9999)
	smf = JsonUtil.GetIntValue(TimerConfigFile,"smf",9999)
	fmf = JsonUtil.GetIntValue(TimerConfigFile,"fmf",9999)
	sfj = JsonUtil.GetIntValue(TimerConfigFile,"sfj",9999)
	ffj = JsonUtil.GetIntValue(TimerConfigFile,"ffj",9999)
	eno = JsonUtil.GetIntValue(TimerConfigFile,"eno",9999)
	eni = JsonUtil.GetIntValue(TimerConfigFile,"eni",9999)
	
	;load IVDT config
	EnableIVDT = JsonUtil.GetIntValue(IVDTConfigFile, "enableivdt" ,0)
	
	;Load Director Configs
	directortoolskey = JsonUtil.GetIntValue(ControlConfigFile, "directortoolskey" ,0)
	modifierkey = JsonUtil.GetIntValue(ControlConfigFile, "modifierkey" ,0)
	adjustforwardkey = JsonUtil.GetIntValue(ControlConfigFile, "adjustforwardkey" ,0)
	adjustsidewayskey = JsonUtil.GetIntValue(ControlConfigFile, "adjustsidewayskey" ,0)
	adjustupdownkey = JsonUtil.GetIntValue(ControlConfigFile, "adjustupdownkey" ,0)
	adjustrotationkey = JsonUtil.GetIntValue(ControlConfigFile, "adjustrotationkey" ,0)
	advancekey = JsonUtil.GetIntValue(ControlConfigFile, "advancekey" ,0)
	enablehentairimscaling = JsonUtil.GetIntValue(ControlConfigFile, "enablehentairimscaling" ,0)
	enablearmorswap = JsonUtil.GetIntValue(ControlConfigFile, "enablearmorswap" ,0)
	enableautoadvancestage = JsonUtil.GetIntValue(ControlConfigFile, "enableautoadvancestage" ,0)
	resetsmp = JsonUtil.GetIntValue(ControlConfigFile, "resetsmp" ,0)
	resetsexassignment = JsonUtil.GetIntValue(ControlConfigFile, "resetsexassignment" ,0)
    chancefornpctochangepenetrationscene = JsonUtil.GetIntValue(ControlConfigFile, "chancefornpctochangepenetrationscene" ,0)
	npcchangescenewhenpcisvictim = JsonUtil.GetIntValue(ControlConfigFile, "npcchangescenewhenpcisvictim" ,0)
	enableprintdebug = JsonUtil.GetIntValue(ControlConfigFile, "printdebug" ,0)
	
	;load Stage Maker Configs

	enablestagemaker = JsonUtil.GetIntValue(StageMakerFile, "enablestagemaker" ,0)
	chancetousecustomstage = JsonUtil.GetIntValue(StageMakerFile, "chancetousecustomstage" ,0)
	skipfirststageasap = JsonUtil.GetIntValue(StageMakerFile, "chancetouserandomizedstage" ,0)
	
	
	printdebug("Hentairim : EnableSFX :" + EnableSFX)
	printdebug("Hentairim : enableExpressions :" + enableExpressions)
	printdebug("enablepcexpression :" + enablepcexpression)
	printdebug("enablefemalenpcexpression :" + enablefemalenpcexpression)	
	printdebug("enablemalenpcexpression :" + enablemalenpcexpression)
	printdebug("enablehentairimscaling :" + enablehentairimscaling)
	printdebug("enablearmorswap :" + enablearmorswap)

	printdebug("Hentairim : ldi :" + ldi)
	printdebug("Hentairim : sst :" + sst)
	printdebug("Hentairim : fst :" + fst)
	printdebug("Hentairim : bst :" + bst)
	printdebug("Hentairim : kis :" + kis)
	printdebug("Hentairim : cun :" + cun)
	printdebug("Hentairim : sbj :" + sbj)
	printdebug("Hentairim : fbj :" + fbj)
	printdebug("Hentairim : sap :" + sap)
	printdebug("Hentairim : svp :" + svp)
	printdebug("Hentairim : fap :" + fap)
	printdebug("Hentairim : fvp :" + fvp)
	printdebug("Hentairim : sdp :" + sdp)
	printdebug("Hentairim : fdp :" + fdp)
	printdebug("Hentairim : scg :" + scg)
	printdebug("Hentairim : sac :" + sac)
	printdebug("Hentairim : fcg :" + fcg)
	printdebug("Hentairim : fac :" + fac)
	printdebug("Hentairim : sdv :" + sdv)
	printdebug("Hentairim : sda :" + sda)
	printdebug("Hentairim : fdv :" + fdv)
	printdebug("Hentairim : fda :" + fda)
	printdebug("Hentairim : shj :" + shj)
	printdebug("Hentairim : fhj :" + fhj)
	printdebug("Hentairim : stf :" + stf)
	printdebug("Hentairim : ftf :" + ftf)
	printdebug("Hentairim : smf :" + smf)
	printdebug("Hentairim : fmf :" + fmf)
	printdebug("Hentairim : sfj :" + sfj)
	printdebug("Hentairim : ffj :" + ffj)
	printdebug("Hentairim : eno :" + eno)
	printdebug("Hentairim : eni :" + eni)
	
	printdebug("Hentairim : directortoolskey : " + directortoolskey)
	printdebug("Hentairim : modifierkey : " + modifierkey)
	printdebug("Hentairim : adjustforwardkey : " + adjustforwardkey)
	printdebug("Hentairim : adjustsidewayskey : " + adjustsidewayskey)
	printdebug("Hentairim : adjustupdownkey : " + adjustupdownkey)
	printdebug("Hentairim : adjustrotationkey : " + adjustrotationkey)
	printdebug("Hentairim : enablehentairimscaling : " + enablehentairimscaling)
	printdebug("Hentairim : enablearmorswap : " + enablearmorswap)
	printdebug("Hentairim : enableautoadvancestage : " + enableautoadvancestage)
	printdebug("Hentairim : resetsmp : " + resetsmp)
	printdebug("Hentairim : resetsexassignment : " + resetsexassignment)
	printdebug("Hentairim : chancefornpctochangepenetrationscene : " + chancefornpctochangepenetrationscene)
	printdebug("Hentairim : npcchangescenewhenpcisvictim : " + npcchangescenewhenpcisvictim)
	
	printdebug("Hentairim : Stage maker : " + enablestagemaker)
	printdebug("Hentairim : chancetousecustomstage : " + chancetousecustomstage)
	printdebug("Hentairim : skipfirststageasap : " + skipfirststageasap)

endfunction




;Director's Thread Control when Player's Thread just started.
Function RunThreadControl(actor[] charList)

	if enablearmorswap == 1
		printdebug("Thread Control running body armor swapping")
		BodySwitchtoLewdArmor(playerref)
	endif
	
	if enablehentairimscaling == 1
		printdebug("Thread Control running Scaling")
		HentairimScaling(charList)
	EndIf

EndFunction

;--------------------------------HENTAIRIM SCALING FUNCTIONS START--------------------------------;
Float[] actorlistOriginalScalearr

Function HentairimScaling(actor[] charList)
int z = 0
while z < charlist.Length
	
	actor char = charlist[z]
	
	float display = char.GetScale()
	
	actorlistOriginalScalearr =  papyrusutil.pushfloat(actorlistOriginalScalearr , display)
	
	char.SetScale(1.0)
	float base = char.GetScale()
	float ActorScale = ( display / base )
	float AnimScale  = ActorScale
	
	if ActorScale > 0.0 && ActorScale != 1.0
		char.SetScale(ActorScale)
	endIf
	
	;for shota & big guy scaling
	char.SetScale(GetAnimSpecialScaleValue(z))
	
z += 1
EndWhile

endfunction

Function ResetScaling()
	int z = 0
	while z < actorlistOriginalScalearr.Length
	actorlist[z].SetScale(actorlistOriginalScalearr[z])
	
	z += 1
	EndWhile
	
	actorlistOriginalScalearr = new float[1]
	actorlistOriginalScalearr = papyrusutil.RemoveFloat(actorlistOriginalScalearr,actorlistOriginalScalearr[0])
	printdebug("actorlistOriginalScalearr after resetting : "  + actorlistOriginalScalearr)
EndFunction


float function GetAnimSpecialScaleValue(int position)
SexLabRegistry.GetSceneName(CurrentSceneID)
float ScaleValue = 1.0

if (SexLabRegistry.IsSceneTag(CurrentSceneID, "Bigguy") || SexLabRegistry.IsSceneTag(CurrentSceneID, "Bigguy")) && position != 0
		scalevalue = 1.15
elseif	SexLabRegistry.IsSceneTag(CurrentSceneID, "Shota") && Position > 0 ;there is no shota on 1st position
	int actorcount = CurrentThread.GetPositions().length
	if ActorCount == 2 || (Position == 2 && SexLabRegistry.IsSceneTag(CurrentSceneID, "smff")) || (Position > 0 && SexLabRegistry.IsSceneTag(CurrentSceneID, "smsmf")) || (Position == 3 && SexLabRegistry.IsSceneTag(CurrentSceneID, "smfff")) || (Position == 1 && SexLabRegistry.IsSceneTag(CurrentSceneID, "msmf"))
		scalevalue = 0.8
	endif
endif
	return scalevalue
endfunction



;--------------------------------HENTAIRIM SCALING FUNCTIONS END--------------------------------;
;---------------------------ARMOR SWAPPING FUNCTIONS START------------------------
form[] BaseArmorArr 
form[] LewdArmorArr 
form[] ActorArmorArr  

Function BodySwitchtoLewdArmor(actor char)

string[] ArmorSlotsToSwitch = papyrusutil.stringsplit(JsonUtil.GetStringValue(ArmorSwappingFile,"armorslots","") ,",")

int slotlength = ArmorSlotsToSwitch.length
int slotindex = 0
Armor BaseArmor
Armor LewdArmor

printdebug ("wearing lewd armor...")
	while slotindex < slotlength
		BaseArmor = char.GetWornForm(Armor.GetMaskForSlot(ArmorSlotsToSwitch[slotindex] as int)) as armor
	if BaseArmor != none
		LewdArmor = jsonutil.GetFormValue(ArmorSwappingFile, BaseArmor.getname(), none)	as armor

		if LewdArmor != none
			;printdebug (slotindex + " Trying to add  : "+ LewdArmor.getname())
			char.addItem(LewdArmor , abSilent=true)
			
			;printdebug (slotindex + " Trying to unequip  : "+ BaseArmor.getname())
			char.unEquipItem(BaseArmor , abSilent=true)
			
			;printdebug (slotindex + " Trying to equip  : "+ LewdArmor.getname())
			char.EquipItem(LewdArmor , abSilent=true)

			BaseArmorArr = papyrusutil.pushform(BaseArmorArr , BaseArmor)
			LewdArmorArr = papyrusutil.pushform(LewdArmorArr , LewdArmor)
			ActorArmorArr = papyrusutil.pushform(ActorArmorArr , char)
		endif
	endif

	slotindex += 1
	endwhile
endfunction

Function RestoreArmor(actor char)

int slotlength = BaseArmorArr.length
int slotindex = 0
Armor BaseArmor
Armor LewdArmor

printdebug ("restoring armor....")
while slotindex < slotlength 
	BaseArmor = BaseArmorArr[slotindex] as armor
	LewdArmor = LewdArmorArr[slotindex] as armor
	
	;printdebug (slotindex + " Trying to equip  : "+ BaseArmor.getname())
	char.EquipItem(BaseArmor , abSilent=true)
	
	;printdebug (slotindex + " Trying to remove  : "+ LewdArmor.getname())
	char.RemoveItem(LewdArmor , abSilent=true)
	
	slotindex += 1
endwhile

;clear array for reuse next time
BaseArmorarr = new form[1]
LewdArmorarr = new form[1]
BaseArmorarr = papyrusutil.RemoveForm(BaseArmorarr , BaseArmorarr[0])
LewdArmorarr = papyrusutil.RemoveForm(LewdArmorarr , LewdArmorarr[0])
printdebug("BaseArmor contents after clearing : " + BaseArmor)
EndFunction
;---------------------------ARMOR SWAPPING FUNCTIONS END------------------------

;---------------------------Stage Control FUNCTIONS Start------------------------
Bool IVDTCanAdvance = True
Bool SFXCanAdvance = True

Function IVDTAllowsAdvance(bool allow = true)
	printdebug("IVDT Allows Advance : " + allow)
	IVDTCanAdvance = allow
EndFunction

Function SFXAllowsAdvance(bool allow = true)
	printdebug("SFX Allows Advance : " + allow)
	SFXCanAdvance = allow
EndFunction

bool Function SFXReadytoAdvance()
	return SFXCanAdvance
EndFunction

bool Function IVDTReadytoAdvance()
	return IVDTCanAdvance
EndFunction

bool function PCinShortScene()
	return TimerMultiplier <= 0.7
EndFunction

Function SetTimerMultipler(float multiplier)

	TimerMultiplier = multiplier
endfunction

Function ResetTimerMultipler()
	TimerMultiplier = 1
endfunction

String Function GetPrimaryLabel()
	if EndingLabel != "LDI"
		return EndingLabel
	elseIF OralLabel != "LDI"
		return OralLabel
	elseif Stimulationlabel == "BST"
		return Stimulationlabel
	elseif PenetrationLabel != "LDI"
		return PenetrationLabel
	elseif PenisActionLabel != "LDI"
		return PenisActionLabel
	else
		return Stimulationlabel
	endif
endfunction

int Function GetTimer()
  
 IF GetPrimaryLabel() == "ldi"
return ldi
elseIF GetPrimaryLabel() == "sst"
return sst
elseIF GetPrimaryLabel() == "fst"
return fst
elseIF GetPrimaryLabel() == "bst"
return bst
elseIF GetPrimaryLabel() == "kis"
return kis
elseIF GetPrimaryLabel() == "cun"
return cun
elseIF GetPrimaryLabel() == "sbj"
return sbj
elseIF GetPrimaryLabel() == "fbj"
return fbj
elseIF GetPrimaryLabel() == "sap"
return sap
elseIF GetPrimaryLabel() == "svp"
return svp
elseIF GetPrimaryLabel() == "fap"
return fap
elseIF GetPrimaryLabel() == "fvp"
return fvp
elseIF GetPrimaryLabel() == "sdp"
return sdp
elseIF GetPrimaryLabel() == "fdp"
return fdp
elseIF GetPrimaryLabel() == "scg"
return scg
elseIF GetPrimaryLabel() == "sac"
return sac
elseIF GetPrimaryLabel() == "fcg"
return fcg
elseIF GetPrimaryLabel() == "fac"
return fac
elseIF GetPrimaryLabel() == "sdv"
return sdv
elseIF GetPrimaryLabel() == "sda"
return sda
elseIF GetPrimaryLabel() == "fdv"
return fdv
elseIF GetPrimaryLabel() == "fda"
return fda
elseIF GetPrimaryLabel() == "shj"
return shj
elseIF GetPrimaryLabel() == "fhj"
return fhj
elseIF GetPrimaryLabel() == "stf"
return stf
elseIF GetPrimaryLabel() == "ftf"
return ftf
elseIF GetPrimaryLabel() == "smf"
return smf
elseIF GetPrimaryLabel() == "fmf"
return fmf
elseIF GetPrimaryLabel() == "sfj"
return sfj
elseIF GetPrimaryLabel() == "ffj"
return ffj
elseIF GetPrimaryLabel() == "eno"
return eno
elseIF GetPrimaryLabel() == "eni"
return eni
elseIF GetPrimaryLabel() == "fmf"
return fmf
elseIF GetPrimaryLabel() == "sfj"
return sfj
elseIF GetPrimaryLabel() == "ffj"
return ffj
elseIF GetPrimaryLabel() == "eno"
return eno
elseIF GetPrimaryLabel() == "eni"
return eni
else
printdebug("Label for TImer is not found. Defaulting to 15")
return 15

endif
endfunction

Function AddtoTimer(float value)
	TimertoAdvance += value
	printdebug("Timer Added. New TImer :" + TimertoAdvance)
endfunction


Function AdjustAlignment(int Movement , Bool Modifier = false)
	float offsetmod = 1
	if Modifier
		offsetmod = -1
	endif
	int z = 0
	while z < PositionsToAlign.length
		float[] OffSet = sexlabregistry.GetStageOffset(CurrentSceneID, "", PositionsToAlign[z])
		 OffSet[Movement] = OffSet[Movement] + offsetmod
		sexlabregistry.SetStageOffsetA(currentsceneid ,"", PositionsToAlign[z] , OffSet) 
		z += 1
	EndWhile
	currentthread.skipto(currentstageid)
endfunction

string[] Function FindValidCustomScene()
printdebug("Finding Valid Custom Scenes.")

string actorrace 
string StringKey
string[] ValidCustomScenesarr
;add actor count to string key
StringKey += actorlist.length as string

; identify non PC race
int z 
while z < actorlist.length 
	if actorlist[z] != playerref
		if sexlab.GetGender(actorlist[z]) <= 1
			StringKey += "human"
			z += 100
		else
			StringKey += "creature"
			z += 100
		endif
	endif
	z+= 1
endwhile
;identify string keysd

if isVictim(actorlist[1])
	StringKey += "femdom"
elseif isVictim(actorlist[0])
	StringKey += "aggressive"
else
	StringKey += "consensual"
endif
printdebug("finding line items with Custom Scene String Key : " + StringKey)

;start looping through all the JSON files in StageMakerJSONFolder
string[] StageMakerFileNameList = JsonUtil.JsonInFolder(StageMakerJSONFolder)
printdebug("all stage make file names" + StageMakerFileNameList)

if StageMakerFileNameList.length == 0
	printdebug("No Stage Maker JSON File Found")
	return none
EndIf
;we want to find a custom scenes if its available from various files
int f
while f < StageMakerFileNameList.length
	String Path = StageMakerJSONFolder + StageMakerFileNameList[f]
	printdebug("Searching for Stage Maker Line items in : " + Path)
	
	int CustomSceneCount
	CustomSceneCount = JsonUtil.StringListCount(Path,StringKey)
	printdebug("total line items in " + CustomSceneCount)

	;line items found . start to search for suitable custom scenes.
	if CustomSceneCount > 0
		z = 0
		while z < CustomSceneCount
			
			string Lineitem = JsonUtil.StringListGet(Path,StringKey,z)
			printdebug("Line Item found :" + Lineitem)
			
			;breakdown and validate line item
			string[] LineItemArr = papyrusutil.stringsplit(Lineitem , "|")
			printdebug("LineItemArr : " + LineItemArr)
			
			;first array value is always the position tags to validate against.
			;PositionTagsArr is the lookup criteria
			string[] PositionTagsArr = papyrusutil.stringsplit(LineItemArr[0] , ",")
			printdebug("PositionTagsArr : " + PositionTagsArr)
			
			;start to check if the PositionTagsArr's tags are matching with the current playing animation
			int y = 0
			Bool ValidLineItem = true
			Bool Containstilde = false
			Bool TildeSatisfied = false
			while y < PositionTagsArr.length && ValidLineItem
				string specialchar = StringUtil.Substring(PositionTagsArr[y],0,1)
				printdebug("specialchar : " + specialchar)
				
				if specialchar == "@" ;match animation name
					String SceneNametoCheck = StringUtil.Substring(PositionTagsArr[y],1,0)
					printdebug("Scene Name Look up : " + SceneNametoCheck)
					if SexlabRegistry.GetSceneName(CurrentSceneID) != SceneNametoCheck
						ValidLineItem = false
						y += 100
					endif
				elseif specialchar == "-" ;minus means it should not contain this tag
					string tagtocheck = StringUtil.Substring(PositionTagsArr[y],1,0)
					printdebug("tag to Look up : " + tagtocheck)
					if CurrentThread.HasSceneTag(tagtocheck)
						printdebug("Current Scene Contains excluded" + tagtocheck +" tag. skip this Line Item")
						ValidLineItem = false
						y += 100
					endif
				elseif specialchar == "~" ;minus means it should not contain this tag
					Containstilde = true
					string tagtocheck = StringUtil.Substring(PositionTagsArr[y],1,0)
					printdebug("tagtocheck : " + tagtocheck)
					if CurrentThread.HasSceneTag(tagtocheck)
						printdebug("Current Scene Contains tilde " +tagtocheck + " tag. tilde condition satisfied")
						TildeSatisfied = true
					endif
				else
					string tagtocheck = PositionTagsArr[y]
					printdebug("tagtocheck : " + tagtocheck)
					if !CurrentThread.HasSceneTag(tagtocheck)
						printdebug("Current Scene does not  " +tagtocheck + " tag. Skip this Line Item")
						ValidLineItem = false
						y += 100
					endif
				endif
				y += 1
			endwhile
			;make lineitem valid only after at least one tag fits tilde
			if Containstilde && !TildeSatisfied
				ValidLineItem = false
			endif
			
			;this is a valid line item. add it to the valid item group
			if ValidLineItem
				printdebug("Line Item is Valid and added to the List of valid Custom scenes")
				ValidCustomScenesarr = papyrusutil.pushstring(ValidCustomScenesarr, Lineitem)
			endif
			
			z += 1

		endwhile
	else
	printdebug("no line items found in " + Path +". String Key : "+ StringKey + " Skipping")	
	endif
	f += 1
endwhile
	
	;we are done looking for the list of valid line items from various files. return none if none is found or pick a random line item for the scene if more than 1
	if ValidCustomScenesarr.length <= 0
		printdebug("no valid Line Item Found for Scene")
		Return none
	Else
		string[] Result = papyrusutil.stringsplit(ValidCustomScenesarr[utility.randomint(0,ValidCustomScenesarr.length - 1)] , "|")	
		printdebug("Custom Scene selected : " + Result)
		return Result
	endif
EndFunction

Bool RunCustomScene = false
string CustomScenePositionTags
string[] CustomSceneTags
string StorageUtilCustomScene
int CustomStageNum = 0
Bool Function CheckifShouldRunCustomScene()

if enablestagemaker != 1

	return false
endif
;look for custom scene string from storageutil
String SUCustomSceneString = StorageUtil.GetStringValue(None, "DirectorCustomScene", "")

if Utility.RandomInt(1,100) > chancetousecustomstage && StorageUtilCustomScene == ""
	printdebug("Failed Chance to use Stage Maker's custom Scenes ")
	return false
endif

;has storageutil custom scene string
if StorageUtilCustomScene != ""
	CustomSceneTags = papyrusutil.stringsplit(SUCustomSceneString,"|")
else
	CustomSceneTags = FindValidCustomScene()
endIf

if CustomSceneTags.length <= 0 || CustomSceneTags == none
	printdebug("no Valid Custom Scene Found. Using Default Scene ")
	return false
else	
	printdebug("CustomSceneTags : " + CustomSceneTags)
	
	if skipfirststageasap == 1 && IsgettingPenetrated()
		MovetoNextCustomStage()
	EndIf
	return true
endif
endfunction
Function MovetoNextCustomStage()
	;string CustomScenePositionTags - The position tags that all stages to adhere, unless there are more than one stage tags in the stage number
	;string[] CustomSceneTags - Current Scene tags. or usually hentairim tags
	;CustomStageNum - te current stage number in the custom scene
	if CustomStageNum >= CustomSceneTags.length
		printdebug("Reached the End of Custom Scene. Stopping animation")
		currentthread.Stopanimation()
		return
	endif
	
	string TagsToApply
	int DestinationStage
	String CustomStageTags = CustomSceneTags[CustomStageNum + 1] ;the hentairim tag to go for . +1 tp skip first lookup criteria
	printdebug("CustomStageTags : " + CustomStageTags)

	if StringUtil.find(CustomStageTags , "@") > -1 
		int commaIndex = StringUtil.Find(CustomStageTags, ",")
		string LineItemSceneName = StringUtil.Substring(CustomStageTags, 1, commaIndex - 1)
		int LineItemStagenum = StringUtil.Substring(CustomStageTags, commaIndex + 1) as int
		TeleportToSceneWithName(LineItemSceneName,LineItemStagenum)
		CustomStageNum += 1
		return ;no need to run subsequent code
	elseif StringUtil.find(CustomStageTags , ",") > -1 
		;more tags other than hentairim tag or no hentairim tag . ignore CustomScenePositionTags
		TagsToApply = CustomStageTags
	else
		;if there is only one tag which is hentairim tag
		TagsToApply = CustomSceneTags[0] + "," + CustomStageTags
	endif
	
	;identify destination stage to move to. only look at first character for potential stage number as per rules
	DestinationStage = StringUtil.Substring(CustomStageTags,0,1) as int
	
	;if no destination Stage Identified
	if DestinationStage <= 0
		if IsEnding()
			DestinationStage = 5
		elseif IsgettingPenetrated() || IsCowgirl()
			DestinationStage = Utility.Randomint(3,5)
		else
			DestinationStage = Utility.Randomint(1,2)
		endif
	endif

	printdebug("Custom Stage TagsToApply : " + TagsToApply)
	printdebug("Custom DestinationStage : " + DestinationStage)

	
	bool result = TeleportToRandomStageWithTags(TagsToApply , DestinationStage)
	
	if !result ;no scene found
		WritetoErrorlogs("StageMaker" ,"Custom Scene : " + CustomSceneTags + " | no Stage Found with Tags" + TagsToApply +" and Destination Stage" + DestinationStage + " Verify if the Combination of Actor's Gender & Scene tags availability Exists")
	endIf
	CustomStageNum += 1

EndFunction


Function RevertAllActorsSex()
	int z
	while z < actorlist.length
		sexlab.ClearForcedSex(actorlist[z])
		z += 1
	endwhile

endfunction

Function ResolveStrapon()
	int z
	string PAL 
	while z <= actorList.length
		if !HasSchlongOrStrapOn(actorList[z]) && (sexlab.GetSex(actorList[z]) == 1 ||  sexlab.GetSex(actorList[z]) == 2)
			PAL = HentairimTags.PenisActionLabel(CurrentSceneID , GetLegacyStageNum(CurrentSceneID, CurrentStageID) , z)
			if PAL != "LDI" && !sexlab.WornStrapon(actorList[z])   ; means female actor needs strapon
				armor Strapon = sexlab.pickstrapon(actorList[z]) as armor
				;currentthread.SetStrapon(actorList[z],Strapon)
				debug.notification("adding strapon to" + actorList[z].getdisplayname())
				actorList[z].addItem(strapon , abSilent=true)
				actorList[z].EquipItem(strapon , abSilent=true)
			endIf
		endIf
		z += 1
	endwhile
endFunction

Function RemoveStrapon()
	int z
	while z <= actorList.length
		armor strapon = sexlab.WornStrapon(actorList[z]) as armor
		if !strapon && sexlab.getgender(actorList[z]) == 1
			actorList[z].unEquipItem(strapon , abSilent=true)
			actorList[z].removeItem(strapon , abSilent=true)
		endIf
		z += 1
	endwhile
endFunction

;---------------------------Stage Control FUNCTIONS END------------------------

;---------------------------Director's Utility START------------------------

Bool function ValidateJsonFile(String Title , string Path)
	printdebug("validating " + Path)
	;check if exists
	if !jsonutil.JsonExists(Path)
		Debug.MessageBox(Title + " : "+Path + " File Is Missing")
		WritetoErrorlogs("Director", Title + " : "+Path + " Format Is Missing : ")
		return false
	EndIf
	
	string errors = jsonutil.GetErrors(Path)
	
	if errors != ""
		Debug.MessageBox(Title + " : "+Path + " Format has Errors : ")
		WritetoErrorlogs("Director", Title + " : "+Path + " Format has Errors : ")
		return false
	EndIf
	return true
EndFunction


Bool function HasSchlongOrStrapOn(Actor char)

  if !char
    return false
  endif
  if (schlongfaction)
    return char.isinfaction(schlongfaction)
  elseif (TNG_Gentlewoman)
    if SexLab.GetSex(char) == 1 && !char.HasKeyword(TNG_Gentlewoman)
      return false ; Female
    else
      return true ; Male or Futa
    endif
  elseif CurrentThread.IsUsingStrapon(char)
	return true
  else
    return SexLab.GetSex(char) == 0
  endif
endfunction

Bool Function AllFemale()

	int[] sexarr = sexlab.GetSexAll(actorlist)
	if sexlab.CountFemale(actorlist) == actorlist.length	
		return true
	else
		return false
	endIf
endfunction

function printdebug(string contents = "")
	if enableprintdebug == 1
		miscutil.PrintConsole ("Hentairim Director : "+ contents)
	endif
endfunction

function WritetoErrorlogs(string Header = "Not Specified" ,String contents = "")
	JsonUtil.StringListAdd("ErrorLog.json", Header, " : " + contents, TRUE)
endfunction


Function UpdateMasterVolume()
	Float Volume = 100
	IVDTVoices.SetVolume(Volume)
	IVDTMCMAudio.SetVolume(Volume)
EndFunction

Function UnmuteSexLabVoices()
	SexLabVoices.UnMute()
EndFunction

Function UpdateLabels(string anim , int stage , int actorpos = 0 )

 
 Stimulationlabel = HentairimTags.StimulationLabel(anim , stage , actorpos)
 PenisActionLabel  = HentairimTags.PenisActionLabel(anim , stage , actorpos)
 OralLabel  = HentairimTags.OralLabel(anim , stage , actorpos)
 PenetrationLabel = HentairimTags.PenetrationLabel(anim , stage , actorpos)
 EndingLabel  = HentairimTags.EndingLabel(anim , stage , actorpos)
Labelsconcat = "1" +Stimulationlabel + "1" + PenisActionLabel + "1" + OralLabel + "1" + PenetrationLabel + "1" + EndingLabel
 
endfunction

string function GetNextStageID(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		return all_stages[all_stages.find(asStage)+1]
	endif
endfunction

string function GetPrevStageID(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		return all_stages[all_stages.find(asStage) - 1]
	endif
endfunction

Bool Function IsgettingPenetrated()
	return IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated()
endfunction
string labelsconcat
Bool Function IsLeadIN()
	return stringutil.find(Labelsconcat ,"1F") == -1 && stringutil.find(Labelsconcat ,"1S") == -1 && stringutil.find(Labelsconcat ,"BST") == -1
endfunction 

Bool Function IsCowgirl()
	return PenetrationLabel == "SCG" ||  PenetrationLabel == "FCG" ||  PenetrationLabel == "SAC" ||  PenetrationLabel == "FAC"			
endfunction

Bool Function IsEnding()
	return EndingLabel == "ENI" || EndingLabel == "ENO"
endfunction

Bool Function IsGettingVaginallyPenetrated() 
	return PenetrationLabel == "SVP" || PenetrationLabel == "FVP" || PenetrationLabel == "SCG" || PenetrationLabel == "FCG" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsGettingAnallyPenetrated() 
	return PenetrationLabel == "SAP" || PenetrationLabel == "FAP"  || PenetrationLabel == "SAC" || PenetrationLabel == "FAC" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

int[] Function GetActorInteractiontypes(actor char)
	;SLPP function to find all interaction types from actor Point of view.
	;clear array
	int[] ActorInteractiontypes
	int z = 0
	while z < actorlist.Length
		if actorlist[z] != char
			printdebug("actor list : " + actorlist)
			printdebug("Interaction Types to merge : " + currentthread.GetInteractionTypes(char , actorlist[z]))
			ActorInteractiontypes = papyrusutil.MergeIntArray(ActorInteractiontypes ,currentthread.GetInteractionTypes(char , actorlist[z]) , true)
		endif
	z += 1
	EndWhile
	printdebug( char.getdisplayname() + "Interaction types from Partner : " + ActorInteractiontypes)
	return ActorInteractiontypes
endfunction 

int[] Function GetActorPartnerInteractiontypes(actor char)
	;SLPP function to find all interaction types from actor's partner Point of view.
	;clear array
	int[] PartnerInteractiontypes
	int z = 0
	
	while z < actorlist.Length
		if actorlist[z] != char
			PartnerInteractiontypes = papyrusutil.MergeIntArray(PartnerInteractiontypes , currentthread.GetInteractionTypes(actorlist[z], char ) , true)
		endif
	z += 1
	EndWhile
	printdebug(char.getdisplayname() + " Interaction types to Partner : " + PartnerInteractiontypes)
	return PartnerInteractiontypes
endfunction


Int Function FindInt(Int[] arr, Int target)
    Int i = 0
    While i < arr.Length
        If arr[i] == target
            Return i ; Found, return index
        EndIf
        i += 1
    EndWhile
    Return -1 ; Not found
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

;---------------------------Director's Utility END------------------------

;------------------------------Director's Tools START------------------------
String ActionLogsFile  = "ActionLogs/ActionLogs.json"

Function OpenDirectorsTools()
	if !CurrentThread 
		return none
	endif
	Int result
    b612_SelectList DirectorTools = GetSelectList()
    String[] Directortoolsarr = StringUtil.Split("Change Stage;Change Animation;Resolve Hentairim Scaling;Add Hentairim Tags;Show Scene Tags; Actor Alignments;Find Animation by Name Or Tags;Toggle Stage Advance;Save Stage Speed;End Scene",";")
	
	result = DirectorTools.Show(Directortoolsarr)
	
	if result == 0 ;Change Stage
		if RunCustomScene 
			ShowCustomStageList()
		else
			ShowStageList()
		endif
    elseif result == 1 ;Change Animation
		ShowChangePosition()
	elseif result == 2 ; Resolve Scaling
		int z = 0
		ResetScaling()
		while z < actorList.length
			actorList[z].SetScale(GetAnimSpecialScaleValue(z))
			z += 1
		endwhile
	elseif result == 3 ; Add Hentairim Tags or SFX
		UITextEntryMenu InputBox = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
		Inputbox.OpenMenu()
		string InputString = Inputbox.GetResultString()
		string[] tags = StringUtil.Split(InputString ,",")

		int z = 0
		while z < tags.length
			String Actionline = "AddTag," + SexlabRegistry.GetSceneName(CurrentSceneID) + "," + InputString		
			LogActionToFile(Actionline)
			z += 1
		endwhile
		announce(InputString + "Tags Saved to HentairimDirector/ActionLogs.json")
		
		;/b612_SelectList TagsTypeList = GetSelectList()
		String[] TagsTypearr = StringUtil.Split("Add Hentairim Tag;Update SFX Tag",";")
	
		int selected = TagsTypeList.Show(TagsTypearr)
		if selected == 0
			sexlabregistry.AddSceneAnnotation(currentsceneid,"test tag")
		elseif selected == 1
			ShowUpdateSFXTags()
		EndIf
		/;
	elseif result == 4 ;Show Scene Tags
        debug.Messagebox( SexLabRegistry.GetSceneName(CurrentSceneID) + " : " + SexLabRegistry.GetSceneTags(CurrentSceneID))
	elseif result == 5 ;Actor Alignments
        ShowAlignmentActorList()
	elseif result == 6 ;Find Animation by Name or Tags
		UITextEntryMenu InputBox = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
		Inputbox.OpenMenu()
		string lookup = Inputbox.GetResultString() 
		 String ResultScene = SexlabRegistry.GetSceneByName(lookup) ; first try finding the animation by name
		 if ResultScene != "" ;found a scene with input name
			 currentthread.ResetScene(ResultScene)
			 RunCustomScene = false
		 elseif ResultScene == "" ;if no scene found with name input, search by tags instead.
			LookupAnimation(lookup)
		 EndIf
	elseif result == 7
		if DirectorCanAdvanceStage
			DirectorCanAdvanceStage = false
			Announce("Advance Stage Paused")
		else
			DirectorCanAdvanceStage = true
			Announce("Advance Stage Resumed")
		endif
	elseif result == 8
		SaveStageSpeed()
		
	elseif result == 9
		currentthread.Stopanimation()
    EndIf
EndFunction

Function Announce(String Content)

	GetAnnouncement().Show(Content,"icon.dds", aiDelay = 2.0)

endfunction


;/
target: target refr to set for
scale: time scale of animation speed, 1.0 is normal and 0.5 is 50% speed, negative is now allowed to play animation in reverse
transition: time in seconds until this speed is reached
absolute: time in seconds is fixed or not, if nonzero then it takes exactly this
          many seconds to reach target speed, if zero then it takes
		  speedDiff * transition seconds. Just set 0 if you don't understand :P
 /;

Function SaveStageSpeed()
	jsonutil.SetFloatValue("HentairimDirector/StageSpeed.json",SexlabRegistry.GetSceneName(CurrentSceneID) +"|"+GetLegacyStageNum(currentSceneID,currentStageID),AnimSpeedHelper.GetAnimationSpeed(PlayerRef, false))	
	Announce("Stage Speed Saved")
endfunction

Function LoadStageSpeed()
	float speed	= jsonutil.GetFloatValue("HentairimDirector/StageSpeed.json",SexlabRegistry.GetSceneName(CurrentSceneID) +"|"+GetLegacyStageNum(currentSceneID,currentStageID), 0.0)
	printdebug("Saved Stage Speed :" + Speed)
if Speed > 0
	printdebug("Applying Stage Speed to all Actors")
	int z = 0
	while z < actorList.length
		AnimSpeedHelper.SetAnimationSpeed(actorList[z], speed, 0.5, 0)
		z += 1
	endwhile
else
	printdebug("No Saved Speed. Resetting Speed to default")
	ResetAnimationSpeed()
endIf

endfunction

Function ResetAnimationSpeed()
	int z = 0
	while z < actorList.length
		AnimSpeedHelper.SetAnimationSpeed(actorList[z], 1.0, 0.5, 0)
		z += 1
	endwhile
	
endfunction

Function AddDoNotDisturbandCombatRape()

	actor player = game.getplayer()

	Spell CombatRapeTrackerSpell =  Game.GetFormFromFile(0x801, "Hentairim Director.esp") as Spell
	
	if !player.hasspell(CombatRapeTrackerSpell)
		player.addspell(CombatRapeTrackerSpell)
	EndIf
endfunction


Function LogActionToFile(String actionLine) ;Store SLATE Action Tags for Hentairim
	   
	   If (JsonUtil.StringListAdd("HentairimDirector/ActionLogs.json", "SLATE.ActionLog", actionLine, TRUE) < 0)
            announce("Error: failed to add " + actionLine + " to action-log file ")
        EndIf
EndFunction

Function LookupAnimation(string Tags = "")
	UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	string CurrentSceneName = SexlabRegistry.GetSceneName(CurrentSceneID)
	
	;lookup with playing actors
	string[] SceneIDarr = SexLabRegistry.LookupScenesA( currentthread.GetPositions()  ,Tags,  currentthread.GetSubmissives(), 0, none )
	
	if SceneIDarr.length > 0
		int z
		while z < SceneIDarr.length
			
			if currentsceneid == SceneIDarr[z]
				ListMenu.AddEntryItem(">>>" +SexlabRegistry.GetSceneName(SceneIDarr[z])+"<<<")
			else
				ListMenu.AddEntryItem(SexlabRegistry.GetSceneName(SceneIDarr[z]))
			EndIf
		z += 1
		endwhile

		ListMenu.OpenMenu()
		Int Selected = ListMenu.GetResultInt()
		if Selected >= 0
			currentthread.ResetScene(SceneIDarr[Selected])
			RunCustomScene = false
		endif
	endif
EndFunction

int[] PositionsToAlign

Function ShowAlignmentActorList()
	b612_SelectList Actorlistmenu = GetSelectList()
	;prepare Actorlist Names
	String[] ActorlistNames
	
	int z = 0
	while z < actorlist.Length
		if PositionsToAlign.find(z) >= 0 ; in the arr to align
			ActorlistNames = papyrusutil.pushstring(ActorlistNames , actorlist[z].getdisplayname() + "(Selected)")
		else
			ActorlistNames = papyrusutil.pushstring(ActorlistNames , actorlist[z].getdisplayname() + "(Not Selected)")
		endif
		z += 1
	endWhile
	
	;Show Actor List
	int position = Actorlistmenu.Show(ActorlistNames)
	if position <= -1
		return
	EndIf
	
	if PositionsToAlign.find(position) >= 0 ;remove from actors to Align if existing
		PositionsToAlign = papyrusutil.removeint(PositionsToAlign,position)
		debug.notification("Position " + position + " Removed For Alignment Function")
	else
		PositionsToAlign = papyrusutil.pushint(PositionsToAlign,position)
		debug.notification("Position " + position + " Added For Alignment Function")
	endif	
endfunction

Function ShowCustomStageList()
	customscenetags
	b612_SelectList CustomStagesMenuList = GetSelectList()
	
	;prepare Custom Stages
	
	String[] CustomStagesList
	string[] StagesNumList
	int x = 1 ;skip first item with lookup criteria
	while x < customscenetags.length
		if CustomStageNum == x
			CustomStagesList = papyrusutil.pushstring(CustomStagesList,">>>"+"Custom Stage"+ x + " = " +customscenetags[x]+"<<<")
		else
			CustomStagesList = papyrusutil.pushstring(CustomStagesList,"Custom Stage"+ x + " = " +customscenetags[x])
		endif
		x += 1
	EndWhile

	;position of the selected item
	int selected = CustomStagesMenuList.Show(CustomStagesList)
	if selected >= 0
		CustomStageNum = selected + 1
		MovetoNextCustomStage()
	endif
endfunction

Function ShowStageList()
	b612_SelectList StagesMenuList = GetSelectList()
	;prepare Stages
	String[] StagesIDList = SexlabRegistry.GetAllStages(CurrentSceneID)
	string[] StagesNumList
	int z = 0
	
	while z < StagesIDList.Length
		if currentstageid == StagesIDList[z]
			StagesNumList = papyrusutil.pushstring(StagesNumList, ">>>Stage " + (z + 1)+"<<<" as string)
		else
			StagesNumList = papyrusutil.pushstring(StagesNumList, "Stage " + (z + 1) as string)
		endif
		z += 1
	endWhile
	
	;position of the selected stage
	int StagePosition = StagesMenuList.Show(StagesNumList)
	if StagePosition >= 0
		CurrentThread.SkipTo(StagesIDList[StagePosition]) ;unintended behavior to reset the stage when no stage is selected
	endif
endfunction
;/
Function ShowAddHentairimTags()
	b612_SelectList HentairimList = GetSelectList()
	
	String[] StagenumList = 
	String[] ActorNameList =
	String[] ActionTagList = StringUtil.Split("SST;FST;BST;SVP;FVP;SAP;FAP;SCG;FCG;SAC;FAC;SDP;FDP;SDV;FDV;SDA;FDA;SHJ;FHJ;STF;FTF;SMF;FMF;SFJ;FFJ;KIS;CUN;FBJ;SBJ",";")
	
		result = TagsTypeList.Show(TagsTypearr)
		if result = 0
			;add  hentairim tag
		else if result == 1
			;add hentairim SFX
		EndIf


EndFunction
/;
Function ShowUpdateSFXTags()
	b612_SelectList SFXList = GetSelectList()

	String[] SFXarr = StringUtil.Split("Slow Impact;Medium Impact;Fast Impact;Small Slush;Medium Slush;Heavy Slush;Rapid Slush;None ",";")
	String CurrentSceneName = SexlabRegistry.GetSceneName(currentsceneid)
	String CurrentStageNum = GetLegacyStageNum(CurrentSceneID, CurrentStageID)
	
	int result = SFXList.Show(SFXarr)
	
	if result == 0 ;slow impact
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"sc")
	elseif result == 1 ;medium impact
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"mc")
	elseif result == 2 ;Fast impact
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"fc")
	elseif result == 3 ;Small Slush
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"ss")
	elseif result == 4 ;Medium Slush
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"ms")
	elseif result == 5 ;Heavy Slush
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"fs")
	elseif result == 6 ;Rapid Slush
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"rs")
	elseif result == 7 ;No Sound
		HentairimTags.UpdateHentairimSFXLabels(CurrentSceneName,CurrentStageNum+"NA")
	EndIf
	
	;updatelabels(CurrentSceneid , CurrentStageNum , 0)
	Announce("SFX Tag Added. Save Your Game for it to take effect")
EndFunction

Function TeleportToRandomStageWithSimilarPositions() 
	int CurrentStageNum = GetLegacyStageNum(currentSceneID,currentStageID)
	int DestinationStage
	string tags 
	
	;whether if its standing or kneeling or laying
	if currentthread.HasSceneTag("Standing")
		tags += "Standing,"
	elseif currentthread.HasSceneTag("laying")
		tags += "Laying,"
	elseif currentthread.HasSceneTag("kneeling")
		tags += "Kneeling,"
	EndIf
	;whether if its aggressive
	if currentthread.HasSceneTag("Aggressive") && !currentthread.HasSceneTag("femdom")
		tags += "Aggressive,"
	EndIf
	;Whether if its Doggystyle or spooning
	if  currentthread.HasSceneTag("femdom")
		tags += "femdom,"
	elseif currentthread.HasSceneTag("Doggystyle") || currentthread.HasSceneTag("Doggy")
		tags += "~Doggystyle,~Doggy,~Doggystyle,"
	elseif currentthread.HasSceneTag("Spooning")
		tags += "Spooning,"
	endif
	
	;Finally Add the current Hentairim tags
	String HentairimLabeltoLookFor 
	
	;goes back to the same stage number with same intensity
	HentairimLabeltoLookFor = CurrentStageNum + "A" + PenetrationLabel
	
	tags +=  HentairimLabeltoLookFor
	TeleportToRandomStageWithTags(tags , CurrentStageNum)
	
endfunction

; Tags example : Doggy, Standing,-laying,3BSVP
bool Function TeleportToRandomStageWithTags(String Tags , int StartFromStage = 1) 
	printdebug("Tags to Teleport :" + Tags)
	printdebug("Stage Num to teleport to :" + StartFromStage)
	string[] SceneIDarr =  SexLabRegistry.LookupScenesA( currentthread.GetPositions()  ,Tags,  currentthread.GetSubmissives(), 0, none )
	
	if SceneIDarr.length > 0
		String SelectedSceneID = SceneIDarr[Utility.Randomint(0, SceneIDarr.length - 1)]
		String[] StagesIDarr = SexlabRegistry.GetAllStages(SelectedSceneID)
		currentthread.ResetScene(SelectedSceneID) ;resets to stage 1 by default
		CurrentThread.SkipTo(StagesIDarr[StartFromStage - 1])
		return true
	else
		return false
	endIf
	
endfunction

bool Function TeleportToSceneWithName(String SceneName , int StartFromStage = 1) 

	String ResultSceneID = SexlabRegistry.GetSceneByName(SceneName)

	if ResultSceneID != ""
		printdebug("Teleporting to SceneName : " + SceneName + ", Stage : " + StartFromStage)
		String[] StagesIDarr = SexlabRegistry.GetAllStages(ResultSceneID)
		currentthread.ResetScene(ResultSceneID) ;resets to stage 1 by default
		CurrentThread.SkipTo(StagesIDarr[StartFromStage - 1])
		return true
	else
		printdebug("No Scene Found with " + SceneName)
		return false
	endIf
	
endfunction

bool Function PCisVictim()
	return CurrentThread.GetSubmissive(playerref)
EndFunction

bool Function isVictim(actor char)
	return CurrentThread.GetSubmissive(char)
EndFunction

bool Function PCisAggressor()
	 actor[] victimlist = CurrentThread.GetSubmissives()
	 int z = 0
	 while z < victimlist.length
		if victimlist[z] == playerref
			return false
		endif
		z += 1
	 endwhile
	 
	if victimlist.length > 0
		return true
	else
		return  false
	endif
EndFunction

string Function GetCumTarget(string scene_id) global
	int stage_nums = SexLabRegistry.GetPathMax(  scene_id, "").Length
	string text_out =  "->"
	if stage_nums!=5
		text_out = "|" + stage_nums + text_out 
	endif
	int i = 3
	string[] targets_of = new string[3]
	targets_of[0] = "Anal"
	targets_of[1] = "Vaginal"
	targets_of[2] = "Oral"
	while i > 0
		i -= 1
		if SexlabRegistry.IsSceneTag(scene_id, targets_of[i])
			text_out += StringUtil.getNthChar(targets_of[i],0) +" "
		endif
	endwhile
	return text_out
endFunction



Function CheckStatus()

int ResistancePoints = playerref.GetFactionRank(HentairimResistanceFaction)
int BrokenPoints = playerref.GetFactionRank(HentairimBroken)
string msg 
if PCisVictim
	msg += "You are a Victim! \n"
elseif PCisAggressor 
	msg += "You are an Aggressor! \n"
else
	msg += "You are in Consensual! \n"
endif
msg += "Resistance Points: " + ResistancePoints + "\n"
if BrokenPoints > 0
	msg += "Broken Status : You Are Broken ! Hours Without Sex to Recover : " + BrokenPoints + "\n"
else
	msg += "Broken Status : You are Sane \n"
endIf
Debug.MessageBox(msg)
endFunction


String Function ShowChangePosition()
	if !CurrentThread 
		return none
	endif
	Int TypearrID
	int PositionarrID
    b612_SelectList PositionList = GetSelectList()
	String[] Typearr
	String[] Positionarr
	Typearr = StringUtil.Split("Vaginal;Anal;Oral;Boobjob;Handjob;Lesbian;Futa;Any",";")
	Positionarr = StringUtil.Split("Standing;Kneeling;Laying;Sitting;Doggystyle;Missionary;Any",";")
	TypearrID = PositionList.Show(Typearr) 
	PositionarrID = PositionList.Show(Positionarr)
	string randomstage = Utility.randomint(2,3) as string
	String HentairimTag
	
	if Typearr[TypearrID] == "any"
		Typearr[TypearrID] = "-a"
	endIf
	
	if Positionarr[PositionarrID] == "any"
		Positionarr[PositionarrID] = "-b"
	endIf
	
	string tags = Positionarr[PositionarrID] + "," + Typearr[TypearrID]
	
	UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	string[] SceneIDarr =  SexLabRegistry.LookupScenesA( currentthread.GetPositions()  ,Tags,  currentthread.GetSubmissives(), 0, none )
	if SceneIDarr.length > 0
		int z
		while z < SceneIDarr.length
			
			if currentsceneid == SceneIDarr[z]
				ListMenu.AddEntryItem(">>>" +SexlabRegistry.GetSceneName(SceneIDarr[z])+"<<<")
			else
				ListMenu.AddEntryItem(SexlabRegistry.GetSceneName(SceneIDarr[z]))
			EndIf
		z += 1
		endwhile
		
		;open menu
		ListMenu.OpenMenu()
		Int Selected = ListMenu.GetResultInt()
		if Selected >= 0
			currentthread.ResetScene(SceneIDarr[Selected])
			RunCustomScene = false
		endif
	endif
endfunction

Bool function HasSexlabArousal()
	return Game.GetModbyName("SexlabAroused.esm") != 255
endfunction

function UpdateArousal(Actor char, int value)
if !HasSexlabArousal()
	return
endif
	
	Quest OSLArousalQuest = Game.GetFormFromFile(0x4290F, "SexlabAroused.esm") as Quest
    slaFrameworkScr SLAFramework = OSLArousalQuest as slaFrameworkScr
	
	if SLAFramework != none
		SLAFramework.UpdateActorExposure(char, value)
	else
		miscutil.printconsole("Something is Wrong! SLAFramework Script is none! looks like its not installed")
	endif
	
endfunction
;------------------------------Director's Tools END------------------------
