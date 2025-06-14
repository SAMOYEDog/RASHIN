# RASHIN

![alt text](images/slide_1.png)

RASHINは、位置情報データの収集・可視化・共有を目的としたアプリケーションです。iOSクライアントとサーバーサイド（AWS, supabase等）で構成されています。

![alt text](images/slide_2.png)


## 実証試験結果

San Franciscoの警察の事件に関する報告書とRASHINが取得したデータの比較画像です．

![alt text](images/slide_3.png)

## ディレクトリ構成
```
├── client/           # iOSクライアプリ本体（SwiftUI）
├── server/           # サーバーサイド（AWS, supabase等）
├── docs/             # 技術資料・設計ドキュメント
├── data/             # 実証試験のデータ
└── README.md         # 本ファイル
```

## インストール

### クライアント（iOSアプリ）
1. `client/Rashin_β.xcodeproj` をXcodeで開く
2. 必要に応じて依存パッケージをインストール
3. シミュレータまたは実機でビルド・実行

### サーバー
- `server/` 以下にサーバーサイドのスクリプトや設定ファイルがあります。
- 詳細は各ディレクトリのREADME.mdを参照してください。

## 使い方
1. iOSアプリを起動し、位置情報の取得・共有を行う
2. サーバー側でデータを管理・解析
3. 必要に応じて`data/`のデータを活用

## ライセンス
本プロジェクトのライセンスはGPLです。

---

各ディレクトリの詳細は、それぞれのREADME.mdを参照してください。

