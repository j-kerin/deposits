select
    distinct pd.id provider_id
    , pd.core_user_id
    , cbup.external_id
    , coalesce(e.email_address, pd.email) email
    , case when pd.plan ='deluxe' then 'premium' else  'basic'  end as sub_type
	, subscription_state, pro_top_service_category, profession_type  
 	, case when pd.autocharge_enabled_time is not null then 1 else 0 end payments_enabled 
 	, pro_payment_segment ,  fraud_pro_flag , pro_profile_segmentation
 	, datediff('day', pd.creation_time, current_date) days_on_SS, ncd_enabled
from provider_dim pd
join common_brazeuserprofile cbup on pd.core_user_id = cbup.user_id
left join analytics.dim_provider dp on dp.provider_id = pd.id
left join (
    select 
      external_user_id
      , email_address
      , row_number() over (partition by external_user_id order by date desc) rn_
    from braze.users_messages_email_send
    -- get the most recent email address for an external_id
) e on e.external_user_id = cbup.external_id and rn_ = 1
left join provider_paymentsettings pps on pps.provider_id = pd.id
where coalesce(e.email_address, pd.email) in (
    --list of emails here
)
