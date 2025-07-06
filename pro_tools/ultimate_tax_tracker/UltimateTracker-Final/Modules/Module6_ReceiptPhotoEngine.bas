' ================================================================================
' E&N TAX TRACKER - RECEIPT PHOTO ENGINE
' Module: Feature 2 - Receipt photo discovery, linking, and compliance
' ================================================================================

Option Explicit

' Global constants for photo system
Public Const PHOTO_BASE_FOLDER = "ReceiptPhotos"
Public Const SUPPORTED_EXTENSIONS = "jpg,jpeg,png,pdf,tiff,bmp"

Public Type PhotoMatch
    FilePath As String
    MatchScore As Double
    MatchReason As String
    IsConfirmed As Boolean
End Type

Public Sub InstallReceiptPhotoSystem()
    ' Main installation routine for Feature 2
    
    Dim response As VbMsgBoxResult
    
    response = MsgBox("Install Receipt Photo Integration System?" & vbCrLf & vbCrLf & _
                     "This will:" & vbCrLf & _
                     "• Set up standardized photo folder structure" & vbCrLf & _
                     "• Enhance Receipt Tracker with photo linking" & vbCrLf & _
                     "• Add photo discovery and matching tools" & vbCrLf & _
                     "• Create compliance dashboard" & vbCrLf & vbCrLf & _
                     "Continue?", vbYesNo + vbQuestion, "Install Receipt Photo System")
    
    If response = vbYes Then
        Application.ScreenUpdating = False
        Application.StatusBar = "Installing Receipt Photo System..."
        
        ' Run installation components
        SetupPhotoFolderStructure
        EnhanceReceiptTracker
        AddPhotoDiscoveryButtons
        
        Application.ScreenUpdating = True
        Application.StatusBar = False
        
        MsgBox "Receipt Photo System installed successfully!" & vbCrLf & vbCrLf & _
               "Next steps:" & vbCrLf & _
               "1. Move receipt photos to the created folder structure" & vbCrLf & _
               "2. Use recommended file naming: Vendor_YYYYMMDD_Amount.ext" & vbCrLf & _
               "3. Run 'Discover Photos' to link existing photos" & vbCrLf & _
               "4. Check 'Photo Compliance Report' for status", _
               vbInformation, "Installation Complete"
    End If
End Sub

Public Sub SetupPhotoFolderStructure()
    ' Create standardized folder structure for receipt organization
    
    Dim basePath As String
    Dim yearFolder As String
    Dim monthFolder As String
    Dim categoryFolder As String
    Dim currentYear As Integer
    Dim i As Integer
    
    ' Get workbook directory as base
    basePath = ThisWorkbook.Path & "\" & PHOTO_BASE_FOLDER
    currentYear = Year(Date)
    
    ' Create base folder
    CreateFolderIfNotExists basePath
    
    ' Create year folder
    yearFolder = basePath & "\" & currentYear
    CreateFolderIfNotExists yearFolder
    
    ' Create monthly folders
    Dim monthNames As Variant
    monthNames = Array("01-January", "02-February", "03-March", "04-April", _
                      "05-May", "06-June", "07-July", "08-August", _
                      "09-September", "10-October", "11-November", "12-December")
    
    For i = 0 To UBound(monthNames)
        monthFolder = yearFolder & "\" & monthNames(i)
        CreateFolderIfNotExists monthFolder
        
        ' Create category subfolders in each month
        CreateFolderIfNotExists monthFolder & "\Business_Expenses"
        CreateFolderIfNotExists monthFolder & "\Vehicle_Travel"
        CreateFolderIfNotExists monthFolder & "\Professional_Development"
        CreateFolderIfNotExists monthFolder & "\Medical_Health"
        CreateFolderIfNotExists monthFolder & "\Charitable_Contributions"
        CreateFolderIfNotExists monthFolder & "\Investment_Financial"
        CreateFolderIfNotExists monthFolder & "\Other"
    Next i
    
    ' Create naming guide file
    CreateNamingGuideFile basePath
    
    MsgBox "Photo folder structure created at:" & vbCrLf & basePath & vbCrLf & vbCrLf & _
           "Please move your receipt photos to the appropriate monthly/category folders." & vbCrLf & _
           "Use naming format: Vendor_YYYYMMDD_Amount.ext", vbInformation
