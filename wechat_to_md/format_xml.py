import xml.etree.ElementTree as ET
from xml.dom import minidom

def format_xml_with_indent(file_path, output_path):
    """读取文件并格式化为有缩进的XML"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 尝试解析为XML
    try:
        root = ET.fromstring(content)
        xml_str = ET.tostring(root, encoding='utf-8')
        
        # 使用minidom进行格式化
        dom = minidom.parseString(xml_str)
        pretty_xml = dom.toprettyxml(indent='  ', encoding='utf-8')
        
        with open(output_path, 'wb') as f:
            f.write(pretty_xml)
        
        print(f"格式化成功！已保存到 {output_path}")
    except Exception as e:
        print(f"解析XML失败: {e}")
        print("尝试使用HTML解析...")
        
        # 如果XML解析失败，尝试简单的格式化
        format_html_simple(content, output_path)

def format_html_simple(content, output_path):
    """简单格式化HTML"""
    # 基本的HTML格式化逻辑
    result = []
    indent_level = 0
    i = 0
    n = len(content)
    
    while i < n:
        if content[i] == '<':
            # 找到标签结束位置
            j = i
            while j < n and content[j] != '>':
                j += 1
            if j >= n:
                break
            
            tag = content[i:j+1]
            
            # 判断标签类型
            is_closing = tag.startswith('</')
            is_self_closing = tag.endswith('/>') or tag in ['<br>', '<br/>', '<img>', '<img/>', '<hr>', '<hr/>', '<input>', '<input/>', '<meta>', '<meta/>', '<link>', '<link/>']
            
            # 处理缩进
            if is_closing:
                indent_level -= 1
                if indent_level < 0:
                    indent_level = 0
            
            # 添加缩进和标签
            result.append('  ' * indent_level)
            result.append(tag)
            result.append('\n')
            
            # 更新缩进级别
            if not is_closing and not is_self_closing:
                indent_level += 1
            
            i = j + 1
        elif content[i].isspace():
            i += 1
        else:
            # 找到文本内容结束位置
            j = i
            while j < n and content[j] != '<':
                j += 1
            
            text = content[i:j].strip()
            if text:
                result.append('  ' * indent_level)
                result.append(text)
                result.append('\n')
            
            i = j
    
    # 写入文件
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(''.join(result))
    
    print(f"格式化完成！已保存到 {output_path}")

if __name__ == '__main__':
    format_xml_with_indent('temp/test.txt', 'temp/formatted.xml')
