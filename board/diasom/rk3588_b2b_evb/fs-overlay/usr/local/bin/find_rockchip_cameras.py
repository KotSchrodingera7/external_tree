#!/usr/bin/env python3
"""Discover Rockchip CSI sensors and the matching RKCIF/RKISP /dev/video* nodes.

Requirements: media-ctl (v4l-utils), v4l2-ctl (v4l-utils).
Usage: python3 find_rockchip_cameras.py [--probe] [--timeout 8]

--probe starts a short capture on each ISP mainpath, which may interfere with
another application using the camera.
"""
import argparse
import glob
import os
import re
import shutil
import subprocess
import sys


def command(argv, timeout=6):
    try:
        p = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           text=True, errors="replace", timeout=timeout)
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired:
        return 124, "", "command timed out"
    except OSError as exc:
        return 127, "", str(exc)


def parse_entities(graph):
    entities = {}
    parts = re.split(r'(?=^- entity \d+: )', graph, flags=re.M)
    for part in parts:
        m = re.match(r'^- entity \d+: (.+?) \(', part)
        if m:
            entities[m.group(1)] = part
    return entities


def sensor_names(entities):
    sensors = []
    for name, body in entities.items():
        if re.search(r'type V4L2 subdev subtype Sensor', body, re.I):
            # Only follow connected sensors, not unused sensor entries.
            if re.search(r'-> .+\[ENABLED', body):
                sensors.append(name)
    return sensors


def entity_dev(media, entity):
    ret, out, err = command(['media-ctl', '-d', media, '-e', entity])
    if ret == 0:
        m = re.search(r'/dev/(?:video\d+|v4l-subdev\d+)', out)
        if m:
            return m.group(0)
    return '-'


def probe(dev, timeout):
    if not dev.startswith('/dev/video'):
        return 'нет video node'
    argv = ['v4l2-ctl', '-d', dev, '--stream-mmap=3',
            '--stream-count=15', '--stream-to=/dev/null']
    try:
        p = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           text=True, errors='replace', timeout=timeout)
    except subprocess.TimeoutExpired:
        return 'TIMEOUT: кадры не получены или поток не завершился'
    except OSError as exc:
        return 'ошибка: ' + str(exc)
    output = p.stdout + p.stderr
    num = output.count('<')
    fps = re.findall(r'(\d+(?:\.\d+)?)\s*fps', output, re.I)
    if num:
        return f'OK: ~{num} кадров' + (f', {fps[-1]} fps' if fps else '')
    if p.returncode == 0:
        return 'захват завершился, но счётчик кадров не найден'
    tail = next((line.strip() for line in reversed(output.splitlines()) if line.strip()), '')
    return 'ошибка: ' + (tail or f'exit {p.returncode}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--probe', action='store_true', help='попробовать захватить 15 кадров с mainpath')
    parser.add_argument('--timeout', type=float, default=8.0, help='таймаут проверки потока, сек')
    args = parser.parse_args()

    if not shutil.which('media-ctl'):
        sys.exit('Не найден media-ctl (установите v4l-utils / media-ctl).')
    if args.probe and not shutil.which('v4l2-ctl'):
        sys.exit('Не найден v4l2-ctl.')

    medias = []
    for media in sorted(glob.glob('/dev/media*'), key=lambda d: int(re.search(r'\d+$', d).group())):
        code, graph, err = command(['media-ctl', '-d', media, '-p'])
        if code != 0:
            print(f'{media}: не удалось прочитать media graph: {err.strip()}', file=sys.stderr)
            continue
        m = re.search(r'^model\s+(.+)$', graph, re.M)
        model = m.group(1).strip() if m else '?'
        entities = parse_entities(graph)
        medias.append({'dev': media, 'model': model, 'entities': entities,
                       'sensors': sensor_names(entities)})

    cif_map = {}
    for info in medias:
        if info['model'].startswith('rkcif'):
            cif_map[info['model']] = info

    found = False
    for info in medias:
        entities = info['entities']
        isp = entities.get('rkisp-isp-subdev', '')
        if not isp:
            continue
        # An enabled RKCIF-to-ISP link identifies a live sensor pipeline.
        matches = re.findall(r'<- "(rkcif[^\"]+)":\d+ \[ENABLED', isp)
        if not matches:
            continue
        found = True
        print(f'\nISP: {info["dev"]} ({info["model"]})')
        for cif_name in matches:
            cif = cif_map.get(cif_name)
            if cif:
                sensors = ', '.join(cif['sensors']) or 'сенсор не указан в графе'
                print(f'  Сенсор: {sensors} (через {cif["dev"]}, {cif_name})')
                for entity in ('stream_cif_mipi_id0',):
                    if entity in cif['entities']:
                        print(f'  RKCIF {entity}: {entity_dev(cif["dev"], entity)}')
            else:
                print(f'  Источник: {cif_name} (соответствующий /dev/mediaX не найден)')
        for entity in ('rkisp_mainpath', 'rkisp_selfpath'):
            if entity in entities:
                dev = entity_dev(info['dev'], entity)
                print(f'  {entity}: {dev}')
                if args.probe and entity == 'rkisp_mainpath':
                    print(f'    Захват: {probe(dev, args.timeout)}')

    if not found:
        print('Не найдено активных связей RKCIF -> RKISP.')
        print('Проверьте: media-ctl -p -d /dev/media0 и dmesg | grep -Ei "imx|ov|rkisp|rkcif"')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
