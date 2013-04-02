Pod::Spec.new do |s|
  s.name         = "Themes"
  s.version      = "0.0.1"
  s.summary      = "OSX Application Theme generator and manager."
  s.homepage     = "https://github.com/Coppertino/Themes"

  s.license      = { 
    :type => 'MIT', 
    :text => <<-LICENSE
    Copyright (c) 2013 Coppertino Inc. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
  LICENSE
  }
  
  s.author       = { "Coppertino Inc." => "dev@coppertino.com" }
  s.source       = { :git => "https://github.com/Coppertino/Themes.git", :commit => "deceb09ae39683b30f06ceb2aa5d7755520e67c1" }
  s.platform     = :osx, '10.7'

  s.source_files = 'Theme', 'Theme/*.{h,m}'
  s.public_header_files = 'Theme/*.h'
  s.requires_arc = true
  s.frameworks    = 'Cocoa'
end
