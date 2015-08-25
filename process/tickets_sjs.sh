echo "Importando tickets de SAN JUSTO SHOPPING ..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/sjs/tickets/sjs_mysql_to_postgres.kjb -level=Detail >> /opt/pdi-3.2.4.stable/alertaspi/sjs/tickets/tickets_sjs.log
#sh -C /opt/Data_integration_4.2/data-integration/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/sjs/tickets/sjs_mysql_to_postgres.kjb -level=Detail >> /opt/pdi-3.2.4.stable/alertaspi/sjs/tickets/tickets_sjs.log
