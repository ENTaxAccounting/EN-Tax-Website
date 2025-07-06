' ================================================================================
' E&N TAX TRACKER - INSTALLATION SETUP
' Module: Installation, configuration, and initialization
' ================================================================================

Option Explicit

Public Sub InstallRecurringExpenseSystem()
    ' Complete installation of the recurring expense system
    
    Dim response As VbMsgBoxResult
    
    response = MsgBox("This will install the Auto-Recurring Expense System for E&N Tax Tracker." & vbCrLf & vbCrLf & _
                     "The installation will:" & vbCrLf & _
                     "• Create the Recurring Setup worksheet" & vbCrLf & _
                     "• Add control buttons to the Dashboard" & vbCrLf & _
                     "• Set up data validation and formatting" & vbCrLf & _
                     "• Load sample data for testing" & vbCrLf & vbCrLf & _
                     "Continue with installation?", vbYesNo + vbQuestion, "Install Recurring Expense System")
    
    If response = vbYes Then
        Application.ScreenUpdating = False
        Application.StatusBar = "Installing Recurring Expense System..."
        
        ' Run installation steps
        SetupRecurringExpenses
        AddRecurringExpenseButton
        
        ' Add sample data if worksheet is new
        Dim ws As Worksheet
        Set ws = GetWorksheet("Recurring Setup")
        If Not ws Is Nothing Then
            If ws.Cells(2, "A").Value = "" Then
                LoadSampleRecurringData ws
            End If
            
            ' Add menu buttons to the recurring setup sheet
            AddRecurringMenuButtons
        End If
        
        Application.ScreenUpdating = True
        Application.StatusBar = False
        
        MsgBox "Installation complete!" & vbCrLf & vbCrLf & _
               "Your Auto-Recurring Expense System is now ready to use." & vbCrLf & _
               "Check the 'Recurring Setup' worksheet to configure your recurring expenses." & vbCrLf & vbCrLf & _
               "Next steps:" & vbCrLf & _
               "1. Review sample data in Recurring Setup" & vbCrLf & _
               "2. Click 'Validate Data' to check setup" & vbCrLf & _
               "3. Click 'Generate Expenses' to create recurring entries", _
               vbInformation, "Installation Complete"
    End If
End Sub

Public Sub SetupRecurringExpenses()
    ' Initialize the recurring expenses system
    ' Creates the Recurring Setup worksheet if it doesn't exist
    
    Dim ws As Worksheet
    Dim headers As Variant
    Dim i As Integer
    
    ' Check if Recurring Setup worksheet exists
    Set ws = GetWorksheet("Recurring Setup")
    
    If ws Is Nothing Then
        ' Create new worksheet
        Set ws = ThisWorkbook.Worksheets.Add
        ws.Name = "Recurring Setup"
        
        ' Position after Dashboard (try different dashboard names)
        Dim dashboardWs As Worksheet
        Set dashboardWs = GetWorksheet("Dashboard")
        If dashboardWs Is Nothing Then
            Set dashboardWs = GetWorksheet("Executive Dashboard")
        End If
        
        If Not dashboardWs Is Nothing Then
            ws.Move After:=dashboardWs
        End If
        
        ' Add headers
        headers = Array("Recurring ID", "Description", "Vendor/Payee", "Category", _
                       "Amount", "Business %", "Day of Month", "Active Status", _
                       "Target Sheet", "Start Month", "End Month", "Notes")
        
        For i = 0 To UBound(headers)
            ws.Cells(1, i + 1).Value = headers(i)
            ws.Cells(1, i + 1).Font.Bold = True
            ws.Cells(1, i + 1).Interior.Color = RGB(68, 114, 196)
            ws.Cells(1, i + 1).Font.Color = RGB(255, 255, 255)
        Next i
        
        ' Set column widths
        ws.Columns("A").ColumnWidth = 12   ' Recurring ID
        ws.Columns("B").ColumnWidth = 25   ' Description
        ws.Columns("C").ColumnWidth = 20   ' Vendor/Payee
        ws.Columns("D").ColumnWidth = 25   ' Category
        ws.Columns("E").ColumnWidth = 12   ' Amount
        ws.Columns("F").ColumnWidth = 12   ' Business %
        ws.Columns("G").ColumnWidth = 15   ' Day of Month
        ws.Columns("H").ColumnWidth = 15   ' Active Status
        ws.Columns("I").ColumnWidth = 20   ' Target Sheet
        ws.Columns("J").ColumnWidth = 12   ' Start Month
        ws.Columns("K").ColumnWidth = 12   ' End Month
        ws.Columns("L").ColumnWidth = 30   ' Notes
        
        ' Add data validation for dropdowns
        SetupDataValidation ws
        
        ' Add instructions
        AddSetupInstructions ws
        
        MsgBox "Recurring Setup worksheet created successfully!" & vbCrLf & _
               "Please add your recurring expenses to get started.", vbInformation
    Else
        ' Worksheet exists, just update validation
        SetupDataValidation ws
        MsgBox "Recurring Setup worksheet already exists. Data validation updated.", vbInformation
    End If
