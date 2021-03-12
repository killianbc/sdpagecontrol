#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:   Killian Becet
 Mail : killian@becet.net

 Script Function: send Stream Deck page to companion

 MAJ : 12/03/2020
 V1.0

#ce ----------------------------------------------------------------------------



#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <Misc.au3>

Global Const $udpPort = 51235 ; Companion UDP Port
   OnAutoItExitRegister("OnAutoItExit")

sdpagectrl()

Func sdpagectrl()
	UDPStartup()

	Global $title = "Stream Deck page control"
	Global $enable = RegRead("HKEY_CURRENT_USER\SOFTWARE\sdpagectrl", "enable")
	Global $setpage = ""
	Global $idSd = RegRead("HKEY_CURRENT_USER\SOFTWARE\sdpagectrl", "sdserial")
	Global $sIPAddress = RegRead("HKEY_CURRENT_USER\SOFTWARE\sdpagectrl", "companionip")
	
	If $enable == "" Then
		$enable = False
	EndIf

	If $sIPAddress == "" Then
		$sIPAddress = "127.0.0.1"
	EndIf


	If $CmdLine[0] > 0 Then
		If $enable = 1 Then
			$setpage = $CmdLine[1]
			CMDcompanion()
		EndIf
	Else
		guiEdit()
	EndIf

EndFunc


Func guiEdit()
   	Local $hGui = GUICreate($title, 350, 150, 100, 200, $WS_SIZEBOX + $WS_SYSMENU)
	  	GUISetState(@SW_SHOW)
    
		Local $pageSetLabel= GUICtrlCreateLabel("Page", 15, 10)
		Local $pageSetEditBox = GUICtrlCreateInput("", 120, 10,120,20)
		Local $pageSetSet = GUICtrlCreateButton("Set", 260, 10, 50, 20)

		Local $ipLabel= GUICtrlCreateLabel("IP address", 15, 40)
		Local $ipEditBox = GUICtrlCreateInput($sIPAddress, 120, 40,120,20)
		Local $ipSet = GUICtrlCreateButton("Set", 260, 40, 50, 20)

		Local $idSdLabel= GUICtrlCreateLabel("Serial Stream Deck", 15, 70)
		Local $idSdEditBox = GUICtrlCreateInput($idSd, 120, 70,120,20)
		Local $idSdSet = GUICtrlCreateButton("Set", 260, 70, 50, 20)

		Local $enableLabel= GUICtrlCreateLabel("Enable", 15, 100)
		Local $enableCheckbox = GUICtrlCreateCheckbox("", 120, 95, 185, 25)
		GUICtrlSetState($enableCheckbox, $enable)



	Local $idMsg = GUIGetMsg()

	While 1
		If $idMsg=$GUI_EVENT_CLOSE Then
        		 Exit
        EndIf
        If $idMsg=$pageSetSet or $idMsg=$pageSetEditBox Then
        		$setpage = GUICtrlRead($pageSetEditBox)
        		CMDcompanion()
        		$setpage = ""
				GUICtrlSetData($pageSetEditBox, $setpage)
		EndIf

        IF $idMsg=$ipSet or $idMsg=$ipEditBox Then
				RegWrite("HKEY_CURRENT_USER\SOFTWARE\sdpagectrl", "companionip", "REG_SZ", GUICtrlRead($ipEditBox))
				MsgBox($MB_SYSTEMMODAL, $title, "The new ip is saved", 2)
        EndIf

        If $idMsg=$idSdSet or $idMsg=$idSdEditBox Then
        		RegWrite("HKEY_CURRENT_USER\SOFTWARE\sdpagectrl", "sdserial", "REG_SZ", GUICtrlRead($idSdEditBox))
        		MsgBox($MB_SYSTEMMODAL, $title, "The new serial is saved", 2)
        EndIf

           If $idMsg=$enableCheckbox Then
        		RegWrite("HKEY_CURRENT_USER\SOFTWARE\sdpagectrl", "enable", "REG_SZ", GUICtrlRead($enableCheckbox))
        EndIf

 		$idMsg = GUIGetMsg()
   	WEnd
EndFunc

Func CMDcompanion()
   If $setpage >= 1 And $setpage <= 99 Then
	Local $msgCompanion = "PAGE-SET "&$setpage&" "&$idSd
    Local $iSocket = UDPOpen($sIPAddress, $udpPort)
    UDPSend($iSocket, StringToBinary($msgCompanion))
    UDPCloseSocket($iSocket)
   Else
	  MsgBox($MB_SYSTEMMODAL, "Error", "Stream Deck page out of range", 10)
   EndIf
 EndFunc ;==>CMDcompanion


Func OnAutoItExit()
    UDPShutdown() ; Close the UDP service.

EndFunc   ;==>OnAutoItExit

Func CLOSEButton()
   Exit
EndFunc   ;==>CLOSEButton