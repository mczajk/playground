UPDATE cstb_param SET param_val = 'N' WHERE param_name = 'IBANPLUS_REQD';

UPDATE cstb_param SET param_val = 'CUSTOM' WHERE param_name = 'STREAM';

commit;
