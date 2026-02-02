Option Explicit

' メインのインポート処理
Sub Import()
    Dim filePath As String
    Dim ws As Worksheet
    Dim csvData As Variant
    Dim rowCount As Long
    Dim colCount As Long

    ' 初期フォルダを設定
    Dim initialDir As String
    initialDir = ThisWorkbook.Path & "\output"
    If Dir(initialDir, vbDirectory) <> "" Then
        ChDir initialDir
    End If

    ' ファイル選択ダイアログを表示
    filePath = Application.GetOpenFilename( _
        "CSVファイル (*.csv),*.csv,すべてのファイル (*.*),*.*", _
        , _
        "インポートするCSVファイルを選択してください")

    ' キャンセルされた場合
    If filePath = "False" Then
        MsgBox "ファイル選択がキャンセルされました。", vbInformation
        Exit Sub
    End If

    ' Viewシートを取得
    Set ws = ThisWorkbook.Worksheets("View")

    ' シートをクリア
    ClearSheet ws

    ' CSVファイルを読み込み
    csvData = ReadCSVFile(filePath)

    If IsEmpty(csvData) Then
        MsgBox "CSVファイルの読み込みに失敗しました", vbCritical
        Exit Sub
    End If

    ' データをシートに書き込み
    rowCount = UBound(csvData, 1) - LBound(csvData, 1) + 1
    colCount = UBound(csvData, 2) - LBound(csvData, 2) + 1

    ws.Range("A1").Resize(rowCount, colCount).Value = csvData

    ' 書式設定
    FormatSheet ws, rowCount, colCount

    MsgBox "インポートが完了しました。" & vbCrLf & _
           "行数: " & rowCount & vbCrLf & _
           "列数: " & colCount, vbInformation
End Sub

' シートをクリアする関数
Private Sub ClearSheet(ws As Worksheet)
    ws.Cells.Clear
    ws.Cells.Interior.ColorIndex = xlNone
    ws.Cells.Borders.LineStyle = xlNone
End Sub

' CSVファイルを読み込む関数（UTF-8 BOM対応）
Private Function ReadCSVFile(filePath As String) As Variant
    Dim stream As Object
    Dim csvText As String
    Dim lines() As String
    Dim lineCount As Long
    Dim i As Long, j As Long
    Dim fields() As String
    Dim maxCols As Long
    Dim result() As Variant
    Dim tempLine As String

    On Error GoTo ErrorHandler

    ' ADODB.Streamを使用してUTF-8（BOM対応）で読み込み
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2 ' adTypeText
    stream.Charset = "UTF-8"
    stream.Open
    stream.LoadFromFile filePath
    csvText = stream.ReadText
    stream.Close
    Set stream = Nothing

    ' BOMを削除（存在する場合）
    If Len(csvText) > 0 Then
        If AscW(Left(csvText, 1)) = &HFEFF Then
            csvText = Mid(csvText, 2)
        End If
    End If

    ' 改行で分割
    lines = Split(csvText, vbLf)

    ' 空行を除外してカウント
    lineCount = 0
    For i = 0 To UBound(lines)
        tempLine = Replace(lines(i), vbCr, "")
        If Len(Trim(tempLine)) > 0 Then
            lineCount = lineCount + 1
        End If
    Next i

    If lineCount = 0 Then
        ReadCSVFile = Empty
        Exit Function
    End If

    ' 最大列数を取得（1行目から）
    tempLine = Replace(lines(0), vbCr, "")
    fields = ParseCSVLine(tempLine)
    maxCols = UBound(fields) + 1

    ' 結果配列を初期化
    ReDim result(1 To lineCount, 1 To maxCols)

    ' データを配列に格納
    Dim resultRow As Long
    resultRow = 0

    For i = 0 To UBound(lines)
        tempLine = Replace(lines(i), vbCr, "")
        If Len(Trim(tempLine)) > 0 Then
            resultRow = resultRow + 1
            fields = ParseCSVLine(tempLine)

            For j = 0 To UBound(fields)
                If j < maxCols Then
                    result(resultRow, j + 1) = fields(j)
                End If
            Next j
        End If
    Next i

    ReadCSVFile = result
    Exit Function

ErrorHandler:
    MsgBox "CSVファイルの読み込み中にエラーが発生しました: " & Err.Description, vbCritical
    ReadCSVFile = Empty
End Function

' CSV行をパースする関数（ダブルクォートに対応）
Private Function ParseCSVLine(line As String) As String()
    Dim result() As String
    Dim fields As New Collection
    Dim i As Long
    Dim currentField As String
    Dim inQuotes As Boolean
    Dim char As String

    currentField = ""
    inQuotes = False

    For i = 1 To Len(line)
        char = Mid(line, i, 1)

        If char = """" Then
            If inQuotes And i < Len(line) And Mid(line, i + 1, 1) = """" Then
                ' エスケープされたダブルクォート
                currentField = currentField & """"
                i = i + 1
            Else
                ' クォートの開始/終了
                inQuotes = Not inQuotes
            End If
        ElseIf char = "," And Not inQuotes Then
            ' フィールドの区切り
            fields.Add currentField
            currentField = ""
        Else
            currentField = currentField & char
        End If
    Next i

    ' 最後のフィールドを追加
    fields.Add currentField

    ' CollectionをArrayに変換
    ReDim result(0 To fields.Count - 1)
    For i = 1 To fields.Count
        result(i - 1) = fields(i)
    Next i

    ParseCSVLine = result
End Function

' シートの書式設定を行う関数
Private Sub FormatSheet(ws As Worksheet, rowCount As Long, colCount As Long)
    Dim dataRange As Range

    If rowCount < 1 Or colCount < 1 Then Exit Sub

    Set dataRange = ws.Range("A1").Resize(rowCount, colCount)

    ' 全体に罫線を設定
    With dataRange.Borders
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With

    ' 会社名列（A列）の背景をオレンジ色に
    With ws.Range("A1").Resize(rowCount, 1).Interior
        .Color = RGB(255, 192, 0) ' オレンジ色
    End With

    ' ヘッダー行の月部分（B1:最終列1）を青色に
    If colCount > 1 Then
        With ws.Range("B1").Resize(1, colCount - 1).Interior
            .Color = RGB(0, 112, 192) ' 青色
        End With

        ' ヘッダー行のフォント色を白に（見やすくするため）
        With ws.Range("B1").Resize(1, colCount - 1).Font
            .Color = RGB(255, 255, 255) ' 白色
            .Bold = True
        End With
    End If

    ' 会社名列のヘッダーもフォーマット
    With ws.Range("A1")
        .Font.Bold = True
    End With

    ' 列幅を自動調整
    dataRange.Columns.AutoFit

End Sub
