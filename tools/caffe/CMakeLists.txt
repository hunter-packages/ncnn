# Compatibility Mode introduced by protobuf
# * see examples/Protobuf for usage of protobuf_MODULE_COMPATIBLE=OFF
option(protobuf_MODULE_COMPATIBLE "use protobuf in module compatible mode" ON)
hunter_add_package(Protobuf)
find_package(Protobuf CONFIG REQUIRED)

protobuf_generate_cpp(CAFFE_PROTO_SRCS CAFFE_PROTO_HDRS caffe.proto)

add_executable(caffe2ncnn caffe2ncnn.cpp ${CAFFE_PROTO_SRCS} ${CAFFE_PROTO_HDRS})
target_include_directories(caffe2ncnn
  PUBLIC # For generated files
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
)

target_link_libraries(caffe2ncnn protobuf::libprotobuf)
install(TARGETS caffe2ncnn EXPORT ${TARGETS_EXPORT_NAME} DESTINATION bin COMPONENT bin)
