# SmithWaterman Harware Implementation
###### tags:  `project`
Bachelor project from the professor Yi-Chang Lu in NTUEE
[github](https://github.com/whoami90506/Smith_Waterman_Hardware_Implementation)

## How to use
### software
#### prepare input data
software need a file to store two sequences and parameter
* the first line is sequence S
* the second line is sequence T
* the next four lines cotain four numbers represented as match, mismatch, $\alpha$, and $\beta$.
* support unlimited groups of parameter.

#### Make
change directory into software/
```shell
# basic
make clean
make

# print all values of v, e, f
make clean
make matrix

# trace back
make clean
make trace

# both print values and trace back
make clean
make both
```

#### Run
the exe file is in folder software/
```shell
./SmithWaterman <input_data>
```

### Hardware
#### prepare input data
Harware simulation and FPGAWrapper need four files to run : s.dat, t.dat, s_len.dat, param.dat.

It's quite easy to use **root_folder/convert.py** to transform software input data to hardware input files.
```shell
python convert.py <input_software_data> <outout_prefix>
```
There will be four file named as <output_prefix>_s.dat, <output_prefix>_t.dat, <output_prefix>_s_len.dat, <output_prefix>_param.dat.

> * Although the hardware design support unlimited groups of parameter, the testbench only read **2** groups of parameters.
> * The python script transform A to 2'b00, C to 2'b01, G to 2'b10, T to 2'b11.

---

Or you can make the hardware input file manually.
* <output_prefix>_s.dat
    * binary memory format
    * 64 DNA elements per line
    * col[127:126] represent the formar element
* <output_prefix>_t.dat
    * binary memory format
    * 7 DNA elements per line
    * 18bits per line
    * col[17] is always 1
    * col[16:14] represent the end of the sequence T. 
        * If the column is the end of the Sequence, it equals the number of remain elements.
        * Otherwise, it equals 3'b000.
    * col [13:0] represent the 7 DNA elements
        * col[13:12] represent the formar element
* <output_prefix>_s_len.dat
    * One line with the length of sequence S in decimal digits.
* <output_prefix>_param.dat
    * hex memory format
    * One parameter group per line
        * col[15:12] represent match
        * col[11:8] represent mismatch
        * col[7:4] represent $\alpha$
        * col[3:0] represent $\beta$
    * Testbench only support **2** groups of parameter.

>The name of the hardware input data must be the format above to fit the testbench.

#### Edit hardware/src/util.v
there are 5 define need to set to get input data
* `define DATA   : <output_prefix>
* `define DATA_s : <output_prefix>_s.dat
* `define DATA_t : <output_prefix>_t.dat
* `define DATA_s_len : <output_prefix>_s_len.dat
* `define DATA_S_TOTAL   : length of sequence S

#### RTL simulation
1. Edit hardware/src/util.v to set the right input file.
2. Type the command below in folder hardware/
```shell
ncverilog -f rtl.f
```

>make sure folder sram_1024x8_t13/ which is not in github is in hardware/Memory/.

#### Synthesis
1. Edit the cycle time in syn/syn_DC.sdc
2. Type the command below in folder hardware/
```shell
dc_shell -f syn/SmithWaterman.tcl
```
SmithWaterman_syn.v, SmithWaterman_syn.sdf, and SmithWaterman_syn.ddc will be in syn/.

>make sure folder sram_1024x8_t13/ which is not in github is in hardware/Memory/.:

#### Gate-level simulation
1. Edit cycle time in hardware/testbench/testfixture.v .
2. Edit hardware/src/util.v to set the right input file.
3. Type the command below in folder hardware/
```shell
ncverilog -f syn.f
```

>* make sure folder sram_1024x8_t13/ which is not in github is in hardware/Memory/.
>* make sure tsmc13_neg.v which is not in github is in hardware/ .


#### FPGA simulation(by ncverilog)
1. Edit hardware/src/util.v to set the right input file.
2. Type the command below in folder hardware/
```shell
ncverilog -f fpga.f
```

#### Run on FPGA (DE2-115)
1. Prepare a DE2-115 board and a computer with Quartus.
2. Edit hardware/src/util.v to set the right input file.
3. Use Quartus to open Quartus project SmithWaterman.qpf in hardware/ .
4. Compile.
5. Burn on FPGA Board.

* LEDG[8] indicates the module is busy or not.
* KEY[0] represents reset_n.
* KEY[1] represents set_t.
* KEY[2] represents start_calculation.
* SW[17:14] represents match
* SW[13:10] represents mismatch
* SW[9:6] represents $\alpha$
* SW[5:2] represents $\beta$
* SW[1:0] determinies {LEDR, LEDG[7:0]}
    * 2'b00 : the value of result
    * 2'b10 : the number of using cycle from clking start to getting result.
    * 2'b11 : the number of using cycle during busy.
    * 2'b01 : all of the LED are light.

## Performance
### Gate-level


| Cycle time(ns) | Area($\mu m^2$) | Cycle time * Area |Power(mW) |Acceleration ratio with software (16384x1024)|
| -------- | -------- | -------- | --- |-|
| 7    | 3273669.065     | 22915683.45|54.4069 | 115.1432|
| 5 |   3548652.958 |17743264.79    |82.3444|161.20048|
|4.75|  3654453.598|    17358654.59 |89.3567|   169.6847158|
|4.6|   3681995.613|    16973999.77|    93.493| 174.8378308|
|4.36|      3798898.946|    16601188.39|    102.8006    |184.4399085|

### FPGA


| length of S | length of T | Acceleration ratio with software |
| -------- | -------- | -------- |
|80|    80|232.0185615
|256|   256|149.9571551
|512|   512|74.15858528
|1024|  1024|53.16949253
|2048|  1024|48.00912173
|4096|  1024|45.36724787
|8192|  1024|42.32237886
|16384| 1024|40.03012243
|16384  |7168|37.06613518










