#!/usr/bin/env python3
# 获取最新的Linux内核版本
import requests
import re
latest_kernel = None # 给 latest_kernel 赋一个初始值
try:
    response = requests.get("https://www.kernel.org/")
    # 修改正则表达式，匹配以数字开头并且包含小数点的字符串
    latest_kernel = re.search(r"\d+\.\d+\.\d+", response.text).group()
    print(f"最新的Linux内核版本是：{latest_kernel}")
except requests.exceptions.RequestException as e:
    print(f"请求内核官网失败：{e}")
except AttributeError as e:
    print(f"匹配内核版本失败：{e}")
# 将最新的内核版本写入到文件中
try:
    with open("get_latest_kernel.txt", "w") as f: # 以写入模式打开文件
        f.write(str(latest_kernel)) # 写入最新的内核版本，转换为字符串类型
        print(f"已将最新的内核版本导出到 get_latest_kernel.txt 文件中")
except IOError as e:
    print(f"写入文件失败：{e}")
# 获取当前的Linux内核版本
import os
current_kernel = None # 给 current_kernel 赋一个初始值
try:
    # 修改正则表达式，匹配以数字开头并且包含小数点的字符串
    current_kernel = re.search(r"\d+\.\d+\.\d+", os.popen("uname -r").read()).group()
    print(f"当前的Linux内核版本是：{current_kernel}")
except OSError as e:
    print(f"获取内核版本失败：{e}")
except AttributeError as e:
    print(f"匹配内核版本失败：{e}")
