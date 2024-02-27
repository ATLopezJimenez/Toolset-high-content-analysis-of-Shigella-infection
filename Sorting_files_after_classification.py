#------------------------------GENERAL INFORMATION------------------------------#

# This code was developed by Ana T. López Jiménez @ LSHTM.
# This code has been developped and used in the pre-print:
# High-content high-resolution microscopy and deep learning assisted analysis reveals host and bacterial heterogeneity during Shigella infection.
# Ana T. López-Jiménez, Dominik Brokatzky, Kamla Pillay, Tyrese Williams, Gizem Özbaykal Güler and Serge Mostowy (2024)





#------------------------------ DESCRIPTION------------------------------#

# This code sorts images contained in the same folder as this python code into two folders, "single" and "clump", or alternatively "SEPT7+" and SEPT7-".
# Sorting occurs according to the .txt classification results obtained with the trained models "model_classification_single_vs_clump.hdf5" or "model_classification_SEPT7positive_vs_negative.hdf5"
# The .txt document with the result needs to be located in the same folder as this python code and images to be analysed.
# Line 64 and 66 can be modified so the recipient folders are named appropriately.




#------------------------------ IMPORT OF PACKAGES------------------------------#

import os
from os import listdir
from shutil import copyfile






#------------------------------USER INPUT FOR .txt FILE TO BE USED (CLASSIFICATION RESULTS)------------------------------#

name = input("Enter file:")
if len(name) < 1 : name = "text.txt" # default name by pressing enter
handle = open(name) # treats the file as a file





#------------------------------RETRIEVING INFORMATION FROM .txt FILE------------------------------#

picture_prediction=dict() # create a dictionary with the name of the files and the predictions
for line in handle:
    line=line.rstrip()
    if "tif" in line:
        picture = line[(line.index("/")+1):line.index(".tif")]+'.tif'
        prediction = line[(line.index(".tif")+5):]
        picture_prediction.update({picture : prediction})
    else:
        continue
#print(picture_prediction)





#------------------------------CREATING RECEPIENT FOLDERS AND SORTING------------------------------#

cwd = os.getcwd() # gets the current and new directory

zerocwd = os.path.join(cwd, "single") #alternatively, if classifying SEPT+ vs SEPT-, change "single" for "SEPT7_positive"
os.makedirs(zerocwd)
onecwd = os.path.join(cwd, "clump") #alternatively, if classifying SEPT+ vs SEPT-, change "clump" for "SEPT7_negative"
os.makedirs(onecwd)

total_files = os.listdir(cwd) #gets the files within the folder
print(total_files)

for file in total_files:
    print('These are all the files:', file)
    if file in picture_prediction:
        print ('This file matches the dictionary', file)
        pred = picture_prediction.get(file)
        print('prediction is', pred)
        match = True

    else:
        print ('This file does NOT match the dictionary', file)
        match = False

    if match:
        print ('hurray')
        if pred == "0":
            olddir = os.path.join(cwd, file)
            newdir = os.path.join(zerocwd, file)
            copyfile(olddir, newdir)
        if pred == "1":
            olddir = os.path.join(cwd, file)
            newdir = os.path.join(onecwd, file)
            copyfile(olddir, newdir)
