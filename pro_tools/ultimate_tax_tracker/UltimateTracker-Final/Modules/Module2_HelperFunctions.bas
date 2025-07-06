' ================================================================================
' E&N TAX TRACKER - HELPER FUNCTIONS
' Module: Utilities, validation, and support functions
' ================================================================================

Option Explicit

Public Function GetWorksheet(sheetName As String) As Worksheet
    ' Safely get a worksheet by name
    
    Dim ws As Worksheet
    
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(sheetName)
    On Error GoTo 0
    
    Set GetWorksheet = ws
End Function

Public Sub ValidateRecurringDataStructure()
    ' Comprehensive validation of Recurring Setup data structure
    ' Call this BEFORE running expense generation
    
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim errorCount As Integer
    Dim warningCount As Integer
    Dim errorDetails As String
    Dim warningDetails As String
    
    Set ws = GetWorksheet("Recurring Setup")
    If ws Is Nothing Then
        MsgBox "Recurring Setup worksheet not found.", vbExclamation
        Exit Sub
    End If
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    errorCount = 0
    warningCount = 0
    errorDetails = "CRITICAL ERRORS (Must Fix):" & vbCrLf
    warningDetails = vbCrLf & "WARNINGS (Recommended Fixes):" & vbCrLf
    
    ' Validate each row
    For i = 2 To lastRow
        If ws.Cells(i, "A").Value <> "" Then ' Has Recurring ID
            
            ' CRITICAL VALIDATIONS (Will cause VBA failures)
            
            ' Check Column B - Description
            If Trim(ws.Cells(i, "B").Value) = "" Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Missing Description (Column B)" & vbCrLf
            End If
            
            ' Check Column C - Vendor/Payee
            If Trim(ws.Cells(i, "C").Value) = "" Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Missing Vendor/Payee (Column C)" & vbCrLf
            End If
            
            ' Check Column D - Category
            If Trim(ws.Cells(i, "D").Value) = "" Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Missing Category (Column D)" & vbCrLf
            End If
            
            ' Check Column E - Amount (Critical for VBA)
            Dim amountText As String
            amountText = Trim(Replace(Replace(ws.Cells(i, "E").Value, "$", ""), ",", ""))
            If Not IsNumeric(amountText) Or CDbl(amountText) <= 0 Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Invalid Amount (Column E): '" & ws.Cells(i, "E").Value & "'" & vbCrLf
            End If
            
            ' Check Column F - Business %
            If Trim(ws.Cells(i, "F").Value) = "" Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Missing Business % (Column F)" & vbCrLf
            End If
            
            ' Check Column G - Day of Month
            Dim dayText As String
            dayText = Trim(ws.Cells(i, "G").Value)
            If Not IsNumeric(dayText) Or CInt(dayText) < 1 Or CInt(dayText) > 31 Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Invalid Day of Month (Column G): '" & ws.Cells(i, "G").Value & "'" & vbCrLf
            End If
            
            ' Check Column H - Active Status
            Dim statusText As String
            statusText = UCase(Trim(ws.Cells(i, "H").Value))
            If statusText <> "ACTIVE" And statusText <> "INACTIVE" And statusText <> "PAUSED" Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Invalid Active Status (Column H): '" & ws.Cells(i, "H").Value & "'" & vbCrLf
            End If
            
            ' Check Column I - Target Sheet
            If Trim(ws.Cells(i, "I").Value) = "" Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Missing Target Sheet (Column I)" & vbCrLf
            Else
                ' Verify target sheet exists
                If GetWorksheet(ws.Cells(i, "I").Value) Is Nothing Then
                    errorCount = errorCount + 1
                    errorDetails = errorDetails & "Row " & i & ": Target Sheet doesn't exist: '" & ws.Cells(i, "I").Value & "'" & vbCrLf
                End If
            End If
            
            ' Check Columns J & K - Start/End Month
            If Not IsNumeric(ws.Cells(i, "J").Value) Or CInt(ws.Cells(i, "J").Value) < 1 Or CInt(ws.Cells(i, "J").Value) > 12 Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Invalid Start Month (Column J): '" & ws.Cells(i, "J").Value & "'" & vbCrLf
            End If
            
            If Not IsNumeric(ws.Cells(i, "K").Value) Or CInt(ws.Cells(i, "K").Value) < 1 Or CInt(ws.Cells(i, "K").Value) > 12 Then
                errorCount = errorCount + 1
                errorDetails = errorDetails & "Row " & i & ": Invalid End Month (Column K): '" & ws.Cells(i, "K").Value & "'" & vbCrLf
            End If
            
            ' WARNING VALIDATIONS (Won't break system but not ideal)
            
            ' Check for reasonable amounts
            If IsNumeric(amountText) Then
                If CDbl(amountText) > 5000 Then
                    warningCount = warningCount + 1
                    warningDetails = warningDetails & "Row " & i & ": Large amount (" & Format(CDbl(amountText), "$#,##0.00") & ") - verify correct" & vbCrLf
                End If
            End If
            
            ' Check for missing notes on large amounts
            If IsNumeric(amountText) And CDbl(amountText) > 1000 And Trim(ws.Cells(i, "L").Value) = "" Then
                warningCount = warningCount + 1
                warningDetails = warningDetails & "Row " & i & ": Large expense without notes - consider adding explanation" & vbCrLf
            End If
            
        End If
    Next i
    
    ' Display results
    Dim resultMsg As String
    
    If errorCount = 0 And warningCount = 0 Then
        resultMsg = "? VALIDATION PASSED!" & vbCrLf & vbCrLf & _
                   "No errors or warnings found." & vbCrLf & _
                   "Recurring Setup data is ready for generation."
        MsgBox resultMsg, vbInformation, "Data Validation Complete"
    ElseIf errorCount = 0 Then
        resultMsg = "? VALIDATION PASSED with " & warningCount & " warnings:" & vbCrLf & warningDetails & vbCrLf & _
                   "Safe to proceed with generation."
        MsgBox resultMsg, vbInformation, "Data Validation Complete"
    Else
        resultMsg = "? VALIDATION FAILED!" & vbCrLf & vbCrLf & _
                   "Found " & errorCount & " critical errors that must be fixed:" & vbCrLf & _
                   errorDetails
        If warningCount > 0 Then
            resultMsg = resultMsg & warningDetails
        End If
        resultMsg = resultMsg & vbCrLf & "Please fix errors before running expense generation."
        MsgBox resultMsg, vbCritical, "Data Validation Failed"
    End If
