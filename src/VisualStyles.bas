Attribute VB_Name = "VisualStyles"
Option Explicit

'Menu Icons loader' by Alex Dragokas, 2017

Private Const MF_BYPOSITION = &H400&
Private Const MIIM_ID = &H2
Private Const MIIM_TYPE = &H10
Private Const MFT_STRING = &H0&
Private Const MIIM_STRING = &H40&

Private Type MENU_POSITION
    hMenu As Long
    lPosition As Long
End Type

Private Type MENUITEMINFOW
    cbSize          As Long
    fMask           As Long
    fType           As Long
    fState          As Long
    wID             As Long
    hSubMenu        As Long
    hbmpChecked     As Long
    hbmpUnchecked   As Long
    dwItemData      As Long
    dwTypeData      As Long
    cch             As Long
    hbmpItem        As Long
End Type

Private Declare Function GetMenu Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function GetSubMenu Lib "user32" (ByVal hMenu As Long, ByVal nPos As Long) As Long
Private Declare Function SetMenuItemBitmaps Lib "user32" (ByVal hMenu As Long, ByVal nPosition As Long, ByVal wFlags As Long, ByVal hBitmapUnchecked As Long, ByVal hBitmapChecked As Long) As Long
Private Declare Function GetMenuItemID Lib "user32" (ByVal hMenu As Long, ByVal nPos As Long) As Long
Private Declare Function GetMenuItemCount Lib "user32" (ByVal hMenu As Long) As Long
Private Declare Function GetMenuItemInfo Lib "user32" Alias "GetMenuItemInfoW" (ByVal hMenu As Long, ByVal uItem As Long, ByVal fByPosition As Long, lpmii As MENUITEMINFOW) As Long

Public Function MenuReleaseIcons()
    SetMenuIconByName 0, "", Nothing, True 'free objects
End Function

Public Function SetMenuIconByName(WndHandle As Long, sMenuName As String, objBitmap As StdPicture, Optional bFreeMemory As Boolean) As Boolean
    On Error GoTo ErrorHandler
    
    Dim mp As MENU_POSITION
    Dim i As Long
    
    Static oBitmap()    As StdPicture
    Static IsInit       As Boolean
    
    If bFreeMemory Then
        If IsInit Then
            For i = 0 To UBound(oBitmap)
                Set oBitmap(i) = Nothing
            Next
        End If
        Exit Function
    End If
    
    If Not IsInit Then
        IsInit = True
        ReDim oBitmap(0)
    Else
        ReDim Preserve oBitmap(UBound(oBitmap) + 1)
    End If
    
    mp = FindMenuByName(WndHandle, sMenuName)
    
    If mp.hMenu <> 0 Then
        Set oBitmap(UBound(oBitmap)) = objBitmap 'cache object
        
        SetMenuIconByName = SetMenuItemBitmaps(mp.hMenu, mp.lPosition, MF_BYPOSITION, oBitmap(UBound(oBitmap)), oBitmap(UBound(oBitmap)))
    End If
    
    Exit Function
ErrorHandler:
    ErrorMsg Err, "SetMenuIconByName"
    If inIDE Then Stop: Resume Next
End Function

Private Function FindMenuByName(WndHandle As Long, sMenuName As String) As MENU_POSITION
    Dim hRootMenu As Long
    
    hRootMenu = GetMenu(WndHandle)
    
    If hRootMenu <> 0 Then FindMenuByName = FindSubMenu(hRootMenu, sMenuName)
End Function

Private Function FindSubMenu(hMenu As Long, sMenuName As String) As MENU_POSITION
    On Error GoTo ErrorHandler
    
    Dim cntSubMenu1 As Long
    Dim cntSubMenu2 As Long
    Dim hSubMenu As Long
    Dim sCaption As String
    Dim i As Long
    Dim j As Long
    
    cntSubMenu1 = GetMenuItemCount(hMenu)
    
    If cntSubMenu1 <> 0 Then
        For i = 0 To cntSubMenu1 - 1
            
            hSubMenu = GetSubMenu(hMenu, i)
            
            If hSubMenu <> 0 Then
            
                cntSubMenu2 = GetMenuItemCount(hSubMenu)
                
                If cntSubMenu2 <> 0 Then
                
                    For j = 0 To cntSubMenu2 - 1
                
                        sCaption = GetMenuText(hSubMenu, j)
                        
                        If StrComp(sMenuName, sCaption, vbTextCompare) = 0 Then
                            FindSubMenu.hMenu = hSubMenu
                            FindSubMenu.lPosition = j
                            Exit Function
                        End If
                    Next
                End If
                
                FindSubMenu = FindSubMenu(hSubMenu, sMenuName) 'recursive
                
                If FindSubMenu.hMenu <> 0 Then Exit Function
            End If
        Next
    End If
    
    Exit Function
ErrorHandler:
    ErrorMsg Err, "FindSubMenu"
    If inIDE Then Stop: Resume Next
End Function

Private Function GetMenuText(hMenu As Long, nPosition As Long) As String
    On Error GoTo ErrorHandler
    
    Dim mii As MENUITEMINFOW
    Dim sBuf As String

    With mii
        .cbSize = Len(mii)
        .dwTypeData = 0
        .fMask = MIIM_STRING
        .fType = MFT_STRING
    End With
                
    If GetMenuItemInfo(hMenu, nPosition, MF_BYPOSITION, mii) Then
                        
        With mii
            sBuf = String$(.cch + 1, 0)
            .dwTypeData = StrPtr(sBuf)
            .cch = .cch + 1
        End With
        
        If GetMenuItemInfo(hMenu, nPosition, MF_BYPOSITION, mii) Then
            GetMenuText = Left$(sBuf, mii.cch)
        End If
    End If
    
    Exit Function
ErrorHandler:
    ErrorMsg Err, "GetMenuText"
    If inIDE Then Stop: Resume Next
End Function

Public Sub SetMenuIcons(WndHandle As Long)
    On Error GoTo ErrorHandler:
    
    SetMenuIconByName WndHandle, Translate(1212), LoadResPicture("ADSSPY", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1202), LoadResPicture("CROSS_RED", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1208), LoadResPicture("CROSS_BLACK", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1209), LoadResPicture("CROSS_BLACK", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1210), LoadResPicture("CROSS_BLACK", vbResBitmap)
'    SetMenuIconByName WndHandle, Translate(1226), LoadResPicture("GLOBE", vbResBitmap)
'    SetMenuIconByName WndHandle, Translate(1233), LoadResPicture("GLOBE", vbResBitmap)
'    SetMenuIconByName WndHandle, Translate(1234), LoadResPicture("GLOBE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1206), LoadResPicture("HOSTS", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1226), LoadResPicture("IE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1233), LoadResPicture("IE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1234), LoadResPicture("IE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1211), LoadResPicture("KEY", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1205), LoadResPicture("PROCMAN", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1201), LoadResPicture("SETTINGS", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1213), LoadResPicture("SIGNATURE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1232), LoadResPicture("STARTUPLIST", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1214), LoadResPicture("UNINSTALLER", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1235), LoadResPicture("INSTALL", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1224), LoadResPicture("UPDATE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1237), LoadResPicture("IE", vbResBitmap)
    SetMenuIconByName WndHandle, Translate(1238), LoadResPicture("IE", vbResBitmap)
    
    Exit Sub
ErrorHandler:
    ErrorMsg Err, "SetMenuIcons"
    If inIDE Then Stop: Resume Next
End Sub
