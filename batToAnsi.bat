@echo off
setlocal EnableDelayedExpansion
chcp 932 > nul
title batファイルエンコード変換ツール

echo ================================================
echo   batファイルのエンコードをANSI(CP932)に変換するツール
echo ================================================
echo.
echo 使用方法:
echo  1. 個別のbatファイル: ファイルをドラッグアンドドロップしてください
echo  2. 複数のbatファイル: フォルダのパスを入力してください
echo.
echo 終了するには「exit」と入力してください
echo.

:MAIN_LOOP
set "input="
set /p "input=変換したいファイルまたはフォルダのパスを入力してください: "

if /i "%input%"=="exit" goto :EOF
if not defined input goto MAIN_LOOP

if exist "%input%\" (
    rem フォルダの場合
    echo.
    echo フォルダ "%input%" 内のbatファイルを検索中...
    set "found=0"
    for /r "%input%" %%f in (*.bat) do (
        set /a found+=1
        call :CONVERT_FILE "%%f"
    )
    
    if !found! EQU 0 (
        echo フォルダ内にbatファイルは見つかりませんでした。
    ) else (
        echo 合計 !found! 個のbatファイルの変換が完了しました。
    )
) else if exist "%input%" (
    rem 単一ファイルの場合
    call :CONVERT_FILE "%input%"
) else (
    echo 指定されたパスが見つかりません: "%input%"
)

echo.
echo 別のファイルやフォルダを変換する場合は、パスを入力してください。
goto MAIN_LOOP

:CONVERT_FILE
set "file=%~1"
set "ext=%~x1"

if /i not "%ext%"==".bat" (
    echo "%file%" はbatファイルではありません。スキップします。
    exit /b
)

echo 処理中: "%file%"

rem 一時ファイルを作成
set "temp_file=%TEMP%\temp_convert_%RANDOM%.txt"

rem ファイルをANSI(CP932)エンコードで書き出す
powershell -Command "$content = Get-Content -Path '%file%' -Raw; [System.IO.File]::WriteAllText('%temp_file%', $content, [System.Text.Encoding]::GetEncoding(932))"

if %ERRORLEVEL% NEQ 0 (
    echo エラー: "%file%" の変換に失敗しました。
    if exist "%temp_file%" del "%temp_file%"
    exit /b
)

rem 一時ファイルを元のファイルに上書き
copy /Y "%temp_file%" "%file%" > nul
if %ERRORLEVEL% NEQ 0 (
    echo エラー: "%file%" の上書きに失敗しました。
    if exist "%temp_file%" del "%temp_file%"
    exit /b
)

rem 一時ファイルを削除
if exist "%temp_file%" del "%temp_file%"

echo 変換完了: "%file%"
exit /b
