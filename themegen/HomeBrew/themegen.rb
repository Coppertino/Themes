require 'formula'

class Themegen < Formula
    head 'https://github.com/Coppertino/Themes.git', :branch => 'master'
    homepage 'https://github.com/Coppertino/Themes'
    
    def install
        system "xcodebuild", "-project", "themes.xcodeproj",
        "-target", "themegen",
        "-configuration", "Release",
        "install",
        "SYMROOT=build",
        "DSTROOT=build",
        "INSTALL_PATH=/bin"
        bin.install "build/bin/themegen"
    end
end