End Sub

Private Sub SetupDataValidation(ws As Worksheet)
    ' Set up data validation dropdowns for the Recurring Setup sheet
    
    Dim categoryRange As String
    Dim sheetRange As String
    Dim statusRange As String
    Dim monthRange As String
    
    ' Define validation lists based on existing expense categories
    categoryRange = "Office Supplies,Equipment & Software,Professional Services," & _
               "Marketing & Advertising,Utilities (Business Portion),Rent (Business Portion)," & _
               "Insurance (Business Portion),Meals & Entertainment,Conference & Training," & _
               "Subscriptions & Memberships,Legal & Professional Fees,Bank Fees," & _
               "Other Business Expenses,Cash Donation,Non-Cash Donation,Volunteer Mileage," & _
               "Investment Advisory Fees,Tax Preparation Fees,Investment Publications," & _
               "Financial Software,Legal Fees (Investment),Mortgage Interest,Property Taxes," & _
               "Homeowners Insurance,Utilities - Electric,Utilities - Gas,Utilities - Internet," & _
               "Home Repairs,Maintenance,Security System"
    
    sheetRange = "Business Expenses,Home Office,Charitable Contributions,Investment & Financial"
    
    statusRange = "Active,Inactive,Paused"
    
    monthRange = "1,2,3,4,5,6,7,8,9,10,11,12"
    
    On Error Resume Next
    
    ' Apply validation to columns
    With ws
        ' Category validation (Column D)
        .Range("D2:D1000").Validation.Delete
        .Range("D2:D1000").Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                                     Formula1:=categoryRange
        
        ' Business % validation (Column F)
        .Range("F2:F1000").Validation.Delete
        .Range("F2:F1000").Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                                     Formula1:="25%,50%,75%,80%,100%"
        
        ' Active Status validation (Column H)
        .Range("H2:H1000").Validation.Delete
        .Range("H2:H1000").Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                                     Formula1:=statusRange
        
        ' Target Sheet validation (Column I)
        .Range("I2:I1000").Validation.Delete
        .Range("I2:I1000").Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                                     Formula1:=sheetRange
        
        ' Month validation (Columns J and K)
        .Range("J2:J1000,K2:K1000").Validation.Delete
        .Range("J2:J1000,K2:K1000").Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                                         Formula1:=monthRange
        
        ' Day of Month validation (Column G)
        .Range("G2:G1000").Validation.Delete
        .Range("G2:G1000").Validation.Add Type:=xlValidateWholeNumber, AlertStyle:=xlValidAlertStop, _
                                     Operator:=xlBetween, Formula1:=1, Formula2:=31
    End With
    
    On Error GoTo 0
End Sub

