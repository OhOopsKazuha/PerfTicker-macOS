// SPDX-License-Identifier: GPL-3.0-only
// Copyright (c) 2026 OhOopsKazuha and contributors
// Unofficial macOS reimplementation of QiuSui1145/PerfTicker; see NOTICE.
#include <stdint.h>
typedef struct { int pid; uint64_t cpu_ns, resident, started; int threads; char name[256]; } PTProcess;
int pt_processes(PTProcess *out, int capacity);
int pt_cpu(double *out, int capacity);
void pt_memory(double *used, double *total, double *swap);
void pt_network(uint64_t *rx, uint64_t *tx);
