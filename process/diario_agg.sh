echo "Exportando datos de BIYEMAS, KANDIKO y REBISCO, a EXCEL..."
sh -C /opt/pdi-3.2.4.stable/kitchen.sh -file=/opt/pdi-3.2.4.stable/alertaspi/agg/diario_por_sala_v1.kjb -level=minimal >> /opt/pdi-3.2.4.stable/alertaspi/agg/diario_agg_v1.log
