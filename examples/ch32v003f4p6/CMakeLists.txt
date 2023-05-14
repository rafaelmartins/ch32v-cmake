# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.12)

# for external projects, change the path below accordingly
include(../../cmake/ch32v.cmake)
include(CheckIPOSupported)

project(ch32v003f4p6-example C ASM)

add_executable(ch32v003f4p6-example
    main.c
    ch32v00x_it.c
)
target_include_directories(ch32v003f4p6-example PRIVATE
    .
)

target_compile_options(ch32v003f4p6-example PRIVATE
    -Wall
    -Wextra
    -Werror
)

target_compile_definitions(ch32v003f4p6-example PRIVATE
    -DCLK_FREQ_48MHZ_HSE=1
)

check_ipo_supported()
set_property(TARGET ch32v003f4p6-example PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)

ch32v_target_set_device(ch32v003f4p6-example ch32v003f4p6 DEBUG)
ch32v_target_generate_map(ch32v003f4p6-example)
ch32v_target_generate_hex(ch32v003f4p6-example)
ch32v_target_show_size(ch32v003f4p6-example)
