# gpu-computed-particle-system-with-swift
Lookup project demonstrating how to compute and render basic particle systems.

## Introduction
Implementation of a simple particle system using Swift, SwiftUI and the Metal Shading Language. This repository is meant as a knowledge archive demonstrating how to create basic particle systems, how to implement a gaussian blur render pass and conditional / positional coloring of particles.

Frame capture showing 1e5 particles @ 60fps with conditional coloring:  
![1e5 particles with conditinal color rendering](https://github.com/julianlork/gpu-computed-particle-system-with-swift/assets/118125250/5b0e580a-04fd-4489-9542-76ea29272795)


## Resources

Processing textures on a gpu by Apple  
https://developer.apple.com/documentation/metal/compute_passes/processing_a_texture_in_a_compute_function  
https://developer.apple.com/documentation/metal/textures/understanding_color-renderable_pixel_format_sizes  
https://developer.apple.com/documentation/metal/textures/creating_and_sampling_textures  


Underlying concept: working with particles in Metal by metalkit.org  
https://metalkit.org/2017/09/30/working-with-particles-in-metal/  
https://metalkit.org/2017/10/31/working-with-particles-in-metal-part-2/  
https://metalkit.org/2017/11/30/working-with-particles-in-metal-part-3/  