Private Sub LoadSampleRecurringData(ws As Worksheet)
    ' Load sample recurring expenses for demonstration
    
    Dim sampleData As Variant
    Dim i As Integer, j As Integer
    
    ' Sample data array (matching the CSV structure)
    sampleData = Array( _
        Array(1, "Office 365 Business", "Microsoft", "Equipment & Software", 22, "100%", 25, "Active", "Business Expenses", 1, 12, "Monthly subscription"), _
        Array(2, "QuickBooks Subscription", "QuickBooks", "Equipment & Software", 25, "100%", 5, "Active", "Business Expenses", 1, 12, "Accounting software"), _
        Array(3, "Business Phone Bill", "AT&T", "Utilities (Business Portion)", 125, "80%", 1, "Active", "Business Expenses", 1, 12, "Business line portion") _
    )
    
    ' Add sample data to worksheet
    For i = 0 To UBound(sampleData)
        For j = 0 To UBound(sampleData(i))
            ws.Cells(i + 2, j + 1).Value = sampleData(i)(j)
        Next j
    Next i
    
    ' Format the data
    ws.Range("E2:E4").NumberFormat = "$#,##0.00"
    
    ' Add note about sample data
    ws.Cells(6, 1).Value = "NOTE:"
    ws.Cells(6, 2).Value = "Sample data provided above. Replace with your actual recurring expenses."
    ws.Cells(6, 1).Font.Bold = True
    ws.Cells(6, 2).Font.Italic = True
    ws.Range("A6:L6").Interior.Color = RGB(255, 255, 204)
End Sub

Private Sub AddSetupInstructions(ws As Worksheet)
    ' Add helpful instructions to the recurring setup worksheet
    
    Dim instructionRow As Long
    instructionRow = 8
    
    ' Add instruction headers
    ws.Cells(instructionRow, 1).Value = "SETUP INSTRUCTIONS:"
    ws.Cells(instructionRow, 1).Font.Bold = True
    ws.Cells(instructionRow, 1).Font.Size = 12
    instructionRow = instructionRow + 1
    
    ' Add instructions
    Dim instructions As Variant
    instructions = Array( _
        "1. Enter your recurring expenses in rows above (replace sample data)", _
        "2. Use dropdown menus for Category, Active Status, Target Sheet, and months", _
        "3. Enter amounts without $ symbol (e.g., 25.00 not $25.00)", _
        "4. Day of Month: Enter 1-31 for when expense typically occurs", _
        "5. Business %: Percentage of expense used for business purposes", _
        "6. Click 'Validate Data' button to check for errors", _
        "7. Click 'Generate Expenses' to create recurring entries for the year" _
    )
    
    Dim i As Integer
    For i = 0 To UBound(instructions)
        ws.Cells(instructionRow + i, 1).Value = instructions(i)
        ws.Cells(instructionRow + i, 1).Font.Size = 10
    Next i
    
    ' Format instruction area
    ws.Range("A" & instructionRow - 1 & ":L" & instructionRow + UBound(instructions)).Interior.Color = RGB(240, 248, 255)
    ws.Range("A" & instructionRow - 1 & ":L" & instructionRow + UBound(instructions)).Borders.LineStyle = xlContinuous
End Sub

Public Sub UninstallRecurringExpenseSystem()
    ' Remove the recurring expense system (for testing/cleanup)
    
    Dim response As VbMsgBoxResult
    Dim ws As Worksheet
    
    response = MsgBox("This will completely remove the Recurring Expense System." & vbCrLf & vbCrLf & _
                     "This will delete:" & vbCrLf & _
                     "• Recurring Setup worksheet" & vbCrLf & _
                     "• All backup worksheets" & vbCrLf & _
                     "• Control buttons" & vbCrLf & vbCrLf & _
                     "Continue with uninstall?", vbYesNo + vbExclamation, "Uninstall Recurring System")
    
    If response = vbYes Then
        Application.DisplayAlerts = False
        
        ' Remove Recurring Setup worksheet
        Set ws = GetWorksheet("Recurring Setup")
        If Not ws Is Nothing Then
            ws.Delete
        End If
        
        ' Remove backup worksheets
        For Each ws In ThisWorkbook.Worksheets
            If Left(ws.Name, 16) = "Recurring Backup" Then
                ws.Delete
            End If
        Next ws
        
        ' Remove archive worksheet
        Set ws = GetWorksheet("Recurring Archive")
        If Not ws Is Nothing Then
            ws.Delete
        End If
        
        ' Remove buttons from Dashboard
        Set ws = GetWorksheet("Dashboard")
        If ws Is Nothing Then Set ws = GetWorksheet("Executive Dashboard")
        
        If Not ws Is Nothing Then
            On Error Resume Next
            ws.Shapes("btnGenerateRecurring").Delete
            ws.Shapes("btnValidateData").Delete
            On Error GoTo 0
        End If
        
        Application.DisplayAlerts = True
        
        MsgBox "Recurring Expense System has been uninstalled.", vbInformation
    End If
