param(
    [string[]]$FilePaths
)

function ConvertToANSI {
    param (
        [string]$FilePath
    )

    # ファイルが存在するか確認
    if (-not (Test-Path -Path $FilePath)) {
        Write-Host "エラー: ファイルが見つかりません: $FilePath" -ForegroundColor Red
        return
    }

    # 拡張子がbatかどうか確認
    if ([System.IO.Path]::GetExtension($FilePath) -ne ".bat") {
        Write-Host "警告: '$FilePath' はbatファイルではありません。スキップします。" -ForegroundColor Yellow
        return
    }    try {
        # バイナリモードでファイルを読み取る
        $bytes = [System.IO.File]::ReadAllBytes($FilePath)
        $content = $null

        # エンコーディングを自動検出
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
            # UTF-8 with BOM
            Write-Host "  - UTF-8(BOM) エンコーディングを検出しました" -ForegroundColor Cyan
            $utf8 = New-Object System.Text.UTF8Encoding $false
            $content = $utf8.GetString($bytes, 3, $bytes.Length - 3)
        } 
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 255 -and $bytes[1] -eq 254) {
            # Unicode (UTF-16 Little Endian)
            Write-Host "  - Unicode エンコーディングを検出しました" -ForegroundColor Cyan
            $content = [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
        } 
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 254 -and $bytes[1] -eq 255) {
            # Unicode Big Endian
            Write-Host "  - Unicode (Big Endian) エンコーディングを検出しました" -ForegroundColor Cyan
            $content = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
        } 
        else {
            # その他のエンコーディングはUTF-8として試す
            Write-Host "  - エンコーディング不明、UTF-8として処理します" -ForegroundColor Yellow
            $utf8 = New-Object System.Text.UTF8Encoding $false
            $content = $utf8.GetString($bytes)
        }

        # ANSIエンコーディング(日本語Windows環境ではCP932/Shift-JIS)で書き出し
        [System.IO.File]::WriteAllText($FilePath, $content, [System.Text.Encoding]::GetEncoding(932))
        Write-Host "変換完了: $FilePath" -ForegroundColor Green
    }
    catch {
        Write-Host "エラー: ファイルの処理中に問題が発生しました: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function ProcessFolder {
    param (
        [string]$FolderPath
    )

    # フォルダ内のすべてのbatファイルを取得
    $batFiles = Get-ChildItem -Path $FolderPath -Filter "*.bat" -Recurse

    if ($batFiles.Count -eq 0) {
        Write-Host "フォルダ内にbatファイルは見つかりませんでした: $FolderPath" -ForegroundColor Yellow
        return 0
    }

    Write-Host "フォルダ '$FolderPath' 内の $($batFiles.Count) 個のbatファイルを処理中..." -ForegroundColor Cyan

    # 各batファイルを処理
    foreach ($file in $batFiles) {
        ConvertToANSI -FilePath $file.FullName
    }

    return $batFiles.Count
}

# メイン処理
function Main {
    Clear-Host
    Write-Host "================================================"
    Write-Host "   batファイルのエンコードをANSI(CP932)に変換するツール   "
    Write-Host "   バージョン: 1.1 (エンコーディング自動検出機能追加)"
    Write-Host "================================================`n"
    Write-Host "使用方法:"
    Write-Host " 1. 個別のbatファイル: ファイルをドラッグアンドドロップしてください"
    Write-Host " 2. 複数のbatファイル: フォルダのパスを入力してください"
    Write-Host " 3. 終了するには「exit」と入力してください`n"

    # パラメータが指定されている場合は処理
    if ($FilePaths.Count -gt 0) {
        foreach ($path in $FilePaths) {
            ProcessPath -Path $path
        }
    }    # メインループ
    while ($true) {
        $userInput = Read-Host -Prompt "変換したいファイルまたはフォルダのパスを入力してください"
        if ($userInput -eq "exit") {
            break
        }
        
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            continue
        }

        ProcessPath -Path $userInput
        Write-Host "`n別のファイルやフォルダを変換する場合は、パスを入力してください。"
    }
}

function ProcessPath {
    param (
        [string]$Path
    )

    if ([string]::IsNullOrEmpty($Path)) {
        return
    }

    # パスの先頭と末尾の引用符を削除（ドラッグ&ドロップ時の対応）
    $Path = $Path.Trim('"')

    # フォルダかファイルかを判定
    if (Test-Path -Path $Path -PathType Container) {
        # フォルダの場合
        $count = ProcessFolder -FolderPath $Path
        if ($count -gt 0) {
            Write-Host "合計 $count 個のbatファイルの変換が完了しました。" -ForegroundColor Green
        }
    }
    elseif (Test-Path -Path $Path -PathType Leaf) {
        # ファイルの場合
        ConvertToANSI -FilePath $Path
    }
    else {
        Write-Host "エラー: 指定されたパスが見つかりません: $Path" -ForegroundColor Red
    }
}

# スクリプトを実行
Main
