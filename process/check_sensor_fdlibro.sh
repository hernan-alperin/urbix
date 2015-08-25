echo "Verificando los sensores del sistema, en FERIA DEL LIBRO..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/fdlibro/check_sensor.kjb -level=Minimal >> /opt/pdi-3.2.4.stable/alertaspi/fdlibro/chk_sensor_fdlibro.log