End Sub

Public Sub RepairRecurringExpenseSystem()
    ' Repair common issues with the recurring expense system
    
    Dim ws As Worksheet
    Dim issuesFound As Integer
    Dim repairLog As String
    
    issuesFound = 0
    repairLog = "REPAIR LOG:" & vbCrLf & "============" & vbCrLf
    
    Application.ScreenUpdating = False
    
    ' Check and repair Recurring Setup worksheet
    Set ws = GetWorksheet("Recurring Setup")
    If ws Is Nothing Then
        SetupRecurringExpenses
        issuesFound = issuesFound + 1
        repairLog = repairLog & "• Created missing Recurring Setup worksheet" & vbCrLf
    Else
        ' Repair data validation
        SetupDataValidation ws
        repairLog = repairLog & "• Refreshed data validation rules" & vbCrLf
    End If
    
    ' Check and repair Dashboard buttons
    Set ws = GetWorksheet("Dashboard")
    If ws Is Nothing Then Set ws = GetWorksheet("Executive Dashboard")
    
    If Not ws Is Nothing Then
        On Error Resume Next
        Dim buttonExists As Boolean
        buttonExists = False
        
        Dim shp As Shape
        For Each shp In ws.Shapes
            If shp.Name = "btnGenerateRecurring" Then
                buttonExists = True
                Exit For
            End If
        Next shp
        
        If Not buttonExists Then
            AddRecurringExpenseButton
            issuesFound = issuesFound + 1
            repairLog = repairLog & "• Added missing Dashboard buttons" & vbCrLf
        End If
        On Error GoTo 0
    End If
    
    ' Run data validation
    Set ws = GetWorksheet("Recurring Setup")
    If Not ws Is Nothing Then
        QuickFixRecurringData
        repairLog = repairLog & "• Applied quick data fixes" & vbCrLf
    End If
    
    Application.ScreenUpdating = True
    
    If issuesFound = 0 Then
        repairLog = repairLog & "• No issues found - system is healthy" & vbCrLf
    End If
    
    repairLog = repairLog & vbCrLf & "Repair complete!"
    
    MsgBox repairLog, vbInformation, "System Repair Complete"
End Sub

' ================================================================================
' FEATURE 2: RECEIPT PHOTO INTEGRATION - INSTALLATION
' ================================================================================

Public Sub InstallCompleteENTaxSystem()
    ' Master installation for both Feature 1 and Feature 2
    
    Dim response As VbMsgBoxResult
    
    response = MsgBox("Install COMPLETE E&N Tax Tracker System?" & vbCrLf & vbCrLf & _
                     "This will install:" & vbCrLf & _
                     "✅ Feature 1: Auto-Recurring Expense System" & vbCrLf & _
                     "✅ Feature 2: Receipt Photo Integration" & vbCrLf & vbCrLf & _
                     "Features included:" & vbCrLf & _
                     "• Automated recurring expense generation" & vbCrLf & _
                     "• Receipt photo discovery and linking" & vbCrLf & _
                     "• Professional folder organization" & vbCrLf & _
                     "• Compliance reporting dashboard" & vbCrLf & _
                     "• Complete user interface with buttons" & vbCrLf & vbCrLf & _
                     "Continue with full installation?", vbYesNo + vbQuestion, "Install Complete System")
    
    If response = vbYes Then
        Application.ScreenUpdating = False
        Application.StatusBar = "Installing Complete E&N Tax System..."
        
        ' Install Feature 1
        InstallRecurringExpenseSystem
        
        ' Install Feature 2
        InstallReceiptPhotoSystem
        
        ' Add all interface buttons
        AddPhotoDiscoveryButtons
        AddReceiptTrackerPhotoButtons
        
        Application.ScreenUpdating = True
        Application.StatusBar = False
        
        MsgBox "COMPLETE INSTALLATION SUCCESSFUL!" & vbCrLf & vbCrLf & _
               "E&N Tax Tracker Professional Edition is now ready!" & vbCrLf & vbCrLf & _
               "Features installed:" & vbCrLf & _
               "✅ Auto-Recurring Expenses (Feature 1)" & vbCrLf & _
               "✅ Receipt Photo Integration (Feature 2)" & vbCrLf & vbCrLf & _
               "Next steps:" & vbCrLf & _
               "1. Set up recurring expenses in 'Recurring Setup'" & vbCrLf & _
               "2. Organize receipt photos using naming guide" & vbCrLf & _
               "3. Run photo discovery to link existing photos" & vbCrLf & _
               "4. Check compliance reports for status", _
               vbInformation, "Installation Complete - Professional Edition"
    End If
