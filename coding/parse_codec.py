#
# Copyright (C) 2019 Maria Santamaria
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#


from glob import glob
import re

import numpy as np


def read_encoding_summary(pattern: str = './../encLog*.out'):
    """
    Reads a set of files containing the encoder standard output
    :param pattern: file pattern
    :return: encoder process check, file name, quantisation parameter, rate, Y PSNR, U PSNR, V PSNR, YUV PSNR and encoding time
    """
    files = sorted(glob(pattern, recursive=True))
    num_files = len(files)

    encoder_check = np.ones(num_files, dtype=bool)
    file_names = []
    qp = np.zeros(num_files, dtype=int)
    rate = np.zeros(num_files, dtype=float)
    y_psnr = np.zeros(num_files, dtype=float)
    u_psnr = np.zeros(num_files, dtype=float)
    v_psnr = np.zeros(num_files, dtype=float)
    yuv_psnr = np.zeros(num_files, dtype=float)
    encoding_time = np.zeros(num_files, dtype=float)

    for i in range(len(files)):
        qp_read = False
        with open(files[i], 'r') as _file:
            for line in _file:
                if line.startswith('\n'):
                    continue

                elif line.startswith('Bitstream'):
                    file_names.append(line.strip().split('_')[1])

                elif line.startswith('QP') and not qp_read:
                    qp[i] = int(line.strip().split()[2])
                    qp_read = True

                elif line.startswith('SUMMARY'):
                    next(_file)
                    _data = next(_file).strip().split()
                    rate[i] = float(_data[2])
                    y_psnr[i] = float(_data[3])
                    u_psnr[i] = float(_data[4])
                    v_psnr[i] = float(_data[5])
                    yuv_psnr[i] = float(_data[6])

                elif line.startswith(' Total Time'):
                    encoding_time[i] = float(line.strip().split()[2])

                elif line.startswith('Process finished'):
                    encoder_check[i] = line.strip().split()[5] == '0'

    return encoder_check, file_names, qp, rate, y_psnr, u_psnr, v_psnr, yuv_psnr, encoding_time


def read_decoding_summary(pattern: str = './**/decLog*.out'):
    """
    Reads a set of files containing the decoder standard output
    :param pattern: file pattern
    :return: decoder process check, md5 check of reconstructed video and decoding time
    """
    rgx = re.compile(r'(OK|ERROR)')

    files = sorted(glob(pattern, recursive=True))
    num_files = len(files)

    decoder_check = np.ones(num_files, dtype=bool)
    md5_check = np.ones(num_files, dtype=bool)
    decoding_time = np.zeros(num_files, dtype=float)

    for i in range(num_files):
        with open(files[i], 'r') as _file:
            for line in _file:
                if line.startswith('\n') or (line.startswith('POC') and not decoder_check[i]):
                    continue

                elif line.startswith('POC'):
                    result = re.search(rgx, line)
                    if result.group(1) == 'ERROR':
                        md5_check[i] = False

                elif line.startswith(' Total Time'):
                    decoding_time[i] = float(line.strip().split()[2])

                elif line.startswith('Process finished'):
                    decoder_check[i] = line.strip().split()[5] == '0'

    return decoder_check, md5_check, decoding_time


