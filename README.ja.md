# kiarina/test-assets

[English](README.md) | 日本語

このリポジトリは、複数のプロジェクト間で**共有テストアセット**（画像、動画、バイナリファイル、データセットなど）を配布するための専用リポジトリです。
実際のアセットファイルはリポジトリの履歴には**コミットされません**。
代わりに、[GitHub Release のアセット](https://github.com/kiarina/test-assets/releases)として公開されます。

---

## 📦 テストアセットの仕組み

このリポジトリのテストアセットは、**リリースバージョン (Release Version)** と **アセット名 (Asset Name)** の組み合わせで管理されます。これにより、利用側のプロジェクトは必要なデータだけを選択的にダウンロードし、安定したスナップショットに固定（ピン留め）することができます。

### 🔑 リリースバージョン (バージョニングポリシー)
リリースバージョンは、特定の時点におけるアセットの安定したスナップショットを表します。
- バージョンは `vYYYY.MM` または `vYYYY.MM.DD` の形式に従います（例: `v2025.09`）。
- 各リリースには、1つ以上のアセットアーカイブ (`*.tar.zst`)、チェックサムファイル (`SHA256SUMS`)、および内容を説明する `MANIFEST.md` が含まれます。
- 各利用プロジェクトは、このリリースバージョンを明示的に**ピン留め**して使用してください。

### 🏷️ アセット名 (命名規則)
リリース内に含まれる個々のアセットアーカイブは、以下のセマンティックな規則に従って命名されます：
`{project-name}-assets-v{major}.{minor}.{patch}.tar.zst`

- **Major**: 破壊的変更（テストの修正が必要になるようなアセットの構造変更など）
- **Minor**: データの追加（新しいファイル、画像、テストケースの追加など）
- **Patch**: データの修正（テキストファイルの誤字修正や、破損した画像の差し替えなど）

### 🗂 構造の例
リリース内部のレイアウトは以下のようになっています：
```
v2025.09/
  ├─ kiarina-python-assets-v1.0.0.tar.zst
  ├─ SHA256SUMS
  └─ MANIFEST.md   # ファイルの説明
```

---

## 👤 利用者向け (For Consumers)

プロジェクトでこれらのアセットを利用したい場合、いくつかのダウンロード方法があります。

### 📥 自動ダウンロードスクリプト

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

### ⚡ GitHub Actions の例

プロジェクトで GitHub Actions を使用している場合、CIパイプラインの中でダウンロードスクリプトを使ってテストアセットを取得・キャッシュする完全なサンプルを用意しています。

👉 **完全なワークフローのサンプルは [`.github/workflows/ci.yml`](.github/workflows/ci.yml) をご覧ください。**

### 📦 手動でのダウンロード

自動化スクリプトを使用しない場合は、手動でダウンロードして展開することも可能です。

**GitHub CLI を使用する場合:**
```sh
mkdir -p tests/assets
gh release download --repo kiarina/test-assets v2025.09 -p kiarina-python-assets-v1.0.0.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.0.0.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.0.0.tar.zst
```

**curl / wget を使用する場合:**
```sh
# 例: リリース v2025.09 からアセットをダウンロードする
curl -L -o kiarina-python-assets-v1.0.0.tar.zst \
  https://github.com/kiarina/test-assets/releases/download/v2025.09/kiarina-python-assets-v1.0.0.tar.zst
```

---

## 🛠 メンテナ向け (For Maintainers)

このリポジトリを管理し、新しいアセットを追加・更新する手順です。

### ⚙️ ワークスペースのセットアップ

リポジトリを軽量に保つため、`src/` 内の巨大なアセットファイルは Git で管理されていません。そのため、このリポジトリを clone した直後はアセットが空の状態です。

GitHub Releases から最新のアセットをダウンロードし、`src/` ディレクトリを再構築するには以下のコマンドを実行してください：
```sh
mise run setup
# またはバージョンを指定: mise run setup v2025.09
```
※このコマンドを実行するには GitHub CLI (`gh`) の認証が必要です。

### 🚀 新しいアセットのリリース方法

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
   make release
   # またはバージョンを直接指定: mise run release v2025.09
   ```

---

## ⚖️ ライセンス

このリポジトリ自体は [MIT](./LICENSE) の下でライセンスされています。
個別のアセットのライセンス条件は、それぞれの `MANIFEST.md` ファイルに記載されています。