End Sub

Private Sub CreateFolderIfNotExists(folderPath As String)
    ' Safely create folder if it doesn't exist
    
    On Error Resume Next
    If Dir(folderPath, vbDirectory) = "" Then
        MkDir folderPath
    End If
    On Error GoTo 0
End Sub

Private Sub CreateNamingGuideFile(basePath As String)
    ' Create a naming convention guide file
    
    Dim guideContent As String
    Dim filePath As String
    Dim fileNum As Integer
    
    filePath = basePath & "\Photo_Naming_Guide.txt"
    
    guideContent = "E&N TAX TRACKER - RECEIPT PHOTO NAMING GUIDE" & vbCrLf & _
                  "=============================================" & vbCrLf & vbCrLf & _
                  "RECOMMENDED FILE NAMING CONVENTION:" & vbCrLf & _
                  "Vendor_YYYYMMDD_Amount[_Optional].ext" & vbCrLf & vbCrLf & _
                  "EXAMPLES:" & vbCrLf & _
                  "• OfficeDepot_20240115_47.23.jpg" & vbCrLf & _
                  "• GasStation_20240118_45.67_Travel.pdf" & vbCrLf & _
                  "• Adobe_20240122_52.99_Subscription.png" & vbCrLf & _
                  "• RestaurantName_20240214_78.45_ClientLunch.jpg" & vbCrLf & vbCrLf & _
                  "FOLDER ORGANIZATION:" & vbCrLf & _
                  "• Store photos in month/category folders" & vbCrLf & _
                  "• Use category folders: Business_Expenses, Vehicle_Travel, etc." & vbCrLf & _
                  "• Keep file names descriptive but concise" & vbCrLf & vbCrLf & _
                  "TIPS FOR BEST MATCHING:" & vbCrLf & _
                  "• Use exact vendor names when possible" & vbCrLf & _
                  "• Include exact date (YYYYMMDD format)" & vbCrLf & _
                  "• Include exact amount (use decimal point)" & vbCrLf & _
                  "• Avoid spaces (use underscores)" & vbCrLf & _
                  "• Remove special characters from vendor names"
    
    fileNum = FreeFile
    Open filePath For Output As fileNum
    Print #fileNum, guideContent
    Close fileNum
End Sub

Public Sub DiscoverReceiptPhotos()
    ' Main photo discovery engine - scans folders and matches to expense entries
    
    Dim ws As Worksheet
    Dim photoPath As String
    Dim discoveredCount As Integer
    Dim linkedCount As Integer
    Dim startTime As Double
    
    startTime = Timer
    discoveredCount = 0
    linkedCount = 0
    
    Application.ScreenUpdating = False
    Application.StatusBar = "Discovering receipt photos..."
    
    ' Process each worksheet with expenses
    Dim targetSheets As Variant
    targetSheets = Array("Business Expenses", "Home Office", "Vehicle & Travel", _
                        "Medical & Health", "Charitable Contributions", "Investment & Financial")
    
    Dim i As Integer
    For i = 0 To UBound(targetSheets)
        Set ws = GetWorksheet(targetSheets(i))
        If Not ws Is Nothing Then
            Dim sheetResults As Integer
            sheetResults = DiscoverPhotosForWorksheet(ws)
            discoveredCount = discoveredCount + sheetResults
        End If
        
        Application.StatusBar = "Discovering photos... " & (i + 1) & " of " & (UBound(targetSheets) + 1) & " sheets"
    Next i
    
    ' Update Receipt Tracker with discovery results
    UpdateReceiptTrackerFromDiscovery
    
    Application.ScreenUpdating = True
    Application.StatusBar = False
    
    Dim elapsedTime As Double
    elapsedTime = Timer - startTime
    
    MsgBox "Photo Discovery Complete!" & vbCrLf & vbCrLf & _
           "Photos discovered: " & discoveredCount & vbCrLf & _
           "Photos linked: " & linkedCount & vbCrLf & _
           "Time elapsed: " & Format(elapsedTime, "0.0") & " seconds" & vbCrLf & vbCrLf & _
           "Check the Receipt Tracker for updated photo links.", _
           vbInformation, "E&N Photo Discovery"
