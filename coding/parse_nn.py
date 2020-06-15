#
# Copyright (C) 2020 Maria Santamaria
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
import os

import pandas as pd


def natural_sort_key(s, _nsre=re.compile('([0-9]+)')):
    """
    https://stackoverflow.com/a/16090640
    """
    return [int(text) if text.isdigit() else text.lower() for text in _nsre.split(s)]


def nn_test_results(pattern: str = './**/*.sh.*'):
    files = sorted(glob(pattern, recursive=True), key=natural_sort_key)
    num_files = len(files)

    metrics = []

    for i in range(num_files):
        with open(files[i], 'r') as stream:
            for line in stream:
                if line.startswith('archive') or line.startswith('[!]'):
                    continue

                line = line.replace('; ', ' ')
                data_ = line.split()

                metrics.append([data_[1], data_[3], data_[5], data_[7], data_[9]])

    df = pd.DataFrame(metrics, columns=['loss', 'PSNR Y', 'MSE Y', 'SSIM Y', 'RMSE Y'])
    return df
