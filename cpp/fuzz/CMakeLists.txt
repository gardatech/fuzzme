set(LIB_FUZZING_ENGINE $ENV{LIB_FUZZING_ENGINE})

if (NOT LIB_FUZZING_ENGINE)
    set(LIB_FUZZING_ENGINE "-fsanitize=fuzzer")
endif()

add_compile_options(-fsanitize=fuzzer-no-link)
add_executable(fuzzme fuzz.cpp)
target_link_libraries(fuzzme PRIVATE ${LIB_FUZZING_ENGINE})

