CREATE OR REPLACE TRIGGER ictr_racr
after delete on ICTB_ACC_PR
for each row
/*------------------------------------------------------------------------------------------
** This source is part of the Oracle FLEXCUBE Universal Banking Software Product.
** Copyright ? 2001 - 2014  Oracle and/or its affiliates.  All rights reserved.
**
** No part of this work may be reproduced, stored in a retrieval system,
** adopted or transmitted in any form or by any means, electronic, mechanical, photographic, graphic, optic recording or otherwise,
** translated in any language or computer language,
** without the prior written permission of Oracle and/or its affiliates.
**
**
** Oracle Financial Services Software Limited.
** Oracle Park, Off Western Express Highway,
** Goregaon (East),
** Mumbai - 400 063, India.
------------------------------------------------------------------------------------------
*/
/*
   CHANGE_HISTORY
   Modified By        	: Preethymol S
   Modified On        	: 14-Mar-2014
   Modified Reason    	: For differed liquidation cases after actual liquidation date accrued amount is not getting reversed.
						  code chages done to get the accrued amount from entries history where liqn=Y and entry_passed='N'
   Search String      	: 9NT1606_12.0.3_ISGBINTL_18401301_RETRO
-------------------------------------------------------------------------------------------*/
begin

begin  
insert into ictbs_racr(brn,acc,prod,frm_no,accrued_amt)
		select brn,acc,prod,frm_no,accrued_amt
		from ictbs_entries e
		where e.brn=:old.brn and e.acc=:old.acc and e.prod=:old.prod--;
		--ICMTP 3.1 SFR NO 33
		and has_accr = 'Y';
--sygnity
exception
 when dup_val_on_index
   then
     null;--sygnity
end;

delete from ictbs_entries e
where e.brn=:old.brn and e.acc=:old.acc and e.prod=:old.prod;


--9NT1606_12.0.3_ISGBINTL_18401301_RETRO Starts
update ictbs_racr r
set    r.accrued_amt = nvl(accrued_amt,0) +
                       (select nvl(sum(accrued_amt),0)
                        from   ictbs_entries_history e
                        where  e.brn=:old.brn
                        and    e.acc=:old.acc
                        and    e.prod=:old.prod
                        and    e.liqn='Y'
                        and    e.entry_passed='N'
                        and    e.accrued_amt > 0
                        and    e.frm_no = r.frm_no)
where  r.brn=:old.brn
and    r.acc=:old.acc
and    r.prod=:old.prod;
--9NT1606_12.0.3_ISGBINTL_18401301_RETRO ends

end ictr_racr;
/
