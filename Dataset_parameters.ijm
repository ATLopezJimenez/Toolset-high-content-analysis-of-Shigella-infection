// ImageJ macro by Ana Teresa Lopez Jimenez @ LSHTM

// This macro has been developped and used in the pre-print: 
// High-content high-resolution microscopy and deep learning assisted analysis reveals host and bacterial heterogeneity during Shigella infection. Ana T. López-Jiménez, Dominik Brokatzky, Kamla Pillay, Tyrese Williams, Gizem Özbaykal Güler and Serge Mostowy (2024)
 
//--------------------DESCRIPTION--------------------//
// This ImageJ macro analyses the denoised images obtained after processing with the Python "Denoise_tool.py" 
// This macro provides the user with the maximum value of intensity of the dataset to use in normalisation with "Normalise_tool.py"
// This macro can be used to assess other parameters of the dataset such as the intensity mean or Std.





//--------------------Selecting the input folder and image format to be analysed--------------------//

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix



//--------------------Setting up batch mode to analyse multiple images in the same folder--------------------//

setBatchMode(true)//Set true to avoid display of the processing (faster), set false to display processing

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
run("Bio-Formats Windowless Importer", "open=[" + input + File.separator + file +"]"); 





//--------------------Automatic retrieval of information about the opened image--------------------//

name = getTitle();
dir = getDirectory("image");
cbact= "1";
cprot= "2";
cmask= "3";
newname=replace(name, ".tif", "");
newcbact="C" + cbact;
newcprot="C" + cprot;
newcmask="C" + cmask;





//--------------------Measurements--------------------//

run("Split Channels");
run("Set Measurements...", "mean min display redirect=["+ newcprot + "-" + newname + ".tif"+"]");
run("Measure");
}





//--------------------Calculating the max value of the dataset--------------------//

maxArray = newArray(nResults);

for ( i=0; i<nResults; i++ ) { 
	maxArray[i] = getResult("Max", i);
}

values = Array.getStatistics(maxArray, min, max, mean, stdDev);
print("Max value of dataset is: ", max);

