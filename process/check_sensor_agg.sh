echo "Verificando los sensores del sistema, en AGG..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/agg/check_sensor.kjb -level=Minimal >> /opt/pdi-3.2.4.stable/alertaspi/agg/chk_sensor_agg.log
