' ================================================================================
' E&N TAX TRACKER - RECURRING ENGINE
' Module: Core automation logic and main processing
' ================================================================================

Option Explicit

Public Sub GenerateRecurringExpenses()
    ' Main entry point for generating all recurring expenses
    ' Called by user button click or scheduled automation
    
    Dim ws As Worksheet
    Dim recurringWs As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim targetYear As Integer
    Dim generatedCount As Integer
    Dim errorCount As Integer
    Dim statusMsg As String
    
    On Error GoTo ErrorHandler
    
    ' Initialize
    targetYear = Year(Date)
    generatedCount = 0
    errorCount = 0
    
    ' Get the Recurring Setup worksheet
    Set recurringWs = GetWorksheet("Recurring Setup")
    If recurringWs Is Nothing Then
        MsgBox "Recurring Setup worksheet not found. Please set up recurring expenses first.", vbExclamation
        Exit Sub
    End If
    
    ' Show progress form
    Application.ScreenUpdating = False
    statusMsg = "Generating recurring expenses for " & targetYear & "..."
    Application.StatusBar = statusMsg
    
    ' Get last row of recurring setup data
    lastRow = recurringWs.Cells(recurringWs.Rows.Count, "A").End(xlUp).Row
    
    ' Process each recurring expense
    For i = 2 To lastRow ' Start from row 2 (skip headers)
        If recurringWs.Cells(i, "H").Value = "Active" Then ' Column H = Active Status
            If ProcessRecurringExpenseEnhanced(recurringWs, i, targetYear) Then
                generatedCount = generatedCount + 1
            Else
                errorCount = errorCount + 1
            End If
        End If
        
        ' Update progress
        Application.StatusBar = statusMsg & " Processing " & i - 1 & " of " & lastRow - 1
    Next i
    
    ' Refresh all formulas and calculations
    Application.CalculateFullRebuild
    
    ' Show completion message
    Application.ScreenUpdating = True
    Application.StatusBar = False
    
    MsgBox "Recurring expense generation complete!" & vbCrLf & _
           "Generated: " & generatedCount & " expense series" & vbCrLf & _
           "Errors: " & errorCount & " items", vbInformation, "E&N Tax Tracker"
    
    Exit Sub
    
ErrorHandler:
    Application.ScreenUpdating = True
    Application.StatusBar = False
    MsgBox "Error generating recurring expenses: " & Err.description, vbCritical
End Sub

Private Function ProcessRecurringExpenseEnhanced(recurringWs As Worksheet, rowNum As Long, targetYear As Integer) As Boolean
    ' Enhanced version with safe data reading
    
    Dim description As String
    Dim vendor As String
    Dim category As String
    Dim amount As Double
    Dim businessPercent As String
    Dim dayOfMonth As Integer
    Dim targetSheet As String
    Dim startMonth As Integer
    Dim endMonth As Integer
    Dim notes As String
    
    On Error GoTo ErrorHandler
    
    ' Use safe reading functions
    description = SafeReadCellValue(recurringWs, rowNum, "B", "TEXT")
    vendor = SafeReadCellValue(recurringWs, rowNum, "C", "TEXT")
    category = SafeReadCellValue(recurringWs, rowNum, "D", "TEXT")
    amount = SafeReadCellValue(recurringWs, rowNum, "E", "NUMBER")
    businessPercent = SafeReadCellValue(recurringWs, rowNum, "F", "PERCENT")
    dayOfMonth = SafeReadCellValue(recurringWs, rowNum, "G", "INTEGER")
    targetSheet = SafeReadCellValue(recurringWs, rowNum, "I", "TEXT")
    startMonth = SafeReadCellValue(recurringWs, rowNum, "J", "INTEGER")
    endMonth = SafeReadCellValue(recurringWs, rowNum, "K", "INTEGER")
    notes = SafeReadCellValue(recurringWs, rowNum, "L", "TEXT")
    
    ' Validate critical fields
    If description = "" Or vendor = "" Or category = "" Or amount <= 0 Or targetSheet = "" Then
        ProcessRecurringExpenseEnhanced = False
        Exit Function
    End If
    
    ' Continue with existing logic...
    Dim currentMonth As Integer
    Dim expenseDate As Date
    Dim targetWs As Worksheet
    
    Set targetWs = GetWorksheet(targetSheet)
    If targetWs Is Nothing Then
        ProcessRecurringExpenseEnhanced = False
        Exit Function
    End If
    
    ' Generate expenses for each month in range
    For currentMonth = startMonth To endMonth
        expenseDate = CalculateExpenseDate(targetYear, currentMonth, dayOfMonth)
        
        If Not ExpenseExists(targetWs, expenseDate, vendor, amount) Then
            AddExpenseToSheet targetWs, expenseDate, vendor, description, category, businessPercent, amount, True
        End If
    Next currentMonth
    
    ProcessRecurringExpenseEnhanced = True
    Exit Function
    
ErrorHandler:
    ProcessRecurringExpenseEnhanced = False
End Function

