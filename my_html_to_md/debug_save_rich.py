def get_rich_media_content(html):
    """获取rich_media_content内容"""
    start_idx = html.find('<div')
    while start_idx != -1:
        end_of_tag = html.find('>', start_idx)
        if end_of_tag == -1:
            break
        tag_content = html[start_idx:end_of_tag]
        if 'rich_media_content' in tag_content:
            div_count = 1
            end_idx = end_of_tag + 1
            while end_idx < len(html) and div_count > 0:
                if html[end_idx:end_idx+5] == '</div':
                    div_end = html.find('>', end_idx)
                    if div_end != -1:
                        div_count -= 1
                        end_idx = div_end + 1
                    else:
                        end_idx += 1
                elif html[end_idx:end_idx+4] == '<div':
                    div_count += 1
                    end_idx += 1
                else:
                    end_idx += 1
            if div_count == 0:
                return html[end_of_tag+1:end_idx-6]
        start_idx = html.find('<div', end_of_tag)
    return ''

def main():
    html_file = 'raw/美国打伊朗，比特币为何暴跌？.html'
    
    with open(html_file, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    rich_content = get_rich_media_content(html_content)
    
    with open('temp/rich_media_content_structure.txt', 'w', encoding='utf-8') as f:
        # 只保存前5000字符，避免文件过大
        f.write(rich_content[:5000])
    
    print('已保存 rich_media_content 的前5000字符到 temp/rich_media_content_structure.txt')

if __name__ == '__main__':
    main()
