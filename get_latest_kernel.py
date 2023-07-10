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
# 比较两个版本
if latest_kernel and current_kernel: # 检查两个变量是否都存在
    if latest_kernel == current_kernel:
        print("您已经安装了最新的Linux内核")
    else:
        print("您的Linux内核有更新可用")
        # 在这里添加自动更新的代码，例如使用apt-get或者其他工具
else:
    print("无法比较两个版本")
