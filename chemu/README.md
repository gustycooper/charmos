## Chemu
Chemu is the emulator for the Charm ISA. Chemu consists of C code the implements the emulator and three interfaces to the emulator. A simple Linux terminal command line interface (chemut), a ncurses window interface (chemun), and a web interface (charmweb). The source code in structured with the charmweb files in the chemu folder. The C code for chemut and chemun is in the chemu/src folder. Building charmweb is done in the chemu folder by invoking the setup.sh, which uses setup.py, which references the code via relative paths - for example src/command.c bring the C code for command.c into charmweb. The resulting files for executing charmweb are in chemu and various web folders such as static/scripts and templates. Building chemut and chemun is done in the chemu/src folder by invoking make. The makefile produces the executables chemun and chemut in the chemu/src folder. 

# Chemu Web
Chemu Web (chemuw) is a web frontend for the Charm ISA emulator. It will allow you to run Charm ISA .o files within your web browser and see how each instruction affects the Charm CPU's registers and memory, all within a user-friendly interface that makes using the emulator more intuitive.

To create .o files, you will need to assemble .s files containing Charm assembly code using Gusty's `chasm` tool. See [Gusty's website](https://gusty.bike/charm.html) for more info about the ISA, including ISA specifications and how to use tools like `chasm`. Visit [his repo](https://github.com/gustycooper/cpsc305) to download the tools needed to create .o files, along with sample .s files which can be assembled into .o files and used with this project (see the `charm/isacode` folder within his repo).

## Getting Chemu Web working:
1. Open a terminal. If you’re running Ubuntu within Windows, open an Ubuntu window to access the terminal. The commands listed below will be entered in the terminal
2. (Optional) Change directory to the place you’d like to install chemuw using `cd`
3. Download the chemuw repo using   
`git clone https://github.com/lk-umw-cpsc/charmweb`
4. `cd` into the charmweb folder created in the previous step using:  
`cd charmweb`
5. If you’re running Ubuntu within Windows, run the following command:  
`sudo ./dependencies.sh`  
This will take about 5 minutes to finish executing.
This downloads and installs binaries required to run the setup script in the next step
6. Run the setup script using the following command  
`./setup.sh`  
This creates a virtual Python environment and installs the necessary Python modules to run chemuw

Now that the emulator is installed, use it by running `./run.sh` while in the charmweb folder
* Navigate to `http://127.0.0.1:5000` in your web browser to use the emulator
* When you’re done, go back to your terminal, hold the CTRL (Control on Mac) key and press C to terminate the web server
