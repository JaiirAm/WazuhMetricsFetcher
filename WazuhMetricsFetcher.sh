#!/bin/bash

#WazuhMetricsFetcher is a simple bash script, written in a mindset to help the users to fetch wazuh metrics using internal APIs and convert it in to a prometheus metrics and then push them to PushGateway exporter for prometheus to scrape them.
#Wazuh ----> Wazuh Metrics ---> PushGateway ---> Prometheus

#Variables for iterating the api endpoints to fetch details
whoami=$(basename "$0")
hostname="<Wazuh endpoint here>"
API_PORT="<Wazuh API PORT here>"
pushgateway="<Pushgateway endpoint here>"
Login_Endpoint="/security/user/authenticate?raw=true"
TOKEN=$(curl -s -u <api user here>:'<api password here>' -k -X POST ""$hostname":"$API_PORT""$Login_Endpoint"")
Auth=$(curl -s -k -X GET ""$hostname":"$API_PORT"/" -H "Authorization: Bearer $TOKEN")
metrictype="gauge"

#check if already a metrics file exist
echo -e "**************************************************************"
echo -e "		Prepping the CWD to store the results		"
echo -e "**************************************************************"
recur(){
while read r; do
	if [ -f $r ];then
                echo -e "Old Wazuh Metrics file --> "$r" found. moving it....."
                mv $r ./$dir
        fi
done < init_remove.txt
}
dir="Wazuh_old_metrics"
if [ -d $dir ];then
	echo -e "Deleting the old Metrics directory content and pushing the previous scanned metrics to the directory"
	rm -r $dir && mkdir $dir
	recur
else
	mkdir $dir
	recur
fi

#Authentication validator
if [[ $Auth == *"Unauthorized"* ]];then
        echo -e "Authentication parameters invalid!"
        exit 0
else
        echo -e "Authentication successfull"
        AuthActive=1
fi

#cluster status
echo -e "**************************************************************"
echo -e "			Cluster Metrics				"
echo -e "**************************************************************"
curl -s -k -X GET ""$hostname":"$API_PORT"/cluster/status?pretty=true" -H "Authorization: Bearer $TOKEN" > clusterstatus.json
jq -r '.data' clusterstatus.json | jq -r '.enabled' | tr -d '\r' > cluster_enabled.txt
jq -r '.data' clusterstatus.json | jq -r '.running' | tr -d '\r' > cluster_running.txt
echo -e "Wazuh_Cluster_enabled=$(cat cluster_enabled.txt)"
echo -e "Wazuh_Cluster_running=$(cat cluster_running.txt)"
rm cluster_enabled.txt cluster_running.txt clusterstatus.json

#iterating the agents counts according to their status
curl -s -k -X GET ""$hostname":"$API_PORT"/overview/agents?pretty=true" -H "Authorization: Bearer $TOKEN" > agent_overview.json
	jq -r ' .data | .nodes | .[] | .node_name' agent_overview.json > node_details.txt
	echo -e  "Wazuh_nodes_count=$(wc -l node_details.txt | cut -d ' ' -f1 )" >> Wazuh_Metrics.txt
	echo -e  "Wazuh_nodes_count=$(wc -l node_details.txt | cut -d ' ' -f1 )"
	echo -e "**************************************************************"
	echo -e "			Agent metrics				"
	echo -e "**************************************************************"
	jq -r ' .data | .agent_status | .connection | .active' agent_overview.json | tr -d '\r' > active_Agent_count.txt
        echo -e "Wazuh_active_agents=$(cat active_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_active_agents=$(cat active_Agent_count.txt)"
	rm active_Agent_count.txt
        jq -r ' .data | .agent_status | .connection | .disconnected' agent_overview.json | tr -d '\r' > disconnected_Agent_count.txt
        echo -e "Wazuh_disconnected_agents=$(cat disconnected_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_diconnected_agents=$(cat disconnected_Agent_count.txt)"
	rm disconnected_Agent_count.txt
        jq -r ' .data | .agent_status | .connection | .pending' agent_overview.json | tr -d '\r' > pending_Agent_count.txt
        echo -e "Wazuh_pending_agents=$(cat pending_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_pending_agents=$(cat pending_Agent_count.txt)"
	rm pending_Agent_count.txt
        jq -r ' .data | .agent_status | .connection | .never_connected' agent_overview.json | tr -d '\r' > never_connected_Agent_count.txt
        echo -e "Wazuh_never_connected_agents=$(cat never_connected_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_never_connected_agents=$(cat never_connected_Agent_count.txt)"
        rm never_connected_Agent_count.txt
        jq -r ' .data | .agent_status | .connection | .total' agent_overview.json | tr -d '\r' > total_Agent_count.txt
        echo -e "Wazuh_total_agents=$(cat total_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_total_agents=$(cat total_Agent_count.txt)"
	rm total_Agent_count.txt
	jq -r ' .data | .agent_status | .configuration | .synced' agent_overview.json | tr -d '\r' > synced_Agent_count.txt
        echo -e "Wazuh_synced_agents=$(cat synced_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_synced_agents=$(cat synced_Agent_count.txt)"
	rm synced_Agent_count.txt
	jq -r ' .data | .agent_status | .configuration | .not_synced' agent_overview.json | tr -d '\r' > not_synced_Agent_count.txt
        echo -e "Wazuh_not_synced_agents=$(cat not_synced_Agent_count.txt)" >> Wazuh_Metrics.txt
        echo -e "Wazuh_not_synced_agents=$(cat not_synced_Agent_count.txt)"
	rm not_synced_Agent_count.txt
	rm agent_overview.json
	
