if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    if uwsm check may-start; then
        exec uwsm start hyprland.desktop
    fi
fi
# if uwsm check may-start; then
#     exec uwsm start hyprland.desktop
# fi
# if uwsm check may-start && uwsm select; then
#     exec systemd-cat -t uwsm_start uwsm start default
# fi
