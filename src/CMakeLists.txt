##############################################

configure_file(platform.h.in ${CMAKE_CURRENT_BINARY_DIR}/platform.h)
set(ncnn_SRCS
    blob.cpp
    cpu.cpp
    layer.cpp
    mat.cpp
    mat_pixel.cpp
    modelbin.cpp
    net.cpp
    opencv.cpp
    paramdict.cpp
    benchmark.cpp
)

macro(ncnn_add_layer class)
    string(TOLOWER ${class} name)

    # WITH_LAYER_xxx option
    if(${ARGC} EQUAL 2)
        option(WITH_LAYER_${name} "build with layer ${name}" ${ARGV1})
    else()
        option(WITH_LAYER_${name} "build with layer ${name}" ON)
    endif()

    message("WITH_LAYER_${name} = ${WITH_LAYER_${name}}")

    if(WITH_LAYER_${name})
        list(APPEND ncnn_SRCS "${CMAKE_CURRENT_SOURCE_DIR}/layer/${name}.cpp")

        # look for arch specific implementation and append source
        # optimized implementation for armv7 aarch64
        if((ANDROID AND ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv7-a"))
            OR (ANDROID AND ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "aarch64"))
            OR (IOS AND ("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "armv7"))
            OR (IOS AND ("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "arm64"))
            OR (IOS AND ("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "armv7;arm64")))
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/layer/arm/${name}_arm.cpp")
                list(APPEND ncnn_SRCS "${CMAKE_CURRENT_SOURCE_DIR}/layer/arm/${name}_arm.cpp")
                set(WITH_LAYER_${name}_arm 1)
            endif()
        else()
            if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/layer/x86/${name}_x86.cpp")
                list(APPEND ncnn_SRCS "${CMAKE_CURRENT_SOURCE_DIR}/layer/x86/${name}_x86.cpp")
                set(WITH_LAYER_${name}_x86 1)
            endif()
        endif()
    endif()

    # generate layer_declaration and layer_registry file
    if(WITH_LAYER_${name})
        if(WITH_LAYER_${name}_arm)
            file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_declaration.h
                "extern Layer* ${class}_arm_layer_creator();\n")
            file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_registry.h
                "#if NCNN_STRING\n{\"${class}\",${class}_arm_layer_creator},\n#else\n{${class}_arm_layer_creator},\n#endif\n")
        elseif(WITH_LAYER_${name}_x86)
            file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_declaration.h
                "extern Layer* ${class}_x86_layer_creator();\n")
            file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_registry.h
                "#if NCNN_STRING\n{\"${class}\",${class}_x86_layer_creator},\n#else\n{${class}_x86_layer_creator},\n#endif\n")
        else()
            file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_declaration.h
                "extern Layer* ${class}_layer_creator();\n")
            file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_registry.h
                "#if NCNN_STRING\n{\"${class}\",${class}_layer_creator},\n#else\n{${class}_layer_creator},\n#endif\n")
        endif()
    else()
        file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_registry.h "#if NCNN_STRING\n{\"${class}\",0},\n#else\n{0},\n#endif\n")
    endif()

    # generate layer_type_enum file
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/layer_type_enum.h "${class} = ${__LAYER_TYPE_ENUM_INDEX},\n")
    math(EXPR __LAYER_TYPE_ENUM_INDEX "${__LAYER_TYPE_ENUM_INDEX}+1")
endmacro()

# create new
file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/layer_declaration.h)
file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/layer_registry.h)
file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/layer_type_enum.h)
set(__LAYER_TYPE_ENUM_INDEX 0)

