echo "Actualizando Tabla, report_circulacion en DB SOLAR..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/solar/circulacion_semanal.kjb -level=minimal >> /opt/pdi-3.2.4.stable/alertaspi/solar/circulacion_semanal.log
