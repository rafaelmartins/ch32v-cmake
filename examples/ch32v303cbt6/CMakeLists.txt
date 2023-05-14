# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.12)

# for external projects, change the path below accordingly
include(../../cmake/ch32v.cmake)
include(CheckIPOSupported)

project(ch32v303cbt6-example C ASM)

add_executable(ch32v303cbt6-example
    main.c
    ch32v30x_it.c
)
target_include_directories(ch32v303cbt6-example PRIVATE
    .
)

target_compile_options(ch32v303cbt6-example PRIVATE
    -Wall
    -Wextra
    -Werror
)

target_compile_definitions(ch32v303cbt6-example PRIVATE
    -DCLK_FREQ_144MHZ_HSE=1
    -DDEBUG_UART=1
)

check_ipo_supported()
set_property(TARGET ch32v303cbt6-example PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)

ch32v_target_set_device(ch32v303cbt6-example ch32v303cbt6 DEBUG)
ch32v_target_generate_map(ch32v303cbt6-example)
ch32v_target_generate_hex(ch32v303cbt6-example)
ch32v_target_show_size(ch32v303cbt6-example)
