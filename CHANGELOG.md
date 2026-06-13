# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- **Repository Renamed:** Changed the repository name and terminology from `test-data` to `test-assets`. This better reflects the fact that the repository distributes large media files (images, audio, video) and binary resources, rather than just text-based datasets.
- **Extraction Path:** Updated documentation to recommend extracting assets directly to `tests/assets` instead of `tests/data/large`.
- **Cache Keys:** Updated the recommended GitHub Actions cache key format to use `test-assets-*` instead of `test-data-*`.
- **Archive Naming Convention:** Updated examples to use `*-assets-*.tar.zst` instead of `*-dataset-*.tar.zst`.

### Added
- **Documentation:** Added a Japanese translation of the README (`README.ja.md`).
