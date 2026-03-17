<h1 align="center">Superscalar Single-Cycle RISC-V (Dual-Issue)</h1>

<p align="center">
  Dual-issue superscalar processor implemented in SystemVerilog, capable of issuing two instructions per clock cycle.
</p>

---

<h2 align="center">🖼️ Architecture Diagram</h2>

<p align="center">
  <img src="Diagrama-Superescalar-Ciclo-Unico.png" width="700"/>
</p>

---

## 📌 Overview

This project consists of the design and implementation of a **superscalar single-cycle RISC-V architecture** capable of issuing up to **two instructions per clock cycle (dual-issue)**.

The main objective was to explore **Instruction-Level Parallelism (ILP)** within a single-cycle organization, serving as a structural foundation for future evolution into a pipelined architecture.

---

## 🚀 Key Features

- Dual-issue execution (2 instructions per cycle)
- Superscalar architecture
- Single-cycle design
- Instruction-Level Parallelism (ILP) exploration
- In-order issue and completion

---

## ⚙️ Execution Model

The architecture follows an **in-order execution model**, meaning:

- Instructions are issued in program order
- Instructions are completed in program order
- Two consecutive instructions can be executed simultaneously **only if there are no hazards**

### ✔️ Conditions for Dual Execution:
- No data hazards
- No structural hazards
- Independent instructions

---

## 🧠 Architectural Highlights

To support dual-issue execution, the following adaptations were required:

- Duplication/extension of datapath components
- Parallel instruction fetch and decode
- Control logic capable of handling two instructions per cycle
- Hazard detection mechanisms to prevent incorrect execution

---

## 🧪 Simulation and Testing

The architecture was validated using:

- **Intel Quartus**
- Test programs developed in **RARS (RISC-V Assembler and Simulator)**

---

## ▶️ How to Run the Project

### Option 1 — Open directly in Quartus

1. Clone or download this repository:
   
```bash
https://github.com/natycristina/single-cycle-superscalar-architecture-implementation.git
```

2. Open the project file:

```bash
Ic-teste-validando.qpf
```

3. Compile the project

4. Open the waveform file:

```bash
Waveform.vwf
```

5. Run simulation

### Option 2 — Create a new Quartus project

1. Open Quartus

2. Create a new project

3. Add all .sv files from this repository

4. Compile the design

5. Run simulation using the waveform file

##  📁 Project Structure

*.sv → SystemVerilog source files

*.vwf → Waveform simulation file

*.qpf → Quartus project file

*.txt → Machine code / test inputs

## 🎯 Conclusion

This project demonstrates the implementation of a dual-issue superscalar processor in a single-cycle architecture, highlighting the challenges and design decisions involved in exploiting instruction-level parallelism.

It also serves as a foundation for more advanced architectures, such as pipelined and out-of-order processors.

## 👩‍💻 Author

Nataly Cristina

Developed as part of an undergraduate research project (Iniciação Científica).
