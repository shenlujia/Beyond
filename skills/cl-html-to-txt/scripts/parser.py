#!/usr/bin/env python3
"""
网页解析模块
负责从HTML中提取纯文本内容
"""

import re
from typing import Optional


def extract_title(html: str) -> str:
    """
    从HTML中提取标题
    
    Args:
        html: HTML内容
        
    Returns:
        标题字符串
    """
    title_match = re.search(r'<title[^>]*>([^<]+)</title>', html, re.IGNORECASE)
    if title_match:
        title = title_match.group(1).strip()
        title = re.sub(r'&nbsp;', ' ', title)
        title = re.sub(r'\s+', ' ', title)
        title = re.sub(r'\s*-\s*成人文學交流區.*$', '', title)
        title = title.strip()
        
        # 检查是否符合特定格式：[四个字] 标题
        parts = title.split(' ')
        if len(parts) == 2:
            part_a = parts[0]
            part_b = parts[1]
            if len(part_a) == 6 and part_a.startswith('[') and part_a.endswith(']'):
                middle_part = part_a[1:-1]
                if len(middle_part) == 4:
                    return part_b
        
        return title
    return "untitled"


def extract_tpc_content(html: str) -> str:
    """
    从HTML中提取所有 tpc_content 中的内容，之间用空行分隔，并移除 t_like 内容
    
    Args:
        html: HTML内容
        
    Returns:
        所有 tpc_content 中的 HTML 内容，之间用空行分隔
    """
    cleaned_html = re.sub(r'<div[^>]*class="[^"]*t_like[^"]*"[^>]*>[\s\S]*?</div>', '', html, flags=re.IGNORECASE)
    
    contents = []
    
    content_matches = re.finditer(
        r'<div[^>]*class="[^"]*tpc_content[^"]*"[^>]*>([\s\S]*?)</div>',
        cleaned_html,
        re.IGNORECASE
    )
    for match in content_matches:
        contents.append(match.group(1))
    
    if not contents:
        content_matches = re.finditer(
            r'<div[^>]*id="[^"]*conttpc[^"]*"[^>]*>([\s\S]*?)</div>',
            cleaned_html,
            re.IGNORECASE
        )
        for match in content_matches:
            contents.append(match.group(1))
    
    if contents:
        return '<br><br>'.join(contents)
    
    return cleaned_html


def clean_html_tags(html: str) -> str:
    """
    清除HTML标签，保留文本内容，优化 <br> 标签处理
    
    Args:
        html: HTML内容
        
    Returns:
        纯文本内容
    """
    text = html
    
    text = re.sub(r'<div[^>]*class="[^"]*t_like[^"]*"[^>]*>[\s\S]*?</div>', '', text, flags=re.IGNORECASE)
    
    text = re.sub(r'<!--[\s\S]*?-->', '', text)
    
    text = re.sub(r'<script[^>]*>[\s\S]*?</script>', '', text, flags=re.IGNORECASE)
    text = re.sub(r'<style[^>]*>[\s\S]*?</style>', '', text, flags=re.IGNORECASE)
    text = re.sub(r'<noscript[^>]*>[\s\S]*?</noscript>', '', text, flags=re.IGNORECASE)
    
    text = re.sub(r'<p[^>]*>', '\n\n', text, flags=re.IGNORECASE)
    text = re.sub(r'</p>', '', text, flags=re.IGNORECASE)
    
    text = re.sub(r'<div[^>]*>', '\n', text, flags=re.IGNORECASE)
    text = re.sub(r'</div>', '', text, flags=re.IGNORECASE)
    text = re.sub(r'<h[1-6][^>]*>', '\n\n', text, flags=re.IGNORECASE)
    text = re.sub(r'</h[1-6]>', '', text, flags=re.IGNORECASE)
    
    text = re.sub(r'<li[^>]*>', '\n• ', text, flags=re.IGNORECASE)
    text = re.sub(r'</li>', '', text, flags=re.IGNORECASE)
    
    br_parts = re.split(r'<br\s*/?>', text, flags=re.IGNORECASE)
    
    original_parts = []
    for part in br_parts:
        part_clean = re.sub(r'<[^>]+>', '', part)
        part_clean = re.sub(r'&nbsp;', ' ', part_clean)
        part_clean = re.sub(r'&lt;', '<', part_clean)
        part_clean = re.sub(r'&gt;', '>', part_clean)
        part_clean = re.sub(r'&amp;', '&', part_clean)
        part_clean = re.sub(r'&quot;', '"', part_clean)
        part_clean = re.sub(r'&#39;', "'", part_clean)
        original_parts.append(part_clean)
    
    result = []
    ending_punctuation = r'[。！？.!?」』」』））\]\]"\'\'\'\'…⋯]$'
    last_was_author_line = False
    
    for i in range(len(original_parts)):
        original_part = original_parts[i]
        part_clean = original_part.rstrip()
        
        if i == 0:
            result.append(part_clean)
        else:
            if not part_clean.strip():
                result.append('\n')
            else:
                should_newline = False
                
                if i > 0:
                    prev_original = original_parts[i-1]
                    last_result = result[-1] if result else ''
                    curr_original = original_parts[i]
                    
                    if last_was_author_line:
                        should_newline = True
                    elif re.search(r'\s$', prev_original):
                        should_newline = True
                    elif last_result and re.search(ending_punctuation, last_result):
                        should_newline = True
                    elif re.search(r'^\s', curr_original):
                        should_newline = True
                
                is_author_line = False
                part_stripped = part_clean.strip()
                if (part_stripped.startswith('作者：') or part_stripped.startswith('作者:')):
                    if not re.search(ending_punctuation, part_stripped):
                        is_author_line = True
                        should_newline = True
                
                if should_newline:
                    result.append('\n' + part_clean)
                    if is_author_line:
                        result.append('\n')
                else:
                    if result:
                        result[-1] = result[-1] + part_clean
                    else:
                        result.append(part_clean)
                
                last_was_author_line = is_author_line
    
    text = ''.join(result)
    
    return text


