#!/usr/bin/env python3
import subprocess
import os
import math
import csv
from itertools import product

def parse_mpki_data(output):
    """从缓存模拟器输出中解析访问次数和缺失次数"""
    for line in output.split('\n'):
        if line.startswith('MPKI_DATA:'):
            parts = line.split()
            if len(parts) >= 3:
                accesses = int(parts[1])
                misses = int(parts[2])
                return accesses, misses
    return None, None

def calculate_mpki(accesses, misses):
    """计算MPKI（每千条指令缺失数）"""
    if accesses == 0:
        return 0
    return (misses / accesses) * 1000  # 每千条指令的缺失数

def calculate_trimmed_geo_mean(mpki_values):
    """计算去掉最高和最低值后的几何平均值"""
    if len(mpki_values) < 3:
        # 如果少于3个值，无法去掉最高最低，直接计算几何平均
        return math.exp(sum(math.log(mpki) for mpki in mpki_values) / len(mpki_values))
    
    # 去掉一个最高值和一个最低值
    sorted_values = sorted(mpki_values)
    trimmed_values = sorted_values[1:-1]  # 去掉第一个（最小）和最后一个（最大）
    
    return math.exp(sum(math.log(mpki) for mpki in trimmed_values) / len(trimmed_values))

def main():
    # 固定参数
    TOTAL_CACHE_SIZE_KB = 32
    TOTAL_CACHE_SIZE_BYTES = TOTAL_CACHE_SIZE_KB * 1024
    
    # 可变参数
    ways_list = [2, 4, 8]
    cacheline_sizes_list = [8, 16, 32, 64]
    policies_list = ['lru', 'plru', 'rrip', 'mru']
    
    # Trace文件列表
    trace_files = [
        '../smoke_test/dhrystone.trace',
        '../smoke_test/coremark.trace',
        '../smoke_test/microbench.trace',
        '../smoke_test/rthread.trace',
        '../smoke_test/MC.trace',
        '../smoke_test/MC_1024.trace',
        '../smoke_test/MC_2048.trace',
        '../smoke_test/MC_8192.trace',
        '../smoke_test/gemm.trace',
        '../smoke_test/conv_stride.trace',
        '../smoke_test/conv_block.trace'
    ]
    
    # 检查缓存模拟器是否存在
    if not os.path.exists('./cachesim'):
        print("错误: 找不到 cachesim 可执行文件")
        print("请先编译: gcc -o cachesim cachesim.c")
        return
    
    # 检查trace文件是否存在
    missing_traces = [trace for trace in trace_files if not os.path.exists(trace)]
    if missing_traces:
        print("警告: 以下trace文件不存在:")
        for trace in missing_traces:
            print(f"  {trace}")
        print("将继续处理存在的trace文件")
        trace_files = [trace for trace in trace_files if os.path.exists(trace)]
    
    # 结果存储
    results = {}
    
    # 遍历所有参数组合
    param_combinations = list(product(ways_list, cacheline_sizes_list, policies_list))
    total_combinations = len(param_combinations)
    
    print(f"开始批量测试，共有 {total_combinations} 种参数组合")
    print("=" * 80)
    
    for i, (ways, cacheline_size, policy) in enumerate(param_combinations, 1):
        # 计算set数量
        sets = TOTAL_CACHE_SIZE_BYTES // (ways * cacheline_size)
        
        # 检查set数量是否为2的幂
        if (sets & (sets - 1)) != 0:
            print(f"跳过: ways={ways}, cacheline={cacheline_size}B -> sets={sets} (不是2的幂)")
            continue
        
        # 检查way数量对于PLRU是否为2的幂
        if policy == 'plru' and (ways & (ways - 1)) != 0:
            print(f"跳过: PLRU需要way数为2的幂, ways={ways}")
            continue
        
        param_key = f"ways{ways}_line{cacheline_size}_{policy}"
        results[param_key] = {}
        
        print(f"[{i}/{total_combinations}] 测试: ways={ways}, sets={sets}, line_size={cacheline_size}B, policy={policy}")
        
        mpki_values = []
        all_trace_results = {}
        
        for trace_file in trace_files:
            if not os.path.exists(trace_file):
                continue
                
            trace_name = os.path.basename(trace_file)
            
            try:
                # 执行缓存模拟器
                cmd = ['./cachesim', str(ways), str(sets), str(cacheline_size), policy, trace_file]
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                
                if result.returncode == 0:
                    # 解析访问次数和缺失次数
                    accesses, misses = parse_mpki_data(result.stdout)
                    
                    if accesses is not None and misses is not None:
                        mpki = calculate_mpki(accesses, misses)
                        mpki_values.append(mpki)
                        all_trace_results[trace_name] = mpki
                        results[param_key][trace_name] = mpki
                        print(f"  {trace_name}: {mpki:.4f} MPKI")
                    else:
                        print(f"  错误: 无法解析 {trace_name} 的MPKI数据")
                        results[param_key][trace_name] = None
                else:
                    print(f"  错误: 执行 {trace_name} 失败")
                    results[param_key][trace_name] = None
                    
            except subprocess.TimeoutExpired:
                print(f"  超时: {trace_name}")
                results[param_key][trace_name] = None
            except Exception as e:
                print(f"  异常: {trace_name} - {e}")
                results[param_key][trace_name] = None
        
        # 计算两种几何平均值
        valid_mpki = [mpki for mpki in mpki_values if mpki is not None]
        
        if valid_mpki:
            # 原始几何平均值
            geo_mean_mpki = math.exp(sum(math.log(mpki) for mpki in valid_mpki) / len(valid_mpki))
            results[param_key]['geo_mean'] = geo_mean_mpki
            
            # 去掉最高最低后的几何平均值
            trimmed_geo_mean_mpki = calculate_trimmed_geo_mean(valid_mpki)
            results[param_key]['trimmed_geo_mean'] = trimmed_geo_mean_mpki
            
            # 找出被去掉的最高和最低值
            if len(valid_mpki) >= 3:
                sorted_mpki = sorted(valid_mpki)
                min_mpki = sorted_mpki[0]
                max_mpki = sorted_mpki[-1]
                
                # 找出对应的trace名称
                min_trace = [name for name, mpki in all_trace_results.items() if mpki == min_mpki][0]
                max_trace = [name for name, mpki in all_trace_results.items() if mpki == max_mpki][0]
                
                print(f"  原始几何平均MPKI: {geo_mean_mpki:.4f}")
                print(f"  去掉最高最低后几何平均MPKI: {trimmed_geo_mean_mpki:.4f}")
                print(f"  去掉的最低值: {min_trace} = {min_mpki:.4f} MPKI")
                print(f"  去掉的最高值: {max_trace} = {max_mpki:.4f} MPKI")
            else:
                print(f"  几何平均MPKI: {geo_mean_mpki:.4f} (数据太少，无法去掉最高最低)")
                results[param_key]['trimmed_geo_mean'] = geo_mean_mpki
        else:
            results[param_key]['geo_mean'] = None
            results[param_key]['trimmed_geo_mean'] = None
            print(f"  无法计算几何平均MPKI")
        
        print("-" * 60)
    
    # 输出最终结果表格
    print("\n" + "=" * 80)
    print("最终结果汇总 (MPKI - 每千条指令缺失数)")
    print("=" * 80)
    
    # 准备CSV输出
    output_csv = "cachesimulation_results_mpki.csv"
    with open(output_csv, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        
        # 写入表头
        header = ['Configuration', 'Geo_Mean_MPKI', 'Trimmed_Geo_Mean_MPKI'] + [os.path.basename(trace) for trace in trace_files]
        writer.writerow(header)
        
        # 按去掉最高最低后的几何平均值排序（MPKI越小越好）
        sorted_results = sorted(results.items(), 
                               key=lambda x: x[1].get('trimmed_geo_mean', float('inf')) 
                               if x[1].get('trimmed_geo_mean') is not None else float('inf'))
        
        # 控制台输出和CSV写入
        print(f"{'Configuration':<25} {'Trim_Mean':<10} {'Orig_Mean':<10} ", end='')
        for trace in trace_files:
            trace_name = os.path.basename(trace)
            print(f"{trace_name[:10]:<10} ", end='')
        print()
        
        print("-" * (25 + 10 + 10 + 10 * len(trace_files)))
        
        for config, data in sorted_results:
            geo_mean = data.get('geo_mean', 'N/A')
            trimmed_geo_mean = data.get('trimmed_geo_mean', 'N/A')
            
            if geo_mean is not None:
                geo_mean_str = f"{geo_mean:.4f}"
            else:
                geo_mean_str = "N/A"
                
            if trimmed_geo_mean is not None:
                trimmed_geo_mean_str = f"{trimmed_geo_mean:.4f}"
            else:
                trimmed_geo_mean_str = "N/A"
            
            # CSV行
            row = [config, geo_mean_str if geo_mean_str != "N/A" else "", 
                   trimmed_geo_mean_str if trimmed_geo_mean_str != "N/A" else ""]
            for trace in trace_files:
                trace_name = os.path.basename(trace)
                mpki = data.get(trace_name, 'N/A')
                if mpki is not None:
                    row.append(f"{mpki:.4f}")
                else:
                    row.append("")
            writer.writerow(row)
            
            # 控制台输出
            print(f"{config:<25} {trimmed_geo_mean_str:<10} {geo_mean_str:<10} ", end='')
            for trace in trace_files:
                trace_name = os.path.basename(trace)
                mpki = data.get(trace_name, 'N/A')
                if mpki is not None:
                    print(f"{mpki:>8.4f}  ", end='')
                else:
                    print(f"{'N/A':>8}  ", end='')
            print()
    
    print(f"\n详细结果已保存到: {output_csv}")
    
    # 找出最佳配置（按去掉最高最低后的MPKI，越小越好）
    valid_results = [(config, data['trimmed_geo_mean']) for config, data in sorted_results 
                    if data.get('trimmed_geo_mean') is not None]
    
    if valid_results:
        best_config, best_trimmed_geo_mean = valid_results[0]
        # 也找出原始几何平均值用于比较
        best_orig_geo_mean = results[best_config].get('geo_mean', 'N/A')
        
        print(f"\n最佳配置: {best_config}")
        print(f"最佳去掉最高最低后几何平均MPKI: {best_trimmed_geo_mean:.4f}")
        if best_orig_geo_mean != 'N/A':
            print(f"对应的原始几何平均MPKI: {best_orig_geo_mean:.4f}")
    else:
        print("\n没有有效的测试结果")

if __name__ == "__main__":
    main()