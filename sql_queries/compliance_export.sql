select array_to_string(array_agg(host_name),', ') AS affected_hosts, ip_address, proof, title, description,severity, compliance from fact_asset_policy_rule
join dim_asset using (asset_id)
join dim_policy_rule using (rule_id)
