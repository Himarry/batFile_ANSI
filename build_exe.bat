@echo off

setlocal EnableDelayedExpansion

chcp 932 > nul

title bat�t�@�C���G���R�[�h�ϊ��c�[�� - exe�쐬



echo ================================================

echo   batToAnsi.py��exe�t�@�C���ɃR���p�C�����܂�

echo ================================================

echo.

echo ���̏��������s����ƁAPython�X�N���v�g�����s�\��

echo �X�^���h�A������exe�t�@�C���ɕϊ�����܂��B

echo.

echo �K�v�ȃ��C�u����:

echo  - pyinstaller (�C���X�g�[������Ă��Ȃ���Ύ����I�ɃC���X�g�[�����܂�)

echo.

echo ���s����ɂ͉����L�[�������Ă�������...

pause >nul



REM Python���g�p�\���`�F�b�N

where python >nul 2>nul

if %ERRORLEVEL% NEQ 0 (

    echo �G���[: Python��������܂���ł����B

    echo Python���C���X�g�[�����Ă�������: https://www.python.org/downloads/

    pause

    exit /b 1

)



REM pyinstaller���C���X�g�[������Ă��邩�`�F�b�N

python -c "import PyInstaller" >nul 2>nul

if %ERRORLEVEL% NEQ 0 (

    echo PyInstaller���C���X�g�[�����܂�...

    python -m pip install pyinstaller

    if %ERRORLEVEL% NEQ 0 (

        echo �G���[: PyInstaller�̃C���X�g�[���Ɏ��s���܂����B

        echo �蓮�ŃC���X�g�[�����Ă�������: pip install pyinstaller

        pause

        exit /b 1

    )

)



REM chardet���C�u���������݂��邩�`�F�b�N

python -c "import chardet" >nul 2>nul

if %ERRORLEVEL% NEQ 0 (

    echo chardet���C�u�������C���X�g�[�����܂�...

    python -m pip install chardet

    if %ERRORLEVEL% NEQ 0 (

        echo �G���[: chardet���C�u�����̃C���X�g�[���Ɏ��s���܂����B

        echo �蓮�ŃC���X�g�[�����Ă�������: pip install chardet

        pause

        exit /b 1

    )

)



echo.

echo PyInstaller��exe�t�@�C�����r���h���Ă��܂�...

echo.



REM pyinstaller��exe�t�@�C�����r���h

pyinstaller --onefile --windowed --icon=NONE --name=batToAnsi "%~dp0batToAnsi.py"



if %ERRORLEVEL% NEQ 0 (

    echo.

    echo �G���[: exe�t�@�C���̍쐬�Ɏ��s���܂����B

    pause

    exit /b 1

)



echo.

echo �r���h���������܂����I

echo.

echo ���s�t�@�C���͈ȉ��̏ꏊ�ɂ���܂�:

echo %~dp0dist\batToAnsi.exe

echo.

echo ���̃t�@�C����C�ӂ̏ꏊ�ɃR�s�[���Ďg�p�ł��܂��B

echo.

pause

