Here I can explain the complete uvm process in a flow
DUT:
It is the actual hardware design
what it does
store Wdata value in particular address reg(0x08)
supports:
write -> store data
Read - > return data
connected to
Interface
Driver
Monitor

Interface
It is a bridge between DUT & UVM
DUT use wires
UVM uses classes(driver/monitor)
contains:
APB signals
sva assertions
coverage logic
Connected to:
DUT
driver 
monitor
The interface encapsulates DUT signals and provide a bridge between DUT & RTL


Transaction:
A data container
Instead of using usingnals 
PADDR PWRITE PREAD PREADY PRDATA.... everytime
we use
apb_txn object (it contains all signals)

connects to:
sequencer
driver
monitor
scoreboard


sequencer:
stimulus generator
what it does?
creates different transaction
randomization
generates diff traffic modes
random
boundary
stress
write only
read only

 connects to
 driver
 sequence

 The sequencer generates random apb transactions with diff stimulus pattern  to improve coverage


 DRiver:
 translator
 converts APB transaction into pin-level APB signals
 connnects to:
 sequrncer(get txn)
 interface(drives DUT)


 Monitor:
 passive observer
 watches DUT signals
 reconstructs txns
 sends to score board
 collects coverage

 connects to:
 interface
 scoreboard

 scoreboard:
 a reference checker
 maintains refernce mode(reg_model)
 predicts expected output
 compares with DUT output
 connects to monitor


 Agent:
 a protocol connatiner
 container
 sequencer
 driver
 monitor
 the agent contains  protocol level components and provides reusable verification block.


 env:
 A system integrator:
 contains
 agent
 scoreboard

Test:
the top level control
It does 
cretaes environments
start sequence
control simulation time
end simulation

connects to
env
sequence
sequencer


tb_top
The top module connects RTL with uvm and instantiates the simulation.


SImply what my UVM does:

1. sequencer creates transaction
2. sequencer sends to driver
3. driver converts apb_txn to  apb_signals
4. DUT process request
5. monitor captures it
6. Scoreboard checkness correcrtness(with ref_model)





















