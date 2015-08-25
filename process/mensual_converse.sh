echo "GENERANDO EXCEL MENSUAL, PARA CONVERSE..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/process/converse/mensual_converse.kjb -level=minimal >> /opt/process/converse/mensual_converse.log
