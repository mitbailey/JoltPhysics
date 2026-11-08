# Builds JoltPhysics (Linux + Windows/mingw) with a consistent set of
# instruction-set options, so it matches the JoltC wrapper build.
#
# Usage:
#   make            build both Linux and Windows
#   make linux      build only Linux
#   make windows    build only Windows
#   make clean      remove both build directories
#   make clean-linux / make clean-windows

JOLT_DIR   := .
JOLT_BUILD := $(JOLT_DIR)/Build
JOBS       := 12

LINUX_DIR   := Linux_Debug
WINDOWS_DIR := Win_Debug

# Must match the flags JoltC is compiled with (SSE4.2 only, no AVX etc.)
ISA_FLAGS := -DUSE_AVX=OFF \
             -DUSE_AVX2=OFF \
             -DUSE_AVX512=OFF \
             -DUSE_LZCNT=OFF \
             -DUSE_TZCNT=OFF \
             -DUSE_F16C=OFF \
             -DUSE_FMADD=OFF \
			 -DUSE_ASSERTS=ON

.PHONY: all linux windows clean clean-linux clean-windows

all: linux windows

linux:
	cd $(JOLT_BUILD) && \
	./cmake_linux_clang_gcc.sh Debug clang++ \
		-DJPH_USE_VK=OFF \
		-DBUILD_SAMPLES=OFF \
		-DBUILD_JOLT_VIEWER=OFF \
		-DCPP_RTTI_ENABLED=ON \
		$(ISA_FLAGS)
	$(MAKE) -C $(JOLT_BUILD)/$(LINUX_DIR) Jolt -j$(JOBS)

windows:
	cd $(JOLT_BUILD) && \
	cmake -S . -B $(WINDOWS_DIR) \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
		-DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
		-DCMAKE_RC_COMPILER=x86_64-w64-mingw32-windres \
		-DCMAKE_BUILD_TYPE=Debug \
		-DTARGET_UNIT_TESTS=OFF \
		-DTARGET_HELLO_WORLD=OFF \
		-DTARGET_PERFORMANCE_TEST=OFF \
		-DTARGET_SAMPLES=OFF \
		-DTARGET_VIEWER=OFF \
		-DJPH_USE_VK=OFF \
		-DJPH_USE_DX12=OFF \
		-DJPH_USE_MTL=OFF \
		-DCPP_RTTI_ENABLED=ON \
		$(ISA_FLAGS) \
		-DINTERPROCEDURAL_OPTIMIZATION=OFF
	cd $(JOLT_BUILD) && cmake --build $(WINDOWS_DIR) -j$(JOBS)

clean: clean-linux clean-windows

clean-linux:
	rm -rf $(JOLT_BUILD)/$(LINUX_DIR)

clean-windows:
	rm -rf $(JOLT_BUILD)/$(WINDOWS_DIR)