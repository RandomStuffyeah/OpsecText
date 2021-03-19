#SingleInstance off
#NoTrayIcon
; Create the sub-menus
Menu, FileMenu, Add, &New, FileNew
Menu, FileMenu, Add, &Open, FileOpen
Menu, FileMenu, Add, &Save, FileSave
Menu, FileMenu, Add, Save &As, FileSaveAs
Menu, FileMenu, Add  ; Separator line.
Menu, FileMenu, Add, E&xit, FileExit
Menu, HelpMenu, Add, &About, HelpAbout
Menu, HelpMenu, Add, &License, HelpLicense
Menu, MiscMenu, Add, &GitHub Repo, MiscSource
Menu, MiscMenu, Add, &Input License Key, MiscKey
Menu, MiscMenu, Add, Activate, MiscActivate
Menu, MiscMenu, Add, &Open Welcome file, MiscWelcome

; Attach the menu bar
Menu, menu, Add, &File, :FileMenu
Menu, menu, Add, &Help, :HelpMenu
Menu, menu, Add, &Misc, :MiscMenu

; Attach menu bar to window
Gui, Menu, menu

; Create GUI + window
Gui, +Resize  ; Make the window resizable.
Gui, Add, Edit, vMainEdit WantTab W600 R20
Gui, Show,, Zdrmonster World
CurrentFileName := ""  ; Indicate that there is no current file.
return

FileNew:
GuiControl,, MainEdit  ; Clear the Edit control.
return

FileOpen:
Gui +OwnDialogs  ; Force user to dismiss save dialog
FileSelectFile, SelectedFileName, 3,, Open File, Text Documents (*.txt)
if not SelectedFileName  ; No file selected.
    return
Gosub FileRead
return

FileRead:  ; Caller has set the variable SelectedFileName for us.
FileRead, MainEdit, %SelectedFileName%  ; Read file contents from variable
if ErrorLevel
{
    MsgBox Error encountered while trying to open %SelectedFileName%.
    return
}
GuiControl,, MainEdit, %MainEdit%  ; Put the text into the control.
CurrentFileName := SelectedFileName
Gui, Show,, %CurrentFileName% - Zdrmonster World   ; Show file name in title bar.
return

FileSave:
if not CurrentFileName   ; No filename selected yet, so do Save-As instead.
    Goto FileSaveAs
Gosub SaveCurrentFile
return

FileSaveAs:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, S16,, Save File, Text Documents (*.txt)
if not SelectedFileName  ; No file selected.
    return
CurrentFileName := SelectedFileName
Gosub SaveCurrentFile
return

SaveCurrentFile:  ; Caller has ensured that CurrentFileName is not blank.
if FileExist(CurrentFileName)
{
    FileDelete %CurrentFileName%
    if ErrorLevel
    {
        MsgBox Error encountered while trying to overwrite %CurrentFileName%.
        return
    }
}
GuiControlGet, MainEdit  ; Retrieve the contents of the Edit control.
FileAppend, %MainEdit%, %CurrentFileName%  ; Save the contents to the file.
; Upon success, Show file name in title bar (in case we were called by FileSaveAs):
Gui, Show,, %CurrentFileName%
return

HelpAbout:
Gui, About:+owner1  ; Make the main window (Gui #1) the owner of the "about box".
Gui +Disabled  ; Disable main window.
Gui, About:Add, Text,, Zdrmonster World
Gui, About:Add, Text,, Version 3.0
Gui, About:Add, Text,, This program is free software under the GNU General Public License, You can modify and redistribute the source code.
Gui, About:Add, Button, Default, OK
Gui, About:Show
return

AboutButtonOK:  ; This section is used by the "about box" above.
AboutGuiClose:
AboutGuiEscape:
Gui, 1:-Disabled  ; Re-enable the main window.
Gui Destroy  ; Destroy the about box.
return

HelpLicense:
Run, license.txt
return

GuiDropFiles:  ; Support drag & drop.
Loop, Parse, A_GuiEvent, `n
{
    SelectedFileName := A_LoopField  ; Get the first file only (in case there's more than one).
    break
}
Gosub FileRead
return

GuiSize:
; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
NewWidth := A_GuiWidth - 21
NewHeight := A_GuiHeight - 21
GuiControl, Move, MainEdit, W%NewWidth% H%NewHeight%
return

FileExit:     ; User chose "Exit" from the File menu.
GuiClose:  ; User closed the window.
ExitApp

MiscSource:
Run, https://github.com/RandomStuffyeah/OpsecText
return

MiscKey:
GuiControl,, MainEdit, Enter anything below this and we'll activate for you:  ; Put the text into the control.
Gui, Show,, Zdrmonster World   ; Show file name in title bar.
return

MiscActivate:
MsgBox We forgot to activate, we sent your info to Microshaft!
return

MiscWelcome:
GuiControl,, MainEdit, Zdrmonster World is the best Microsoft Word bootleg, It is written in AutoHotkey and is licensed under the GNU General Public License, See Help > License for more information.  ; Put the text into the control.
Gui, Show,, Zdrmonster World   ; Show file name in title bar.
