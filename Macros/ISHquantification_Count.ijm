rename("Quant");
run("Colour Deconvolution", "vectors=[H DAB]");
selectImage("Quant-(Colour_1)");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "  show=[Overlay Masks] display clear include summarize overlay")