# Soft Error Mitigation IP in vivado 

**Project Statement** - Explore the soft error injection IP in Vivado – to understand the role of random errors (called soft errors
Exploration of SOFT ERROR MITIGATION IP by AMD in FPGA

 **Soft Errors** :- soft errors are unintended changes to the values stored in state elements caused by ionizing radiation.
 But if we want to test our design/hardware for soft errors using ion radiation testing it is very costly and hard. so instead we can use the Soft Error Mitigation IP provided by AMD using which it is possible to inject errors into the configuration memory manually, simulate and observe their effects on our design in initial phase.


### System level design example

- Below is the block diagram of design example that comes with the SEM IP and which we have explored and implemented.


  ![Block-diagaram](https://github.com/dillibabuporlapothula/VL505_FPGA_PROJECT/assets/141803312/69dc9b24-6dcd-4692-b4cc-b9cefe5d67e3)



 - The structure of code example is shown below



   ![Code-structure](https://github.com/dillibabuporlapothula/VL505_FPGA_PROJECT/assets/141803312/5410c2cd-381f-41d5-a7e5-451d300aeaaa)



 
 ### Schematic
  - In the schematic we can see all the sub-blocks that are there in the block diagram as modules.



    ![Schematic](https://github.com/dillibabuporlapothula/VL505_FPGA_PROJECT/assets/141803312/29891cd0-7b13-4be0-8c36-65b5a38d7849)


### VIO output 

- The VIO output which SEM in observation state.



  ![VIO](https://github.com/dillibabuporlapothula/VL505_FPGA_PROJECT/assets/141803312/79f11510-ab23-4217-9592-ee8fafc557bd)





### Monitor interface output


- Monitor interface showing error injection (in idle state) , error detection, error correction and error classification in below terminal output.



  
    
  ![Monitor_interface](https://github.com/dillibabuporlapothula/VL505_FPGA_PROJECT/assets/141803312/4b7145dc-e002-4faa-8969-7ffd02029329)

