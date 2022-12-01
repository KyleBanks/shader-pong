# shader-pong

A simplistic game of pong implemented in a fragment shader and custom Unity render pipeline, including Audio, AI, Physics and Gameplay, all controlled through the shader (as much as possible). This project is simply a proof of concept to see if it's feasible to build a game within a fragment shader, and certainly isn't meant to represent any kind of polished game. 

There are definitely bugs. 

For more information on the approach, [check out the YouTube video](https://www.youtube.com/watch?v=e-hTTVr_pDI)!

## License

The majority of this project is made available under the [MIT License](./LICENSE), so you're free to use it for any purpose. 

The `_lineLine` and `_lineRect` functions in `Physics.hlsl` are adapted from [jeffreythompson.org](http://www.jeffreythompson.org/) under the [Creative Commons Attribution, Non-Commercial, Share-Alike license](http://www.jeffreythompson.org/collision-detection/license.php).
