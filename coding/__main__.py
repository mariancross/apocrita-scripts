#
# Copyright (C) 2018 Maria Santamaria
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


from parser import summarise_coding_results, aggregate_intra_modes
from post_processing import save_intra_modes, compute_bd_rate

from sys import exit
import argparse


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--task', type=str, required=True)
    parser.add_argument('--dir', type=str)
    parser.add_argument('--enc_file_rgx', type=str)
    parser.add_argument('--dec_file_rgx', type=str)
    parser.add_argument('--anchor_file', type=str)
    parser.add_argument('--test_file', type=str)
    parser.add_argument('--output_file', type=str)
    parser.add_argument('--config', type=str)
    parser.add_argument('--codec', type=str)

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()

    if args.task == 'coding_summary':
        summarise_coding_results(args.config, args.dir, args.enc_file_rgx, args.dec_file_rgx, args.codec)
    elif args.task == 'bd_rate':
        compute_bd_rate(args.anchor_file, args.test_file, args.output_file)
    elif args.task == 'intra_modes':
        intra_modes = aggregate_intra_modes(args.dir, args.dec_file_rgx)
        save_intra_modes(intra_modes, args.output_file)

    exit()
