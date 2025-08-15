Scriptname IVDTControllerScript extends ReferenceAlias  

import b612
sslthreadcontroller threadcontroller
SexLabFramework Property SexLab Auto
IVDTMCMConfigurationScript Property ConfigOptions Auto
IVDTSoundsScript Property Sounds Auto
CreatureFrameworkUtil CFutil
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
keyword TNG_XL 
keyword TNG_L
faction HentairimBroken
faction HentairimResistanceFaction
Faction HentairimDoNotDisturbFaction
SexLabThread CurrentThread
bool SceneExtend
int CurrentThreadid
string OriginalSceneID 
bool isPlayingForeplayScene
int[] PCInteractionTypes
int[] PCPartnerInteractionTypes
int linearsceneenjoymentendstagetopup

Bool DoneLinearSceneOrgasm
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
if Game.GetModbyName("HentairimSFX.esp") != 255
	SFXSPELL = Game.GetFormFromFile(0x800, "HentairimSFX.esp") as Spell
endif
if Game.GetModbyName("HentairimExpressions.esp") != 255
	ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell	
endif

if Game.GetModbyName("HentairimResistance.esp") != 255
	ResistanceSpell = Game.GetFormFromFile(0x800, "HentairimResistance.esp") as Spell
endif	

;Others
if Game.GetModbyName("Schlongs of Skyrim.esp") != 255
	schlongfaction = Game.GetFormFromFile(0xAFF8 , "Schlongs of Skyrim.esp") as Faction
EndIf
if Game.GetModbyName("TheNewGentleman.esp") != 255
	TNG_Gentlewoman = Game.GetFormFromFile(0xFF8, "TheNewGentleman.esp") as Keyword
	TNG_XL = Game.GetFormFromFile(0xFE5, "TheNewGentleman.esp") as Keyword
    TNG_L = Game.GetFormFromFile(0xFE4, "TheNewGentleman.esp") as Keyword
endif
if Game.GetModbyName("HentairimResistance.esp") != 255
	HentairimBroken = Game.GetFormFromFile(0x802, "HentairimResistance.esp") as Faction
endif

if !SFXSPELL && Game.GetModbyName("HentairimSFX.esp") != 255
	WritetoErrorlogs("Director", "SFX Spell is Missing! Make Sure the Mod is properly installed and Plugin Enabled")
endif

if !ExpressionsSpell && Game.GetModbyName("HentairimExpressions.esp") != 255
	WritetoErrorlogs("Director", "Expressions Spell is Missing! Make Sure the Mod is properly installed and Plugin Enabled")
endif

if !ResistanceSpell && Game.GetModbyName("HentairimResistance.esp") != 255
	WritetoErrorlogs("Director", "Resistance Spell is Missing! Make Sure the Mod is properly installed and Plugin Enabled")
endif

;workarounds male actors to show male animations for female only


EndFunction

Function RegisterForTheEventsWeNeed()
	RegisterForModEvent("AnimationStart", "DirectorSceneStart")
	RegisterForModEvent("SexLabOrgasmSeparate", "DirectorOnOrgasm")
	RegisterForModEvent("StageStart", "DirectorStageStart")
	;RegisterForModEvent("AnimationEnd", "DirectorSceneEnd")
EndFunction

Event DirectorStageStart(string eventName, string argString, float argNum, form sender)
	if CurrentThread
		LoadStageSpeed() ;load saved speed
		LoadSchlongAdjustment() ;load saved schlong adjustments
		;trigger update for creatureframework
		if currentSceneID != CurrentThread.GetActiveScene() 
			DoneLinearSceneOrgasm = false
			TriggerUpdateforCreatures()
		endif
	endif
EndEvent

int[]PositionsToAlign
;Director reacts when a sexlab scene start
Event DirectorSceneStart(string eventName, string argString, float argNum, form sender)
	;Hentairim is for handling player scenes only. 
	playerref = game.getplayer() ;player
	printdebug("Sexlab Scene Detected")
	if PlayerInScene || !Sexlab.GetThreadByActor(PlayerRef)
		printdebug("Sexlab Scene Does not Involve Player.Ignored")
		Return
	endIf
	
	;Initialize Configs
	InitializeDIrectorConfigs()
	CustomScenePositionTags = ""
	CustomStageNum = 0
	CustomSceneTags = new string[1]
	CustomSceneTags = papyrusutil.RemoveString(CustomSceneTags , CustomSceneTags[0])
	TimertoAdvance = 0 
	UpdateNow = false
	Timerdebt = 0
	StorageUtil.SetIntValue(None, "DirectorAdvanceStage", 0) ;default no directory signal to have processes be ready
	threadcontroller = sexlab.GetPlayerController()
	CurrentThread = Sexlab.GetThreadByActor(PlayerRef) ;CURRENT THREAD
	CurrentThreadID = CurrentThread.GetThreadID()
	CurrentSceneID = CurrentThread.GetActiveScene()
	CurrentStageID = CurrentThread.GetActiveStage()
	actorList = CurrentThread.GetPositions()
	PCPosition =  CurrentThread.GetPositionIdx(Playerref)
	if isLinearScene()
		disableorgasmall()
	endif
	
	PlayerInScene = true
	SceneExtend = false
	RunCustomScene = CheckifShouldRunCustomScene()
	if !RunCustomScene
		if utility.randomint(1,100) <= chancetostartforeplay && PCPosition == 0 && !currentthread.GetSubmissive(playerref)
			printdebug("Starting Foreplay")
			StartForeplayScene()
		endif
	endif
	UpdateLabelsArr(CurrentSceneID , GetLegacyStageNum(CurrentSceneID, CurrentStageID) )
	;initialize variables
	IVDTCanAdvance = true ;default IVDT ready to advance
	SFXCanAdvance = true ;default sfx ready to advance
	PCisAggressor = PCisAggressor()
	AllFemale = AllFemale()
	PCisReceiving = playerref == actorList[0]
	PCisVictim = PCisVictim()
	
	PositionsToAlign = papyrusutil.pushint(PositionsToAlign,0)
	
	
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

Event DirectorOnOrgasm(Form actorRef, Int thread)
	
endevent

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
	;unset Hentairim Director Custom Scene Variable
	StorageUtil.SetStringValue(None, "DirectorCustomScene", "")
	
	CurrentThread = none
	CurrentSceneID = none
	CurrentStageID = none
	PlayerInScene = false
	OriginalSceneID = ""
	isPlayingForeplayScene = false
	DoneLinearSceneOrgasm = false
	PositionsToAlign = new int[1]
	PositionsToAlign = papyrusutil.RemoveInt(PositionsToAlign , PositionsToAlign[0])
	EnableOrgasmAll()
	storageutil.setfloatvalue(none,"HentairimTimerModifier",1.0)
	storageutil.Setintvalue(none,"HentairimNextnup",0)
	updaterate = 0.5
	if EnableExpressions == 1
		resetexpressions()
	endif
	printdebug("Hentairim Director Scene END")
	
endfunction 

;Event DirectorSceneEnd(string eventName, string argString, float argNum, form sender)
;	miscutil.printconsole("DirectorSceneEnd START eventName : " + eventName + " argString : " + argString + " argNum : " + argNum)
;	printdebug("eventName :" + eventName + " argString : " + argString + " argNum : " + argNum)
;EndEvent
bool completedResolvingHornyDebt
Event OnUpdate()

	int threadstatus = currentthread.GetStatus()
	printdebug("threadstatus : " + threadstatus)
	if threadstatus == 4 || threadstatus == 0
		printdebug("End Scene.")
		DirectorEndScene()
		return
	endif
	
	printdebug("---Updating---")
	;check whether to advance Stage
	printdebug("TimertoAdvance : " + TimertoAdvance)
	printdebug("Thread Total Time : " + CurrentThread.GetTimeTotal())
	;check for key being held down
	if Input.IsKeyPressed(directortoolskey)
	printdebug("Director Tools key pressed.")
	OpenDirectorTools()

	elseif Input.IsKeyPressed(adjustsidewayskey)
		printdebug("Adjust Sideways key pressed.")
		if Input.IsKeyPressed(modifierkey)
			printdebug("Modifier key held. Adjusting sideways with fine control.")
			AdjustAlignment(0 , true)
		else
			printdebug("Modifier key not held. Adjusting sideways normally.")
			AdjustAlignment(0 , false)
		endif

	elseif Input.IsKeyPressed(adjustupdownkey)
		printdebug("Adjust Up/Down key pressed.")
		if Input.IsKeyPressed(modifierkey)
			printdebug("Modifier key held. Adjusting up/down with fine control.")
			AdjustAlignment(2 , true)
		else
			printdebug("Modifier key not held. Adjusting up/down normally.")
			AdjustAlignment(2 , false)
		endif

	elseif Input.IsKeyPressed(adjustforwardkey)
		printdebug("Adjust Forward/Back key pressed.")
		if Input.IsKeyPressed(modifierkey)
			printdebug("Modifier key held. Adjusting forward/back with fine control.")
			AdjustAlignment(1 , true)
		else
			printdebug("Modifier key not held. Adjusting forward/back normally.")
			AdjustAlignment(1 , false)
		endif

	elseif Input.IsKeyPressed(adjustrotationkey)
		printdebug("Adjust Rotation key pressed.")
		if Input.IsKeyPressed(modifierkey)
			printdebug("Modifier key held. Adjusting rotation with fine control.")
			AdjustAlignment(3 , true)
		else
			printdebug("Modifier key not held. Adjusting rotation normally.")
			AdjustAlignment(3 , false)
		endif

	elseif Input.IsKeyPressed(advancekey)
		printdebug("Advance key pressed.")
		if CurrentThread.GetTimeTotal() > LastManualAdvancetime + 3
			printdebug("Enough time has passed. Advancing to next stage.")
			AdvancetoNextStage()
			AddtoTimer(GetTimer())
			LastManualAdvancetime = CurrentThread.GetTimeTotal()
		else
			printdebug("Advance key pressed too soon. Ignoring.")
		endif
	endif
	
	printdebug("DoneLinearSceneOrgasm : " + DoneLinearSceneOrgasm)
	printdebug("Isfinalstage() : " + Isfinalstage())
	printdebug("isLinearScene() : " + isLinearScene())
	printdebug("isPlayingForeplayScene : " + isPlayingForeplayScene)

	;handle final stage orgasm for linear scene
	if !DoneLinearSceneOrgasm && Isfinalstage() && isLinearScene()
		printdebug("Linear Scene play endstage orgasm")
		LinearEndStageForceOrgasm()
		DoneLinearSceneOrgasm = true
		
	endif
	printdebug("step 1")
	;======Extended Scene===========
	if storageutil.getintvalue(None,"HentairimExtendScene",0) == 1 && canAdvance()
		printdebug("HentairimExtendScene is active.")

		AdvancetoNextStage()
		
		AddtoTimer(GetTimer())
		printdebug("Timer updated.")
		UpdateNow = true
		
		;extend once
		if isFinalStage()
			printdebug("end extend scene.")
			storageutil.Setintvalue(None,"HentairimExtendScene",0)
			currentthread.Stopanimation()
		endif
	else ;=========NORMAL SCENE===========
		if CanAdvance()
			printdebug("CanAdvance = true. Advancing stage now.")

			StorageUtil.SetIntValue(None, "DirectorAdvanceStage", 0)
			;check to see if can extendstage
			bool result
			if isFinalStage()
				printdebug("is final stage.")
				if isPlayingForeplayScene
					printdebug("is foreplay scene. reset scene to original penetration scene.")
					DoneLinearSceneOrgasm = false
					isPlayingForeplayScene = false
					currentthread.ResetScene(OriginalSceneID) ;Go back to original intended scene that was skipped
				else ;check if can extend scene
					;check if can counter rape
					printdebug("check if can counter rape")
					result = CounterRape()
					printdebug("counter rape result : " + result)
					;check if can extend scene
					if !result
						printdebug("check if can extend")
						result = ExtendScene()
						printdebug("ExtendScene result : " + ExtendScene())
					endif
					;advance to next stage. usually its end animation
					if !result
						printdebug("Cannot Extend or Counter Rape")
						AdvancetoNextStage()
					endif
				endif
			else
				printdebug("Not Final Stage. Advance")
				AdvancetoNextStage()
			endif
			printdebug("Calling AddtoTimer with value: " + GetTimer())
			AddtoTimer(GetTimer())

			UpdateNow = true
			printdebug("UpdateNow set to true. Stage advance complete.")

		elseif DirectorCanAdvanceStage && enableautoadvancestage == 1 && TimertoAdvance < CurrentThread.GetTimeTotal()
			printdebug("Timer passed but waiting on other processes. Checking DirectorAdvanceStage.")

			if StorageUtil.GetIntValue(None, "DirectorAdvanceStage") == 0
				StorageUtil.SetIntValue(None, "DirectorAdvanceStage", 1)
				printdebug("DirectorAdvanceStage was 0. Set to 1.")
			else
				printdebug("DirectorAdvanceStage already set. No change.")
			endif
		endif
	endif	

	;=== Scene or Stage update check ===
	if UpdateNow || currentSceneID != CurrentThread.GetActiveScene() || CurrentStageID != CurrentThread.GetActiveStage()
		printdebug("Updating labels: Scene or Stage changed.")
		currentSceneID = CurrentThread.GetActiveScene()
		CurrentStageID = CurrentThread.GetActiveStage()
		updatelabelsarr(CurrentSceneID, GetLegacyStageNum(CurrentSceneID, CurrentStageID))
		if enablehentairimscaling == 1 && currentSceneID != CurrentThread.GetActiveScene()
			HentairimScaling()
			
		EndIf
		
		LastLabelUpdateTime = CurrentThread.GetTimeTotal()
		UpdateNow = false

		if resetsmp == 1
			printdebug("SMP reset triggered.")
			consoleutil.executecommand("SMP Reset")
		endif
	endif

	;=== Continue Scene or End ===
	
	RegisterForSingleUpdate(updaterate)		
	
