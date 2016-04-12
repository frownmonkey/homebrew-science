class Nfft < Formula
  homepage "http://www-user.tu-chemnitz.de/~potts/nfft"
  url "http://www-user.tu-chemnitz.de/~potts/nfft/download/nfft-3.2.3.tar.gz"
  sha256 "5c920f4be63230083756f36ad78bbdd083c4c2298ec361741dc74243c4d67818"

  bottle do
    cellar :any
    sha256 "974d157ac1307b48aa95fd4fcf15b737c0eac42409fd35a4b7faf5b383d9b5ef" => :yosemite
    sha256 "31491ef2ea68c1a516b33ed28ee65bb03f1ad3976f58f69f5b1fbe69054949c5" => :mavericks
    sha256 "0636617b35ad4b61cdfe51f50db319f4247ee0482b36a6ddbb8f9d09f387f6f4" => :mountain_lion
  end

  depends_on "fftw"

  fails_with :clang do
    build 425
    cause "Cannot compile complex compound assignment (works for >=503)"
  end

  def install
    args = %W[--disable-debug --disable-dependency-tracking --prefix=#{prefix}]
    if ENV.compiler == :clang
      opoo "Clang does not support OpenMP. Compile with gcc (--cc=gcc-x.y) if this is not acceptable."
    else
      args << "--enable-openmp"
    end
    system "./configure", *args
    system "make", "install"
    system "make", "check"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <nfft3.h>
      #include <nfft3util.h>

      int main()
      {
        nfft_plan p;
        int N=14;
        int M=19;
        nfft_init_1d(&p,N,M);
        nfft_vrand_shifted_unit_double(p.x,p.M_total);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lnfft3", "-o", "test"
    system "./test"
  end

  def caveats
    <<-EOS.undent
    NFFT is built as serial (not multi-threaded) library by default
    when being built with clang, as this compiler doesn't support
    OpenMP.

    A multi-threaded version of the NFFT library can be build with
    Homebrew's GNU C compiler, using

      brew install --cc=gcc-x.y nfft

    which will create both serial and multi-threaded NFFT libraries.

    Linking against the serial libraries:

       ... -L#{opt_lib} -lnfft -lfftw3 ...

    Linking against the multi-threaded libraries (if built):

       ... -L#{opt_lib} -lnfft_threads -lfftw3_threads ...

    EOS
  end
end