// ImageJ macro by Ana Teresa Lopez Jimenez @ LSHTM


// This macro has been developped and used in the pre-print: 
// High-content superresolution microscopy and deep learning assisted analysis reveals host and bacterial heterogeneity during Shigella infection. Ana T. López-Jiménez, Dominik Brokatzky, Kamla Pillay, Tyrese Williams, Gizem Özbaykal Güler and Serge Mostowy (2024)
 
//--------------------DESCRIPTION--------------------//
// This ImageJ macro segments rod shaped bacteria based on fluorescence, and then saves a square crop of the bacteria with additional channels and the segmented mask.
// This macro is to be used to generate images to train a CNN or to be classified by a trained CNN.
// This macro works on 8 or 16 bits tif images up to 5 channels and with multiple z-slices (stack).
// This macro requires the input from the user of the threshold value to be used for the segmentation. 
// To choose this threshold value we recommend to open an example image containing bacteria and performing autothreshold in ImageJ on the max projection of the channel containing the bacteria using the Otsu method.





//--------------------Selecting the input folder, output folder and image format to be analysed--------------------//

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix





//--------------------Printing date and time for log file--------------------//

function now(){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	nowValue = ""+IJ.pad(hour,2)+":"+IJ.pad(minute,2)+":"+IJ.pad(second,2);
	return nowValue;
}

print("Macro used: imageJ macro_crop");
print("Macro run: " + now());
print("Directory input: " + input);
print("Directory output: " + output);
print("Particles analysed: size=0.6-10 circularity=0.00-1.00")





//--------------------Dialog to retrieve information about the channels--------------------//

Dialog.create("Provide this this information about the image");
Dialog.addString("Channel with fluorescent bacteria (1, 2, 3, 4..?)", "1");
Dialog.addNumber("Threshold (input value of Otsu threshold)", 3000);
Dialog.addNumber("Dimension of the square to be crop around bacteria", 128);
//Dialog.addNumber("Max Threshold: ", 65535);
Dialog.show();


cbacteria=Dialog.getString();
minthreshold = Dialog.getNumber();
dim = Dialog.getNumber();

newcbacteria="C" + cbacteria;
print("bacteria channel selected: " + newcbacteria);
print("Values for threshold: " + minthreshold);
print("Dimension of crops: " + dim);





//--------------------Setting up batch mode to analyse multiple images in the same folder--------------------//

setBatchMode(true); //Set true to avoid display of the processing (faster), set false to display processing

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
open(input + File.separator + file);




//--------------------Automatic retrieval of information about the opened image--------------------//

name = getTitle();
dir = getDirectory("image");
print ("File dir: " + dir);
print ("File name: " + name);
Stack.getDimensions(width, height, channels, slices, frames) ;
print("Channels: "+channels);
chan = channels;
print("Slices: "+slices);
bit = bitDepth();

if (bitDepth() == '8')
	maxthreshold = 255;
	else if (bitDepth() == '16')
	maxthreshold = 65535;
	else 
	print ("bitdepth different from 8 or 16, modify code"); //if bitdepth of image different from 8 or 16, change the maxthreshold here





//--------------------doing a max projection, getting the bacterial mask and ROI set--------------------//
//saving log file 
newname=replace(name, ".tif", "");
run("Duplicate...","duplicate");
run("Set Measurements...", "  redirect=[name] decimal=3");

if(slices >= '1')//creation of the mask
	run("Z Project...", "projection=[Max Intensity]");
	else
	continue;

run("Channels Tool...");
Stack.setDisplayMode("composite");
run("Split Channels");
selectWindow(newcbacteria + "-MAX_" + newname + "-1.tif");
call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
setThreshold(minthreshold, maxthreshold);
run("Make Binary"); //creation of the mask
saveAs("Tiff", output + File.separator + newname + "_mask"); //saving the generated mask
run("Analyze Particles...", "size=0.60-10.00 display exclude clear add"); //if segmented objects different than rod shape bacteria, change these value

