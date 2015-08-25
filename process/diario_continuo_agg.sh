echo "Exportando datos de AGG, a EXCEL..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/agg/diario_continuo.kjb -level=minimal >> /opt/pdi-3.2.4.stable/alertaspi/agg/diario_continuo_agg.log
