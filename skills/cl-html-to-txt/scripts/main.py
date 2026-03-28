#!/usr/bin/env python3
"""
parse_cl_html_to_txt Skill - 解析本地 HTML 文件为 TXT 文件
"""

import sys
import os
import re
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from parser import parse_html_to_structured, sanitize_filename, get_final_title


def get_sort_key(filename: str) -> tuple:
    """
    获取文件名的排序键，支持两种格式：
    - 旧格式: 01.html, 02.html
    - 新格式: 7187084_000001.html (6位页码)
    
    Args:
        filename: 文件名
        
    Returns:
        排序键元组
    """
    match = re.search(r'_(\d{6})\.', filename)
    if match:
        return (2, int(match.group(1)))
    
    match = re.search(r'_(\d{4})\.', filename)
    if match:
        return (2, int(match.group(1)))
    
    match = re.search(r'^(\d+)\.', filename)
    if match:
        return (1, int(match.group(1)))
    
    return (0, filename)


def parse_and_save_to_cache(html_path: str, cache_dir: str = "caches") -> str:
    """
    解析单个 HTML 文件并保存为 JSON 到缓存目录
    
    Args:
        html_path: HTML 文件路径
        cache_dir: 缓存目录
        
    Returns:
        缓存的 JSON 文件路径，失败返回 None
    """
    print(f"正在解析: {html_path}")
    
    try:
        with open(html_path, 'r', encoding='utf-8') as f:
            html = f.read()
    except Exception as e:
        print(f"读取失败: {e}")
        return None
    
    data = parse_html_to_structured(html)
    
    html_filename = os.path.basename(html_path)
    json_filename = os.path.splitext(html_filename)[0] + ".json"
    
    os.makedirs(cache_dir, exist_ok=True)
    cache_path = os.path.join(cache_dir, json_filename)
    
    with open(cache_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"已缓存到: {cache_path}")
    return cache_path


def parse_all_to_cache(input_dir: str = "htmls", cache_dir: str = "caches") -> list:
    """
    批量解析目录中的所有 HTML 文件到缓存
    
    Args:
        input_dir: 输入目录（包含 HTML 文件）
        cache_dir: 缓存目录
        
    Returns:
        缓存文件路径列表
    """
    if not os.path.exists(input_dir):
        print(f"输入目录不存在: {input_dir}")
        return []
    
    html_files = []
    for filename in os.listdir(input_dir):
        if filename.lower().endswith('.html') or filename.lower().endswith('.htm'):
            html_files.append(filename)
    
    if not html_files:
        print(f"在 {input_dir} 目录中没有找到 HTML 文件")
        return []
    
    html_files.sort(key=get_sort_key)
    
    print(f"找到 {len(html_files)} 个 HTML 文件")
    print()
    
    cache_files = []
    for filename in html_files:
        html_path = os.path.join(input_dir, filename)
        cache_path = parse_and_save_to_cache(html_path, cache_dir)
        if cache_path:
            cache_files.append(cache_path)
        print()
    
    print(f"完成！成功缓存 {len(cache_files)}/{len(html_files)} 个文件")
    return cache_files


def merge_articles_by_title(cache_dir: str = "caches", output_dir: str = "output") -> int:
    """
    按顺序逐个解析、逐个合并缓存中的文章，并去重
    
    Args:
        cache_dir: 缓存目录
        output_dir: 输出目录
        
    Returns:
        合并后的文章数量
    """
    if not os.path.exists(cache_dir):
        print(f"缓存目录不存在: {cache_dir}")
        return 0
    
    json_files = []
    for filename in os.listdir(cache_dir):
        if filename.lower().endswith('.json'):
            json_files.append(filename)
    
    if not json_files:
        print(f"在 {cache_dir} 目录中没有找到 JSON 文件")
        return 0
    
    json_files.sort(key=get_sort_key)
    
    print(f"找到 {len(json_files)} 个缓存文件")
    print()
    
    os.makedirs(output_dir, exist_ok=True)
    
    processed_titles = {}
    
    for filename in json_files:
        json_path = os.path.join(cache_dir, filename)
        try:
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            title = data.get("title", "")
            if title:
                final_title = get_final_title(title)
                safe_filename = sanitize_filename(final_title) + ".txt"
                output_path = os.path.join(output_dir, safe_filename)
                
                if final_title not in processed_titles:
                    processed_titles[final_title] = {
                        "output_path": output_path,
                        "seen_lines": set(),
                        "part_count": 0
                    }
                    merged_content_parts = [f"{title}\n\n{'=' * len(title)}\n\n"]
                else:
                    with open(output_path, 'r', encoding='utf-8') as f:
                        existing_content = f.read()
                    merged_content_parts = [existing_content]
                    merged_content_parts.append('\n\n' + '='*80 + '\n\n')
                
                processed_titles[final_title]["part_count"] += 1
                
                tpc_contents = data.get("tpc_content", [])
                for tpc_content in tpc_contents:
                    for line in tpc_content:
                        if not line.strip():
                            merged_content_parts.append(line + '\n')
                        else:
                            line_stripped = line.rstrip()
                            if line_stripped not in processed_titles[final_title]["seen_lines"]:
                                processed_titles[final_title]["seen_lines"].add(line_stripped)
                                merged_content_parts.append(line + '\n')
                
                merged_content = ''.join(merged_content_parts)
                lines = merged_content.split('\n')
                merged_lines = []
                prev_empty = False
                for line in lines:
                    if not line.strip():
                        if not prev_empty:
                            merged_lines.append(line)
                            prev_empty = True
                    else:
                        merged_lines.append(line)
                        prev_empty = False
                merged_content = '\n'.join(merged_lines)
                
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(merged_content)
                
                print(f"已合并: {filename} -> {title}")
                print(f"  -> {output_path}")
                print(f"  当前包含 {processed_titles[final_title]['part_count']} 个部分")
                print()
                
        except Exception as e:
            print(f"处理缓存文件失败 {filename}: {e}")
    
    print(f"完成！成功合并 {len(processed_titles)} 篇文章到 {output_dir}")
    return len(processed_titles)


def main():
    """
    主函数
    """
    import argparse
    
    parser = argparse.ArgumentParser(description="解析 HTML 并合并为 TXT")
    parser.add_argument("command", choices=["parse", "merge", "all"], 
                        help="命令: parse(仅解析HTML到JSON), merge(仅合并JSON到TXT), all(全部执行)")
    parser.add_argument("--input", default="tmp_files/htmls", help="输入目录 (默认: tmp_files/htmls)")
    parser.add_argument("--cache", default="tmp_files/caches", help="缓存目录 (默认: tmp_files/caches)")
    parser.add_argument("--output", default="tmp_output", help="输出目录 (默认: tmp_output)")
    
    args = parser.parse_args()
    
    input_dir = args.input
    cache_dir = args.cache
    output_dir = args.output
    
    print(f"输入目录: {input_dir}")
    print(f"缓存目录: {cache_dir}")
    print(f"输出目录: {output_dir}")
    print()
    
    if args.command in ["parse", "all"]:
        print("=" * 80)
        print("第一步：解析 HTML 到缓存")
        print("=" * 80)
        print()
        cache_files = parse_all_to_cache(input_dir, cache_dir)
        
        if not cache_files and args.command == "parse":
            print("没有文件被缓存")
            return 1
        
        print()
    
    if args.command in ["merge", "all"]:
        print("=" * 80)
        print("第二步：按标题合并文章")
        print("=" * 80)
        print()
        merge_count = merge_articles_by_title(cache_dir, output_dir)
        
        return 0 if merge_count > 0 else 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())