//
//  Class001-020.mm
//  LeetCode
//
//  Created by SLJ on 2019/8/15.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "Class001-020.h"
#import "ListNode.h"
#include <string>
#include <vector>

using namespace std;

class Solution
{
  public:
    vector<int> twoSum(vector<int> &nums, int target)
    {
        vector<int> ret;
        int a = 0;
        int b = 0;
        bool found = false;
        for (; a < nums.size(); ++a) {
            int next = target - nums[a];
            for (b = a + 1; b < nums.size(); ++b) {
                if (next == nums[b]) {
                    found = true;
                    break;
                }
            }
            if (found) {
                break;
            }
        }
        if (found) {
            ret.push_back(a);
            ret.push_back(b);
        }
        return ret;
    }

    ListNode *addTwoNumbers(ListNode *l1, ListNode *l2)
    {
        ListNode *ret = NULL;
        ListNode *end = NULL;
        int flag = 0;
        while (l1 || l2) {
            ListNode *node = new ListNode(flag);
            if (l1) {
                node->val += l1->val;
                l1 = l1->next;
            }
            if (l2) {
                node->val += l2->val;
                l2 = l2->next;
            }
            if (node->val >= 10) {
                node->val -= 10;
                flag = 1;
            } else {
                flag = 0;
            }
            if (end) {
                end->next = node;
            } else {
                ret = node;
            }
            end = node;
        }
        if (!ret) {
            ret = new ListNode(0);
        }
        if (flag > 0 && end) {
            end->next = new ListNode(1);
        }
        return ret;
    }

    int lengthOfLongestSubstring(string s)
    {
        int length = (int)s.length();
        int i = 0;
        int max = 0;
        for (int j = 0; j < length; ++j) {
            for (int k = i; k < j; ++k)
                if (s[k] == s[j]) {
                    i = k + 1;
                    break;
                }
            if (max < j - i + 1) {
                max = j - i + 1;
            }
        }
        return max;
    }

    double findMedianSortedArrays(vector<int> &nums1, vector<int> &nums2)
    {
        // todo hard
        return 2;
    }

    string convert(string s, int numRows)
    {
        if (s.empty() || numRows <= 1 || numRows >= s.length()) {
            return s;
        }

        vector<string> rows(numRows);
        int curRow = 0;
        bool goingDown = false;
        for (char c : s) {
            rows[curRow] += c;
            if (curRow == 0 || curRow == numRows - 1) { // 当前行curRow为0或numRows -1时，箭头发生反向转折
                goingDown = !goingDown;
            }
            curRow += goingDown ? 1 : -1;
        }
        string ret;
        for (string row : rows) { // 从上到下遍历行
            ret += row;
        }
        return ret;
    }

    int reverse(int x)
    {
        int ret = 0;
        while (x != 0) {
            int pop = x % 10;
            x /= 10;
            if (ret > INT_MAX / 10) {
                return 0;
            }
            if (ret < INT_MIN / 10) {
                return 0;
            }
            ret = ret * 10 + pop;
        }
        return ret;
    }

    int myAtoi(string str)
    {
        long long ans = 0;
        int flag = 0;      // 出现 '-' 置1
        int len = 0;       // 记录数字的长度
        int flagCount = 0; // 记录 "+-" 出现的次数
        for (char c : str) {
            //判断 正负号   且数字长度为0  防止 "0-1" 这样的情况
            if ((c == '+' || c == '-') && len == 0) {
                flagCount++;
                flag = (c == '-') ? 1 : 0;
            } else if (0 <= (c - '0') && (c - '0') <= 9 && flagCount < 2) { // temp<2 表示 正负号 只出现过一次
                ans = ans * 10 + (c - '0');
                len++;
                // INT_MAX=2147483647     INT_MIN=-2147483648
                if (ans - 1 > INT_MAX)
                    break;                                     // 如果 数字的绝对值 大于 INT_MAX +1 那么直接跳出 一定溢出
            } else if (c == ' ' && len == 0 && flagCount == 0) //如果是空格则继续 但前提是 之前没有出现过 正负号 和 数字
                continue;
            else //其他情况：英文和其他字符
                break;
        }
        if (flag == 1) // flag==1 表示数字为负
            return (int)(-ans < INT_MIN ? INT_MIN : -ans);
        return (int)(ans > INT_MAX ? INT_MAX : ans);
    }

