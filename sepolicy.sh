## GlobalFashiongallery

# fd
magiskpolicy --live "dontaudit rs { surfaceflinger hal_graphics_allocator_default } fd use"
magiskpolicy --live "allow     rs { surfaceflinger hal_graphics_allocator_default } fd use"

# tcp_socket
magiskpolicy --live "dontaudit rs { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } tcp_socket { read write }"
magiskpolicy --live "allow     rs { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } tcp_socket { read write }"

# fifo_file
magiskpolicy --live "dontaudit rs { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } fifo_file { read write }"
magiskpolicy --live "allow     rs { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } fifo_file { read write }"

# unix_stream_socket
magiskpolicy --live "dontaudit rs surfaceflinger unix_stream_socket { read write }"
magiskpolicy --live "allow     rs surfaceflinger unix_stream_socket { read write }"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } rs_exec file { read open execute }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } rs_exec file { read open execute }"


## MiuiHome

# type
magiskpolicy --live "type theme_data_file"
magiskpolicy --live "type app_data_file"
magiskpolicy --live "type vendor_overlay_file"

# dir
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } dir { read open add_name search }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } dir { read open add_name search }"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } file { create write open getattr unlink }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } file { create write open getattr unlink }"