End Sub

Private Function DiscoverPhotosForWorksheet(ws As Worksheet) As Integer
    ' Discover and link photos for a specific worksheet
    
    Dim lastRow As Long
    Dim i As Long
    Dim matchCount As Integer
    Dim expenseDate As Date
    Dim vendor As String
    Dim amount As Double
    Dim photoMatches() As PhotoMatch
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    matchCount = 0
    
    ' Add photo path column if it doesn't exist
    AddPhotoPathColumn ws
    
    For i = 2 To lastRow
        If IsDate(ws.Cells(i, "A").Value) Then
            expenseDate = ws.Cells(i, "A").Value
            vendor = CleanVendorName(ws.Cells(i, "B").Value)
            amount = ExtractAmountFromCell(ws.Cells(i, "F").Value) ' Assuming amount is in column F
            
            ' Find matching photos
            photoMatches = FindMatchingPhotos(expenseDate, vendor, amount)
            
            If UBound(photoMatches) >= 0 Then
                ' Use best match
                Dim bestMatch As PhotoMatch
                bestMatch = GetBestPhotoMatch(photoMatches)
                
                If bestMatch.MatchScore > 0.7 Then ' 70% confidence threshold
                    LinkPhotoToExpense ws, i, bestMatch
                    matchCount = matchCount + 1
                End If
            End If
        End If
    Next i
    
    DiscoverPhotosForWorksheet = matchCount
End Function

Private Function FindMatchingPhotos(expenseDate As Date, vendor As String, amount As Double) As PhotoMatch()
    ' Find photos that match the expense criteria
    
    Dim photoMatches() As PhotoMatch
    Dim matchCount As Integer
    Dim basePath As String
    Dim searchPaths As Variant
    Dim i As Integer
    
    matchCount = 0
    ReDim photoMatches(0 To 0)
    
    basePath = ThisWorkbook.Path & "\" & PHOTO_BASE_FOLDER & "\" & Year(expenseDate)
    
    ' Define search paths (month folder and category subfolders)
    Dim monthFolder As String
    monthFolder = Format(expenseDate, "mm") & "-" & Format(expenseDate, "mmmm")
    
    searchPaths = Array( _
        basePath & "\" & monthFolder & "\Business_Expenses", _
        basePath & "\" & monthFolder & "\Vehicle_Travel", _
        basePath & "\" & monthFolder & "\Professional_Development", _
        basePath & "\" & monthFolder & "\Medical_Health", _
        basePath & "\" & monthFolder & "\Charitable_Contributions", _
        basePath & "\" & monthFolder & "\Investment_Financial", _
        basePath & "\" & monthFolder & "\Other", _
        basePath & "\" & monthFolder _
    )
    
    ' Search each path for matching files
    For i = 0 To UBound(searchPaths)
        SearchFolderForMatches searchPaths(i), expenseDate, vendor, amount, photoMatches, matchCount
    Next i
    
    ' Resize array to actual count
    If matchCount > 0 Then
        ReDim Preserve photoMatches(0 To matchCount - 1)
    Else
        ReDim photoMatches(0 To -1) ' Empty array
    End If
    
    FindMatchingPhotos = photoMatches
End Function

Private Sub SearchFolderForMatches(folderPath As String, expenseDate As Date, vendor As String, _
                                  amount As Double, ByRef photoMatches() As PhotoMatch, ByRef matchCount As Integer)
    ' Search a specific folder for matching photo files
    
    Dim fileName As String
    Dim fullPath As String
    Dim matchScore As Double
    Dim matchReason As String
    
    If Dir(folderPath, vbDirectory) = "" Then Exit Sub
    
    fileName = Dir(folderPath & "\*.*")
    
    Do While fileName <> ""
        If IsPhotoFile(fileName) Then
            fullPath = folderPath & "\" & fileName
            matchScore = CalculatePhotoMatchScore(fileName, expenseDate, vendor, amount, matchReason)
            
            If matchScore > 0.3 Then ' Minimum 30% match to be considered
                ' Expand array if needed
                If matchCount > UBound(photoMatches) Then
                    ReDim Preserve photoMatches(0 To matchCount + 10)
                End If
                
                ' Add match to array
                photoMatches(matchCount).FilePath = fullPath
                photoMatches(matchCount).MatchScore = matchScore
                photoMatches(matchCount).MatchReason = matchReason
                photoMatches(matchCount).IsConfirmed = False
                
                matchCount = matchCount + 1
            End If
        End If
        
        fileName = Dir
    Loop
