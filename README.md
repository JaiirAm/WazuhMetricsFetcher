# WazuhMetricsFetcher
This bash script will help the security analyst to extract the metrics for Prometheus from Wazuh using Wazuh internal APIs.

It was developed in a mindset, where many of the security analyst wants to monitor wazuh environment using prometheus, as it has a great alerting feature to trigger alert via most of the channels like Microsoft Teams, Slack and so on..

There are many ways to extract a metrics from wazuh and push it to prometheus, But i found this method easy and reliable.


## Pre-requisites

1. An environment to run this script.
2. Wazuh environment (Central components + agents) up and running.
3. Wazuh API endpoints, Ports and credentials to interact with APIs.
4. PushGateway exporter - to push the extracted metrics from this script


## Prep & Usage

To successfully run this script, initially we have to hardcode the API endpoint and port details in the script, as it doesnt accepts any runtime arguments

**root@noobie:** nano WazuhMetricsFetcher.sh 

Edit the "hostname", "API_PORT" and "username" "password" (in TOKEN) variables with your environment details.

Then ctrl+o and ctrl+x to save.

**root@noobie:** chmod +x WazuhMetricsFetcher
**root@noobie:** ./WazuhMetricsFetcher

## Sample Output:
Total **58 Metrics** are fetched and prepped to be kept available for prometheus to scrape
**Metrics Format : Wazuh_<Metrics name><space><Metrics value> : Wazuh_nodes_count 5**

**Captured Metrics:**

Wazuh_Cluster_enabled 

Wazuh_Cluster_enabled 

Wazuh_nodes_count 

Wazuh_active_agents 

Wazuh_disconnected_agents 

Wazuh_pending_agents 

Wazuh_never_connected_agents 

Wazuh_total_agents 

Wazuh_synced_agents 

Wazuh_not_synced_agents 

Wazuh_active_outdated_agents 

Wazuh_disconnected_outdated_agents 

Wazuh_never_connected_outdated_agents 

Wazuh_pending_outdated_agents 

Wazuh_total_outdated_agents 

Wazuh_group_count 

Wazuh_total_events_decoded

Wazuh_syscheck_events_decoded 

Wazuh_syscollector_events_decoded 

Wazuh_rootcheck_events_decoded

Wazuh_sca_events_decoded 

Wazuh_winevt_events_decoded 

Wazuh_dbsync_messages_dispatched 

Wazuh_other_events_decoded 

Wazuh_events_processed 

Wazuh_events_received 

Wazuh_events_dropped 

Wazuh_alerts_written 

Wazuh_firewall_written 

Wazuh_fts_written 

Wazuh_syscheck_queue_usage 

Wazuh_syscheck_queue_size 

Wazuh_syscollector_queue_usage 

Wazuh_syscollector_queue_size 

Wazuh_rootcheck_queue_usage 

Wazuh_rootcheck_queue_size 

Wazuh_sca_queue_usage 

Wazuh_sca_queue_size 

Wazuh_hostinfo_queue_usage 

Wazuh_hostinfo_queue_size

Wazuh_winevt_queue_usage 

Wazuh_winevt_queue_size 

Wazuh_dbsync_queue_usage 

Wazuh_dbsync_queue_size 

Wazuh_upgrade_queue_usage 

Wazuh_upgrade_queue_size 

Wazuh_event_queue_usage 

Wazuh_event_queue_size 

Wazuh_rule_matching_queue_usage 

Wazuh_rule_matching_queue_size 

Wazuh_alerts_queue_usage 

Wazuh_alerts_queue_size 

Wazuh_firewall_queue_usage 

Wazuh_firewall_queue_size 

Wazuh_statistical_queue_usage 

Wazuh_statistical_queue_size 

Wazuh_archives_queue_usage 

Wazuh_archives_queue_size 

