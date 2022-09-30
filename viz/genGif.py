# python genGif.py <PathNNameOfTheVidToBeGiffed.VideoFormat>
# python genGif.py /../vidTest.mp4
import sys
from moviepy.editor import VideoFileClip
VideoFileClip(sys.argv[1]).write_gif("./out/vidToGif.gif")
# https://www.freecodecamp.org/news/how-to-convert-video-files-to-gif-in-python/