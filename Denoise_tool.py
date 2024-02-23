#------------------------------GENERAL INFORMATION------------------------------#

# This code was developed by Ana T. López Jiménez and Gizem Özbaykal Güler @ LSHTM.
# This code has been developped and used in the pre-print:
# High-content superresolution microscopy and deep learning assisted analysis reveals host and bacterial heterogeneity during Shigella infection.
# Ana T. López-Jiménez, Dominik Brokatzky, Kamla Pillay, Tyrese Williams, Gizem Özbaykal Güler and Serge Mostowy (2024)





#------------------------------ DESCRIPTION------------------------------#

# This code does a band pass filtering on images obtained with the "Segmentation_bacteria_square_crop" ImageJ macro.
# Input required by the user is required in lines 64-66 to define the channels.
# Parameters on the band pass filtering can be modified according to the image characteristics.
# Output of this code is composed by 3 channels x 32 bit images containing the bacteria channel, the channel of the recruited protein of interest, and the bacterial mask.





#------------------------------ IMPORT OF PACKAGES------------------------------#

import os
import numpy as np
import cv2
import imageio
from os import listdir
from scipy import ndimage, misc, fftpack, signal
from matplotlib import pyplot as plt
from PIL import Image, ImageFilter
from skimage import io





#------------------------------DEFINTION OF THE GAUSSIAN FILTER------------------------------#

def matlab_style_gauss2D(shape=(3,3),sigma=0.5): #defining Gaussian filter
    m,n = [(ss-1.)/2. for ss in shape]
    y,x = np.ogrid[-m:m+1,-n:n+1]
    h = np.exp( -(x*x + y*y) / (2.*sigma*sigma) )
    h[ h < np.finfo(h.dtype).eps*h.max() ] = 0
    sumh = h.sum()
    if sumh != 0:
        h /= sumh
    return h





#------------------------------DEFINING IMAGE CHANNELS------------------------------#

IMAGE_PATH = os.getcwd()
newfolder = os.path.join(IMAGE_PATH, "denoised")
os.makedirs(newfolder)
for image in os.listdir(IMAGE_PATH):
    tifname=os.path.basename(image)
    print("Images_analysed: ", tifname)
    if ".tif" in tifname:
        im = io.imread(image)
        mask = im[4] #Define number channel of segmentation mask here (first channel = 0)
        gfp_img = im[2] #Define number channel of recruited protein here
        bact = im[1] #Define number of bacterial channel here
        ObjSize= 2*30 +1





#------------------------------APPLICATION OF THE FILTERS------------------------------#

        GaussFilt = matlab_style_gauss2D(shape=(9,9),sigma=0.5) # Gaussian filter with a size 9 and sigma 0.5.
        img_fg = signal.fftconvolve(gfp_img, GaussFilt, mode='same')
        kernel = np.ones((ObjSize,1),np.float32) / (ObjSize*ObjSize) # Mean filter with a size 1. Increase for larger objects.
        img_fb = cv2.filter2D(gfp_img,-1,kernel)
        img_f = img_fg - img_fb # Substraction of Mean filter to Gaussian filter





#------------------------------MERGE DENOISED IMAGE WITH OTHER CHANNELS AND SAVE------------------------------#

        image_merge = np.dstack((bact, img_f, mask))
        transformed_image = os.path.join(newfolder, tifname) # creation of new folder
        imageio.imwrite(transformed_image, image_merge) # save images
    else:
        continue
