# MIPS_based_8bit_RISC_Processor
This processor was implemented on an FPGA to execute instructions you created in ROM to solve a problem

> Set of instructions for solving problems

`Problem 1`
Useing Loops, Find the number of ones in the binary equivalent of a given integer value. Assume the given value is 29

```vhdl
constant inst : memoryinst := (
			x"721D",--0 -- r1 <- 29
			x"0000",--1 -- r3 <- 0
			x"0000",--2 -- r2 <- 0
			x"7802",--3 -- r4 <- 2
			x"2240",--4 -- r1 <- r1 to update sf_flag 
			x"F009",--5 -- if(sf==0) --> inst[9]
			x"0000",--6 -- wait for 10 ns
			x"0000",--7 -- wait for 10 ns
			x"2481",--8 -- r2 <- r2 + 1
			x"130B",--9 -- r1 <- r1 / r4
			x"B2C4",--A -- if(r1>r3) --> inst[4]
			x"0000",--B -- wait for 10 ns
			x"0000",--C -- wait for 10 ns
			x"2480",--D -- r2 <- r2 to update destnation_register
			x"0000",--E -- end
			x"0000"); 
```
`Problem 2`
Useing Loops, Find the factorial of a given integer value. Assume the given value is 5

```vhdl
constant inst : memoryinst := (
			x"7205",-- r1 <- 5
			x"EFC9",-- check r1=0 or zf=1 ?branch to end  
			x"7401",-- r2 <- 1
			x"7600",-- r3 <- 0
			x"1452",-- r2 <- r2*r1
			x"3241",-- r1 <- r1-1 
			x"B2C3",-- check r1 > r3 ?branch to 7600  
			x"0000",
			x"0000",
			x"2480",-- cout r2
			x"0000",
			x"0000",
			x"0000",
			x"0000",
			x"0000",
			x"0000");
```
> ### Wave_Problem_1.vcd

![Screenshot from 2023-12-24 16-42-02](https://github.com/Eng-Omar-Hussein/MIPS_based_8bit_RISC_Processor/assets/117474007/5e9284e4-e6d7-45b4-902f-960eae2cb7ba)

> ### Wave_Problem_2.vcd
![Screenshot from 2024-01-24 20-16-09](https://github.com/Eng-Omar-Hussein/MIPS_based_8bit_RISC_Processor/assets/117474007/d8e9680c-859a-4d36-bf84-577b91c62455)