End Sub

Public Sub EnhanceReceiptTracker()
    ' Enhance existing Receipt Tracker worksheet with photo integration columns
    
    Dim ws As Worksheet
    Dim lastCol As Integer
    Dim photoCol As Integer
    Dim statusCol As Integer
    Dim detailsCol As Integer
    
    Set ws = GetWorksheet("Receipt Tracker")
    If ws Is Nothing Then
        MsgBox "Receipt Tracker worksheet not found. Please create it first.", vbExclamation
        Exit Sub
    End If
    
    ' Check if photo columns already exist
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    
    ' Look for existing photo columns
    Dim i As Integer
    For i = 1 To lastCol
        If UCase(ws.Cells(1, i).Value) = "RECEIPT PHOTO" Then
            MsgBox "Receipt Tracker already enhanced for photos.", vbInformation
            Exit Sub
        End If
    Next i
    
    ' Add photo integration columns
    photoCol = lastCol + 1
    statusCol = lastCol + 2
    detailsCol = lastCol + 3
    
    ' Add headers
    ws.Cells(1, photoCol).Value = "Receipt Photo"
    ws.Cells(1, statusCol).Value = "Photo Status"
    ws.Cells(1, detailsCol).Value = "Match Details"
    
    ' Format headers
    ws.Range(ws.Cells(1, photoCol), ws.Cells(1, detailsCol)).Font.Bold = True
    ws.Range(ws.Cells(1, photoCol), ws.Cells(1, detailsCol)).Interior.Color = RGB(76, 175, 80)
    ws.Range(ws.Cells(1, photoCol), ws.Cells(1, detailsCol)).Font.Color = RGB(255, 255, 255)
    
    ' Set column widths
    ws.Columns(photoCol).ColumnWidth = 15   ' Receipt Photo
    ws.Columns(statusCol).ColumnWidth = 12  ' Photo Status
    ws.Columns(detailsCol).ColumnWidth = 25 ' Match Details
    
    ' Add data validation for Photo Status column
    With ws.Range(ws.Cells(2, statusCol), ws.Cells(1000, statusCol))
        .Validation.Delete
        .Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, _
                        Formula1:="Found,Missing,Pending,Manual Link"
    End With
    
    ' Add instructional text
    ws.Cells(2, photoCol).Value = "Auto-populated by photo discovery"
    ws.Cells(2, statusCol).Value = "Found/Missing/Pending"
    ws.Cells(2, detailsCol).Value = "Match confidence and details"
    
    ws.Range(ws.Cells(2, photoCol), ws.Cells(2, detailsCol)).Font.Italic = True
    ws.Range(ws.Cells(2, photoCol), ws.Cells(2, detailsCol)).Font.Color = RGB(128, 128, 128)
    
    MsgBox "Receipt Tracker enhanced for photo integration!" & vbCrLf & vbCrLf & _
           "New columns added:" & vbCrLf & _
           "• Receipt Photo (hyperlinks to photo files)" & vbCrLf & _
           "• Photo Status (Found/Missing/Pending)" & vbCrLf & _
           "• Match Details (confidence and matching info)" & vbCrLf & vbCrLf & _
           "Run 'Auto-Link Photos' to populate these columns.", vbInformation
End Sub