End Sub

Private Function CalculatePhotoMatchScore(fileName As String, expenseDate As Date, _
                                        vendor As String, amount As Double, ByRef matchReason As String) As Double
    ' Calculate confidence score for photo-expense matching
    
    Dim score As Double
    Dim reasons As String
    Dim fileParts() As String
    Dim fileVendor As String
    Dim fileDate As String
    Dim fileAmount As String
    
    score = 0
    reasons = ""
    
    ' Remove file extension
    Dim fileNameOnly As String
    fileNameOnly = Left(fileName, InStrRev(fileName, ".") - 1)
    
    ' Split filename by underscores
    fileParts = Split(fileNameOnly, "_")
    
    If UBound(fileParts) >= 2 Then
        fileVendor = fileParts(0)
        fileDate = fileParts(1)
        fileAmount = fileParts(2)
        
        ' Vendor matching (40% of total score)
        If UCase(CleanVendorName(fileVendor)) = UCase(CleanVendorName(vendor)) Then
            score = score + 0.4
            reasons = reasons & "Exact vendor match; "
        ElseIf InStr(UCase(CleanVendorName(fileVendor)), UCase(CleanVendorName(vendor))) > 0 Or _
               InStr(UCase(CleanVendorName(vendor)), UCase(CleanVendorName(fileVendor))) > 0 Then
            score = score + 0.25
            reasons = reasons & "Partial vendor match; "
        End If
        
        ' Date matching (35% of total score)
        Dim expectedDateString As String
        expectedDateString = Format(expenseDate, "yyyymmdd")
        
        If fileDate = expectedDateString Then
            score = score + 0.35
            reasons = reasons & "Exact date match; "
        ElseIf IsDate(Left(fileDate, 4) & "/" & Mid(fileDate, 5, 2) & "/" & Right(fileDate, 2)) Then
            Dim fileDateTime As Date
            fileDateTime = DateSerial(CInt(Left(fileDate, 4)), CInt(Mid(fileDate, 5, 2)), CInt(Right(fileDate, 2)))
            
            If Abs(fileDateTime - expenseDate) <= 3 Then
                score = score + 0.2
                reasons = reasons & "Date within 3 days; "
            ElseIf Abs(fileDateTime - expenseDate) <= 7 Then
                score = score + 0.1
                reasons = reasons & "Date within 1 week; "
            End If
        End If
        
        ' Amount matching (25% of total score)
        If IsNumeric(Replace(fileAmount, ".", "")) Then
            Dim fileAmountValue As Double
            fileAmountValue = CDbl(fileAmount)
            
            If Abs(fileAmountValue - amount) < 0.01 Then
                score = score + 0.25
                reasons = reasons & "Exact amount match; "
            ElseIf Abs(fileAmountValue - amount) < amount * 0.05 Then ' Within 5%
                score = score + 0.15
                reasons = reasons & "Amount within 5%; "
            ElseIf Abs(fileAmountValue - amount) < amount * 0.1 Then ' Within 10%
                score = score + 0.1
                reasons = reasons & "Amount within 10%; "
            End If
        End If
    Else
        ' Fallback matching for non-standard filenames
        If InStr(UCase(fileName), UCase(CleanVendorName(vendor))) > 0 Then
            score = score + 0.2
            reasons = reasons & "Vendor in filename; "
        End If
        
        If InStr(UCase(fileName), Format(expenseDate, "yyyymmdd")) > 0 Or _
           InStr(UCase(fileName), Format(expenseDate, "yyyy-mm-dd")) > 0 Then
            score = score + 0.15
            reasons = reasons & "Date in filename; "
        End If
    End If
    
    matchReason = Left(reasons, Len(reasons) - 2) ' Remove trailing "; "
    CalculatePhotoMatchScore = score
