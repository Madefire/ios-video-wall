#!/usr/bin/env python
# Copyright (c) 2012, Madefire Inc.
# All rights reserved.

from __future__ import absolute_import

from threading import Event, Thread
from time import sleep
import SocketServer
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

PREPARE_DELAY = 2.5
IDLE_DELAY = 2.5


class Library:

    def __init__(self, videos):
        self._videos = videos
        self._index = len(videos) - 1

    def current(self):
        return self._videos[self._index]

    def next(self):
        self._index += 1
        if self._index == len(self._videos):
            self._index = 0
        return self.current()


event = Event()
# fill in the following array with the names of your videos and their
# durations, rounding up is better than down.
library = Library([('<video-name>', <video-duration-in-seconds>), ...])

class PlayRequestHandler(SocketServer.BaseRequestHandler ):

    def setup(self):
        logger.info('gained connection to %s', self.client_address)

    def handle(self):
        while True:
            event.wait()
            video = library.current()
            try:
                logger.debug('sending %s to %s', video[0], self.client_address)
                self.request.send('prepare %s' % video[0])
                sleep(PREPARE_DELAY)
                self.request.send('play')
            except:
                return

    def finish(self):
        logger.info('lost connection to %s', self.client_address)


class Director(Thread):

    def __init__(self):
        self._running = True
        Thread.__init__(self)

    def run(self):
        sleep(1)
        while self._running:
            video = library.next()
            logger.info('playing %s for %d seconds', video[0], video[1])
            event.set()
            event.clear()
            sleep(video[1] + PREPARE_DELAY + IDLE_DELAY)
        logger.info('director finished')

    def shutdown(self):
        self._running = False


director = Director()
director.start()

class Server(SocketServer.ThreadingTCPServer):

    def __init__(self, *args, **kwargs):
        SocketServer.ThreadingTCPServer.__init__(self, *args, **kwargs)
        self.allow_reuse_address = True

server = Server(('', 3333), PlayRequestHandler)
try:
    logger.info('serving')
    server.serve_forever()
except KeyboardInterrupt:
    logger.info('shutting down')
    director.shutdown()
    server.shutdown()
    director.join()
    logger.info('done')
