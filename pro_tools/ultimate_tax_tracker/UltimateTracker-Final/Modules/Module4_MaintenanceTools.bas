' ================================================================================
' E&N TAX TRACKER - MAINTENANCE TOOLS
' Module: Backup, validation, and system maintenance
' ================================================================================

Option Explicit

Public Sub ValidateRecurringSetup()
    ' Legacy function - calls the enhanced validation
    ' Kept for backward compatibility
    
    ValidateRecurringDataStructure
End Sub

Public Sub BackupRecurringData()
    ' Create a backup copy of recurring expenses data
    
    Dim ws As Worksheet
    Dim backupWs As Worksheet
    Dim backupName As String
    
    Set ws = GetWorksheet("Recurring Setup")
    If ws Is Nothing Then
        MsgBox "Recurring Setup worksheet not found.", vbExclamation
        Exit Sub
    End If
    
    backupName = "Recurring Backup " & Format(Date, "yyyy-mm-dd")
    
    ' Delete existing backup if it exists
    On Error Resume Next
    ThisWorkbook.Worksheets(backupName).Delete
    Application.DisplayAlerts = False
    On Error GoTo 0
    Application.DisplayAlerts = True
    
    ' Create new backup
    ws.Copy After:=ws
    Set backupWs = ActiveSheet
    backupWs.Name = backupName
    
    ' Add timestamp to backup
    backupWs.Cells(1, 15).Value = "Backup Created:"
    backupWs.Cells(1, 16).Value = Now()
    backupWs.Cells(1, 15).Font.Bold = True
    backupWs.Cells(1, 16).NumberFormat = "mm/dd/yyyy hh:mm"
    
    MsgBox "Backup created: " & backupName, vbInformation
End Sub

Public Sub ArchiveGeneratedExpenses()
    ' Archive generated recurring expenses for record keeping
    
    Dim sourceSheets As Variant
    Dim archiveWs As Worksheet
    Dim ws As Worksheet
    Dim i As Integer
    Dim lastRow As Long
    Dim archiveRow As Long
    Dim j As Long
    
    ' Define worksheets that contain generated expenses
    sourceSheets = Array("Business Expenses", "Home Office", "Charitable Contributions", "Investment & Financial")
    
    ' Create or get archive worksheet
    Set archiveWs = GetWorksheet("Recurring Archive")
    If archiveWs Is Nothing Then
        Set archiveWs = ThisWorkbook.Worksheets.Add
        archiveWs.Name = "Recurring Archive"
        archiveWs.Move After:=ThisWorkbook.Worksheets("Recurring Setup")
        
        ' Add headers
        archiveWs.Cells(1, 1).Value = "Archive Date"
        archiveWs.Cells(1, 2).Value = "Source Sheet"
        archiveWs.Cells(1, 3).Value = "Date"
        archiveWs.Cells(1, 4).Value = "Vendor"
        archiveWs.Cells(1, 5).Value = "Description"
        archiveWs.Cells(1, 6).Value = "Category"
        archiveWs.Cells(1, 7).Value = "Business %"
        archiveWs.Cells(1, 8).Value = "Amount"
        archiveWs.Cells(1, 9).Value = "Receipt Status"
        
        ' Format headers
        archiveWs.Range("A1:I1").Font.Bold = True
        archiveWs.Range("A1:I1").Interior.Color = RGB(68, 114, 196)
        archiveWs.Range("A1:I1").Font.Color = RGB(255, 255, 255)
    End If
    
    archiveRow = archiveWs.Cells(archiveWs.Rows.Count, "A").End(xlUp).Row + 1
    
    ' Archive auto-generated expenses from each sheet
    For i = 0 To UBound(sourceSheets)
        Set ws = GetWorksheet(sourceSheets(i))
        If Not ws Is Nothing Then
            lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
            
            For j = 2 To lastRow
                ' Check if this is an auto-generated expense
                If ws.Cells(j, "G").Value = "Auto-Generated" Then
                    archiveWs.Cells(archiveRow, 1).Value = Date
                    archiveWs.Cells(archiveRow, 2).Value = sourceSheets(i)
                    archiveWs.Cells(archiveRow, 3).Value = ws.Cells(j, "A").Value
                    archiveWs.Cells(archiveRow, 4).Value = ws.Cells(j, "B").Value
                    archiveWs.Cells(archiveRow, 5).Value = ws.Cells(j, "C").Value
                    archiveWs.Cells(archiveRow, 6).Value = ws.Cells(j, "D").Value
                    archiveWs.Cells(archiveRow, 7).Value = ws.Cells(j, "E").Value
                    archiveWs.Cells(archiveRow, 8).Value = ws.Cells(j, "F").Value
                    archiveWs.Cells(archiveRow, 9).Value = ws.Cells(j, "G").Value
                    
                    archiveRow = archiveRow + 1
                End If
            Next j
        End If
    Next i
    
    MsgBox "Recurring expenses archived successfully!", vbInformation
End Sub

Public Sub CleanupOldBackups()
    ' Remove backup worksheets older than 30 days
    
    Dim ws As Worksheet
    Dim wsName As String
    Dim backupDate As Date
    Dim deletedCount As Integer
    
    deletedCount = 0
    Application.DisplayAlerts = False
    
    For Each ws In ThisWorkbook.Worksheets
        wsName = ws.Name
        
        ' Check if this is a backup worksheet
        If Left(wsName, 16) = "Recurring Backup" Then
            ' Extract date from name (format: "Recurring Backup yyyy-mm-dd")
            If Len(wsName) >= 27 Then
                On Error Resume Next
                backupDate = DateValue(Mid(wsName, 18))
                On Error GoTo 0
                
                ' Delete if older than 30 days
                If backupDate > 0 And Date - backupDate > 30 Then
                    ws.Delete
                    deletedCount = deletedCount + 1
                End If
            End If
        End If
    Next ws
    
    Application.DisplayAlerts = True
    
    MsgBox "Cleanup complete! Removed " & deletedCount & " old backup worksheets.", vbInformation
