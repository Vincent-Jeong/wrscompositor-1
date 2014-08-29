#!/usr/bin/env python
# -*- coding: utf-8 -*-
from twisted.internet import reactor
from twisted.internet.abstract import FileDescriptor
from twisted.python.filepath import FilePath
import sys
import time
import base64
from ipod.wrs_ipod_2 import *

connection = None

cmds = []
def deferred_call(scenario, func, *args):
    cmds.insert(0, {'func': func, 'args': args, 'tid': None, 'scenario': scenario})
    if len(cmds) == 1:
        callinfo = cmds[-1]
        callinfo['tid'] = apply(callinfo['func'], callinfo['args'])

def event_cb(c, _ev, ud):
    ev = wrs_ipod_event_type(_ev)
    broadcast = ud
    if WRSIPOD_EVENT_CONNECTED == ev:
        print 'connected'
        broadcast({'event': 'ipod connected'})
    elif WRSIPOD_EVENT_AUTHENTICATED == ev:
        print 'authenticated'
    elif WRSIPOD_EVENT_DEVICE_READY == ev:
        print 'device ready'
        if wrs_ipod_device_count(c) > 0:
            wrs_ipod_open_session_sync(c, 0)
            broadcast({'event': 'ipod ready'})
            deferred_call(None, wrs_ipod_play, c)
    elif WRSIPOD_EVENT_MODE_CHANGED == ev:
        print 'mode changed'
    elif WRSIPOD_EVENT_SAMPLERATE_RETRIEVED == ev:
        print 'samplerate retrieved'
    elif WRSIPOD_EVENT_DISCONNECTED == ev:
        print 'disconnected'
        broadcast({'event': 'ipod disconnected'})
    elif WRSIPOD_EVENT_PLAYSTATE_CHANGED == ev:
        print 'play state changed'
        broadcast({'event': 'playstate changed', 'data': wrs_ipod_current_track_state(c)})
    elif WRSIPOD_EVENT_TRACK_CHANGED == ev:
        print 'track changed', wrs_ipod_current_track_index(c)
        broadcast({'event': 'track changed', 'data': wrs_ipod_current_track_index(c)})
        deferred_call('get trackinfo', wrs_ipod_current_track_info, c)
    elif WRSIPOD_EVENT_TRACKINFO_RETRIEVED == ev:
        print 'track info retrieved'
    elif WRSIPOD_EVENT_SHUFFLE_CHANGED == ev:
        print 'changed shuffle status', wrs_ipod_current_shuffle_state(c)
        broadcast({'event': 'shuffle changed', 'data': wrs_ipod_current_shuffle_state(c)})
    elif WRSIPOD_EVENT_REPEAT_CHANGED == ev:
        print 'changed repeat status', wrs_ipod_current_repeat_state(c)
        broadcast({'event': 'shuffle changed', 'data': wrs_ipod_current_repeat_state(c)})
    elif WRSIPOD_EVENT_TRACK_POSITION_CHANGED == ev:
        print 'track_position_changed', wrs_ipod_current_track_position(c)
        broadcast({'event': 'track position changed', 'data': wrs_ipod_current_track_position(c)})
        #print 'has artwork: ',wrs_ipod_current_track_has_artwork(c)
    else:
        print 'event no ', ev

