@echo off
setlocal EnableDelayedExpansion
chcp 932 > nul
title batファイルエンコード変換ツール (Python版)

REM Pythonが使用可能かチェック
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo エラー: Pythonが見つかりませんでした。
    echo Pythonをインストールしてください: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM chardetライブラリが存在するかチェック
python -c "import chardet" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo chardetライブラリをインストールします...
    python -m pip install chardet
    if %ERRORLEVEL% NEQ 0 (
        echo エラー: chardetライブラリのインストールに失敗しました。
        echo 手動でインストールしてください: pip install chardet
        pause
        exit /b 1
    )
)

REM 引数があれば渡す、なければ対話モードでPythonスクリプトを実行
if "%~1"=="" (
    python "%~dp0batToAnsi.py"
) else (
    python "%~dp0batToAnsi.py" %*
)

exit /b %ERRORLEVEL%
