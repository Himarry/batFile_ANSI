#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
batToAnsi.py - batファイルのエンコード形式をANSI(CP932)に変換するツール

使用方法:
    1. スクリプトを直接実行: python batToAnsi.py 
       対話モードで起動します。

    2. コマンドライン引数を指定: python batToAnsi.py [ファイルパス/フォルダパス]
       指定されたファイルまたはフォルダ内のbatファイルを変換します。
       
    3. ドラッグ＆ドロップ: batファイルをこのPythonスクリプトにドラッグ＆ドロップ
       ドロップされたファイルを変換します。

必要なライブラリ:
    chardet - エンコーディング自動検出のために必要
    インストール方法: pip install chardet
"""

import os
import sys
import shutil
import tempfile
import chardet
from pathlib import Path
import traceback


def detect_encoding(file_path):
    """ファイルのエンコーディングを検出する"""
    try:
        with open(file_path, 'rb') as f:
            raw_data = f.read()
            
        # BOMの確認
        if raw_data.startswith(b'\xef\xbb\xbf'):
            print(f"  - UTF-8 (BOM付き) エンコーディングを検出しました: {file_path}")
            return 'utf-8-sig', raw_data
        elif raw_data.startswith(b'\xff\xfe'):
            print(f"  - UTF-16 LE エンコーディングを検出しました: {file_path}")
            return 'utf-16-le', raw_data
        elif raw_data.startswith(b'\xfe\xff'):
            print(f"  - UTF-16 BE エンコーディングを検出しました: {file_path}")
            return 'utf-16-be', raw_data
            
        # BOMがない場合はchardetで検出を試みる
        result = chardet.detect(raw_data)
        encoding = result['encoding']
        confidence = result['confidence']
        
        if encoding:
            print(f"  - {encoding} エンコーディングを検出しました (信頼度: {confidence:.2f}): {file_path}")
            return encoding, raw_data
        else:
            print(f"  - エンコーディングを検出できませんでした。UTF-8として処理します: {file_path}")
            return 'utf-8', raw_data
    except Exception as e:
        print(f"エラー: エンコーディング検出中に問題が発生しました: {e}")
        return None, None


def convert_to_ansi(file_path):
    """ファイルをANSI(CP932)に変換する"""
    if not os.path.isfile(file_path):
        print(f"エラー: ファイルが存在しません: {file_path}")
        return False
        
    # 拡張子を確認
    if not file_path.lower().endswith('.bat'):
        print(f"警告: {file_path} はbatファイルではありません。スキップします。")
        return False
        
    print(f"処理中: {file_path}")
    
    # エンコーディング検出
    encoding, raw_data = detect_encoding(file_path)
    if encoding is None or raw_data is None:
        return False
    
    try:
        # 一時ファイルを作成
        fd, temp_path = tempfile.mkstemp(suffix='.bat', prefix='temp_convert_')
        os.close(fd)
        
        # 内容をデコードしてからANSIエンコードで書き出す
        try:
            # 検出されたエンコーディングでデコード
            content = raw_data.decode(encoding, errors='replace')
            
            # ANSI(CP932)で書き出す
            with open(temp_path, 'w', encoding='cp932', errors='replace') as f:
                f.write(content)
                
            # 一時ファイルを元のファイルにコピー
            shutil.copy2(temp_path, file_path)
            print(f"変換完了: {file_path}")
            return True
        finally:
            # 一時ファイルを削除
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except:
                pass
    except Exception as e:
        print(f"エラー: ファイル変換中に問題が発生しました: {e}")
        print(traceback.format_exc())
        return False


def process_directory(dir_path):
    """フォルダ内のすべてのbatファイルを処理する"""
    if not os.path.isdir(dir_path):
        print(f"エラー: フォルダが存在しません: {dir_path}")
        return 0
        
    print(f"\nフォルダ {dir_path} 内のbatファイルを検索中...")
    count = 0
    
    for root, _, files in os.walk(dir_path):
        for file in files:
            if file.lower().endswith('.bat'):
                file_path = os.path.join(root, file)
                if convert_to_ansi(file_path):
                    count += 1
    
    return count


def main():
    """メイン処理"""
    print("=" * 50)
    print("  batファイルのエンコードをANSI(CP932)に変換するツール")
    print("  バージョン: 1.0 (Python版)")
    print("=" * 50)
    print("\n使用方法:")
    print(" 1. 個別のbatファイル: ファイルをドラッグアンドドロップするか、パスを入力")
    print(" 2. 複数のbatファイル: フォルダのパスを入力")
    print("\n終了するには「exit」と入力してください\n")
    
    # コマンドライン引数がある場合は処理
    if len(sys.argv) > 1:
        path = sys.argv[1]
        process_path(path)
    else:
        # 対話モードで実行
        while True:
            user_input = input("\n変換したいファイルまたはフォルダのパスを入力してください: ")
            
            if user_input.lower() == 'exit':
                break
                
            if not user_input:
                continue
                
            process_path(user_input)
            print("\n別のファイルやフォルダを変換する場合は、パスを入力してください。")


def process_path(path):
    """パスを処理する"""
    # 引用符を削除（ドラッグ＆ドロップ時の対応）
    path = path.strip('"')
    
    if os.path.isdir(path):
        # フォルダの場合
        count = process_directory(path)
        if count == 0:
            print(f"フォルダ内にbatファイルは見つかりませんでした: {path}")
        else:
            print(f"合計 {count} 個のbatファイルの変換が完了しました。")
    elif os.path.isfile(path):
        # ファイルの場合
        convert_to_ansi(path)
    else:
        print(f"エラー: 指定されたパスが見つかりません: {path}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nプログラムが中断されました。")
    except Exception as e:
        print(f"\n\nエラーが発生しました: {e}")
        print(traceback.format_exc())
    finally:
        # Windows環境では終了前に一時停止
        if os.name == 'nt' and len(sys.argv) <= 1:
            input("\nエンターキーを押して終了...")
