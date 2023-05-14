# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

add_library(ch32v00x INTERFACE)

target_sources(ch32v00x INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Core/core_riscv.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_adc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_dbgmcu.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_dma.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_exti.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_flash.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_gpio.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_i2c.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_iwdg.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_misc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_opa.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_pwr.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_rcc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_spi.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_tim.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_usart.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v00x_wwdg.c
    ${CMAKE_CURRENT_LIST_DIR}/System/system_ch32v00x.c
)

target_include_directories(ch32v00x INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Core
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/inc
    ${CMAKE_CURRENT_LIST_DIR}/System
)

add_library(ch32v00x_debug INTERFACE)

target_sources(ch32v00x_debug INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Debug/debug.c
)

target_include_directories(ch32v00x_debug INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Debug
)

function(_ch32v00x_target target mcu)
    message(STATUS "ch32v00x: Building ${target} for ${mcu}")

    cmake_parse_arguments(arg "DEBUG" "" "" ${ARGN})

    # for the chips that support multiple flash+sram configurations, we don't support them
    if(${mcu} MATCHES "^ch32v003[acfgjkrtvwz]4[mprtu][673d]$")
        set(FLASH_SIZE "16K")
        set(RAM_SIZE "2K")
    else()
        message(FATAL_ERROR "Unsupported mcu: ${mcu}")
    endif()

    message(STATUS "ch32v00x: Flash size: ${FLASH_SIZE}; RAM size: ${RAM_SIZE}")

    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Ld/Link.ld.in
        ${CMAKE_CURRENT_BINARY_DIR}/Link.ld
        @ONLY
    )

    target_sources(${target} PRIVATE
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Startup/startup_ch32v00x.S
    )
    target_compile_definitions(${target} PRIVATE
        "-DCH32V00x=1"
    )

    target_compile_options(${target} PRIVATE
        -march=rv32ec
        -mabi=ilp32e
    )

    target_link_options(${target} PRIVATE
        -march=rv32ec
        -mabi=ilp32e
        -T${CMAKE_CURRENT_BINARY_DIR}/Link.ld
    )

    target_link_libraries(${target}
        ch32v00x
    )

    if(arg_DEBUG)
        target_link_libraries(${target}
            ch32v00x_debug
        )
    endif()
endfunction()
