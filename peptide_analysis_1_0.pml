# short pyMOL script for generation of electrostatic surface (APBS mapping) for peptide of interest and preparation of high resolution figures

# version 1.0
# this plugin fetches and uses different plugins to carry out the data preparation and manipulation (namely pdb2pqr and apbs - see more in preparation D), so you need to install them to run this plugin 
# you can run multiple this plugin multiple times in the same session for different structures, respectively --> the defined "get_names" command will prevent that objects and pictures with the same naming get generated and thus prevent overwriting of files (of course only when you named your input structures differently :D)
# everything written in the brackets "<>" is a placeholder for the actual filenames (e.g. <peptide_name> --> name PDB file for your peptide) and need to be filled in manually
# the variable <PATH> in the descriptions and commands refers to the data pathways (on your machine) where you stored the respected files --> they need to be filled in (if needed) by yourself manually

# preparations for running this script:
#   A. put Plugin file (peptide_analysis_1_0.pml) in a destination folder, from which you want to run it (e.g. C:\User\Max_Muster\Desktop\PyMOL_Plguins) --> copy and store the pathway information for later running the plugin  
#      (Alternatively put it directly in the working folder, in which you want to store the figure of your peptide of interest --> you can then later run the plugin without needing to input the whole pathway information of the .pml file)
#   B. open PyMol software --> load your PDB file into the PyMOL viewer (either through the tab File--> Open --> Browse for your PDB file in "Open file" Window // or through writing command "load <PATH>/<peptide_name>.pdb" in the command line at the top)
#   C. make sure that your peptide structure (and only your peptide structure!) is enabled in the PyMOL viewer (object button needs to be light grey in the object manager on the left) --> if other objects are enabled in the PyMOL viewer it will mess up the plugin and most likely crash your PyMOL session!!!
#   D. be sure that following plugins/modules are installed =
#           1. PDB2PQR plugin (should be already pre-compiled in current PyMOL2 software package)
#           2. APBS plugin (should be already pre-compiled in current PyMOL2 software package)
#               --> if plugins are not installed, then install them for Linux system (in bash shell) using "apt-get install apbs pdb2pdr" // or for Windows/Mac system by downloading from: https://github.com/Electrostatics/apbs-pdb2pqr/releases
#           3.Psico module (should be already pre-compiled in current PyMOL2 software package)
#               --> if module is not installed on Linux system use "conda install -c speleo3 pymol-psico" (in conda envoirment of course) // or when using a Windows/Mac system download github repository from: https://github.com/speleo3/pymol-psico and pull it in site-packages folder of PyMOL2 (on Windows should look something like this <PATH>\AppData\Local\Schrodinger\PyMOL2\Lib\site-packages) and extract it
#   E. if not done already change your current working directory of your PyMOL session to your designated directory by writing "cd <PATH>" in the command line at the top (their your figures will be stored!) --> to check your current working directory write "pwd" in the command line   
#   F. type "run <PATH>/peptide_analysis_1_0.pml" in command line at the top

# first we import all the plugins and modules in the current PyMOL session to run this plugin 
from pymol import cmd
import re
import sys
import psico
psico.init(save=0, fetch=0, pymolapi=0)
from pdb2pqr import mainCommand

# then we copy the enabled object(s) in this session as an seperate "peptide of interest" object and prepare this object in a nice representation (be sure to only enable your desired peptide structure in the PyMOL viewer)
    hide all;
    select selection_3, enabled;
    disable;
    create pep_of_int, selection_3;
    show cartoon, selection_3;
    show sticks, pep_of_int;
    hide cartoon, pep_of_int;
    select selection, bb. and pep_of_int;
    hide sticks, selection;
    delete selection;
    select selection, bycalpha pep_of_int;
    show sticks, selection;
    util.cbay pep_of_int; 
    delete selection;
    show cartoon, pep_of_int;
    set cartoon_color, green;

# we orient the prepared peptide structure to generate a nice overview figure and take ray-traced high resolution pictures from the front and the back of the structure --> pictures will be named "<OBJECT_NAME_OF_INPUT_PEPTIDE>_peptide_overview_front/back.png" in current working directory    
    orient pep_of_int, 0;
    center pep_of_int;
    zoom pep_of_int, complete=1;
    set ray_shadow, off;
    ray 2400,1200;
    cmd.png('%s_peptide_overview_front.png'%(cmd.get_names('public_objects', selection='selection_3')), '1920', '1920', '600', '1');
    turn y, 180;
    set ray_shadow, off;
    ray 2400,1200;
    cmd.png('%s_peptide_overview_back.png'%(cmd.get_names('public_objects', selection='selection_3')), '1920', '1920', '600', '1');
    turn y, 180;

# in the next steps we prepare a PQR file for our peptide structure, convert it then to a readable electrostatic potential-map, and color code (from red-white-blue) the molecular surface of the peptide-PQR file based on this charge-map
    pdb2pqr pep_of_int_apbs, pep_of_int;
    map_new_apbs pep_of_int_map, pep_of_int_apbs;
    ramp_new apbs_slider, pep_of_int_map, [-1, 0, 1], [red, white, blue];
    select selection, pep_of_int_apbs;
    set surface_color, apbs_slider, selection;
    delete selection;
    set surface_ramp_above_mode;
    show surface, pep_of_int_apbs;

# now we fine tune the quality of the electrostatic surface (if needed better quality needed, you can change surface_quality parameter between 1-3 (above 3 will most likely crash session!!!)), orient it and generate a nice figures (again) from front and back -->pictures will be named "<OBJECT_NAME_OF_INPUT_PEPTIDE>_peptide_electrostatics_front/back.png" in current working directory
    set surface_quality, 1;
    orient pep_of_int_apbs, 0;
    center pep_of_int_apbs;
    zoom pep_of_int_apbs, complete=1;
    zoom buffer=2;
    set ray_shadow, off;
    ray 2400,1200;
    cmd.png('%s_peptide_electrostatics_front.png'%(cmd.get_names('public_objects', selection='selection_3')), '1920', '1920', '600', '1');
    turn y, 180;
    set ray_shadow, off;
    ray 2400,1200;
    cmd.png('%s_peptide_electrostatics_back.png'%(cmd.get_names('public_objects', selection='selection_3')), '1920', '1920', '600', '1');
    turn y, 180;

# additionally we group all the created objects during this run in one object-group called "analysis_<OBJECT_NAME_OF_INPUT_PEPTIDE>" --> in the group you will find the several objects, generated from the plugin (Abbreviations: sc - object showing peptide "side chains"; es - object showing peptide "electrostatic surface"; cm - object showing peptide "charge map"; cs - object showing "charge slider" managing cutoff values)
    enable pep_of_int_map
    cmd.set_name('pep_of_int', '%s_sc'%cmd.get_names('public_objects', selection='selection_3'));
    cmd.set_name('pep_of_int_apbs', '%s_es'%cmd.get_names('public_objects', selection='selection_3'));
    cmd.set_name('pep_of_int_map', '%s_cm'%cmd.get_names('public_objects', selection='selection_3'));
    cmd.set_name('apbs_slider', '%s_cs'%cmd.get_names('public_objects', selection='selection_3'));
    cmd.group('ana_%s'%cmd.get_names('public_objects', selection='selection_3'), 'enabled');
    delete selection_3;
    

# author of plugin: Paul Schrank (Leibniz Institute for Plant Biochemistry / Martin-Luther-University Halle-Wittenberg)
# if you have problems with the plugin please contact: paul.schrank@ipb-halle.de // paul.schrank@student.uni-halle.de
# last edited: 20.10.2022