Public Sub CreatePhotoSystemDocumentation()
    ' Create comprehensive documentation for the photo system
    
    Dim ws As Worksheet
    Dim docRow As Long
    
    ' Create or get Photo Documentation worksheet
    Set ws = GetWorksheet("Photo System Guide")
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add
        ws.Name = "Photo System Guide"
        ws.Move After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count)
    Else
        ws.Cells.Clear
    End If
    
    docRow = 1
    
    ' Add documentation content
    ws.Cells(docRow, 1).Value = "E&N TAX TRACKER - RECEIPT PHOTO SYSTEM GUIDE"
    ws.Cells(docRow, 1).Font.Bold = True
    ws.Cells(docRow, 1).Font.Size = 14
    ws.Range("A" & docRow & ":E" & docRow).Merge
    docRow = docRow + 2
    
    ' Feature overview
    ws.Cells(docRow, 1).Value = "RECEIPT PHOTO INTEGRATION"
    ws.Cells(docRow, 1).Font.Bold = True
    ws.Cells(docRow, 1).Font.Size = 12
    docRow = docRow + 1
    
    Dim documentation As Variant
    documentation = Array( _
        "OVERVIEW:", _
        "The Receipt Photo Integration system automatically links receipt photos to expense entries", _
        "through intelligent file naming and folder organization. This ensures IRS compliance", _
        "and eliminates manual receipt filing.", _
        "", _
        "FOLDER STRUCTURE:", _
        "ReceiptPhotos/", _
        "  └── 2024/", _
        "      ├── 01-January/", _
        "      │   ├── Business_Expenses/", _
        "      │   ├── Vehicle_Travel/", _
        "      │   ├── Professional_Development/", _
        "      │   ├── Medical_Health/", _
        "      │   ├── Charitable_Contributions/", _
        "      │   ├── Investment_Financial/", _
        "      │   └── Other/", _
        "      ├── 02-February/", _
        "      └── ... (through 12-December)", _
        "", _
        "FILE NAMING CONVENTION:", _
        "Format: Vendor_YYYYMMDD_Amount[_Optional].ext", _
        "", _
        "Examples:", _
        "  • OfficeDepot_20240115_47.23.jpg", _
        "  • GasStation_20240118_45.67_Travel.pdf", _
        "  • Adobe_20240122_52.99_Subscription.png", _
        "  • RestaurantName_20240214_78.45_ClientLunch.jpg", _
        "", _
        "PHOTO DISCOVERY PROCESS:", _
        "1. System scans folder structure for photo files", _
        "2. Parses filename for vendor, date, and amount", _
        "3. Calculates match confidence score against expense entries", _
        "4. Auto-links photos with 70%+ confidence", _
        "5. Flags questionable matches for manual review", _
        "", _
        "MATCH CONFIDENCE LEVELS:", _
        "  90-100%: Excellent - All criteria match exactly", _
        "  70-89%:  Good - Most criteria match with minor variations", _
        "  50-69%:  Fair - Some criteria match but needs review", _
        "  30-49%:  Poor - Weak match requires manual verification", _
        "  <30%:    No confident match found", _
        "", _
        "USER INTERFACE BUTTONS:", _
        "Dashboard:", _
        "  • Setup Photo System - Creates folder structure", _
        "  • Discover & Link Photos - Runs auto-matching", _
        "  • Photo Compliance Report - Shows status summary", _
        "", _
        "Receipt Tracker:", _
        "  • Enhance for Photos - Adds photo columns", _
        "  • Auto-Link Photos - Runs discovery process", _
        "  • Manual Photo Link - Link specific photos", _
        "  • Photo Status - Shows compliance report", _
        "", _
        "COMPLIANCE FEATURES:", _
        "• Real-time compliance rate calculation", _
        "• Missing photo identification", _
        "• Match confidence reporting", _
        "• Professional audit trail", _
        "", _
        "BEST PRACTICES:", _
        "1. Scan/photograph receipts immediately after purchase", _
        "2. Use consistent vendor names in filenames", _
        "3. Include exact dates in YYYYMMDD format", _
        "4. Include exact amounts with decimal points", _
        "5. Organize photos in monthly/category folders", _
        "6. Run photo discovery weekly", _
        "7. Manually review matches below 80% confidence", _
        "8. Target 95%+ compliance rate for IRS readiness", _
        "", _
        "TROUBLESHOOTING:", _
        "• Photos not found: Check file naming and folder location", _
        "• Low match scores: Verify vendor names and amounts", _
        "• Missing links: Run discovery again after organizing", _
        "• Duplicate matches: Use manual link for specific photos", _
        "", _
        "SUPPORTED FILE FORMATS:", _
        "• Images: .jpg, .jpeg, .png, .tiff, .bmp", _
        "• Documents: .pdf", _
        "", _
        "TECHNICAL NOTES:", _
        "• System uses file system access only (no cloud dependency)", _
        "• Photos remain on local computer for security", _
        "• Hyperlinks work with Excel, Windows Explorer integration", _
        "• Compatible with Excel 2016+ on Windows", _
        "• Handles 100+ receipts efficiently", _
        "", _
        "PRICING IMPACT:", _
        "Feature 2 adds significant value justifying premium pricing:", _
        "• Basic tracker without photos: $47", _
        "• Professional with Feature 1 + 2: $127-147", _
        "• Enterprise with full automation: $197+" _
    )
    
    ' Add documentation lines
    Dim i As Integer
    For i = 0 To UBound(documentation)
        ws.Cells(docRow + i, 1).Value = documentation(i)
        
        ' Format section headers
        If Right(documentation(i), 1) = ":" And Len(documentation(i)) < 50 Then
            ws.Cells(docRow + i, 1).Font.Bold = True
            ws.Cells(docRow + i, 1).Font.Color = RGB(68, 114, 196)
        End If
        
        ' Format examples with indent
        If Left(documentation(i), 2) = "  " Then
            ws.Cells(docRow + i, 1).IndentLevel = 1
            ws.Cells(docRow + i, 1).Font.Name = "Courier New"
        End If
    Next i
    
    ' Format worksheet
    ws.Columns("A").ColumnWidth = 80
    ws.Range("A1:A" & docRow + UBound(documentation)).WrapText = False
    
    MsgBox "Photo System documentation created!" & vbCrLf & _
           "Check the 'Photo System Guide' worksheet for complete instructions.", vbInformation
