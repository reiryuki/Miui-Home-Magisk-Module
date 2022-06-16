## MiuiHome

# debug
magiskpolicy --live "dontaudit system_server system_file file write"
magiskpolicy --live "allow     system_server system_file file write"

# context
magiskpolicy --live "type vendor_overlay_file"
magiskpolicy --live "type theme_data_file"
magiskpolicy --live "dontaudit theme_data_file labeledfs filesystem associate"
magiskpolicy --live "allow     theme_data_file labeledfs filesystem associate"
magiskpolicy --live "dontaudit init theme_data_file dir relabelfrom"
magiskpolicy --live "allow     init theme_data_file dir relabelfrom"
magiskpolicy --live "dontaudit init theme_data_file file relabelfrom"
magiskpolicy --live "allow     init theme_data_file file relabelfrom"
magiskpolicy --live "type app_data_file"
magiskpolicy --live "dontaudit app_data_file labeledfs filesystem associate"
magiskpolicy --live "allow     app_data_file labeledfs filesystem associate"
magiskpolicy --live "dontaudit init app_data_file dir relabelfrom"
magiskpolicy --live "allow     init app_data_file dir relabelfrom"
magiskpolicy --live "dontaudit init app_data_file file relabelfrom"
magiskpolicy --live "allow     init app_data_file file relabelfrom"

# service_manager
magiskpolicy --live "allow { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } default_android_service service_manager find"

# dir
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } dir { read open add_name search }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } dir { read open add_name search }"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } file { create write open getattr unlink }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { theme_data_file app_data_file } file { create write open getattr unlink }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } apk_data_file file ioctl"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } apk_data_file file ioctl"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } incremental_prop file { read open getattr }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } incremental_prop file { read open getattr }"

# unix_stream_socket
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } zygote unix_stream_socket getopt"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } zygote unix_stream_socket getopt"


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
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } rs_exec file { read open execute execute_no_trans getattr }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } rs_exec file { read open execute execute_no_trans getattr }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } app_data_file file execute"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } app_data_file file execute"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } proc_pid_max file read"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } proc_pid_max file read"


