' ================================================================================
' E&N TAX TRACKER - USER INTERFACE
' Module: Buttons, forms, and user interaction
' ================================================================================

Option Explicit

Public Sub AddRecurringExpenseButton()
    ' Add the Generate Recurring Expenses button to the Dashboard
    
    Dim ws As Worksheet
    Dim btn As Object
    
    Set ws = GetWorksheet("Dashboard")
    If ws Is Nothing Then
        Set ws = GetWorksheet("Executive Dashboard")
    End If
    If ws Is Nothing Then Exit Sub
    
    ' Remove existing button if it exists
    On Error Resume Next
    ws.Shapes("btnGenerateRecurring").Delete
    On Error GoTo 0
    
    ' Add new button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, 100, 200, 40)
    
    With btn
        .Name = "btnGenerateRecurring"
        .TextFrame.Characters.Text = "Generate Recurring Expenses"
        .TextFrame.Characters.Font.Size = 10
        .TextFrame.Characters.Font.Bold = True
        .Fill.ForeColor.RGB = RGB(68, 114, 196)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "GenerateRecurringExpenses"
    End With
    
    ' Add validation button
    On Error Resume Next
    ws.Shapes("btnValidateData").Delete
    On Error GoTo 0
    
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 220, 100, 180, 40)
    
    With btn
        .Name = "btnValidateData"
        .TextFrame.Characters.Text = "Validate Setup Data"
        .TextFrame.Characters.Font.Size = 10
        .TextFrame.Characters.Font.Bold = True
        .Fill.ForeColor.RGB = RGB(46, 125, 50)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "ValidateRecurringDataStructure"
    End With
    
    MsgBox "Recurring Expenses buttons added to Dashboard!", vbInformation
End Sub

Public Sub ShowRecurringExpenseReport()
    ' Display a summary report of recurring expenses
    
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim activeCount As Integer
    Dim inactiveCount As Integer
    Dim totalMonthly As Double
    Dim totalAnnual As Double
    Dim reportText As String
    
    Set ws = GetWorksheet("Recurring Setup")
    If ws Is Nothing Then
        MsgBox "Recurring Setup worksheet not found.", vbExclamation
        Exit Sub
    End If
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' Analyze recurring expenses
    For i = 2 To lastRow
        If UCase(ws.Cells(i, "H").Value) = "ACTIVE" Then
            activeCount = activeCount + 1
            Dim amountText As String
            amountText = Replace(Replace(ws.Cells(i, "E").Value, "$", ""), ",", "")
            If IsNumeric(amountText) Then
                totalMonthly = totalMonthly + CDbl(amountText)
            End If
        Else
            inactiveCount = inactiveCount + 1
        End If
    Next i
    
    totalAnnual = totalMonthly * 12
    
    ' Build report
    reportText = "RECURRING EXPENSE SUMMARY" & vbCrLf & _
                "================================" & vbCrLf & vbCrLf & _
                "Active Recurring Expenses: " & activeCount & vbCrLf & _
                "Inactive Recurring Expenses: " & inactiveCount & vbCrLf & vbCrLf & _
                "Estimated Monthly Total: " & Format(totalMonthly, "$#,##0.00") & vbCrLf & _
                "Estimated Annual Total: " & Format(totalAnnual, "$#,##0.00") & vbCrLf & vbCrLf & _
                "Note: Amounts shown are approximate based on" & vbCrLf & _
                "setup data and may vary with actual generation."
    
    MsgBox reportText, vbInformation, "E&N Tax Tracker - Recurring Expenses"
End Sub

Public Sub AddRecurringMenuButtons()
    ' Add a comprehensive menu of recurring expense functions
    
    Dim ws As Worksheet
    Dim btn As Object
    Dim buttonY As Long
    
    Set ws = GetWorksheet("Recurring Setup")
    If ws Is Nothing Then Exit Sub
    
    buttonY = 10
    
    ' Clear existing buttons
    On Error Resume Next
    ws.Shapes("btnSetupRecurring").Delete
    ws.Shapes("btnValidateSetup").Delete
    ws.Shapes("btnGenerateExpenses").Delete
    ws.Shapes("btnShowReport").Delete
    ws.Shapes("btnQuickFix").Delete
    On Error GoTo 0
    
    ' Setup Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnSetupRecurring"
        .TextFrame.Characters.Text = "Setup System"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(68, 114, 196)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "SetupRecurringExpenses"
    End With
    
    buttonY = buttonY + 40
    
    ' Validate Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnValidateSetup"
        .TextFrame.Characters.Text = "Validate Data"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(46, 125, 50)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "ValidateRecurringDataStructure"
    End With
    
    buttonY = buttonY + 40
    
    ' Generate Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnGenerateExpenses"
        .TextFrame.Characters.Text = "Generate Expenses"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(255, 87, 34)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "GenerateRecurringExpenses"
    End With
    
    buttonY = buttonY + 40
    
    ' Report Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnShowReport"
        .TextFrame.Characters.Text = "Show Report"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(156, 39, 176)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "ShowRecurringExpenseReport"
    End With
    
    buttonY = buttonY + 40
    
    ' Quick Fix Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnQuickFix"
        .TextFrame.Characters.Text = "Quick Fix Data"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(255, 193, 7)
        .TextFrame.Characters.Font.Color = RGB(0, 0, 0)
        .OnAction = "QuickFixRecurringData"
    End With
    
    MsgBox "Recurring expense menu buttons added!", vbInformation
