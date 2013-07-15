Dim fso, winShell, MyTarget, MySource, MyLove, file
Set fso = CreateObject("Scripting.FileSystemObject")
Set winShell = createObject("shell.application")

MySource = fso.GetAbsolutePathName(WScript.Arguments.Item(0))
MyTarget = fso.GetAbsolutePathName(WScript.Arguments.Item(1))

MyTarget = MyTarget & ".zip"
MyLove = Mid(MyTarget, 1, InStrRev(MyTarget, ".")) & "love"

If (fso.FileExists(MyTarget)) Then
   fso.DeleteFile(MyTarget)
End If

Set file = fso.CreateTextFile(MyTarget, True)
file.write("PK" & chr(5) & chr(6) & string(18,chr(0)))
file.close

winShell.NameSpace(MyTarget).CopyHere winShell.NameSpace(MySource).Items

do until winShell.namespace(MyTarget).items.count = winShell.namespace(MySource).items.count
    wscript.sleep 1000 
loop

If (fso.FileExists(MyLove)) Then
   fso.DeleteFile(MyLove)
End If

fso.MoveFile MyTarget, MyLove

Set winShell = Nothing
Set fso = Nothing