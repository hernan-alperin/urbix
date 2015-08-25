echo "Generando TC diaria de locales auditados en SAN JUSTO SHOPPING ..."
sh -C /opt/Data_integration_4.2/data-integration/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/sjs/tc/tc_diaria_locales_auditados.kjb -level=Detail >> /opt/pdi-3.2.4.stable/alertaspi/sjs/tc/tc_diaria_locales_auditado_sjs.log
