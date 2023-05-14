# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

add_library(ch32v20x INTERFACE)

target_sources(ch32v20x INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Core/core_riscv.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_adc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_bkp.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_can.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_crc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_dbgmcu.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_dma.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_exti.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_flash.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_gpio.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_i2c.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_iwdg.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_misc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_opa.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_pwr.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_rcc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_rtc.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_spi.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_tim.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_usart.c
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/src/ch32v20x_wwdg.c
    ${CMAKE_CURRENT_LIST_DIR}/System/system_ch32v20x.c
)

target_include_directories(ch32v20x INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Core
    ${CMAKE_CURRENT_LIST_DIR}/Peripheral/inc
    ${CMAKE_CURRENT_LIST_DIR}/System
)

add_library(ch32v20x_debug INTERFACE)

target_sources(ch32v20x_debug INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Debug/debug.c
)

target_include_directories(ch32v20x_debug INTERFACE
    ${CMAKE_CURRENT_LIST_DIR}/Debug
)

function(_ch32v20x_target target mcu)
    message(STATUS "ch32v20x: Building ${target} for ${mcu}")

    cmake_parse_arguments(arg "DEBUG" "" "" ${ARGN})

    # for the chips that support multiple flash+sram configurations, we don't support them
    if(${mcu} MATCHES "^ch32v203[acfgjkrtvwz]6[mprtu][673d]$")
        set(FLASH_SIZE "64K")
        set(RAM_SIZE "20K")
    elseif(${mcu} MATCHES "^ch32v203[acfgjkrtvwz]8[mprtu][673d]$")
        set(FLASH_SIZE "64K")
        set(RAM_SIZE "20K")
    elseif(${mcu} MATCHES "^ch32v203[acfgjkrtvwz]b[mprtu][673d]$")
        set(FLASH_SIZE "128K")
        set(RAM_SIZE "64K")
    else()
        message(FATAL_ERROR "Unsupported mcu: ${mcu}")
    endif()

    message(STATUS "ch32v20x: Flash size: ${FLASH_SIZE}; RAM size: ${RAM_SIZE}")

    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Ld/Link.ld.in
        ${CMAKE_CURRENT_BINARY_DIR}/Link.ld
        @ONLY
    )

    if(${mcu} MATCHES "^ch32v208")
        target_sources(${target} PRIVATE
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Startup/startup_ch32v20x_D8W.S
        )
        target_compile_definitions(${target} PRIVATE
            "-DCH32V20x_D8W=1"
        )
    elseif(${mcu} MATCHES "^ch32v203[acfgjkrtvwz]b")
        target_sources(${target} PRIVATE
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Startup/startup_ch32v20x_D8.S
        )
        target_compile_definitions(${target} PRIVATE
            "-DCH32V20x_D8=1"
        )
    else()
        target_sources(${target} PRIVATE
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Startup/startup_ch32v20x_D6.S
        )
        target_compile_definitions(${target} PRIVATE
            "-DCH32V20x_D6=1"
        )
    endif()

    set(march "rv32imac")
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12.0.0")
        set(march "${march}_zicsr")
    endif()

    target_compile_options(${target} PRIVATE
        -march=${march}
        -mabi=ilp32
    )

    target_link_options(${target} PRIVATE
        -march=${march}
        -mabi=ilp32
        -T${CMAKE_CURRENT_BINARY_DIR}/Link.ld
    )

    target_link_libraries(${target}
        ch32v20x
    )

    if(arg_DEBUG)
        target_link_libraries(${target}
            ch32v20x_debug
        )
    endif()
endfunction()
