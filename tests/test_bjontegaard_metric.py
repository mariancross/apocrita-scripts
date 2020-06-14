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


from coding.bjontegaard_metric import BD_RATE
from unittest import TestCase

import numpy as np


class TestBjontegaardMetric(TestCase):
    def test_bd_rate(self):
        rateA = np.array([6873.4368, 3732.84, 1937.664, 955.8992])
        psnrA = np.array([41.6995, 38.578, 35.5628, 32.7459])

        rateB = np.array([6838.0456, 3708.1552, 1936.8936, 966.9368])
        psnrB = np.array([41.7739, 38.6574, 35.6526, 32.8186])

        bd_rate = BD_RATE(rateA, psnrA, rateB, psnrB)
        bd_rate = np.around(bd_rate, 2)
        self.assertEqual(-1.98, bd_rate)

    def test_bd_rate_piecewise(self):
        rateA = np.array([13378.5237, 7583.6716, 4329.8053, 2446.4242])
        psnrA = np.array([43.4297, 40.1851, 37.0864, 34.052])

        rateB = np.array([13308.6284, 7532.7126, 4299.4311, 2450.5168])
        psnrB = np.array([43.4954, 40.2354, 37.1369, 34.1159])

        bd_rate = BD_RATE(rateA, psnrA, rateB, psnrB, 1)
        bd_rate = np.around(bd_rate, 2)
        self.assertEqual(-1.53, bd_rate)