endEvent

bool function isUpdating()
	return updatenow
endfunction

float function GetDirectorLastLabelTime()
	return LastLabelUpdateTime
endfunction
Function AddTrackerToSceneIfApplicable(string argString)
	
	;Hentairim Director running

	;------------Start Applying Effects to Actors in Thread------------------------		
	RunThreadControl()
	
	;---------------Applying IVDT Spell to Player-------------------
	if playerref.HasSpell(SceneTrackerSpell) ;Scene with female voice actor
		playerref.RemoveSpell(SceneTrackerSpell)
	endif	
	if EnableIVDT == 1
		printdebug("playerref added Hentairim ivdt Spell")
		sslVoiceSlots.DeleteVoice(playerref)
		sslVoiceSlots.StoreVoice(playerref,"")
		threadcontroller.ActorAlias[pcposition].SetActorVoice("",true)
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
int uselinearscene
int givingforeplayinlinearscenedontorgasm
int modifierkey
int adjustforwardkey
int adjustsidewayskey
int adjustupdownkey
int adjustrotationkey
int advancekey
int enablehentairimscaling
int enablearmorswap
int enableautoadvancestage
int ResetSMP
int resetsexassignment
int chancetostartforeplay
int foreplayhandjobweight
int foreplaytitfuckweight
int foreplayfootjobweight
int foreplayblowjobweight
int enableprintdebug

int enablestagemaker
int chancetousecustomstage
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

;Traits
string TraitsFile = "HentairimDirector/HentairimTrait.json"
String[] linearscenefinalstageorgasmfactor
String[] linearsceneextendstagechance
String[] linearscenecounterrapechance

int daystorerolltrait
int extrahornyextendscenechance
int strongnpccounterfuckchance
int cumalotnpcorgasmsecondtimechance
int cumalotnpcorgasmthirdtimechance

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
	uselinearscene = JsonUtil.GetIntValue(ControlConfigFile, "uselinearscene" ,0)
	givingforeplayinlinearscenedontorgasm = JsonUtil.GetIntValue(ControlConfigFile, "givingforeplayinlinearscenedontorgasm" ,0)
	linearsceneenjoymentendstagetopup = JsonUtil.GetIntValue(ControlConfigFile, "givingforeplayinlinearscenedontorgasm" ,0)
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
	chancetostartforeplay = JsonUtil.GetIntValue(ControlConfigFile, "chancetostartforeplay" ,0)
	foreplayhandjobweight = JsonUtil.GetIntValue(ControlConfigFile, "foreplayhandjobweight" ,0)
	foreplaytitfuckweight = JsonUtil.GetIntValue(ControlConfigFile, "foreplaytitfuckweight" ,0)
	foreplayfootjobweight = JsonUtil.GetIntValue(ControlConfigFile, "foreplayfootjobweight" ,0)
	foreplayblowjobweight = JsonUtil.GetIntValue(ControlConfigFile, "foreplayblowjobweight" ,0)
	enableprintdebug = JsonUtil.GetIntValue(ControlConfigFile, "printdebug" ,0)
	linearscenefinalstageorgasmfactor = papyrusutil.stringsplit(JsonUtil.GetstringValue(ControlConfigFile, "linearscenefinalstageorgasmfactor" ,0) ,",")
	linearsceneextendstagechance = papyrusutil.stringsplit(JsonUtil.GetstringValue(ControlConfigFile, "linearsceneextendstagechance" ,0) ,",")
	linearscenecounterrapechance = papyrusutil.stringsplit(JsonUtil.GetstringValue(ControlConfigFile, "linearscenecounterrapechance" ,0) ,",")

	;load Stage Maker Configs

	enablestagemaker = JsonUtil.GetIntValue(StageMakerFile, "enablestagemaker" ,0)
	chancetousecustomstage = JsonUtil.GetIntValue(StageMakerFile, "chancetousecustomstage" ,0)
	
	printdebug(" EnableSFX :" + EnableSFX)
	printdebug(" enableExpressions :" + enableExpressions)
	printdebug("enablepcexpression :" + enablepcexpression)
	printdebug("enablefemalenpcexpression :" + enablefemalenpcexpression)	
	printdebug("enablemalenpcexpression :" + enablemalenpcexpression)
	printdebug("enablehentairimscaling :" + enablehentairimscaling)
	printdebug("enablearmorswap :" + enablearmorswap)

	printdebug(" ldi :" + ldi)
	printdebug(" sst :" + sst)
	printdebug(" fst :" + fst)
	printdebug(" bst :" + bst)
	printdebug(" kis :" + kis)
	printdebug(" cun :" + cun)
	printdebug(" sbj :" + sbj)
	printdebug(" fbj :" + fbj)
	printdebug(" sap :" + sap)
	printdebug(" svp :" + svp)
	printdebug(" fap :" + fap)
	printdebug(" fvp :" + fvp)
	printdebug(" sdp :" + sdp)
	printdebug(" fdp :" + fdp)
	printdebug(" scg :" + scg)
	printdebug(" sac :" + sac)
	printdebug(" fcg :" + fcg)
	printdebug(" fac :" + fac)
	printdebug(" sdv :" + sdv)
	printdebug(" sda :" + sda)
	printdebug(" fdv :" + fdv)
	printdebug(" fda :" + fda)
	printdebug(" shj :" + shj)
	printdebug(" fhj :" + fhj)
	printdebug(" stf :" + stf)
	printdebug(" ftf :" + ftf)
	printdebug(" smf :" + smf)
	printdebug(" fmf :" + fmf)
	printdebug(" sfj :" + sfj)
	printdebug(" ffj :" + ffj)
	printdebug(" eno :" + eno)
	printdebug(" eni :" + eni)
	
	printdebug(" directortoolskey : " + directortoolskey)
	printdebug(" modifierkey : " + modifierkey)
	printdebug(" adjustforwardkey : " + adjustforwardkey)
	printdebug(" adjustsidewayskey : " + adjustsidewayskey)
	printdebug(" adjustupdownkey : " + adjustupdownkey)
	printdebug(" adjustrotationkey : " + adjustrotationkey)
	printdebug(" enablehentairimscaling : " + enablehentairimscaling)
	printdebug(" enablearmorswap : " + enablearmorswap)
	printdebug(" enableautoadvancestage : " + enableautoadvancestage)
	printdebug(" resetsmp : " + resetsmp)
	printdebug(" resetsexassignment : " + resetsexassignment)
	
	printdebug(" Stage maker : " + enablestagemaker)
	printdebug(" chancetousecustomstage : " + chancetousecustomstage)
	printdebug(" linearscenefinalstageorgasmfactor : " + linearscenefinalstageorgasmfactor)
	printdebug(" linearsceneextendstagechance : " + linearsceneextendstagechance)
	printdebug(" linearscenecounterrapechance : " + linearscenecounterrapechance)
endfunction




;Director's Thread Control when Player's Thread just started.
Function RunThreadControl()

	if enablearmorswap == 1
		printdebug("Thread Control running body armor swapping")
		BodySwitchtoLewdArmor(playerref)
	endif
	
	if enablehentairimscaling == 1
		printdebug("Thread Control running Scaling")
		HentairimScaling()
	EndIf

EndFunction

;--------------------------------HENTAIRIM SCALING FUNCTIONS START--------------------------------;
Float[] actorlistOriginalScalearr

