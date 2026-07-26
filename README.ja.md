# kiarina/test-assets

[English](README.md) | 日本語

このリポジトリは、複数のプロジェクト間で**共有テストアセット**（画像、動画、バイナリファイル、データセットなど）を配布するための専用リポジトリです。
実際のアセットファイルはリポジトリの履歴には**コミットされません**。
代わりに、[GitHub Release のアセット](https://github.com/kiarina/test-assets/releases)として公開されます。

---

## 📦 About Test Assets

このリポジトリのテストアセットは、**リリースバージョン (Release Version)** と **アセット名 (Asset Name)** の組み合わせで管理されます。どちらもメジャーバージョンだけの互換性ラインであり、リリースバージョンはアセットの存在を、アセットバージョンは既存ファイルを保証します。

### 🔑 Release Version (Versioning Policy)
リリースバージョンは、公開するアセット集合の互換性を定義します。
- バージョンは正のメジャー番号だけを使用します：`v1`、`v2` など。
- 各リリースには、1つ以上のアセットアーカイブ (`*.tar.zst`)、チェックサムファイル (`SHA256SUMS`)、および内容を説明する `MANIFEST.md` が含まれます。
- 同じリリースバージョン内では、アセットアーカイブの追加と更新が可能です。
- 公開済みのアセットアーカイブを同じリリースバージョンから削除してはいけません。アセットを削除する場合は、リリースバージョンを上げて新しいリリースラインを作成します。
- 各利用プロジェクトは、リリースバージョンとアセットバージョンを明示的に**ピン留め**してください。追加によってアーカイブを差し替えるため、どちらのラインもアーカイブのバイト単位の同一性は保証しません。

### 🏷️ Asset Name (Naming Convention)
リリース内の個々のアセットアーカイブは、メジャーバージョンだけを使って命名します：
`{project-name}-assets-{asset-version}.tar.zst`。アセットバージョンは `v1`、`v2` などの形式を使用します。

- 同じメジャーバージョン内のアセットは**追加専用**です。既存ファイルの変更、差し替え、移動、削除は禁止します。
- ファイル追加時は、同名のアーカイブを再ビルドして差し替えます。
- 既存ファイルの変更や削除が必要な場合は、メジャーバージョンを上げて新しいアセットディレクトリを作成します。
- アーカイブを差し替えるため、URLやチェックサムの不変性は保証しません。これは意図的なトレードオフであり、アーカイブのバイト単位の同一性よりも、迅速で簡単な運用を優先します。

### 🗂 Example Structure
リリース内部のレイアウトは以下のようになっています：
```
v1/
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
2. 引数なしでタスクを実行すると、値を自動解決してアセットをダウンロード・展開します：
   ```sh
   mise run test-assets:download
   ```
   デフォルトでは `./tests/assets` に展開され、自動的に `.gitignore` に追記されます。
3. 左から順に一部の値だけを上書きすることも、すべて明示することもできます：
   ```sh
   mise run test-assets:download v1
   mise run test-assets:download v1 kiarina-python
   mise run test-assets:download v1 kiarina-python v1
   ```
4. 展開先ディレクトリを変更したい場合は、`--output-dir` フラグを使用します：
   ```sh
   mise run test-assets:download --output-dir ./my/custom/path
   ```

未指定の値は次の順序で解決します：

- **リリースバージョン**: GitHub REST API が返す最新リリースを使用します。
- **プロジェクト名**: 現在の Git リポジトリの `origin` リモートからリポジトリ名を取得します。
- **アセットバージョン**: 選択したリリース内で `{project-name}-assets-v<version>.tar.zst` に一致するアセットを検索し、数値として最大のバージョンを使用します。

タスクは、自動解決または明示指定されたアセットがリリースに存在することも検証します。REST API を認証し、未認証時の低いレート制限を避けるには `GITHUB_TOKEN` を設定してください。自動解決には `jq` と、`curl` または `wget` のいずれかが必要です。ダウンロードと展開には、さらに `tar` と `unzstd` が必要です。

ダウンローダーはリクエストごとに一意なキャッシュバスターをクエリパラメータとして付与します。これにより、GitHub Release のアセットを差し替えた直後でも、CDN の古いレスポンスではなく最新のアセットを取得できます。

### One-line Download Command

アセットをダウンロードして展開する、コピー＆ペースト用のワンライナーを生成できます：

```sh
mise run test-assets:download-command
```

出力例：

```sh
set -o pipefail; mkdir -p assets && curl -fsSL https://github.com/kiarina/test-assets/releases/download/v1/labs-assets-v1.tar.zst\?cachebust="$(date +%s)-$$-$RANDOM" | tar --use-compress-program=unzstd --strip-components=1 -xf - -C assets
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
gh release download --repo kiarina/test-assets v1 -p kiarina-python-assets-v1.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.tar.zst
```

**curl / wget を使用する場合:**
```sh
# 例: リリース v1 からアセットをダウンロードする
curl -L -o kiarina-python-assets-v1.tar.zst \
  "https://github.com/kiarina/test-assets/releases/download/v1/kiarina-python-assets-v1.tar.zst?cachebust=$(date +%s)-$$-$RANDOM"
```

---

## 🛠 For Maintainers

このリポジトリを管理し、新しいアセットを追加・更新する手順です。

### 📸 The Compatibility Model

このリポジトリは、二層の追加専用の互換性境界を採用します：

- **リリースバージョン**は、公開済みのアセット名が引き続き利用できることを保証します。アセットの追加とアーカイブの更新は可能ですが、アセットを削除する場合は次のリリースバージョンが必要です。
- **アセットバージョン**は、既存ファイルのパスと内容が引き続き利用できることを保証します。アセットバージョンはメジャー番号だけで構成されます。ファイルの追加は可能ですが、変更、差し替え、移動、削除を行う場合は次のアセットバージョンが必要です。

次のリリースバージョンを作成する際は、前のリリースを引き継ぎ、意図的に互換性を壊す対象のアセットだけを削除します。**GitHub上の過去のリリースは絶対に削除しないでください。** 利用者が引き続き依存している可能性があります。

### 📝 Recommended File Naming

これは必須のルールではなく、推奨事項です。アセットファイルを開かなくても、内容と重要な特性をメンテナが把握できるような説明的な名前を付けてください。現在の `src/` 以下のファイルは、概ね次の形式に従っています：

`{内容の説明}[_{特性}][_{概算ファイルサイズ}].{拡張子}`

- 内容の説明には、小文字の `snake_case` を使用します。
- ファイル形式に応じて重要な特性を追加します。たとえば、画像サイズ (`1024x1024`)、行数 (`13row`、`1027line`)、ページ数 (`3p`)、話者数 (`2speaker`)、長さ (`14s`)、フレームレート (`24fps`)、サンプルレート (`16k`) などです。
- 有用な場合は、ファイル名の末尾に概算ファイルサイズを付けます。単位には `b`、`kb`、`mb` などの小文字を使用します。
- すべての特性を含める必要はなく、識別や用途の把握に役立つものだけを使用します。

現在のアセットには、`apple_1024x1024_138kb.jpg`、`monthly_temperature_13row_141b.csv`、`conversation_2speaker_14s_16k.mp3`、`shape_animation_1600x900_24fps_13s_4400kb.mp4` などの例があります。

### ⚙️ Setup Workspace

リポジトリを軽量に保つため、`src/` 内の巨大なアセットファイルは Git で管理されていません。そのため、このリポジトリを clone した直後はアセットが空の状態です。

GitHub Releases から最新のアセットをダウンロードし、`src/` ディレクトリを再構築するには以下のコマンドを実行してください：
```sh
make setup
# または引数指定で実行: mise run setup v1
```
※このコマンドを実行するには GitHub CLI (`gh`) の認証が必要です。

### 🚀 How to Release New Assets

互換性モデルを簡単に運用するためのヘルパータスクが用意されています。

1. **新しいリリースバージョンの初期化**:
   既存アセットを削除する必要がある場合にのみ、新しいリリースラインを作成します。最新リリースを自動的にダウンロードして新しいバージョンディレクトリへコピーするため、その後、不要なアセットディレクトリをローカルで削除します。
   ```sh
   make create
   # または引数指定で実行: mise run create v2
   ```

2. **新規アセットディレクトリの追加**:
   ```sh
   make add
   # または引数指定で実行: mise run add v1 kiarina-python v1
   # その後、作成されたディレクトリに実ファイルを配置してください。
   ```

   同じメジャーバージョンへ後から追加する場合は、既存のディレクトリへ新しいファイルを直接配置します。`add` の再実行は不要です：
   ```sh
   cp new-test-file.jpg src/v1/kiarina-python-assets-v1/
   ```

   ファイルの変更、差し替え、移動、削除が必要な場合は、次のメジャーバージョンを作成します：
   ```sh
   mise run add v1 kiarina-python v2
   ```

3. **リリースのビルド**:
   ビルドコマンドを実行し、圧縮された `.tar.zst` アーカイブとチェックサムを生成します。この際、アセットの実際の容量が計算され、`MANIFEST.md` のプレースホルダーに自動で書き込まれます。
   ```sh
   make build
   # または引数指定で実行: mise run build v1
   ```

4. **GitHub への公開**:
   自動化された `release` タスクを使って、生成されたアセットを GitHub Release にアップロードします。
   ```sh
   make release
   # または引数指定で実行: mise run release v1
   ```

既存メジャーバージョンへの追加専用の変更であれば、ファイルを配置し、`build`、`release` を実行するだけで完了します。

---

## ⚖️ License

このリポジトリ自体は [MIT](./LICENSE) の下でライセンスされています。
個別のアセットのライセンス条件は、それぞれの `MANIFEST.md` ファイルに記載されています。
