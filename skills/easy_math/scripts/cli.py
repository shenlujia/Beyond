
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
easy_math 命令行接口
"""

import sys
import argparse
from generator import (
    generate_questions, 
    format_questions,
    generate_20_mixed_add_sub,
    format_questions_grid,
    save_to_docx
)


def main():
    parser = argparse.ArgumentParser(description='生成小孩子数学题目')
    parser.add_argument('command', choices=['generate', '20-add-sub'], help='命令类型 (generate: 常规题目; 20-add-sub: 20以内进退位加减法)')
    parser.add_argument('--type', '-t', 
                        choices=['add', 'sub', 'mul', 'div', 'mixed'],
                        default='add',
                        help='题目类型 (add/sub/mul/div/mixed)')
    parser.add_argument('--count', '-c', type=int, default=10,
                        help='题目数量 (默认: 10)')
    parser.add_argument('--difficulty', '-d', type=int, default=2, choices=[1, 2, 3, 4, 5],
                        help='难度等级 1-5 (默认: 2)')
    parser.add_argument('--output', '-o', help='输出文件 (支持 .txt 和 .docx)')
    parser.add_argument('--show-answers', '-a', action='store_true',
                        help='显示答案')
    parser.add_argument('--grid', '-g', action='store_true',
                        help='网格布局 (每行4题)')
    parser.add_argument('--per-row', type=int, default=4,
                        help='每行题目数量 (默认: 4)')
    
    args = parser.parse_args()
    
    if args.command == '20-add-sub':
        print("生成 %d 道20以内进退位加减法" % args.count)
        print()
        
        questions = generate_20_mixed_add_sub(args.count)
        
        if args.output and args.output.endswith('.docx'):
            save_to_docx(questions, args.output, args.per_row, args.show_answers)
            print("已保存到: %s" % args.output)
        else:
            output = format_questions_grid(questions, args.per_row, args.show_answers)
            print(output)
            
            if args.output:
                with open(args.output, 'w', encoding='utf-8') as f:
                    f.write(output)
                print()
                print("已保存到: %s" % args.output)
    
    elif args.command == 'generate':
        type_names = {
            'add': '加法',
            'sub': '减法',
            'mul': '乘法',
            'div': '除法',
            'mixed': '混合运算'
        }
        
        print("生成 %d 道%s题，难度等级 %d" % (args.count, type_names[args.type], args.difficulty))
        print()
        
        questions = generate_questions(args.type, args.count, args.difficulty)
        
        if args.grid:
            output = format_questions_grid(questions, args.per_row, args.show_answers)
        else:
            output = format_questions(questions, args.show_answers)
        
        print(output)
        
        if args.output:
            if args.output.endswith('.docx'):
                save_to_docx(questions, args.output, args.per_row, args.show_answers)
            else:
                with open(args.output, 'w', encoding='utf-8') as f:
                    f.write(output)
            print()
            print("已保存到: %s" % args.output)


if __name__ == '__main__':
    main()
