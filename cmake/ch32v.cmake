# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

if(DEFINED ENV{MRS_TOOLCHAIN_PATH} AND (NOT MRS_TOOLCHAIN_PATH))
    set(MRS_TOOLCHAIN_PATH $ENV{MRS_TOOLCHAIN_PATH} CACHE PATH "Path to the MounRiver Studio toolchain" FORCE)
    message(STATUS "MRS_TOOLCHAIN_PATH: ${MRS_TOOLCHAIN_PATH}")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/ch32v-mrs-toolchain.cmake")
endif()

if(NOT MRS_TOOLCHAIN_PATH)
    message(FATAL_ERROR "No supported toolchain found!")
endif()

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../lib ch32v-lib)

function(ch32v_target_set_device target mcu)
    if(${mcu} MATCHES "^ch32v00")
        _ch32v00x_target(${target} ${mcu} ${ARGN})
    elseif(${mcu} MATCHES "^ch32v20")
        _ch32v20x_target(${target} ${mcu} ${ARGN})
    elseif(${mcu} MATCHES "^ch32v30")
        _ch32v30x_target(${target} ${mcu} ${ARGN})
    else()
        message(FATAL_ERROR "Unsupported mcu: ${mcu}")
    endif()

    add_custom_target(
        program
        COMMAND
            ${RISCV_OPENOCD}
            -f ${RISCV_OPENOCD_CONFIG}
            -c init
            -c halt
            #-c "flash erase_sector wch_riscv 0 last"
            -c "program \"$<TARGET_FILE:${target}>\" verify"
            -c wlink_reset_resume
            -c exit
        DEPENDS $<TARGET_FILE:${target}>
    )
endfunction()

function(ch32v_target_generate_map target)
    target_link_options(${target} PRIVATE
        "-Wl,-Map,$<TARGET_FILE:${target}>.map"
    )
    set_property(TARGET ${target}
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES "$<TARGET_FILE:${target}>.map"
    )
endfunction()

function(ch32v_target_generate_hex target)
    add_custom_command(
        OUTPUT ${target}.hex
        COMMAND ${RISCV_OBJCOPY} -O ihex $<TARGET_FILE:${target}> ${target}.hex
        DEPENDS $<TARGET_FILE:${target}>
    )
    add_custom_target(${target}-hex
        ALL
        DEPENDS ${target}.hex
    )
endfunction()

function(ch32v_target_show_size target)
    add_custom_command(
        TARGET ${target}
        POST_BUILD
        COMMAND ${RISCV_SIZE} --format=berkeley "$<TARGET_FILE:${target}>"
    )
endfunction()