Private Function CalculateExpenseDate(targetYear As Integer, month As Integer, dayOfMonth As Integer) As Date
    ' Calculate the actual expense date with business logic
    
    Dim calculatedDate As Date
    Dim lastDayOfMonth As Date
    
    ' Handle end-of-month scenarios
    lastDayOfMonth = DateSerial(targetYear, month + 1, 0)
    
    ' If requested day doesn't exist in month (e.g., Feb 30), use last day of month
    If dayOfMonth > Day(lastDayOfMonth) Then
        calculatedDate = lastDayOfMonth
    Else
        calculatedDate = DateSerial(targetYear, month, dayOfMonth)
    End If
    
    ' Handle weekends for business expenses (move to next business day)
    Do While Weekday(calculatedDate) = 1 Or Weekday(calculatedDate) = 7 ' Sunday or Saturday
        calculatedDate = calculatedDate + 1
    Loop
    
    CalculateExpenseDate = calculatedDate
End Function

Private Function ExpenseExists(ws As Worksheet, expenseDate As Date, vendor As String, amount As Double) As Boolean
    ' Check if an expense already exists to prevent duplicates
    
    Dim lastRow As Long
    Dim i As Long
    Dim checkDate As Date
    Dim checkVendor As String
    Dim checkAmount As Double
    
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    For i = 2 To lastRow
        If IsDate(ws.Cells(i, "A").Value) Then
            checkDate = ws.Cells(i, "A").Value
            checkVendor = ws.Cells(i, "B").Value
            checkAmount = CDbl(ws.Cells(i, "F").Value)
            
            ' Match within 3 days, same vendor, same amount
            If Abs(checkDate - expenseDate) <= 3 And _
               UCase(checkVendor) = UCase(vendor) And _
               Abs(checkAmount - amount) < 0.01 Then
                ExpenseExists = True
                Exit Function
            End If
        End If
    Next i
    
    ExpenseExists = False
End Function

Private Sub AddExpenseToSheet(ws As Worksheet, expenseDate As Date, vendor As String, _
                              description As String, category As String, businessPercent As String, _
                              amount As Double, hasReceipt As Boolean)
    Dim nextRow As Long
    nextRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row + 1
    
    Select Case ws.Name
        Case "Business Expenses"
            ws.Cells(nextRow, "A").Value = expenseDate
            ws.Cells(nextRow, "B").Value = vendor
            ws.Cells(nextRow, "C").Value = description
            ws.Cells(nextRow, "D").Value = category
            ws.Cells(nextRow, "E").Value = CDbl(Replace(businessPercent, "%", "")) / 100
            ws.Cells(nextRow, "F").Value = amount
            ws.Cells(nextRow, "G").Value = "Yes"
            ws.Cells(nextRow, "E").NumberFormat = "0%"
            ws.Cells(nextRow, "F").NumberFormat = "_($* #,##0.00_);_($* (#,##0.00);_($* ""-""??_);_(@_)"
            
        Case "Home Office"
            ws.Cells(nextRow, "A").Value = expenseDate
            ws.Cells(nextRow, "B").Value = category ' Expense Type
            ws.Cells(nextRow, "C").Value = amount ' Total Amount
            ws.Cells(nextRow, "D").Value = CDbl(Replace(businessPercent, "%", "")) / 100 ' Business %
            ' Calculate deductible amount (Total Amount * Business %)
            Dim deductibleAmount As Double
            deductibleAmount = amount * (CDbl(Replace(businessPercent, "%", "")) / 100)
            ws.Cells(nextRow, "E").Value = deductibleAmount
            ' Format columns
            ws.Cells(nextRow, "C").NumberFormat = "_($* #,##0.00_);_($* (#,##0.00);_($* ""-""??_);_(@_)"
            ws.Cells(nextRow, "D").NumberFormat = "0.0%"
            ws.Cells(nextRow, "E").NumberFormat = "_($* #,##0.00_);_($* (#,##0.00);_($* ""-""??_);_(@_)"
            
            
        Case "Charitable Contributions"
            ws.Cells(nextRow, "A").Value = expenseDate
            ws.Cells(nextRow, "B").Value = vendor ' Organization
            ws.Cells(nextRow, "C").Value = category ' Type
            ws.Cells(nextRow, "D").Value = "Check" ' Method (default)
            ws.Cells(nextRow, "E").Value = amount
            ws.Cells(nextRow, "F").Value = "Yes"
            ws.Cells(nextRow, "G").Value = description
            ws.Cells(nextRow, "E").NumberFormat = "_($* #,##0.00_);_($* (#,##0.00);_($* ""-""??_);_(@_)"
            
        Case "Investment & Financial"
            ws.Cells(nextRow, "A").Value = expenseDate
            ws.Cells(nextRow, "B").Value = vendor ' Institution/Advisor
            ws.Cells(nextRow, "C").Value = category ' Type
            ws.Cells(nextRow, "D").Value = description
            ws.Cells(nextRow, "E").Value = amount
            ws.Cells(nextRow, "E").NumberFormat = "_($* #,##0.00_);_($* (#,##0.00);_($* ""-""??_);_(@_)"
            
        Case Else ' Default to Business Expenses format
            ' Same as Business Expenses case above
    End Select
    
    ' Add borders
    'ws.Range(ws.Cells(nextRow, "A"), ws.Cells(nextRow, 7)).Borders.LineStyle = xlContinuous | commented out due to formatting issues
End Sub