if (roiManager("count")>0){
	print("Particles analysed: 0.02-Inf, circularity 0.00-1.00");
	roiManager("Deselect"); 
	roiManager("Save", output +File.separator+ newname + "_ROI set.zip"); //saving the ROI detected
	diroutnew = output+File.separator+"crop"+File.separator; //generate a new folder to save crop images
	File.makeDirectory(diroutnew);

	for (i=0;i<roiManager("count");i++){ 
		selectWindow(newname + "_mask.tif"); 
		run("Duplicate...", "duplicate");
		selectWindow(newname + "_mask-1.tif");
		roiManager("Select", i); 
		run("Make Inverse");
		run("Clear", "slice");
		run("Select None");
		roiManager("Select", i); 
		Roi.getBounds(x, y, width, height);
		print("x= ",x,"y= ",y,"width= ",width,"height= ",height);
		makePoint(x+(width/2), y+(height/2), "central point");
		roiManager("Update");
		Roi.getCoordinates(k, l);
		run("Specify...", "width="+dim+" height="+dim+" x="+k[0]+" y="+l[0]+" centered"); 
		roiManager("Update");
		selectWindow(newname + "_mask-1.tif");
		roiManager("Select", i);
		run("Duplicate...", "duplicate");
		run("Select None");
		rename("Object.tif");
		setOption("BlackBackground", true);
		run("Make Binary");
		run("16-bit");
		selectWindow(newname + "_mask-1.tif");
		close();
		
		widthpic = getWidth();
		heightpic = getHeight();
		if(widthpic == dim){
			if(heightpic == dim){
				selectWindow(newname + ".tif"); 
				run("Z Project...", "projection=[Max Intensity]");
				roiManager("Select", i); 
				run("Duplicate...", "duplicate");
				rename("image.tif");
				
				if (chan == 1){
					selectWindow("image.tif");
					run("Split Channels");
					run("Merge Channels...", "c1=C1-image.tif c2=Object.tif create");
					saveAs("Tiff", diroutnew + File.separator + newname + i +".tif");}	
					
				if (chan == 2){
					selectWindow("image.tif");
					run("Split Channels");
					run("Merge Channels...", "c1=C1-image.tif c2=C2-image.tif c3=Object.tif create");
					saveAs("Tiff", diroutnew + File.separator + newname + i +".tif");}
				
				if (chan == 3){
					selectWindow("image.tif");
					run("Split Channels");
					run("Merge Channels...", "c1=C1-image.tif c2=C2-image.tif c3=C3-image.tif c4=Object.tif create");
					saveAs("Tiff", diroutnew + File.separator + newname + i +".tif");}
				
				if (chan == 4){
					selectWindow("image.tif");
					run("Split Channels");
					run("Merge Channels...", "c1=C1-image.tif c2=C2-image.tif c3=C3-image.tif c4=C4-image.tif c5=Object.tif create");
					saveAs("Tiff", diroutnew + File.separator + newname + i +".tif");}
				
				if (chan == 5){
					selectWindow("image.tif");
					run("Split Channels");
					run("Merge Channels...", "c1=C1-image.tif c2=C2-image.tif c3=C3-image.tif c4=C4-image.tif c5=C5-image.tif c6=Object.tif create");
					saveAs("Tiff", diroutnew + File.separator + newname + i +".tif");}	
			}
			else {close();}
		}
		else {close();}	
	}
	roiManager("Deselect"); 
	roiManager("Save", output + File.separator + newname + "_ROI set_square.zip"); //saving ROI Manager of square positions 
	selectWindow("Log");
	saveAs("Text", output + File.separator + newname +  "Log.txt"); //saving log file 
	print("ROI manager set of square crop saved: " + output + File.separator + newname + "_ROI set_square.zip");
	print("Log file saved: " + output + "Log " + newname + ".txt"); 
	run("Close");
	close('*');
}

else
close('*');

}
