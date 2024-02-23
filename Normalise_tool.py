#------------------------------GENERAL INFORMATION------------------------------#

# This code was developed by Ana T. López Jiménez and Gizem Özbaykal Güler @ LSHTM.
# This code has been developped and used in the pre-print:
# High-content superresolution microscopy and deep learning assisted analysis reveals host and bacterial heterogeneity during Shigella infection.
# Ana T. López-Jiménez, Dominik Brokatzky, Kamla Pillay, Tyrese Williams, Gizem Özbaykal Güler and Serge Mostowy (2024)





#------------------------------DESCRIPTION------------------------------#

# This code normalises the fluorescence of the protein of interest recruited to the bacteria to enable comparison from different batches or experiments.
# Input images are the 32 bit 3 channel images generated by the python code: Denoise_tool.py
# Output images are 8 bit RGB images for training a CNN or to be classified by the trained "model_classification_SEPT7positive_vs_negative.hdf5"
# Input required by the user is required in lines 63-65 to define the channels.





#------------------------------IMPORT OF PACKAGES------------------------------#

import os
import numpy as np
import cv2
import imageio
from os import listdir
from scipy import ndimage, misc, fftpack, signal
from matplotlib import pyplot as plt
from PIL import Image, ImageFilter
from skimage import io





#------------------------------DEFINE THE NORMALISATION FUNCTION------------------------------#

def normalise (m):
    im = io.imread(image)
    print(im.shape)
    bact = im[:,:,0]
    gfp_img = im[:,:,1]
    im_blue = im[:,:,2]
    im2 = gfp_img/m #m is max value of pixel in dataset after noise removal
    im3 = im2*255
    im4 = np.around(im3, decimals=0)
    im5 = np.uint8(im4)
    bact_max = np.amax(bact)
    bact2 = bact/bact_max
    bact3 = bact2*255
    bact4 = np.uint8 (bact3)
    im_blue2 = np.uint8 (im_blue)
    image_merge = np.dstack((bact4, im5, im_blue2))
    transformed_image = os.path.join(newfolder, tifname)
    imageio.imwrite(transformed_image, image_merge)





#------------------------------APPLY THE NORMALISATION FUNCTION------------------------------#

IMAGE_PATH = os.getcwd()
newfolder = os.path.join(IMAGE_PATH, "normalised") # Creation of the output folder
os.makedirs(newfolder)
for image in os.listdir(IMAGE_PATH):
    tifname=os.path.basename(image)
    print("Images_analysed: ", tifname)
    if "tif" in tifname:
        m=1 # Input required from the user: input the max fluorescence value from the dataset after noise removal, obtained with the ImageJ macro "Dataset_parameters.ijm"
        apply_function =normalise (m)
        
    else:
        continue