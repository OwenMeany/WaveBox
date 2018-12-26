# WaveBox 

A simple wave equation solver for iOS devices. Constructs a Laplacian matrix of the system and uses leap-frog integration with Accelerate framework to time evolve the system. Currently tested only in iPhone simulator. Work on going.

## Getting Started

After cloning the repo you should be able to build and run it with xCode >8.2.1. 

## Known bugs

* Horizontal positioning of the launched wave packet is not correct
* Simulator is tested only with N x N grid. Other grid sizes cause some interference patterns.

## Authors

* **Harri Mökkönen** - *Initial work* - [OwenMeany](https://github.com/OwenMeany)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks for LP for the help with numerics.
