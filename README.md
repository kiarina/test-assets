# kiarina/test-assets

English | [日本語](README.ja.md)

This repository is dedicated to distributing **shared test assets** (e.g., large media files, binaries, datasets) for multiple projects.
The actual asset files are **not committed** to the repository history.
Instead, they are published as [GitHub Release assets](https://github.com/kiarina/test-assets/releases).

---

## 📦 About Test Assets

Test assets in this repository are managed by a combination of a **Release Version** and an **Asset Name**. This structure allows consuming projects to selectively download exactly what they need while pinning to a stable snapshot.

### 🔑 Release Version (Versioning Policy)
The release version defines a stable snapshot of assets at a given point in time.
- Versions follow the format `vYYYY.MM` or `vYYYY.MM.DD` (e.g., `v2025.09`).
- Each release contains one or more asset archives (`*.tar.zst`), a checksum file (`SHA256SUMS`), and optionally a `MANIFEST.md` describing the contents.
- Consuming projects should **pin the release version** explicitly.

### 🏷️ Asset Name (Naming Convention)
Within a release, individual asset archives follow a semantic naming convention:
`{project-name}-assets-v{major}.{minor}.{patch}.tar.zst`

- **Major**: Breaking changes (e.g., structural changes to the assets that require test updates).
- **Minor**: Data addition (e.g., adding new files, images, or test cases).
- **Patch**: Data correction (e.g., fixing a typo in a text file or replacing a corrupted image).

### 🗂 Example Structure
Here is how a release looks internally:
```
v2025.09/
  ├─ kiarina-python-assets-v1.0.0.tar.zst
  ├─ SHA256SUMS
  └─ MANIFEST.md   # file descriptions
```

---

## 👤 For Consumers

If you want to use these assets in your project, you have a few ways to download them.

### 📥 Automated Downloader

You can automate fetching the latest test assets directly within your own project by copying our ready-to-use download script.

1. Create a `.mise/tasks/test-assets/download` file in your project and copy the contents from [our download script](https://github.com/kiarina/test-assets/blob/main/.mise/tasks/test-assets/download).
2. Run the task to download and extract the assets:
   ```sh
   mise run test-assets:download v2025.09 kiarina-python v1.0.0
   ```
   By default, this will extract the assets into `./tests/assets` and automatically add it to your `.gitignore`.
3. To specify a different output directory, use the `--output-dir` flag:
   ```sh
   mise run test-assets:download --output-dir ./my/custom/path v2025.09 kiarina-python v1.0.0
   ```

### ⚡ GitHub Actions Example

If your project uses GitHub Actions, we provide a complete, copy-pasteable example of how to cache and download the test assets in your CI pipeline using our download script.

👉 **See [`.github/workflows/ci.yml`](.github/workflows/ci.yml) for the complete workflow example.**

### 📦 Manual Download

If you prefer not to use the automated script, you can download the assets manually.

**Using GitHub CLI:**
```sh
mkdir -p tests/assets
gh release download --repo kiarina/test-assets v2025.09 -p kiarina-python-assets-v1.0.0.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.0.0.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.0.0.tar.zst
```

**Using curl / wget:**
```sh
# Example: download assets from release v2025.09
curl -L -o kiarina-python-assets-v1.0.0.tar.zst \
  https://github.com/kiarina/test-assets/releases/download/v2025.09/kiarina-python-assets-v1.0.0.tar.zst
```

---

## 🛠 For Maintainers

If you are a maintainer of this repository, here is how you work with the assets.

### 📸 The Snapshot Model

This repository uses a **Snapshot Model**. Every new release should include **all** assets from the previous release, plus any new or updated assets. 
**Never delete past releases on GitHub.** Consuming projects pin specific versions, and deleting past releases will break their CI pipelines. By inheriting past assets, we ensure that a single version tag contains everything a consumer might need at that point in time.

### ⚙️ Setup Workspace

Since the actual asset files in `src/` are ignored by git to keep the repository lightweight, you will need to reconstruct the workspace after cloning this repository.

To download and extract the latest assets back into the `src/` directory, run:
```sh
make setup
# or with arguments: mise run setup v2025.10
```
This requires the GitHub CLI (`gh`) to be authenticated.

### 🚀 How to Release New Assets

We provide helper tasks to make the snapshot model easy to maintain.

1. **Initialize a New Release Version**:
   Create a new version workspace. This will automatically download the latest release and copy its assets to the new version's directory to act as your baseline.
   ```sh
   make create
   # or with arguments: mise run create v2025.10
   ```

2. **Add a New Asset Directory**:
   ```sh
   make add
   # or with arguments: mise run add v2025.10 kiarina-python v1.0.0
   # You can then place your raw files into the created directory.
   ```

3. **Build the Release**:
   Run the build command to generate the compressed `.tar.zst` and checksums. This will also automatically calculate the uncompressed size of your assets and inject it into the `MANIFEST.md`.
   ```sh
   make build
   # or with arguments: mise run build v2025.10
   ```

4. **Publish to GitHub**:
   Upload the contents to GitHub Releases using the automated `release` task.
   ```sh
   make release
   # or with arguments: mise run release v2025.10
   ```

---

## ⚖️ License

This repository itself is licensed under [MIT](./LICENSE).
The license terms of individual assets are documented in their respective `MANIFEST.md` files.