End Sub

Public Sub GenerateMaintenanceReport()
    ' Generate a comprehensive maintenance report
    
    Dim reportText As String
    Dim recurringWs As Worksheet
    Dim lastRow As Long
    Dim activeCount As Integer
    Dim inactiveCount As Integer
    Dim errorCount As Integer
    Dim backupCount As Integer
    Dim i As Long
    Dim ws As Worksheet
    
    ' Count backup worksheets
    For Each ws In ThisWorkbook.Worksheets
        If Left(ws.Name, 16) = "Recurring Backup" Then
            backupCount = backupCount + 1
        End If
    Next ws
    
    ' Analyze recurring setup
    Set recurringWs = GetWorksheet("Recurring Setup")
    If Not recurringWs Is Nothing Then
        lastRow = recurringWs.Cells(recurringWs.Rows.Count, "A").End(xlUp).Row
        
        For i = 2 To lastRow
            If recurringWs.Cells(i, "A").Value <> "" Then
                If UCase(recurringWs.Cells(i, "H").Value) = "ACTIVE" Then
                    activeCount = activeCount + 1
                Else
                    inactiveCount = inactiveCount + 1
                End If
                
                ' Quick error check
                If Trim(recurringWs.Cells(i, "B").Value) = "" Or _
                   Trim(recurringWs.Cells(i, "C").Value) = "" Or _
                   Not IsNumeric(Replace(Replace(recurringWs.Cells(i, "E").Value, "$", ""), ",", "")) Then
                    errorCount = errorCount + 1
                End If
            End If
        Next i
    End If
    
    ' Build maintenance report
    reportText = "E&N TAX TRACKER - MAINTENANCE REPORT" & vbCrLf & _
                "=====================================" & vbCrLf & vbCrLf & _
                "Report Date: " & Format(Date, "mmmm dd, yyyy") & vbCrLf & _
                "System Time: " & Format(Time, "hh:mm AM/PM") & vbCrLf & vbCrLf & _
                "RECURRING EXPENSES STATUS:" & vbCrLf & _
                "• Active Expenses: " & activeCount & vbCrLf & _
                "• Inactive Expenses: " & inactiveCount & vbCrLf & _
                "• Data Errors Found: " & errorCount & vbCrLf & vbCrLf & _
                "SYSTEM HEALTH:" & vbCrLf & _
                "• Backup Worksheets: " & backupCount & vbCrLf & _
                "• Last Validation: " & IIf(errorCount = 0, "PASSED", "FAILED") & vbCrLf & vbCrLf & _
                "RECOMMENDATIONS:" & vbCrLf
    
    If errorCount > 0 Then
        reportText = reportText & "• Run data validation to fix errors" & vbCrLf
    End If
    
    If backupCount = 0 Then
        reportText = reportText & "• Create backup of recurring data" & vbCrLf
    ElseIf backupCount > 5 Then
        reportText = reportText & "• Consider cleaning up old backups" & vbCrLf
    End If
    
    If activeCount = 0 Then
        reportText = reportText & "• Set up recurring expenses to save time" & vbCrLf
    End If
    
    reportText = reportText & vbCrLf & "System Status: " & IIf(errorCount = 0, "HEALTHY", "NEEDS ATTENTION")
    
    MsgBox reportText, vbInformation, "Maintenance Report"
End Sub

Public Sub ResetRecurringSystem()
    ' Reset the recurring expense system (use with caution)
    
    Dim response As VbMsgBoxResult
    Dim ws As Worksheet
    
    response = MsgBox("WARNING: This will reset the entire recurring expense system!" & vbCrLf & vbCrLf & _
                     "This action will:" & vbCrLf & _
                     "• Clear all recurring setup data" & vbCrLf & _
                     "• Remove all auto-generated expenses" & vbCrLf & _
                     "• Delete backup worksheets" & vbCrLf & vbCrLf & _
                     "This cannot be undone. Continue?", _
                     vbYesNo + vbCritical + vbDefaultButton2, "Reset Recurring System")
    
    If response = vbYes Then
        response = MsgBox("Are you absolutely sure? This will delete all recurring data!", _
                         vbYesNo + vbCritical + vbDefaultButton2, "Final Confirmation")
        
        If response = vbYes Then
            Application.DisplayAlerts = False
            
            ' Clear recurring setup data (keep headers)
            Set ws = GetWorksheet("Recurring Setup")
            If Not ws Is Nothing Then
                ws.Range("A2:L1000").Clear
            End If
            
            ' Delete backup worksheets
            For Each ws In ThisWorkbook.Worksheets
                If Left(ws.Name, 16) = "Recurring Backup" Then
                    ws.Delete
                End If
            Next ws
            
            ' Delete archive worksheet
            Set ws = GetWorksheet("Recurring Archive")
            If Not ws Is Nothing Then
                ws.Delete
            End If
            
            Application.DisplayAlerts = True
            
            MsgBox "Recurring expense system has been reset.", vbInformation
        End If
    End If
End Sub