End Sub

Public Sub UninstallCompleteSystem()
    ' Remove both Feature 1 and Feature 2
    
    Dim response As VbMsgBoxResult
    
    response = MsgBox("UNINSTALL COMPLETE E&N TAX SYSTEM?" & vbCrLf & vbCrLf & _
                     "This will remove:" & vbCrLf & _
                     "• Feature 1: Auto-Recurring Expense System" & vbCrLf & _
                     "• Feature 2: Receipt Photo Integration" & vbCrLf & _
                     "• All associated worksheets and buttons" & vbCrLf & _
                     "• Photo folder structure (files preserved)" & vbCrLf & vbCrLf & _
                     "WARNING: This cannot be undone!" & vbCrLf & vbCrLf & _
                     "Continue with uninstall?", vbYesNo + vbCritical, "Uninstall Complete System")
    
    If response = vbYes Then
        Application.DisplayAlerts = False
        
        ' Uninstall Feature 1
        UninstallRecurringExpenseSystem
        
        ' Remove Feature 2 components
        Dim ws As Worksheet
        
        ' Remove Photo System Guide
        Set ws = GetWorksheet("Photo System Guide")
        If Not ws Is Nothing Then
            ws.Delete
        End If
        
        ' Remove photo buttons from Dashboard
        Set ws = GetWorksheet("Dashboard")
        If ws Is Nothing Then Set ws = GetWorksheet("Executive Dashboard")
        
        If Not ws Is Nothing Then
            On Error Resume Next
            ws.Shapes("btnSetupPhotos").Delete
            ws.Shapes("btnDiscoverPhotos").Delete
            ws.Shapes("btnPhotoCompliance").Delete
            On Error GoTo 0
        End If
        
        ' Remove photo buttons from Receipt Tracker
        Set ws = GetWorksheet("Receipt Tracker")
        If Not ws Is Nothing Then
            On Error Resume Next
            ws.Shapes("btnEnhanceTracker").Delete
            ws.Shapes("btnLinkPhotos").Delete
            ws.Shapes("btnManualLink").Delete
            ws.Shapes("btnPhotoReport").Delete
            On Error GoTo 0
        End If
        
        Application.DisplayAlerts = True
        
        MsgBox "Complete system uninstalled." & vbCrLf & vbCrLf & _
               "Note: Receipt photo files in ReceiptPhotos folder" & vbCrLf & _
               "were preserved and can be manually deleted if desired.", vbInformation
    End If
End Sub


