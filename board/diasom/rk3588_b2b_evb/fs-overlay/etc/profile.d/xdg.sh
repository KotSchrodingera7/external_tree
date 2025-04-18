# Set XDG_RUNTIME_DIR manually.
# The variable is not set for ssh login, causing app failures. It's not clear
# if this is an error or by design, but setting it manually does help and
# doesn't seem to hurt...

if test -z "$XDG_RUNTIME_DIR"; then
	export XDG_RUNTIME_DIR=/run/weston
fi

if test -z "$WAYLAND_DISPLAY"; then
	export WAYLAND_DISPLAY=wayland-1
fi

if [ ! -d $XDG_RUNTIME_DIR ]; then
	mkdir -p $XDG_RUNTIME_DIR
fi

chmod 0700 $XDG_RUNTIME_DIR
