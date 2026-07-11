# kiarina/test-assets

[English](README.md) | 日本語

このリポジトリは、複数のプロジェクト間で**共有テストアセット**（画像、動画、バイナリファイル、データセットなど）を配布するための専用リポジトリです。
実際のアセットファイルはリポジトリの履歴には**コミットされません**。
代わりに、[GitHub Release のアセット](https://github.com/kiarina/test-assets/releases)として公開されます。

---

## 📦 About Test Assets

このリポジトリのテストアセットは、**リリースバージョン (Release Version)** と **アセット名 (Asset Name)** の組み合わせで管理されます。これにより、利用側のプロジェクトは必要なデータだけを選択的にダウンロードし、安定したスナップショットに固定（ピン留め）することができます。

### 🔑 Release Version (Versioning Policy)
リリースバージョンは配布スナップショットを識別します。既存アセットの同じメジャーバージョンへファイルを追加してアーカイブを差し替えると、リリースの内容は増えることがあります。
- バージョンは `vYYYY.MM` または `vYYYY.MM.DD` の形式に従います（例: `v2025.09`）。
- 各リリースには、1つ以上のアセットアーカイブ (`*.tar.zst`)、チェックサムファイル (`SHA256SUMS`)、および内容を説明する `MANIFEST.md` が含まれます。
- 各利用プロジェクトは、リリースバージョンとアセットのメジャーバージョンを明示的に**ピン留め**してください。これにより対象のアセット系列は固定されますが、その系列内の内容が不変であることは保証されません。

### 🏷️ Asset Name (Naming Convention)
リリース内の個々のアセットアーカイブは、メジャーバージョンだけを使って命名します：
`{project-name}-assets-v{major}.tar.zst`

- 同じメジャーバージョン内のアセットは**追加専用**です。既存ファイルの変更、差し替え、移動、削除は禁止します。
- ファイル追加時は、同名のアーカイブを再ビルドして差し替えます。
- 既存ファイルの変更や削除が必要な場合は、メジャーバージョンを上げて新しいアセットディレクトリを作成します。
- アーカイブを差し替えるため、URLやチェックサムの不変性は保証しません。これは意図的なトレードオフであり、アーカイブのバイト単位の同一性よりも、迅速で簡単な運用を優先します。

### 🗂 Example Structure
リリース内部のレイアウトは以下のようになっています：
```
v2025.09/
  ├─ kiarina-python-assets-v1.tar.zst
  ├─ SHA256SUMS
  └─ MANIFEST.md   # ファイルの説明
```

---

## 👤 For Consumers

プロジェクトでこれらのアセットを利用したい場合、いくつかのダウンロード方法があります。

### 📥 Automated Downloader

提供されているテストアセットを、ご自身のプロジェクト内で自動的に取得・展開するためのスクリプトを用意しています。

1. ご自身のプロジェクトに `.mise/tasks/test-assets/download` を作成し、[こちらのスクリプト](https://github.com/kiarina/test-assets/blob/main/.mise/tasks/test-assets/download) の内容をコピー＆ペーストしてください。
2. 以下のコマンドを実行すると、アセットのダウンロードと展開が行われます：
   ```sh
   mise run test-assets:download v2025.09 kiarina-python v1
   ```
   デフォルトでは `./tests/assets` に展開され、自動的に `.gitignore` に追記されます。
3. 展開先ディレクトリを変更したい場合は、`--output-dir` フラグを使用します：
   ```sh
   mise run test-assets:download --output-dir ./my/custom/path v2025.09 kiarina-python v1
   ```

ダウンローダーはリクエストごとに一意なキャッシュバスターをクエリパラメータとして付与します。これにより、GitHub Release のアセットを差し替えた直後でも、CDN の古いレスポンスではなく最新のアセットを取得できます。

### One-line Download Command

アセットをダウンロードして展開する、コピー＆ペースト用のワンライナーを生成できます：

```sh
mise run test-assets:download-command
```

出力例：

```sh
set -o pipefail; mkdir -p assets && curl -fsSL https://github.com/kiarina/test-assets/releases/download/v2026.07/labs-assets-v1.tar.zst\?cachebust="$(date +%s)-$$-$RANDOM" | tar --use-compress-program=unzstd --strip-components=1 -xf - -C assets
```

実行には `curl`、`tar`、`unzstd` コマンドが必要です。
生成されるコマンドにも、実行時に一意なキャッシュバスターが付与されます。

### ⚡ GitHub Actions Example

プロジェクトで GitHub Actions を使用している場合、CIパイプラインの中でダウンロードスクリプトを使ってテストアセットを取得・キャッシュする完全なサンプルを用意しています。

追加専用の更新ではリリース名とアセット名が変わらないため、CI のキャッシュキーでは更新を自動検知できません。ファイルを追加した際は、ワークフロー内のキャッシュリビジョンを更新してください。

👉 **完全なワークフローのサンプルは [`.github/workflows/ci.yml`](.github/workflows/ci.yml) をご覧ください。**

### 📦 Manual Download

自動化スクリプトを使用しない場合は、手動でダウンロードして展開することも可能です。

**GitHub CLI を使用する場合:**
```sh
mkdir -p tests/assets
gh release download --repo kiarina/test-assets v2025.09 -p kiarina-python-assets-v1.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.tar.zst
```

**curl / wget を使用する場合:**
```sh
# 例: リリース v2025.09 からアセットをダウンロードする
curl -L -o kiarina-python-assets-v1.tar.zst \
  "https://github.com/kiarina/test-assets/releases/download/v2025.09/kiarina-python-assets-v1.tar.zst?cachebust=$(date +%s)-$$-$RANDOM"
```

---

## 🛠 For Maintainers

このリポジトリを管理し、新しいアセットを追加・更新する手順です。

### 📸 The Snapshot Model

このリポジトリは**スナップショット方式**を採用しています。新しいリリースを作成する際は、必ず**過去のリリースのアセットをすべて引き継ぎ**、そこに新しいアセットを追加・上書きします。
**GitHub上の過去のリリースは絶対に削除しないでください。** 利用側のプロジェクトは特定のバージョンをピン留めしているため、過去のリリースを削除すると利用者のCIが壊れてしまいます。すべてを引き継ぐことで、1つのバージョンを指定するだけで必要な全アセットが揃う状態を維持します。

### ⚙️ Setup Workspace

リポジトリを軽量に保つため、`src/` 内の巨大なアセットファイルは Git で管理されていません。そのため、このリポジトリを clone した直後はアセットが空の状態です。

GitHub Releases から最新のアセットをダウンロードし、`src/` ディレクトリを再構築するには以下のコマンドを実行してください：
```sh
make setup
# または引数指定で実行: mise run setup v2025.10
```
※このコマンドを実行するには GitHub CLI (`gh`) の認証が必要です。

### 🚀 How to Release New Assets

スナップショット方式を簡単に運用するためのヘルパータスクが用意されています。

1. **新しいリリースバージョンの初期化**:
   新しいバージョンのワークスペースを作成します。自動的に最新のリリースをダウンロードし、過去のアセットをすべて新しいディレクトリにコピーしてベースラインを構築します。
   ```sh
   make create
   # または引数指定で実行: mise run create v2025.10
   ```

2. **新規アセットディレクトリの追加**:
   ```sh
   make add
   # または引数指定で実行: mise run add v2025.10 kiarina-python v1
   # その後、作成されたディレクトリに実ファイルを配置してください。
   ```

   同じメジャーバージョンへ後から追加する場合は、既存のディレクトリへ新しいファイルを直接配置します。`add` の再実行は不要です：
   ```sh
   cp new-test-file.jpg src/v2025.10/kiarina-python-assets-v1/
   ```

   ファイルの変更、差し替え、移動、削除が必要な場合は、次のメジャーバージョンを作成します：
   ```sh
   mise run add v2025.10 kiarina-python v2
   ```

3. **リリースのビルド**:
   ビルドコマンドを実行し、圧縮された `.tar.zst` アーカイブとチェックサムを生成します。この際、アセットの実際の容量が計算され、`MANIFEST.md` のプレースホルダーに自動で書き込まれます。
   ```sh
   make build
   # または引数指定で実行: mise run build v2025.10
   ```

4. **GitHub への公開**:
   自動化された `release` タスクを使って、生成されたアセットを GitHub Release にアップロードします。
   ```sh
   make release
   # または引数指定で実行: mise run release v2025.10
   ```

既存メジャーバージョンへの追加専用の変更であれば、ファイルを配置し、`build`、`release` を実行するだけで完了します。

---

## ⚖️ License

このリポジトリ自体は [MIT](./LICENSE) の下でライセンスされています。
個別のアセットのライセンス条件は、それぞれの `MANIFEST.md` ファイルに記載されています。
