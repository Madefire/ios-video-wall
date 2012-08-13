#!/usr/bin/env python
# Copyright (c) 2012, Madefire Inc.
# All rights reserved.

from getopt import getopt
from sys import argv
from subprocess import PIPE, Popen, check_call
import argparse
import re

video_pattern = re.compile(r'Stream.*Video.* ([0-9]+)x([0-9]+)')
image_pattern = re.compile(r' ([0-9]+)x([0-9]+) ')


def get_size_of_video(src):
    p = Popen(['avconv', '-i', src], stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    match = video_pattern.search(stderr)
    if match:
        x, y = map(int, match.groups())
    else:
        raise Exception('failed to determine video size')
    return x, y


def get_size_of_image(src):
    p = Popen(['identify', src], stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    match = image_pattern.search(stdout)
    if match:
        x, y = map(int, match.groups())
    else:
        raise Exception('failed to determine image size')
    return x, y


def find_src_region(width, height, aspect_ratio):
    video_aspect_ratio = video_width / float(video_height)
    ret = {}
    if video_aspect_ratio < aspect_ratio:
        h = width / aspect_ratio
        return {'x': 0, 'y': (height - h) / 2.0, 'w': width, 'h': h}
    else:
        w = height * aspect_ratio
        return {'x': (width - w) / 2.0, 'y': 0, 'w': w, 'h': height}


def round_rect(rect):
    return dict([[k, int(v + 0.5)] for k, v in rect.items()])


parser = argparse.ArgumentParser(description='Cut up a video for a wall')
parser.add_argument('--no-borders', action='store_true')
parser.add_argument('--cols', default=7, type=int)
parser.add_argument('--rows', default=3, type=int)
parser.add_argument('source')
parser.add_argument('destination')
args = parser.parse_args()

is_video = True
if args.source.endswith('.png') or args.source.endswith('.jpg'):
    is_video = False
    (video_width, video_height) = get_size_of_image(args.source)
else:
    (video_width, video_height) = get_size_of_video(args.source)

print 'size: %dx%d' % (video_width, video_height)

num_cols = args.cols
num_rows = args.rows

dst_region = {'x': 0, 'y': 0,
              'w': num_cols * 768,
              'h': num_rows * 1024}

borders = not args.no_borders
if borders:
    dst_region['w'] += (num_cols - 1) * 198
    dst_region['h'] += (num_rows - 1) * 231

screen_aspect_ratio = dst_region['w'] / float(dst_region['h'])
print 'aspect: %f' % screen_aspect_ratio

src_region = find_src_region(video_width, video_height, screen_aspect_ratio)

print 'src: %fx%f+%f+%f' % (src_region['w'], src_region['h'],
                            src_region['x'], src_region['y'])

border_width_factor = (768 / 966.0) if borders else 1
border_height_factor = (1024 / 1189.0) if borders else 1

print 'border: %f, %f' % (border_width_factor, border_height_factor)

reg = {'x': src_region['x'], 'y': src_region['y'], 
       'w': (src_region['w'] * border_width_factor) / float(num_cols),
       'h': (src_region['h'] * border_height_factor) / float(num_rows)}
for row in range(num_rows):
    # reset x
    reg['x'] = src_region['x'] + ((src_region['w'] / num_cols) - reg['w']) / 2
    for col in range(num_cols):
        print 'source: %f,%f' % (reg['x'], reg['y'])
        rreg = round_rect(reg)
        if is_video:
            dst = '{0}-{1}{2}.mov'.format(args.destination, row, col)
            cmd = 'avconv -i "{src}" -strict experimental -q 1 -vf ' \
                    '"crop={w}:{h}:{x}:{y}, scale={ow}:{oh}" -an ' \
                    '-y -loglevel quiet "{dst}"'.format(src=args.source,
                                                        dst=dst, ow=768,
                                                        oh=1024, **rreg)
        else:
            dst = '{0}-{1}{2}.png'.format(args.destination, row, col)
            cmd = 'convert "{src}" -crop {h}x{w}+{x}+{y} ' \
                    '-scale {ow}x{oh} "{dst}"'.format(src=args.source, dst=dst,
                                                      ow=768, oh=1024, **rreg)
        print 'processing {0}: {1}'.format(dst, cmd)
        check_call(cmd, shell=True)
        reg['x'] += reg['w'] / border_width_factor
    reg['y'] += reg['h'] / border_height_factor
