add_executable(mxnet2ncnn mxnet2ncnn.cpp)
install(TARGETS mxnet2ncnn EXPORT ${TARGETS_EXPORT_NAME} DESTINATION bin COMPONENT bin)
