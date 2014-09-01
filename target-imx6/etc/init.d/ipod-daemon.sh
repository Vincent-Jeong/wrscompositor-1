#! /bin/sh -e
### BEGIN INIT INFO
# Provides:          ipod daemon 2
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Should-Start:      avahi udev NetworkManager
# Should-Stop:       avahi udev NetworkManager
# Default-Start:     5
# Default-Stop:      0 6
# Short-Description: Start the ipod daemon
# Description:       System mode startup script for
#                    the ipod daemon.
### END INIT INFO

NAME=ipod-daemon-2
DAEMON=/usr/bin/$NAME
PATH=/sbin:/bin:/usr/bin
PIDFILE=/var/run/ipod-daemon.pid

cp_reset() {
        echo 171 > /sys/class/gpio/export
        echo "out" > /sys/class/gpio/gpio171/direction
        echo "0" > /sys/class/gpio/gpio171/value
        msleep 250
        echo "1" > /sys/class/gpio/gpio171/value
        msleep 250
        echo 171 > /sys/class/gpio/unexport
}

ipod_daemon_start() {
        echo "Starting $NAME"
        cp_reset
	start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE -exec "$DAEMON"
}

ipod_daemon_stop() {
        echo "Stopping $NAME"
	start-stop-daemon --stop --background --pidfile $PIDFILE --exec "$DAEMON"
	rm -f $PIDFILE
}


case "$1" in
        start|stop)
                ipod_daemon_${1}
                ;;
        restart)
                echo "Restarting $DAEMON"
                ipod_daemon_stop
                sleep 1
                ipod_daemon_start
                ;;
        status)
                ;;
        *)
                echo "Usage: /etc/init.d/ipod-daemon {start|stop|restart|status}"
                exit 1
                ;;

esac

exit 0

