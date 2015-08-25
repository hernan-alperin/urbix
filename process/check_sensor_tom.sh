echo "Verificando los sensores del sistema, en TORTUGAS OPEN MALL..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/tom/check_sensor.kjb -level=Minimal >> /opt/pdi-3.2.4.stable/alertaspi/tom/chk_sensor_tom.log
