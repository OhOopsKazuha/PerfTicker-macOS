// SPDX-License-Identifier: GPL-3.0-only
// Copyright (c) 2026 OhOopsKazuha and contributors
// Unofficial macOS reimplementation of QiuSui1145/PerfTicker; see NOTICE.
#include "Probe.h"
#include <libproc.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <sys/sysctl.h>
#include <sys/proc_info.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <stdlib.h>
#include <string.h>
int pt_processes(PTProcess *out,int cap) {
 mach_timebase_info_data_t tb;mach_timebase_info(&tb);
 int bytes=proc_listallpids(NULL,0); if(bytes<=0)return 0;
 int ncap=bytes+512; pid_t *pids=calloc(ncap,sizeof(pid_t)); int n=proc_listallpids(pids,ncap*sizeof(pid_t)), count=0;
 for(int i=0;i<n && count<cap;i++) { struct proc_taskallinfo p={0};
 if(pids[i]<=0 || proc_pidinfo(pids[i],PROC_PIDTASKALLINFO,0,&p,sizeof(p))!=(int)sizeof(p))continue;
 PTProcess *o=&out[count++]; memset(o,0,sizeof(*o));o->pid=pids[i];o->cpu_ns=(uint64_t)((long double)(p.ptinfo.pti_total_user+p.ptinfo.pti_total_system)*tb.numer/tb.denom);
 o->resident=p.ptinfo.pti_resident_size;o->threads=p.ptinfo.pti_threadnum;
 o->started=p.pbsd.pbi_start_tvsec*1000000ULL+p.pbsd.pbi_start_tvusec;
 proc_name(pids[i],o->name,sizeof(o->name)); if(!o->name[0])strncpy(o->name,p.pbsd.pbi_comm,255);
 }free(pids);return count;
}
int pt_cpu(double *out,int cap) {
 static uint64_t previous[256][2];natural_t n=0;processor_info_array_t info;mach_msg_type_number_t cnt=0;
 if(host_processor_info(mach_host_self(),PROCESSOR_CPU_LOAD_INFO,&n,&info,&cnt)!=KERN_SUCCESS)return 0;
 int k=n<cap?n:cap;if(k>256)k=256;
 for(int i=0;i<k;i++){uint64_t total=0;for(int j=0;j<CPU_STATE_MAX;j++)total+=(uint32_t)info[i*CPU_STATE_MAX+j];
 uint64_t idle=(uint32_t)info[i*CPU_STATE_MAX+CPU_STATE_IDLE],dt=total-previous[i][0],di=idle-previous[i][1];
 out[i]=previous[i][0] && dt?100.0*(1.0-(double)di/dt):0;previous[i][0]=total;previous[i][1]=idle;}
 vm_deallocate(mach_task_self(),(vm_address_t)info,cnt*sizeof(integer_t));return k;
}
void pt_memory(double *used,double *total,double *swap) {
 uint64_t mem=0;size_t size=sizeof(mem);sysctlbyname("hw.memsize",&mem,&size,NULL,0);*total=mem/1073741824.0;
 vm_statistics64_data_t v={0};mach_msg_type_number_t count=HOST_VM_INFO64_COUNT;vm_size_t page=0;host_page_size(mach_host_self(),&page);
 if(host_statistics64(mach_host_self(),HOST_VM_INFO64,(host_info64_t)&v,&count)==KERN_SUCCESS)
 *used=((double)v.active_count+v.wire_count+v.compressor_page_count-v.purgeable_count)*page/1073741824.0;
 if(*used<0)*used=0;if(*used>*total)*used=*total;
 struct xsw_usage x={0};size=sizeof(x);if(sysctlbyname("vm.swapusage",&x,&size,NULL,0)==0)*swap=x.xsu_used/1073741824.0;
}
void pt_network(uint64_t *rx,uint64_t *tx) {
 *rx=0;*tx=0;struct ifaddrs *list=NULL;if(getifaddrs(&list)!=0)return;
 for(struct ifaddrs *p=list;p;p=p->ifa_next){if(!p->ifa_addr || p->ifa_addr->sa_family!=AF_LINK || !p->ifa_data)continue;
 if(!(p->ifa_flags&IFF_UP) || (p->ifa_flags&IFF_LOOPBACK) || strncmp(p->ifa_name,"en",2)!=0)continue;
 struct if_data *d=p->ifa_data;*rx+=d->ifi_ibytes;*tx+=d->ifi_obytes;}freeifaddrs(list);
}
