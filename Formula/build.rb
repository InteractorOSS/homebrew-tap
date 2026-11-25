# Homebrew formula for ibuild — the Interactor build sync daemon.
#
# This file lives in cli/homebrew/build.rb in the product-manager repo.
#
# NOTHING UPDATES THIS FILE FOR YOU. cli-release.yml builds and publishes the
# binaries; it does not touch the version or the sha256 values below, and it does
# not push to the tap. Both steps are yours, per release. This comment used to
# claim the workflow updated the version here — believing it is how the formula sat
# at 1.1.0 while v1.2.0 and v1.3.0 shipped, handing every `brew install` a binary
# two releases old (and, once `ibuild fleet up` landed, one with no `fleet` verb at
# all while the setup surfaces told people to run it).
#
# Per release, both steps:
#   1. Bump `version` below and replace each sha256 from the release's own
#      checksums.txt asset — never a locally recomputed one:
#        gh release download cli/v<x.y.z> --pattern checksums.txt -O - | cat
#      Step 1 is the half this repo can enforce, and now does:
#      scripts/cli-packaging-version-floor.test.ts fails when the version below — or the newest
#      cli/winget/manifests/i/InteractorOSS/build/<x.y.z>/ directory — is older than the release
#      floor the web setup surfaces tell people to run (IBUILD_WORKSPACE_MIN_VERSION). It cannot
#      check the sha256 values (the suite is offline); those still come from checksums.txt above,
#      never from a local `shasum` of a file you downloaded yourself.
#   2. Submit to the tap (manual/one-time per release):
#        cp cli/homebrew/build.rb /path/to/homebrew-tap/Formula/build.rb
#        # commit verbatim (checksums are already release-verified), then push/PR
#
# Step 1 is now GATED: scripts/cli-release-packaging-parity.test.ts fails the unit lane when this
# `version` drifts from the winget manifests / IBUILD_VERSION, or when all three trail the newest
# `cli/v*` tag. It also holds the platform stanzas below against RELEASE_ASSETS, so dropping one
# — as the linuxbrew arm64 stanza was missing from 1.3.0 until 1.4.0 — fails here instead of 404ing
# on somebody's Graviton box.

class Build < Formula
  desc "Bidirectional sync daemon for Interactor PM tasks/goals — works in any project"
  homepage "https://build.interactor.com"
  version "1.9.0"

  license "AGPL-3.0-or-later"

  # URLs go through the app's authenticated asset proxy, not a direct GitHub releases download —
  # this repo is private, so an unauthenticated `releases/download/...` URL 404s (G#2502/CS-3).
  # The proxy streams the exact same release asset via the GitHub App installation token; the
  # sha256 values below are unaffected (still taken from the release's own checksums.txt).
  on_macos do
    on_arm do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-macos-arm64"
      sha256 "633a70442710f91b4c6833db8058caf0d485b4322b0a1fbfa376e8566a063a92"
    end
    on_intel do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-macos-x64"
      sha256 "22703145a3ad2d7a8b203be633cec1dcabc287f9736c948c7bebc65119e2d098"
    end
  end

  on_linux do
    on_intel do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-linux-x64"
      sha256 "e9bd62ac34adb1c64cb575c33d48f5041826540717539856142ca547d514f306"
    end
    on_arm do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-linux-arm64"
      sha256 "de99922d95051466f9381a7a5cbb62d8b7603bb157e4384e3e6126ab04d4b3c1"
    end
  end

  def install
    # The downloaded file is the binary itself (no archive to unpack)
    binary = Dir["ibuild-*"].first
    bin.install binary => "ibuild"
  end

  test do
    assert_match "ibuild #{version}", shell_output("#{bin}/ibuild --version")
  end
end