Function HentairimScaling()
	int z = 0
	while z < actorlist.Length

		Actor char = actorlist[z]

		;miscutil.PrintConsole(char.GetDisplayName() + " | Original GetScale: " + char.GetScale())
		float display = char.GetScale()
		;miscutil.PrintConsole(char.GetDisplayName() + " | Stored display: " + display)

		actorlistOriginalScalearr = PapyrusUtil.PushFloat(actorlistOriginalScalearr, display)
		;miscutil.PrintConsole(char.GetDisplayName() + " | Pushed original scale to array: " + display)

		char.SetScale(1.0)
		;miscutil.PrintConsole(char.GetDisplayName() + " | SetScale to 1.0")
		;miscutil.PrintConsole(char.GetDisplayName() + " | Scale after setting to 1.0: " + char.GetScale())

		float base = char.GetScale()
		;miscutil.PrintConsole(char.GetDisplayName() + " | Stored base: " + base)

		float ActorScale = display / base
		;miscutil.PrintConsole(char.GetDisplayName() + " | Calculated ActorScale: " + ActorScale)

		float AnimScale = ActorScale
		;miscutil.PrintConsole(char.GetDisplayName() + " | AnimScale initialized to ActorScale: " + AnimScale)

		if ActorScale > 0.0 && ActorScale != 1.0
			char.SetScale(ActorScale)
			;miscutil.PrintConsole(char.GetDisplayName() + " | Restored ActorScale: " + ActorScale)
		else
			;miscutil.PrintConsole(char.GetDisplayName() + " | Skipped restoring ActorScale (value: " + ActorScale + ")")
		endIf

		float finalScale = GetAnimSpecialScaleValue(z)
		char.SetScale(finalScale)
		;miscutil.PrintConsole(char.GetDisplayName() + " | Final SetScale from GetAnimSpecialScaleValue: " + finalScale)

		z += 1
	endWhile
EndFunction


Function ResetScaling()
	int z = 0
	while z < actorlistOriginalScalearr.Length
	actorlist[z].SetScale(actorlistOriginalScalearr[z])
	
	z += 1
	EndWhile
	
	actorlistOriginalScalearr = new float[1]
	actorlistOriginalScalearr = papyrusutil.RemoveFloat(actorlistOriginalScalearr,actorlistOriginalScalearr[0])

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
EndFunction
;---------------------------ARMOR SWAPPING FUNCTIONS END------------------------

;---------------------------Stage Control FUNCTIONS Start------------------------
Bool IVDTCanAdvance = True
Bool SFXCanAdvance = True

bool Function CanAdvance()
	PrintDebug("CanAdvance=" + (DirectorCanAdvanceStage && enableautoadvancestage == 1 && IVDTCanAdvance && SFXCanAdvance && TimertoAdvance < CurrentThread.GetTimeTotal()) + " | DirectorCanAdvanceStage=" + DirectorCanAdvanceStage + " | enableautoadvancestage=" + enableautoadvancestage + " | IVDTCanAdvance=" + IVDTCanAdvance + " | SFXCanAdvance=" + SFXCanAdvance + " | TimertoAdvance=" + TimertoAdvance + " | TimeTotal=" + CurrentThread.GetTimeTotal())

	return DirectorCanAdvanceStage && enableautoadvancestage == 1 && IVDTCanAdvance && SFXCanAdvance && TimertoAdvance < CurrentThread.GetTimeTotal()
endfunction


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
	value = value * storageutil.Getfloatvalue(none,"HentairimTimerModifier",1.0) ;global storageutil that lets mods to modify timer for this scene
	
	TimertoAdvance = CurrentThread.GetTimeTotal()
	TimertoAdvance += value
	if IsGettingAnallyPenetrated(actorlist[0]) || IsGettingVaginallyPenetrated(actorlist[0]) || IsSuckingoffOther(actorlist[0])
		if timerdebt > 0
			if timerdebt < 15
				TimertoAdvance += timerdebt
				timerdebt = 0
			else
				TimertoAdvance += 15
				timerdebt -= 15
			endif
		elseif timerdebt < 0
			if timerdebt > -10
				TimertoAdvance += timerdebt ; negative debt fully paid off
				timerdebt = 0
			else
				TimertoAdvance -= 10
				timerdebt += 10
			endif
		endif
	endif

endFunction



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

string[] Function FindValidCustomScene(bool ReturnAllValidScenes = false) ;if enabled, it will return all valid custom scenes. the entire line item string will be stuffed into array in place of custom stage. used for custom scene searching only
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
	ElseIf ReturnAllValidScenes
		return ValidCustomScenesarr
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

if currentthread.HasSceneTag("Furniture")
	printdebug("Cannot use CUstom Scene in FUrniture")
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
	

	MovetoNextCustomStage()

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
	;if current scene already has this customstagetags
	if currentthread.HasSceneTag(CustomStageTags)
		DestinationStage = StringUtil.Substring(CustomStageTags, 0, 1) as int
		if DestinationStage > 0
			string[] StagesIDList = SexlabRegistry.GetAllStages(CurrentSceneID)
			CurrentThread.SkipTo(StagesIDList[DestinationStage - 1])
			CustomStageNum += 1
			return ;no need to run subsequent code
		endif
	endif
	;identify destination stage to move to. only look at first character for potential stage number as per rules
		DestinationStage = StringUtil.Substring(CustomStageTags,0,1) as int
	
	;if no destination Stage Identified
	if DestinationStage <= 0
		if IsEnding(actorlist[0])
			DestinationStage = 5
		elseif IsgettingPenetrated(actorlist[0]) || IsCowgirl(actorlist[0]	)
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

Int Timerdebt = 0
Function AddTimerDebt(int value)

	Timerdebt += Value

EndFunction

Function ModResistance(Actor char, int value)
if enableResistance == 1
	int currentRank = char.GetFactionRank(HentairimResistanceFaction)
	int newRank = currentRank + value

	if newRank > 100
		newRank = 100
	elseif newRank < 0
		newRank = 0
	endif

	char.SetFactionRank(HentairimResistanceFaction, newRank)
endif
EndFunction


Bool Function TryToFindaPositions(String HentairimTagwithoutStage ,string additionaltags, bool SearchFromtheFront = false)
	PrintDebug("TryToFindaPositions: Started with Tag = " + HentairimTagwithoutStage)

	string tags
	int TargetStage

	if StringUtil.Substring(HentairimTagwithoutStage, 0, 1) == "s"
		TargetStage = Utility.RandomInt(2, 3)
		PrintDebug("Tag starts with S, setting TargetStage between 2 and 3: " + TargetStage)
	else
		TargetStage = Utility.RandomInt(3, 6)
		PrintDebug("Tag not starting with S, setting TargetStage between 3 and 6: " + TargetStage)
	endif

	tags = TargetStage as string + HentairimTagwithoutStage
	PrintDebug("Constructed initial tags: " + tags)

	bool found = TeleportToRandomStageWithTags(tags, TargetStage)
	PrintDebug("Initial teleport result with TargetStage " + TargetStage + ": " + found)
	bool found2
	if !found
		if SearchFromtheFront
			int y = 1
			
			PrintDebug("Initial search failed, attempting fallback search from stage 7 down to 1")

			while y <= 7 && !found2
				tags = y as string + HentairimTagwithoutStage + "," + additionaltags
				PrintDebug("Trying fallback tag: " + tags + " at stage " + y)
				found2 = TeleportToRandomStageWithTags(tags, y)
				PrintDebug("Fallback attempt at stage " + y + " result: " + found2)
				y += 1
			endwhile
		else
			int y = 7
			PrintDebug("Initial search failed, attempting fallback search from stage 7 down to 1")

			while y >= 1 && !found2
				tags = y as string + HentairimTagwithoutStage + "," + additionaltags
				PrintDebug("Trying fallback tag: " + tags + " at stage " + y)
				found2 = TeleportToRandomStageWithTags(tags, y)
				PrintDebug("Fallback attempt at stage " + y + " result: " + found2)
				y -= 1
			endwhile
		endif
		
		if found2
			PrintDebug("Fallback found a position successfully.")
			return true
		else
			PrintDebug("Fallback failed. No valid position found. Ending Scene")
			currentthread.Stopanimation()
			return false
		endif
	else
		PrintDebug("Initial teleport succeeded.")
		return true
	endif
EndFunction

Bool Function NextStageHasPenetration()
	bool result
	bool ContinueInSameScene
	int currentstage = GetLegacyStageNum(CurrentSceneID, CurrentStageID)
	string NextStage = (Currentstage + 1) as string

	if isFinalStage()
		result = false
	else
		result = CurrentThread.HasSceneTag(NextStage + "ASVP") || CurrentThread.HasSceneTag(NextStage + "AFVP") || CurrentThread.HasSceneTag(NextStage + "ASDP") || CurrentThread.HasSceneTag(NextStage + "AFDP") || CurrentThread.HasSceneTag(NextStage + "ASAP") || CurrentThread.HasSceneTag(NextStage + "FSAP")
	endif
	return result
endfunction

Function AdvancetoNextStage()
	if RunCustomScene
		MovetoNextCustomStage()
	else
		CurrentThread.skipto(GetNextStageID(CurrentSceneID, CurrentStageID))
	endIf
endFunction

Function DisableOrgasm(actor char)
	CurrentThread.DisableOrgasm(char, true)
EndFunction

Function EnableOrgasm(actor char)

	if isLinearScene()
		CurrentThread.DisableOrgasm(char, true)
	else
		CurrentThread.DisableOrgasm(char, false)
	endif
EndFunction

Function EnableOrgasmAll()
	int z 
	while z < actorlist.length
		EnableOrgasm(actorlist[z])
		z += 1
	endwhile	
EndFunction

Function DisableOrgasmAll()
	int z 
	while z < actorlist.length
		DisableOrgasm(actorlist[z])
		z += 1
	endwhile	
EndFunction
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

bool function ResistanceEnabled()
	return enableResistance == 1
EndFunction

Function UpdateMasterVolume()
	Float Volume = 100
	IVDTVoices.SetVolume(Volume)
	IVDTMCMAudio.SetVolume(Volume)
EndFunction

Function UnmuteSexLabVoices()
	SexLabVoices.UnMute()
EndFunction
string[] Stimulationlabelarr
string[] PenisActionLabelarr
string[] OralLabelarr
string[] PenetrationLabelarr
string[] EndingLabelarr

Function UpdateLabelsArr(string anim , int stage)
	int z
	while z < actorList.length
		Stimulationlabelarr = HentairimTags.GetStimulationlabelarr(anim , stage , actorlist)
		PenisActionLabelarr  = HentairimTags.GetPenisActionLabelarr(anim , stage , actorlist)
		OralLabelarr  = HentairimTags.GetOralLabelarr(anim , stage , actorlist)
		PenetrationLabelarr = HentairimTags.GetPenetrationLabelarr(anim , stage , actorlist)
		EndingLabelarr  =HentairimTags.GetEndingLabelarr(anim , stage , actorlist)
		z += 1
	endwhile
	
	printdebug("Stimulationlabelarr : " + Stimulationlabelarr)
	printdebug("PenisActionLabelarr : " + PenisActionLabelarr)
	printdebug("OralLabelarr : " + OralLabelarr)
	printdebug("PenetrationLabelarr : " + PenetrationLabelarr)
	printdebug("EndingLabelarr : " + EndingLabelarr)
endfunction


;string labelsconcat

