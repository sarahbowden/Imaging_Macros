# Imaging_Macros
Macros for processing images in FIJI

## How To
- Save macro with extension .ijm
- Select a region of interest (ROI) from an imaged WMISH embryo
  - For most accurate results it is important to keep ROI selection size consistent across all embryos in analysis
- Quantify a set (biological replicates of a single condition) at once (Process > Batch > Macro)
- or individual images (Plugins > Macros > Run...)
- Copy from the results table "% Area" (ISHquantification_Area) or "Count" (ISHquantification_Count) to quantify

### **Important note**
- I always create a Results folder for each batch processing analysis, and then I check that the black mask covers the stained regions.
- Convert to Mask is a binary process and black is selected as the smallest coverage. If images have more staining than background, this may be flipped.
- If this is the case I either manually perform these steps to ensure the correct region is covered (you can use Image > Adjust > Threshold..., or invert the ROI).
- In theory, if the whole batch needs to be inverted, you can add an inversion line to the macro prior to Convert to Mask.

- ISHquantification_Count has an additional Watershedding step to deconvolute doublets/triplets. This can be useful when staining has very clear punctae, but often has a risk of mis-representing the area.
  - Mainly useful when a manipulation does not change the area of staining but instead changes the size and number of cells.


## Step-by-step process
1. Renames each file to make downstream processes simpler
2. Colour Deconvolution to identify BM-stained tissue / eliminate background colours
3. Selects purple (BM-stained) channel
4. Prevents FIJI from assumption background = dark
5. Creates a mask based on differences between staining and background
6. _(only on ISHquantification_count)_ Generates gaps between individual punctae in cases of doublets/triplets etc
7. Analyses particles; counts number of punctae/regions, and calculates area covered by black mask