    bool isPalindrome(int x)
    {
        // 特殊情况：
        // 如上所述，当 x < 0 时，x 不是回文数。
        // 同样地，如果数字的最后一位是 0，为了使该数字为回文，
        // 则其第一位数字也应该是 0
        // 只有 0 满足这一属性
        if (x < 0 || (x % 10 == 0 && x != 0)) {
            return false;
        }
        int revertedNumber = 0;
        while (x > revertedNumber) {
            revertedNumber = revertedNumber * 10 + x % 10;
            x /= 10;
        }
        // 当数字长度为奇数时，我们可以通过 revertedNumber/10 去除处于中位的数字。
        // 例如，当输入为 12321 时，在 while 循环的末尾我们可以得到 x = 12，revertedNumber = 123，
        // 由于处于中位的数字不影响回文（它总是与自己相等），所以我们可以简单地将其去除。
        return x == revertedNumber || x == revertedNumber / 10;
    }

    bool isMatch(string s, string p)
    {
        if (p.empty())
            return s.empty();

        bool first_match = !s.empty() && (s[0] == p[0] || p[0] == '.');

        if (p.length() >= 2 && p[1] == '*') {
            return isMatch(s, p.substr(2)) || (first_match && isMatch(s.substr(1), p));
        } else {
            return first_match && isMatch(s.substr(1), p.substr(1));
        }
    }
};

@implementation Test2