def normalize_text(text: str) -> str:
    """
    规范化文本，清理多余空白，保留 clean_html_tags 中的换行处理和行首空格
    
    Args:
        text: 原始文本
        
    Returns:
        规范化后的文本
    """
    lines = text.split('\n')
    
    cleaned_lines = []
    for line in lines:
        line = line.rstrip()
        cleaned_lines.append(line)
    
    result = '\n'.join(cleaned_lines)
    
    result = re.sub(r'[ \t]+', ' ', result)
    result = re.sub(r'\n{3,}', '\n\n', result)
    
    return result


def parse_html_to_text(html: str) -> str:
    """
    将HTML解析为纯文本
    
    Args:
        html: HTML内容
        
    Returns:
        纯文本内容
    """
    title = extract_title(html)
    content_html = extract_tpc_content(html)
    text = clean_html_tags(content_html)
    text = normalize_text(text)
    
    result = f"{title}\n\n{'=' * len(title)}\n\n{text}"
    
    return result


def parse_tpc_content_to_lines(html: str) -> list:
    """
    解析单个 tpc_content 的 HTML 内容，返回每行文本的数组
    
    Args:
        html: 单个 tpc_content 的 HTML 内容
        
    Returns:
        每行文本的数组
    """
    text = clean_html_tags(html)
    text = normalize_text(text)
    lines = text.split('\n')
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
    return merged_lines


def parse_html_to_structured(html: str) -> dict:
    """
    将HTML解析为结构化数据
    
    Args:
        html: HTML内容
        
    Returns:
        包含 title 和 tpc_content 数组的字典
    """
    title = extract_title(html)
    
    cleaned_html = re.sub(r'<div[^>]*class="[^"]*t_like[^"]*"[^>]*>[\s\S]*?</div>', '', html, flags=re.IGNORECASE)
    
    tpc_contents = []
    
    content_matches = re.finditer(
        r'<div[^>]*class="[^"]*tpc_content[^"]*"[^>]*>([\s\S]*?)</div>',
        cleaned_html,
        re.IGNORECASE
    )
    for match in content_matches:
        content_html = match.group(1)
        lines = parse_tpc_content_to_lines(content_html)
        tpc_contents.append(lines)
    
    if not tpc_contents:
        content_matches = re.finditer(
            r'<div[^>]*id="[^"]*conttpc[^"]*"[^>]*>([\s\S]*?)</div>',
            cleaned_html,
            re.IGNORECASE
        )
        for match in content_matches:
            content_html = match.group(1)
            lines = parse_tpc_content_to_lines(content_html)
            tpc_contents.append(lines)
    
    return {
        "title": title,
        "tpc_content": tpc_contents
    }


def sanitize_filename(title: str) -> str:
    """
    清理文件名，移除非法字符
    
    Args:
        title: 原始标题
        
    Returns:
        安全的文件名
    """
    filename = title
    filename = re.sub(r'[<>:\"/\\|?*]', '_', filename)
    filename = re.sub(r'[\x00-\x1f\x7f]', '', filename)
    filename = filename.strip()
    filename = filename[:100]
    if not filename:
        filename = "untitled"
    return filename


def get_final_title(title: str) -> str:
    """
    获取最终标题，如果符合特定格式则使用 B 部分
    
    规则：
    - 如果包含空格
    - 用第一个空格作为分割符拆为 A 和 B
    - 且 A 第一个字是 [，最后一个字是 ]
    - 且 [] 中间是四个字
    - 那么最终的标题应该是 B
    
    Args:
        title: 原始标题
        
    Returns:
        最终标题
    """
    first_space_index = title.find(' ')
    if first_space_index != -1:
        part_a = title[:first_space_index]
        part_b = title[first_space_index + 1:]
        if part_a.startswith('[') and part_a.endswith(']'):
            middle_part = part_a[1:-1]
            if len(middle_part) == 4:
                return part_b
    return title