End Sub

Public Function SafeReadCellValue(ws As Worksheet, rowNum As Long, colLetter As String, dataType As String) As Variant
    ' Safely read cell values with type conversion and error handling
    ' dataType options: "TEXT", "NUMBER", "PERCENT", "INTEGER"
    
    Dim cellValue As Variant
    Dim cleanValue As String
    
    On Error GoTo ErrorHandler
    
    cellValue = ws.Cells(rowNum, colLetter).Value
    
    Select Case UCase(dataType)
        Case "TEXT"
            SafeReadCellValue = Trim(CStr(cellValue))
            
        Case "NUMBER"
            cleanValue = Trim(Replace(Replace(Replace(CStr(cellValue), "$", ""), ",", ""), " ", ""))
            If IsNumeric(cleanValue) Then
                SafeReadCellValue = CDbl(cleanValue)
            Else
                SafeReadCellValue = 0
            End If
            
        Case "PERCENT"
            cleanValue = Trim(Replace(CStr(cellValue), "%", ""))
            SafeReadCellValue = cleanValue & "%"
            
        Case "INTEGER"
            cleanValue = Trim(CStr(cellValue))
            If IsNumeric(cleanValue) Then
                SafeReadCellValue = CInt(cleanValue)
            Else
                SafeReadCellValue = 1
            End If
            
        Case Else
            SafeReadCellValue = cellValue
    End Select
    
    Exit Function
    
ErrorHandler:
    ' Return safe default values for each data type
    Select Case UCase(dataType)
        Case "TEXT": SafeReadCellValue = ""
        Case "NUMBER": SafeReadCellValue = 0
        Case "PERCENT": SafeReadCellValue = "100%"
        Case "INTEGER": SafeReadCellValue = 1
        Case Else: SafeReadCellValue = ""
    End Select
End Function

Public Sub QuickFixRecurringData()
    ' Quick fix for common CSV formatting issues
    
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim fixCount As Integer
    
    Set ws = GetWorksheet("Recurring Setup")
    If ws Is Nothing Then Exit Sub
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    fixCount = 0
    
    Application.ScreenUpdating = False
    
    For i = 2 To lastRow
        ' Fix amount formatting (remove $ and ,)
        If ws.Cells(i, "E").Value <> "" Then
            Dim amountText As String
            amountText = Replace(Replace(ws.Cells(i, "E").Value, "$", ""), ",", "")
            If IsNumeric(amountText) Then
                ws.Cells(i, "E").Value = CDbl(amountText)
                ws.Cells(i, "E").NumberFormat = "$#,##0.00"
                fixCount = fixCount + 1
            End If
        End If
        
        ' Ensure business % has % symbol
        If ws.Cells(i, "F").Value <> "" Then
            Dim percentText As String
            percentText = ws.Cells(i, "F").Value
            If Right(percentText, 1) <> "%" Then
                ws.Cells(i, "F").Value = percentText & "%"
            End If
        End If
    Next i
    
    Application.ScreenUpdating = True
    
    MsgBox "Quick fix complete! Fixed " & fixCount & " formatting issues.", vbInformation
End Sub


