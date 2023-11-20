## load ASAP data for gene names

less /data/repro_res/200427_asap2_data_v4.sql | perl -i -p -e "s/postgres/rvmuser/g" | perl -i -p -e "s/AS integer//g" | grep -vw "idle_in_transaction_session_timeout" | psql -v ON_ERROR_STOP=1 repro_res 
