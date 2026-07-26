# kiarina/test-assets

English | [日本語](README.ja.md)

This repository is dedicated to distributing **shared test assets** (e.g., large media files, binaries, datasets) for multiple projects.
The actual asset files are **not committed** to the repository history.
Instead, they are published as [GitHub Release assets](https://github.com/kiarina/test-assets/releases).

---

## 📦 About Test Assets

Test assets in this repository are managed by a combination of a **Release Version** and an **Asset Name**. Both are major-only compatibility lines: the release version guarantees asset availability, while the asset version guarantees existing files.

### 🔑 Release Version (Versioning Policy)
The release version defines compatibility for the set of published assets.
- Versions use only a positive major number: `v1`, `v2`, and so on.
- Each release contains one or more asset archives (`*.tar.zst`), a checksum file (`SHA256SUMS`), and optionally a `MANIFEST.md` describing the contents.
- Within the same release version, asset archives may be added or updated.
- Published asset archives must not be removed from a release version. To remove an asset, increment the release version and create a new release line.
- Consuming projects should **pin the release version** and asset version explicitly. Neither line guarantees byte-for-byte archive identity because append-only additions replace archives in place.

### 🏷️ Asset Name (Naming Convention)
Within a release, individual asset archives use only a major version:
`{project-name}-assets-{asset-version}.tar.zst`, where the asset version uses the format `v1`, `v2`, and so on.

- Within the same major version, assets are **append-only**. Existing files must not be modified, replaced, moved, or deleted.
- Additions are published by rebuilding and replacing the archive with the same name.
- If an existing file must change or be removed, increment the major version and create a new asset directory.
- Replacing an archive means its URL and checksum are not immutable. This tradeoff is intentional: the repository prioritizes quick, simple asset maintenance over byte-for-byte identity of an asset archive.

### 🗂 Example Structure
Here is how a release looks internally:
```
v1/
  ├─ kiarina-python-assets-v1.tar.zst
  ├─ SHA256SUMS
  └─ MANIFEST.md   # file descriptions
```

---

## 👤 For Consumers

If you want to use these assets in your project, you have a few ways to download them.

### 📥 Automated Downloader

You can automate fetching the latest test assets directly within your own project by copying our ready-to-use download script.

1. Create a `.mise/tasks/test-assets/download` file in your project and copy the contents from [our download script](https://github.com/kiarina/test-assets/blob/main/.mise/tasks/test-assets/download).
2. Run the task without arguments to resolve and download the assets automatically:
   ```sh
   mise run test-assets:download
   ```
   By default, this will extract the assets into `./tests/assets` and automatically add it to your `.gitignore`.
3. You can override any value from left to right, or specify all values explicitly:
   ```sh
   mise run test-assets:download v1
   mise run test-assets:download v1 kiarina-python
   mise run test-assets:download v1 kiarina-python v1
   ```
4. To specify a different output directory, use the `--output-dir` flag:
   ```sh
   mise run test-assets:download --output-dir ./my/custom/path
   ```

Missing values are resolved in this order:

- **Release version**: use the latest release returned by the GitHub REST API.
- **Project name**: use the repository name parsed from the current Git repository's `origin` remote.
- **Asset version**: find assets matching `{project-name}-assets-v<version>.tar.zst` in the selected release and use the highest numeric version.

The task validates that the resolved or explicitly selected asset exists in the release. Set `GITHUB_TOKEN` to authenticate REST API requests and avoid the lower unauthenticated rate limit. Automatic resolution requires `jq` and either `curl` or `wget`. Downloading and extraction additionally require `tar` and `unzstd`.

The downloader adds a unique cache-busting query parameter to each request so that a recently replaced GitHub Release asset is fetched immediately instead of a stale CDN response.

### One-line Download Command

Generate a copy-pasteable one-line command to download and extract an asset:

```sh
mise run test-assets:download-command
```

Example output:

```sh
set -o pipefail; mkdir -p assets && curl -fsSL https://github.com/kiarina/test-assets/releases/download/v1/labs-assets-v1.tar.zst\?cachebust="$(date +%s)-$$-$RANDOM" | tar --use-compress-program=unzstd --strip-components=1 -xf - -C assets
```

Requires the `curl`, `tar`, and `unzstd` commands.
The generated command also adds a unique cache-busting query parameter when it runs.

### ⚡ GitHub Actions Example

If your project uses GitHub Actions, we provide a complete, copy-pasteable example of how to cache and download the test assets in your CI pipeline using our download script.

Because an append-only update keeps the same release and asset name, CI cache keys cannot detect it automatically. Increment the cache revision in the workflow whenever files are added.

👉 **See [`.github/workflows/ci.yml`](.github/workflows/ci.yml) for the complete workflow example.**

### 📦 Manual Download

If you prefer not to use the automated script, you can download the assets manually.

**Using GitHub CLI:**
```sh
mkdir -p tests/assets
gh release download --repo kiarina/test-assets v1 -p kiarina-python-assets-v1.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.tar.zst
```

**Using curl / wget:**
```sh
# Example: download assets from release v1
curl -L -o kiarina-python-assets-v1.tar.zst \
  "https://github.com/kiarina/test-assets/releases/download/v1/kiarina-python-assets-v1.tar.zst?cachebust=$(date +%s)-$$-$RANDOM"
```

---

## 🛠 For Maintainers

If you are a maintainer of this repository, here is how you work with the assets.

### 📸 The Compatibility Model

This repository uses two append-only compatibility boundaries:

- A **release version** guarantees that published asset names remain available. Assets may be added or their archives updated, but removing an asset requires the next release version.
- An **asset version** guarantees that existing file paths and contents remain available. Asset versions contain only a major number. Files may be added, but modifying, replacing, moving, or deleting a file requires the next asset version.

When creating the next release version, inherit the previous release and remove only the assets that intentionally require the compatibility break. **Never delete past releases on GitHub.** Consumers may still depend on them.

### 📝 Recommended File Naming

This is a recommendation, not a requirement. Give asset files descriptive names that let maintainers understand their contents and important properties without opening them. The files currently under `src/` generally follow this pattern:

`{content-description}[_{characteristics}][_{approximate-size}].{extension}`

- Use lowercase `snake_case` for the content description.
- Add characteristics that matter for the file type, such as image dimensions (`1024x1024`), row or line count (`13row`, `1027line`), page count (`3p`), speaker count (`2speaker`), duration (`14s`), frame rate (`24fps`), or sample rate (`16k`).
- When useful, end the name with an approximate file size using a lowercase unit such as `b`, `kb`, or `mb`.
- Include only useful characteristics; the filename does not need to contain every available property.

Examples from the current assets include `apple_1024x1024_138kb.jpg`, `monthly_temperature_13row_141b.csv`, `conversation_2speaker_14s_16k.mp3`, and `shape_animation_1600x900_24fps_13s_4400kb.mp4`.

### ⚙️ Setup Workspace

Since the actual asset files in `src/` are ignored by git to keep the repository lightweight, you will need to reconstruct the workspace after cloning this repository.

To download and extract the latest assets back into the `src/` directory, run:
```sh
make setup
# or with arguments: mise run setup v1
```
This requires the GitHub CLI (`gh`) to be authenticated.

### 🚀 How to Release New Assets

We provide helper tasks to make the compatibility model easy to maintain.

1. **Initialize a New Release Version**:
   Create a new release line only when an existing asset must be removed. This automatically downloads the latest release and copies its assets to the new version directory as a baseline; then remove the unwanted asset directory locally.
   ```sh
   make create
   # or with arguments: mise run create v2
   ```

2. **Add a New Asset Directory**:
   ```sh
   make add
   # or with arguments: mise run add v1 kiarina-python v1
   # You can then place your raw files into the created directory.
   ```

   For later additions to the same major version, place new files directly in the existing directory. Do not run `add` again:
   ```sh
   cp new-test-file.jpg src/v1/kiarina-python-assets-v1/
   ```

   If a file must be modified, replaced, moved, or deleted, create the next major version instead:
   ```sh
   mise run add v1 kiarina-python v2
   ```

3. **Build the Release**:
   Run the build command to generate the compressed `.tar.zst` and checksums. This will also automatically calculate the uncompressed size of your assets and inject it into the `MANIFEST.md`.
   ```sh
   make build
   # or with arguments: mise run build v1
   ```

4. **Publish to GitHub**:
   Upload the contents to GitHub Releases using the automated `release` task.
   ```sh
   make release
   # or with arguments: mise run release v1
   ```

For an append-only addition to an existing major version, the complete routine is simply: place the file, run `build`, then run `release`.

---

## ⚖️ License

This repository itself is licensed under [MIT](./LICENSE).
The license terms of individual assets are documented in their respective `MANIFEST.md` files.
