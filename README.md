# kiarina/test-assets

English | [日本語](README.ja.md)

This repository is dedicated to distributing **shared test assets** (e.g., large media files, binaries, datasets) for multiple projects.
The actual asset files are **not committed** to the repository history.
Instead, they are published as [GitHub Release assets](https://github.com/kiarina/test-assets/releases).

---

## 📦 How to Download Assets

### Using GitHub CLI

```sh
mkdir -p tests/assets
gh release download --repo kiarina/test-assets v2025.09 -p kiarina-python-assets-v1.0.0.tar.zst --dir tests/assets
tar --use-compress-program=unzstd -xvf tests/assets/kiarina-python-assets-v1.0.0.tar.zst -C tests/assets
rm tests/assets/kiarina-python-assets-v1.0.0.tar.zst
```

### Using curl / wget

You can copy the asset download link directly from the [Releases](https://github.com/kiarina/test-assets/releases) page.

```sh
# Example: download assets from release v2025.09
curl -L -o kiarina-python-assets-v1.0.0.tar.zst \
  https://github.com/kiarina/test-assets/releases/download/v2025.09/kiarina-python-assets-v1.0.0.tar.zst
```

---

## 🏷️ Asset Naming Convention

Asset archives should follow the naming convention:
`{project-name}-assets-v{major}.{minor}.{patch}.tar.zst`

- **Major**: Breaking changes (e.g., structural changes to the assets that require test updates).
- **Minor**: Data addition (e.g., adding new files, images, or test cases).
- **Patch**: Data correction (e.g., fixing a typo in a text file or replacing a corrupted image).

---

## 🔑 Versioning Policy

* Versions follow the format `vYYYY.MM` or `vYYYY.MM.DD`.
* Each release includes:
  * one or more asset archives (`*.tar.zst`)
  * a checksum file (`SHA256SUMS`)
  * optionally, a `MANIFEST.md` describing the contents
* Each consuming project should **pin the release version** explicitly.

---

## 🛠 For Maintainers: Setup Workspace

Since the actual asset files in `src/` are ignored by git to keep the repository lightweight, you will need to reconstruct the workspace after cloning this repository.

To download and extract the latest assets back into the `src/` directory, run:
```sh
mise run setup
# or specify a version: mise run setup v2025.09
```
This requires the GitHub CLI (`gh`) to be authenticated.

---

## 🚀 How to Release New Assets

1. **Add Assets to Source**: 
   Place your raw asset files in `src/{release-version}/{project-name}-assets-v{major}.{minor}.{patch}/`.
2. **Update Manifest**: 
   Update or create `src/{release-version}/MANIFEST.md` to describe the new assets.
3. **Build the Release**:
   Run the build command to generate the compressed `.tar.zst` and checksums.
   ```sh
   make
   # or specify the version directly: make v2025.09
   ```
4. **Publish to GitHub**:
   Upload the contents to GitHub Releases using the automated `release` task. This will create a new release (or update an existing one) using the GitHub CLI (`gh`).
   ```sh
   mise run release
   # or specify the version directly: mise run release v2025.09
   ```

---

## 📥 For Consumers: Automated Downloader

You can automate fetching the latest test assets directly within your own project by copying our ready-to-use download script.

1. Create a `.mise/tasks/download` file in your project and copy the contents from [our download script](https://github.com/kiarina/test-assets/blob/main/.mise/tasks/download).
2. Run the task to download and extract the assets:
   ```sh
   mise run download v2025.09 kiarina-python v1.0.0
   ```
   By default, this will extract the assets into `./tests/assets` and automatically add it to your `.gitignore`.
3. To specify a different output directory, use the `--output-dir` flag:
   ```sh
   mise run download --output-dir ./my/custom/path v2025.09 kiarina-python v1.0.0
   ```

---

## 🗂 Example Release Layout

```
v2025.09/
  ├─ kiarina-python-assets-v1.0.0.tar.zst
  ├─ SHA256SUMS
  └─ MANIFEST.md   # file descriptions
```

---

## ⚡ GitHub Actions Example

If your project uses GitHub Actions, we provide a complete, copy-pasteable example of how to cache and download the test assets in your CI pipeline using our download script.

👉 **See [`.github/workflows/ci.yml`](.github/workflows/ci.yml) for the complete workflow example.**

Notes:

* `actions/cache` keeps the assets for up to **7 days of inactivity** and **10 GB per repository**.
* Use a **versioned cache key** (`test-assets-v2025.09`) to ensure reproducibility.
* Always verify integrity with `sha256sum -c SHA256SUMS` if security matters.

---

## ⚖️ License

This repository itself is licensed under [MIT](./LICENSE).
The license terms of individual assets are documented in their respective `MANIFEST.md` files.
