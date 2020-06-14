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


from bjontegaard_metric import BD_RATE

import numpy as np
import pandas as pd


def compute_percentages(data_: pd.DataFrame):
    percentages = data_.div(data_.iloc[:, -1], axis=0)
    percentages.replace([np.inf, -np.inf, np.nan], 0, inplace=True)
    return percentages


def summarise_mode_usage_per_block_size(df):
    total_count = df.pivot_table(values='count', index='block_size', aggfunc='sum', fill_value=0)
    type_count = df.pivot_table(values='count', index='block_size', columns='mode_type', aggfunc='sum', fill_value=0)

    summary = pd.merge(type_count, total_count, 'left', on=['block_size'])
    return summary


def summarise_mode_usage_per_mode(df: pd.DataFrame, column_filter: int):
    summary = df[df.mode_type == column_filter]
    total = summary.pivot_table(values='count', index='block_size', aggfunc='sum', fill_value=0)
    modes = summary.pivot_table(
        values='count', index='block_size', columns='mode_idx', aggfunc='sum', fill_value=0)

    summary = pd.merge(modes, total, 'left', on=['block_size'])
    return summary


def compute_intra_mode_statistics(intra_modes):
    df = pd.DataFrame(intra_modes, columns=['block_size', 'mode_idx', 'mode_type', 'count'])
    df.sort_values(['block_size', 'mode_type', 'mode_idx', 'count'], ascending=[1, 1, 0, 1], inplace=True)

    summary = summarise_mode_usage_per_block_size(df)
    summary_p = compute_percentages(summary)

    summary_ang = summarise_mode_usage_per_mode(df, 0)
    summary_ang_p = compute_percentages(summary_ang)

    summary_mip = summarise_mode_usage_per_mode(df, 1)
    summary_mip_p = compute_percentages(summary_mip)

    return summary, summary_p, summary_ang, summary_ang_p, summary_mip, summary_mip_p


def save_intra_modes(intra_modes: list, file_name: str):
    with pd.ExcelWriter(file_name, engine='xlsxwriter') as writer:
        summ, summ_p, summ_ang, summ_ang_p, summ_mip, summ_mip_p = compute_intra_mode_statistics(intra_modes)

        summ.to_excel(writer, sheet_name='general')
        summ_p.to_excel(writer, sheet_name='general_%')
        summ_ang.to_excel(writer, sheet_name='anchor')
        summ_ang_p.to_excel(writer, sheet_name='anchor_%')
        summ_mip.to_excel(writer, sheet_name='test')
        summ_mip_p.to_excel(writer, sheet_name='test_%')


def read_summary(file_name: str):
    columns = ['sequence', 'Bitrate', 'PSNR(Y\')', 'PSNR(Cb)', 'PSNR(Cr)']
    df = pd.read_csv(file_name, header=0, index_col=None)
    df = df[columns]

    return df.to_numpy()


def compute_bd_rate(anchor_filename: str, test_filename: str, output_file: str, piecewise: int = 1):
    anchor_summary = read_summary(anchor_filename)
    test_summary = read_summary(test_filename)

    results = []

    for i in range(0, len(anchor_summary), 4):
        row = []
        seq_name = anchor_summary[i, 0]
        row.append(seq_name)

        anchor_rate = np.array(anchor_summary[i:i + 4, 1], dtype=float)
        test_rate = np.array(test_summary[i:i + 4, 1], dtype=float)

        for j in range(3):
            anchor_psnr = np.array(anchor_summary[i:i + 4, j + 2], dtype=float)
            test_psnr = np.array(test_summary[i:i + 4, j + 2], dtype=float)
            bd_rate = BD_RATE(anchor_rate, anchor_psnr, test_rate, test_psnr, piecewise)
            row.append(bd_rate)

        results.append(row)

    df = pd.DataFrame(results, columns=['sequence', 'BD-rate Y', 'BD-rate U', 'BD-rate V'])
    with pd.ExcelWriter(output_file, engine='xlsxwriter') as writer:
        df.to_excel(writer, sheet_name='BD-rate')