End Sub

Public Sub ShowProgressForm(message As String, percent As Integer)
    ' Show progress to user during long operations
    
    Application.StatusBar = message & " (" & percent & "% complete)"
    DoEvents
End Sub

Public Sub HideProgressForm()
    ' Hide progress indicators
    
    Application.StatusBar = False
End Sub

' ================================================================================
' FEATURE 2: RECEIPT PHOTO INTEGRATION - USER INTERFACE
' ================================================================================

Public Sub AddPhotoDiscoveryButtons()
    ' Add photo discovery buttons to the Dashboard
    
    Dim ws As Worksheet
    Dim btn As Object
    
    Set ws = GetWorksheet("Dashboard")
    If ws Is Nothing Then
        Set ws = GetWorksheet("Executive Dashboard")
    End If
    If ws Is Nothing Then Exit Sub
    
    ' Remove existing photo buttons if they exist
    On Error Resume Next
    ws.Shapes("btnSetupPhotos").Delete
    ws.Shapes("btnDiscoverPhotos").Delete
    ws.Shapes("btnPhotoCompliance").Delete
    On Error GoTo 0
    
    ' Setup Photos Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, 150, 180, 35)
    
    With btn
        .Name = "btnSetupPhotos"
        .TextFrame.Characters.Text = "Setup Photo System"
        .TextFrame.Characters.Font.Size = 10
        .TextFrame.Characters.Font.Bold = True
        .Fill.ForeColor.RGB = RGB(76, 175, 80)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "InstallReceiptPhotoSystem"
    End With
    
    ' Discover Photos Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 200, 150, 180, 35)
    
    With btn
        .Name = "btnDiscoverPhotos"
        .TextFrame.Characters.Text = "Discover & Link Photos"
        .TextFrame.Characters.Font.Size = 10
        .TextFrame.Characters.Font.Bold = True
        .Fill.ForeColor.RGB = RGB(255, 152, 0)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "DiscoverReceiptPhotos"
    End With
    
    ' Photo Compliance Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 390, 150, 180, 35)
    
    With btn
        .Name = "btnPhotoCompliance"
        .TextFrame.Characters.Text = "Photo Compliance Report"
        .TextFrame.Characters.Font.Size = 10
        .TextFrame.Characters.Font.Bold = True
        .Fill.ForeColor.RGB = RGB(103, 58, 183)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "ShowPhotoComplianceReport"
    End With
    
    MsgBox "Receipt Photo buttons added to Dashboard!" & vbCrLf & vbCrLf & _
           "Feature 2: Receipt Photo Integration is now available." & vbCrLf & _
           "Click 'Setup Photo System' to begin.", vbInformation
End Sub

