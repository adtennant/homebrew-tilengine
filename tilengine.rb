class Tilengine < Formula
  desc "Tilengine is a free, cross-platform 2D graphics engine for creating classic/retro games with tilemaps, sprites and palettes. Its unique scanline-based rendering system makes raster effects a core feature, a technique used by many games running on real 2D graphics chips."
  homepage "http://www.tilengine.org/"
  url "https://github.com/adtennant/tilengine.git", :revision => "c8d8e167f98dd27e58102172e4ffb1054aff1eca"
  version "1.15"

  depends_on "libpng"
  depends_on "sdl2"

  def install
    include.install "include/Tilengine.h"

    system "install_name_tool", "-change", "@rpath/SDL2.framework/Versions/A/SDL2", "/usr/local/lib/libSDL2.dylib", "lib/darwin_x86_64/Tilengine.dylib"
    lib.install "lib/darwin_x86_64/Tilengine.dylib"

    inreplace "tilengine-config.cmake" do |s|
      s.gsub! "<library>", "Tilengine.dylib"
      s.gsub! "<incpath>", "#{HOMEBREW_PREFIX}/include"
      s.gsub! "<libpath>", "#{HOMEBREW_PREFIX}/lib"
    end

    (lib/"cmake/Tilengine").install "tilengine-config.cmake"
    
    inreplace "tilengine.pc" do |s|
      s.gsub! "<library>", "Tilengine.dylib"
      s.gsub! "<incpath>", "#{HOMEBREW_PREFIX}/include"
      s.gsub! "<libpath>", "#{HOMEBREW_PREFIX}/lib"
    end

    (lib/"pkgconfig").install "tilengine.pc"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <Tilengine.h>
      int main() {
        TLN_Init(320, 240, 2, 1, 3);
        TLN_Deinit();
        return 0;
      }
    EOS
    system ENV.cc, "test.cpp", "#{lib}/Tilengine.dylib", "-o", "test"
    system "./test"
  end
end
