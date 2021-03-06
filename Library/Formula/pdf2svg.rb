require 'formula'

def have_poppler_glib?
  # Not using Homebrew's system wrapper because we actually want to see the
  # exit code of the command.
  Kernel.system "#{HOMEBREW_PREFIX}/bin/pkg-config", "poppler-glib", "--exists"
end

class Pdf2svg < Formula
  url 'http://www.cityinthesky.co.uk/_media/opensource/pdf2svg-0.2.1.tar.gz'
  homepage 'http://www.cityinthesky.co.uk/opensource/pdf2svg'
  md5 '59b3b9768166f73b77215e95d91f0a9d'

  depends_on "pkg-config" => :build

  depends_on "poppler"
  depends_on "gtk+"
  depends_on "cairo" # Poppler-glib needs a newer cairo than provided by OS X 10.6.x
                     # and pdf2svg needs it to be on PKG_CONFIG_PATH during the build

  def patches
    # fix call to poppler to render normal thickness lines in firefox
    DATA
  end

  def install
    unless have_poppler_glib?
      onoe <<-EOS.undent
        pkg-config could not find poppler-glib! Please try re-installing
        Poppler with support for the Glib backend:

            brew uninstall poppler
            brew install --with-glib poppler
      EOS
      exit 1
    end

    ENV.x11
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make install"
  end
end

__END__
--- pdf2svg-0.2.1/pdf2svg.c.ORIG        2008-02-01 10:28:35.000000000 -0800
+++ pdf2svg-0.2.1/pdf2svg.c     2011-11-26 03:56:15.000000000 -0800
@@ -65,7 +65,7 @@
     drawcontext = cairo_create(surface);
 
     // Render the PDF file into the SVG file
-    poppler_page_render(page, drawcontext);
+    poppler_page_render_for_printing(page, drawcontext);
     cairo_show_page(drawcontext);
 
     // Close the SVG file
