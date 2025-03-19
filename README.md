# Imaging_Macros
Macros for processing images in FIJI

## How To
- Save macro with extension .ijm
- Select a region of interest (ROI) from an imaged WMISH embryo
  - For most accurate results it is important to keep ROI selection size consistent across all embryos in analysis
- Quantify a set (biological replicates of a single condition) at once (Process > Batch > Macro)
- or individual images (Plugins > Macros > Run...)
- Copy from the results table "% Area" (ISH_Area) or "Count" (ISH_Punctae) to quantify

### **Important**
- I always create a Results folder for each batch processing analysis, and then I check that the black mask covers the stained regions.
- *Convert to Mask* is a binary process and black is selected as the smallest coverage. If images have more staining than background, this may be flipped.
- If this is the case I either manually perform these steps to ensure the correct region is covered (you can use Image > Adjust > Threshold..., or invert the ROI).
- In theory, if the whole batch needs to be inverted, you can add an inversion line to the macro prior to Convert to Mask.