;Function UpdateLabels(string anim , int stage , int actorpos = 0 )
; Stimulationlabel = HentairimTags.StimulationLabel(anim , stage , actorpos)
; PenisActionLabel  = HentairimTags.PenisActionLabel(anim , stage , actorpos)
; OralLabel  = HentairimTags.OralLabel(anim , stage , actorpos)
; PenetrationLabel = HentairimTags.PenetrationLabel(anim , stage , actorpos)
; EndingLabel  = HentairimTags.EndingLabel(anim , stage , actorpos)
;Labelsconcat = "1" +Stimulationlabel + "1" + PenisActionLabel + "1" + OralLabel + "1" + PenetrationLabel + "1" + EndingLabel

;endfunction

Bool Function LinearSceneCanOrgasm(actor char)
;check the past stages tags to see if actor has been stimulated before for orgasm
int stagecount = SexlabRegistry.GetAllStages(currentsceneid).length - 1
int pos = CurrentThread.GetPositionIdx(char)
	while stagecount > -1
		string tmpPenisActionLabel = HentairimTags.PenisActionLabel(currentsceneid , stagecount , pos)
		string tmpStimulationLabel = HentairimTags.StimulationLabel(currentsceneid , stagecount , pos)
		string tmpPenetrationLabel = HentairimTags.PenetrationLabel(currentsceneid , stagecount , pos)
		if tmpPenisActionLabel == "SFJ" || tmpPenisActionLabel == "FFJ" || tmpPenisActionLabel == "STF" || tmpPenisActionLabel == "FTF" || tmpPenisActionLabel == "SDV" || tmpPenisActionLabel == "FDV" || tmpPenisActionLabel == "SDA" || tmpPenisActionLabel == "FDA" || tmpPenisActionLabel == "SMF" || tmpPenisActionLabel == "FMF" || tmpPenisActionLabel == "SHJ" || tmpPenisActionLabel == "FHJ"
			printdebug(char.getdisplayname() + " had Penis Action Label. Can Orgasm")
			return TRUE
		elseif tmpPenetrationLabel == "SVP" || tmpPenetrationLabel == "FVP" || tmpPenetrationLabel == "SAP" || tmpPenetrationLabel == "FAP" || tmpPenetrationLabel == "SDP" || tmpPenetrationLabel == "FDP"
			printdebug(char.getdisplayname() + " had Penetrated before. Can Orgasm")
			return TRUE
		elseif tmpStimulationLabel == "SST" || tmpStimulationLabel == "FST" || tmpStimulationLabel == "BST"
			printdebug(char.getdisplayname() + " had Stimulation before. Can Orgasm")
			return TRUE
		endif
		Stagecount -= 1
	endwhile
	printdebug(char.getdisplayname() + " didnt had any sort of stimulation. cannot orgasm")
	return false
endFunction


