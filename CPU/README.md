# CS61CPU

A Logisim CPU that executes RISC-V instructions.

## ALU:
- Implements arithmetic logic:
  - ALUSel: Function
  - 0: add
  - 1: sll
  - 2: slt
  - 3: Unused
  - 4: xor
  - 5: srl
  - 6: or
  - 7: and
  - 8: mul
  - 9: mulh
  - 10: Unused
  - 11: mulhu
  - 12: sub
  - 13: sra
  - 14: Unused
  - 15: bsel
- Output obtained using bit-by-bit multiplexer selection on all the above functions' outputs

## Regfile
- Contains 32 registers x0 to x31.
- Output obtained using bit-by-bit multiplexer selection on all registers' outputs
- Input & WriteEnable implemented using bit-by-bit demultiplexer selection on all registers' inputs

## CPU
- Currently only supports addi
- Follows the IF/ID/EX/MEM/WB workflow but no pipeline
- Uses tunnels occasionally to clean up wiring

## Control Logic
- Check instruction for instruction type
- From those instruction types, separate out special instructions (e.g. jalr) if necessary
- Separate out funct7 and funct3 fields, since those will be useful later
- For each control logic output, find which instructions give which output, and process them one by one
- Some components that I wanted to put inside my control logic, such as a 4-bit MemRW instead of a 1-bit MemRW, was not possible because of the output pins.

## Advantages/Disadvantages of my Design
- In control logic, I used a lot of abstraction.
- For example, when categorizing instructions by opcode, I simply used a comparator and a constant instead of using lower-level things like gates and doing it myself bit-by-bit.
- This slows down my CPU a little bit, but it's worth it because debugging becomes a lot easier, and I know that in the end, if neeeded, it is always possible to optimize this CPU further by using lower level components.

## Best bug
My best bug occurred when I finished writing my custom tests and wanted to convert them to circuits. For some reason, the create-test.py I had didn't work. I was looking through the create-test.py's code and thinking about what to change, but then I decided to give re-pulling starter code a shot, which fixed my bug and saved me a lot of time.

## Worst bug
Debugging the CPU (both before and after pipelining) was a huge pain. I fixed bug after bug and the output would remain incorrect. Sometimes, I would even make something that was originally correct incorrect. Eventually, however, I ran out of things to make mistakes on (I hope at least - I don't know the results of the edge case tests), and pushed through.