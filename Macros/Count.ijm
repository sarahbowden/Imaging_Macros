inputDir = getDirectory("Choose a folder with images");
sep = File.separator;
maskDir = inputDir + "masks" + sep;
roiDir  = inputDir + "rois"  + sep;
File.makeDirectory(maskDir);
File.makeDirectory(roiDir);

// Process files
list = getFileList(inputDir);
setBatchMode(true);

for (i=0; i<list.length; i++) {
    path = inputDir + list[i];
    if (File.isDirectory(path)) continue;   

    
    base = stripExtension(list[i]);

    open(path);
    origTitle = getTitle();

    // Colour Deconvolution (H DAB)
    run("Colour Deconvolution", "vectors=[H DAB]");

    // Work on Colour_1
    selectWindow(origTitle + "-(Colour_1)");

    // Convert to mask
    setOption("BlackBackground", false);
    run("Convert to Mask");

    // Save mask
    saveAs("Tiff", maskDir + base + "_mask.tif");

    // Analyze particles
    run("Analyze Particles...", "size=30.00-2500.00 circularity=0.00-1.00 show=Overlay display clear summarize overlay add composite");

    // Save per-image ROI set 
	roiManager("Save", roiDir + base + "_RoiSet.zip");

    // Reset
    roiManager("reset");
    close("*");
}

setBatchMode(false);


// ---------- Helper: strip file extension ----------
function stripExtension(name) {
    dot = lastIndexOf(name, ".");
    if (dot==-1) return name;
    return substring(name, 0, dot);
}

// Helper: last index of substring
function lastIndexOf(s, sub) {
    pos = -1; start = 0;
    while (true) {
        idx = indexOf(s, sub, start);
        if (idx==-1) return pos;
        pos = idx; start = idx + 1;
    }
}
