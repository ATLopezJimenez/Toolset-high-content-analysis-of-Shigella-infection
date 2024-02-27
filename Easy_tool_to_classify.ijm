// ImageJ macro by Ana Teresa Lopez Jimenez @ LSHTM

// This macro has been developped and used in the pre-print: 
// High-content high-resolution microscopy and deep learning assisted analysis reveals host and bacterial heterogeneity during Shigella infection. Ana T. López-Jiménez, Dominik Brokatzky, Kamla Pillay, Tyrese Williams, Gizem Özbaykal Güler and Serge Mostowy (2024)
 
//--------------------DESCRIPTION--------------------//
// This ImageJ macro can be used to easily annotate a dataset to be trained by a CNN.
// Images retrieved from a folder are automatic sorted in different folders according by the numeric classification provided by the user.
// This macro is optimized for a binary classification but can be modified to accomodate more categories.



//--------------------Selecting the input folder and image format to be analysed--------------------//

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix





//--------------------Description of the classification task--------------------//

Dialog.create("Provide this information");
Dialog.addString("Name of the first category: ", "negatives");
Dialog.addString("Name of the first category: ", "positives");
Dialog.addString("Channel number for fluorescent bacteria (1, 2, 3, 4..?)", "2");
Dialog.addString("Channel number for recruited protein (1, 2, 3, 4..?)", "3"); 
Dialog.show();

cat1name=Dialog.getString();
cat2name=Dialog.getString();
cbacteria=Dialog.getString();
cprot=Dialog.getString();


Dialog.create("Next, provide the directory to store images belonging to the first category");
Dialog.show();
path_firstcat = getDirectory("Choose a directory to store first category");


Dialog.create("Next, provide the directory to store images belonging to the second category");
Dialog.show();
path_secondcat = getDirectory("Choose a directory to store second category");

newcbacteria="C" + cbacteria;
newcprot="C" + cprot;

print("bacteria channel: " + newcbacteria);
print("recruited protein channel: " + newcprot);
print (cat1name + " will be sorted in " + path_firstcat);
print (cat2name + " will be sorted in " + path_secondcat);





//--------------------Setting up batch mode to analyse multiple images in the same folder--------------------//

setBatchMode(false); //Needs to be set in false so images are displayed to be sorted
processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
open(input + File.separator + file);





//--------------------Automatic retrieval of information about the opened image--------------------//

name = getTitle();
dir = getDirectory("image");
print ("File dir: " + dir);
print ("File name: " + name);
newname=replace(name, ".tif", "");
Stack.getDimensions(width, height, channels, slices, frames);
chan = channels;
cmask=chan;
newcmask="C" + cmask;





//--------------------Display of image as a montage--------------------//

run("Duplicate...", "duplicate");
run("Split Channels");
selectWindow(newcbacteria + "-" + newname + "-1.tif");
run("Red");
run("Enhance Contrast", "saturated=0.35");
selectWindow(newcprot + "-" + newname + "-1.tif");
run("Green");
run("Enhance Contrast", "saturated=0.35");
run("Merge Channels...", "c1=["+ newcbacteria + "-" + newname + "-1.tif"+"] c2=["+ newcprot + "-" + newname + "-1.tif"+"] create keep");
run("RGB Color");
selectWindow("Composite");
close();
selectWindow(newcbacteria + "-" + newname + "-1.tif");
run("RGB Color");
selectWindow(newcprot + "-" + newname + "-1.tif");
run("RGB Color");
selectWindow(newcmask + "-" + newname + "-1.tif");
run("RGB Color");
run("Combine...", "stack1=["+ newcmask + "-" + newname + "-1.tif"+"] stack2=[Composite (RGB)]");
run("Combine...", "stack1=[Combined Stacks] stack2=["+ newcbacteria + "-" + newname + "-1.tif"+"]");
run("Combine...", "stack1=[Combined Stacks] stack2=["+ newcprot + "-" + newname + "-1.tif"+"]");





//--------------------Ask input to the user--------------------//
Dialog.create("To which category does this item belong to?");
message = cat1name + " (0), " + cat2name + " (1)";
Dialog.addString( message, "0");
Dialog.show();
x=Dialog.getString();




//--------------------Sort classified images in indicated folders--------------------//
if (x == "0"){
	selectWindow(name);
	saveAs("Tiff", path_firstcat + name);}
if (x == "1"){
	selectWindow(name);
	saveAs("Tiff", path_secondcat + name);}
else {
	continue;}

close(*);
}