string function GetNextStageID(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		return all_stages[all_stages.find(asStage)+1]
	endif
endfunction

string function GetLastStageID(String asScene)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	return all_stages[all_stages.length - 1]
endfunction

string function GetPrevStageID(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		return all_stages[all_stages.find(asStage) - 1]
	endif
endfunction

;----------------HENTAIRIM LABEL FUNCTIONs===============
string function GetStimulationlabel(actor char)
	return Stimulationlabelarr[CurrentThread.GetPositionIdx(char)]
endfunction

string function GetPenisActionLabel(actor char)
	return PenisActionLabelarr[CurrentThread.GetPositionIdx(char)]
endfunction

string function GetOralLabel(actor char)
	return OralLabelarr[CurrentThread.GetPositionIdx(char)]
endfunction

string function GetPenetrationLabel(actor char)
	return PenetrationLabelarr[CurrentThread.GetPositionIdx(char)]
endfunction

string function GetEndingLabel(actor char)
	return EndingLabelarr[CurrentThread.GetPositionIdx(char)]
endfunction

Bool Function ActorIsgettingTitfucked(actor char)
	return  Getpenisactionlabel(char) == "STF" || Getpenisactionlabel(char) == "FTF"
endfunction

Bool Function ActorIsgettingHandjobbed(actor char)
	return  Getpenisactionlabel(char) == "SHJ" || Getpenisactionlabel(char) == "FHJ"
endfunction

Bool Function ActorIsgettingFootjobbed(actor char)
	return  Getpenisactionlabel(char) == "SFJ" || Getpenisactionlabel(char) == "FFJ"
endfunction

Bool Function IsgettingPenetrated(actor char)
	return IsGettingAnallyPenetrated(char) || IsGettingVaginallyPenetrated(char)
endfunction

Bool Function IsgettingDoublePenetrated(actor char)
	return GetPenetrationLabel(char) == "SDP" || GetPenetrationLabel(char) == "FDP"
endfunction

Bool Function IsLeadIN(actor char)
	return GetStimulationlabel(char) == "LDI" && GetPenisActionlabel(char) == "LDI" && GetPenetrationlabel(char) == "LDI" && GetOralLabel(char) == "LDI" && GetEndingLabel(char) == "LDI" 
endfunction 

Bool Function IsSuckingoffOther(actor char)
	return GetOralLabel(char) == "SBJ" ||  GetOralLabel(char) == "FBJ"
endfunction

Bool Function IsCowgirl(actor char)
	return GetPenetrationLabel(char) == "SCG" ||  GetPenetrationLabel(char) == "FCG" ||  GetPenetrationLabel(char) == "SAC" ||  GetPenetrationLabel(char) == "FAC"			
endfunction

Bool Function IsEnding(actor char)
	return IsEnding( char) == "ENI" || IsEnding( char) == "ENO"
endfunction

Bool Function IsGettingVaginallyPenetrated(actor char)
	return GetPenetrationLabel(char) == "SVP" || GetPenetrationLabel(char) == "FVP" || GetPenetrationLabel(char) == "SCG" || GetPenetrationLabel(char) == "FCG" || GetPenetrationLabel(char) == "SDP" || GetPenetrationLabel(char) == "FDP"
endfunction

Bool Function IsGettingAnallyPenetrated(actor char)
	return GetPenetrationLabel(char) == "SAP" || GetPenetrationLabel(char) == "FAP"  || GetPenetrationLabel(char) == "SAC" || GetPenetrationLabel(char) == "FAC" || GetPenetrationLabel(char) == "SDP" || GetPenetrationLabel(char) == "FDP"
endfunction

Bool Function IsGivingAnalPenetration(actor char)
	return GetPenisActionLabel(char) == "FDA" || GetPenisActionLabel(char) == "SDA"
endfunction

Bool Function IsGivingVaginalPenetration(actor char)
	return GetPenisActionLabel(char) =="FDV" || GetPenisActionLabel(char) == "SDV"
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

function resetexpressions()

int z
while z < actorlist.length
	MfgConsoleFuncExt.resetmfg(actorlist[z]) 
	if MuFacialExpressionExtended.GetVersion() > 0
		MuFacialExpressionExtended.RevertExpression(actorlist[z])
	endif
z += 1
endwhile

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

bool Function isFinalStage()

	if RunCustomScene
		if CustomStageNum >= CustomSceneTags.length
			return  true
		else 
			return false
		endif
	else
		int stages_count = SexlabRegistry.GetAllStages(currentsceneid).Length
		int StageNum = GetLegacyStageNum(CurrentSceneid,currentstageid)
		return StageNum >= stages_count
	endIf
EndFunction

bool Function isAlmostFinalStage()

	if RunCustomScene
		if CustomStageNum == CustomSceneTags.length - 1
			return  true
		endif
	else
		int stages_count = SexlabRegistry.GetAllStages(currentsceneid).Length
		int StageNum = GetLegacyStageNum(CurrentSceneid,currentstageid)
		return StageNum == stages_count - 1
	endIf
EndFunction

;---------------------------Director's Utility END------------------------

;------------------------------Director's Tools START------------------------
String ActionLogsFile  = "ActionLogs/ActionLogs.json"

Function OpenDirectorTools()
	if !CurrentThread 
		return none
	endif
	Int result
    b612_SelectList DirectorTools = GetSelectList()
    String[] Directortoolsarr = StringUtil.Split("Change Stage;Change Animation;Resolve Hentairim Scaling;Actor Position Alignments;Actor Schlong Alignments;Toggle Stage Advance;Save Stage Speed;Debug Tools",";")
	
	result = DirectorTools.Show(Directortoolsarr)
	
	if result == 0 ;Change Stage
		if RunCustomScene 
			ShowCustomStageList()
		else
			ShowStageList()
		endif
    elseif result == 1 ;Change Animation
		;ShowChangePosition()
		OpenChangeAnimationMenu()
	elseif result == 2 ; Resolve Scaling
		int z = 0
		ResetScaling()
		while z < actorList.length
			actorList[z].SetScale(GetAnimSpecialScaleValue(z))
			z += 1
		endwhile
	elseif result == 3 ;Actor Alignments
        ShowAlignmentActorList()		
	elseif result == 4 ;Actor Schlong Alignments
		ShowSchlongAlignmentActorList()
	elseif result == 5
		if DirectorCanAdvanceStage
			DirectorCanAdvanceStage = false
			Announce("Advance Stage Paused")
		else
			DirectorCanAdvanceStage = true
			Announce("Advance Stage Resumed")
		endif
	elseif result == 6
		SaveStageSpeed()
	elseif result == 7 ;Open Debug tools
		OpenDebugTools()
	endif
EndFunction

function OpenDebugTools()
	Int result
	b612_SelectList DiagnosticToolsMenu = GetSelectList()
	String[] Menulist = StringUtil.Split("Show Scene Tags;Disable Scene;Stop Animation;Find Animation Without Hentairim Tags;Diagnose Hentairim Tags;Diagnose Director",";")
	result = DiagnosticToolsMenu.Show(Menulist)	

	if result == 0 ;Show Scene Tags
		debug.Messagebox( SexLabRegistry.GetSceneName(CurrentSceneID) + " : " + SexLabRegistry.GetSceneTags(CurrentSceneID))
	elseif result == 1 ; Disable scene
		DisableScene(CurrentSceneID)
	elseif result == 2 ;stop animation
		currentthread.Stopanimation() ;
	elseif result == 3 ;find animation without hentairim tags
		FindAnimationWithoutHentairimTags()
	ElseIf result == 4 ;diagnose hentairim tags
		DiagnoseHentairimTags()
	ElseIf result == 5 ;diagnose Director
		DiagnoseDirector()
	endif
endfunction

Function DiagnoseHentairimTags()

	string Tags = "-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1BFST,-2BFST,-3BFST,-4BFST,-5BFST,-5AFST,-4AFST,-3AFST,-2AFST,-1AFST,-5BSST,-4BSST,-3BSST,-2BSST,-1BSST,-1ASST,-2ASST,-3ASST,-4ASST,-5ASST,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-1BFHJ,-2BFHJ,-3BFHJ,-4BFHJ,-5BFHJ,-1BSHJ,-2BSHJ,-3BSHJ,-4BSHJ,-5BSHJ,-1BSFJ,-2BSFJ,-3BSFJ,-4BSFJ,-5BSFJ,-1BFTF,-2BFTF,-3BFTF,-4BFTF,-5BFTF,-1BSTF,-2BSTF,-3BSTF,-4BSTF,-5BSTF,-1AFBJ,-2AFBJ,-3AFBJ,-4AFBJ,-5AFBJ,-1ASBJ,-2ASBJ,-3ASBJ,-4ASBJ,-5ASBJ,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP"
	;lookup with playing actors
	string[] SceneIDarrWithoutTags = SexLabRegistry.LookupScenesA( currentthread.GetPositions()  ,Tags,  currentthread.GetSubmissives(), 0, none )
	string[] SceneIDarr = SexLabRegistry.LookupScenesA( currentthread.GetPositions()  ,"",  currentthread.GetSubmissives(), 0, none )
	
	int Countwithouttags = SceneIDarrWithoutTags.length
	int TotalCount = SceneIDarr.length
	String Messagestr = "=====Hentairim Tags Diagnostics====="
	int z
	while z < actorList.length
		string sexname
		int sex = Sexlab.GetSex(actorlist[z])
		if sex == 0
			sexname = Actorlist[z].GetDisplayName() + " (Male)"
		elseif sex == 1
			sexname = Actorlist[z].GetDisplayName() +" (Female)"
		elseif sex == 2
			Sexname = Actorlist[z].GetDisplayName() + " (Futa)"
		elseif Sex > 2
			sexname = Actorlist[z].GetDisplayName() + " (" +actorlist[z].GetRace().GetName()+")"
		endif		
		Messagestr += "\n Position " + z + " : " + sexname 
		z += 1
	EndWhile
	 float Incompletepc = Countwithouttags as float / TotalCount as float
	  Messagestr += "\n \n =====Results===== "
	 Messagestr += "\n Total Animations For this Position  : " + TotalCount
	 Messagestr += "\n Total Animations For this Position Without Tags: " + Countwithouttags
	 Messagestr += "\n Percentage of Animations without Hentairim Tags : " + (Incompletepc * 100) as string + "%"
	 debug.MessageBox(Messagestr)
	 Messagestr = ""
	 Messagestr += "=====Director's Message===== "
	 
	 if Incompletepc > 0.9
		Messagestr += "\n a Very high Percentage of your scenes are missing its Hentairim Tags. Hentairim will still function, but You will lose out a lot , A LOT of the intended experience by Hentairim as scenes not without HentairimTags will be treated as lead in"
		Messagestr += "\n its very likely that although you installed SLSB correctly, the Scenes Do not Contain Hentairim Tags, which is likely that you Generated your own SLSB or Downloaded Someone's SLSB release without HentairimTags and did not use the Pre Converted SLSB from the Release Page which already contain the Hentairim Tags."
		Messagestr += "\n Few things you can do :"
		Messagestr += "\n If you Didnt Generate the SLSB Yourself, You can pester the Guy who released the SLSB to include Hentairim Tags in SLSB."
		Messagestr += "\n OR"
		Messagestr += "\n Follow the Step by Step Guide from SLPP Release Page on how to use the Convert.py to Generate SLSB WITH HENTAIRIM TAGS IN SLATE ACTION FILES. You can get the Hentairim Tags SLATE Action log along with the Hentairim Release Page. FOLLOW THE CONVERT.py GUIDE WORD FOR WORD. if you not sure what you are doing, Ask for Help in the SLPP discord." 
	 elseif Incompletepc > 0.30
		Messagestr += "\n a High Percentage of your scenes are missing its Hentairim Tags. you will have mixed experience depending on the scene played which wouldnt be very pleasant."
		Messagestr += "\n If You Generated the SLSB, Add the Hentairim Action Logs which can be retrieved from Hentairim Release Page, and include it into your SLSB Generation. Follow the Convert.py Guide on how to include SLATE Action logs."
		Messagestr += "\n If you didnt Generate the SLSB, you can pester the SLSB Release Guy to include updated Hentairim Tags."
		Messagestr += "\n Download the PreConverted SLSB from SLPP Release Page and use the Matching Animation Packs Version against the Fomod."
	elseif Incompletepc > 0.10
		Messagestr += "\n Most of your Animations have Hentairim Installed, but there is a significant amount to notice"
		Messagestr += "\n Make sure You have Generated/Downloaded the SLSB with the latest Hentairim SLATE Action logs."
	elseif  Incompletepc > 0.05
		Messagestr += "\n Great! a most of Your Scenes Contain Hentairim Tags."
		Messagestr += "\n You can choose to Fine tune by adding in the tags and include in the SLSB Generation."
		Messagestr += "\n if you do add in your tags in missing animation, please do share your SLATE Action log to the Hentairim Board in SLPP Discord or Loverslab Release Page."
	 endIf
	 
		Messagestr += "\n \n \n Note : Hentairim Tags SLATE is missing some tags for some animation as it does not cover Guro animations, explicitly gay animations , and some obscure animation packs."
		Messagestr += "\n You can always Assign the Hentairim Tags yourself by adding them into the action log. Read the Hentairim Guide for its assignment."
		debug.MessageBox(Messagestr)
endfunction

Function DiagnoseDirector()
	String Messagestr = "===== Director Config Diagnostics ====="

	; ===== Expressions =====
	if enableExpressions == 1
		Messagestr += "\nExpressions: Enabled"
	else
		Messagestr += "\nExpressions: Disabled"
	endif

	if enablepcexpression == 1
		Messagestr += "\n - PC Expressions: Enabled"
	else
		Messagestr += "\n - PC Expressions: Disabled"
	endif

	if enablefemalenpcexpression == 1
		Messagestr += "\n - Female NPC Expressions: Enabled"
	else
		Messagestr += "\n - Female NPC Expressions: Disabled"
	endif

	if enablemalenpcexpression == 1
		Messagestr += "\n - Male NPC Expressions: Enabled"
	else
		Messagestr += "\n - Male NPC Expressions: Disabled"
	endif

	; ===== SFX =====
	if EnableSFX == 1
		Messagestr += "\nSFX: Enabled"
	else
		Messagestr += "\nSFX: Disabled"
	endif

	; ===== Resistance =====
	if enableResistance == 1
		Messagestr += "\nAggression Resistance: Enabled"
	else
		Messagestr += "\nAggression Resistance: Disabled"
	endif

	if enablepcresistancedamage == 1
		Messagestr += "\n - PC Damage: Enabled"
	else
		Messagestr += "\n - PC Damage: Disabled"
	endif

	if enablemalenpcresistancedamage == 1
		Messagestr += "\n - Male NPC Damage: Enabled"
	else
		Messagestr += "\n - Male NPC Damage: Disabled"
	endif

	if enablefemalenpcresistancedamage == 1
		Messagestr += "\n - Female NPC Damage: Enabled"
	else
		Messagestr += "\n - Female NPC Damage: Disabled"
	endif

	if enablecreaturenpcresistancedamage == 1
		Messagestr += "\n - Creature NPC Damage: Enabled"
	else
		Messagestr += "\n - Creature NPC Damage: Disabled"
	endif

	; ===== Director Controls =====
	if enableautoadvancestage == 1
		Messagestr += "\nAuto-Advance Stage: Enabled"
	else
		Messagestr += "\nAuto-Advance Stage: Disabled"
	endif

	if enablearmorswap == 1
		Messagestr += "\nArmor Swap: Enabled"
	else
		Messagestr += "\nArmor Swap: Disabled"
	endif

	if enablehentairimscaling == 1
		Messagestr += "\nHentairim Scaling: Enabled"
	else
		Messagestr += "\nHentairim Scaling: Disabled"
	endif

	if resetsmp == 1
		Messagestr += "\nReset SMP: Enabled"
	else
		Messagestr += "\nReset SMP: Disabled"
	endif

	if resetsexassignment == 1
		Messagestr += "\nReset Sex Assignment: Enabled"
	else
		Messagestr += "\nReset Sex Assignment: Disabled"
	endif

	; ===== Stage Maker =====
	if enablestagemaker == 1
		Messagestr += "\nStage Maker: Enabled"
	else
		Messagestr += "\nStage Maker: Disabled"
	endif

	Messagestr += "\n - Chance to Use Custom Stage: " + chancetousecustomstage + "%"
	debug.messagebox(Messagestr)
	messagestr = ""
	; ===== Timers =====
	Messagestr += "\n\n===== Timers (seconds) ====="
	Messagestr += "\nLDI: " + ldi
	Messagestr += "\nSST: " + sst
	Messagestr += "\nFST: " + fst
	Messagestr += "\nBST: " + bst
	Messagestr += "\nKIS: " + kis
	Messagestr += "\nCUN: " + cun
	Messagestr += "\nSBJ: " + sbj
	Messagestr += "\nFBJ: " + fbj
	Messagestr += "\nSAP: " + sap
	Messagestr += "\nSVP: " + svp
	Messagestr += "\nFAP: " + fap
	Messagestr += "\nFVP: " + fvp
	Messagestr += "\nSDP: " + sdp
	Messagestr += "\nFDP: " + fdp
	Messagestr += "\nSCG: " + scg
	Messagestr += "\nSAC: " + sac
	Messagestr += "\nFCG: " + fcg
	Messagestr += "\nFAC: " + fac
	Messagestr += "\nSDV: " + sdv
	Messagestr += "\nSDA: " + sda
	Messagestr += "\nFDV: " + fdv
	Messagestr += "\nFDA: " + fda
	Messagestr += "\nSHJ: " + shj
	Messagestr += "\nFHJ: " + fhj
	Messagestr += "\nSTF: " + stf
	Messagestr += "\nFTF: " + ftf
	Messagestr += "\nSMF: " + smf
	Messagestr += "\nFMF: " + fmf
	Messagestr += "\nSFJ: " + sfj
	Messagestr += "\nFFJ: " + ffj
	Messagestr += "\nENO: " + eno
	Messagestr += "\nENI: " + eni
	debug.messagebox(Messagestr)
	messagestr = ""
	; ===== Foreplay Weights =====
	Messagestr += "\n\n===== Foreplay Weights ====="
	Messagestr += "\nHandjob: " + foreplayhandjobweight
	Messagestr += "\nTitfuck: " + foreplaytitfuckweight
	Messagestr += "\nFootjob: " + foreplayfootjobweight
	Messagestr += "\nBlowjob: " + foreplayblowjobweight

	; ===== Linear Scene Settings =====
	Messagestr += "\n\n===== Linear Scene Factors ====="
	Messagestr += "\nFinal Stage Orgasm Factor: " + linearscenefinalstageorgasmfactor
	;Print Orgasm Factor of each Actor
	
	int z
	while z < Actorlist.length
		Float ActorOrgasmFactor = GetOrgasmFactor(actorList[z])
		Messagestr += "\n--" + actorList[z].getdisplayname()
		Messagestr += "\n----Linear Stage Orgasm Factor : " + ActorOrgasmFactor
		Messagestr += "\n----Current Enjoyment : " + currentthread.GetEnjoyment(actorList[z])
		Messagestr += "\n----Enjoyment After Orgasm Factor : " + currentthread.GetEnjoyment(actorList[z]) * ActorOrgasmFactor
		z += 1
	EndWhile
	
	; ===== Stage Extension ===== ExtendStageChance
	Messagestr += "\n\n===== Stage Extensions ====="
	Messagestr += "\nExtend Stage Chance: " + linearsceneextendstagechance + "%"
	while z < Actorlist.length
		Messagestr += "\n--" + actorList[z].getdisplayname() 
		int ActorExtendStageChance = (ExtendStageChance(actorList[z]) * 100 ) as int
		if actorList[z] == playerref
			Messagestr += "\n----Player Cannot Extend Stage."
		else
			Messagestr += "\n---Extend Stage Chance : " + ActorExtendStageChance
			if  GetControllingActor() && ActorExtendStageChance > 0
				Messagestr += "\n----"+ actorList[z].getdisplayname() +" is Controlling & Extend Stage chance is "+ ActorExtendStageChance+"%. Extend Scene Might Happen"
			else
				Messagestr += "\n----"+ actorList[z].getdisplayname() +" is Not Controlling or Extend Stage chance is 0%. Extend Scene Wont Happen"
			endif
		endIf
		z += 1
	EndWhile
	
	Messagestr += "\nCounter Rape Chance: " + linearscenecounterrapechance + "%"
	
	while z < Actorlist.length
		Messagestr += "\n--" + actorList[z].getdisplayname() 
		int ActorCounterrapechance = (CounterRapeChance(actorList[z]) * 100) as int
		if actorList[z] == playerref
			Messagestr += "\n----Player Cannot Counter Rape Others."
		else
			Messagestr += "\n----Counter Rape Chance : " + ActorCounterrapechance
			if currentthread.GetSubmissive(playerref)
				Messagestr += "\n----Player is Victim. Counter Rape Wont Happen"
			elseif currentthread.GetSubmissive(actorList[z]) && ActorCounterrapechance > 0
				Messagestr += "\n----"+ actorList[z].getdisplayname() +" is Victim & Counter Rape Chance is " +ActorCounterrapechance +". Counter Rape Might Happen"
			else
				Messagestr += "\n----"+ actorList[z].getdisplayname() +" is Not Victim or Counter Rape Chance is 0. Counter Rape Wont Happen"
			endif
		endIf
		z += 1
	EndWhile
	debug.messagebox(Messagestr)
	messagestr = ""
EndFunction


Function OpenChangeAnimationMenu()
	Int result
	b612_SelectList ChangeAnimationMenu = GetSelectList()
	String[] Menulist = StringUtil.Split("Find Animation by Positions;Find Animation by Name Or Tags;Find Custom Scenes",";")
		
	result = ChangeAnimationMenu.Show(Menulist)
	
	if result == 0
		ShowChangePosition()
	elseif result == 1
		FindAnimationbyNameorTags()
	elseif result == 2
		FindCustomScene()
	endif
endfunction	

Function FindAnimationbyNameorTags()
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
endfunction


Function FindCustomScene()
	string[] CustomSceneList = FindValidCustomScene(true)
	if CustomSceneList.length > 0
		UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
		int z
		while z < CustomSceneList.length
			ListMenu.AddEntryItem(CustomSceneList[z])
		z += 1
		EndWhile

		;open menu
		ListMenu.OpenMenu()	
		
		Int Selected = ListMenu.GetResultInt()
		if Selected >= 0
			CustomSceneTags = papyrusutil.stringsplit(CustomSceneList[Selected] , "|")	
			CustomStageNum = 0
			RunCustomScene = true
			MovetoNextCustomStage()	
		endif	
	else
		announce("No Valid Custom Scenes Found")
	endif
endfunction

Function Announce(String Content , string icon = "icon.dds" ,float delay = 2.0)

	GetAnnouncement().Show(Content,icon, delay)

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


Function FindAnimationWithoutHentairimTags()
	UIListMenu ListMenu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
	string CurrentSceneName = SexlabRegistry.GetSceneName(CurrentSceneID)
	
	string Tags = "-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1BFST,-2BFST,-3BFST,-4BFST,-5BFST,-5AFST,-4AFST,-3AFST,-2AFST,-1AFST,-5BSST,-4BSST,-3BSST,-2BSST,-1BSST,-1ASST,-2ASST,-3ASST,-4ASST,-5ASST,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-1BFHJ,-2BFHJ,-3BFHJ,-4BFHJ,-5BFHJ,-1BSHJ,-2BSHJ,-3BSHJ,-4BSHJ,-5BSHJ,-1BSFJ,-2BSFJ,-3BSFJ,-4BSFJ,-5BSFJ,-1BFTF,-2BFTF,-3BFTF,-4BFTF,-5BFTF,-1BSTF,-2BSTF,-3BSTF,-4BSTF,-5BSTF,-1AFBJ,-2AFBJ,-3AFBJ,-4AFBJ,-5AFBJ,-1ASBJ,-2ASBJ,-3ASBJ,-4ASBJ,-5ASBJ,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP"
	;lookup with playing actors
	string[] SceneIDarr = SexLabRegistry.LookupScenesA( currentthread.GetPositions()  ,Tags,  currentthread.GetSubmissives(), 0, none )
	
	if SceneIDarr.length > 0
		int z
		while z < SceneIDarr.length
			ListMenu.AddEntryItem(SexlabRegistry.GetSceneName(SceneIDarr[z]))
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

Function ShowSchlongAlignmentActorList()
	b612_SelectList Actorlistmenu = GetSelectList()
	b612_QuantitySlider AdjustmentValueSlider = GetQuantitySlider()
	String[] ActorlistNames
	
	int z = 0
	while z < actorlist.Length
			ActorlistNames = papyrusutil.pushstring(ActorlistNames , actorlist[z].getdisplayname())
		z += 1
	endWhile
	
	;Show Actor List
	actor ActortoAdjust
	int position = Actorlistmenu.Show(ActorlistNames)
	if position <= -1
		return
	else
		ActortoAdjust = actorlist[position]
	EndIf
		printdebug("ActortoAdjust Schlong : " + ActortoAdjust.getdisplayname())

		;Actor has Schlong or Strap on. Open UI for value input
		UITextEntryMenu InputBox = UIExtensions.GetMenu("UITextEntryMenu") as UITextEntryMenu
		Inputbox.OpenMenu()
		int AdjustmentValue = Inputbox.GetResultString() as int
		;int AdjustmentValue = AdjustmentValueSlider.show("Adjust Schlong Position",-9,9)
		if AdjustmentValue <= 9 ||  AdjustmentValue >= -9
			printdebug("ActortoAdjust Schlong AdjustmentValue: " + AdjustmentValue)
			Debug.SendAnimationEvent(ActortoAdjust, "SOSBend" + AdjustmentValue as string)
			SaveSchlongAdjustment(currentthread.GetPositionIdx(ActortoAdjust) , AdjustmentValue)
			printdebug("Applied Schlong Adjustments")
		else
			printdebug("Bad Schlong Adjustment Value Input. Value must be between -9 and 9")
			Announce("Bad Schlong Adjustment Value Input. Value must be between -9 and 9")
		endIf

endFunction


Function SaveSchlongAdjustment(int position , int value)
	jsonutil.SetintValue("HentairimDirector/SchlongAdjustment.json",SexlabRegistry.GetSceneName(CurrentSceneID) +"|"+GetLegacyStageNum(currentSceneID,currentStageID)+"|"+position,value)	
	printdebug ("=======================Saved Schlong Adjustments")
endfunction

Function LoadSchlongAdjustment()
	int z
	while z < actorList.Length
		actor ActortoAdjust = actorList[z]
		Int Adjustment = jsonutil.GetIntValue("HentairimDirector/SchlongAdjustment.json",SexlabRegistry.GetSceneName(CurrentSceneID) +"|"+GetLegacyStageNum(currentSceneID,currentStageID)+"|"+z, 0)
		if Adjustment != 0
			Debug.SendAnimationEvent(ActortoAdjust, "SOSBend" + Adjustment as string)
			printdebug("=======================Applying Schlong Adjustment to : " + ActortoAdjust)
		else
			printdebug("=======================No Schlong Adjustments Saved for position " + z)
		endIf
		z += 1
	endwhile		
endfunction

Function ShowAlignmentActorList()
	b612_SelectList Actorlistmenu = GetSelectList()
	;prepare Actorlist Names
	String[] ActorlistNames
	
	int z = 0
	while z < actorlist.Length
		if PositionsToAlign.find(z) >= 0 ; in the arr to align
			ActorlistNames = papyrusutil.pushstring(ActorlistNames , actorlist[z].getdisplayname()+"(Selected)")
		else
			ActorlistNames = papyrusutil.pushstring(ActorlistNames , actorlist[z].getdisplayname()+"(Not Selected)")
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
		RunCustomScene = false ;stop running custom stage
		isPlayingForeplayScene = false ;stop identifying as foreplay
		DoneLinearSceneOrgasm = false; Reset Linear Scene Orgasm
		return true
	else
		printdebug("No Scene Found with Tags : " + Tags)
		WritetoErrorlogs("No Scene Found with Tags : " + Tags)
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



; TriggerUpdate for CF to work around penis reverting from SL PP
function CFTriggerUpdate(actor char)
	; Get the framework script
	CreatureFramework CF = Game.GetFormFromFile(0xD62, "CreatureFramework.esm") as CreatureFramework
	CF.TriggerUpdateForActor(char)
endFunction

Function TriggerUpdateforCreatures()
	int z
	while z < actorlist.length
		if sexlab.GetSex(actorList[z]) > 2
			CFTriggerUpdate(actorList[z])
		endif
	z += 1
	endwhile
	
endfunction

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
	Positionarr = StringUtil.Split("Standing;Kneeling;Laying;Sitting;Doggystyle;Cowgirl;Missionary;Any",";")
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


bool Function PCIsInControl()
	return ActorInControl() != playerref
endfunction

int Function PositionInControl()
	if (CurrentThread.HasSceneTag("Cowgirl") || CurrentThread.HasSceneTag("femdom") || CurrentThread.HasSceneTag("Amazon")) || (IsSuckingoffOther(actorlist[0]) && !CurrentThread.HasSceneTag("Forced"))
		return 0
	else
		return 1
	endif
endfunction

Actor Function ActorInControl()
	if (CurrentThread.HasSceneTag("Cowgirl") || CurrentThread.HasSceneTag("femdom") || CurrentThread.HasSceneTag("Amazon")) || (IsSuckingoffOther(actorlist[0]) && !CurrentThread.HasSceneTag("Forced"))
		return actorlist[0]
	else
		return actorlist[1]
	endif
endfunction

Function ForceOrgasm(actor char)
	int pos
	pos = CurrentThread.getpositionidx(char)
	if pos >= 0
		threadcontroller.ActorAlias[pos].DoOrgasm(true)
	endif
endfunction

Function LinearEndStageForceOrgasm()
    actor[] tmpCummingActorlist = actorList
    int[] orgasmCount
    int[] maleIndexes
    int[] femaleIndexes

    PrintDebug("=== Starting LinearEndStageForceOrgasm ===")

    ;------------------------------------------------
    ; Build orgasmCount and split actors by gender
    ;------------------------------------------------
    int i = 0
    while i < tmpCummingActorlist.Length
        int enjoy = math.ceiling(CurrentThread.GetEnjoyment(tmpCummingActorlist[i]) as float * GetOrgasmFactor(tmpCummingActorlist[i]))
        PrintDebug("Actor " + i + " initial enjoyment: " + enjoy)
		if enjoy < 100
			enjoy = 100
		endif
		bool CanOrgasm = true
		
		if givingforeplayinlinearscenedontorgasm == 1
			CanOrgasm = LinearSceneCanOrgasm(tmpCummingActorlist[i])
		endIf
		
        if SexLab.GetSex(tmpCummingActorlist[i]) == 1 ; Female
            if CanOrgasm
				femaleIndexes = PapyrusUtil.PushInt(femaleIndexes, i)
			endif
        else ; Male
			if CanOrgasm
				maleIndexes = PapyrusUtil.PushInt(maleIndexes, i)
			endif
        endif

        int orgasms = enjoy / 100
        orgasmCount = PapyrusUtil.PushInt(orgasmCount, orgasms)
        PrintDebug("Actor " + i + " initial orgasm count: " + orgasms)
        i += 1
    endwhile

    ;------------------------------------------------
    ; Compute total male orgasms and choose insertion point
    ;  insertionPoint is somewhere in the middle third of total male orgasms.
    ;------------------------------------------------
    int totalMaleOrgasms = 0
    i = 0
    while i < maleIndexes.Length
        totalMaleOrgasms += orgasmCount[maleIndexes[i]]
        i += 1
    endwhile

    ; Ensure we have a sensible insertion range
    int minInsert = Max(1, Math.Ceiling(totalMaleOrgasms / 3.0)) ; at least 1
    int maxInsert = Max(minInsert, Math.Floor((2 * totalMaleOrgasms) / 3.0))
    int insertionPoint = 0
    if totalMaleOrgasms <= 0
        insertionPoint = 0 ; no male orgasms — females get added in fallback below
    else
        insertionPoint = Utility.RandomInt(minInsert, maxInsert)
    endif

    PrintDebug("Total male orgasms: " + totalMaleOrgasms + " | female insertion point: " + insertionPoint)

    ;------------------------------------------------
    ; Start with only males allowed
    ;------------------------------------------------
    int[] allowedIndexes = maleIndexes
    int maleOrgasmsSoFar = 0
    bool keepGoing = True

    while keepGoing
        ; Remove anyone with 0 left from allowedIndexes
        int j = 0
        while j < allowedIndexes.Length
            int idx = allowedIndexes[j]
            if orgasmCount[idx] <= 0
                PrintDebug("Removing actor " + idx + " from pool (no orgasms left)")
                allowedIndexes = PapyrusUtil.RemoveInt(allowedIndexes, idx)
            else
                j += 1
            endif
        endwhile

        int[] available = GetAvailableFromList(orgasmCount, allowedIndexes)
        if available.Length <= 0
            ; If males are done but females still waiting, inject remaining females (fallback)
            if femaleIndexes.Length > 0
                PrintDebug("Male pool exhausted — adding remaining females to allowed pool as fallback")
                int f = 0
                while f < femaleIndexes.Length
                    int fidx = femaleIndexes[f]
                    allowedIndexes = PapyrusUtil.PushInt(allowedIndexes, fidx)
                    f += 1
                endwhile
                ; clear femaleIndexes entirely (they are now in allowed pool)
                int g = 0
                while g < femaleIndexes.Length
                    femaleIndexes = PapyrusUtil.RemoveInt(femaleIndexes, femaleIndexes[g])
                    ; don't increment g because RemoveInt shifts elements
                endwhile
                ; recompute available after adding females
                available = GetAvailableFromList(orgasmCount, allowedIndexes)
                if available.Length <= 0
                    keepGoing = False
                endif
            else
                keepGoing = False
            endif
        else
            ; Choose random starter from current allowed pool
            int starter = available[Utility.RandomInt(0, available.Length - 1)]
            PrintDebug("Starting orgasm chain with actor " + starter)
            maleOrgasmsSoFar += TriggerOrgasmChain(starter, tmpCummingActorlist, orgasmCount, allowedIndexes, maleOrgasmsSoFar)

            ;------------------------------------------------
            ; Female insertion logic:
            ; - Add a female once maleOrgasmsSoFar hits insertionPoint
            ; - If insertionPoint == 0 (no males), fallback handled above
            ;------------------------------------------------
            if insertionPoint > 0 && maleOrgasmsSoFar >= insertionPoint && femaleIndexes.Length > 0
                int addIdx = femaleIndexes[Utility.RandomInt(0, femaleIndexes.Length - 1)]
                allowedIndexes = PapyrusUtil.PushInt(allowedIndexes, addIdx)
                femaleIndexes = PapyrusUtil.RemoveInt(femaleIndexes, addIdx)
                PrintDebug("Inserted female actor " + addIdx + " into allowed pool at male count " + maleOrgasmsSoFar)
            endif
        endif
    endwhile

    PrintDebug("All orgasms done. Final orgasmCount array:")
    i = 0
    while i < orgasmCount.Length
        PrintDebug(" actor " + i + " left: " + orgasmCount[i])
        i += 1
    endwhile
EndFunction


;====================================================
; TriggerOrgasmChain
; - causes actor to orgasm, attempts to start another during wait time,
;   then resumes actor's own next orgasm if any.
; - returns updated maleSoFar count
;====================================================
Int Function TriggerOrgasmChain(int index, Actor[] actors, int[] orgasmCount, Int[] allowedIndexes, int maleSoFar)
    if orgasmCount[index] <= 0
        PrintDebug("Actor " + index + " skipped — no orgasms left")
        return maleSoFar
    endif

    ; Trigger orgasm now
    ForceOrgasm(actors[index])
     ; decrement properly (Papyrus has no -=)
    int remaining = orgasmCount[index] - 1
    orgasmCount[index] = remaining
    PrintDebug("Actor " + index + " orgasmed. Remaining = " + remaining)

    ; if needed, remove from allowed pool
    if remaining <= 0
        allowedIndexes = PapyrusUtil.RemoveInt(allowedIndexes, index)
    endif

    ; If male, increment male counter used for insertion timing
    if SexLab.GetSex(actors[index]) != 1
        maleSoFar += 1
        PrintDebug("maleOrgasmsSoFar -> " + maleSoFar)
    endif

    int waitTime = Utility.RandomInt(1, 3)

    ; During this actor's wait, try to start another random actor (exclude current)
    int[] available = GetAvailableFromList(orgasmCount, allowedIndexes, index)
    if available.Length > 0
        int nextIndex = available[Utility.RandomInt(0, available.Length - 1)]
        PrintDebug("Actor " + nextIndex + " will orgasm during wait of " + waitTime + "s for actor " + index)
        Utility.Wait(Utility.RandomFloat(0.3, waitTime))
        maleSoFar = TriggerOrgasmChain(nextIndex, actors, orgasmCount, allowedIndexes, maleSoFar)
    endif

    ; After wait, resume this actor if they have more orgasms left
    if orgasmCount[index] > 0
        Utility.Wait(waitTime)
        PrintDebug("Actor " + index + " preparing next orgasm after " + waitTime + "s")
        maleSoFar = TriggerOrgasmChain(index, actors, orgasmCount, allowedIndexes, maleSoFar)
    endif

    return maleSoFar
EndFunction


;====================================================
; Helper: returns indexes from groupList that still have orgasms left
; excludeIndex optional: skip one index (e.g., the current orgasmer)
;====================================================
Int[] Function GetAvailableFromList(Int[] orgasmCount, Int[] groupList, Int excludeIndex = -1)
    int[] result
    int i = 0
    while i < groupList.Length
        int idx = groupList[i]
        if orgasmCount[idx] > 0 && idx != excludeIndex
            result = PapyrusUtil.PushInt(result, idx)
        endif
        i += 1
    endwhile
    return result
EndFunction



Bool function isDependencyReady(String modname)
  int index = Game.GetModByName(modname)
  if index == 255 || index == -1
    return false
  else
    return true
  endif
endfunction


Bool function IshugePP(actor char)
  int HugePPSchlongSize
	HugePPSchlongSize = JsonUtil.GetIntValue(ControlConfigFile, "soshugeppsize" ,6)
  Race charRace = char.GetRace()
  String charraceName = charRace.GetName()
  if stringutil.find(charraceName, "Brute") > -1 || stringutil.find(charraceName, "Spider") > -1 || stringutil.find(charraceName, "Lurker") > -1 || stringutil.find(charraceName, "Daedroth") > -1 || stringutil.find(charraceName, "Horse") > -1 || stringutil.find(charraceName, "Bear") > -1 || stringutil.find(charraceName, "Chaurus") > -1 || stringutil.find(charraceName, "Dragon") > -1 || charraceName == "Frost Atronach" || stringutil.find(charraceName, "Giant") > -1 || charraceName == "Mammoth" || charraceName == "Sabre Cat" || stringutil.find(charraceName, "Troll") > -1 || charraceName == "Werewolf" || stringutil.find(charraceName, "Gargoyle") > -1 || charraceName == "Dwarven Centurion" || stringutil.find(charraceName, "Ogre") > -1 || charraceName == "Ogrim" || charraceName == "Nest Ant Flier" || stringutil.find(charraceName, "OGrim") > -1
    return True
  else
    ;if Schlong is big
    if (SchlongFaction)
      return char.GetFactionRank(SchlongFaction) >= HugePPSchlongSize
    elseif (TNG_XL)
      ;keywords can explicitly overwrite value
      int TNG_Size = TNG_PapyrusUtil.GetActorSize(char)
      bool tngxl = char.HasKeyword(TNG_XL)
      bool tngl = char.HasKeyword(TNG_L)
      bool isBig = tngxl || TNG_Size >= HugePPSchlongSize || tngl

      ;miscutil.PrintConsole ("DEBUG : current TNG_XL : " + tngxl)
      ;miscutil.PrintConsole ("DEBUG : current TNG_PapyrusUtil.GetActorSize : " + TNG_Size)
      ;miscutil.PrintConsole ("DEBUG : current TNG_L : " + tngl)
      ;miscutil.PrintConsole ("DEBUG : current isBig : " + isBig)
      return isBig
    endif
    return false
  endif
EndFunction

Bool Function ScenehasCreatures()
	return sexlab.CountCreatures(actorList) > 0
endfunction

Bool Function isLinearScene()
	return uselinearscene == 1 || storageutil.Getintvalue(none,"HentairimNextUseLinearScene",0) == 1
endfunction

Bool Function DoneLinearSceneOrgasm()
	return DoneLinearSceneOrgasm
Endfunction

Float Function GetOrgasmFactor(actor char)
	
	string charname = char.getdisplayname()
	
	int z 
	while z < linearscenefinalstageorgasmfactor.length
		string[] item = stringutil.split(linearscenefinalstageorgasmfactor[z],"|")
		;check if display name contains the keyword
		printdebug(" Orgasm Factor items : " + item)
		if stringutil.find( charname, item[0]) > -1
			;display name match keyword. Get Orgasm Factor
			Float Factor = item[1] as float
			printdebug("Orgasm Factor :" + Factor)
			return Factor
		endif
		z += 1
	endWhile
	return 1
endFunction

actor function FindFirstActorwithPenisPosition()
	int z
	while z == actorlist.length
		if sexlab.getsex(actorList[z]) != 1 ;not female
			return actorList[z]
		endif
	z += 1
	endwhile
	
	return none
EndFunction

Actor function GetControllingActor()
	if currentthread.HasSceneTag("cowgirl") || currentthread.HasSceneTag("amazon") || currentthread.HasSceneTag("femdom")
		return actorlist[0]
	elseif currentthread.HasSceneTag("lesbian")
		return actorlist[1]
	else
		return FindFirstActorwithPenisPosition()
	endif
EndFunction

bool Function ExtendScene()
	;check if can Extend Scene
	string tags
	Actor ActorWhoisControlling 
	if currentthread.HasSceneTag("cowgirl") || currentthread.HasSceneTag("amazon") || currentthread.HasSceneTag("femdom")
		ActorWhoisControlling = actorlist[0]
		;femdom scene extend to femdom scene
		tags = "~1ASCG,~2ASCG,~3ASCG,~4ASCG,~5ASCG,~6ASCG,~1AFCG,~2AFCG,~3AFCG,~4AFCG,~5AFCG"
	elseif currentthread.HasSceneTag("lesbian")
		ActorWhoisControlling = actorlist[1]
		tags = "lesbian"
	else
		ActorWhoiscontrolling = FindFirstActorwithPenisPosition()
		
		if currentthread.HasSceneTag("aggressive")
			; non femdom scene extend to non femdom scene
			tags = "aggressive,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-6ASCG,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG"
		else
			tags = "-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-6ASCG,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG"
		endif
	endIf
	if ActorWhoisControlling == None
		return false
	endif
	bool result
	if utility.randomfloat(0,1) < ExtendStageChance(ActorWhoiscontrolling)
		
		result = TeleportToRandomStageWithTags(tags, StartFromStage = 2)
		if result
			StorageUtil.SetIntValue(None, "HentairimExtendScene", 1)
		endif
	
	endif
	return result
endfunction

Float Function ExtendStageChance(actor char)

	if char == PlayerRef || char.isplayerteammate()
		return 0
	EndIf
	string charname = char.getdisplayname()
	int z 
	while z < linearsceneextendstagechance.length
		string[] item = stringutil.split(linearsceneextendstagechance[z],"|")
		;check if display name contains the keyword
		printdebug(" Extend Stage Chance items : " + item)
		if stringutil.find( charname, item[0]) > -1
			;display name match keyword. Get Extend Stage Chance
			Float Chance = item[1] as float / 100
			printdebug("Extend Stage Chance :" + Chance)
			return Chance
		endif
		z += 1
	endWhile
	return 0
endFunction

bool Function CounterRape()		
	
	string tags
	string hentairimtagwithoutstage
	actor[] Submissives = CurrentThread.GetSubmissives()
	int SubmissivePos = CurrentThread.getpositionidx(Submissives[0])
	int SubmissiveSex = sexlab.getsex(Submissives[0])
	if utility.randomfloat(0,1) < CounterRapeChance(Submissives[0])
		if SubmissivePos == 0 && SubmissiveSex == 1;pos 0 female submissive
			tags = "~femdom,~cowgirl,~amazon"
		elseif SubmissivePos > 0 && SubmissiveSex != 1  ;victim has penis
			if SubmissiveSex > 2 ;creature
				tags = "-2ASCG,-3ASCG,-4ASCG,-5ASCG,-6ASCG,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG"
			else
				tags = "aggressive,~vaginal,~anal"
			endIf
		endif
	;flip all actor submissive Status
	int z 
		while z <= actorList.length
			if CurrentThread.GetSubmissive(actorList[z]) ;is submissive
				CurrentThread.SetIsSubmissive(actorList[z], false)
				printdebug("Counter Rape! :" + actorList[z].getdisplayname() + " Flipped to Aggressor")
			else
				CurrentThread.SetIsSubmissive(actorList[z], true)
				printdebug("Counter Rape! :" + actorList[z].getdisplayname() + " Flipped to Victim")
			endif
			z += 1
		endwhile
		
		bool result = TeleportToRandomStageWithTags(tags , StartFromStage = 2) 
		storageutil.Setintvalue(None,"HentairimExtendScene",1)
		if result
			return true
		else
			return false
		endif
	else
		return false
	endif
endfunction

Float Function CounterRapeChance(actor char)
	string charname = char.getdisplayname() || char.isplayerteammate()
	if char == PlayerRef
		return 0
	EndIf
	int z 
	while z < linearscenecounterrapechance.length
		string[] item = stringutil.split(linearscenecounterrapechance[z],"|")
		;check if display name contains the keyword
		printdebug(" Counter Rape Chance items : " + item)
		if stringutil.find( charname, item[0]) > -1
			;display name match keyword. Get Counter Rape Chance
			Float Chance = item[1] as float / 100
			printdebug("Counter Rape Chance :" + Chance)
			return Chance
		endif
		z += 1
	endWhile
	return 0
endFunction

Function DisableScene(string Sceneid)
	;for disabling the scene in library
		SexlabRegistry.SetSceneEnabled(Sceneid,false)
		Announce("Scene Disabled")

endfunction

Int Function Max(Int a, Int b)
    If a > b
        return a
    Else
        return b
    EndIf
EndFunction

bool Function StartForeplayScene()

	int totalWeight = foreplayhandjobweight + foreplaytitfuckweight + foreplayfootjobweight + foreplayblowjobweight
	if totalWeight <= 0 && !currentthread.HasSceneTag("Vaginal") && !currentthread.HasSceneTag("anal") && !currentthread.HasSceneTag("fisting")
		return false
	endif
	;Tags = "-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP,"
	int roll = Utility.RandomInt(0, totalWeight - 1)

	string HandjobTags = "~1CSHJ,~2CSHJ,~3CSHJ,~4CSHJ,~1CFHJ,~2CFHJ,~3CFHJ,~4CFHJ,~1BSHJ,~2BSHJ,~3BSHJ,~4BSHJ,~1BFHJ,~2BFHJ,~3BFHJ,~4BFHJ,-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP,-vaginal,-anal"
	string TitFuckTags = "~1CSTF,~2CSTF,~3CSTF,~4CSTF,~1CFTF,~2CFTF,~3CFTF,~4CFTF,~1BSTF,~2BSTF,~3BSTF,~4BSTF,~1BFTF,~2BFTF,~3BFTF,~4BFTF,-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP,-vaginal,-anal"
	string FootJobTags = "~1CSFJ,~2CSFJ,~3CSFJ,~4CSFJ,~1CFFJ,~2CFFJ,~3CFFJ,~4CFFJ,~1BSFJ,~2BSFJ,~3BSFJ,~4BSFJ,~1BFFJ,~2BFFJ,~3BFFJ,~4BFFJ,-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP,-vaginal,-anal"
	string BlowjobTags = "~1BSBJ,~2BSBJ,~3BSBJ,~4BSBJ,~1BFBJ,~2BFBJ,~3BFBJ,~4BFBJ,~1ASBJ,~2ASBJ,~3ASBJ,~4ASBJ,~1AFBJ,~2AFBJ,~3AFBJ,~4AFBJ,-5AFAC,-4AFAC,-3AFAC,-2AFAC,-1AFAC,-5ASAC,-4ASAC,-3ASAC,-2ASAC,-1ASAC,-1AFAP,-2AFAP,-3AFAP,-4AFAP,-5AFAP,-1ASAP,-2ASAP,-3ASAP,-4ASAP,-5ASAP,-1AFCG,-2AFCG,-3AFCG,-4AFCG,-5AFCG,-6AFCG,-7AFCG,-1ASCG,-2ASCG,-3ASCG,-4ASCG,-5ASCG,-2ASVP,-3ASVP,-4ASVP,-5ASVP,-6ASVP,-7ASVP,-8ASVP,-2AFVP,-3AFVP,-4AFVP,-5AFVP,-6AFVP,-7AFVP,-8AFVP,-1ASDP,-2ASDP,-3ASDP,-4ASDP,-5ASDP,-2AFDP,-3AFDP,-4AFDP,-5AFDP,-6AFDP,-7AFDP,-vaginal,-anal"

	string SelectedTags
	if roll < foreplayhandjobweight
		SelectedTags = HandjobTags
	elseif roll < (foreplayhandjobweight + foreplaytitfuckweight)
		SelectedTags = TitFuckTags
	elseif roll < (foreplayhandjobweight + foreplaytitfuckweight + foreplayfootjobweight)
		SelectedTags = FootJobTags
	else
		SelectedTags = BlowjobTags
	endif

	bool result
	OriginalSceneID = CurrentSceneID
	printdebug("foreplay SelectedTags : " + SelectedTags)
	result = TeleportToRandomStageWithTags(SelectedTags, 1)
	printdebug("foreplay teleport : " + result)
	if result
		isPlayingForeplayScene = true
	else
		isPlayingForeplayScene = false
		OriginalSceneID = ""
	endif

	return result
endFunction

bool function isPlayingForeplayScene()
	return isPlayingForeplayScene
endfunction

;------------------------------Director's Tools END------------------------


	
;/
;future task
;find and implement diffent cum noise. light medium heavy, very heavy
;Enable Sexlab Voice and See how it goes
;Add Schlong Adjustment
;Penetration happened gape sound with IVDT before foreplay change
;orgasm play too many times
;if foreplay and play stage transition, its as if player is started fucking extended.

>added new option to find and play custom stage from Stagemaker from Director Tools
>Moved all changing animations options into one menu tree
>Fix conditions for SFX not playing for Creatures.
>Some Optimizations
>Added New Linear Scene option
>Added Foreplay control
>add identification for actors who can counter rape or extend scene
>Combat Rape Option for Short Rape
>added Cosplay Basic and Gala armor to armorswapping
>Expressions Tongue usage conditions to check only once per stage
>Enabling IVDT will Mute Player in Sexlab
>Add Schlong Adjustments Function

known issues
if close swf menu with N, scene ends prematurely at the last scene. not sure if it only happens to me, but keep the menu initialized.
/; 