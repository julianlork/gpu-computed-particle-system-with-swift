# gpu-computed-particle-system-with-swift
Lookup project demonstrating how to compute and render basic particle systems.

## Overview
Implementation of a simple particle system using Swift, SwiftUI and the Metal Shading Language. This repository is meant as a knowledge archive demonstrating how to create basic particle systems and perform basic modifications to that system.  
This project is composed of two branches which are described in the following.

### main branch  
The main branch contains the basic implementation of the moving particle system. It consists of a clear pass that is responsible for resetting the texture and a draw pass that is responsible for computing and drawing the updated particle position to the texture. The draw pass shader also implements a very simple collision model that simulates collisions with the view boundaries. Additionally a color selection logic has been implemented that increases the red-component of each particle as it gets closer to the vertical view boundaries.

The following frame capture shows 1e5 particles at 60 frames per seconds:
<img width="1295" alt="demo-main-branch" src="https://github.com/julianlork/gpu-computed-particle-system-with-swift/assets/118125250/de66858f-0169-435c-8846-d32a62ff2f08">

### implement-gaussian-blur
The implement-gaussian-blur branch extends the main-branch by a gaussian blur pass which is applied to the texture after the draw pass. Additionally the clear pass has been updated so that the particle trail becomes visible:

The following frame capture shows 1e3 particles (for better visibility) at 60 frames per seconds:
<img width="1295" alt="demo-gaussian-blur-with-trail" src="https://github.com/julianlork/gpu-computed-particle-system-with-swift/assets/118125250/e2125081-8bbf-4183-a6bb-6cc5ff8271b1">




## References and Further Reading

Processing textures on a gpu by Apple  
https://developer.apple.com/documentation/metal/compute_passes/processing_a_texture_in_a_compute_function  
https://developer.apple.com/documentation/metal/textures/understanding_color-renderable_pixel_format_sizes  
https://developer.apple.com/documentation/metal/textures/creating_and_sampling_textures  


Underlying concept: working with particles in Metal by metalkit.org  
https://metalkit.org/2017/09/30/working-with-particles-in-metal/  
https://metalkit.org/2017/10/31/working-with-particles-in-metal-part-2/  
https://metalkit.org/2017/11/30/working-with-particles-in-metal-part-3/  