End Function

Private Function GetBestPhotoMatch(photoMatches() As PhotoMatch) As PhotoMatch
    ' Get the photo with the highest match score
    
    Dim bestMatch As PhotoMatch
    Dim i As Integer
    
    bestMatch.MatchScore = 0
    
    For i = 0 To UBound(photoMatches)
        If photoMatches(i).MatchScore > bestMatch.MatchScore Then
            bestMatch = photoMatches(i)
        End If
    Next i
    
    GetBestPhotoMatch = bestMatch
End Function

Private Sub LinkPhotoToExpense(ws As Worksheet, rowNum As Long, photoMatch As PhotoMatch)
    ' Create hyperlink from expense to photo file
    
    Dim photoCol As Integer
    photoCol = GetPhotoPathColumnIndex(ws)
    
    If photoCol > 0 Then
        ' Add hyperlink
        ws.Hyperlinks.Add Anchor:=ws.Cells(rowNum, photoCol), _
                          Address:=photoMatch.FilePath, _
                          TextToDisplay:="View Receipt"
        
        ' Add match confidence in adjacent column
        If photoCol + 1 <= ws.Columns.Count Then
            ws.Cells(rowNum, photoCol + 1).Value = Format(photoMatch.MatchScore, "0.0%") & " - " & photoMatch.MatchReason
            ws.Cells(rowNum, photoCol + 1).Font.Size = 8
        End If
    End If
End Sub

Private Sub AddPhotoPathColumn(ws As Worksheet)
    ' Add photo path column to worksheet if it doesn't exist
    
    Dim lastCol As Integer
    Dim photoCol As Integer
    
    photoCol = GetPhotoPathColumnIndex(ws)
    
    If photoCol = 0 Then
        lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
        
        ' Add headers
        ws.Cells(1, lastCol + 1).Value = "Receipt Photo"
        ws.Cells(1, lastCol + 2).Value = "Match Details"
        
        ' Format headers
        ws.Cells(1, lastCol + 1).Font.Bold = True
        ws.Cells(1, lastCol + 2).Font.Bold = True
        ws.Cells(1, lastCol + 1).Interior.Color = RGB(68, 114, 196)
        ws.Cells(1, lastCol + 2).Interior.Color = RGB(68, 114, 196)
        ws.Cells(1, lastCol + 1).Font.Color = RGB(255, 255, 255)
        ws.Cells(1, lastCol + 2).Font.Color = RGB(255, 255, 255)
        
        ' Set column widths
        ws.Columns(lastCol + 1).ColumnWidth = 15
        ws.Columns(lastCol + 2).ColumnWidth = 25
    End If
End Sub

Private Function GetPhotoPathColumnIndex(ws As Worksheet) As Integer
    ' Find the photo path column index
    
    Dim lastCol As Integer
    Dim i As Integer
    
    lastCol = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    
    For i = 1 To lastCol
        If UCase(ws.Cells(1, i).Value) = "RECEIPT PHOTO" Then
            GetPhotoPathColumnIndex = i
            Exit Function
        End If
    Next i
    
    GetPhotoPathColumnIndex = 0
End Function

' Helper functions
Private Function IsPhotoFile(fileName As String) As Boolean
    Dim ext As String
    Dim supportedExts() As String
    Dim i As Integer
    
    ext = LCase(Right(fileName, Len(fileName) - InStrRev(fileName, ".")))
    supportedExts = Split(SUPPORTED_EXTENSIONS, ",")
    
    For i = 0 To UBound(supportedExts)
        If ext = supportedExts(i) Then
            IsPhotoFile = True
            Exit Function
        End If
    Next i
    
    IsPhotoFile = False
End Function

Private Function CleanVendorName(vendor As String) As String
    ' Clean vendor name for better matching
    
    Dim cleaned As String
    cleaned = Trim(vendor)
    
    ' Remove common suffixes
    cleaned = Replace(cleaned, " Inc", "")
    cleaned = Replace(cleaned, " LLC", "")
    cleaned = Replace(cleaned, " Corp", "")
    cleaned = Replace(cleaned, " Ltd", "")
    cleaned = Replace(cleaned, ",", "")
    cleaned = Replace(cleaned, ".", "")
    
    CleanVendorName = cleaned
