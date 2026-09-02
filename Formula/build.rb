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
  version "1.4.0"

  license "AGPL-3.0-or-later"

  # URLs go through the app's authenticated asset proxy, not a direct GitHub releases download —
  # this repo is private, so an unauthenticated `releases/download/...` URL 404s (G#2502/CS-3).
  # The proxy streams the exact same release asset via the GitHub App installation token; the
  # sha256 values below are unaffected (still taken from the release's own checksums.txt).
  on_macos do
    on_arm do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-macos-arm64"
      sha256 "5f00c5571586de0fc85306a15907df30013390a48dff8f428f59950017c4f0f2"
    end
    on_intel do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-macos-x64"
      sha256 "ed631344c25c6d9f45cc30635e6f1951e5867d51095ccf6c13d32eb35c19084c"
    end
  end

  on_linux do
    on_intel do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-linux-x64"
      sha256 "07e1775ffc814f04b3fd4b163ebcab91cd0bf2764bbf103462c95c010d446352"
    end
    on_arm do
      url "https://build.interactor.com/api/v1/cli/asset?tag=cli%2Fv#{version}&file=ibuild-linux-arm64"
      sha256 "de9d0379ded40c89ccf42dba07fe917baf892cf311ee44a1b7fb41bdab94fe12"
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