def summarise_coding_results(
        config: str, enc_pattern: str = './**/encLog*.out', dec_pattern: str = './**/decLog*.out', codec: str = 'vvc'):
    """
    Reads both encoding and decoding standard output
    :param config: coding configuration (all intra, random access or low delay)
    :param enc_pattern: file pattern for encoding output
    :param dec_pattern: file pattern for decoding output
    :param codec: video codec name
    """
    enc_chk, file_names, qp, rate, y_psnr, u_psnr, v_psnr, _, enc_t = read_encoding_summary(enc_pattern)
    dec_chk, md5_chk, dec_t = read_decoding_summary(dec_pattern)

    if codec == 'hevc':
        order = np.array([68, 69, 70, 71, 56, 57, 58, 59, 40, 41, 42, 43, 48, 49, 50, 51, 28, 29, 30, 31, 8, 9, 10, 11,
                          16, 17, 18, 19, 64, 65, 66, 67, 0, 1, 2, 3, 52, 53, 54, 55, 12, 13, 14, 15, 60, 61, 62, 63,
                          4, 5, 6, 7, 24, 25, 26, 27, 20, 21, 22, 23, 32, 33, 34, 35,  36, 37, 38, 39, 44, 45, 46, 47])
    elif codec == 'vvc':
        order = np.array([84, 85, 86, 87, 44, 45, 46, 47, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43,
                          64, 65, 66, 67, 60, 61, 62, 63, 80, 81, 82, 83, 28, 29, 30, 31,  4,  5,  6,  7,
                          24, 25, 26, 27, 76, 77, 78, 79, 16, 17, 18, 19, 68, 69, 70, 71,  0,  1,  2,  3,
                          72, 73, 74, 75, 20, 21, 22, 23, 12, 13, 14, 15,  8,  9, 10, 11, 48, 49, 50, 51,
                          52, 53, 54, 55, 56, 57, 58, 59])
        # order = np.array([40, 41, 42, 43, 24, 25, 26, 27, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
        #                   32, 33, 34, 35, 28, 29, 30, 31, 36, 37, 38, 39, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])

    if len(enc_chk):
        print('config,sequence,QP,Bitrate,PSNR(Y\'),PSNR(Cb),PSNR(Cr),EncT,DecT,EncS,DecS,MD5')
    for i in range(len(enc_chk)):
        idx = order[i]
        print('%s,%s,%d,%f,%f,%f,%f,%f,%f,ENC:%s,DEC:%s,MD5:%s' % (
            config, file_names[idx], qp[idx], rate[idx], y_psnr[idx], u_psnr[idx], v_psnr[idx],
            enc_t[idx], dec_t[idx], 'OK' if enc_chk[idx] else 'ERROR', 'OK' if dec_chk[idx] else 'ERROR',
            'OK' if md5_chk[idx] else 'ERROR'))


def aggregate_intra_modes(pattern: str = './**/decLog*.out'):
    """
    Returns the usage of intra-prediction modes
    :param pattern: file pattern for coding output
    :return: list of list in the format [block size, mode id, mode type, count]
    """
    files = sorted(glob(pattern, recursive=True))

    anchor_modes = {}
    test_modes = {}

    lines_to_ignore = tuple(['VVC', 'POC', ' Total', 'real', 'user', 'sys', 'Note'])

    for f in files:
        with open(f, 'r') as file:
            for line in file:
                if line == '' or line == '\n' or line.startswith(lines_to_ignore):
                    continue

                _data = np.fromstring(line, dtype=int, sep=' ')

                if _data[4] == 0:
                    key = '%dx%d_%d' % (_data[2], _data[3], _data[5])
                    if key in anchor_modes:
                        anchor_modes[key] += 1
                    else:
                        anchor_modes[key] = 1
                else:
                    key = '%dx%d_%d' % (_data[2], _data[3], _data[5])
                    if key in test_modes:
                        test_modes[key] += 1
                    else:
                        test_modes[key] = 1

    mode_usage = []

    for k, v in anchor_modes.items():
        bs, mode = k.split('_')
        mode_usage.append([bs, mode, 0, v])

    for k, v in test_modes.items():
        bs, mode = k.split('_')
        mode_usage.append([bs, mode, 1, v])

    return mode_usage


def read_intra_type(pattern: str = './**/decLog*.out'):
    """
    Returns the usage of intra-prediction modes
    :param pattern: file pattern for coding output
    :return: list of list in the format [block size, mode id, mode type, count]
    """
    files = sorted(glob(pattern, recursive=True))

    intra_modes = []

    lines_to_ignore = tuple(['VVC', 'POC', ' Total', 'real', 'user', 'sys', 'Note'])

    for f in files:
        with open(f, 'r') as file:
            blocks_frame = []
            for line in file:
                if line.startswith('POC'):
                    intra_modes.append(blocks_frame)
                    blocks_frame = []
                if line == '' or line == '\n' or line.startswith(lines_to_ignore):
                    continue

                blocks_frame.append(np.fromstring(line, dtype=int, sep=' '))

    return intra_modes