End Function

Private Function ExtractAmountFromCell(cellValue As Variant) As Double
    ' Extract numeric amount from cell value
    
    Dim cleanValue As String
    cleanValue = Trim(Replace(Replace(Replace(CStr(cellValue), "$", ""), ",", ""), " ", ""))
    
    If IsNumeric(cleanValue) Then
        ExtractAmountFromCell = CDbl(cleanValue)
    Else
        ExtractAmountFromCell = 0
    End If
End Function

Private Sub UpdateReceiptTrackerFromDiscovery()
    ' Update Receipt Tracker worksheet with photo discovery results
    
    Dim ws As Worksheet
    Set ws = GetWorksheet("Receipt Tracker")
    
    If ws Is Nothing Then Exit Sub
    
    ' Add photo status columns if they don't exist
    AddPhotoPathColumn ws
    
    ' This would scan the other worksheets and update the Receipt Tracker
    ' Implementation depends on how Receipt Tracker relates to expense sheets
End Sub

Public Sub ShowPhotoComplianceReport()
    ' Generate compliance report showing photo status
    
    Dim totalExpenses As Integer
    Dim expensesWithPhotos As Integer
    Dim missingPhotos As Integer
    Dim reportText As String
    
    ' Scan all expense worksheets for photo status
    Dim targetSheets As Variant
    targetSheets = Array("Business Expenses", "Home Office", "Vehicle & Travel", _
                        "Medical & Health", "Charitable Contributions", "Investment & Financial")
    
    Dim i As Integer
    Dim ws As Worksheet
    
    For i = 0 To UBound(targetSheets)
        Set ws = GetWorksheet(targetSheets(i))
        If Not ws Is Nothing Then
            Dim sheetStats As Variant
            sheetStats = AnalyzePhotoComplianceForSheet(ws)
            totalExpenses = totalExpenses + sheetStats(0)
            expensesWithPhotos = expensesWithPhotos + sheetStats(1)
        End If
    Next i
    
    missingPhotos = totalExpenses - expensesWithPhotos
    
    ' Build report
    reportText = "RECEIPT PHOTO COMPLIANCE REPORT" & vbCrLf & _
                "===============================" & vbCrLf & vbCrLf & _
                "Report Date: " & Format(Date, "mmmm dd, yyyy") & vbCrLf & vbCrLf & _
                "PHOTO STATUS SUMMARY:" & vbCrLf & _
                "• Total Expenses: " & totalExpenses & vbCrLf & _
                "• Expenses with Photos: " & expensesWithPhotos & vbCrLf & _
                "• Missing Photos: " & missingPhotos & vbCrLf & _
                "• Compliance Rate: " & Format(expensesWithPhotos / totalExpenses, "0.0%") & vbCrLf & vbCrLf
    
    If missingPhotos = 0 Then
        reportText = reportText & "✅ FULL COMPLIANCE ACHIEVED!" & vbCrLf & _
                    "All expenses have associated receipt photos."
    Else
        reportText = reportText & "⚠️ ACTION NEEDED:" & vbCrLf & _
                    "• Scan/photograph missing receipts" & vbCrLf & _
                    "• Follow naming convention for auto-linking" & vbCrLf & _
                    "• Run photo discovery after adding files"
    End If
    
    MsgBox reportText, vbInformation, "Photo Compliance Report"
End Sub

Private Function AnalyzePhotoComplianceForSheet(ws As Worksheet) As Variant
    ' Analyze photo compliance for a single worksheet
    
    Dim results(0 To 1) As Integer ' [total, with photos]
    Dim lastRow As Long
    Dim i As Long
    Dim photoCol As Integer
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    photoCol = GetPhotoPathColumnIndex(ws)
    
    For i = 2 To lastRow
        If IsDate(ws.Cells(i, "A").Value) Then
            results(0) = results(0) + 1 ' Total count
            
            If photoCol > 0 And ws.Cells(i, photoCol).Value <> "" Then
                results(1) = results(1) + 1 ' Has photo count
            End If
        End If
    Next i
    
    AnalyzePhotoComplianceForSheet = results
End Function