"""Draws the launcher icon, Play Store icon and feature graphic."""
import os, sys
from PIL import Image, ImageDraw, ImageFont

COBALT=(47,73,245); WHITE=(255,255,255); ORANGE=(232,83,28); INK=(20,24,48); GREEN=(15,138,95)
BOLD="/usr/share/fonts/truetype/google-fonts/Poppins-Bold.ttf"
root=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def icon(size=1024):
    s=4; S=size*s
    im=Image.new("RGB",(S,S),COBALT); d=ImageDraw.Draw(im)
    # speech bubble
    x0,y0,x1,y1=int(S*.20),int(S*.22),int(S*.80),int(S*.70)
    d.rounded_rectangle((x0,y0,x1,y1),radius=int(S*.12),fill=WHITE)
    d.polygon([(int(S*.33),y1-5),(int(S*.30),int(S*.82)),(int(S*.47),y1-5)],fill=WHITE)
    f=ImageFont.truetype(BOLD,int(S*.40))
    d.text(((x0+x1)//2,(y0+y1)//2+int(S*.02)),"?",font=f,fill=ORANGE,anchor="mm")
    # small green "human" dot
    r=int(S*.07); cx,cy=int(S*.78),int(S*.24)
    d.ellipse((cx-r,cy-r,cx+r,cy+r),fill=GREEN,outline=COBALT,width=int(S*.02))
    return im.resize((size,size),Image.LANCZOS)

big=icon(1024)
os.makedirs(f"{root}/branding/store",exist_ok=True)
big.resize((512,512),Image.LANCZOS).save(f"{root}/branding/store/icon-512.png")
for name,px in {"mdpi":48,"hdpi":72,"xhdpi":96,"xxhdpi":144,"xxxhdpi":192}.items():
    p=f"{root}/branding/android/mipmap-{name}"; os.makedirs(p,exist_ok=True)
    big.resize((px,px),Image.LANCZOS).save(f"{p}/ic_launcher.png")

# feature graphic 1024x500
W,H=1024,500
fg=Image.new("RGB",(W,H),COBALT); d=ImageDraw.Draw(fg)
ic=icon(300); fg.paste(ic,(W-300-70,100))
d.text((70,150),"Human or AI?",font=ImageFont.truetype(BOLD,78),fill=WHITE,anchor="lm")
d.text((72,245),"Two answers are bots.",font=ImageFont.truetype(BOLD,40),fill=(205,212,255),anchor="lm")
d.text((72,300),"Find the human.",font=ImageFont.truetype(BOLD,40),fill=WHITE,anchor="lm")
d.text((72,380),"Pass-and-play party game",font=ImageFont.truetype(BOLD,26),fill=(205,212,255),anchor="lm")
fg.save(f"{root}/branding/store/feature-graphic-1024x500.png")
print("ok")
