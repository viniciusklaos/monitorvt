# Hostname
servidor_nome=`hostname`
servidor_dominio=`hostname | cut -d. -f2-100`
# Plataforma
if [ -d /var/cpanel ]; then
	servidor_painel="CPanel"
elif [ -d /usr/local/vesta ]; then
	servidor_painel="VestaCP"
else
	servidor_painel="Desconhecida"
fi
#
servidor_ultimo_registro=`date`
#
servidor_espaco_disco=`df -h | grep -n ^ | grep ^2 | awk '{print $5}' | cut -d% -f1`
#
servidor_espaco_inodes=`df -i | grep -n ^ | grep ^2 | awk '{print $5}' | cut -d% -f1`
#
servidor_load=`cat /proc/loadavg | awk '{print $1}'`
#
servidor_load_cinco_minutos=`cat /proc/loadavg | awk '{print $2}'`
#
servidor_load_quinze_minutos=`cat /proc/loadavg | awk '{print $3}'`
#
servidor_memoria_total=`expr $(cat /proc/meminfo | grep -F "MemTotal:" | awk '{print $2}') '/' 1024`
#
servidor_memoria_livre=`expr $(cat /proc/meminfo | grep -F "MemFree:" | awk '{print $2}') '/' 1024`
#
# PROCESSOS DO APACHE
servidor_memoria_apache=0; servidor_processos_apache=0; for i in `ps gawux | grep apache | grep -v root | awk '{print $2}'`; do APACHETAMANHO=`pmap -d $i | tail -1 | awk '{print $4}' | sed 's/K//'`
let servidor_memoria_apache=servidor_memoria_apache+APACHETAMANHO
servidor_processos_apache=`expr $servidor_processos_apache + 1`
done
# PROCESSOS DO MYSQL
servidor_memoria_mysql=0; servidor_processos_mysql=0; for i in `ps gawux | grep mysqld | grep -v root | awk '{print $2}'`; do MYSQLTAMANHO=`pmap -d $i | tail -1 | awk '{print $4}' | sed 's/K//'`
let servidor_memoria_mysql=servidor_memoria_mysql+MYSQLTAMANHO
servidor_processos_mysql=`expr $servidor_processos_mysql + 1`
done
# PROCESSOS DO EXIM
servidor_memoria_exim=0; servidor_processos_exim=0; for i in `ps gawux | grep exim | grep -v root | awk '{print $2}'`; do EXIMTAMANHO=`pmap -d $i | tail -1 | awk '{print $4}' | sed 's/K//'`
let servidor_memoria_exim=servidor_memoria_exim+EXIMTAMANHO
servidor_processos_exim=`expr $servidor_processos_exim + 1`
done
#
servidor_espaco_exim=`du -sh /var/spool/exim/input | awk '{print $1}'`
#
servidor_ip_principal=`ip a | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | cut -f1 -d/ | grep -n ^ | grep -w ^1 | cut -f2 -d:`
#
QUANTIDADE=`dominios | sed '/vesta./d' | wc -l`
if [ $QUANTIDADE -ge "2" ]; then
	servidor_tipo="Signo"
else
	servidor_tipo="VPS"
fi
#
if [ -d /var/spool/pmta ]; then
	servidor_espaco_pmta=`du -sh /var/spool/pmta | awk '{print $1}'`
	servidor_memoria_pmta=0; servidor_memoria_pmta=0; for i in `ps gawux | grep pmta | grep -v root | awk '{print $2}'`; do PMTATAMANHO=`pmap -d $i | tail -1 | awk '{print $4}' | sed 's/K//'`
	let servidor_memoria_pmta=servidor_memoria_pmta+PMTATAMANHO
	servidor_processos_pmta=`expr $servidor_processos_pmta + 1`
	done
fi
#
update () {
	mysql -h 173.249.151.31 -u smcentra_monitoramento -pphCA24bgK smcentra_monitoramento -e "UPDATE servidor
	SET servidor_painel= '$servidor_painel', servidor_ultimo_registro= '$servidor_ultimo_registro', servidor_espaco_disco= '$servidor_espaco_disco', servidor_espaco_inodes= '$servidor_espaco_inodes', servidor_load= '$servidor_load', servidor_load_cinco_minutos= '$servidor_load_cinco_minutos', servidor_load_quinze_minutos= '$servidor_load_quinze_minutos', servidor_memoria_total= '$servidor_memoria_total', servidor_memoria_livre= '$servidor_memoria_livre', servidor_processos_pmta= '$servidor_processos_pmta', servidor_memoria_pmta= '$servidor_memoria_pmta', servidor_processos_apache= '$servidor_processos_apache', servidor_memoria_apache= '$servidor_memoria_apache', servidor_processos_mysql= '$servidor_processos_mysql', servidor_memoria_mysql= '$servidor_memoria_mysql', servidor_processos_exim= '$servidor_processos_exim', servidor_memoria_exim= '$servidor_memoria_exim', servidor_espaco_exim= '$servidor_espaco_exim', servidor_espaco_pmta= '$servidor_espaco_pmta', servidor_ip_principal= '$servidor_ip_principal', servidor_dominio= '$servidor_dominio', servidor_tipo= '$servidor_tipo'
	WHERE servidor_nome = '$servidor_nome';"
}
#
insert () {
	mysql -h 173.249.151.31 -u smcentra_monitoramento -pphCA24bgK smcentra_monitoramento -e "INSERT INTO servidor (servidor_nome, servidor_painel, servidor_ultimo_registro, servidor_espaco_disco, servidor_espaco_inodes, servidor_load, servidor_load_cinco_minutos, servidor_load_quinze_minutos, servidor_memoria_total, servidor_memoria_livre, servidor_processos_pmta, servidor_memoria_pmta, servidor_processos_apache, servidor_memoria_apache, servidor_processos_mysql, servidor_memoria_mysql, servidor_processos_exim, servidor_memoria_exim, servidor_espaco_exim, servidor_espaco_pmta, servidor_ip_principal, servidor_dominio, servidor_tipo)
	VALUES ('$servidor_nome', '$servidor_painel', '$servidor_ultimo_registro', '$servidor_espaco_disco', '$servidor_espaco_inodes', '$servidor_load', '$servidor_load_cinco_minutos', '$servidor_load_quinze_minutos', '$servidor_memoria_total', '$servidor_memoria_livre', '$servidor_processos_pmta', '$servidor_memoria_pmta', '$servidor_processos_apache', '$servidor_memoria_apache', '$servidor_processos_mysql', '$servidor_memoria_mysql', '$servidor_processos_exim', '$servidor_memoria_exim', '$servidor_espaco_exim', '$servidor_espaco_pmta', '$servidor_ip_principal', '$servidor_dominio', '$servidor_tipo');"
}
#
JAEXISTE=$(mysql -h 173.249.151.31 -u smcentra_monitoramento -pphCA24bgK smcentra_monitoramento -e "SELECT * from servidor WHERE servidor_nome = '$servidor_nome';")
#
if [ -z "$JAEXISTE" ]; then
	insert;
else
	update;
fi


# RAFAEL COELHO AJUSTE