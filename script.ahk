;需要先修改变量"需要备份的文件夹路径" & "备份文件夹目的路径"
; 设置文件编码为 UTF-8
; Using Enable FilterKeys
; https://support.microsoft.com/en-us/topic/using-the-shortcut-key-to-enable-filterkeys-d9202e14-4ce5-84ed-582b-68ea1538fa59
; In Control Panel, double-click Accessibility Options.
; Click the Keyboard tab, click Settings in the FilterKeys section to enable the FilterKeys feature.

FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; #NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#InstallKeybdHook
#InstallMouseHook
#SingleInstance force
; #Persistent
#MaxHotkeysPerInterval 1000
; #HotkeyInterval 99000000
#KeyHistory 0

CoordMode, Mouse, Client

#Include MouseKeyBoardDLL.ahk
ScriptDir := A_ScriptDir
IniFile := ScriptDir "\ZERO Sievert Settings.ini"

if not A_IsAdmin
{
    ; 请求管理员权限并重新启动脚本
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

IfNotExist, %IniFile%
{
    Gosub 写入ini变量默认值
}
Gosub 读取ini变量
Gosub 射击延迟变量写入ini
Hotkey, %备份热键%, 备份热键
Hotkey, %人数统计快捷键%, 增加人数统计
Hotkey, +%人数统计快捷键%, 减少人数统计
Hotkey, %物资统计快捷键%, 增加物资统计
Hotkey, +%物资统计快捷键%, 减少物资统计
Hotkey, %清空统计数据%, 清空统计数据
Hotkey, +%清空统计数据%, 清空人数统计数据
Hotkey, !%清空统计数据%, 清空物资统计数据
Hotkey, %移动物品%, 启动移动物品
Hotkey, %移动物品% Up, 关闭移动物品
Hotkey, %增加连点延迟%, 增加连点延迟
Hotkey, %减少连点延迟%, 减少连点延迟
Hotkey, *%连点鼠标左键%, 连点鼠标左键
Hotkey, *%连点鼠标左键% Up, 终止连点鼠标左键
Hotkey, ~%释放Shift快捷键%, 侦测和判断Shift

Hotkey, *~Shift, Shift按下处理函数
; Hotkey, *~Shift Up, ShiftUp处理函数
Hotkey, *~Lbutton, Lbutton按下处理函数
Hotkey, *~Lbutton Up, LbuttonUp处理函数
global 1按键:= "1"
global 2按键:= "2"
Hotkey, ~^%1按键%, 绑定一号武器程序
Hotkey, ~^%2按键%, 绑定二号武器程序
Hotkey, ~%1按键%, 正在使用的武器编号程序
Hotkey, ~%2按键%, 正在使用的武器编号程序

global Mon_1_X_M := A_ScreenWidth/2
global Mon_1_Y_M := A_ScreenHeight/2
global X_0:=""
global Y_0:=""
global X_ratio := 3840 / A_ScreenWidth
global Y_ratio := 2160 / A_ScreenHeight
global X_Interval:=Round(128/X_ratio, 3)
global Y_Interval:=Round(128/Y_ratio, 3)
global X_3_Left:= 245/X_ratio
global Y_3_Left:= 245/Y_ratio
global X_Backpack_Range_End_Left:= 左容器的右边界/X_ratio
global X_Backpack_Range_End_Right:= 右容器的右边界/X_ratio
global Y_Backpack_Range_End:= 1930/X_ratio

备份信息档案路径 := A_WorkingDir . "\" . 备份信息档案名称 ;不需要改

X_A_Index:=0
Y_A_Index:=0

^+I::Suspend ;开关
^+s::
    Send, ^s ; To save a changed script
    Sleep, 300 ; give it time to save the script
    loop, 1
    {
        soundBeep
    }
    Reload
Return
GetStyles: ;字符的颜色/大小/背景
    {
        OwnStyle2 := {Border:3
            , Rounded:30
            , Margin:30
            , BorderColorLinearGradientStart:0xffb7407c
            , BorderColorLinearGradientEnd:0xff3881a7
            , BorderColorLinearGradientAngle:45
            , BorderColorLinearGradientMode:6
            , TextColor:0xffd9d9db
            , BackgroundColor:0xff26293a
            , FontSize:16
            , FontRender:4
            , FontStyle:"Bold"}
        OwnStyle3 := {BorderColor:0x00ffffff
            , TextColorLinearGradientStart:0xCCFF0000
            , TextColorLinearGradientEnd:0xCCFF0000
            , TextColorLinearGradientAngle:Angle
            , TextColorLinearGradientMode:1
            , BackgroundColor:0x00ffffff
            , FontSize:20
            , FontRender:4
            , FontStyle:"Bold"}
        OwnStyle4 := {BorderColor:0x00ffffff
            , TextColorLinearGradientStart:0xCC335BCE
            , TextColorLinearGradientEnd:0xCC335BCE
            , TextColorLinearGradientAngle:Angle
            , TextColorLinearGradientMode:1
            , BackgroundColor:0x00ffffff
            , FontSize:20
            , FontRender:4
            , FontStyle:"Bold"}
        OwnStyle5 := {BorderColor:0x00ffffff
            , TextColorLinearGradientStart:0xCCFF0000
            , TextColorLinearGradientEnd:0xCCFF0000
            , TextColorLinearGradientAngle:Angle
            , TextColorLinearGradientMode:1
            , BackgroundColor:0x00ffffff
            , FontSize:20
            , FontRender:4
            , FontStyle:"Bold"}
        OwnStyle6 := {Border:3
            , Rounded:30
            , Margin:30
            , BorderColorLinearGradientStart:0xffb7407c
            , BorderColorLinearGradientEnd:0xff3881a7
            , BorderColorLinearGradientAngle:Angle+45
            , BorderColorLinearGradientMode:6
            , TextColor:0xffd9d9db
            , FontSize:20
            , BackgroundColor:0xff26293a}
        OwnStyle7 := {BorderColor:0x00ffffff
            , TextColorLinearGradientStart:0xCC335BCE
            , TextColorLinearGradientEnd:0xCC335BCE
            , TextColorLinearGradientAngle:Angle
            , TextColorLinearGradientMode:1
            , BackgroundColor:0x00ffffff
            , FontSize:70
            , FontRender:4
            , FontStyle:"Bold"}
    }return

人数统计显示:
    {
        人数统计显示 =
        (
            %人数统计%
            )
    }Return

物资统计显示:
    {
        物资统计显示 =
            (
                %物资统计%
            )
    }Return

备份热键: ;备份热键
    {
        FileRead, a, %A_WorkingDir%\%备份序号档案%
        if (a = "")
        {
            a := 0
        }
        Global b := a + 1
        if (b = 6)
        {
            b := 1
        }
        File := FileOpen(备份序号档案, "w")  ; 直接覆盖写入文件
        File.Write(b)
        File.Close()
        GoSub, Save_Backup
        return
    }

Save_Backup:
    {
        备份文件夹 := 备份文件夹目的路径 . "\Backup_" . b
        IfNotExist, %备份文件夹%
        {
            FileCreateDir, %备份文件夹%
        }
        If (只备份存档文件="True")
            ErrorCount := CopyFilesAndFolders_1(需要备份的文件路径, 备份文件夹)
        Else
            ErrorCount := CopyFilesAndFolders_1(需要备份的文件夹路径 . "\*.*", 备份文件夹)
        if (ErrorCount != 0)
        {
            MsgBox, %ErrorCount% files/folders could not be copied.
        }

        物资统计显示 =
        (
        Saved`nBackup_%b%
        )
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(物资统计显示,50,50,11,OwnStyle2)
        SetTimer, ToolTip_Remove_BTT, -2500

        FormatTime, Format_Time_for_Backup_Loop,, yyyy/MM/dd HH:mm:ss
        FileAppend, %Format_Time_for_Backup_Loop%`n备份信息_%b%`n, %备份信息档案路径%
        SoundBeep, 200, 80
    }Return

    CopyFilesAndFolders_1(SourcePattern, DestinationFolder, DoOverwrite = True)
    {
        ; 首先复制所有文件 (不是文件夹):
        FileCopy, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
        ErrorCount := ErrorLevel

        ; 现在复制所有文件夹:
        Loop, %SourcePattern%, 2  ; 2 表示 "只获取文件夹".
        {
            FileCopyDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
            ErrorCount += ErrorLevel
            if ErrorLevel  ; 报告每个出现问题的文件夹名称.
                MsgBox Could not copy %A_LoopFileFullPath% into %DestinationFolder%.
        }
        return ErrorCount
    }

ToolTip_Remove_BTT: ;移除提示框BTT
    {
        btt(,,,11)
        btt(,,,12)
    }Return

ToolTip_Remove: ;移除提示框
    {
        ToolTip
    }Return

增加人数统计:
    {
        人数统计 ++
        If (人数统计=0)
            人数统计:=""
        Gosub, 人数统计显示
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(人数统计显示,50,Mon_1_Y_M,9,OwnStyle3)
        SoundPlay, Windows Information Bar.wav
    }Return

减少人数统计:
    {
        人数统计 --
        If (人数统计=0)
            人数统计:=""
        Gosub, 人数统计显示
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(人数统计显示,50,Mon_1_Y_M,9,OwnStyle3)
        SoundPlay, Windows Information Bar.wav
    }Return

增加物资统计:
    {
        物资统计 ++
        If (物资统计=0)
            物资统计:=""
        Gosub, 物资统计显示
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(物资统计显示,50,Mon_1_Y_M+50,10,OwnStyle4)
        SoundPlay, Windows Information Bar.wav
    }Return

减少物资统计:
    {
        物资统计 --
        If (物资统计=0)
            物资统计:=""
        Gosub, 物资统计显示
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(物资统计显示,50,Mon_1_Y_M+50,10,OwnStyle4)
        SoundPlay, Windows Information Bar.wav
    }Return

清空统计数据: ;清空数据
    {
        人数统计:=""
        btt(,50,Mon_1_Y_M+50,9,OwnStyle3)
        物资统计:=""
        btt(,50,Mon_1_Y_M+50,10,OwnStyle3)
        SoundPlay, Windows Information Bar.wav
    }Return
清空人数统计数据: ;清空数据
    {
        人数统计:=""
        btt(,50,Mon_1_Y_M+50,9,OwnStyle3)
        SoundPlay, Windows Information Bar.wav
    }Return

清空物资统计数据: ;清空数据
    {
        物资统计:=""
        btt(,50,Mon_1_Y_M+50,10,OwnStyle3)
        SoundPlay, Windows Information Bar.wav
    }Return

启动移动物品:
    {
        关闭Hotkey()
        Gosub, 移动物品
    }Return

关闭移动物品:
    {
        开启Hotkey()
    }Return

移动物品: ;移动/收获现在鼠标位置以及之后的战利品 (等同Ctrl + 左键)
    {

        MouseGetPos X_0, Y_0
        if (X_0 < Mon_1_X_M)
        {
            global X_3_Left:= 396/X_ratio
            global Y_3_Left:= 245/Y_ratio
            global X_Backpack_Range_End:= X_Backpack_Range_End_Left
        }
        else if (X_0 > Mon_1_X_M)
        {
            global X_3_Left:= 2550/X_ratio
            global Y_3_Left:= 390/Y_ratio
            global X_Backpack_Range_End:= X_Backpack_Range_End_Right
        }
        KeyDownDLL(0x11) ;0x11	CTRL key Down
        Sleep 5
        MouseLButtonDLL_25ms()
        SoundPlay, Windows Information Bar.wav
        Sleep 15
        KeyUpDLL(0x11) ;0x11	CTRL key Up
        Sleep 1
        if GetKeyState("C", "P") ;獲取鼠標第一行的戰利品。
        {
            loop 8
            {
                X_A_Index:= (A_Index-1)
                X_3_left_A:= X_0 + (X_A_Index * X_Interval)
                if (X_3_left_A > X_Backpack_Range_End)
                {
                    KeyUpDLL(0x11) ;0x11	CTRL key Up
                    Sleep 1
                    break
                }
                if GetKeyState("C", "P") And (A_Index != 1)
                {
                    KeyDownDLL(0x11) ;0x11	CTRL key Down
                    Sleep 5
                    MouseMoveDLL(X_3_left_A, Y_0)
                    Sleep 15
                    MouseLButtonDLL_25ms()
                    Sleep 15
                }
                KeyUpDLL(0x11) ;0x11	CTRL key Up
                Sleep 1
            }
        }
        if GetKeyState("C", "P")
            Loop 11
            {
                Y_A_Index:= (A_Index-0)
                Y_3_Left_A:= Y_0 + (Y_A_Index * Y_Interval)
                if (!GetKeyState("C", "P") or (Y_3_Left_A > Y_Backpack_Range_End))
                {
                    Return
                }
                Get_Items_Left()
            }
        X_A_Index:= ""
        Y_A_Index:= ""
        return
    }

    Get_Items_Left() ;獲取鼠標第二行及之后的戰利品。
    {
        global X_Interval,Y_Interval,X_3_Left,Y_3_Left_A,X_0,Y_0,notColorList,X_3_Left_A
        If (GetKeyState("C", "P"))
            loop 8
            {
                X_A_Index:= (A_Index-1)
                X_3_left_A:= X_3_left + (X_A_Index * X_Interval)

                if (X_3_left_A > X_Backpack_Range_End)
                {
                    KeyUpDLL(0x11) ;0x11	CTRL key Up
                    Sleep 1
                    Return
                }
                if GetKeyState("C", "P")
                {
                    KeyDownDLL(0x11) ;0x11	CTRL key Down
                    Sleep 5
                    MouseMoveDLL(X_3_left_A, Y_3_Left_A)
                    Sleep 15
                    MouseLButtonDLL_25ms()
                    Sleep 15
                }
            }
        KeyUpDLL(0x11) ;0x11	CTRL key Up
        Sleep 1
        X_A_Index:= ""
        KeyWait, %移动物品%
        Return
    }

增加连点延迟: ;增加连点延迟
    {
        global 射击延迟
        射击延迟 := 射击延迟 + 5
        ToolTip 射击延迟: %射击延迟%
        SetTimer 射击延迟变量写入ini, -5000
        SetTimer ToolTip_Remove, -1000
    }Return

减少连点延迟: ;减少连点延迟
    {
        global 射击延迟
        射击延迟 := 射击延迟 - 5
        ToolTip 射击延迟: %射击延迟%
        SetTimer 射击延迟变量写入ini, -5000
        SetTimer ToolTip_Remove, -1000
    }Return

连点鼠标左键: ;连点鼠标左键
    {
        SetTimer, Click_LButton, 5
    }Return

终止连点鼠标左键: ;关闭settimer
    {
        SetTimer, Click_LButton, Off
        ;Send {LButton Up}
    }Return

    Click_LButton()
    {
        MouseLButtonDLL_25ms()
        Sleep 射击延迟
    }

侦测和判断Shift:
    {
        自动释放Shift状态 := !自动释放Shift状态
        If (自动释放Shift状态=1) {
            自动释放Shift状态显示:= "Release Shift Automatically"
        }
        If (自动释放Shift状态=0) {
            自动释放Shift状态显示:= "Release Shift Automatically Turned off"
        }
        释放Shift状态 =
        (
%自动释放Shift状态显示%
        )
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(释放Shift状态,50,50,12,OwnStyle2)
        SetTimer, 变量写入ini, -5000
        SetTimer, ToolTip_Remove_BTT, -3000
    }Return

Lbutton按下处理函数:
    {
        If (正在使用的武器编号 == 1 And 绑定一号武器 == 0) Or (正在使用的武器编号 == 2 And 绑定二号武器 == 0) Or (自动释放Shift状态 == 0) {
            Return
        }
        If (GetKeyState("LButton", "P") And GetKeyState("Shift", "P")) {
            ;SendInput, {Shift Up}
            KeyUpDLL(0xA0) ; LSHIFT Up
        }
    }Return

LbuttonUp处理函数:
    {
        If (GetKeyState("Shift", "P")) {
            KeyDownDLL(0xA0) ; LSHIFT Down
        }
    }Return

Shift按下处理函数:
    {
        ;     Shift按下统计 ++
        ;     testA =
        ; (
        ; %Shift按下统计% timesShift按下统计
        ; )
        ;     Angle:=(A_Index-1)*3
        ;     gosub, GetStyles
        ;     btt(testA,50,50,13,OwnStyle2)
        If (正在使用的武器编号 == 1 And 绑定一号武器 == 0) Or (正在使用的武器编号 == 2 And 绑定二号武器 == 0) Or (自动释放Shift状态 == 0) {
            Return
        }
        If (GetKeyState("LButton", "P") And GetKeyState("Shift", "P")) {
            KeyUpDLL(0xA0) ; LSHIFT Up
        }
    }Return

绑定一号武器程序:
    {
        绑定一号武器 := !绑定一号武器
        If (绑定一号武器=1) {
            绑定一号武器显示:= "Bind Weapon No.1 "
        }
        If (绑定一号武器=0) {
            绑定一号武器显示:= "Unbind Weapon No.1"
        }
        绑定一号武器状态 =
        (
        %绑定一号武器显示%
        )
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(绑定一号武器状态,50,50,12,OwnStyle2)
        SetTimer, 变量写入ini, -5000
        SetTimer, ToolTip_Remove_BTT, -3000
    }Return

绑定二号武器程序:
    {
        绑定二号武器 := !绑定二号武器
        If (绑定二号武器=1) {
            绑定二号武器显示:= "Bind Weapon No.2"
        }
        If (绑定二号武器=0) {
            绑定二号武器显示:= "Unbind Weapon No.2"
        }
        绑定二号武器状态 =
        (
        %绑定二号武器显示%
        )
        Angle:=(A_Index-1)*3
        gosub, GetStyles
        btt(绑定二号武器状态,50,50,12,OwnStyle2)
        SetTimer, 变量写入ini, -5000
        SetTimer, ToolTip_Remove_BTT, -3000
    }Return

正在使用的武器编号程序:
    {
        If GetKeyState("1", "P") {
            正在使用的武器编号 := 1
            If (绑定一号武器=1)
                bindStaus:= "Bind"
            Else
                bindStaus:= "Unbind"
            绑定武器状态 =
            (
Using Weapon No.%正在使用的武器编号% (%bindStaus%)
            )
            Angle:=(A_Index-1)*3
            gosub, GetStyles
            btt(绑定武器状态,50,50,12,OwnStyle2)
            SetTimer, 变量写入ini, -2000
            SetTimer, ToolTip_Remove_BTT, -2000
        }
        If GetKeyState("2", "P") {
            正在使用的武器编号 := 2
            If (绑定二号武器=1)
                bindStaus:= "Bind"
            Else
                bindStaus:= "Unbind"
            绑定武器状态 =
            (
Using Weapon No.%正在使用的武器编号% (%bindStaus%)
            )
            Angle:=(A_Index-1)*3
            gosub, GetStyles
            btt(绑定武器状态,50,50,12,OwnStyle2)
            SetTimer, 变量写入ini, -2000
            SetTimer, ToolTip_Remove_BTT, -2000
        }
    }Return

写入ini变量默认值:
    {
        IniWrite, 1363, %IniFile%, 变量, 左容器的右边界
        IniWrite, 3530, %IniFile%, 变量, 右容器的右边界
        IniWrite, 150, %IniFile%, 变量, 射击延迟
        IniWrite, False, %IniFile%, 备份, 只备份存档文件
        IniWrite, C:\Users\Joanthan Wu\AppData\Local\ZERO_Sievert\22202\save_shared_1.dat, %IniFile%, 备份, 需要备份的文件路径
        IniWrite, C:\Users\Joanthan Wu\AppData\Local\ZERO_Sievert, %IniFile%, 备份, 需要备份的文件夹路径
        IniWrite, C:\Users\Joanthan Wu\AppData\Local\ZERO_Sievert, %IniFile%, 备份, 备份文件夹目的路径
        IniWrite, 备份序号档案.ini, %IniFile%, 备份, 备份序号档案
        IniWrite, 备份信息记录档案.txt, %IniFile%, 备份, 备份信息档案名称

        IniWrite, Home, %IniFile%, 快捷键, 备份热键
        IniWrite, e, %IniFile%, 快捷键, 物资统计快捷键
        IniWrite, q, %IniFile%, 快捷键, 人数统计快捷键
        快捷键 := "``"
        IniWrite, %快捷键%, %IniFile%, 快捷键, 清空统计数据
        IniWrite, c, %IniFile%, 快捷键, 移动物品
        IniWrite, Up, %IniFile%, 快捷键, 增加连点延迟
        IniWrite, Down, %IniFile%, 快捷键, 减少连点延迟
        IniWrite, XButton1, %IniFile%, 快捷键, 连点鼠标左键
        IniWrite, y, %IniFile%, 快捷键, 释放Shift快捷键
        IniWrite, True, %IniFile%, 变量, 自动释放Shift状态
    }Return

变量写入ini:
    {
        IniWrite, %左容器的右边界%, %IniFile%, 变量, 左容器的右边界
        IniWrite, %右容器的右边界%, %IniFile%, 变量, 右容器的右边界
        IniWrite, %自动释放Shift状态%, %IniFile%, 变量, 自动释放Shift状态
        IniWrite, %绑定一号武器%, %IniFile%, 变量, 绑定一号武器
        IniWrite, %绑定二号武器%, %IniFile%, 变量, 绑定二号武器
        IniWrite, %正在使用的武器编号%, %IniFile%, 变量, 正在使用的武器编号
    }Return

射击延迟变量写入ini:
    {
        IniWrite, %射击延迟%, %IniFile%, 变量, 射击延迟
    }Return

读取ini变量:
    {
        IniRead, 左容器的右边界, %IniFile%, 变量, 左容器的右边界
        IniRead, 右容器的右边界, %IniFile%, 变量, 右容器的右边界
        IniRead, 射击延迟, %IniFile%, 变量, 射击延迟
        IniRead, 只备份存档文件, %IniFile%, 备份, 只备份存档文件
        IniRead, 需要备份的文件路径, %IniFile%, 备份, 需要备份的文件路径
        IniRead, 需要备份的文件夹路径, %IniFile%, 备份, 需要备份的文件夹路径
        IniRead, 备份文件夹目的路径, %IniFile%, 备份, 备份文件夹目的路径
        IniRead, 备份序号档案, %IniFile%, 备份, 备份序号档案
        IniRead, 备份信息档案名称, %IniFile%, 备份, 备份信息档案名称

        IniRead, 备份热键, %IniFile%, 快捷键, 备份热键
        IniRead, 物资统计快捷键, %IniFile%, 快捷键, 物资统计快捷键
        IniRead, 人数统计快捷键, %IniFile%, 快捷键, 人数统计快捷键
        IniRead, 清空统计数据, %IniFile%, 快捷键, 清空统计数据
        IniRead, 移动物品, %IniFile%, 快捷键, 移动物品
        IniRead, 增加连点延迟, %IniFile%, 快捷键, 增加连点延迟
        IniRead, 减少连点延迟, %IniFile%, 快捷键, 减少连点延迟
        IniRead, 连点鼠标左键, %IniFile%, 快捷键, 连点鼠标左键

        IniRead, 释放Shift快捷键, %IniFile%, 快捷键, 释放Shift快捷键, u
        IniRead, 自动释放Shift状态, %IniFile%, 变量, 自动释放Shift状态, 1
        IniRead, 绑定一号武器, %IniFile%, 变量, 绑定一号武器, 0
        IniRead, 绑定二号武器, %IniFile%, 变量, 绑定二号武器, 0
        IniRead, 正在使用的武器编号, %IniFile%, 变量, 正在使用的武器编号
    }Return

    关闭Hotkey()
    {
        Hotkey, *~Shift, Off
        ; Hotkey, *~Shift Up, Off
        Hotkey, *~Lbutton, Off
        Hotkey, *~Lbutton Up, Off
    }
    开启Hotkey()
    {
        Hotkey, *~Shift, On
        ; Hotkey, *~Shift Up, On
        Hotkey, *~Lbutton, On
        Hotkey, *~Lbutton Up, On
    }