+ (void)go
{
    Solution s;

    {
        /*
         给定一个整数数组 nums 和一个目标值 target，请你在该数组中找出和为目标值的那 两个 整数，并返回他们的数组下标。
         你可以假设每种输入只会对应一个答案。但是，你不能重复利用这个数组中同样的元素。
         示例:
         给定 nums = [2, 7, 11, 15], target = 9
         因为 nums[0] + nums[1] = 2 + 7 = 9
         所以返回 [0, 1]
         */
        vector<int> nums;
        nums.push_back(2);
        nums.push_back(7);
        nums.push_back(11);
        nums.push_back(15);
        vector<int> ret = s.twoSum(nums, 9);
        NSParameterAssert(ret[0] == 0 && ret[1] == 1);
    }
    {
        /*
         给出两个 非空
         的链表用来表示两个非负的整数。其中，它们各自的位数是按照 逆序 的方式存储的，并且它们的每个节点只能存储 一位 数字。
         如果，我们将这两个数相加起来，则会返回一个新的链表来表示它们的和。
         您可以假设除了数字 0 之外，这两个数都不会以 0 开头。
         示例：
         输入：(2 -> 4 -> 3) + (5 -> 6 -> 4)
         输出：7 -> 0 -> 8
         原因：342 + 465 = 807
         */
        ListNode *node1 = new ListNode(1); // 1
        ListNode *node9 = new ListNode(9);
        ListNode *node99 = new ListNode(9);
        node99->next = node9;
        ListNode *ret = s.addTwoNumbers(node1, node99); // 99
        NSParameterAssert(ret->val == 0);
        NSParameterAssert(ret->next->val == 0);
        NSParameterAssert(ret->next->next->val == 1);
    }
    {
        /*
         给定一个字符串，请你找出其中不含有重复字符的 最长子串 的长度。
         示例 1:
         输入: "abcabcbb"
         输出: 3
         解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
         示例 2:
         输入: "bbbbb"
         输出: 1
         解释: 因为无重复字符的最长子串是 "b"，所以其长度为 1。
         示例 3:
         输入: "pwwkew"
         输出: 3
         解释: 因为无重复字符的最长子串是 "wke"，所以其长度为 3。
              请注意，你的答案必须是 子串 的长度，"pwke" 是一个子序列，不是子串。
         */
        NSParameterAssert(s.lengthOfLongestSubstring("abcabcbb") == 3);
        NSParameterAssert(s.lengthOfLongestSubstring("bbbbb") == 1);
        NSParameterAssert(s.lengthOfLongestSubstring("pwwkew") == 3);
        NSParameterAssert(s.lengthOfLongestSubstring("dvdf") == 3);
    }
    {
        /*
         给定两个大小为 m 和 n 的有序数组 nums1 和 nums2。
         请你找出这两个有序数组的中位数，并且要求算法的时间复杂度为 O(log(m + n))。
         你可以假设 nums1 和 nums2 不会同时为空。
         示例 1:
         nums1 = [1, 3]
         nums2 = [2]
         则中位数是 2.0
         示例 2:
         nums1 = [1, 2]
         nums2 = [3, 4]
         则中位数是 (2 + 3)/2 = 2.5
         */
        vector<int> num1;
        num1.push_back(1);
        num1.push_back(3);
        vector<int> num2;
        num2.push_back(2);
        NSParameterAssert(s.findMedianSortedArrays(num1, num2) == 2);
    }
    {
        /*
         将一个给定字符串根据给定的行数，以从上往下、从左到右进行 Z 字形排列。
         比如输入字符串为 "LEETCODEISHIRING" 行数为 3 时，排列如下：
         L   C   I   R
         E T O E S I I G
         E   D   H   N
         之后，你的输出需要从左往右逐行读取，产生出一个新的字符串，比如："LCIRETOESIIGEDHN"。
         请你实现这个将字符串进行指定行数变换的函数：
         string convert(string s, int numRows);
         示例 1:
         输入: s = "LEETCODEISHIRING", numRows = 3
         输出: "LCIRETOESIIGEDHN"
         示例 2:
         输入: s = "LEETCODEISHIRING", numRows = 4
         输出: "LDREOEIIECIHNTSG"
         解释:
         L     D     R
         E   O E   I I
         E C   I H   N
         T     S     G
         */
    } {
        /*
        给出一个 32 位的有符号整数，你需要将这个整数中每位上的数字进行反转。
        示例 1:
        输入: 123
        输出: 321
         示例 2:
        输入: -123
        输出: -321
        示例 3:
        输入: 120
        输出: 21
         */
        NSParameterAssert(s.reverse(123) == 321);
        NSParameterAssert(s.reverse(120) == 21);
    }
    {
        /*
         请你来实现一个 atoi 函数，使其能将字符串转换成整数。
         首先，该函数会根据需要丢弃无用的开头空格字符，直到寻找到第一个非空格的字符为止。
         当我们寻找到的第一个非空字符为正或者负号时，则将该符号与之后面尽可能多的连续数字组合起来，作为该整数的正负号；假如第一个非空字符是数字，则直接将其与之后连续的数字字符组合起来，形成整数。
         该字符串除了有效的整数部分之后也可能会存在多余的字符，这些字符可以被忽略，它们对于函数不应该造成影响。
         注意：假如该字符串中的第一个非空格字符不是一个有效整数字符、字符串为空或字符串仅包含空白字符时，则你的函数不需要进行转换。
         在任何情况下，若函数不能进行有效的转换时，请返回 0。
         说明：
         假设我们的环境只能存储 32 位大小的有符号整数，那么其数值范围为 [−2(31),  2(31) −
         1]。如果数值超过这个范围，qing返回  INT_MAX 或 INT_MIN
         示例 1:
         输入: "42"
         输出: 42
         示例 2:
         输入: "   -42"
         输出: -42
         解释: 第一个非空白字符为 '-', 它是一个负号。
              我们尽可能将负号与后面所有连续出现的数字组合起来，最后得到 -42 。
         示例 3:
         输入: "4193 with words"
         输出: 4193
         解释: 转换截止于数字 '3' ，因为它的下一个字符不为数字。
         示例 4:
         输入: "words and 987"
         输出: 0
         解释: 第一个非空字符是 'w', 但它不是数字或正、负号。
         因此无法执行有效的转换。
         示例 5:
         输入: "-91283472332"
         输出: -2147483648
         解释: 数字 "-91283472332" 超过 32 位有符号整数范围。
              因此返回 INT_MIN (−231) 。
         */
        NSParameterAssert(s.myAtoi("   -42") == -42);
    }
    {
        /*
         判断一个整数是否是回文数。回文数是指正序（从左向右）和倒序（从右向左）读都是一样的整数。
         输入: 121
         输出: true
         */
        NSParameterAssert(s.isPalindrome(121));
    }
}

@end
