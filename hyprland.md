

# 主体安装

最快：

安装：`sudo pacman -S hyprland gtk3`

启动：`Hyprland`

一些软件需要更多的依赖，不过有一些在安装hyprland的时候就会被安装，下面是一些常见的：

```bash
sudo pacman -S xorg-xwayland qt5-wayland qt6-wayland glfw-wayland xdg-desktop-portal-hyprland
```

参考：

[Hyprland 安装配置|缩放模糊|输入法](https://www.bilibili.com/read/cv24967541/)

[HiDPI(高分屏) Hyprland 安装配置](https://www.bilibili.com/read/cv24998287?from=articleDetail)

[ArchLinux下Hyprland配置指北 ](https://www.bilibili.com/read/cv22707313/)

# 包管理器

参考：[paru安装和简单使用](https://zhuanlan.zhihu.com/p/350920414)

参考：[包空间清理](https://yangsihan.com/article/2023/01/28/105/)

目前主要使用paru，yay只是为了一个过渡。

```text
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

提示：清理需谨慎！！！

一、清理安装包缓存

`sudo pacman -Scc`

`paru -Scc `

`yay -Scc`

不仅会删除未安装或旧版本的包文件缓存，也会将安装着的包的包文件缓存也一并删除。

二、清理孤立的软件包

`sudo pacman -Rns $(pacman -Qtdq)`

就可以删除孤立的软件包。什么是孤立的软件包呢？比如我想要吃西餐，我需要买刀叉。刀叉即西餐的一个依赖，西餐依赖于刀叉。如果我再也不想要吃西餐了，那么已经买来的刀叉也没用了。这个刀叉即孤立的软件包。既然用不上了，那么可以删掉

三、清理日志（可选）

`journalctl --vacuum-size=50M`

可以限制日志记录大小在50M，我使用一年没清理过，日志记录大概在2G左右。设置了固定大小为50M后，多的日志就会被删掉。

# 缩放/模糊的问题

由于linux的桌面都是不怎么支持缩放的，最好是把桌面的缩放设置成1，然后再对每个框架进行设置，不然会非常的模糊。

先用`hyprctl monitors`查看当前打开的所有窗口的`scale`，只要scale不为1，xwayland下的程序会糊，wayland的应用可能也会稍微糊一点，因为wayland不支持非整数缩放，此时统一把hyprland.conf中的scale调整为1，也就是monitor的最后一个参数，例如monitor=，preferred，auto，1

如何查看是否在xwayland下运行，用`hyprctl clients`查看，如果是`xwayland:1`的则是在xwayland下运行的。不糊的并且大小合适的不用看下面调整的步骤。

1. xwayland配置：安装`xorg-xrdb`，通过此命令调整dpi到合适的值(每调一次打开一次xwayland的应用查看是否合适)，`echo 'Xft.dpi: 144' | xrdb -merge `(一倍缩放dpi为96，在此基础上加，1.5倍为144)，调整好后，在配置文件中添加`exec-once = echo 'Xft.dpi: 144' | xrdb -merge`，此时xwayland的显示问题解决了。

2. wayland 配置(不同框架下的应用配置不同):

一般设置gtk3和qt就好。

gtk3(安装dconf,dconf-editor): 
设置dconf-editor (这是一个桌面应用)的/org/gnome/desktop/interface/text-scaling-factor 改字体缩放， /org/gnome/desktop/interface/scaling-factor 改界面缩放(貌似没用)，鼠标的大小也要单独设置，就在同一个父级下。

QT: 

```bash
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_WAYLAND_FORCE_DPI=144
```

比如OBS必须在wayalnd下运行：Hyprland must use `exec Hyprland` to run

electron: 

运行electron时加参数`--force-device-scale-factor`，有输入法和显示bug(建议electron在xwayland下运行，默认是在xwayland下运行)

其他： 像waybar这种就调一下字体大小就行

详情参考: [dpi设置](https://wiki.archlinux.org/title/HiDPI#GUI_toolkits) 

# 中文输入法

`paru -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-chinese-addons fcitx5-pinyin-zhwiki`

在.bashrc中添加：

```bash
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export SDL_IM_MODULE=fcitx5
export XMODIFIERS="@im=fcitx5" 
export GLFW_IM_MODULE=ibus
```

在 hyprland 中启动：

```conf
exec-once=fcitx5 --replace -d
```

输入法也要设置一下dpi，下面是图形界面的步骤：

1. fcitx5 ->Addons -> Classic User Interface -> 勾上 Use Per Screen DPI
2. fcitx5 ->Addons -> Classic User Interface -> Force Font DPI on Wayland 设置为 144

# 复制与粘贴

剪切板管理工具也经常用到，wayland下可以使用**clipman（只能管理文字）或cliphist（文字加图片）**：

基本安装：`paru -S cliphist wl-clipboard`

基本使用：

```bash
# 拷贝
echo "Hello World" | wl-copy
# 粘贴
wl-paste
# 复制了太多东西可以清空一下剪切板
cliphist wipe
```

在配置文件里启用：

```conf
# 这个会自动监控剪切板，然后将复制的内容保存到本地数据库中。
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# 在一个软件内复制，这软件关闭后无法进行历史粘贴，需要配置快捷键显示剪切板历史，需要注意的是rofi是软件启动器，需要额外安装。
bind = SUPER_SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
```


# 软件启动器

桌面环境下，我们可以点击桌面图标和软件菜单启动程序，wayland窗口管理器下一般使用bmenu或者rofi，rofi更加美观，推荐使用，安装：`paru -S rofi`，如果无法正常工作，那就使用经过修复的rofi，使用AUR安装：`paru -S rofi-lbonn-wayland-only-git`。其配置文件位于`~/.config/rofi/`目录下，美化不进行介绍，可以参考waybar方法在Github上查找。

在hyprland配置文件中绑定快捷键即可：

```conf
bind = $mainMod, R, exec, rofi -show drun
```

# 配置顶栏

这个顶栏很好理解，用来显示系统的一些信息，比如工作区、网络、声音、亮度、电量、系统托盘等。wayland 下可以使用waybar，支持很多模块显示，不过官方版本对 Hyprland 的工作区有点问题，建议安装 AUR 上对工作区进行修复的版本：

```bash
# 安装官方版本（不推荐）
sudo pacman -S waybar
# 安装Hyprland工作区修复版本
paru -S waybar-hyprland-git
```

waybar配置文件在`~/.config/waybar`目录下的config.json和style.css文件，如果自己不会配置可以在Github上搜索waybar theme使用别人配置好的，篇幅原因这里不进行介绍。

配置文件弄好后还需要在Hypeland配置文件中启动：`exec-once = waybar`。

Discord 社群的chat中有rice-fields，有别人分享自己好看的配置，一般也会附上github链接

> https://discord.com/invite/hQ9XvMUjjr

# 字体推荐  

字体我这里推荐**Maple**，一个中文编程字体。

效果一般：

```bash
# nerd字体
paru -S ttf-jetbrains-mono-nerd
# 一些图标
paru -S ttf-material-design-icons-git
# emoji表情
paru -S ttf-joypixels
# 中文字体
paru -S wqy-microhei
```

推荐：

```bash
# 中文+nerd+emoji
# 缺一不可
paru -S ttf-maple
paru -S nerd-fonts-sarasa-term
paru -S ttf-apple-emoji
```

参考：[字体arch wiki](https://wiki.archlinuxcn.org/wiki/%E5%AD%97%E4%BD%93)

参考：[emoji的讨论](https://github.com/fkxxyz/rime-cloverpinyin/issues/43)

参考：[apple-emoji](https://github.com/samuelngs/apple-emoji-linux)

参考：[noto-emoji](https://github.com/googlefonts/noto-emoji)

# 配置壁纸

安装swww：`paru -S swww`

简单使用：

```bash
swww init
swww img /home/xxx/wallpaper/p1.jpg
```

如果在hyprland的配置文件中写这两个到exec-once中，可能会启动失败，这两个是有启动顺序的，最好是写在一个脚本里面，然后在hyprland.conf中的exec-once写上脚本的路径。

# 通知守护程序

平时使用，接收通知是必须的，wayland下可以使用**dunst、mako**等守护程序：

这里使用mako：`sudo pacman -S mako`

hyprland配置：

```bash
exec-once = mako
```

如果需要使用命令行发送通知，使用`notify-send 'Hello world!' 'This is an example notification.' -u normal`可以发送通知。

# 截屏与录屏

如果需要进行屏幕录制或者直播，pipewire 是必须的：
`paru -S pipewire wireplumber slurp grim swappy obs-studio`
**grim**可以截取屏幕，**slurp**可以选择一块区域，两者配合可以进行区域截图，在配合swappy进行编辑，swappy可以悬浮。

```bash
bind = $mainMod, S, exec, grim -g "$(slurp)" - | swappy -f - # take a screenshot
```

录屏可以使用 **obs-studio** 。其中obs-studio需要`qt6-wayland`和`xdg-desktop-portal-hyprland`。然后在配置中设置：

```conf
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```

然后重启就可以了。
在obs中选择`屏幕采集(PipeWire)`

参考：[Screen sharing on Hyprland](https://gist.github.com/PowerBall253/2dea6ddf6974ba4e5d26c3139ffb7580)

# 用户认证软件

很多时候我们打开软件都不需要root权限，不过有些特殊的软件需要使用root权限，不过在桌面启动时无法认证并获得权限，这就需要一个图形化的认证程序，KDE旗下的**polkit-kde-agent**是个不错的选择：

安装：`paru -S polkit-kde-agent`

基本使用：

hyprland 配置文件内：

```bash
exec-once = /usr/lib/polkit-kde-authentication-agent-1
# 使用体验，对认证程序采用浮动窗口
windowrulev2 = float, class:^(.*polkit-kde.*)$
```

# 移动磁盘挂载

Linux下可移动磁盘不会自动挂载，特别是在窗口管理器环境下。使用**udiskie**可以自动进行挂载，非常方便：

```bash
paru -S udiskie
# 配置文件内启用
exec-once = udiskie &
```

# 使用蓝牙

安装：`paru -S bluez bluez-utils blueman`

启动bluez服务：

```bash
sudo systemctl start bluetooth
sudo systemctl enable bluetooth
```

blueman的使用：blueman-manager
也可以点击ui图标。

```conf
# 蓝牙自启动
exec-once = blueman-applet
```

想要自动连接，需要在界面中将设备设置为信任设备，然后就会自动连接了。

# 临时锁屏

安装：[swaylock-effiecs](https://github.com/mortie/swaylock-effects)

注意，可能会误装（不同的源可能会出现重名的，尽量使用官方的）：
> I believe you're all using jirutka's fork of swaylock-effects ([https://github.com/jirutka/swaylock-effects](https://github.com/jirutka/swaylock-effects)), that's what the AUR package has been changed to these days. There is no 1.6.10 version in this repo.

```bash
maple@archlinux ~ [1]> paru -Ss swaylock-effects
archlinuxcn/swaylock-effects 1.6.10-1 [0B 117.38KiB]
    A fancier screen locker for Wayland.
aur/swaylock-effects-git r402.9ac172a-1 [+32 ~0.65]
    A fancier screen locker for Wayland.
aur/swaylock-effects 1.6.4-1 [+13 ~0.43]
    A fancier screen locker for Wayland.
maple@archlinux ~> 
```

使用：paru -s aur/swaylock-effects

然后：

```conf
bind = $mainMod, L, exec, swaylock  --screenshots  --clock  --indicator  --indicator-radius 100  --indicator-thickness 7  --effect-blur 7x5  --effect-vignette 0.5:0.5  --ring-color bb00cc  --key-hl-color 880033  --line-color 00000000  --inside-color 00000088  --separator-color 00000000  --grace 2  --fade-in 0.2
```

# 文件管理

使用thunar，这个比较好看：

```bash
paru -S thunar

# conf
bind = $mainMod, E, exec, thunar # Show the graphical file browser
```

# 文件查看

图片查看：ristretto

视频查看：mpv

`paru -S ristretto mpv`

在文件管理器可以直接双击文件查看，如果没有那就看看默认打开文件的应用有没有设置成这两个。

# wifi管理

在装archlinux的时候一般都会装了networkmanage

tip：如果有了networkmanage，直接`paru -S network-manager-applet`就可以了，然后：`exec-once = nm-applet --indicator`，结束

参考：[网络最小适配器](https://unix.stackexchange.com/questions/292195/install-network-manager-applet-tray-icon-on-arch-linux-gnome-3-20)

如果啥都没有，或者出了什么问题，从头开始看/检查：

安装 wpa_supplicant 工具

```bash
sudo pacman -S wpa_supplicant
```

安装无线工具：

```bash
sudo pacman -S wireless_tools
```

安装网络管理器：

```bash
sudo pacman -S networkmanager
```

安装网络管理器小程序，又名 nm-applet：

```bash
sudo pacman -S network-manager-applet
```

让网络管理器在启动时启动：

```bash
sudo systemctl enable NetworkManager.service
```

禁用 dhcpcd：

由于 Networkmanager 希望成为处理 dhcpcd 相关内容的人，因此您必须禁用并停止 dhcpcd：

```bash
sudo systemctl disable dhcpcd.service
sudo systemctl disable dhcpcd@.service
sudo systemctl stop dhcpcd.service
sudo systemctl stop dhcpcd@.service
```

如果您想使用无线连接，请启用 wpa_supplicant：

```bash
sudo systemctl enable wpa_supplicant.service
```

将您的用户添加到网络组：

```bash
gpasswd -a <USERNAME> network
```

关闭网络接口控制器：

关闭网络接口控制器，在我的例子中是 eth0 和 wlan0：

```bash
ip link set down eth0
ip link set down wlan0
```

现在启动wpa_supplicant：

```bash
sudo systemctl start wpa_supplicant.service
```

现在启动网络管理器：

```bash
sudo systemctl start NetworkManager.service
```

# 设置用户登陆界面

使用sddm

安装：`paru -S sddm-git`

开启服务就可以了：

```bash
sudo systemctl enable sddm
sudo systemctl start sddm
```

注意：使用sddm后，export的变量，都要在hyprland的配置文件中设置（env），参考：[hyprland wiki env](https://wiki.hyprland.org/Configuring/Environment-variables/)

# 设置用户图标

将图片放在家目录下即可，然后命名为`.face.icon`，后缀就是icon，可以使用png/jpg改名字，比如：`maple.png -> .face.icon`。

给sddm可以访问的权限就好。

```bash
setfacl -m u:sddm:x ~/
setfacl -m u:sddm:r ~/.face.icon
```

重启sddm：`sudo systemctl restart sddm`，有时候需要重启电脑。

推荐一个主题：[sddm主题](https://github.com/aczw/sddm-theme-corners)

参考：[arch user icon](https://wiki.archlinux.org/title/SDDM#User_icon_(avatar))

# 安装virtualbox（可选）

```bash
sudo pacman -S linux-headers
sudo pacman -S virtualbox
# 选择 1 virtualbox-host-dkms
sudo pacman -S virtualbox-guest-iso
```

不知道有没有作用的指令：

```bash
sudo dkms autoinstall
sudo modprobe vboxdrv
```

一些问题：

1. Failed to enumerate host USB devices.
VirtualBox is not currently allowed to access USB devices. You can change this by adding your user to the 'vboxusers' group. Please see the user manual for a more detailed explanation.

解决：

```bash
sudo usermod -a -G vboxusers $USER
# 查看一下有没有添加成功
groups $USER
```

# 内存查看器（可选）

安装：`paru -S btop`

使用命令启动：btop
