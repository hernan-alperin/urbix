echo "Verificando los sensores del sistema, en LAZARO CUEROS..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/lazaro/check_sensor.kjb -level=Minimal >> /opt/pdi-3.2.4.stable/alertaspi/lazaro/chk_sensor_lazaro.log
