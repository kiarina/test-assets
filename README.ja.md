# kiarina/test-assets

[English](README.md) | 日本語

このリポジトリは、複数のプロジェクト間で**共有テストアセット**（画像、動画、バイナリファイル、データセットなど）を配布するための専用リポジトリです。
実際のアセットファイルはリポジトリの履歴には**コミットされません**。
代わりに、[GitHub Release のアセット](https://github.com/kiarina/test-assets/releases)として公開されます。

---

## 📦 アセットのダウンロード方法

### GitHub CLI を使用する場合

```sh
mkdir -p tests/assets
gh release download --repo kiarina/test-assets v2025.09 -p kiarina-python-assets-v1.0.0.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.0.0.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.0.0.tar.zst
```

### curl / wget を使用する場合

[Releases](https://github.com/kiarina/test-assets/releases) ページから直接アセットのダウンロードリンクをコピーできます。

```sh
# 例: リリース v2025.09 からアセットをダウンロードする
curl -L -o kiarina-python-assets-v1.0.0.tar.zst \
  https://github.com/kiarina/test-assets/releases/download/v2025.09/kiarina-python-assets-v1.0.0.tar.zst
```

---

## 🏷️ アセットの命名規則

アセットのアーカイブ名は以下の規則に従うことを推奨します：
`{project-name}-assets-v{major}.{minor}.{patch}.tar.zst`

- **Major**: 破壊的変更（テストの修正が必要になるようなアセットの構造変更など）
- **Minor**: データの追加（新しいファイル、画像、テストケースの追加など）
- **Patch**: データの修正（テキストファイルの誤字修正や、破損した画像の差し替えなど）

---

## 🔑 バージョニングポリシー

* バージョンは `vYYYY.MM` または `vYYYY.MM.DD` の形式に従います。
* 各リリースには以下が含まれます:
  * 1つ以上のアセットアーカイブ (`*.tar.zst`)
  * チェックサムファイル (`SHA256SUMS`)
  * （オプション）内容を説明する `MANIFEST.md`
* 各利用プロジェクトは、リリースのバージョンを明示的に**ピン留め**する必要があります。

---

## 🛠 メンテナ向け: ワークスペースのセットアップ

リポジトリを軽量に保つため、`src/` 内の巨大なアセットファイルは Git で管理されていません。そのため、このリポジトリを clone した直後はアセットが空の状態です。

GitHub Releases から最新のアセットをダウンロードし、`src/` ディレクトリを再構築するには以下のコマンドを実行してください：
```sh
mise run setup
# またはバージョンを指定: mise run setup v2025.09
```
※このコマンドを実行するには GitHub CLI (`gh`) の認証が必要です。

---

## 🚀 新しいアセットのリリース方法

1. **アセットの配置**: 
   元となるアセットファイルを `src/{release-version}/{project-name}-assets-v{major}.{minor}.{patch}/` に配置します。
2. **マニフェストの更新**: 
   `src/{release-version}/MANIFEST.md` を作成または更新し、アセットの詳細を記載します。
3. **リリースのビルド**:
   ビルドコマンドを実行し、圧縮された `.tar.zst` アーカイブとチェックサムを生成します。
   ```sh
   make
   # またはバージョンを直接指定: make v2025.09
   ```
4. **GitHub への公開**:
   自動化された `release` タスクを使って、生成されたアセットを GitHub Release にアップロードします。背後で GitHub CLI (`gh`) が使用されます。
   ```sh
   mise run release
   # またはバージョンを直接指定: mise run release v2025.09
   ```

---

## 📥 利用者向け: 自動ダウンロードスクリプト

提供されているテストアセットを、ご自身のプロジェクト内で自動的に取得・展開するためのスクリプトを用意しています。

1. ご自身のプロジェクトに `.mise/tasks/download` を作成し、[こちらのスクリプト](https://github.com/kiarina/test-assets/blob/main/.mise/tasks/download) の内容をコピー＆ペーストしてください。
2. 以下のコマンドを実行すると、アセットのダウンロードと展開が行われます：
   ```sh
   mise run download v2025.09 kiarina-python v1.0.0
   ```
   デフォルトでは `./tests/assets` に展開され、自動的に `.gitignore` に追記されます。
3. 展開先ディレクトリを変更したい場合は、`--output-dir` フラグを使用します：
   ```sh
   mise run download --output-dir ./my/custom/path v2025.09 kiarina-python v1.0.0
   ```

---

## 🗂 リリースレイアウトの例

```
v2025.09/
  ├─ kiarina-python-assets-v1.0.0.tar.zst
  ├─ SHA256SUMS
  └─ MANIFEST.md   # ファイルの説明
```

---

## ⚡ GitHub Actions の例

プロジェクトで GitHub Actions を使用している場合、CIパイプラインの中でダウンロードスクリプトを使ってテストアセットを取得・キャッシュする完全なサンプルを用意しています。

👉 **完全なワークフローのサンプルは [`.github/workflows/ci.yml`](.github/workflows/ci.yml) をご覧ください。**

注意事項:

* `actions/cache` は、アセットを最大 **7日間の非アクティブ状態** かつ **リポジトリあたり10GB** まで保持します。
* 再現性を確保するために、**バージョン付きのキャッシュキー** (`test-assets-v2025.09`) を使用してください。
* セキュリティが重要な場合は、常に `sha256sum -c SHA256SUMS` を使用して整合性を確認してください。

---

## ⚖️ ライセンス

このリポジトリ自体は [MIT](./LICENSE) の下でライセンスされています。
個別のアセットのライセンス条件は、それぞれの `MANIFEST.md` ファイルに記載されています。
