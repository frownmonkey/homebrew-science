class Insighttoolkit < Formula
  desc "ITK is a toolkit for performing registration and segmentation"
  homepage "http://www.itk.org"
  url "https://downloads.sourceforge.net/project/itk/itk/4.10/InsightToolkit-4.10.0.tar.gz"
  sha256 "2ede59a95c4864885c863365f9df9371c39d2b31a545e3da6bda800249840168"
  head "git://itk.org/ITK.git"

  bottle do
    sha256 "ca3455b3cda713a3bd65fe4e126b49d1adb47d23f8593131199ec61530cafa2f" => :el_capitan
    sha256 "ebf291a054a45a17b4a07ea804083e0b45505bedf63080e649ee9a283e1d0258" => :yosemite
    sha256 "73c5baa18e60f4fbed4b1682faafe8c41a02ca13297d98d12860a4e617d342c8" => :mavericks
  end

  option :cxx11
  cxx11dep = build.cxx11? ? ["c++11"] : []

  depends_on "cmake" => :build
  depends_on "opencv" => [:optional] + cxx11dep
  depends_on :python => :optional
  depends_on :python3 => :optional
  depends_on "fftw" => :recommended
  depends_on "hdf5" => [:recommended] + cxx11dep
  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "gdcm" => [:optional] + cxx11dep

  if build.with? "python3"
    depends_on "vtk" => [:build, "with-python3", "without-python"] + cxx11dep
  elsif build.with? "python"
    depends_on "vtk" => [:build, "with-python"] + cxx11dep
  else
    depends_on "vtk" => [:build] + cxx11dep
  end

  deprecated_option "examples" => "with-examples"
  deprecated_option "remove-legacy" => "with-remove-legacy"

  option "with-examples", "Compile and install various examples"
  option "with-itkv3-compatibility", "Include ITKv3 compatibility"
  option "with-remove-legacy", "Disable legacy APIs"

  def install
    args = std_cmake_args + %W[
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DITK_USE_GPU=ON
      -DITK_USE_64BITS_IDS=ON
      -DITK_USE_STRICT_CONCEPT_CHECKING=ON
      -DITK_USE_SYSTEM_ZLIB=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DModule_SCIFIO=ON
    ]
    args << ".."
    args << "-DBUILD_EXAMPLES=" + ((build.include? "examples") ? "ON" : "OFF")
    args << "-DModule_ITKVideoBridgeOpenCV=" + ((build.with? "opencv") ? "ON" : "OFF")
    args << "-DITKV3_COMPATIBILITY:BOOL=" + ((build.with? "itkv3-compatibility") ? "ON" : "OFF")

    args << "-DITK_USE_SYSTEM_FFTW=ON" << "-DITK_USE_FFTWF=ON" << "-DITK_USE_FFTWD=ON" if build.with? "fftw"
    args << "-DITK_USE_SYSTEM_HDF5=ON" if build.with? "hdf5"
    args << "-DITK_USE_SYSTEM_JPEG=ON" if build.with? "jpeg"
    args << "-DITK_USE_SYSTEM_PNG=ON" if build.with? :libpng
    args << "-DITK_USE_SYSTEM_TIFF=ON" if build.with? "libtiff"
    args << "-DITK_USE_SYSTEM_GDCM=ON" if build.with? "gdcm"
    args << "-DITK_LEGACY_REMOVE=ON" if build.include? "remove-legacy"
    args << "-DModule_ITKLevelSetsv4Visualization=ON"
    args << "-DModule_ITKReview=ON"
    args << "-DModule_ITKVtkGlue=ON"

    args << "-DVCL_INCLUDE_CXX_0X=ON" if build.cxx11?
    ENV.cxx11 if build.cxx11?

    mkdir "itk-build" do
      if build.with?("python") || build.with?("python3")

        args << "-DITK_WRAP_PYTHON=ON"

        # CMake picks up the system's python dylib, even if we have a brewed one.
        if build.with? "python"
          args << "-DPYTHON_LIBRARY='#{`python-config --prefix`.chomp}/lib/libpython2.7.dylib'"
          args << "-DPYTHON_INCLUDE_DIR='#{`python-config --prefix`.chomp}/include/python2.7'"
        elsif build.with? "python3"
          ENV["PYTHONPATH"] = lib/"python3.5/site-packages"
          args << "-DPYTHON_EXECUTABLE='#{`python3-config --prefix`.chomp}/bin/python3'"
          args << "-DPYTHON_LIBRARY='#{`python3-config --prefix`.chomp}/lib/libpython3.5.dylib'"
          args << "-DPYTHON_INCLUDE_DIR='#{`python3-config --prefix`.chomp}/include/python3.5m'"
        end

      end
      system "cmake", *args
      system "make", "install"
    end
  end
end