# layer implementation
ncnn_add_layer(AbsVal)
ncnn_add_layer(ArgMax OFF)
ncnn_add_layer(BatchNorm)
ncnn_add_layer(Bias)
ncnn_add_layer(BNLL)
ncnn_add_layer(Concat)
ncnn_add_layer(Convolution)
ncnn_add_layer(Crop)
ncnn_add_layer(Deconvolution)
ncnn_add_layer(Dropout)
ncnn_add_layer(Eltwise)
ncnn_add_layer(ELU)
ncnn_add_layer(Embed)
ncnn_add_layer(Exp)
ncnn_add_layer(Flatten)
ncnn_add_layer(InnerProduct)
ncnn_add_layer(Input)
ncnn_add_layer(Log)
ncnn_add_layer(LRN)
ncnn_add_layer(MemoryData)
ncnn_add_layer(MVN)
ncnn_add_layer(Pooling)
ncnn_add_layer(Power)
ncnn_add_layer(PReLU)
ncnn_add_layer(Proposal)
ncnn_add_layer(Reduction)
ncnn_add_layer(ReLU)
ncnn_add_layer(Reshape)
ncnn_add_layer(ROIPooling)
ncnn_add_layer(Scale)
ncnn_add_layer(Sigmoid)
ncnn_add_layer(Slice)
ncnn_add_layer(Softmax)
ncnn_add_layer(Split)
ncnn_add_layer(SPP OFF)
ncnn_add_layer(TanH)
ncnn_add_layer(Threshold)
ncnn_add_layer(Tile OFF)
ncnn_add_layer(RNN OFF)
ncnn_add_layer(LSTM OFF)
ncnn_add_layer(BinaryOp)
ncnn_add_layer(UnaryOp)
ncnn_add_layer(ConvolutionDepthWise)
ncnn_add_layer(Padding)
ncnn_add_layer(Squeeze)
ncnn_add_layer(ExpandDims)
ncnn_add_layer(Normalize)
ncnn_add_layer(Permute)
ncnn_add_layer(PriorBox)
ncnn_add_layer(DetectionOutput)
ncnn_add_layer(Interp)
ncnn_add_layer(DeconvolutionDepthWise)
ncnn_add_layer(ShuffleChannel)
ncnn_add_layer(InstanceNorm)

add_library(ncnn ${ncnn_SRCS})
target_include_directories(ncnn 
  PUBLIC # these will be propagated to dependencies
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/layer>"
)

# Installation (https://github.com/forexample/package-example) {

# Layout. This works for all platforms:
#   * <prefix>/lib/cmake/<PROJECT-NAME>
#   * <prefix>/lib/
#   * <prefix>/include/
set(config_install_dir "lib/cmake/${PROJECT_NAME}")
set(include_install_dir "include")

set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

# Configuration
set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
set(namespace "${PROJECT_NAME}::")

# Include module with fuction 'write_basic_package_version_file'
include(CMakePackageConfigHelpers)

# Configure '<PROJECT-NAME>ConfigVersion.cmake'
# Use:
#   * PROJECT_VERSION
write_basic_package_version_file(
    "${version_config}" COMPATIBILITY SameMajorVersion
)

# Configure '<PROJECT-NAME>Config.cmake'
# Use variables:
#   * TARGETS_EXPORT_NAME
#   * PROJECT_NAME
configure_package_config_file(
    "${NCNN_TOP_DIR}/cmake/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
)

# Targets:
#   * header location after install: <prefix>/include/ncnn/ncnn.hpp
#   * headers can be included by C++ code `#include <ncnn/ncnn.hpp>`
install(
    TARGETS ncnn
    EXPORT "${TARGETS_EXPORT_NAME}"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    INCLUDES DESTINATION "${include_install_dir}"
)

# Headers:
#   * include/ncnn/ncnn.hpp -> <prefix>/include/ncnn/ncnn.hpp
install(FILES
    blob.h
    cpu.h
    layer.h
    layer_type.h
    mat.h
    modelbin.h
    net.h
    opencv.h
    paramdict.h
    benchmark.h
    ${CMAKE_CURRENT_BINARY_DIR}/layer_type_enum.h
    ${CMAKE_CURRENT_BINARY_DIR}/platform.h
    DESTINATION "${include_install_dir}"
)

# Config
#   * <prefix>/lib/cmake/ncnn/ncnnConfig.cmake
#   * <prefix>/lib/cmake/ncnn/ncnnConfigVersion.cmake
install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
)

# Config
#   * <prefix>/lib/cmake/ncnn/ncnnTargets.cmake
install(
    EXPORT "${TARGETS_EXPORT_NAME}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}"
)

# }
