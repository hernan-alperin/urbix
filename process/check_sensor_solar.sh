echo "Verificando los sensores del sistema, en EL SOLAR SHOPPING..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/solar/check_sensor.kjb -level=Minimal >> /opt/pdi-3.2.4.stable/alertaspi/solar/chk_sensor_solar.log
