@echo off
setlocal EnableDelayedExpansion
chcp 932 > nul
title batファイルエンコード変換ツール - exe作成

echo ================================================
echo   batToAnsi.pyをexeファイルにコンパイルします
echo ================================================
echo.
echo この処理を実行すると、Pythonスクリプトが実行可能な
echo スタンドアロンのexeファイルに変換されます。
echo.
echo 必要なライブラリ:
echo  - pyinstaller (インストールされていなければ自動的にインストールします)
echo.
echo 続行するには何かキーを押してください...
pause >nul

REM Pythonが使用可能かチェック
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo エラー: Pythonが見つかりませんでした。
    echo Pythonをインストールしてください: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM pyinstallerがインストールされているかチェック
python -c "import PyInstaller" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo PyInstallerをインストールします...
    python -m pip install pyinstaller
    if %ERRORLEVEL% NEQ 0 (
        echo エラー: PyInstallerのインストールに失敗しました。
        echo 手動でインストールしてください: pip install pyinstaller
        pause
        exit /b 1
    )
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

echo.
echo PyInstallerでexeファイルをビルドしています...
echo.

REM pyinstallerでexeファイルをビルド
pyinstaller --onefile --windowed --icon=NONE --name=batToAnsi "%~dp0batToAnsi.py"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo エラー: exeファイルの作成に失敗しました。
    pause
    exit /b 1
)

echo.
echo ビルドが完了しました！
echo.
echo 実行ファイルは以下の場所にあります:
echo %~dp0dist\batToAnsi.exe
echo.
echo このファイルを任意の場所にコピーして使用できます。
echo.
pause
