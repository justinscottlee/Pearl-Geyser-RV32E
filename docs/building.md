```bash
verilator -Wall -cc tb_uart.sv --exe --timing --binary --trace
```
```bash
cd obj_dir
```
```bash
make -f Vtb_uart.mk
```
```bash
./Vtb_uart
```
```bash
gtkwave tb_uart.vcd --rcvar 'fontname_signals Monospace 14' --rcvar 'fontname_waves Monospace 14'
```