def reply_cb(c, tid, retval, error, ud):
    print 'reply_cb', c, tid, retval, error, ud
    broadcast = ud
    called = cmds.pop()
    assert called['tid'] == tid
    scenario = called['scenario']
    if scenario:
        if 'get trackinfo' == scenario:
            print 'title', wrs_ipod_current_track_title(c)
            print 'artist', wrs_ipod_current_track_artist(c)
            print 'album', wrs_ipod_current_track_album(c)
            print 'chapter', wrs_ipod_current_track_chapter(c)
            broadcast({'event': 'track info', 'data':
                        {'title': wrs_ipod_current_track_title(c),
                        #'uid': wrs_ipod_current_track_uid(c),
                        'artist': wrs_ipod_current_track_artist(c),
                        'album': wrs_ipod_current_track_album(c),
                        'chapter': wrs_ipod_current_track_chapter(c),
                        'playstate': wrs_ipod_current_track_state(c),
                        'has_artwork':wrs_ipod_current_track_has_artwork(c),
                        'has_chapters':wrs_ipod_current_track_has_chapters(c),
                        'shuffle_state':wrs_ipod_current_shuffle_state(c),
                        'repeat_state':wrs_ipod_current_repeat_state(c),
                        'number_of_tracks':wrs_ipod_current_number_of_tracks(c),
                        'track_length':wrs_ipod_current_track_length(c),
                        'track_position':wrs_ipod_current_track_position(c),
                        'track_timestamp':wrs_ipod_current_track_timestamp(c),
                        'track_timestamp':wrs_ipod_current_track_timestamp(c),
                        'track_index': wrs_ipod_current_track_index(c), }})
        elif 'get artwork' == scenario:
            print '[41m artwork [0m'
            print wrs_ipod_current_track_artwork_length(c)
            open('haha.bin', 'wb').write(wrs_ipod_current_track_artwork_pydata(c))
            print len(wrs_ipod_current_track_artwork_pydata(c)) == wrs_ipod_current_track_artwork_length(c)
            print wrs_ipod_current_track_artwork_width(c)
            print wrs_ipod_current_track_artwork_height(c)
            print wrs_ipod_current_track_artwork_rowstride(c)
            broadcast({'event': 'current artwork', 'data':
                        {'image': base64.encodestring(
                            wrs_ipod_current_track_artwork_pydata(c))
                            .replace('\n',''),
                        'width': wrs_ipod_current_track_artwork_width(c),
                        'height': wrs_ipod_current_track_artwork_height(c),
                        'rowstride':wrs_ipod_current_track_artwork_rowstride(c)}
                        })
        else:
            print scenario

    if cmds:
        next_call = cmds[-1]
        next_call['tid'] = apply(next_call['func'], next_call['args'])

class IPodClient(FileDescriptor):
    def __init__(self, c):
        FileDescriptor.__init__(self, reactor)
        global connection
        self.c = c
        connection = c
    def fileno(self):
        return wrs_ipod_fd(self.c)
    def doRead(self):
        wrs_ipod_read(self.c)
    def connectionLost(self, reason):
        global connection
        print 'ipod daemon closed'
        wrs_ipod_close(self.c)
        self.c = None
        connection = None

class IPodController:
    def __init__(self, c):
        self.c = c
    def command(self, func, args=()):
        if func == 'play':
            deferred_call(None, wrs_ipod_play, self.c)
        elif func == 'stop':
            deferred_call(None, wrs_ipod_stop, self.c)
        elif func == 'pause':
            deferred_call(None, wrs_ipod_pause, self.c)
        elif func == 'next':
            deferred_call(None, wrs_ipod_next_track, self.c)
        elif func == 'prev':
            deferred_call(None, wrs_ipod_prev_track, self.c)
        elif func == 'get_trackinfo':
            deferred_call('get trackinfo', wrs_ipod_current_track_info, self.c)
        elif func == 'get_artwork':
            deferred_call('get artwork', wrs_ipod_current_track_artwork, self.c, args[0])


def run_ipodclient(broadcastCallback):
    global connection
    if connection:
        return IPodController(connection)
    c = wrs_ipod_connect(None)
    if not c:
        print 'Could not connect to ipod-daemon-2'
        return None

    wrs_ipod_set_event_pycb(c, event_cb, broadcastCallback);
    wrs_ipod_set_reply_pycb(c, reply_cb, broadcastCallback);
    if wrs_ipod_device_count(c) > 0:
        wrs_ipod_open_session_sync(c, 0)
        deferred_call(None, wrs_ipod_play, c)

    reactor.addReader(IPodClient(c))
    return IPodController(c)

# vim: sw=4 ts=8 sts=4 et bs=2 fdm=marker fileencoding=utf8