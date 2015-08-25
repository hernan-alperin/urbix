echo "Verificando los sensores del sistema, en SAN JUSTO SHOPPING..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/sjs/check_sensor.kjb -level=Minimal >> /opt/pdi-3.2.4.stable/alertaspi/sjs/chk_sensor_sjs.log
