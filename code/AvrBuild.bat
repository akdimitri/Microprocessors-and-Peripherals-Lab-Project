@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "D:\Microprocessors\Assembly Workspace\Silo_0.2\labels.tmp" -fI -W+ie -C V2E -o "D:\Microprocessors\Assembly Workspace\Silo_0.2\Silo.hex" -d "D:\Microprocessors\Assembly Workspace\Silo_0.2\Silo.obj" -e "D:\Microprocessors\Assembly Workspace\Silo_0.2\Silo.eep" -m "D:\Microprocessors\Assembly Workspace\Silo_0.2\Silo.map" "D:\Microprocessors\Assembly Workspace\Silo_0.2\Silo.asm"
