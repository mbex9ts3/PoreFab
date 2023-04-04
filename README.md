# PoreFab
PoreFab is an open-source GUI application (written in MATLAB code) for the generation of micro-fabricated transparent models of porous media (micromodels) from raster image datasets using optically transparent 3D polymer additive manufacturing (3D printing).

![GUI](https://user-images.githubusercontent.com/58100363/229711858-18e6bc1b-658d-4d70-995f-b8dcbf67e71e.png)

PoreFab’s image processing pipeline encompasses three main stages: namely, (1) image input, (2) image segmentation/cleaning, and (3) mesh generation. Segmentation and cleanup operations are used to produce binarized images with fully connected pore spaces, which are a prerequisite to the production of 3D printable models. Binary images form the input to mesh generation, which produces watertight 3D triangular irregular network-based representations of the matrix and pore network. The generated models are self-contained, with the inlet-outlet chambers/ports, synthetic rock matrix and transparent viewing panels printed as a single integrated unit, negating the need for complex assembly. PoreFab exports micro-models as stereolithography (.stl) files: the de facto file format used by consumer grade 3D printers. 

![Fig 6](https://user-images.githubusercontent.com/58100363/229722050-048371a5-41b9-4eec-82d3-95ecdb5bcf4f.png)

Note that to run the Windows binaries as a standalone application, the user need to download and install MATLAB RUNTIME 2021a (9.10): https://www.mathworks.com/products/compiler/matlab-runtime.html