Public Sub AddReceiptTrackerPhotoButtons()
    ' Add photo management buttons to Receipt Tracker worksheet
    
    Dim ws As Worksheet
    Dim btn As Object
    Dim buttonY As Long
    
    Set ws = GetWorksheet("Receipt Tracker")
    If ws Is Nothing Then Exit Sub
    
    buttonY = 10
    
    ' Clear existing photo buttons
    On Error Resume Next
    ws.Shapes("btnEnhanceTracker").Delete
    ws.Shapes("btnLinkPhotos").Delete
    ws.Shapes("btnManualLink").Delete
    ws.Shapes("btnPhotoReport").Delete
    On Error GoTo 0
    
    ' Enhance Tracker Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnEnhanceTracker"
        .TextFrame.Characters.Text = "Enhance for Photos"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(76, 175, 80)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "EnhanceReceiptTracker"
    End With
    
    buttonY = buttonY + 40
    
    ' Auto-Link Photos Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnLinkPhotos"
        .TextFrame.Characters.Text = "Auto-Link Photos"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(255, 152, 0)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "DiscoverReceiptPhotos"
    End With
    
    buttonY = buttonY + 40
    
    ' Manual Link Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnManualLink"
        .TextFrame.Characters.Text = "Manual Photo Link"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(63, 81, 181)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "ManualPhotoLinkInterface"
    End With
    
    buttonY = buttonY + 40
    
    ' Photo Report Button
    Set btn = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, buttonY, 150, 30)
    With btn
        .Name = "btnPhotoReport"
        .TextFrame.Characters.Text = "Photo Status"
        .TextFrame.Characters.Font.Size = 9
        .Fill.ForeColor.RGB = RGB(103, 58, 183)
        .TextFrame.Characters.Font.Color = RGB(255, 255, 255)
        .OnAction = "ShowPhotoComplianceReport"
    End With
    
    MsgBox "Receipt Tracker photo buttons added!", vbInformation
End Sub

Public Sub ManualPhotoLinkInterface()
    ' Simple interface for manually linking photos to expenses
    
    Dim selectedCell As Range
    Dim photoPath As String
    Dim ws As Worksheet
    
    Set selectedCell = Selection
    Set ws = ActiveSheet
    
    ' Ensure user has selected a cell in an expense row
    If selectedCell.Row < 2 Then
        MsgBox "Please select a cell in an expense row first.", vbExclamation
        Exit Sub
    End If
    
    ' Open file dialog to select photo
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    
    With fd
        .Title = "Select Receipt Photo"
        .Filters.Clear
        .Filters.Add "Image Files", "*.jpg;*.jpeg;*.png;*.pdf;*.tiff;*.bmp"
        .AllowMultiSelect = False
        
        If .Show = -1 Then
            photoPath = .SelectedItems(1)
            
            ' Add photo path column if needed
            AddPhotoPathColumn ws
            
            ' Get photo column index
            Dim photoCol As Integer
            photoCol = GetPhotoPathColumnIndex(ws)
            
            If photoCol > 0 Then
                ' Create hyperlink
                ws.Hyperlinks.Add Anchor:=ws.Cells(selectedCell.Row, photoCol), _
                                  Address:=photoPath, _
                                  TextToDisplay:="View Receipt"
                
                ' Add manual link note
                If photoCol + 1 <= ws.Columns.Count Then
                    ws.Cells(selectedCell.Row, photoCol + 1).Value = "Manual Link - " & Format(Now(), "mm/dd/yyyy")
                    ws.Cells(selectedCell.Row, photoCol + 1).Font.Size = 8
                End If
                
                MsgBox "Photo linked successfully!", vbInformation
            End If
        End If
    End With
End Sub

Public Sub ShowFeature2InstallationGuide()
    ' Show installation guide for Feature 2
    
    Dim guideText As String
    
    guideText = "FEATURE 2: RECEIPT PHOTO INTEGRATION" & vbCrLf & _
               "====================================" & vbCrLf & vbCrLf & _
               "INSTALLATION STEPS:" & vbCrLf & _
               "1. Click 'Setup Photo System' to create folder structure" & vbCrLf & _
               "2. Move receipt photos to monthly/category folders" & vbCrLf & _
               "3. Rename photos using: Vendor_YYYYMMDD_Amount.ext" & vbCrLf & _
               "4. Click 'Discover & Link Photos' to auto-match" & vbCrLf & _
               "5. Use 'Manual Photo Link' for unmatched items" & vbCrLf & _
               "6. Check 'Photo Compliance Report' for status" & vbCrLf & vbCrLf & _
               "FOLDER STRUCTURE CREATED:" & vbCrLf & _
               "ReceiptPhotos/2024/MM-Month/Category/" & vbCrLf & vbCrLf & _
               "FILE NAMING EXAMPLES:" & vbCrLf & _
               "• OfficeDepot_20240115_47.23.jpg" & vbCrLf & _
               "• GasStation_20240118_45.67_Travel.pdf" & vbCrLf & _
               "• Adobe_20240122_52.99_Subscription.png" & vbCrLf & vbCrLf & _
               "Ready to install Feature 2?"
    
    Dim response As VbMsgBoxResult
    response = MsgBox(guideText, vbYesNo + vbQuestion, "Feature 2 Installation Guide")
    
    If response = vbYes Then
        InstallReceiptPhotoSystem
    End If
End Sub


