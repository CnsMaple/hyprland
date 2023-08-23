swaylock  --screenshots  --clock --timestr=%H:%M:%S --datestr=%Y-%m-%d  --indicator  --indicator-radius 100  --indicator-thickness 7  --effect-blur 7x5  --effect-vignette 0.5:0.5  --ring-color b5b5b5  --key-hl-color 3cdec3  --line-color 00000000  --inside-color 00000088  --separator-color 00000000  --grace 0  --fade-in 0.5 &

sleep 2

notify-send "Lock time" "$(date +'%H:%M:%S')" &
