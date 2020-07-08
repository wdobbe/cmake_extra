
# Usage example:
#
# flatcc_generate_sources(GENERATED_SOURCE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/datadef
#                         GENERATE_BUILDER
#                         GENERATE_VERIFIER
#                         EXPECTED_OUTPUT_FILES datadef/seclif_protocol_reader.h 
#                                               datadef/seclif_protocol_builder.h 
#                                               datadef/seclif_protocol_verifier.h
#                         DEFINITION_FILES ${CMAKE_CURRENT_SOURCE_DIR}/datadef/seclif_protocol.fbs
# )
#
# GENERATED_SOURCE_DIRECTORY: directory where you want flatcc to save the generated C source files
#
# GENERATE_BUILDER: enables code generation to build buffers
#
# GENERATE_VERIFIER: generates a verifier file per schema
#
# EXPECTED_OUTPUT_FILES: the C source files that you expect flatcc to generate.
#
# DEFINITION_FILES: the flatbuffer input schema file(s)


function(flatcc_generate_sources)
    
    # parse function arguments
    set(OUTPREFIX "FLATCC") #variables created by 'cmake_parse_arguments' will be prefixed with this
    set(NO_VAL_ARGS GENERATE_BUILDER GENERATE_VERIFIER)
    set(SINGLE_VAL_ARGS GENERATED_SOURCE_DIRECTORY)
    set(MULTI_VAL_ARGS DEFINITION_FILES EXPECTED_OUTPUT_FILES CC_OPTIONS)
    
    cmake_parse_arguments(${OUTPREFIX}
                          "${NO_VAL_ARGS}"
                          "${SINGLE_VAL_ARGS}"
                          "${MULTI_VAL_ARGS}"
                          ${ARGN}
    )
    if (GENERATED_SOURCE_DIRECTORY IN_LIST FLATCC_KEYWORDS_MISSING_VALUES)
        message(FATAL_ERROR "No directory provided after GENERATED_SOURCE_DIRECTORY keyword")
    endif()
    if (NOT FLATCC_GENERATED_SOURCE_DIRECTORY)
        set(FLATCC_GENERATED_SOURCE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    message(STATUS "Flatcc sources will be generated in directory ${FLATCC_GENERATED_SOURCE_DIRECTORY}")

    if (FLATCC_GENERATE_BUILDER)
        list(APPEND FLATCC_CC_OPTIONS --builder)
    endif()
    if (FLATCC_GENERATE_VERIFIER)
        list(APPEND FLATCC_CC_OPTIONS --verifier)
    endif()
    
    if (FLATCC_DEFINITION_FILES)
        if (NOT EXISTS ${FLATCC_GENERATED_SOURCE_DIRECTORY})
            file(MAKE_DIRECTORY ${FLATCC_GENERATED_SOURCE_DIRECTORY})
        endif()
        message(VERBOSE "Executing command ${FlatCC_EXE} ${FLATCC_CC_OPTIONS} -o ${FLATCC_GENERATED_SOURCE_DIRECTORY} ${FLATCC_DEFINITION_FILES}")
        add_custom_command(OUTPUT ${FLATCC_EXPECTED_OUTPUT_FILES}
                           COMMAND ${FlatCC_EXE} ${FLATCC_CC_OPTIONS} -o ${FLATCC_GENERATED_SOURCE_DIRECTORY} ${FLATCC_DEFINITION_FILES}
                           WORKING_DIRECTORY ${FLATCC_GENERATED_SOURCE_DIRECTORY})
    else()
        message(WARNING "No flatbuffer definition files provided, no sources will be generated")
    endif()

endfunction()
