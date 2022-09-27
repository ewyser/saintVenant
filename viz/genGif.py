import sys
from moviepy.editor import VideoFileClip
VideoFileClip(sys.argv[1]).write_gif("vidToGif.gif")
# https://www.freecodecamp.org/news/how-to-convert-video-files-to-gif-in-python/
# python genGif.py <PathNNameOfTheVidToBeGiffed>