#iteration to fetch the oudated agents counts with respective status
echo -e "**************************************************************"
echo -e "			Outdated Agent metrics			"
echo -e "**************************************************************"
while read AgentStatus; do
        curl -s -k -X GET ""$hostname":"$API_PORT"/agents/outdated?pretty=true&offset=1&q="status="$AgentStatus""" -H "Authorization: Bearer $TOKEN" > "$AgentStatus"_Outdated_Agents.json
        jq -r '.data' "$AgentStatus"_Outdated_Agents.json | jq -r '.total_affected_items' | tr -d '\r' > "$AgentStatus"_OutdatedAgent_count.txt
        if [[ $(cat "$AgentStatus"_OutdatedAgent_count.txt) -ne 0 ]];then
                echo -e "Wazuh_"$AgentStatus"_outdated_agents=$(expr $(cat "$AgentStatus"_OutdatedAgent_count.txt) - 1)"
                echo -e "Wazuh_"$AgentStatus"_outdated_agents=$(expr $(cat "$AgentStatus"_OutdatedAgent_count.txt) - 1)" >> Wazuh_Metrics.txt
        else
                echo -e "Wazuh_"$AgentStatus"_outdated_agents=$(cat "$AgentStatus"_OutdatedAgent_count.txt)"
                echo -e "Wazuh_"$AgentStatus"_outdated_agents=$(cat "$AgentStatus"_OutdatedAgent_count.txt)" >> Wazuh_Metrics.txt
        fi
rm "$AgentStatus"_OutdatedAgent_count.txt "$AgentStatus"_Outdated_Agents.json
done < agentstatus.txt

#group details
echo -e "**************************************************************"
echo -e "			Agent Group metrics			"
echo -e "**************************************************************"
curl -s -k -X GET ""$hostname":"$API_PORT"/groups?pretty=true" -H "Authorization: Bearer $TOKEN" > group_details.json
jq -r '.data | .affected_items | .[] | .name' group_details.json > group_name.txt
echo -e  "Wazuh_group_count=$(wc -l group_name.txt | cut -d ' ' -f1 )" >> Wazuh_Metrics.txt
echo -e  "Wazuh_group_count=$(wc -l group_name.txt | cut -d ' ' -f1 )"
rm group_details.json

#fetching stats from analysisd
echo -e "**************************************************************"
echo -e "			Analysisd metrics				"
echo -e "**************************************************************"
curl -s -k -X GET ""$hostname":"$API_PORT"/manager/stats/analysisd?pretty=true" -H "Authorization: Bearer $TOKEN" > stats.json
jq -r '.data | .affected_items | .[] ' stats.json | tr -d '{}," ' > stats.txt
sed -i -e 's/:/=/g' stats.txt && sed '/^[[:space:]]*$/d' stats.txt > stats_analysisd_draft.txt
p="Wazuh_"
while read s; do
	echo -e $p$s
	echo -e $p$s >> Wazuh_Metrics.txt
done < stats_analysisd_draft.txt
rm stats_analysisd_draft.txt stats.txt stats.json

#printing the final Wazuh metrics file to prometheus
sed -i -e 's/=/ /g' Wazuh_Metrics.txt
echo -e "*************************************************************************************************************"
echo -e "root@"$whoami" :  Wazuh Metrics will be available in the Wazuh_Metrics.txt file in the working directory"
echo -e "*************************************************************************************************************"

#final Prometheus formatted wazuh metrics file
while read metrics;do
	name=$(echo $metrics | cut -d ' ' -f1)
	value=$(echo $metrics | cut -d ' ' -f2)
	echo -e "# HELP "$name >> Wazuh_Metrics_prom.txt
	echo -e "# TYPE "$name $metrictype >> Wazuh_Metrics_prom.txt
	echo -e $metrics >> Wazuh_Metrics_prom.txt
done<Wazuh_Metrics.txt
cat Wazuh_Metrics_prom.txt | curl --data-binary @- $pushgateway/metrics/job/wazuh_custom_metrics/
"*************************************************************************************************************"
echo -e "root@"$whoami" :  Wazuh Metrics with prometheus format will be available in the Wazuh_Metrics_prom.txt file in the working directory"
echo -e "*************************************************************************************************************"
