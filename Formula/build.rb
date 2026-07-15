# Homebrew formula for ibuild — the Interactor build sync daemon.
#
# This file lives in cli/homebrew/build.rb in the product-manager repo.
# The release workflow (cli-release.yml) updates version + sha256 values
# and pushes the result to the interactor-oss/homebrew-tap repo.
#
# Manual submission:
#   cp cli/homebrew/build.rb /path/to/homebrew-tap/Formula/build.rb
#   # update version and sha256, then open a PR

class Build < Formula
  desc "Bidirectional sync daemon for Interactor PM tasks/goals — works in any project"
  homepage "https://build.interactor.com"
  version "1.0.1"

  license "AGPL-3.0-or-later"

  on_macos do
    on_arm do
      url "https://github.com/InteractorOSS/product-manager/releases/download/cli/v#{version}/ibuild-macos-arm64"
      sha256 "a0542810ef5f8db9cc196722d01c6e64bb55fa6ca9c93407ff47831d084f3d64"
    end
    on_intel do
      url "https://github.com/InteractorOSS/product-manager/releases/download/cli/v#{version}/ibuild-macos-x64"
      sha256 "610d33b01fb7e7f3510c978d058d15912ad16eb220baca3643ca97dc08766f5d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/InteractorOSS/product-manager/releases/download/cli/v#{version}/ibuild-linux-x64"
      sha256 "74c712605f7f5bce38eabbe54e061aa8d7d3a51626579d07a433b5430bb00ced"
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
